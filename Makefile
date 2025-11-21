name:=asia-southeast1-docker.pkg.dev/test-devops-478606/test-devops-images/test-devops
tag:=latest

build:
	docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t $(name):$(tag) .

push:
	docker push $(name):$(tag)

build-graphite:
	docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile.graphite -t $(name)-graphite:$(tag) .

run-localhost:
	docker compose -f docker-compose-localhost.yaml up --build

run-development:
	docker compose -f docker-compose-development.yaml up -d

stop-localhost:
	docker compose -f docker-compose-localhost.yaml down

stop-development:
	docker compose -f docker-compose-development.yaml down

