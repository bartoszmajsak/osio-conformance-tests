PROJECT_NAME=osio-conformance-tests
PACKAGE_NAME := github.com/bartoszmajsak/osio-conformance-tests

SOURCEDIR=.
SOURCES := $(shell find $(SOURCEDIR) -not -path "./bin/*" -name '*.go')

BINARY=osio/osio.test

REGISTRY = bartoszmajsak
TARGET = osio-conformance

latest_stable = 1.8
KUBE_VERSION ?= $(latest_stable)
kube_version = $(subst v,,$(KUBE_VERSION))
kube_version_full = $(shell curl -Ss https://storage.googleapis.com/kubernetes-release/release/stable-$(kube_version).txt)
in_docker_group=$(filter docker,$(shell groups))
is_root=$(filter 0,$(shell id -u))
DOCKER?=$(if $(or $(in_docker_group),$(is_root)),docker,sudo docker)
DIR := ${CURDIR}

# Build configuration
BUILD_TIME=$(shell date -u '+%Y-%m-%dT%H:%M:%SZ')
COMMIT=$(shell git rev-parse HEAD)
GITUNTRACKEDCHANGES := $(shell git status --porcelain --untracked-files=no)
ifneq ($(GITUNTRACKEDCHANGES),)
  COMMIT := $(COMMIT)-dirty
endif

# Pass in build time variables to main
LDFLAGS="-X main.Commit=${COMMIT} -X main.BuildTime=${BUILD_TIME}"

help: ## Hey! That's me!
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := all

.PHONY: all
all: clean install compile container ## (default) Performs clean build  and container packaging

.PHONY: clean
clean: ## Removes binary, cache folder and docker images
	if [ -f ${BINARY} ] ; then rm ${BINARY} ; fi
	rm -rf _cache bin/*
	$(DOCKER) rmi $(REGISTRY)/$(TARGET):latest \
				  $(REGISTRY)/$(TARGET):v$(kube_version) \
				  $(REGISTRY)/$(TARGET):$(kube_version_full) || true

.PHONY: compile
compile: $(BINARY) ## Just builds the test binary

$(BINARY): $(SOURCES)
	ginkgo build -r -ldflags ${LDFLAGS}
	mkdir -p ./bin/
	mv $(BINARY) ./bin/

.PHONY: install
install: ## Fetches all dependencies using Glide
	glide install -v

.PHONY: up
up: ## Updates all dependencies defined for glide
	glide up -v

.PHONY: container
container: getbins ## fetches required binaries (kubectl and cluster) and builds docker images
	$(DOCKER) build -t $(REGISTRY)/$(TARGET):v$(kube_version) \
	                -t $(REGISTRY)/$(TARGET):$(kube_version_full) .
	if [ "$(kube_version)" = "$(latest_stable)" ]; then \
	  $(DOCKER) tag $(REGISTRY)/$(TARGET):v$(kube_version) $(REGISTRY)/$(TARGET):latest; \
	fi

getbins: | _cache/.getbins.$(kube_version_full).timestamp

_cache/.getbins.$(kube_version_full).timestamp: clean
	mkdir -p _cache/$(kube_version_full)
	curl -SsL -o _cache/$(kube_version_full)/kubernetes.tar.gz http://gcsweb.k8s.io/gcs/kubernetes-release/release/$(kube_version_full)/kubernetes.tar.gz
	tar -C _cache/$(kube_version_full) -xzf _cache/$(kube_version_full)/kubernetes.tar.gz
	cd _cache/$(kube_version_full) && KUBE_VERSION="${kube_version_full}" \
	                                  KUBERNETES_DOWNLOAD_TESTS=true \
					  KUBERNETES_SKIP_CONFIRM=true ./kubernetes/cluster/get-kube-binaries.sh
	mv _cache/$(kube_version_full)/kubernetes/cluster ./bin/
	mv _cache/$(kube_version_full)/kubernetes/platforms/linux/amd64/kubectl ./bin/
	rm -rf _cache/$(kube_version_full)
	touch $@

