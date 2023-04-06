from prefect.deployments import Deployment
from prefect import flow, task
from prefect.tasks.docker import (
    CreateContainer,
    StartContainer,
    GetContainerLogs,
    WaitOnContainer,
)
import os

docker_block = DockerContainer.load("dbt-run-step")

create = CreateContainer(image_name=docker_block.image, command="dbt run")
start = StartContainer()
wait = WaitOnContainer()
logs = GetContainerLogs()

@task
def see_output(out):
    print(out)

docker_dep = Deployment.build_from_flow(
    flow=dbt_run,
    name='dbt_run',
    infrastructure=docker_block    
)


with Flow("docker-flow") as flow:
    container_id = create()
    s = start(container_id=container_id)
    w = wait(container_id=container_id)

    l = logs(container_id=container_id)
    l.set_upstream(w)

    see_output(l)



# docker_dep = Deployment(
#     flow_name='dbt_run',
#     name='dbt_run',
#     infrastructure=docker_block,
#     entrypoint=" "  
# )

if __name__ == "__main__":
    flow.run()