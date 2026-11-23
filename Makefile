-include .env

COMPOSE ?= docker compose --env-file .env -f deploy/compose.yaml

ifeq ($(OS),Windows_NT)
E2E_PYTHON ?= tests/.venv/Scripts/python.exe
PYTHON ?= $(shell if [ -f .venv/Scripts/python.exe ]; then echo .venv/Scripts/python.exe; elif [ -f scraper/.venv/Scripts/python.exe ]; then echo scraper/.venv/Scripts/python.exe; else echo python; fi)
else
E2E_PYTHON ?= tests/.venv/bin/python
PYTHON ?= $(shell if [ -f .venv/bin/python ]; then echo .venv/bin/python; elif [ -f scraper/.venv/bin/python ]; then echo scraper/.venv/bin/python; else echo python3; fi)
endif

.PHONY: up down init cms payments shipping webservice storefront images import backup restore promotion-module promotions check-env e2e

check-env:
ifndef DATABASE_PASSWORD
	$(error BŁĄD: Brak zmiennej DATABASE_PASSWORD w pliku .env!)
endif
ifndef DATABASE_USER
	$(error BŁĄD: Brak zmiennej DATABASE_USER w pliku .env!)
endif
ifndef DATABASE_NAME
	$(error BŁĄD: Brak zmiennej DATABASE_NAME w pliku .env!)
endif
ifndef PRESTASHOP_WEBSERVICE_KEY
	$(error BŁĄD: Brak zmiennej PRESTASHOP_WEBSERVICE_KEY w pliku .env!)
endif

up:
	$(COMPOSE) up -d --build

down:
	docker compose -f deploy/compose.yaml down

cms: check-env
	$(COMPOSE) cp deploy/init-cms.sql mariadb:/tmp/init-cms.sql
	@$(COMPOSE) exec -T mariadb sh -c 'mariadb --default-character-set=utf8mb4 -u"$$MARIADB_USER" -p"$$MARIADB_PASSWORD" "$$MARIADB_DATABASE" -e "SOURCE /tmp/init-cms.sql;"'
	$(COMPOSE) exec -T prestashop sh -c "php /var/www/html/bin/console prestashop:module install domitekcookies || true"
	$(COMPOSE) exec -T prestashop sh -c "rm -rf /var/www/html/var/cache/prod"

payments: check-env
	@$(COMPOSE) exec -T mariadb sh -c 'mariadb --default-character-set=utf8mb4 -u"$$MARIADB_USER" -p"$$MARIADB_PASSWORD" "$$MARIADB_DATABASE"' < deploy/payment_config.sql

shipping: check-env
	@$(COMPOSE) exec -T mariadb sh -c 'mariadb --default-character-set=utf8mb4 -u"$$MARIADB_USER" -p"$$MARIADB_PASSWORD" "$$MARIADB_DATABASE"' < deploy/shipping_config.sql

webservice: check-env
	$(COMPOSE) cp deploy/init-webservice.sql mariadb:/tmp/init-webservice.sql
	@$(COMPOSE) exec -T mariadb sh -c 'mariadb --default-character-set=utf8mb4 -u"$$MARIADB_USER" -p"$$MARIADB_PASSWORD" "$$MARIADB_DATABASE" -e "SET @api_key = '\''$(PRESTASHOP_WEBSERVICE_KEY)'\''; SOURCE /tmp/init-webservice.sql;"'

storefront: check-env
	$(COMPOSE) cp deploy/storefront_config.sql mariadb:/tmp/storefront_config.sql
	@$(COMPOSE) exec -T mariadb sh -c 'mariadb --default-character-set=utf8mb4 -u"$$MARIADB_USER" -p"$$MARIADB_PASSWORD" "$$MARIADB_DATABASE" -e "SOURCE /tmp/storefront_config.sql;"'
	$(COMPOSE) cp shop/custom.css prestashop:/var/www/html/themes/classic/assets/css/custom.css
	$(COMPOSE) exec -T prestashop sh -c "rm -rf /var/www/html/var/cache/prod"

# Install Omnibus before importing so it can record the original prices.
init: check-env
	$(MAKE) cms
	$(MAKE) payments
	$(MAKE) shipping
	$(MAKE) webservice
	$(MAKE) storefront
	$(MAKE) promotion-module
	$(MAKE) import
	$(MAKE) promotions

promotion-module:
	$(COMPOSE) exec -T --user www-data prestashop php /var/www/html/modules/omnibus/cli/seed.php --install-only

images: check-env
	$(PYTHON) scraper/download_release_images.py

import: check-env images
	$(PYTHON) shop/import_api.py

backup: check-env
	$(PYTHON) deploy/backup.py

restore: check-env
	$(PYTHON) deploy/restore.py

promotions:
	$(COMPOSE) cp scraper-results/products.json prestashop:/tmp/omnibus-products.json
	$(COMPOSE) exec -T --user www-data prestashop php /var/www/html/modules/omnibus/cli/seed.php

e2e:
	"$(E2E_PYTHON)" -m pytest -c tests/pytest.ini tests $(E2E_ARGS)
