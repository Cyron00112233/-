package com.platform.admin_backend.enums;

/**
 * 用户角色枚举
 */
public enum RoleEnum {
    /** 超级管理员：全部增删改查权限 */
    SUPER_ADMIN,
    /** 管理员：创建项目、分配人员、查看所有项目 */
    ADMIN,
    /** 普通员工：仅查询自己关联的项目 */
    EMPLOYEE
}
