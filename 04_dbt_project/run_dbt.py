from prefect import flow, task
import subprocess

@flow(log_prints=True)
def run_dbt(cmds):
    print(f'running .. {cmds}')
    result = subprocess.run(cmds, shell=True, capture_output=True, text=True)
    print(result.stdout)


if __name__ == '__main__':
    cmd = [ "dbt run --project-dir bussiness_dashboard" ]
    run_dbt(cmd)