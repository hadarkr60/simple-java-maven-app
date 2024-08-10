# Use a minimal Debian-based image as a parent image
FROM debian:bullseye-slim AS build

# Install necessary packages and OpenJDK
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    wget \
    openjdk-17-jdk=17.0.1+12-1~deb11u1 \
    maven=3.8.1-1 \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the pom.xml and source code
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package

# Use a minimal Debian-based image to run the application
FROM debian:bullseye-slim

# Install OpenJDK for running the application
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    openjdk-17-jdk=17.0.1+12-1~deb11u1 \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the built jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
