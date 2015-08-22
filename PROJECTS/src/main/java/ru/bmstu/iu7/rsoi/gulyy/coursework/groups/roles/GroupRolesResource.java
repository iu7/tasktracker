package ru.bmstu.iu7.rsoi.gulyy.coursework.groups.roles;

import ru.bmstu.iu7.rsoi.gulyy.coursework.groups.Group;
import ru.bmstu.iu7.rsoi.gulyy.coursework.groups.GroupPK;
import ru.bmstu.iu7.rsoi.gulyy.coursework.projects.Project;
import ru.bmstu.iu7.rsoi.gulyy.coursework.roles.Role;
import ru.bmstu.iu7.rsoi.gulyy.coursework.roles.RolePK;

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
public class GroupRolesResource {

    @PersistenceContext(unitName = "PROJECTS")
    private EntityManager em;
    @Context
    private UriInfo uriInfo;

    @POST
    @Path("/{projectName}/groups/{groupId}/roles")
    public Response addRolesToGroup(@PathParam("projectName") String projectName,
                                   @PathParam("groupId") int groupId,
                                   JAXBElement<GroupRoles> groupRolesJAXBElement) {

        Project project = em.find(Project.class, projectName);

        GroupPK groupPK = new GroupPK(groupId, projectName);
        Group group = em.find(Group.class, groupPK);

        if (project == null || group == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        GroupRoles groupRoles = groupRolesJAXBElement.getValue();

        int roleId = groupRoles.getRoleId();
        RolePK rolePK = new RolePK(roleId, projectName);
        Role role = em.find(Role.class, rolePK);

        if (role == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        groupRoles.setProjectId(project.getName());
        groupRoles.setGroupId(group.getId());

        em.persist(groupRoles);

        URI groupUri = uriInfo.getAbsolutePathBuilder().path(String.valueOf(groupRoles.getGroupId())).build();
        return Response.created(groupUri).build();
    }

    @DELETE
    @Path("/{projectName}/groups/{id}/roles/{roleId}")
    public void deleteRolesFromGroup(@PathParam("projectName") String projectName,
                                    @PathParam("id") int groupId,
                                    @PathParam("roleId") int roleId) {

        GroupRolesPK pk = new GroupRolesPK(projectName, groupId, roleId);
        GroupRoles groupRoles = em.find(GroupRoles.class, pk);
        em.remove(groupRoles);
    }

    @GET
    @Path("/{projectName}/groups/{id}/roles")
    public List<GroupRoles> getAllGroupRoles(@PathParam("projectName") String projectName,
                                               @PathParam("id") int groupId) {

        Query query = em.createNamedQuery(GroupRoles.FIND_ALL_GROUP_ROLES);

        query.setParameter(1, projectName);
        query.setParameter(2, groupId);

        List<GroupRoles> groupRolesList = query.getResultList();
        return groupRolesList;
    }
}
