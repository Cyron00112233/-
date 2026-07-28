package com.platform.admin_backend.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.platform.admin_backend.entity.Project;
import java.util.List;

public interface ProjectService extends IService<Project> {
    List<Project> listProjects(int pageNum, int pageSize);
    void createProject(Project project, List<Long> memberIds);
    void updateProject(Project project);
    void deleteProject(Long projectId);
    void assignMembers(Long projectId, List<Long> memberIds);
    void removeMember(Long projectId, Long userId);
}