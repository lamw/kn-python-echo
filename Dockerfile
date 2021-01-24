FROM python:3

COPY . .
RUN pip install -r requirements.txt

ENV FLASK_ENV=development
ENV FLASK_APP=handler.py
ENV PORT=8080

ENTRYPOINT python3 -m flask run --host=0.0.0.0 --port=${PORT}