package ru.bmstu.iu7.rsoi.gulyy.coursework.users;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriInfo;
import javax.xml.bind.JAXBElement;
import java.net.URI;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author Konstantin Gulyy
 */
@Path("users")
@Produces({MediaType.APPLICATION_JSON})
@Consumes({MediaType.APPLICATION_JSON})
@Stateless
public class UserResource {

    @PersistenceContext(unitName = "USERS")
    private EntityManager em;
    @Context
    private UriInfo uriInfo;

    @GET
    public List<User> getUsers(@QueryParam("logins") @DefaultValue("") String logins) {

        logins = (logins.equals(",")) ? "" : logins;

        List<String> inclList = Arrays.asList(logins.split("\\s*,\\s*"));

        Query query = em.createNamedQuery(User.FIND_ALL);

        query.setParameter("inclList", inclList);

        List<User> users = query.getResultList();
        return users;
    }

    @GET
    @Path("{login}")
    public User getUserByLogin(@PathParam("login") String login) {
        User user = em.find(User.class, login);
        return user;
    }

    @POST
    public Response createNewUser(JAXBElement<User> userJaxb) {
        User user = userJaxb.getValue();
        em.persist(user);
        URI userUri = uriInfo.getAbsolutePathBuilder().path(user.getLogin()).build();
        return Response.created(userUri).build();
    }

    @POST
    @Path("{login}/resetPassword")
    public Response resetPassword(@PathParam("login") String login, JAXBElement<User> userJaxb) {

        // find user by login
        User user = em.find(User.class, login);

        // check exist user
        if (user == null) {
            return Response.noContent().build();
        }

        // get json data (old and new password)
        User newUser = userJaxb.getValue();
        // check old password
        if (newUser.getOldPassword().equals(user.getPassword())) {
            // set new password
            user.setPassword(newUser.getPassword());
        } else {
            return Response.status(Response.Status.BAD_REQUEST).build();
        }

        // merge and return response
        em.merge(user);
        URI userUri = uriInfo.getBaseUriBuilder().path("users").path(user.getLogin()).build();
        return Response.ok(userUri).build();
    }

    @PUT
    @Path("{login}/updateName")
    public Response updateName(@PathParam("login") String login, JAXBElement<User> userJaxb) {

        // find user by login
        User user = em.find(User.class, login);

        // check exist user
        if (user == null) {
            return Response.noContent().build();
        }

        // get json data (new user name)
        User newUser = userJaxb.getValue();

        // set new name
        user.setName(newUser.getName());

        // merge and return response
        em.merge(user);

        URI userUri = uriInfo.getBaseUriBuilder().path("users").path(user.getLogin()).build();
        return Response.ok(userUri).build();
    }


    @PUT
    @Path("{login}/updateEmail")
    public Response updateEmail(@PathParam("login") String login, JAXBElement<User> userJaxb) {

        // find user by login
        User user = em.find(User.class, login);

        // check exist user
        if (user == null) {
            return Response.noContent().build();
        }

        // get json data (new email)
        User newUser = userJaxb.getValue();

        // set new email
        user.setEmail(newUser.getEmail());

        // merge and return response
        em.merge(user);

        URI userUri = uriInfo.getBaseUriBuilder().path("users").path(user.getLogin()).build();
        return Response.ok(userUri).build();
    }
}
