-- ============================================================
-- 中台管理系统 数据库初始化脚本
-- ============================================================

CREATE DATABASE IF NOT EXISTS admin_platform
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;

USE admin_platform;

-- ----------------------------
-- 用户表
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `username`    VARCHAR(50)  NOT NULL COMMENT '用户名（登录账号）',
    `password`    VARCHAR(255) NOT NULL COMMENT '密码（加密存储）',
    `real_name`   VARCHAR(50)  DEFAULT NULL COMMENT '真实姓名',
    `role`        VARCHAR(20)  NOT NULL COMMENT '角色：SUPER_ADMIN / ADMIN / EMPLOYEE',
    `create_time` DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`     TINYINT      DEFAULT 0 COMMENT '逻辑删除（0-未删除，1-已删除）',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ----------------------------
-- 项目表
-- ----------------------------
DROP TABLE IF EXISTS `project`;
CREATE TABLE `project` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `name`        VARCHAR(100) NOT NULL COMMENT '项目名称',
    `description` TEXT         DEFAULT NULL COMMENT '项目描述',
    `status`      VARCHAR(20)  DEFAULT '进行中' COMMENT '项目状态',
    `creator_id`  BIGINT       NOT NULL COMMENT '创建者 ID',
    `create_time` DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`     TINYINT      DEFAULT 0 COMMENT '逻辑删除（0-未删除，1-已删除）',
    PRIMARY KEY (`id`),
    KEY `idx_creator` (`creator_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目表';

-- ----------------------------
-- 项目成员关联表
-- ----------------------------
DROP TABLE IF EXISTS `project_member`;
CREATE TABLE `project_member` (
    `id`          BIGINT   NOT NULL AUTO_INCREMENT COMMENT '主键',
    `project_id`  BIGINT   NOT NULL COMMENT '项目 ID',
    `user_id`     BIGINT   NOT NULL COMMENT '用户 ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '分配时间',
    PRIMARY KEY (`id`),
    KEY `idx_project` (`project_id`),
    KEY `idx_user`    (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目成员关联表';

-- ----------------------------
-- 初始测试数据
-- ----------------------------
-- 密码均为 123456 的 BCrypt 加密值
INSERT INTO `user` (`username`, `password`, `real_name`, `role`) VALUES
('superadmin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5Eh', '超级管理员', 'SUPER_ADMIN'),
('admin',      '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5Eh', '项目管理员', 'ADMIN'),
('employee1',  '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5Eh', '员工张三',   'EMPLOYEE'),
('employee2',  '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5Eh', '员工李四',   'EMPLOYEE');
