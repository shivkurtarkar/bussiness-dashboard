from prefect.deployments import Deployment
from prefect.infrastructure.docker import DockerContainer
from run_dbt import run_dbt
import os

docker_block = DockerContainer.load("dbt-run-step")

docker_dep = Deployment.build_from_flow(
    flow=run_dbt,
    name='run_dbt',
    infrastructure=docker_block,
    parameters={
        'cmds':[ "dbt run --project-dir bussiness_dashboard" ]
    }
)

if __name__ == "__main__":
    docker_dep.apply()
