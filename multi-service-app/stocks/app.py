# Name: Niv Kirshenbaum
# ID: 315328336


import requests
from flask import Flask, jsonify, request
import json
from datetime import datetime
import os
import pymongo
from pymongo import MongoClient
from bson import ObjectId
from bson.errors import InvalidId


try:
    MONGO_URI = os.getenv("MONGO_URI")  # get the api key from the dockerfile
except KeyError:
    raise Exception("MONGO_URI enviroment variable is not defined")

client = MongoClient(MONGO_URI)   #TODO: change localhost to the name given in the docker-compose to the mongo service.
db = client["stocks"]

collection_name = os.getenv

try:
    COLLECTION_NAME = os.getenv("MONGO_COLLECTION")  # get the api key from the dockerfile
except KeyError:
    raise Exception("MONGO_COLLECTION environment variable is not defined")

stocks_collection = db[COLLECTION_NAME]

stocks_collection.create_index([("symbol", pymongo.ASCENDING)], unique=True)   # add unique index to the field: "symbol" to prevent duplicates



app = Flask(__name__)


try:
    API_KEY = os.getenv("NINJA_API_KEY")  # get the api key from the dockerfile
except KeyError:
    raise Exception("API_KEY environment variable is not defined.")


curr_id = 0
######################################################################################################
# helper functions:

def generate_new_id():
    global curr_id
    curr_id += 1
    return str(curr_id)


def get_share_price(stock_symbol):
    api_url = 'https://api.api-ninjas.com/v1/stockprice?ticker={}'.format(stock_symbol)
    try:
        response = requests.get(api_url, headers={'X-Api-Key': API_KEY})
        if response.status_code == requests.codes.ok:
            return(response.json().get('price'))
        else:
            return jsonify({"server error": "API response code " + str(response.status_code)}), 500
    except Exception as e:
        print("Exception: ", str(e))
        return jsonify({"server error": str(e)}), 500


def validate_date(date):
    try:
        datetime.strptime(date.strip(), "%d-%m-%Y")
        return True
    except ValueError:
        return False


####################################################################
# Resource : /stocks

@app.route('/stocks', methods=['GET'])
def get_stocks():
    try:
        stocks = list(stocks_collection.find({}))  # matches all documents in the collection.
        for stock in stocks:
            # stock['_id'] = str(stock['_id'])
            stock['id'] = str(stock.pop('_id'))
        return jsonify(stocks), 200
    except Exception as e:
        return jsonify({"server error": str(e)}), 500


@app.route('/stocks', methods=['POST'])
def add_stock():
    try:
        content_type = request.headers.get('Content-Type')
        if content_type != 'application/json':
            return jsonify({"error": "Expected application/json media type"}), 415
        data = request.get_json()

        required_fields = ['symbol', 'purchase price', 'shares']
        if not all(field in data for field in required_fields):
            return jsonify({"error": "Malformed data"}), 400

        if 'purchase date' in data:
            if validate_date(data['purchase date']) == False:    # if 'purchase date' is in date, check if it's in the required format.
                return jsonify({"error": "Malformed data"}), 400

        if isinstance(data['purchase price'], float) == False:    #check if it is of type float.
            return jsonify({"error": "Malformed data"}), 400

        if isinstance(data['shares'], int) == False:    #check if it is of type float.
            return jsonify({"error": "Malformed data"}), 400


        if 'id' in data:  # check if there's wrong field in the payload. ('id' the only field that cannot be added to post request)
            return jsonify({"error": "Malformed data"}), 400


        # # checking if symbol already exists in the portfolio
        # stock_symbol_exists = stocks_collection.find_one({'symbol': data['symbol'].upper()})
        # if stock_symbol_exists:
        #     return jsonify({"error": "Stock with the same symbol already exists."}), 400

        new_stock = {
            'name': data.get('name', 'NA'),
            'purchase date': data.get('purchase date', 'NA'),
            'purchase price': round(data['purchase price'], 2),
            'shares': data['shares'],
            'symbol': data['symbol'].upper()
        }

        try:
            # ensuring uniqness of symbol when insrting
            inserted_id = stocks_collection.insert_one(new_stock).inserted_id
            return jsonify({'id': str(inserted_id)}), 201

        except pymongo.errors.DuplicateKeyError:
            return jsonify({"error": "Stock with the same symbol already exists."}), 400

        # inserted_id = stocks_collection.insert_one(new_stock).inserted_id
        #
        # return jsonify({'id': str(inserted_id)}), 201

    except Exception as e:
        print("Exception: ", str(e))
        return jsonify({"server error": str(e)}), 500


#######################################################################
# Resource: /stocks/{id}

@app.route('/stocks/<string:stock_id>', methods=['GET'])
def get_stock(stock_id):
    try:
        object_id = ObjectId(stock_id)
    except InvalidId:
        print("GET request error: No such ID")
        return jsonify({"error": "Not found"}), 404

    try:
        stock = stocks_collection.find_one({'_id': object_id})
        if stock:
            # stock['_id'] = str(stock['_id'])
            stock['id'] = str(stock.pop('_id'))
            return jsonify(stock), 200
        print("GET request error: No such ID")
        return jsonify({"error": "Not found"}), 404

    except Exception as e:
        print("Exception: ", str(e))
        return jsonify({"server error": str(e)}), 500


