# REPOSITORY_NAME:=shivamkurtarkar
# KAGGLE_CREDENTIAL_DIR:=/home/shiv/.kaggle
# GCP_PROJECT_ID:=dtc-de-376914
# GCP_CREDENTIAL_JSON:=/run/media/shiv/27c10285-91ca-41fa-9213-f60af3807181/code/keys/google/dtc-de-376914-d552dc193e05.json


-include .env 

ifeq ($(DBT_PROFILE_DIR),)
DBT_PROFILE_DIR:=`pwd`/04_dbt_project/docker-setup/.dbt
endif

PREFECT_CONTAINER_NAME:=${REPOSITORY_NAME}/prefect:dedtc
EXTRACT_CONTAINER_NAME:=${REPOSITORY_NAME}/kaggle_download_step
LOAD_CONTAINER_NAME:=${REPOSITORY_NAME}/gcp_bq_import
DBT_CONTAINER_NAME:=${REPOSITORY_NAME}/dbt-local:dev

PREFECT_ORION_HOST:=0.0.0.0	
PREFECT_ORION_PORT:=4200

ifeq ($(PREFECT_API_URL),)
PREFECT_API_URL:=http://prefect:4200/api
endif

NETWORK:=pg-network

#run: make help 		help command
help:
	@echo -e "\nCommands:\n"
	@cat Makefile | grep -e '^#run:.*' | sed -e 's~#~~g' | sort
# @make -qpRr | grep -e '^[a-z].*:' | sed -e 's~#~~g' | sort
	@echo ""

#run: make build-kaggle-download-step		build kaggle download step
build-kaggle-download-step:
	cd 01_kaggle_dataset && \
	docker build -t ${EXTRACT_CONTAINER_NAME} .


