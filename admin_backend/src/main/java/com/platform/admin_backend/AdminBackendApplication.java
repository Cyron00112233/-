package com.platform.admin_backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = {"com.platform.admin_backend.common", "com.platform.admin_backend.config", "com.platform.admin_backend.controller", "com.platform.admin_backend.service"})
public class AdminBackendApplication {
    public static void main(String[] args) {
        SpringApplication.run(AdminBackendApplication.class, args);
    }
}