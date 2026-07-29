package com.platform.admin_backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.platform.admin_backend.common.Result;
import com.platform.admin_backend.common.UserContextHolder;
import com.platform.admin_backend.entity.User;
import com.platform.admin_backend.enums.RoleEnum;
import com.platform.admin_backend.service.UserService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;
    private final PasswordEncoder passwordEncoder;

    public UserController(UserService userService, PasswordEncoder passwordEncoder) {
        this.userService = userService;
        this.passwordEncoder = passwordEncoder;
    }

    /** 分页查询所有用户（超管/管理员） */
    @GetMapping
    public Result<Page<User>> list(@RequestParam(defaultValue = "1") int pageNum,
                                    @RequestParam(defaultValue = "10") int pageSize) {
        if (UserContextHolder.getRole() == RoleEnum.EMPLOYEE) return Result.forbidden();
        Page<User> page = userService.page(new Page<>(pageNum, pageSize),
                new LambdaQueryWrapper<User>().orderByDesc(User::getCreateTime));
        return Result.success(page);
    }

    @GetMapping("/{id}")
    public Result<User> getById(@PathVariable Long id) {
        Long uid = UserContextHolder.getUserId();
        if (UserContextHolder.getRole() == RoleEnum.EMPLOYEE && !id.equals(uid)) return Result.forbidden();
        User user = userService.getById(id);
        return user != null ? Result.success(user) : Result.error(404, "not found");
    }

    /** 新增账号（超管） */
    @PostMapping
    public Result<?> create(@RequestBody User user) {
        if (UserContextHolder.getRole() != RoleEnum.SUPER_ADMIN) return Result.forbidden();
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        userService.save(user);
        return Result.success("created", user);
    }

    /** 修改用户信息（超管） */
    @PutMapping("/{id}")
    public Result<?> update(@PathVariable Long id, @RequestBody User user) {
        if (UserContextHolder.getRole() != RoleEnum.SUPER_ADMIN) return Result.forbidden();
        user.setId(id);
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        userService.updateById(user);
        return Result.success("updated");
    }

    /** 删除用户（超管） */
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        if (UserContextHolder.getRole() != RoleEnum.SUPER_ADMIN) return Result.forbidden();
        userService.removeById(id);
        return Result.success("deleted");
    }

    /** 修改密码（本人或超管） */
    @PutMapping("/{id}/password")
    public Result<?> changePassword(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Long currentUserId = UserContextHolder.getUserId();
        RoleEnum role = UserContextHolder.getRole();
        if (!currentUserId.equals(id) && role != RoleEnum.SUPER_ADMIN) return Result.forbidden();
        User user = userService.getById(id);
        if (user == null) return Result.error(404, "user not found");
        user.setPassword(passwordEncoder.encode(body.get("password")));
        userService.updateById(user);
        return Result.success("password changed");
    }
}