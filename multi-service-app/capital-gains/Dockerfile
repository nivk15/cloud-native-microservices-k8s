FROM python:alpine3.17

WORKDIR /app

COPY app.py .

RUN pip install requests
RUN pip install flask


ENV FLASK_APP=app.py
ENV FLASK_RUN_PORT=8080


EXPOSE 8080

CMD ["flask", "run", "--host=0.0.0.0"]