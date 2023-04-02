from pathlib import Path
import pandas as pd
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from prefect_gcp import GcpCredentials
import pandas
from datetime import datetime, time
import numpy as np

@task()
def extract_from_gcs(file):
    gcs_path = f"/data/{file}"
    local_path = f"/data/"
    gcs_block = GcsBucket.load("prefect-dtc-de-bucket")
    gcs_block.get_directory(from_path=gcs_path, local_path=local_path)
    return Path(f'/data/{file}')

@task()
def extract_from_file(path:Path) -> pd.DataFrame:
    df = pd.read_csv(path)
    return df

@task()
def write_bq(df:pd.DataFrame)->None:
    gcp_credentials_block = GcpCredentials.load("gcp-cred")
    project_id="dtc-de-376914"
    processed_df = df.to_gbq(
        destination_table=f"{project_id}.bd.sales",
        project_id=project_id,
        credentials=gcp_credentials_block.get_credentials_from_service_account(),
        chunksize=500000,
        if_exists="append"
    )

@task()
def preprocess_data(sales_df:pd.DataFrame)->pd.DataFrame:
    # drop duplicate events
    sales_df.drop_duplicates(inplace=True)
    # percentage of missing data
    print(f"Percentage of missing data")
    print(100*sales_df.isna().sum()/len(sales_df))
    print()
    # some price and user_data has shifted into category_code and brand data
    # following lines validates same
    sales_df[sales_df.price.isna()].category_code.apply(lambda x: float(x))
    sales_df[sales_df.price.isna()].brand.apply(lambda x: np.NaN if x is None else float(x))
    sales_df_fixed = sales_df.copy()
    # the fix 
    sales_df_fixed['user_id'] = sales_df.apply(lambda row: float(row['brand']) if np.isnan(row['price']) else row['user_id'], axis=1)
    sales_df_fixed['price'] = sales_df.apply(lambda row: float(row['category_code']) if np.isnan(row['price']) else row['price'], axis=1)    
    sales_df_fixed['brand'] = sales_df.apply(lambda row: 'unknown' if np.isnan(row['price']) else row['brand'], axis=1)
    sales_df_fixed['category_code'] = sales_df.apply(lambda row: 'unknown' if np.isnan(row['price']) else row['category_code'], axis=1)
    sales_df_fixed.category_code.fillna('unknown', inplace=True)
    sales_df_fixed.brand.fillna('unknown', inplace=True)    
    # percentage of missing data
    print(f"Percentage of missing data after pre processing")
    print(100*sales_df_fixed.isna().sum()/len(sales_df_fixed))
    print()
    # sales_df_fixed[sales_df_fixed.user_id.isna()]
    # fix event_time
    sales_df_fixed = sales_df_fixed.astype({
            'order_id':    pd.Int64Dtype(),
            'product_id':  pd.Int64Dtype(),
            'category_id':  pd.Float64Dtype(),
            'category_code':str,
            'brand':       str,
            'price':    pd.Float64Dtype(),
            'user_id':  pd.Float64Dtype()
    })
    sales_df_fixed['event_time'] = pd.to_datetime(sales_df_fixed['event_time'], format="%Y-%m-%d %H:%M:%S UTC")

    return sales_df_fixed


@flow(log_prints=True)
def etl_gcs_to_bq():
    data_filename="kz.csv"
    path = extract_from_gcs(data_filename)
    print(f"path {path}")
    data = extract_from_file(path)
    data = preprocess_data(data)
    write_bq(data)
    rows_processed = len(data)
    print(f"processed rows: {rows_processed}")

if __name__ == '__main__':
    etl_gcs_to_bq()