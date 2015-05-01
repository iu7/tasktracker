package ru.bmstu.iu7.rsoi.gulyy.coursework.roles;

import java.io.Serializable;

public class RolePK implements Serializable {
    private int id;
    private String projectName;

    public RolePK(int id, String projectName) {
        this.id = id;
        this.projectName = projectName;
    }
}