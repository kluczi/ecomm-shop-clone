-include .env

SHELL := /bin/sh

DOCKER ?= $(shell if command -v docker.exe >/dev/null 2>&1; then echo docker.exe; else echo docker; fi)

ifeq ($(OS),Windows_NT)
PYTHON ?= $(shell if [ -f .venv/Scripts/python.exe ]; then echo .venv/Scripts/python.exe; elif [ -f scraper/.venv/Scripts/python.exe ]; then echo scraper/.venv/Scripts/python.exe; else echo python; fi)
E2E_PYTHON ?= $(shell if [ -f tests/.venv/Scripts/python.exe ]; then echo tests/.venv/Scripts/python.exe; elif [ -f .venv/Scripts/python.exe ]; then echo .venv/Scripts/python.exe; else echo python; fi)
else
PYTHON ?= $(shell if [ -f .venv/Scripts/python.exe ]; then echo .venv/Scripts/python.exe; elif [ -f .venv/bin/python ]; then echo .venv/bin/python; elif [ -f scraper/.venv/bin/python ]; then echo scraper/.venv/bin/python; else echo python3; fi)
E2E_PYTHON ?= $(shell if [ -f tests/.venv/Scripts/python.exe ]; then echo tests/.venv/Scripts/python.exe; elif [ -f tests/.venv/bin/python ]; then echo tests/.venv/bin/python; elif [ -f .venv/bin/python ]; then echo .venv/bin/python; else echo python3; fi)
endif

COMPOSE ?= $(DOCKER) compose -f deploy/compose.yaml --env-file .env

.PHONY: up down init cms payments shipping webservice storefront images import backup restore promotion-module promotions e2e search check-env verify

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
	$(COMPOSE) exec -T prestashop sh -c "rm -rf /var/www/html/var/cache/prod && chown -R www-data:www-data /var/www/html/var/cache && chmod -R 777 /var/www/html/var/cache || true"

payments: check-env
	$(COMPOSE) exec -T prestashop sh -c "php /var/www/html/bin/console prestashop:module install ps_wirepayment || true"
	$(COMPOSE) exec -T prestashop sh -c "php /var/www/html/bin/console prestashop:module install ps_cashondelivery || true"
	$(COMPOSE) exec -T prestashop sh -c "php /var/www/html/bin/console prestashop:module uninstall ps_checkpayment || true"
	@$(COMPOSE) exec -T mariadb sh -c 'mariadb --default-character-set=utf8mb4 -u"$$MARIADB_USER" -p"$$MARIADB_PASSWORD" "$$MARIADB_DATABASE"' < deploy/payment_config.sql
	$(COMPOSE) exec -T prestashop sh -c "rm -rf /var/www/html/var/cache/prod && chown -R www-data:www-data /var/www/html/var/cache && chmod -R 777 /var/www/html/var/cache || true"

shipping: check-env
	@$(COMPOSE) exec -T mariadb sh -c 'mariadb --default-character-set=utf8mb4 -u"$$MARIADB_USER" -p"$$MARIADB_PASSWORD" "$$MARIADB_DATABASE"' < deploy/shipping_config.sql

webservice: check-env
	$(COMPOSE) cp deploy/init-webservice.sql mariadb:/tmp/init-webservice.sql
	@$(COMPOSE) exec -T mariadb sh -c 'mariadb --default-character-set=utf8mb4 -u"$$MARIADB_USER" -p"$$MARIADB_PASSWORD" "$$MARIADB_DATABASE" -e "SET @api_key = '\''$(PRESTASHOP_WEBSERVICE_KEY)'\''; SOURCE /tmp/init-webservice.sql;"'

storefront: check-env
	$(COMPOSE) cp deploy/storefront_config.sql mariadb:/tmp/storefront_config.sql
	@$(COMPOSE) exec -T mariadb sh -c 'mariadb --default-character-set=utf8mb4 -u"$$MARIADB_USER" -p"$$MARIADB_PASSWORD" "$$MARIADB_DATABASE" -e "SOURCE /tmp/storefront_config.sql;"'
	$(COMPOSE) cp shop/custom.css prestashop:/var/www/html/themes/classic/assets/css/custom.css
	$(COMPOSE) exec -T prestashop sh -c "rm -rf /var/www/html/var/cache/prod && chown -R www-data:www-data /var/www/html/var/cache && chmod -R 777 /var/www/html/var/cache || true"

# Install Omnibus before importing so it can record the original prices.
init: check-env
	$(MAKE) cms
	$(MAKE) shipping
	$(MAKE) payments
	$(MAKE) webservice
	$(MAKE) storefront
	$(MAKE) promotion-module
	$(MAKE) import
	$(MAKE) promotions
	$(MAKE) search
	$(MAKE) verify

promotion-module:
	$(COMPOSE) exec -T --user www-data prestashop sh -c "php /var/www/html/modules/omnibus/cli/seed.php --install-only"

verify: check-env
	$(PYTHON) deploy/verify_metrics.py

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
	$(COMPOSE) exec -T --user www-data prestashop sh -c "php /var/www/html/modules/omnibus/cli/seed.php"

e2e:
	"$(E2E_PYTHON)" -m pytest -c tests/pytest.ini tests $(E2E_ARGS)

search:
	$(COMPOSE) exec -T --user www-data prestashop sh -c "php /tmp/search-index.php"
