STOCK_ID="679d4f18b61876e82b85542d"

DATA1='{
	"id": "'"$STOCK_ID"'",
	"name": "first update",
	"symbol": "AAPL",
	"purchase date": "25-12-2020",
	"purchase price": 140.0,
	"shares": 30
}'

DATA2='{
	"id": "'"$STOCK_ID"'",
	"name": "second update",
	"symbol": "AAPL",
	"purchase date": "25-12-9999",
	"purchase price": 999.0,
	"shares": 55
}'



# PUT two different updates simultaneously
curl -i -X PUT -H "Content-Type: application/json" -d "$DATA1" "http://localhost:80/stocks/$STOCK_ID" &
curl -i -X PUT -H "Content-Type: application/json" -d "$DATA2" "http://localhost:80/stocks/$STOCK_ID" &
wait

# GET final stock data
curl -i -X GET "http://localhost:80/stocks/$STOCK_ID"
