#!/usr/bin/env bash
set -euo pipefail

NS="stocks-system"
BASE="http://localhost:80"

CURL_COMMON=(--silent --show-error --connect-timeout 2 --max-time 12)
hr(){ echo; echo "------------------------------------------------------------"; echo; }

fail() { echo "❌ $*"; exit 1; }
ok()   { echo "✅ $*"; }

require_ns() {
  kubectl get ns "$NS" >/dev/null 2>&1 || fail "Namespace $NS not found. Run: bash test-submission.sh"
}

wait_deploy() {
  local name="$1"
  kubectl wait -n "$NS" --for=condition=available "deployment/$name" --timeout=120s >/dev/null 2>&1 \
    || fail "Deployment $name not available (timeout)"
}

# Detect whether single-stock resource is /stocks/{id} or /stock/{id}
detect_stock_id_base() {
  local tmp_id
  # Create a temp stock and see which GET works.
  tmp_id=$(curl "${CURL_COMMON[@]}" -X POST "$BASE/stocks" \
    -H "Content-Type: application/json" \
    -d '{"symbol":"TMP","purchase price":1.0,"shares":1,"name":"Temp","purchase date":"01-01-2000"}' \
    | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

  [[ -n "${tmp_id:-}" ]] || fail "Could not create temp stock to detect endpoint style."

  if curl "${CURL_COMMON[@]}" -o /dev/null -w "%{http_code}" "$BASE/stocks/$tmp_id" | grep -q '^200$'; then
    echo "stocks"   # base path: /stocks/{id}
  elif curl "${CURL_COMMON[@]}" -o /dev/null -w "%{http_code}" "$BASE/stock/$tmp_id" | grep -q '^200$'; then
    echo "stock"    # base path: /stock/{id}
  else
    # cleanup attempt then fail
    curl "${CURL_COMMON[@]}" -X DELETE "$BASE/stocks/$tmp_id" >/dev/null 2>&1 || true
    curl "${CURL_COMMON[@]}" -X DELETE "$BASE/stock/$tmp_id"  >/dev/null 2>&1 || true
    fail "Neither /stocks/{id} nor /stock/{id} responded with 200. Check routing."
  fi
}

post_stock() {
  local payload="$1"
  local resp id
  resp=$(curl "${CURL_COMMON[@]}" -X POST "$BASE/stocks" -H "Content-Type: application/json" -d "$payload")
  id=$(echo "$resp" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  [[ -n "${id:-}" ]] || fail "POST /stocks failed. Response: $resp"
  echo "$id"
}

get_stocks_list() {
  curl "${CURL_COMMON[@]}" "$BASE/stocks"
}

get_stock_by_id() {
  local base="$1" id="$2"
  curl "${CURL_COMMON[@]}" "$BASE/$base/$id"
}

put_stock_full_update() {
  local base="$1" id="$2" payload="$3"
  curl "${CURL_COMMON[@]}" -X PUT "$BASE/$base/$id" -H "Content-Type: application/json" -d "$payload"
}

delete_stock() {
  local base="$1" id="$2"
  curl "${CURL_COMMON[@]}" -o /dev/null -w "%{http_code}" -X DELETE "$BASE/$base/$id"
}

cleanup_all_stocks() {
  local base="$1"
  local list ids
  list=$(get_stocks_list)

  # extract all "id":"..." occurrences
  ids=$(echo "$list" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' | tr '\n' ' ')
  # above sed is too greedy for arrays; use a safer extraction:
  ids=$(echo "$list" | grep -oE '"id":"[^"]+"' | cut -d'"' -f4 | tr '\n' ' ')

  if [[ -z "${ids// }" ]]; then
    ok "No existing stocks to cleanup."
    return
  fi

  echo "Cleaning up existing stocks..."
  for id in $ids; do
    code=$(delete_stock "$base" "$id" || true)
    echo "  DELETE $base/$id -> $code"
  done
}

echo "==[0] Verify cluster + wait for deployments =="
require_ns
# wait for key deployments
wait_deploy "nginx-deployment"
wait_deploy "stocks-deployment"
wait_deploy "capital-gains-deployment"
wait_deploy "mongodb"

kubectl get pods -n "$NS" -o wide
hr

echo "==[1] NGINX routing sanity (GET /stocks, GET /capital-gains) =="
curl "${CURL_COMMON[@]}" -i "$BASE/stocks" | head -n 20
echo
curl "${CURL_COMMON[@]}" -i "$BASE/capital-gains" | head -n 20
hr

echo "==[2] Detect ID endpoint style (/stocks/{id} vs /stock/{id}) =="
ID_BASE=$(detect_stock_id_base)
ok "Using /$ID_BASE/{id} for single-stock operations."
# cleanup temp stock(s) that were created in detection
# easiest: cleanup all (we do cleanup anyway next)
hr

echo "==[3] Optional cleanup (start from clean DB) =="
cleanup_all_stocks "$ID_BASE"
echo "Current /stocks:"
get_stocks_list | head -c 600; echo
hr

echo "==[4] Create 3 stocks (POST /stocks) =="
ID1=$(post_stock '{"symbol":"AAPL","purchase price":100.00,"shares":3,"name":"Apple Inc","purchase date":"22-02-2024"}')
ID2=$(post_stock '{"symbol":"MSFT","purchase price":200.00,"shares":5,"name":"Microsoft","purchase date":"10-01-2024"}')
ID3=$(post_stock '{"symbol":"NVDA","purchase price":300.00,"shares":2,"name":"NVIDIA","purchase date":"05-03-2024"}')

echo "Created:"
echo "  AAPL id=$ID1"
echo "  MSFT id=$ID2"
echo "  NVDA id=$ID3"
hr

echo "==[5] List all (GET /stocks) =="
get_stocks_list | head -c 800; echo
hr

echo "==[6] Get by id (GET /{base}/{id}) =="
echo "GET /$ID_BASE/$ID1:"
get_stock_by_id "$ID_BASE" "$ID1" | head -c 600; echo
hr

echo "==[7] Update one stock (PUT /{base}/{id}) full update כולל id =="
UPDATED_PAYLOAD=$(cat <<EOF
{"id":"$ID2","symbol":"MSFT","purchase price":210.00,"shares":7,"name":"Microsoft (updated)","purchase date":"10-01-2024"}
EOF
)

echo "PUT /$ID_BASE/$ID2 payload:"
echo "$UPDATED_PAYLOAD"
echo
echo "PUT response:"
put_stock_full_update "$ID_BASE" "$ID2" "$UPDATED_PAYLOAD" | head -c 400; echo
echo
echo "Verify GET /$ID_BASE/$ID2:"
get_stock_by_id "$ID_BASE" "$ID2" | head -c 600; echo
hr

echo "==[8] Stock value (GET /stock-value/{id}) =="
echo "GET /stock-value/$ID1:"
curl "${CURL_COMMON[@]}" "$BASE/stock-value/$ID1" | head -c 600; echo
hr

echo "==[9] Portfolio value (GET /portfolio-value) =="
curl "${CURL_COMMON[@]}" "$BASE/portfolio-value" | head -c 600; echo
hr

echo "==[10] Capital gains (GET /capital-gains) =="
curl "${CURL_COMMON[@]}" -i "$BASE/capital-gains" | head -n 30
hr

echo "==[11] Delete one stock and verify (DELETE + GET-by-id should fail) =="
echo "DELETE /$ID_BASE/$ID3 -> status:"
del_code=$(delete_stock "$ID_BASE" "$ID3" || true)
echo "$del_code"

echo "Verify GET /$ID_BASE/$ID3 (expect non-200):"
get_code=$(curl "${CURL_COMMON[@]}" -o /dev/null -w "%{http_code}" "$BASE/$ID_BASE/$ID3" || true)
echo "$get_code"
if [[ "$get_code" == "200" ]]; then
  echo "⚠️  Warning: GET after delete returned 200. Check delete implementation."
else
  ok "GET after delete is non-200 as expected."
fi

echo "Current /stocks after delete:"
get_stocks_list | head -c 800; echo
hr

echo "==[12] Persistence demo: delete Mongo pod and verify /stocks unchanged =="
BEFORE=$(get_stocks_list)
MONGO_POD=$(kubectl get pods -n "$NS" -o name | grep -E 'mongo|mongodb' | head -n 1 || true)
[[ -n "${MONGO_POD:-}" ]] || fail "Could not find mongo pod."

echo "Deleting $MONGO_POD ..."
kubectl delete "$MONGO_POD" -n "$NS" >/dev/null

echo "Waiting for MongoDB pod to be Running..."
for i in {1..60}; do
  if kubectl get pods -n "$NS" | grep -E 'mongo|mongodb' | grep -q 'Running'; then
    break
  fi
  sleep 2
done

AFTER=$(get_stocks_list)
if [[ "$BEFORE" == "$AFTER" ]]; then
  ok "Persistence OK: /stocks unchanged after Mongo pod restart (PV/PVC working)."
else
  echo "⚠️  Warning: /stocks changed after Mongo restart. Check PV/PVC."
fi
hr

echo "==[13] Resilience demo: delete one stocks pod, system should continue working =="
STOCKS_POD=$(kubectl get pods -n "$NS" -o name | grep -E 'stocks-deployment' | head -n 1 || true)
if [[ -n "${STOCKS_POD:-}" ]]; then
  echo "Deleting $STOCKS_POD ..."
  kubectl delete "$STOCKS_POD" -n "$NS" >/dev/null
  sleep 4
  echo "GET /stocks after deleting a stocks pod:"
  get_stocks_list | head -c 600; echo
  ok "System still responds => Deployment self-healing / replicas working."
else
  echo "⚠️  Could not find a stocks pod to delete (skipping)."
fi

hr
echo "== DONE =="
