API_URL="http://127.0.0.1:80/stocks"

# Define JSON body for the stock entry
DATA='{"symbol": "AAPL", "purchase price": 150.0, "shares": 10}'


# Run two requests concurrently
# curl -i -X POST -H "Content-Type: application/json" -d "$DATA" $API_URL &
# curl -i -X POST -H "Content-Type: application/json" -d "$DATA" $API_URL &
############################################################################

#curl -X DELETE -H "Content-Type: application/json"  '$http://127.0.0.1:80/stocks/679d08a728df3afe4cc87dd3 &
#curl -X PUT -H "Content-Type: application/json" -d   $API_URL &

DATA2='{"name: "a", "purchase date":"10-10-3443", "symbol": "AAPL", "purchase price": 150.0, "shares": 10, "id": "679d2c4728df3afe4cc87dd7"}'

URL2="http://127.0.0.1:80/stocks/679d3157cb89f3d27ee36f36"

#curl -X DELETE -H "Content-Type: application/json" $URL2 &
# Corrected PUT request
#curl -X PUT -H "Content-Type: application/json" -d "$DATA2" $URL2 &

curl -i -X DELETE "http://localhost:80/stocks/679d50e8f5bed9ec6e560bf1"

curl -i -X PUT "http://localhost:80/stocks/679d50e8f5bed9ec6e560bf1" \
     -H "Content-Type: application/json" \
     -d '{"id": "679d50e8f5bed9ec6e560bf1", "name": "Apple Inc.", "purchase date": "25-12-2024", "purchase price": 140.0, "shares": 35, "symbol": "AAPL"}' &

wait

