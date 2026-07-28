package com.platform.admin_backend.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.platform.admin_backend.entity.User;
import com.platform.admin_backend.enums.RoleEnum;
import com.platform.admin_backend.mapper.UserMapper;
import com.platform.admin_backend.service.UserService;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {
    @Override
    public RoleEnum getRoleById(Long userId) {
        User user = getById(userId);
        return user != null ? user.getRole() : null;
    }
}