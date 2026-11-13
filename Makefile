.PHONY: up down init cms payments shipping

up:
	docker compose -f deploy/compose.yaml up -d --build

down:
	docker compose -f deploy/compose.yaml down

cms:
	docker compose -f deploy/compose.yaml cp deploy/init-cms.sql mariadb:/tmp/init-cms.sql
	docker compose -f deploy/compose.yaml exec -T mariadb mariadb --default-character-set=utf8mb4 -u prestashop -padmin prestashop -e "SOURCE /tmp/init-cms.sql;"
	docker compose -f deploy/compose.yaml exec -T prestashop php /var/www/html/bin/console prestashop:module install domitekcookies || true
	docker compose -f deploy/compose.yaml exec -T prestashop rm -rf /var/www/html/var/cache/prod

payments:
	docker compose -f deploy/compose.yaml exec -T mariadb mariadb --default-character-set=utf8mb4 -u prestashop -padmin prestashop < deploy/payment_config.sql

shipping:
	docker compose -f deploy/compose.yaml exec -T mariadb mariadb --default-character-set=utf8mb4 -u prestashop -padmin prestashop < deploy/shipping_config.sql

init: cms payments shipping
