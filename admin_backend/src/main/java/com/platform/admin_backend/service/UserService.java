package com.platform.admin_backend.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.platform.admin_backend.entity.User;
import com.platform.admin_backend.enums.RoleEnum;

/**
 * 用户服务接口
 */
public interface UserService extends IService<User> {

    /**
     * 根据用户 ID 获取角色，用于权限校验
     */
    RoleEnum getRoleById(Long userId);
}
