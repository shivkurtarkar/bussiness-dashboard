FROM python

WORKDIR /app

# COPY pipeline.py pipeline.py

# ENTRYPOINT [ "python", "pipeline.py"]

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY etl_gcs_to_bq.py etl_gcs_to_bq.py

ENTRYPOINT [ "python", "etl_gcs_to_bq.py"]