-- Schema initialization for AI Virtual Dress Try-On
CREATE DATABASE IF NOT EXISTS virtual_tryon CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE virtual_tryon;

-- Table: users
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: garments
CREATE TABLE IF NOT EXISTS garments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    image_path VARCHAR(500) NOT NULL,
    category VARCHAR(50) DEFAULT 'general',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_garment_user (user_id),
    CONSTRAINT fk_garments_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: tryon_sessions
CREATE TABLE IF NOT EXISTS tryon_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    garment_id INT NOT NULL,
    person_image_path VARCHAR(500) NOT NULL,
    result_image_path VARCHAR(500) NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tryon_user (user_id),
    INDEX idx_tryon_garment (garment_id),
    CONSTRAINT fk_tryon_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_tryon_garment FOREIGN KEY (garment_id) REFERENCES garments (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
