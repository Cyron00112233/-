package com.platform.admin_backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.platform.admin_backend.entity.ProjectMember;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ProjectMemberMapper extends BaseMapper<ProjectMember> {
    @Select("SELECT user_id FROM project_member WHERE project_id = #{projectId}")
    List<Long> selectUserIdsByProjectId(@Param("projectId") Long projectId);

    @Delete("DELETE FROM project_member WHERE project_id = #{projectId}")
    int deleteByProjectId(@Param("projectId") Long projectId);

    @Insert("<script>" +
            "INSERT INTO project_member (project_id, user_id) VALUES " +
            "<foreach collection=\"userIds\" item=\"uid\" separator=\",\">" +
            "(#{projectId}, #{uid})" +
            "</foreach>" +
            "</script>")
    int batchInsert(@Param("projectId") Long projectId, @Param("userIds") List<Long> userIds);
}