# Базовий образ для побудови
FROM ubuntu:20.04 AS builder
RUN apt-get update && apt-get install -y \
    g++ \
    make \
    curl \
    libboost-system-dev \
    libboost-thread-dev \
    libpthread-stubs0-dev \
 && rm -rf /var/lib/apt/lists/*  # Очищаємо кеш apt, щоб зменшити розмір образу
# Копіювання коду
WORKDIR /app
COPY . .
# Побудова програми
RUN g++ -o http_server http_server.cpp func.cpp -lboost_system -lboost_thread -lpthread
# Фінальний компактний образ
FROM ubuntu:20.04 AS final
RUN apt-get update && apt-get install -y \
    libboost-system-dev \
    libboost-thread-dev \
    libpthread-stubs0-dev \
 && rm -rf /var/lib/apt/lists/*  # Очищаємо кеш apt, щоб зменшити розмір образу
# Копіювання зібраного файлу з попереднього етапу
COPY --from=builder /app/http_server /usr/local/bin/http_server
# Встановлення ENTRYPOINT для запуску http_server
ENTRYPOINT ["/usr/local/bin/http_server"]
