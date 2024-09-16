FROM gradle:8.10.1-jdk21-alpine as builder

WORKDIR /app

COPY . .

RUN gradle build -x test --no-daemon --continue

FROM amazoncorretto:21-alpine3.20-jdk

ENV ENV_SERVER_PORT=8080

WORKDIR /app

COPY --from=builder /app/build/libs/*SNAPSHOT.jar /app/server.jar
EXPOSE ${ENV_SERVER_PORT}

CMD ["java", "-jar", "/app/server.jar", "--server.port=${ENV_SERVER_PORT}", "--debug"]
