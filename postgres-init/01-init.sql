-- 初始化数据库脚本
-- 这个文件会在 PostgreSQL 容器第一次启动时自动执行

-- 创建一个示例数据库和表
CREATE DATABASE IF NOT EXISTS sampledb;

-- 切换到示例数据库
\c sampledb;

-- 创建示例表
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 插入示例数据
INSERT INTO users (username, email) VALUES 
    ('admin', 'admin@example.com'),
    ('user1', 'user1@example.com'),
    ('user2', 'user2@example.com')
ON CONFLICT (username) DO NOTHING;