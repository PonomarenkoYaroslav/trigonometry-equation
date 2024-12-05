# Базовий образ для побудови
FROM ubuntu:20.04 AS builder

RUN apt-get update && apt-get install -y g++ make libboost-system-dev libboost-thread-dev libpthread-stubs0-dev

# Копіювання коду
WORKDIR /app
COPY . .

# Побудова програми
RUN g++ -o http_server http_server.cpp func.cpp -lboost_system -lboost_thread -lpthread

# Фінальний компактний образ
FROM ubuntu:20.04 AS final

RUN apt-get update && apt-get install -y libboost-system-dev libboost-thread-dev libpthread-stubs0-dev
COPY --from=builder /app/http_server /usr/local/bin/http_server

CMD ["http_server"]

