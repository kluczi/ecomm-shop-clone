-include .env
DB_NAME ?= $(DATABASE_NAME)
DB_USER ?= $(DATABASE_USER)
DB_PASS ?= $(DATABASE_PASSWORD)

.PHONY: up down init cms payments shipping check-env

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

up:
	docker compose -f deploy/compose.yaml up -d --build

down:
	docker compose -f deploy/compose.yaml down

cms: check-env
	docker compose -f deploy/compose.yaml cp deploy/init-cms.sql mariadb:/tmp/init-cms.sql
	@docker compose -f deploy/compose.yaml exec -T mariadb mariadb --default-character-set=utf8mb4 -u "$(DB_USER)" "-p$(DB_PASS)" "$(DB_NAME)" -e "SOURCE /tmp/init-cms.sql;"
	docker compose -f deploy/compose.yaml exec -T prestashop php /var/www/html/bin/console prestashop:module install domitekcookies || true
	docker compose -f deploy/compose.yaml exec -T prestashop rm -rf /var/www/html/var/cache/prod

payments: check-env
	@docker compose -f deploy/compose.yaml exec -T mariadb mariadb --default-character-set=utf8mb4 -u "$(DB_USER)" "-p$(DB_PASS)" "$(DB_NAME)" < deploy/payment_config.sql

shipping: check-env
	@docker compose -f deploy/compose.yaml exec -T mariadb mariadb --default-character-set=utf8mb4 -u "$(DB_USER)" "-p$(DB_PASS)" "$(DB_NAME)" < deploy/shipping_config.sql

init: check-env cms payments shipping