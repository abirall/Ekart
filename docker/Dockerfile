# Stage 1: Build the application using Maven
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy pom.xml and download dependencies (better caching)
COPY ../pom.xml .
COPY ../mvnw .
COPY ../.mvn .mvn
COPY ../src ./src
RUN ./mvnw dependency:go-offline -B

# Copy the source code
COPY src ./src

# Package the application (skip tests for faster build)
RUN ./mvnw package -DskipTests

# Stage 2: Run the application using JDK
FROM eclipse-temurin:17-jdk

# Set the working directory
WORKDIR /app

# Copy the jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose application port (change if not 8080)
EXPOSE 8080

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
