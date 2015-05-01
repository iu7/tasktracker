package ru.bmstu.iu7.rsoi.gulyy.coursework.projects;

import javax.persistence.*;

/**
 * @author Konstantin Gulyy
 */

@Entity
@NamedQuery(name = Project.FIND_ALL, query = "SELECT p FROM Project p WHERE p.name IN :inclList")
@Table(name = "PROJECTS")
public class Project {

    public static final String FIND_ALL = "Project.findAll";

    @Id
    private String name;

    @Column(length = 4096)
    private String description;

    @Column(name = "manager_id")
    private String managerId;

    @Column(name = "task_prefix")
    private String taskPrefix;

    @Column(name = "last_task_id")
    private Long lastTaskId;

    @Column(name = "last_group_id")
    private int lastGroupId;

    @Column(name = "last_role_id")
    private int lastRoleId;

    @Column(name = "last_state_id")
    private int lastStateId;

    @Column(name = "last_priority_id")
    private int lastPriorityId;

    @Column(name = "last_issue_type_id")
    private int lastIssueTypeId;

    public Project() {
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

    public String getManagerId() {
        return managerId;
    }

    public void setManagerId(String managerId) {
        this.managerId = managerId;
    }

    public String getTaskPrefix() {
        return taskPrefix;
    }

    public void setTaskPrefix(String taskPrefix) {
        this.taskPrefix = taskPrefix;
    }

    public Long getLastTaskId() {
        return lastTaskId;
    }

    public void setLastTaskId(Long lastTaskId) {
        this.lastTaskId = lastTaskId;
    }

    public int getLastGroupId() {
        return lastGroupId;
    }

    public void setLastGroupId(int lastGroupId) {
        this.lastGroupId = lastGroupId;
    }

    public int getLastRoleId() {
        return lastRoleId;
    }

    public void setLastRoleId(int lastRoleId) {
        this.lastRoleId = lastRoleId;
    }

    public int getLastStateId() {
        return lastStateId;
    }

    public void setLastStateId(int lastStateId) {
        this.lastStateId = lastStateId;
    }

    public int getLastPriorityId() {
        return lastPriorityId;
    }

    public void setLastPriorityId(int lastPriorityId) {
        this.lastPriorityId = lastPriorityId;
    }

    public int getLastIssueTypeId() {
        return lastIssueTypeId;
    }

    public void setLastIssueTypeId(int lastIssueTypeId) {
        this.lastIssueTypeId = lastIssueTypeId;
    }

    public synchronized Long incAndGetLastTaskId() {
        return ++lastTaskId;
    }

    public synchronized int incAndGetLastGroupId() {
        return ++lastGroupId;
    }

    public synchronized int incAndGetLastRoleId() {
        return ++lastRoleId;
    }

    public synchronized int incAndGetLastStateId() { return ++lastStateId; }

    public synchronized int incAndGetLastPriorityId() { return ++lastPriorityId; }

    public synchronized int incAndGetLastIssueTypeId() { return ++lastIssueTypeId; }
}
