FROM python:3.9

RUN pip install pandas

COPY docker-requirements.txt requirements.txt
RUN pip install -r requirements.txt

RUN apt-get update && apt-get install -y make wget

WORKDIR /app

# COPY pipeline.py pipeline.py

ENTRYPOINT [ "dbt", "run"]
