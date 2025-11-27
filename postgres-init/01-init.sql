-- =============================================================================
-- PostgreSQL 初始化脚本
-- =============================================================================
-- 这个文件会在 PostgreSQL 容器第一次启动时自动执行
-- 注意: 此脚本在默认数据库 (devdb) 上下文中运行
-- =============================================================================

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
