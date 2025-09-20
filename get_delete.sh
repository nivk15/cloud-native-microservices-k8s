STOCK_ID="679d546db61876e82b855430"

# GET stock before deletion
curl -i -X GET "http://localhost:80/stocks/$STOCK_ID" &

# DELETE the stock
curl -i -X DELETE "http://localhost:80/stocks/$STOCK_ID" &

# GET stock after deletion
curl -i -X GET "http://localhost:80/stocks/$STOCK_ID" &
wait
