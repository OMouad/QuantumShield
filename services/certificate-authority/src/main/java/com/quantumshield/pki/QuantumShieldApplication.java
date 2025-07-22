package com.quantumshield.pki;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.context.annotation.Profile;
import org.springframework.retry.annotation.EnableRetry;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
@EnableAsync
@EnableRetry
@Profile("!test")
@ConfigurationPropertiesScan("com.quantumshield.pki.config")
public class QuantumShieldApplication {

    public static void main(String[] args) {
        SpringApplication.run(QuantumShieldApplication.class, args);
    }
}
