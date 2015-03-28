package ru.bmstu.iu7.rsoi.gulyy.coursework.users;

import javax.persistence.*;

/**
 * @author Konstantin Gulyy
 */

@Entity
@NamedQuery(name = User.FIND_ALL, query = "SELECT u FROM User u WHERE u.login IN :inclList")
@Table(name = "USERS")
public class User {

    public static final String FIND_ALL = "User.findAll";

    @Id
    private String login;

    @Column(nullable = false)
    private String name;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(name = "PASSWORDHASH", nullable = false)
    private String password;

    @Transient
    private String oldPassword;

    public User() {
    }

    public User(String login, String name, String email, String password) {
        this.login = login;
        this.name = name;
        this.email = email;
        this.password = password;
    }

    public String getLogin() {
        return login;
    }

    public void setLogin(String login) {
        this.login = login;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getOldPassword() {
        return oldPassword;
    }

    public void setOldPassword(String oldPassword) {
        this.oldPassword = oldPassword;
    }
}
