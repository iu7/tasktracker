package ru.bmstu.iu7.rsoi.gulyy.coursework.issue.states;

import javax.persistence.*;
import java.io.Serializable;

/**
 * @author Konstantin Gulyy
 */

@Entity
@IdClass(IssueStatePK.class)
@NamedQuery(name = IssueState.FIND_ALL_FOR_PROJECT, query = "SELECT ist FROM IssueState ist WHERE ist.projectName = ?1")
@Table(name = "PROJECT_ISSUE_STATES")
public class IssueState {

    public static final String FIND_ALL_FOR_PROJECT = "IssueState.findAll";

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

class IssueStatePK implements Serializable {
    private int id;
    private String projectName;

    public IssueStatePK(int id, String projectName) {
        this.id = id;
        this.projectName = projectName;
    }
}
