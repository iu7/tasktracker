package ru.bmstu.iu7.rsoi.gulyy.coursework.groups;

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
import java.net.URI;
import java.util.List;

/**
 * @author Konstantin Gulyy
 */

@Path("projects")
@Produces({MediaType.APPLICATION_JSON})
@Consumes({MediaType.APPLICATION_JSON})
@Stateless
public class GroupResource {

    @PersistenceContext(unitName = "PROJECTS")
    private EntityManager em;
    @Context
    private UriInfo uriInfo;

    @GET
    @Path("{projectName}/groups/{id}")
    public Group getGroup(@PathParam("id") int id, @PathParam("projectName") String projectName) {
        GroupPK pk = new GroupPK(id, projectName);
        Group group = em.find(Group.class, pk);
        return group;
    }

    @GET
    @Path("{projectName}/groups")
    public List<Group> getAllGroupForProject(@PathParam("projectName") String projectName) {

        Query query = em.createNamedQuery(Group.FIND_ALL_FOR_PROJECT);

        query.setParameter(1, projectName);

        List<Group> groups = query.getResultList();
        return groups;
    }

    @POST
    @Path("{projectName}/groups")
    public Response createNewGroup(@PathParam("projectName") String projectName, JAXBElement<Group> groupJaxb) {

        Project project = em.find(Project.class, projectName);

        if (project == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        Group group = groupJaxb.getValue();

        group.setId(project.incAndGetLastGroupId());
        group.setProjectName(project.getName());

        em.persist(project);
        em.persist(group);

        URI groupUri = uriInfo.getAbsolutePathBuilder().path(String.valueOf(group.getId())).build();
        return Response.created(groupUri).build();
    }

    @DELETE
    @Path("{projectName}/groups/{id}")
    public void deleteGroup(@PathParam("id") int id, @PathParam("projectName") String projectName) {
        GroupPK pk = new GroupPK(id, projectName);
        Group group = em.find(Group.class, pk);
        em.remove(group);
    }

    @PUT
    @Path("{projectName}/groups/{id}/updateName")
    public Response updateName(@PathParam("projectName") String projectName, @PathParam("id") int id,
                                    JAXBElement<Group> groupJaxb) {

        GroupPK pk = new GroupPK(id, projectName);

        // find project by name
        Group group = em.find(Group.class, pk);

        // check exist project
        if (group == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        // get json data (new group name)
        Group newGroup = groupJaxb.getValue();

        // set new group name
        group.setName(newGroup.getName());

        // merge and return response
        em.merge(group);

        URI userUri = uriInfo.getBaseUriBuilder().path("projects").path(projectName)
                .path("groups").path(String.valueOf(group.getId())).build();
        return Response.ok(userUri).build();
    }

    @PUT
    @Path("{projectName}/groups/{id}/updateDescription")
    public Response updateDescription(@PathParam("projectName") String projectName, @PathParam("id") int id,
                                      JAXBElement<Group> groupJaxb) {

        GroupPK pk = new GroupPK(id, projectName);

        // find project by name
        Group group = em.find(Group.class, pk);

        // check exist project
        if (group == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        // get json data (new description)
        Group newGroup = groupJaxb.getValue();

        // set new description
        group.setDescription(newGroup.getDescription());

        // merge and return response
        em.merge(group);

        URI userUri = uriInfo.getBaseUriBuilder().path("projects").path(projectName)
                .path("groups").path(String.valueOf(group.getId())).build();
        return Response.ok(userUri).build();
    }
}
