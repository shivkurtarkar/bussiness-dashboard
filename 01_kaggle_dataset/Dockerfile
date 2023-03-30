FROM python

WORKDIR /app

# COPY pipeline.py pipeline.py

# ENTRYPOINT [ "python", "pipeline.py"]

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY download_kaggle_dataset.py download_kaggle_dataset.py

ENTRYPOINT [ "python", "download_kaggle_dataset.py"]