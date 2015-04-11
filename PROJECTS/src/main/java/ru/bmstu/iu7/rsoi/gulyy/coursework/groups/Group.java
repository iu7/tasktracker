package ru.bmstu.iu7.rsoi.gulyy.coursework.groups;

import javax.persistence.*;
import java.io.Serializable;

/**
 * @author Konstantin Gulyy
 */

@Entity
@IdClass(GroupPK.class)
@NamedQuery(name = Group.FIND_ALL_FOR_PROJECT, query = "SELECT g FROM Group g WHERE g.projectName = ?1")
@Table(name = "GROUPS")
public class Group {

    public static final String FIND_ALL_FOR_PROJECT = "Group.findAll";

    @Id
    private int id;

    @Id
    @Column(name = "project_id")
    private String projectName;

    private String name;

    @Column(length = 512)
    private String description;

    public Group() {
    }

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
}

