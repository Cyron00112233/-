package com.platform.admin_backend.controller;

import com.platform.admin_backend.common.Result;
import com.platform.admin_backend.common.UserContextHolder;
import com.platform.admin_backend.entity.User;
import com.platform.admin_backend.enums.RoleEnum;
import com.platform.admin_backend.service.UserService;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;
    public UserController(UserService userService) { this.userService = userService; }

    /** 分页查询所有用户（超管/管理员） */
    @GetMapping
    public Result<List<User>> list(@RequestParam(defaultValue = "1") int pageNum,
                                    @RequestParam(defaultValue = "10") int pageSize) {
        if (UserContextHolder.getRole() == RoleEnum.EMPLOYEE) return Result.forbidden();
        return Result.success(userService.list());
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
        userService.save(user);
        return Result.success("created", user);
    }

    /** 修改用户信息（超管） */
    @PutMapping("/{id}")
    public Result<?> update(@PathVariable Long id, @RequestBody User user) {
        if (UserContextHolder.getRole() != RoleEnum.SUPER_ADMIN) return Result.forbidden();
        user.setId(id);
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
        user.setPassword(body.get("password"));
        userService.updateById(user);
        return Result.success("password changed");
    }
}