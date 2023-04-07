from prefect.infrastructure.docker import DockerContainer
from prefect_gcp.cloud_storage import GcsBucket, GcpCredentials
from pathlib import Path
from prefect.infrastructure.docker import DockerRegistry
from dotenv import load_dotenv
import os

load_dotenv()

repository_name=os.getenv('REPOSITORY_NAME')
kaggle_key_dir=os.getenv('KAGGLE_CREDENTIAL_DIR')
gcp_project_id=os.getenv('GCP_PROJECT_ID')
gcp_key_json_path=os.getenv('GCP_CREDENTIAL_JSON')


dbt_profiles_dir=os.getenv('DBT_PROFILE_DIR', default=f'{os.getcwd()}/04_dbt_project/docker-setup/.dbt')

print()
print(f'repository_name     :   {repository_name}')
print(f'kaggle_key_dir      :   {kaggle_key_dir}')
print(f'gcp_project_id      :   {gcp_project_id}')
print(f'gcp_key_json_path   :   {gcp_key_json_path}')
print(f'dbt_profiles_dir    :   {dbt_profiles_dir}')
print()



gcp_bucket_name='prefect-dtc-de-x0'
GOOGLE_CRED_DOCKER_PATH="/.google/credentials/google_credentials.json"

bq_import_step_block_name="bq-import-step"
dbt_run_step_block_name="dbt-run-step"
kaggle_download_step_block_name="kaggle-download-step"
gcs_block_name='prefect-dtc-de-bucket'
gcp_credentials_block_name='gcp-cred'


kaggle_data_import_docker_block = DockerContainer(
    image=f"{repository_name}/kaggle_download_step",
    networks=[
        "pg-network"
    ],
    volumes=[
    f"{kaggle_key_dir}:/root/.kaggle",
    f"{gcp_key_json_path}:{GOOGLE_CRED_DOCKER_PATH}"
    ],
    auto_remove=True,
)

kaggle_data_import_docker_block.save(kaggle_download_step_block_name, overwrite=True)
print('created kaggle import step docker block')


gcp_bq_import_docker_block = DockerContainer(
    image=f"{repository_name}/gcp_bq_import",
    networks=[
        "pg-network"
    ],
    volumes=[
        f"{gcp_key_json_path}:{GOOGLE_CRED_DOCKER_PATH}"
    ],
    auto_remove=True,
)
gcp_bq_import_docker_block.save(bq_import_step_block_name, overwrite=True)
print('created gcp bq import step docker block')


dbt_docker_block = DockerContainer(
    image=f"{repository_name}/dbt-local:dev",
    networks=[
        "pg-network"
    ],
    volumes=[
        f"{gcp_key_json_path}:{GOOGLE_CRED_DOCKER_PATH}",
        f"{dbt_profiles_dir}:/root/.dbt"
    ],
    env={
        "GCP_PROJECT_ID":gcp_project_id
    },
    auto_remove=True,
)
dbt_docker_block.save(dbt_run_step_block_name, overwrite=True)
print('created dbt run step docker block')



gcp_credentials_block = GcpCredentials(
    service_account_file=Path(gcp_key_json_path),
    verify=False
)
gcp_credentials_block.service_account_file=GOOGLE_CRED_DOCKER_PATH
gcp_credentials_block.save(gcp_credentials_block_name, overwrite=True )
print('created gcs cred block')


gcs_bucket_block = GcsBucket(
    bucket=gcp_bucket_name, 
    gcp_credentials=gcp_credentials_block
)
gcs_bucket_block.save(gcs_block_name, overwrite=True)
print('created gcs bucket block')




# Docker Registry / docker-registry