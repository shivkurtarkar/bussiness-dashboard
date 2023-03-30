from pathlib import Path
import pandas as pd
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from prefect_gcp import GcpCredentials
import pandas

@task()
def extract_from_gcs(file):
    gcs_path = f"/data/{file}"
    local_path = f"/data/"
    gcs_block = GcsBucket.load("prefect-dtc-de-bucket")
    gcs_block.get_directory(from_path=gcs_path, local_path=local_path)
    return Path(f'data/{gcs_path}')

@task()
def extract_from_file(path:Path):
    df = pd.csv(path)
    return df

@task()
def write_bq(data:pd.DataFrame)->None:
    gcp_credentials_block = GcpCredentials.load("gcp-creds")
    processed_df = df.to_gbq(
        destination_table="dtc-de-376914.dtcde.rides",
        project_id="dtc-de-376914",
        credentials=gcp_credentials_block.get_credentials_from_service_account(),
        chunksize=500000,
        if_exists="append"
    )


@flow(log_prints=True)
def etl_gcs_to_bq():
    path = extract_from_gcs()
    print(f"path {path}")
    data = extract_from_file(path)
    write_bq(data)
    rows_processed = len(data)
    print(f"processed rows: {rows_processed}")

if __name__ == '__main__':
    etl_gcs_to_bq()