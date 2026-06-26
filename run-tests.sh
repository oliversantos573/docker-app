#!/bin/bash
set -e

echo "=== Building application with tests ==="
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$(pwd)":/app -w /app maven:3.9-eclipse-temurin-17 mvn clean test

echo ""
echo "=== Tests completed successfully! ==="
echo ""
echo "Test Reports:"
echo "- JUnit: target/surefire-reports/"
echo "- JaCoCo Coverage: target/site/jacoco/"
