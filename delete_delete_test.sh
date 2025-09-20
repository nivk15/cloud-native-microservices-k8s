STOCK_ID="679d56f5b61876e82b855432"

# DELETE stock twice
curl -i -X DELETE "http://localhost:80/stocks/$STOCK_ID" &
curl -i -X DELETE "http://localhost:80/stocks/$STOCK_ID" &
wait
