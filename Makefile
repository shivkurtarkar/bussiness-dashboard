PREFECT_CONTAINER_NAME:=shivamkurtarkar/prefect:dedtc

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
		-v /home/shiv/.kaggle:/root/.kaggle \
		-v /run/media/shiv/27c10285-91ca-41fa-9213-f60af3807181/code/keys/google/dtc-de-376914-d552dc193e05.json:/.google/credentials/google_credentials.json \
		-v `pwd`:/app \
		--entrypoint='bash' \
		kaggle_download_step  -c "prefect config set PREFECT_API_URL=http://prefect:4200/api && bash"

#run: make build-bq-import-step		build bq import step
build-bq-import-step:
	cd 02_gcp && \
	docker build -t gcp_bq_import .

#run: run-import-bq-step		run bq import step
run-import-bq-step:
	cd 02_gcp && \
	docker run -it \
		--network=${NETWORK} \
		-v `pwd`/../data2:/data \
		-v /run/media/shiv/27c10285-91ca-41fa-9213-f60af3807181/code/keys/google/dtc-de-376914-d552dc193e05.json:/.google/credentials/google_credentials.json \
		-v `pwd`:/app \
		--entrypoint='bash' \
		gcp_bq_import  -c "prefect config set PREFECT_API_URL=http://prefect:4200/api && bash"

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


#run: make prefect-run
prefect-run:
	@# prefect config set PREFECT_API_URL=http://127.0.0.1:4200/api
	echo prefect orion start --host ${PREFECT_ORION_HOST} --port ${PREFECT_ORION_PORT}