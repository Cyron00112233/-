package com.platform.admin_backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.platform.admin_backend.common.GlobalExceptionHandler.BusinessException;
import com.platform.admin_backend.common.UserContextHolder;
import com.platform.admin_backend.entity.Project;
import com.platform.admin_backend.enums.RoleEnum;
import com.platform.admin_backend.mapper.ProjectMapper;
import com.platform.admin_backend.mapper.ProjectMemberMapper;
import com.platform.admin_backend.service.ProjectService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
public class ProjectServiceImpl extends ServiceImpl<ProjectMapper, Project> implements ProjectService {
    private final ProjectMemberMapper projectMemberMapper;
    public ProjectServiceImpl(ProjectMemberMapper projectMemberMapper) { this.projectMemberMapper = projectMemberMapper; }

    @Override
    public List<Project> listProjects(int pageNum, int pageSize) {
        Page<Project> page = page(new Page<>(pageNum, pageSize),
                new LambdaQueryWrapper<Project>().orderByDesc(Project::getCreateTime));
        return page.getRecords();
    }

    @Override
    @Transactional
    public void createProject(Project project, List<Long> memberIds) {
        if (UserContextHolder.getRole() == RoleEnum.EMPLOYEE) throw new BusinessException(403, "forbidden");
        project.setCreatorId(UserContextHolder.getUserId());
        save(project);
        if (memberIds != null && !memberIds.isEmpty()) projectMemberMapper.batchInsert(project.getId(), memberIds);
    }

    @Override
    public void updateProject(Project project) {
        Long userId = UserContextHolder.getUserId();
        RoleEnum role = UserContextHolder.getRole();
        Project existing = getById(project.getId());
        if (existing == null) throw new BusinessException(404, "not found");
        if (role == RoleEnum.SUPER_ADMIN) updateById(project);
        else if (role == RoleEnum.ADMIN && existing.getCreatorId().equals(userId)) updateById(project);
        else throw new BusinessException(403, "forbidden");
    }

    @Override
    public void deleteProject(Long projectId) {
        if (UserContextHolder.getRole() != RoleEnum.SUPER_ADMIN) throw new BusinessException(403, "forbidden");
        projectMemberMapper.deleteByProjectId(projectId);
        removeById(projectId);
    }

    @Override
    @Transactional
    public void assignMembers(Long projectId, List<Long> memberIds) {
        Long userId = UserContextHolder.getUserId();
        RoleEnum role = UserContextHolder.getRole();
        if (role == RoleEnum.EMPLOYEE) throw new BusinessException(403, "forbidden");
        Project project = getById(projectId);
        if (project == null) throw new BusinessException(404, "not found");
        if (role == RoleEnum.ADMIN && !project.getCreatorId().equals(userId)) throw new BusinessException(403, "forbidden");
        projectMemberMapper.deleteByProjectId(projectId);
        if (memberIds != null && !memberIds.isEmpty()) projectMemberMapper.batchInsert(projectId, memberIds);
    }

    @Override
    public void removeMember(Long projectId, Long userId) {
        Long currentUserId = UserContextHolder.getUserId();
        RoleEnum role = UserContextHolder.getRole();
        if (role == RoleEnum.EMPLOYEE) throw new BusinessException(403, "forbidden");
        Project project = getById(projectId);
        if (project == null) throw new BusinessException(404, "project not found");
        if (role == RoleEnum.ADMIN && !project.getCreatorId().equals(currentUserId)) throw new BusinessException(403, "forbidden");
        projectMemberMapper.delete(new LambdaQueryWrapper<com.platform.admin_backend.entity.ProjectMember>()
                .eq(com.platform.admin_backend.entity.ProjectMember::getProjectId, projectId)
                .eq(com.platform.admin_backend.entity.ProjectMember::getUserId, userId));
    }
}