# syntax=docker/dockerfile:1

############################
# Builder image
############################
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /workspace

# Copy only POMs first to leverage Docker layer caching
COPY pom.xml ./pom.xml
COPY services/certificate-authority/pom.xml services/certificate-authority/pom.xml

# Pre-fetch dependencies for faster subsequent builds
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B -ntp -q -pl services/certificate-authority -am dependency:go-offline

# Copy source and build the module
COPY services/certificate-authority/src services/certificate-authority/src
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B -ntp -pl services/certificate-authority -am clean package -DskipTests

############################
# Runtime image
############################
FROM eclipse-temurin:21-jre

# Create non-root user
RUN useradd -ms /bin/bash app
WORKDIR /app

# Copy the fat JAR from the builder stage
COPY --from=build /workspace/services/certificate-authority/target/*-SNAPSHOT.jar /app/app.jar

# Optional JVM args (e.g., -Xms256m -Xmx512m)
ENV JAVA_OPTS=""

EXPOSE 8080
USER app

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app/app.jar"]