@app.route('/stocks/<string:stock_id>', methods=['DELETE'])
def delete_stock(stock_id):
    try:
        object_id = ObjectId(stock_id)
    except invalidId:
        print("GET request error: No such ID")
        return jsonify({"error": "Not found"}), 404

    try:
        result = stocks_collection.delete_one({'_id': object_id})
        if result.deleted_count == 0:
            print("DELETE request error: No such ID")
            return jsonify({"error": "Not found"}), 404
        return '', 204

    except Exception as e:
        print("Exception: ", str(e))
        return jsonify({"server error": str(e)}), 500


@app.route('/stocks/<string:stock_id>', methods=['PUT'])
def update(stock_id):
    try:
        object_id = ObjectId(stock_id)
    except InvalidId:
        print("GET request error: No such ID")
        return jsonify({"error": "Not found"}), 404

    try:
        content_type = request.headers.get('Content-Type')
        if content_type != 'application/json':
            return jsonify({"error": "Expected application/json media type"}), 415
        data = request.get_json()
        required_fields = ['id', 'name', 'symbol', 'purchase price', 'purchase date', 'shares']
        if not all(field in data for field in required_fields):
            return jsonify({"error": "Malformed data"}), 400

        if validate_date(data['purchase date']) == False:    # check if it's in the required format.
            return jsonify({"error": "Malformed data"}), 400

        if isinstance(data['purchase price'], float) == False:    # check if it is of type float.
            return jsonify({"error": "Malformed data"}), 400

        if isinstance(data['shares'], int) == False:    # check if it is of type int.
            return jsonify({"error": "Malformed data"}), 400


##################################################
        # Check if stock_id exists
        stock_id_exists = stocks_collection.find_one({'_id': object_id})
        if not stock_id_exists:
            print("PUT request error: No such ID")
            return jsonify({"error": "Not found"}), 404


        # checking if symbol already exists in the portfolio (exclude the stock_id that we're updating!)
        stock_symbol_exists = stocks_collection.find_one({'symbol': data['symbol'].upper(), '_id': {'$ne': ObjectId(stock_id)}})
        if stock_symbol_exists:
            return jsonify({"error": "Stock with the same symbol is already exists."}), 400
##################################################

        update_stock = {
            'name': data['name'],
            'purchase date': data['purchase date'],
            'purchase price': round(data['purchase price'], 2),
            'shares': data['shares'],
            'symbol': data['symbol'].upper()
        }

        # stocks_collection.update_one({'_id': ObjectId(stock_id)}, {'$set': update_stock})
        #
        # response = {"id": stock_id}
        # return jsonify(response), 200

        result = stocks_collection.update_one({'_id': ObjectId(stock_id)}, {'$set': update_stock})

        if result.matched_count == 0:
            return jsonify({"error": "Stock not found"}), 404  # This only happens if the stock was deleted

        if result.modified_count == 0:
            return jsonify({"message": "No changes made"}), 200  # Still a successful PUT

        return jsonify({"message": "Stock updated successfully"}), 200

    except Exception as e:
        print("Exception: ", str(e))
        return jsonify({"server error": str(e)}), 500


############################################################################################################

# Resource /stock-value/{id}
@app.route('/stock-value/<string:stock_id>', methods=['GET'])
def get_stock_val(stock_id):
    try:
        object_id = ObjectId(stock_id)
    except InvalidId:
        print("GET request error: No such ID")
        return jsonify({"error": "Not found"}), 404

    try:
        stock = stocks_collection.find_one({'_id': object_id})
        if not stock:
            print("GET request error: No such ID")
            return jsonify({"error": "Not found"}), 404

        ticker = get_share_price(stock['symbol'])
        if isinstance(ticker, float) == False:
            return ticker  # server error

        stock_value = stock['shares'] * ticker

        response_data = {
            "symbol": stock['symbol'],
            "ticker": ticker,
            "stock value": stock_value
        }
        return jsonify(response_data), 200

    except Exception as e:
        print("Exception: ", str(e))
        return jsonify({"server error": str(e)}), 500


############################################################################################################
# Resource /portfolio-value
@app.route('/portfolio-value', methods=['GET'])
def get_portfolio_val():
    try:
        date = datetime.today().strftime('%d-%m-%Y')  # date in format : mm-dd-yyyy

        total = 0
        stocks = stocks_collection.find({})  # matches all the documents in the collection.
        for stock in stocks:
            # stock['_id'] = str(stock['_id'])
            ticker = get_share_price(stock['symbol'])
            if isinstance(ticker, float) == False:
                return ticker  # server error
            total += ticker * stock['shares']

        response = {
            "date": date,
            "portfolio value": round(total, 2)
        }
        return jsonify(response), 200

    except Exception as e:
        print("Exception: ", str(e))
        return jsonify({"server error": str(e)}), 500


#############################################################################################################
@app.route('/kill', methods=['GET'])
def kill_container():
    os._exit(1)



###############################################################################################################
if __name__ == "__main__":
    print("running stocks server")
    PORT_NUMBER = int(os.getenv("FLASK_RUN_PORT", 8000))
    HOST = str(os.getenv("HOST"))
    app.run(debug=True, port=PORT_NUMBER, host="0.0.0.0")
