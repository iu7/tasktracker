package ru.bmstu.iu7.rsoi.gulyy.coursework.issuetypes;

import javax.persistence.*;
import java.io.Serializable;

/**
 * @author Konstantin Gulyy
 */

@Entity
@IdClass(IssueTypePK.class)
@NamedQuery(name = IssueType.FIND_ALL_FOR_PROJECT, query = "SELECT it FROM IssueType it WHERE it.projectName = ?1")
@Table(name = "PROJECT_ISSUE_TYPES")
public class IssueType {

    public static final String FIND_ALL_FOR_PROJECT = "IssueType.findAll";

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

class IssueTypePK implements Serializable {
    private int id;
    private String projectName;

    public IssueTypePK(int id, String projectName) {
        this.id = id;
        this.projectName = projectName;
    }
}


