package ru.bmstu.iu7.rsoi.gulyy.coursework.issue.priorities;

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
public class IssuePrioritiesResource {

    @PersistenceContext(unitName = "PROJECTS")
    private EntityManager em;
    @Context
    private UriInfo uriInfo;

    @GET
    @Path("{projectName}/issuepriorities/{id}")
    public IssuePriority getIssuePriority(@PathParam("id") int id, @PathParam("projectName") String projectName) {
        IssuePriorityPK pk = new IssuePriorityPK(id, projectName);
        IssuePriority issuePriority = em.find(IssuePriority.class, pk);
        return issuePriority;
    }

    @GET
    @Path("{projectName}/issuepriorities")
    public List<IssuePriority> getAllIssuePrioritiesForProject(@PathParam("projectName") String projectName) {

        Query query = em.createNamedQuery(IssuePriority.FIND_ALL_FOR_PROJECT);

        query.setParameter(1, projectName);

        List<IssuePriority> issuePriorities = query.getResultList();
        return issuePriorities;
    }

    @POST
    @Path("{projectName}/issuepriorities")
    public Response createNewIssuePriority(@PathParam("projectName") String projectName, JAXBElement<IssuePriority> issuePriorityJAXB) {

        Project project = em.find(Project.class, projectName);

        if (project == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        IssuePriority issuePriority = issuePriorityJAXB.getValue();

        issuePriority.setId(project.incAndGetLastPriorityId());
        issuePriority.setProjectName(project.getName());

        em.persist(project);
        em.persist(issuePriority);

        URI issuePriorityUri = uriInfo.getAbsolutePathBuilder().path(String.valueOf(issuePriority.getId())).build();
        return Response.created(issuePriorityUri).build();
    }

    @DELETE
    @Path("{projectName}/issuepriorities/{id}")
    public void deleteIssueType(@PathParam("id") int id, @PathParam("projectName") String projectName) {
        IssuePriorityPK pk = new IssuePriorityPK(id, projectName);
        IssuePriority issuePriority = em.find(IssuePriority.class, pk);
        em.remove(issuePriority);
    }
}
