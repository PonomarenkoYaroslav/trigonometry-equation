FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Встановлюємо необхідні пакети
RUN apt-get update && apt-get install -y \
    build-essential \
    libboost-system-dev \
    libboost-thread-dev \
    libgtest-dev \
    cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Копіюємо всі файли в контейнер
COPY . /app

# Задаємо робочу директорію
WORKDIR /app

# Збираємо проект
RUN mkdir -p build && cd build && cmake .. && make

# Запускаємо сервер
CMD ["./build/http_server"]

