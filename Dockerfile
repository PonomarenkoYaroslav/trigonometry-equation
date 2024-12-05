# Базовий образ для побудови
FROM ubuntu:20.04 AS builder

RUN apt-get update && apt-get install -y g++ make libboost-system-dev libboost-thread-dev

# Копіювання коду
WORKDIR /app
COPY . .

# Побудова програми
RUN g++ -o myapp main.cpp func.cpp -lboost_system -lboost_thread

# Фінальний компактний образ
FROM ubuntu:20.04 AS final

RUN apt-get update && apt-get install -y libboost-system-dev libboost-thread-dev
COPY --from=builder /app/myapp /usr/local/bin/myapp

CMD ["myapp"]

