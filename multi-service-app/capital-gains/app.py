

import requests
from flask import Flask, jsonify, request
import json
import os


app = Flask(__name__)


STOCKS_URL = os.getenv("STOCKS_URL", "http://stocks-service.stocks-system.svc.cluster.local:80")

# capital gain of a stock is: = (current_stock_value - pruchase_price)

def calculate_capital_gain(stock):
	stock_id = stock['id']
	try:
		response = requests.get(f"{STOCKS_URL}/stock-value/{stock_id}")
		response.raise_for_status()
		stock_data = response.json()

		curr_stock_value = stock_data['stock value']
		total_stock_shares_purchase_price = stock['purchase price'] * stock['shares']
		capital_gain = curr_stock_value - total_stock_shares_purchase_price   # (number of shares * share price) - (purchase price * number of shares)

		return capital_gain

	except requests.exceptions.RequestException as e:
		print(f"Error trying to retrieve stock value for {stock_id}: {e}")
		return None



@app.route('/capital-gains', methods=['GET'])
def capital_gains():
	querys = request.args
	portfolio = querys.get('portfolio')
	numsharesgt = querys.get('numsharesgt', type=int)
	numshareslt = querys.get('numshareslt', type=int)


	# if portfolio == 'stocks1': portfolios.append(STOCKS1_URL)
	# if portfolio == 'stocks2': portfolios.append(STOCKS2_URL)
	# if not portfolio:
	# 	portfolios.append(STOCKS1_URL)
	# 	portfolios.append(STOCKS2_URL)

	total = 0
	# for url in portfolios:
	try:
		response = requests.get(f"{STOCKS_URL}/stocks")
		response.raise_for_status()
		stocks = response.json()
		for stock in stocks:
			if numsharesgt and stock['shares'] <= numsharesgt:
				continue
			if numshareslt and stock['shares'] >= numshareslt:
				continue

			capital_gain = calculate_capital_gain(stock)
			if capital_gain is not None:
				total += capital_gain

	except requests.exceptions.RequestException as e:
		return jsonify({"error": f"Failed to retreive stocks from {STOCKS_URL}: {e}"}), 500


	return str(float(total))



if __name__ == '__main__':
	app.run(debug=True, port=8080, host="0.0.0.0")