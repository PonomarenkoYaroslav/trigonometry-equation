# Крок 1: Створення тимчасового образу для збирання
FROM ubuntu:20.04 AS builder

# Встановлення залежностей для збірки
RUN apt-get update && apt-get install -y \
    build-essential \
    libboost-all-dev \
    git

# Клонування коду з публічного GitHub репозиторію
RUN git clone https://github.com/your-username/your-repo.git /app

# Перехід до каталогу з програмою
WORKDIR /app

# Збірка програми
RUN g++ -o http_server main.cpp -lboost_system -lboost_thread -lpthread

# Крок 2: Створення фінального образу на основі Alpine
FROM alpine:latest

# Встановлення необхідних бібліотек
RUN apk --no-cache add libboost-system libboost-thread

# Копіювання виконуваного файлу з образу builder
COPY --from=builder /app/http_server /usr/local/bin/http_server

# Виставлення порту для сервера
EXPOSE 8080

# Запуск сервера
CMD ["http_server"]

