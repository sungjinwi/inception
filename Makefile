.PHONY: all build ssl up clean fclean re 

all: build up

build: ssl
	@echo "Building Docker images..."
	cd srcs && docker compose build

ssl:
	@echo "Generating SSL certificate and key..."
	@mkdir -p secrets
	@if [ ! -f secrets/ssl_cert.crt ] || [ ! -f secrets/ssl_key.key ]; then \
		openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
			-keyout secrets/ssl_key.key \
			-out secrets/ssl_cert.crt \
			-subj "/C=KR/ST=Gyeongbuk/L=Gyeongsan/O=42Gyeongsan/CN=localhost" > /dev/null 2>&1; \
		echo "SSL certificate created."; \
	else \
		echo "SSL certificate already exists."; \
	fi

up:
	@mkdir -p /home/suwi/data/mysql
	@mkdir -p /home/suwi/data/html
	@echo "Starting containers..."
	cd srcs && docker compose up -d

clean:
	@echo "Stopping and removing containers..."
	cd srcs && docker compose down

fclean: clean
	@echo "Removing images and volumes..."
	cd srcs && docker compose down -v --rmi all
	@docker system prune -af
	@rm -rf secrets/ssl_key.key secrets/ssl_cert.crt

re: fclean all
