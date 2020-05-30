-include .env

define run_if_dir_exists
	if [ -d "$(1)" ]; then $(2); else echo "\033[0;31mMissing Path $(1)\033[0m"; exit 1; fi
endef

define clean_if_dir_exists
	if [ -d "$(1)" ]; then cd $(1); make full-cleanup; else echo "\033[0;31mIgnoring Path $(1)\033[0m"; fi
endef

sanity_check:
	@if ! [ -f .env ]; then echo "\033[0;31mERROR: Missing .env file, please run make init-env\033[0m"; exit 1; fi
	@if [ -z "${IMIN-API}" ]; then echo "\033[0;33mWARNING: Missing IMIN-API variable, please check your .env file\033[0m"; fi
	# @if [ -z "${IMIN-WEB}" ]; then echo "\033[0;33mWARNING: Missing IMIN-WEB variable, please check your .env file\033[0m"; fi

init-env:
	cp .env.example .env
	cd .. && cat imin-init/.env.example | sed "s|WORKSPACE_ROOT_FOLDER|$$PWD|g" > imin-init/.env

init-api: sanity_check
	$(call run_if_dir_exists,${IMIN-API},cd ${IMIN-API}; make init)

# init-web: sanity_check
# 	$(call run_if_dir_exists,${IMIN-WEB},cd ${IMIN-WEB}; make init)

up-api: sanity_check
	docker-compose \
		$(IMIN-API) \
		-p all \
		up

# init-imin: sanity_check init-api init-web
init-imin: sanity_check init-api up-api
