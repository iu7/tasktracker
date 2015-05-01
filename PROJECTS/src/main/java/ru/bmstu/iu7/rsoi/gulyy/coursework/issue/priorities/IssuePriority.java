package ru.bmstu.iu7.rsoi.gulyy.coursework.issue.priorities;

import javax.persistence.*;
import java.io.Serializable;

/**
 * @author Konstantin Gulyy
 */

@Entity
@IdClass(IssuePriorityPK.class)
@NamedQuery(name = IssuePriority.FIND_ALL_FOR_PROJECT, query = "SELECT ip FROM IssuePriority ip WHERE ip.projectName = ?1")
@Table(name = "PROJECT_ISSUE_PRIORITIES")
public class IssuePriority {

    public static final String FIND_ALL_FOR_PROJECT = "IssuePriorities.findAll";

    @Id
    private int id;

    @Id
    @Column(name = "project_id")
    private String projectName;

    private String name;

    @Column(length = 512)
    private String description;

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

class IssuePriorityPK implements Serializable {
    private int id;
    private String projectName;

    public IssuePriorityPK(int id, String projectName) {
        this.id = id;
        this.projectName = projectName;
    }
}
