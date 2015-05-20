package ru.bmstu.iu7.rsoi.gulyy.coursework.roles;

import javax.persistence.*;
import java.util.HashMap;
import java.util.Map;

/**
 * @author Konstantin Gulyy
 */

@Entity
@IdClass(RolePK.class)
@NamedQuery(name = Role.FIND_ALL_FOR_PROJECT, query = "SELECT r FROM Role r WHERE r.projectName = ?1")
@Table(name = "ROLES")
public class Role {

    public static final String FIND_ALL_FOR_PROJECT = "Role.findAll";

    @Id
    private int id;

    @Id
    @Column(name = "project_id")
    private String projectName;

    private String name;

    @Column(length = 512)
    private String description;

//    @Transient
    @ElementCollection
    @CollectionTable(name="permissions")
    @MapKeyColumn (name = "name")
    @Column(name = "value")
    private Map<String, Boolean> permissions = new HashMap();

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getProjectName() {
        return projectName;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Map<String, Boolean> getPermissions() {
        return permissions;
    }

    public void setDefaultPermissions() {

        boolean value = false;

        permissions.put("Create Issue", value);
        permissions.put("Delete Issue", value);
        permissions.put("Read Issue", value);
        permissions.put("Update Issue", value);
        permissions.put("Update Watchers", value);
        permissions.put("View Watchers", value);
        permissions.put("Add Attachment", value);
        permissions.put("Delete Attachment", value);
        permissions.put("Update Attachment", value);
        permissions.put("Create Comment", value);
        permissions.put("Delete Own Comment", value);
        permissions.put("Delete Not Own and Permanent Comment Delete", value);
        permissions.put("Read Comment", value);
        permissions.put("Update Own Comment", value);
        permissions.put("Update Not Own Comment", value);
        permissions.put("Delete User", value);
        permissions.put("Read Not Own Profile", value);
        permissions.put("Update Not Own Profile ", value);
        permissions.put("Create Project ", value);
        permissions.put("Delete Project", value);
        permissions.put("Read Project", value);
        permissions.put("Update Project", value);
        permissions.put("Add Role in Project", value);
        permissions.put("Remove Role in Project", value);
        permissions.put("Create Role", value);
        permissions.put("Read User", value);
        permissions.put("Read Self", value);
        permissions.put("Update User", value);
        permissions.put("Update Self", value);
        permissions.put("Create User Group", value);
        permissions.put("Delete User Group", value);
        permissions.put("Read User Group", value);
        permissions.put("Update User Group", value);
    }
}
