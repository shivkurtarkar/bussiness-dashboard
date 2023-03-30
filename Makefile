CONTAINER_NAME:=shivamkurtarkar/prefect:dedtc

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
		-v `pwd`:/app \
		--entrypoint='bash' \
		kaggle_download_step 


#run: make docker-build 		build docker
docker-build:
	docker build -t ${CONTAINER_NAME} .

#run: make docker-push 		push docker
docker-push:
	docker push ${CONTAINER_NAME}

docker-network:
	docker network create ${NETWORK}

docker-run:
	docker run -it --rm	\
		--name=ingetion-job \
		--network=${NETWORK} \
		-p 4200:4200 \
		${CONTAINER_NAME} $(ARGS)

#run: make prefect-run
prefect-run:
	@# prefect config set PREFECT_API_URL=http://127.0.0.1:4200/api
	echo prefect orion start --host ${PREFECT_ORION_HOST} --port ${PREFECT_ORION_PORT}