-include .env
DB_NAME ?= $(DATABASE_NAME)
DB_USER ?= $(DATABASE_USER)
DB_PASS ?= $(DATABASE_PASSWORD)
PRESTASHOP_WEBSERVICE_KEY ?= $(PRESTASHOP_WEBSERVICE_KEY)

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

COMPOSE ?= docker compose --env-file .env -f deploy/compose.yaml

.PHONY: up down init cms payments shipping webservice images import backup restore

up:
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

cms:
	$(COMPOSE) cp deploy/init-cms.sql mariadb:/tmp/init-cms.sql
	$(COMPOSE) exec -T mariadb mariadb --default-character-set=utf8mb4 -u $(DB_USER) -p$(DB_PASS) $(DB_NAME) -e "SOURCE /tmp/init-cms.sql;"
	$(COMPOSE) exec -T prestashop sh -c "php /var/www/html/bin/console prestashop:module install domitekcookies || true"
	$(COMPOSE) exec -T prestashop sh -c "rm -rf /var/www/html/var/cache/prod"

payments:
	$(COMPOSE) exec -T mariadb mariadb --default-character-set=utf8mb4 -u $(DB_USER) -p$(DB_PASS) $(DB_NAME) < deploy/payment_config.sql

shipping:
	$(COMPOSE) exec -T mariadb mariadb --default-character-set=utf8mb4 -u $(DB_USER) -p$(DB_PASS) $(DB_NAME) < deploy/shipping_config.sql

webservice:
	$(COMPOSE) cp deploy/init-webservice.sql mariadb:/tmp/init-webservice.sql
	$(COMPOSE) exec -T mariadb mariadb --default-character-set=utf8mb4 -u $(DB_USER) -p$(DB_PASS) $(DB_NAME) -e "SET @api_key = '$(PRESTASHOP_WEBSERVICE_KEY)'; SOURCE /tmp/init-webservice.sql;"

init: cms payments shipping webservice images import

images:
	python scraper/download_release_images.py

import: images
	python shop/import_api.py

backup:
	python deploy/backup.py

restore:
	python deploy/restore.py
