package ru.bmstu.iu7.rsoi.gulyy.coursework.roles;

import javax.persistence.Entity;
import javax.persistence.Id;

/**
 * Created by Константин on 03.05.2015.
 */
public class Permission {

    private String name;
    private Boolean value;

    public Permission() {
    }

    public Permission(String name, Boolean value) {
        this.name = name;
        this.value = value;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Boolean getValue() {
        return value;
    }

    public void setValue(Boolean value) {
        this.value = value;
    }
}
