PROFILE := ft-services

.PHONY: help start stop clean status apply certs

help:
	@echo "Targets: start (minikube + apply), apply (manifests), certs (self-signed), stop, clean, status"
	@echo "Optional: hosts (generate /etc/hosts entries, requires LB_IP), seed (push synthetic metrics)"

start: certs
	./scripts/init_minikube.sh
	./scripts/apply_all.sh

apply:
	LB_POOL=$(LB_POOL) ./scripts/apply_all.sh

certs:
	./scripts/gen_certs.sh

stop:
	minikube stop -p $(PROFILE) || true

clean: stop
	minikube delete -p $(PROFILE) || true

status:
	kubectl get pods -A

.PHONY: hosts
hosts:
	@if [ -z "$(LB_IP)" ]; then echo "Usage: make hosts LB_IP=<loadbalancer_ip>"; exit 1; fi
	./scripts/gen_hosts.sh $(LB_IP)

.PHONY: seed
seed:
	./scripts/seed_metrics.sh
