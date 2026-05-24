-- =====================================================
-- NEUROSCAN AI - DATABASE SCHEMA
-- Alzheimer's Detection System
-- =====================================================
-- Version: 2.0
-- Date: 2024
-- Database: neuroai_db
-- =====================================================

-- =====================================================
-- 1. CREATE DATABASE
-- =====================================================

CREATE DATABASE IF NOT EXISTS neuroai_db;
USE neuroai_db;

-- =====================================================
-- 2. PATIENTS TABLE
-- Stores all patient/user information
-- =====================================================

DROP TABLE IF EXISTS patients;

CREATE TABLE patients (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique patient identifier',
    name VARCHAR(100) NOT NULL COMMENT 'Full name of patient',
    phone VARCHAR(15) UNIQUE NOT NULL COMMENT 'Indian mobile number (10 digits)',
    email VARCHAR(100) UNIQUE NOT NULL COMMENT 'Email address for login',
    age INT COMMENT 'Age in years',
    gender ENUM('Male', 'Female', 'Other') COMMENT 'Gender identification',
    password VARCHAR(255) NOT NULL COMMENT 'Bcrypt hashed password',
    theme_preference ENUM('light', 'dark') DEFAULT 'light' COMMENT 'UI theme preference',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Account creation timestamp',
    
    INDEX idx_patient_email (email),
    INDEX idx_patient_phone (phone),
    INDEX idx_patient_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Patient/User accounts';

-- =====================================================
-- 3. DOCTORS TABLE
-- Stores medical professional information
-- =====================================================

DROP TABLE IF EXISTS doctors;

CREATE TABLE doctors (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique doctor identifier',
    name VARCHAR(100) NOT NULL COMMENT 'Full name with Dr. prefix',
    phone VARCHAR(15) UNIQUE NOT NULL COMMENT 'Contact number',
    email VARCHAR(100) UNIQUE NOT NULL COMMENT 'Professional email',
    password VARCHAR(255) NOT NULL COMMENT 'Bcrypt hashed password',
    specialization VARCHAR(100) COMMENT 'Medical specialization (Neurology, Radiology, etc.)',
    hospital VARCHAR(200) COMMENT 'Affiliated hospital/clinic',
    experience_years INT COMMENT 'Years of professional experience',
    license_number VARCHAR(50) UNIQUE COMMENT 'Medical license/registration number',
    theme_preference ENUM('light', 'dark') DEFAULT 'light' COMMENT 'UI theme preference',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Registration timestamp',
    
    INDEX idx_doctor_email (email),
    INDEX idx_doctor_license (license_number),
    INDEX idx_doctor_specialization (specialization)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Doctor/Medical professional accounts';

-- =====================================================
-- 4. MRI SCANS TABLE
-- Stores all MRI analysis results and reports
-- =====================================================

DROP TABLE IF EXISTS mri_scans;

CREATE TABLE mri_scans (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique scan identifier',
    patient_id INT NOT NULL COMMENT 'Reference to patient who owns this scan',
    image_path VARCHAR(500) COMMENT 'Path to uploaded MRI image file',
    
    -- Trained Model (Alzheimer's CNN) Results
    trained_stage VARCHAR(50) COMMENT 'Alzheimer\'s stage from trained CNN model',
    trained_confidence DECIMAL(5,2) COMMENT 'Confidence percentage (0-100) for trained model',
    
    -- Untrained Model (EfficientNet) Results
    untrained_stage VARCHAR(50) COMMENT 'Alzheimer\'s stage from untrained model',
    untrained_confidence DECIMAL(5,2) COMMENT 'Confidence percentage (0-100) for untrained model',
    
    -- Comparison Metrics
    stage_agreement BOOLEAN COMMENT 'Whether both models agree on the stage',
    confidence_difference DECIMAL(5,2) COMMENT 'Absolute difference in confidence scores',
    
    -- Additional Data
    findings_summary TEXT COMMENT 'JSON string with detailed findings and recommendations',
    graph_data LONGTEXT COMMENT 'Base64 encoded comparison graphs (4 charts)',
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Scan analysis timestamp',
    
    -- Foreign Keys
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    
    INDEX idx_scan_patient (patient_id),
    INDEX idx_scan_date (created_at),
    INDEX idx_scan_stage (trained_stage),
    INDEX idx_scan_agreement (stage_agreement)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='MRI scan analysis records';

-- =====================================================
-- 5. DOCTOR_PATIENTS TABLE (Junction Table)
-- Links doctors with their assigned patients
-- =====================================================

DROP TABLE IF EXISTS doctor_patients;

CREATE TABLE doctor_patients (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique relationship identifier',
    doctor_id INT NOT NULL COMMENT 'Reference to doctor',
    patient_id INT NOT NULL COMMENT 'Reference to patient',
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When patient was assigned to doctor',
    notes TEXT COMMENT 'Doctor\'s notes about the patient',
    
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_doctor_patient (doctor_id, patient_id),
    
    INDEX idx_dp_doctor (doctor_id),
    INDEX idx_dp_patient (patient_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Doctor-Patient assignment relationships';

-- =====================================================
-- 6. ADMIN TABLE
-- System administrator accounts
-- =====================================================

DROP TABLE IF EXISTS admin;

CREATE TABLE admin (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique admin identifier',
    username VARCHAR(50) DEFAULT 'admin' UNIQUE COMMENT 'Admin username',
    password VARCHAR(255) COMMENT 'Bcrypt hashed password',
    theme_preference ENUM('light', 'dark') DEFAULT 'light' COMMENT 'UI theme preference',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Account creation date',
    last_login TIMESTAMP NULL COMMENT 'Last login timestamp',
    
    INDEX idx_admin_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System administrator accounts';

-- =====================================================
-- 7. INSERT DEFAULT DATA
-- =====================================================

-- Insert default admin user (password: admin123)
-- Note: Password is bcrypt hashed version of 'admin123'
INSERT INTO admin (username, password) 
VALUES ('admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LexY7QmDqZzZzZzZz')
ON DUPLICATE KEY UPDATE id=id;

-- Insert demo doctor (password: doctor123)
INSERT INTO doctors (name, phone, email, password, specialization, hospital, experience_years, license_number)
VALUES (
    'Dr. Alex Johnson',
    '9876543210',
    'doctor@neuroscan.ai',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LexY7QmDqZzZzZzZz',
    'Neurology',
    'City General Hospital',
    10,
    'NEURO12345'
) ON DUPLICATE KEY UPDATE id=id;

-- Insert demo patient (password: patient123)
INSERT INTO patients (name, phone, email, age, gender, password)
VALUES (
    'John Doe',
    '9876543211',
    'patient@neuroscan.ai',
    65,
    'Male',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LexY7QmDqZzZzZzZz'
) ON DUPLICATE KEY UPDATE id=id;

-- =====================================================
-- 8. HELPER VIEWS FOR REPORTS
-- =====================================================

-- View: Patient Scan Summary
DROP VIEW IF EXISTS v_patient_scan_summary;

CREATE VIEW v_patient_scan_summary AS
SELECT 
    p.id AS patient_id,
    p.name AS patient_name,
    p.age,
    p.gender,
    COUNT(m.id) AS total_scans,
    MAX(m.created_at) AS last_scan_date,
    (SELECT trained_stage FROM mri_scans 
     WHERE patient_id = p.id 
     ORDER BY created_at DESC LIMIT 1) AS latest_stage,
    AVG(m.trained_confidence) AS avg_confidence
FROM patients p
LEFT JOIN mri_scans m ON p.id = m.patient_id
GROUP BY p.id;

-- View: Doctor Patient Statistics
DROP VIEW IF EXISTS v_doctor_stats;

CREATE VIEW v_doctor_stats AS
SELECT 
    d.id AS doctor_id,
    d.name AS doctor_name,
    d.specialization,
    COUNT(DISTINCT dp.patient_id) AS total_patients,
    COUNT(m.id) AS total_scans_analyzed
FROM doctors d
LEFT JOIN doctor_patients dp ON d.id = dp.doctor_id
LEFT JOIN patients p ON dp.patient_id = p.id
LEFT JOIN mri_scans m ON p.id = m.patient_id
GROUP BY d.id;

-- View: Stage Distribution Summary
DROP VIEW IF EXISTS v_stage_distribution;

CREATE VIEW v_stage_distribution AS
SELECT 
    DATE(created_at) AS scan_date,
    COUNT(*) AS total_scans,
    SUM(CASE WHEN trained_stage LIKE '%Non%' THEN 1 ELSE 0 END) AS normal,
    SUM(CASE WHEN trained_stage LIKE '%Very Mild%' THEN 1 ELSE 0 END) AS very_mild,
    SUM(CASE WHEN trained_stage LIKE '%Mild%' AND trained_stage NOT LIKE '%Very%' THEN 1 ELSE 0 END) AS mild,
    SUM(CASE WHEN trained_stage LIKE '%Moderate%' THEN 1 ELSE 0 END) AS moderate,
    AVG(CASE WHEN stage_agreement = 1 THEN 1 ELSE 0 END) * 100 AS agreement_rate
FROM mri_scans
GROUP BY DATE(created_at)
ORDER BY scan_date DESC;

-- =====================================================
-- 9. STORED PROCEDURES
-- =====================================================

DELIMITER //

-- Procedure: Get Patient Analysis History
CREATE PROCEDURE GetPatientAnalysisHistory(IN patientId INT)
BEGIN
    SELECT 
        m.id,
        m.trained_stage,
        m.trained_confidence,
        m.untrained_stage,
        m.untrained_confidence,
        m.stage_agreement,
        m.created_at,
        TIMESTAMPDIFF(DAY, m.created_at, NOW()) AS days_ago
    FROM mri_scans m
    WHERE m.patient_id = patientId
    ORDER BY m.created_at DESC;
END//

-- Procedure: Get System Statistics
CREATE PROCEDURE GetSystemStatistics()
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM patients) AS total_patients,
        (SELECT COUNT(*) FROM doctors) AS total_doctors,
        (SELECT COUNT(*) FROM mri_scans) AS total_scans,
        (SELECT COUNT(*) FROM mri_scans WHERE DATE(created_at) = CURDATE()) AS today_scans,
        (SELECT COUNT(*) FROM mri_scans WHERE stage_agreement = 0) AS disagreement_count,
        (SELECT AVG(trained_confidence) FROM mri_scans) AS avg_confidence,
        (SELECT trained_stage FROM mri_scans ORDER BY created_at DESC LIMIT 1) AS latest_stage;
END//

-- Procedure: Clean Old Scans (Delete scans older than N days)
CREATE PROCEDURE CleanOldScans(IN daysOld INT)
BEGIN
    DELETE FROM mri_scans 
    WHERE created_at < DATE_SUB(NOW(), INTERVAL daysOld DAY);
    
    SELECT ROW_COUNT() AS deleted_count;
END//

DELIMITER ;

-- =====================================================
-- 10. TRIGGERS FOR DATA INTEGRITY
-- =====================================================

DELIMITER //

-- Trigger: Validate confidence score before insert
CREATE TRIGGER validate_confidence_before_insert
BEFORE INSERT ON mri_scans
FOR EACH ROW
BEGIN
    IF NEW.trained_confidence < 0 OR NEW.trained_confidence > 100 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Trained confidence must be between 0 and 100';
    END IF;
    
    IF NEW.untrained_confidence < 0 OR NEW.untrained_confidence > 100 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Untrained confidence must be between 0 and 100';
    END IF;
END//

-- Trigger: Update confidence difference automatically
CREATE TRIGGER update_confidence_difference_before_insert
BEFORE INSERT ON mri_scans
FOR EACH ROW
BEGIN
    SET NEW.confidence_difference = ABS(NEW.trained_confidence - NEW.untrained_confidence);
END//

-- Trigger: Update confidence difference on update
CREATE TRIGGER update_confidence_difference_before_update
BEFORE UPDATE ON mri_scans
FOR EACH ROW
BEGIN
    SET NEW.confidence_difference = ABS(NEW.trained_confidence - NEW.untrained_confidence);
END//

DELIMITER ;

-- =====================================================
-- 11. INDEXES FOR PERFORMANCE
-- =====================================================

-- Additional indexes for common queries
CREATE INDEX idx_scans_patient_date ON mri_scans(patient_id, created_at);
CREATE INDEX idx_scans_stage_confidence ON mri_scans(trained_stage, trained_confidence);
CREATE INDEX idx_patients_age ON patients(age);
CREATE INDEX idx_patients_gender ON patients(gender);
CREATE INDEX idx_doctors_experience ON doctors(experience_years);

-- =====================================================
-- 12. GRANT PRIVILEGES (Adjust as needed)
-- =====================================================

-- Create application user (optional - adjust username/password)
-- CREATE USER IF NOT EXISTS 'neuroapp'@'localhost' IDENTIFIED BY 'secure_password_here';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON neuroai_db.* TO 'neuroapp'@'localhost';
-- FLUSH PRIVILEGES;

-- =====================================================
-- 13. VERIFICATION QUERIES
-- =====================================================

-- Check all tables were created
SHOW TABLES;

-- Check table structures
DESCRIBE patients;
DESCRIBE doctors;
DESCRIBE mri_scans;
DESCRIBE doctor_patients;
DESCRIBE admin;

-- Verify default data
SELECT '=== Default Admin ===' AS '';
SELECT username, '********' as password FROM admin;

SELECT '=== Demo Doctor ===' AS '';
SELECT name, email, specialization FROM doctors WHERE email = 'doctor@neuroscan.ai';

SELECT '=== Demo Patient ===' AS '';
SELECT name, email, age, gender FROM patients WHERE email = 'patient@neuroscan.ai';

-- =====================================================
-- END OF SCHEMA
-- =====================================================