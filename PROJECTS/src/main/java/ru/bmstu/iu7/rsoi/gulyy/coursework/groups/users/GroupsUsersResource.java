package ru.bmstu.iu7.rsoi.gulyy.coursework.groups.users;

import ru.bmstu.iu7.rsoi.gulyy.coursework.groups.Group;
import ru.bmstu.iu7.rsoi.gulyy.coursework.groups.GroupPK;
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
public class GroupsUsersResource {

    @PersistenceContext(unitName = "PROJECTS")
    private EntityManager em;
    @Context
    private UriInfo uriInfo;

    @POST
    @Path("/{projectName}/groups/{id}/users")
    public Response addUserToGroup(@PathParam("projectName") String projectName,
                                   @PathParam("id") int groupId,
                                   JAXBElement<GroupsUsers> groupsUsersJAXBElement) {

        Project project = em.find(Project.class, projectName);

        GroupPK pk = new GroupPK(groupId, projectName);
        Group group = em.find(Group.class, pk);

        if (project == null || group == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        GroupsUsers groupsUsers = groupsUsersJAXBElement.getValue();

        groupsUsers.setProjectId(project.getName());
        groupsUsers.setGroupId(group.getId());

        em.persist(groupsUsers);

        URI groupUri = uriInfo.getAbsolutePathBuilder().path(groupsUsers.getUserId()).build();
        return Response.created(groupUri).build();
    }

    @DELETE
    @Path("/{projectName}/groups/{id}/users/{userId}")
    public void deleteUserFromGroup(@PathParam("projectName") String projectName,
                                        @PathParam("id") int groupId,
                                        @PathParam("userId") String userId) {

        GroupsUsersPK pk = new GroupsUsersPK(projectName, groupId, userId);
        GroupsUsers groupsUsers = em.find(GroupsUsers.class, pk);
        em.remove(groupsUsers);
    }

    @GET
    @Path("/list_for_user/{userName}")
    public List<GroupsUsers> getAllUserProjects(@PathParam("userName") String userName) {
        Query query = em.createNamedQuery(GroupsUsers.FIND_ALL_USER_PROJECTS);
        query.setParameter(1, userName);

        return query.getResultList();
    }

    @GET
    @Path("/{projectName}/groups/{id}/users")
    public List<GroupsUsers> getAllGroupsUsers(@PathParam("projectName") String projectName,
                                               @PathParam("id") int groupId) {

        Query query = em.createNamedQuery(GroupsUsers.FIND_ALL_GROUPS_USERS);

        query.setParameter(1, projectName);
        query.setParameter(2, groupId);

        List<GroupsUsers> groupsUsersList = query.getResultList();
        return groupsUsersList;
    }
}
