from prefect.deployments import Deployment
from prefect.infrastructure.docker import DockerContainer
from etl_gcs_to_bq import etl_gcs_to_bq

docker_block = DockerContainer.load("bq-import-step")

docker_dep = Deployment.build_from_flow(
    flow=etl_gcs_to_bq,
    name='etl_gcs_to_bq',
    infrastructure=docker_block
)

if __name__ == "__main__":
    docker_dep.apply()