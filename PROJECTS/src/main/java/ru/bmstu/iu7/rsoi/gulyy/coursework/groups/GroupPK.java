package ru.bmstu.iu7.rsoi.gulyy.coursework.groups;

import java.io.Serializable;

public class GroupPK implements Serializable {
    private int id;
    private String projectName;

    public GroupPK(int id, String projectName) {
        this.id = id;
        this.projectName = projectName;
    }
}
