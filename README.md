# QuantumShield

Enterprise PKI Platform with Post-Quantum Cryptography support. This repo currently contains the Certificate Authority (CA) service scaffold with a strong DevSecOps baseline.

## Requirements
- Java 21 (Temurin recommended). No global Maven needed; Maven Wrapper is included.
- Docker (optional) for container builds and local scans.

## Build & Test
- Build all modules: `./mvnw clean verify` (Windows: `mvnw.cmd`)
- CA service only: `./mvnw -f services/certificate-authority/pom.xml clean package`
- Run tests only: `./mvnw -f services/certificate-authority/pom.xml test`

First tests included:
- Context loads test
- Simple controller test (`GET /ping -> 200 pong`)

## Run Locally
- Direct: `./mvnw -f services/certificate-authority/pom.xml spring-boot:run`
- Jar: `java -jar services/certificate-authority/target/quantumshield-pki-1.0.0-SNAPSHOT.jar`
- Default port: `8080` (Actuator enabled). Security is on by default.

## Docker
- Build image: `docker build -t quantumshield/ca:dev -f services/certificate-authority/Dockerfile .`
- Run: `docker run --rm -p 8080:8080 --name qs-ca-dev quantumshield/ca:dev`

Image notes:
- Multi-stage build (Maven -> JRE), runs as non-root.
- Consider running with hardening flags in production: `--read-only --cap-drop ALL --memory ... --cpus ...`.

## GitHub Actions (DevSecOps)
CI workflows in `.github/workflows`:
- `ci.yml` (build/test + security):
  - Build & test with Java 21
  - SBOM (CycloneDX)
  - Secrets scan (Gitleaks)
- `codeql.yml`: Code scanning (Java)
- `dependency-review.yml`: PR dependency risk checks

Run workflows locally with `act`:
- List jobs: `bash scripts/run-act.sh --list`
- Build job: `bash scripts/run-act.sh -j build`
- SBOM: `bash scripts/run-act.sh -j sbom`
- Secrets scan: `bash scripts/run-act.sh -j secrets`

## Security Posture
- Reproducible builds via Maven Wrapper.
- SBOM generation for dependency inventory.
- Secrets scanning (Gitleaks).
- CodeQL for static analysis; dependency review on PRs.
- Container runs as non-root; small base (JRE 21).

## Roadmap
- Add persistence (JPA + Flyway) and domain entities
- Add container image scanning (Trivy/Grype) and publish SARIF
- Add formatting (Spotless) and dependency updates automation (Dependabot)
