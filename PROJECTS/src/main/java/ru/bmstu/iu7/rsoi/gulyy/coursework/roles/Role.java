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
    }
}