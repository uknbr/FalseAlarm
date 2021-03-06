# Change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

.PHONY: help

help: ## Display help message
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[35m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build the container
	docker image build --force-rm --network host -t $(APP_NAME):$(VERSION) .

up: ## Run container on port configured in `config.env`
	docker container run -dti --env-file=./$(cnf) --label florinda=sensor --restart=always --network host --device /dev/gpiomem -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --name=$(APP_NAME) $(APP_NAME):$(VERSION)

stop: ## Stop and remove a running container
	docker container stop $(APP_NAME) 2>/dev/null ; docker container rm -f $(APP_NAME) 2>/dev/null ; docker info >/dev/null 2>&1

status: ## Check status of container
	docker container ls -f name=$(APP_NAME)

sh: ## Access running container
	docker exec -ti $(APP_NAME) sh

log: ## Follow the logs
	docker logs -f $(APP_NAME)

restart: stop up status ## Alias to stop, up and status

version: ## Output the current version
	@echo $(VERSION)
