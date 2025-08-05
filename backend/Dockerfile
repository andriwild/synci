FROM gradle:8.10.1-jdk21-alpine as builder

ARG AUTH0_URL
ENV AUTH0_URL=$AUTH0_URL

WORKDIR /app

COPY . .

ENV DB_HOST=localhost

RUN gradle build -x test --no-daemon --continue

FROM amazoncorretto:21-alpine3.20-jdk

ENV ENV_SERVER_PORT=8080

WORKDIR /app

COPY --from=builder /app/build/libs/*SNAPSHOT.jar /app/server.jar
EXPOSE ${ENV_SERVER_PORT}

CMD ["java", "-jar", "/app/server.jar", "--server.port=${ENV_SERVER_PORT}", "--debug"]

# build command: docker build --network="host" --build-arg DB_HOST=localhost --build-arg  SPRING_ACTIVE_PROFILE=local ./backend -t synci-backend-test

