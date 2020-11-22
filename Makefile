.DEFAULT_GOAL := help

TOOL_NAME = openapi-stub-generator

IMAGE_NAME ?= liquidsoul/$(TOOL_NAME)
DOCKER_VERSION ?= dev

PREFIX = /usr/local
INSTALL_PATH = $(PREFIX)/bin/$(TOOL_NAME)
BUILD_RELEASE_PATH = .build/release/$(TOOL_NAME)

.PHONY: build_release
## Build the tool in release configuration
build_release:
	swift build --disable-sandbox -c release

.PHONY: install
## Build and install the tool
install: build_release
	mkdir -p $(PREFIX)/bin
	cp -f $(BUILD_RELEASE_PATH) $(INSTALL_PATH)

.PHONY: uninstall
## Uninstall the tool
uninstall:
	rm -f $(INSTALL_PATH)

.PHONY: run_example
## Run the project example locally
run_example: build_release
	swift run $(TOOL_NAME) --config-file Examples/config.json --spec-file Examples/spec.yml --definition Result

.PHONY: docker_build
## Build a docker image. You can override the image name and version by specifying IMAGE_NAME= or DOCKER_VERSION= before the docker_build target
docker_build:
	docker build -t $(IMAGE_NAME):$(DOCKER_VERSION) .

.PHONY: docker_push
## Push the previously built image into docker. See docker_build for more informations
docker_push:
	docker push $(IMAGE_NAME):$(DOCKER_VERSION)

.PHONY: docker_run_example
## Run the project example using docker
docker_run_example: docker_build
	docker run -v $(pwd)/Examples/:workdir $(IMAGE_NAME):$(DOCKER_VERSION) openapi-stub-generator --config-file /workdir/config.json --spec-file /workdir/spec.yml --definition Result

.PHONY: help
# taken from this gist https://gist.github.com/rcmachado/af3db315e31383502660
## Show this help message.
help:
	$(info Usage: make [target...])
	$(info Available targets)
	@awk '/^[a-zA-Z\-\_0-9]+:/ {                    \
		nb = sub( /^## /, "", helpMsg );              \
		if(nb == 0) {                                 \
			helpMsg = $$0;                              \
			nb = sub( /^[^:]*:.* ## /, "", helpMsg );   \
		}                                             \
		if (nb)                                       \
			print  $$1 "\t" helpMsg;                    \
	}                                               \
	{ helpMsg = $$0 }'                              \
	$(MAKEFILE_LIST) | column -ts $$'\t' |          \
	grep --color '^[^ ]*'
