KAGGLE_CREDENTIAL_DIR:=/home/shiv/.kaggle
GCS_CREDENTIAL_JSON:=/run/media/shiv/27c10285-91ca-41fa-9213-f60af3807181/code/keys/google/dtc-de-376914-d552dc193e05.json
REPOSITORY_NAME:=shivamkurtarkar

PREFECT_CONTAINER_NAME:=${REPOSITORY_NAME}/prefect:dedtc
EXTRACT_CONTAINER_NAME:=${REPOSITORY_NAME}/kaggle_download_step
LOAD_CONTAINER_NAME:=${REPOSITORY_NAME}/gcp_bq_import
DBT_CONTAINER_NAME:=${REPOSITORY_NAME}/dbt-local:dev

PREFECT_ORION_HOST:=0.0.0.0	
PREFECT_ORION_PORT:=4200


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
		-v ${GCS_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-v `pwd`:/app \
		-e PREFECT_API_URL=http://prefect:4200/api \
		${EXTRACT_CONTAINER_NAME}  \
		bash

		# \
		--entrypoint='bash' \
		#  -c "prefect config set PREFECT_API_URL=http://prefect:4200/api && bash"

#run: make run-kaggle-download-step		run kaggle download step
run-kaggle-download-step:
	cd 01_kaggle_dataset && \
	docker run -it \
		--network=${NETWORK} \
		-v `pwd`/../data2:/data \
		-v ${KAGGLE_CREDENTIAL_DIR}:/root/.kaggle \
		-v ${GCS_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-e PREFECT_API_URL=http://prefect:4200/api \
		${EXTRACT_CONTAINER_NAME} 


#run: make run-kaggle-download-step-bash		run kaggle download step
run-kaggle-download-step-bash:
	cd 01_kaggle_dataset && \
	docker run -it \
		--network=${NETWORK} \
		-v `pwd`/../data2:/data \
		-v ${KAGGLE_CREDENTIAL_DIR}:/root/.kaggle \
		-v ${GCS_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-e PREFECT_API_URL=http://prefect:4200/api \
		${EXTRACT_CONTAINER_NAME} \
		bash

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
		-v ${GCS_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-v `pwd`:/app \
		-e PREFECT_API_URL=http://prefect:4200/api \
		${LOAD_CONTAINER_NAME} 

		# --entrypoint='bash'  \
		# -c "prefect config set PREFECT_API_URL=http://prefect:4200/api && bash"

#run: make run-import-bq-step		run bq import step
run-import-bq-step:
	cd 02_gcp && \
	docker run -it \
		--network=${NETWORK} \
		-v `pwd`/../data2:/data \
		-v ${GCS_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-e PREFECT_API_URL=http://prefect:4200/api \
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


#run: dbt-docker-build		build dbt docker
dbt-docker-build:
	cd 04_dbt_project && \
	docker build -t ${DBT_CONTAINER_NAME} -f dev.dockerfile . 
#run: make dbt-dev-env	 docker dbt dev env
dbt-dev-env:
	cd 04_dbt_project && \
	docker run -it --rm \
		-v `pwd`/docker-setup/.dbt:/root/.dbt \
		-v ${GCS_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		--network=${NETWORK} \
		${DBT_CONTAINER_NAME} 
		# bash


#run: make dbt-docker-run-bash	 docker dbt run
dbt-docker-run-bash:
	cd 04_dbt_project && \
	docker run -it --rm \
		-v `pwd`:/app/ \
		-v `pwd`/docker-setup/.dbt:/root/.dbt \
		-v ${GCS_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-w  /app \
		--entrypoint='bash' \
		--network=${NETWORK} \
		${DBT_CONTAINER_NAME}

#run: make dbt-docker-run	 docker dbt run
dbt-docker-run:
	cd 04_dbt_project && \
	docker run -it --rm \
		-v `pwd`/docker-setup/.dbt:/root/.dbt \
		-v ${GCS_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
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