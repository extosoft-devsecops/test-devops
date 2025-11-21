name:=asia-southeast1-docker.pkg.dev/test-devops-478606/test-devops-images/test-devops
tag:=latest

build:
	docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t $(name):$(tag) .

push:
	docker push $(name):$(tag)

run-localhost:
	docker compose -f docker-compose-localhost.yaml --env-file .env up --build

stop-localhost:
	docker compose -f docker-compose-localhost.yaml down