#run: make run-kaggle-download-step-bash		run kaggle download step
run-kaggle-download-step-bash:
	cd 01_kaggle_dataset && \
	docker run -it \
		--network=${NETWORK} \
		-v `pwd`/../data2:/data \
		-v ${KAGGLE_CREDENTIAL_DIR}:/root/.kaggle \
		-v ${GCP_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-v `pwd`:/app \
		-e PREFECT_API_URL=${PREFECT_API_URL} \
		${EXTRACT_CONTAINER_NAME}  \
		bash

		# \
		--entrypoint='bash' \
		#  -c "prefect config set PREFECT_API_URL=${PREFECT_API_URL} && bash"

#run: make run-kaggle-download-step		run kaggle download step
run-kaggle-download-step:
	cd 01_kaggle_dataset && \
	docker run -it \
		--network=${NETWORK} \
		-v `pwd`/../data2:/data \
		-v ${KAGGLE_CREDENTIAL_DIR}:/root/.kaggle \
		-v ${GCP_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-e PREFECT_API_URL=${PREFECT_API_URL} \
		${EXTRACT_CONTAINER_NAME} 


#run: make build-bq-import-step		build bq import step
build-bq-import-step:
	cd 02_gcp && \
	docker build -t ${LOAD_CONTAINER_NAME} .

#run: make run-import-bq-step-bash		run bq import step
run-import-bq-step-bash:
	cd 02_gcp && \
	docker run -it \
		--network=${NETWORK} \
		-v `pwd`/../data2:/data \
		-v ${GCP_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-v `pwd`:/app \
		-e PREFECT_API_URL=${PREFECT_API_URL} \
		${LOAD_CONTAINER_NAME} 

		# --entrypoint='bash'  \
		# -c "prefect config set PREFECT_API_URL=${PREFECT_API_URL} && bash"

#run: make run-import-bq-step		run bq import step
run-import-bq-step:
	cd 02_gcp && \
	docker run -it \
		--network=${NETWORK} \
		-v `pwd`/../data2:/data \
		-v ${GCP_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-e PREFECT_API_URL=${PREFECT_API_URL} \
		${LOAD_CONTAINER_NAME} 


#run: make docker-network 		docker-network
docker-network:
	cd prefect && \
	docker network create ${NETWORK}


#run: make prefect-docker-build 		build docker
prefect-docker-build:
	cd prefect && \
	docker build -t ${PREFECT_CONTAINER_NAME} .

#run: make prefect-docker-push 		push docker
prefect-docker-push:
	cd prefect && \
	docker push ${PREFECT_CONTAINER_NAME}

#run: make prefect-docker-run 		docker-run
prefect-docker-run:
	docker run -it --rm	\
		--name=ingetion-job \
		--network=${NETWORK} \
		-p 4200:4200 \
		${PREFECT_CONTAINER_NAME} $(ARGS)

#run: make prefect-docker-compose-run 		docker-run
prefect-docker-compose-run:
	cd prefect && \
	docker-compose up


#run: make prefect-run
prefect-run:
	@# prefect config set PREFECT_API_URL=http://127.0.0.1:4200/api
	echo prefect orion start --host ${PREFECT_ORION_HOST} --port ${PREFECT_ORION_PORT}


#run: make dbt-docker-build		build dbt docker
dbt-docker-build:
	cd 04_dbt_project && \
	docker build -t ${DBT_CONTAINER_NAME} -f dev.dockerfile . 


#run: make dbt-docker-run-bash	 docker dbt run
dbt-docker-run-bash:
	cd 04_dbt_project && \
	docker run -it --rm \
		-v `pwd`:/app/ \
		-v ${DBT_PROFILE_DIR}:/root/.dbt \
		-v ${GCP_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-e GCP_PROJECT_ID=${GCP_PROJECT_ID} \
		-w  /app \
		--entrypoint='bash' \
		--network=${NETWORK} \
		${DBT_CONTAINER_NAME}

#run: make dbt-docker-run	 docker dbt run
dbt-docker-run:
	cd 04_dbt_project && \
	docker run -it --rm \
		-v ${DBT_PROFILE_DIR}:/root/.dbt \
		-v ${GCP_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-e GCP_PROJECT_ID=${GCP_PROJECT_ID} \
		--network=${NETWORK} \
		${DBT_CONTAINER_NAME} 


#run: make docker-build-all					build all dockers
docker-build-all:
	make build-kaggle-download-step
	make build-bq-import-step
	make prefect-docker-build
	make dbt-docker-build

#run: make docker-push-all					push all dockers
docker-push-all:
		docker push ${PREFECT_CONTAINER_NAME}
		docker push ${EXTRACT_CONTAINER_NAME}
		docker push ${LOAD_CONTAINER_NAME}
		docker push ${DBT_CONTAINER_NAME}

#run: make docker-list-all					list all dockers
docker-list-all:
		@echo PREFECT_CONTAINER_NAME			${PREFECT_CONTAINER_NAME}
		@echo EXTRACT_CONTAINER_NAME			${EXTRACT_CONTAINER_NAME}
		@echo LOAD_CONTAINER_NAME				${LOAD_CONTAINER_NAME}
		@echo DBT_CONTAINER_NAME				${DBT_CONTAINER_NAME}

#run: make prefect-create-blocks
prefect-create-blocks:
	python utils/create_blocks.py

#run: make prefect-deploy-all
prefect-deploy-all:
	python 01_kaggle_dataset/docker_deploy.py
	python 02_gcp/docker_deploy.py
	python 04_dbt_project/docker_deploy.py


#run: make prefect-run-agent
prefect-run-agent:
	prefect agent start -q default

#run make export_env
export_env:
	@echo "exporting .env (if it thorws error please create .env file)"
	@source `pwd`/.env

#run: make terraform_init
terraform_init:
	@cd terraform && \
	terraform init

#run: make terraform_plan
terraform_plan:
	@cd terraform && \
	terraform plan -var="project=${GCP_PROJECT_ID}"

#run: make terraform_apply
terraform_apply:
	@cd terraform && \
	terraform apply -var="project=${GCP_PROJECT_ID}"

#run: make terraform_destroy
terraform_destroy:
	@cd terraform && \
	terraform destroy

#run: make terraform_deploy_dry
terraform_deploy_dry: export_env terraform_init terraform_plan

#run: make terraform_deploy
terraform_deploy: terraform_deploy_dry terraform_apply

#run: make init_setup
init_setup: export_env 
	pip install -r requirements.txt

#run: make create_dot_env 		create dot env file from template
create_dot_env:
	@cp -u -f dot_env_template  ".env"
	@echo ".env file created please set appropriate values"