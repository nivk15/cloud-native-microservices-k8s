STOCK_ID="679d5639f5bed9ec6e560bf3"

# Define JSON payload manually, inserting STOCK_ID directly
DATA='{
	"id": "'"$STOCK_ID"'",
	"name": "Updated Name",
	"symbol": "AAPL",
	"purchase date": "25-12-2024",
	"purchase price": 140.0,
	"shares": 35
	}'

# GET stock before update
echo "Before PUT:"
curl -i -X GET "http://localhost:80/stocks/$STOCK_ID"

# PUT request (update stock)
echo "Updating stock..."
curl -i -X PUT -H "Content-Type: application/json" -d "$DATA" "http://localhost:80/stocks/$STOCK_ID"

# GET stock after update
echo "After PUT:"
curl -i -X GET "http://localhost:80/stocks/$STOCK_ID"
