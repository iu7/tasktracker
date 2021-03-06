package ru.bmstu.iu7.rsoi.gulyy.coursework.roles;

import ru.bmstu.iu7.rsoi.gulyy.coursework.projects.Project;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriInfo;
import javax.xml.bind.JAXBElement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.net.URI;

/**
 * @author Konstantin Gulyy
 */

@Path("projects")
@Produces({MediaType.APPLICATION_JSON})
@Consumes({MediaType.APPLICATION_JSON})
@Stateless
public class RoleResource {

    @PersistenceContext(unitName = "PROJECTS")
    private EntityManager em;
    @Context
    private UriInfo uriInfo;

    @GET
    @Path("{projectName}/roles/{id}")
    public Role getRole(@PathParam("id") int id, @PathParam("projectName") String projectName) {
        RolePK pk = new RolePK(id, projectName);
        Role role = em.find(Role.class, pk);
        return role;
    }

    @GET
    @Path("{projectName}/roles")
    public List<Role> getAllRolesForProject(@PathParam("projectName") String projectName) {

        Query query = em.createNamedQuery(Role.FIND_ALL_FOR_PROJECT);

        query.setParameter(1, projectName);

        List<Role> roles = query.getResultList();
        return roles;
    }

    @POST
    @Path("{projectName}/roles")
    public Response createNewRole(@PathParam("projectName") String projectName, JAXBElement<Role> roleJaxb) {

        Project project = em.find(Project.class, projectName);

        if (project == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        Role role = roleJaxb.getValue();

        role.setId(project.incAndGetLastRoleId());
        role.setProjectName(project.getName());

        role.setDefaultPermissions();

        em.persist(project);
        em.persist(role);

        URI roleUri = uriInfo.getAbsolutePathBuilder().path(String.valueOf(role.getId())).build();
        return Response.created(roleUri).build();
    }

    @DELETE
    @Path("{projectName}/roles/{id}")
    public void deleteRole(@PathParam("id") int id, @PathParam("projectName") String projectName) {
        RolePK pk = new RolePK(id, projectName);
        Role role = em.find(Role.class, pk);
        em.remove(role);
    }

    @PUT
    @Path("{projectName}/roles/{id}/updateName")
    public Response updateName(@PathParam("projectName") String projectName, @PathParam("id") int id,
                               JAXBElement<Role> roleJaxb) {

        RolePK pk = new RolePK(id, projectName);

        // find project by name
        Role role = em.find(Role.class, pk);

        // check exist project
        if (role == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        // get json data (new roles name)
        Role newRole = roleJaxb.getValue();

        // set new roles name
        role.setName(newRole.getName());

        // merge and return response
        em.merge(role);

        URI userUri = uriInfo.getBaseUriBuilder().path("projects").path(projectName)
                .path("roles").path(String.valueOf(role.getId())).build();
        return Response.ok(userUri).build();
    }

    @PUT
    @Path("{projectName}/roles/{id}/updateDescription")
    public Response updateDescription(@PathParam("projectName") String projectName, @PathParam("id") int id,
                                      JAXBElement<Role> roleJaxb) {

        RolePK pk = new RolePK(id, projectName);

        // find project by name
        Role role = em.find(Role.class, pk);

        // check exist project
        if (role == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        // get json data (new description)
        Role newRole = roleJaxb.getValue();

        // set new description
        role.setDescription(newRole.getDescription());

        // merge and return response
        em.merge(role);

        URI userUri = uriInfo.getBaseUriBuilder().path("projects").path(projectName)
                .path("roles").path(String.valueOf(role.getId())).build();
        return Response.ok(userUri).build();
    }

    @PUT
    @Path("{projectName}/roles/{id}/permissions")
    public Response setRolePermission(@PathParam("projectName") String projectName, @PathParam("id") int id,
                                      JAXBElement<Permission> permissionJaxb) {

        RolePK pk = new RolePK(id, projectName);

        // find role by id and project name
        Role role = em.find(Role.class, pk);

        // check exist role
        if (role == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        // get json data (permission name and value)
        Permission permission = permissionJaxb.getValue();

        if (permission.getValue() == null || !role.getPermissions().containsKey(permission.getName())) {
            return Response.status(Response.Status.BAD_REQUEST).build();
        }

        // set new permission (value) by name (key)
        role.getPermissions().put(permission.getName(), permission.getValue());

        // merge and return response
        em.merge(role);

        URI permissionUri = uriInfo.getBaseUriBuilder().path("projects").path(projectName).path("roles")
                .path(String.valueOf(role.getId())).path("permissions").path(permission.getName()).build();
        return Response.ok(permissionUri).build();
    }

    @GET
    @Path("{projectName}/roles/{id}/permissions")
    public List<Permission> getPermissions(@PathParam("projectName") String projectName, @PathParam("id") int id) {
        RolePK pk = new RolePK(id, projectName);
        Role role = em.find(Role.class, pk);
        if (role == null) {
            return null;
        }

        List<Permission> result = new ArrayList<Permission>();
        for (Map.Entry<String, Boolean> entry : role.getPermissions().entrySet()) {
            Permission perm = new Permission(entry.getKey(), entry.getValue());
            result.add(perm);
        }

        return result;
    }
}
