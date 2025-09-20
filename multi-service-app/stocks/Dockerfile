FROM python:alpine3.17

WORKDIR /app

COPY app.py .

RUN pip install requests
RUN pip install flask
RUN pip install pymongo


ENV FLASK_APP=app.py
ENV FLASK_RUN_PORT=8000


#ENV MONGO_COLLECTION="stocks"
# default -> will be overriden from docker-compose.

EXPOSE 8000

CMD ["flask", "run", "--host=0.0.0.0"]