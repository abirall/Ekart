# Stage 1: Build the application
# ================================
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Set working directory
WORKDIR /app

# Copy Maven files first (for caching dependencies)
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

# Download dependencies (faster builds thanks to caching)
RUN ./mvnw dependency:go-offline -B

# Copy the source code
COPY src ./src

# Package the application (skip tests for speed)
RUN ./mvnw package -DskipTests

# ================================
# Stage 2: Run the application
# ================================
FROM eclipse-temurin:17-jdk

# Set working directory
WORKDIR /app

# Copy the built jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the app port (default Spring Boot is 8080)
EXPOSE 8080

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
