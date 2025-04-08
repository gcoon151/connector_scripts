IMG ?= quay.io/your-org/agent-operator:v0.1.0
BUNDLE_IMG ?= quay.io/your-org/agent-operator-bundle:v0.1.0

all: docker-build docker-push

docker-build:
	docker build -t $(IMG) .

docker-push:
	docker push $(IMG)

bundle: generate
	operator-sdk generate kustomize manifests -q
	operator-sdk generate bundle --overwrite --version 0.1.0 \
		--manifests config/manifests \
		--metadata config/metadata \
		--output-dir bundle

bundle-build:
	docker build -f bundle.Dockerfile -t $(BUNDLE_IMG) bundle/
	docker push $(BUNDLE_IMG)

bundle-validate:
	operator-sdk bundle validate ./bundle --select-optional suite=operatorframework

run:
	operator-sdk run --local --namespace default --watch-namespace "" --operator-flags="--zap-log-level=debug"

generate:
	operator-sdk generate kustomize manifests

