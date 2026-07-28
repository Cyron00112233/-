package com.platform.admin_backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.platform.admin_backend.common.Result;
import com.platform.admin_backend.common.UserContextHolder;
import com.platform.admin_backend.entity.Project;
import com.platform.admin_backend.entity.ProjectMember;
import com.platform.admin_backend.entity.User;
import com.platform.admin_backend.service.ProjectService;
import com.platform.admin_backend.service.UserService;
import com.platform.admin_backend.mapper.ProjectMemberMapper;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/projects")
public class ProjectController {
    private final ProjectService projectService;
    private final ProjectMemberMapper projectMemberMapper;
    private final UserService userService;

    public ProjectController(ProjectService projectService, ProjectMemberMapper projectMemberMapper, UserService userService) {
        this.projectService = projectService; this.projectMemberMapper = projectMemberMapper; this.userService = userService;
    }

    /** 查询项目列表（自动按角色过滤） */
    @GetMapping
    public Result<List<Project>> list(@RequestParam(defaultValue = "1") int pageNum,
                                       @RequestParam(defaultValue = "10") int pageSize) {
        return Result.success(projectService.listProjects(pageNum, pageSize));
    }

    /** 员工查询自己所属项目 */
    @GetMapping("/my")
    public Result<List<Project>> myProjects(@RequestParam(defaultValue = "1") int pageNum,
                                             @RequestParam(defaultValue = "10") int pageSize) {
        return Result.success(projectService.listProjects(pageNum, pageSize));
    }

    @GetMapping("/{id}")
    public Result<Project> getById(@PathVariable Long id) {
        Project p = projectService.getById(id);
        return p != null ? Result.success(p) : Result.error(404, "not found");
    }

    /** 创建项目（管理员及以上） */
    @PostMapping
    public Result<?> create(@RequestBody Project project, @RequestParam(required = false) List<Long> memberIds) {
        projectService.createProject(project, memberIds);
        return Result.success("created", project);
    }

    /** 修改项目（超管/创建者） */
    @PutMapping("/{id}")
    public Result<?> update(@PathVariable Long id, @RequestBody Project project) {
        project.setId(id);
        projectService.updateProject(project);
        return Result.success("updated");
    }

    /** 删除项目（仅超管） */
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        projectService.deleteProject(id);
        return Result.success("deleted");
    }

    /** 分配人员到项目 */
    @PostMapping("/{id}/members")
    public Result<?> assignMembers(@PathVariable Long id, @RequestBody List<Long> memberIds) {
        projectService.assignMembers(id, memberIds);
        return Result.success("assigned");
    }

    /** 移除项目内某个员工 */
    @DeleteMapping("/{projectId}/members/{userId}")
    public Result<?> removeMember(@PathVariable Long projectId, @PathVariable Long userId) {
        projectService.removeMember(projectId, userId);
        return Result.success("removed");
    }

    /** 查询某个项目下所有员工 */
    @GetMapping("/{id}/members")
    public Result<List<User>> getMembers(@PathVariable Long id) {
        List<Long> userIds = projectMemberMapper.selectUserIdsByProjectId(id);
        if (userIds.isEmpty()) return Result.success(List.of());
        List<User> users = userService.list(new LambdaQueryWrapper<User>().in(User::getId, userIds));
        return Result.success(users);
    }
}