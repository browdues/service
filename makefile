SHELL := /bin/bash

run:
	go run app/services/sales-api/main.go

tidy:
	go mod tidy
	go mod vendor

# ==============================================================================

# $(shell git rev-parse --short HEAD)
VERSION := 1.0

sales-api:
	docker build \
		-f zarf/docker/dockerfile.sales-api \
		-t sales-api-amd64:$(VERSION) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.

# ==============================================================================
# Running from within k8s/kind

KIND_CLUSTER := ardan-starter-cluster

# Upgrade to latest Kind (>=v0.11): e.g. brew upgrade kind
# For full Kind v0.11 release notes: https://github.com/kubernetes-sigs/kind/releases/tag/v0.11.0
# Kind release used for our project: https://github.com/kubernetes-sigs/kind/releases/tag/v0.11.1
# The image used below was copied by the above link and supports both amd64 and arm64.

# Bringing up the cluster (from class)
kind-class-bring-up-from-down:
	kind-up kind-load kind-apply

kind-up:
	kind create cluster \
		--image kindest/node:v1.22.0@sha256:b8bda84bb3a190e6e028b1760d277454a72267a5454b57db34437c34a588d047 \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/kind/kind-config.yaml
	kubectl config set-context --current --namespace=sales-system

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)

kind-load:
	kind load docker-image sales-api-amd64:$(VERSION) --name $(KIND_CLUSTER)

kind-apply:
	kustomize build zarf/k8s/base/sales-pod | kubectl apply -f -

kind-restart:
	kubectl rollout restart deployment sales-pod

kind-update: sales-api kind-load kind-restart

kind-update-apply: sales-api kind-load kind-apply

kind-status-sales:
	kubectl get pods -o wide --watch --namespace=sales-system

kind-logs-sales:
	kubectl logs -l app=sales --all-containers=true -f --tail=100 

kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch --all-namespaces

kind-describe:
	kubectl describe nodes
	kubectl describe svc
	kubectl describe pod -l app=sales

kind-describe-deployment:
	kubectl describe deployment sales-pod
