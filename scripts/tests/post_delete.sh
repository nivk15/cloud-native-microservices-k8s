STOCK_ID="679d5639f5bed9ec6e560bf3"

DATA='{"name": "New Stock", "symbol": "MSFT", "purchase price": 150.0, "shares": 50, "purchase date": "01-03-2024"}'

# POST new stock
curl -i -X POST -H "Content-Type: application/json" -d "$DATA" "http://localhost:80/stocks" &

# DELETE a different stock
curl -i -X DELETE "http://localhost:80/stocks/$STOCK_ID" &
wait

# GET newly created stock
curl -i -X GET "http://localhost:80/stocks"
