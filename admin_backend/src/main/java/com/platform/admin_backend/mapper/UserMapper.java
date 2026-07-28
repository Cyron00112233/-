package com.platform.admin_backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.platform.admin_backend.entity.User;
import org.springframework.stereotype.Repository;

@Repository
public interface UserMapper extends BaseMapper<User> {
}