package ru.bmstu.iu7.rsoi.gulyy.corsework.tasks;

import javax.persistence.*;
import java.util.Date;

/**
 * @author Konstantin Gulyy
 */

@Entity
@Table(name = "TASKS")
public class Task {

    @Id
    private Long id;

    private String name;

    private String description;

    @Column(name = "project_id")
    private String projectId;

    @Column(name = "priority_id")
    private int priorityId;

    @Column(name = "type_id")
    private int typeId;

    @Column(name = "state_id")
    private int stateId;

    @Column(name = "assignee_id")
    private String assigneeId;

    @Column(name = "creator_id")
    private String creatorId;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "creation_date")
    private Date creationDate;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "modification_date")
    private Date modificationDate;

    @Column(name = "last_comment_id")
    private int lastCommentId;

    @Column(name = "last_task_id")
    private int lastTaskId;

    @Column(name = "elapsed_time")
    @Transient
    private int elapsedTime;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public String getProjectId() {
        return projectId;
    }

    public void setProjectId(String projectId) {
        this.projectId = projectId;
    }

    public int getPriorityId() {
        return priorityId;
    }

    public void setPriorityId(int priorityId) {
        this.priorityId = priorityId;
    }

    public int getTypeId() {
        return typeId;
    }

    public void setTypeId(int typeId) {
        this.typeId = typeId;
    }

    public int getStateId() {
        return stateId;
    }

    public void setStateId(int stateId) {
        this.stateId = stateId;
    }

    public String getAssigneeId() {
        return assigneeId;
    }

    public void setAssigneeId(String assigneeId) {
        this.assigneeId = assigneeId;
    }

    public String getCreatorId() {
        return creatorId;
    }

    public void setCreatorId(String creatorId) {
        this.creatorId = creatorId;
    }

    public Date getCreationDate() {
        return creationDate;
    }

    public void setCreationDate(Date creationDate) {
        this.creationDate = creationDate;
    }

    public Date getModificationDate() {
        return modificationDate;
    }

    public void setModificationDate(Date modificationDate) {
        this.modificationDate = modificationDate;
    }

    public int getLastCommentId() {
        return lastCommentId;
    }

    public void setLastCommentId(int lastCommentId) {
        this.lastCommentId = lastCommentId;
    }

    public int getLastTaskId() {
        return lastTaskId;
    }

    public void setLastTaskId(int lastTaskId) {
        this.lastTaskId = lastTaskId;
    }

    public int getElapsedTime() {
        return elapsedTime;
    }

    public void setElapsedTime(int elapsedTime) {
        this.elapsedTime = elapsedTime;
    }
}