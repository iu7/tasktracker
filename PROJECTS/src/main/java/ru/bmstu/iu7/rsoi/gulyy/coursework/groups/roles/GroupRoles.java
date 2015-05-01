package ru.bmstu.iu7.rsoi.gulyy.coursework.groups.roles;

import javax.persistence.*;
import java.io.Serializable;

/**
 * @author Konstantin Gulyy
 */

@Entity
@IdClass(GroupRolesPK.class)
@NamedQuery(name = GroupRoles.FIND_ALL_GROUP_ROLES, query = "SELECT g FROM GroupRoles g WHERE g.projectId = ?1 AND g.groupId = ?2")
@Table(name = "group_roles")
public class GroupRoles {

    public static final String FIND_ALL_GROUP_ROLES = "GroupRoles.findAllGroupRoles";

    @Id
    @Column(name = "project_id")
    private String projectId;

    @Id
    @Column(name = "group_id")
    private int groupId;

    @Id
    @Column(name = "role_id")
    private int roleId;

    public String getProjectId() {
        return projectId;
    }

    public void setProjectId(String projectId) {
        this.projectId = projectId;
    }

    public int getGroupId() {
        return groupId;
    }

    public void setGroupId(int groupId) {
        this.groupId = groupId;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }
}

class GroupRolesPK implements Serializable {
    private String projectId;
    private int groupId;
    private int roleId;

    public GroupRolesPK(String projectId, int groupId, int roleId) {
        this.projectId = projectId;
        this.groupId = groupId;
        this.roleId = roleId;
    }
}
