API_URL="http://127.0.0.1:80/stocks"

# Define JSON body for the stock entry
DATA='{"symbol": "AAPL", "purchase price": 150.0, "shares": 10}'


# Run two requests concurrently
curl -i -X POST -H "Content-Type: application/json" -d "$DATA" $API_URL &
curl -i -X POST -H "Content-Type: application/json" -d "$DATA" $API_URL &


wait

