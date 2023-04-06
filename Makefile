KAGGLE_CREDENTIAL_DIR:=/home/shiv/.kaggle
GCS_CREDENTIAL_JSON:=/run/media/shiv/27c10285-91ca-41fa-9213-f60af3807181/code/keys/google/dtc-de-376914-d552dc193e05.json

PREFECT_CONTAINER_NAME:=shivamkurtarkar/prefect:dedtc
DBT_CONTAINER_NAME:=dbt-local:dev

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
	docker build -t kaggle_download_step .

#run: make run-kaggle-download-step		run kaggle download step
run-kaggle-download-step:
	cd 01_kaggle_dataset && \
	docker run -it \
		--network=${NETWORK} \
		-v `pwd`/../data2:/data \
		-v ${KAGGLE_CREDENTIAL_DIR}:/root/.kaggle \
		-v ${GCS_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-v `pwd`:/app \
		-e PREFECT_API_URL=http://prefect:4200/api \
		kaggle_download_step 
		
		# \
		#  -c "prefect config set PREFECT_API_URL=http://prefect:4200/api && bash"
		--entrypoint='bash' \

#run: make build-bq-import-step		build bq import step
build-bq-import-step:
	cd 02_gcp && \
	docker build -t gcp_bq_import .

#run: make run-import-bq-step		run bq import step
run-import-bq-step:
	cd 02_gcp && \
	docker run -it \
		--network=${NETWORK} \
		-v `pwd`/../data2:/data \
		-v ${GCS_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-v `pwd`:/app \
		-e PREFECT_API_URL=http://prefect:4200/api \
		gcp_bq_import 

		# --entrypoint='bash'  \
		# -c "prefect config set PREFECT_API_URL=http://prefect:4200/api && bash"

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
	cd 04_dbt_project/docker-setup && \
	docker build -t ${DBT_CONTAINER_NAME} -f dev.dockerfile . 
#run: make dbt-dev-env	 docker dbt dev env
dbt-dev-env:
	cd 04_dbt_project && \
	docker run -it --rm \
		-v `pwd`/bussiness_dashboard:/app/ \
		-v `pwd`/docker-setup/.dbt:/root/.dbt \
		-v ${GCS_CREDENTIAL_JSON}:/.google/credentials/google_credentials.json \
		-w  /app \
		--network=${NETWORK} \
		${DBT_CONTAINER_NAME} bash