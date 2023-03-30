import kaggle
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket

@task()
def download_kaggle_dataset(dataset_name:str, output_dir:str) -> None:
    kaggle.api.authenticate()
    kaggle.api.dataset_download_files(dataset_name, path=output_dir, unzip=True)
    files = kaggle.api.dataset_list_files(dataset_name)
    return f'{output_dir}/{files.files[0]}'

@task()
def write_gcs(path: str) -> None:
    """Upload local file to GCS"""    
    gcs_block = GcsBucket.load("prefect-dtc-de-bucket")
    gcs_block.upload_from_path(from_path=f"{path}", to_path=path)
    return

@flow()
def etl_kaggle_to_gcs(dataset_name:str, output_dir:str):
    dataset_filepath = download_kaggle_dataset(dataset_name, output_dir)    
    print(f'files: {dataset_filepath}')
    # write_gcs(dataset_filepath)


if __name__ == '__main__':
    DATASET_NAME='mkechinov/ecommerce-purchase-history-from-electronics-store'
    DATA_DIR='/data'
    etl_kaggle_to_gcs(DATASET_NAME, DATA_DIR)