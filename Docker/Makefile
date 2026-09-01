TAG=libreeda_docker_ubuntu24
VERSION=v1
IMAGE=libreeda_docker_ubuntu24

# LibreEDA ROOT Path - Default is the Top Folder
# LibreEDA root is mapped to /home/LibreEDA-Project inside docker container
# (must match the ENV paths in ../Dockerfile if you change this)
LIBREEDA_ROOT_PATH ?= ${PWD}/../

# Optional extra paths (e.g., PDKs, libraries, external technology files)
# Pass from CLI like: make run PDK_PATHS="-v /path/to/pdk:/pdk -v /path/to/libs:/libs"
EXTRA_PATHS ?=

.DEFAULT_GOAL := help

.PHONY: help build-docker run sh down stop save load

help: ## Show this help message
	@echo "LibreEDA Docker build/run environment."
	@echo
	@echo "Usage: make <target> [VAR=value ...]"
	@echo
	@echo "Targets:"
	@grep -hE '^[a-zA-Z0-9_.%-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "Common variables:"
	@echo "  LIBREEDA_ROOT_PATH  host path mounted into the container (default: repo root)"
	@echo "  EXTRA_PATHS        extra -v mounts, e.g. EXTRA_PATHS=\"-v /path/to/pdk:/pdk\""
	@echo "  IMAGE / TAG        image name / container name (default: $(IMAGE))"
	@echo "  VERSION            image tag version (default: $(VERSION))"

build-docker: ## Build the Docker image
	-docker image rm -f $(IMAGE):$(VERSION)
	docker build -t $(IMAGE):$(VERSION) .

# Runs container in background so crashes inside won't exit/close the container
run: ## Start the container (background) and drop into a shell
	-docker container rm $(TAG) -f
	docker run -d -it \
		--security-opt label=type:container_runtime_t \
		--network=host \
		-e DISPLAY=$$DISPLAY \
		-v ${LIBREEDA_ROOT_PATH}:/home/LibreEDA-Project \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		$(EXTRA_PATHS) \
		--name $(TAG) \
		$(IMAGE):$(VERSION) \
		tail -f /dev/null
	docker exec -it $(TAG) /bin/bash

sh: ## Attach a shell to the already-running container
	docker exec -it $(TAG) /bin/bash

down: stop ## Alias for stop

stop: ## Stop and remove the running container
	-docker stop $(TAG)
	-docker rm -f $(TAG)

save: ## Save the built image to a .tar.gz file
	docker image save $(IMAGE):$(VERSION) | gzip > $(IMAGE).$(VERSION).tar.gz

load: ## Load a previously saved .tar.gz image
	-docker image rm -f $(IMAGE):$(VERSION)
	docker image load < $(IMAGE).$(VERSION).tar.gz