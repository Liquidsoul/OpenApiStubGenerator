.DEFAULT_GOAL := help

TOOL_NAME = openapi-stub-generator

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
