package ru.bmstu.iu7.rsoi.gulyy.coursework.groups.users;

import javax.persistence.*;
import java.io.Serializable;

/**
 * @author Konstantin Gulyy
 */

@Entity
@NamedQueries({
	@NamedQuery(name = GroupsUsers.FIND_ALL_GROUPS_USERS,
		    query = "SELECT g FROM GroupsUsers g WHERE g.projectId = ?1 AND g.groupId = ?2"),
	@NamedQuery(name = GroupsUsers.FIND_ALL_USER_GROUPS,
		    query = "SELECT g FROM GroupsUsers g WHERE g.projectId = ?1 AND g.userId = ?2"),
	@NamedQuery(name = GroupsUsers.FIND_ALL_USER_PROJECTS,
		    query = "SELECT g FROM GroupsUsers g WHERE g.userId = ?1"),
})
@IdClass(GroupsUsersPK.class)
@Table(name = "groups_users")
public class GroupsUsers {

    public static final String FIND_ALL_GROUPS_USERS  = "GroupsUsers.findAllGroupsUsers";
    public static final String FIND_ALL_USER_PROJECTS = "GroupsUsers.findAllUserProjects";
    public static final String FIND_ALL_USER_GROUPS   = "GroupsUsers.findAllUserGroups";

    @Id
    @Column(name = "project_id")
    private String projectId;

    @Id
    @Column(name = "group_id")
    private int groupId;

    @Id
    @Column(name = "user_id")
    private String userId;

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

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }
}

class GroupsUsersPK implements Serializable {
    private String projectId;
    private int groupId;
    private String userId;

    public GroupsUsersPK(String projectId, int groupId, String userId) {
        this.projectId = projectId;
        this.groupId = groupId;
        this.userId = userId;
    }
}
