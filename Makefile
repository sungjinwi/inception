.PHONY: all build up down clean fclean re logs ps

all: build up

build:
	@echo "Building Docker images..."
	cd srcs && docker compose build

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

re: fclean all
