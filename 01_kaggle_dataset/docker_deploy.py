from prefect.deployments import Deployment
from prefect.infrastructure.docker import DockerContainer
from download_kaggle_dataset import etl_kaggle_to_gcs

docker_block = DockerContainer.load("kaggle-download-step")

docker_dep = Deployment.build_from_flow(
    flow=etl_kaggle_to_gcs,
    name='etl_kaggle_to_gcs',
    infrastructure=docker_block,
    parameters={
        'dataset_name':'mkechinov/ecommerce-purchase-history-from-electronics-store',
        'output_dir':'/data'
        }
)

if __name__ == "__main__":
    docker_dep.apply()