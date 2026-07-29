package com.platform.admin_backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.platform.admin_backend.common.JwtUtil;
import com.platform.admin_backend.common.Result;
import com.platform.admin_backend.common.UserContextHolder;
import com.platform.admin_backend.entity.User;
import com.platform.admin_backend.service.UserService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final UserService userService;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;

    public AuthController(UserService userService, JwtUtil jwtUtil, PasswordEncoder passwordEncoder) {
        this.userService = userService;
        this.jwtUtil = jwtUtil;
        this.passwordEncoder = passwordEncoder;
    }

    @PostMapping("/login")
    public Result<?> login(@RequestBody LoginRequest request) {
        User user = userService.getOne(new LambdaQueryWrapper<User>().eq(User::getUsername, request.getUsername()));
        if (user == null || !passwordEncoder.matches(request.getPassword(), user.getPassword()))
            return Result.error(401, "bad credentials");
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
        return Result.success(Map.of("token", token, "userId", user.getId(), "username", user.getUsername(), "role", user.getRole().name()));
    }

    @GetMapping("/me")
    public Result<?> me() {
        Long userId = UserContextHolder.getUserId();
        if (userId == null) return Result.unauthorized();
        User user = userService.getById(userId);
        if (user == null) return Result.error(404, "user not found");
        return Result.success(Map.of("userId", user.getId(), "username", user.getUsername(), "role", user.getRole().name()));
    }

    
    /** 初始化/重置管理员密码（无需登录） */
    @PostMapping("/init")
    public Result<?> init(@RequestBody LoginRequest request) {
        User user = userService.getOne(new LambdaQueryWrapper<User>().eq(User::getUsername, request.getUsername()));
        if (user == null) {
            user = new User();
            user.setUsername(request.getUsername());
            user.setRealName("超级管理员");
            user.setRole(com.platform.admin_backend.enums.RoleEnum.SUPER_ADMIN);
        }
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        userService.saveOrUpdate(user);
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
        return Result.success(Map.of("token", token, "userId", user.getId(), "username", user.getUsername(), "role", user.getRole().name()));
    }

    public static class LoginRequest {
        private String username;
        private String password;
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
    }
}