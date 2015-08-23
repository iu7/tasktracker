package ru.bmstu.iu7.rsoi.gulyy.coursework.groups.users;

import ru.bmstu.iu7.rsoi.gulyy.coursework.groups.roles.GroupRoles;
import ru.bmstu.iu7.rsoi.gulyy.coursework.roles.Permission;
import ru.bmstu.iu7.rsoi.gulyy.coursework.roles.Role;
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
import java.util.ArrayList;
import java.util.HashSet;
import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.Map;
import java.net.URI;

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

    @GET
    @Path("/{projectName}/{userId}/permissions")
    public List<Permission> getAllGroupsUsers(@PathParam("projectName") String projectName,
                                              @PathParam("userId") String userId) {
        Query query = em.createNamedQuery(GroupsUsers.FIND_ALL_USER_GROUPS);

        query.setParameter(1, projectName);
        query.setParameter(2, userId);

        List<GroupsUsers> groupsUsersList = query.getResultList();
        List<Integer> groups = new ArrayList<Integer>();
        for (GroupsUsers gu : groupsUsersList) {
            groups.add(gu.getGroupId());
        }

        // To remove dups
        Set<Integer> groups_set = new HashSet<Integer>(groups);
        List<Integer> groups_without_dups = new ArrayList<Integer>(groups_set);
        if (groups_without_dups.isEmpty()) {
                return new ArrayList<Permission>();
        }

        List<Integer> roles_list =
                em.createQuery("SELECT g.roleId FROM GroupRoles g where g.projectId=?1 AND g.roleId IN ?2")
                .setParameter(1, projectName)
                .setParameter(2, groups_without_dups)
                .getResultList();
        if (roles_list.isEmpty()) {
                return new ArrayList<Permission>();
        }

        List<Role> roles =
                em.createQuery("SELECT r FROM Role r WHERE r.projectName = :projectId and r.id IN :inclList")
                .setParameter("projectId", projectName)
                .setParameter("inclList", roles_list)
                .getResultList();

        Map<String, Boolean> perms_map = new HashMap<String, Boolean>();
        for (Role role : roles) {
            for (Map.Entry<String, Boolean> entry : role.getPermissions().entrySet()) {
                Boolean value = perms_map.get(entry.getKey());
                if (value == null)
                        value = false;

                perms_map.put(entry.getKey(), entry.getValue() || value);
            }
        }

        List<Permission> result = new ArrayList<Permission>();
        for (Map.Entry<String, Boolean> entry : perms_map.entrySet()) {
            Permission perm = new Permission(entry.getKey(), entry.getValue());
            result.add(perm);
        }

        return result;
    }
}
