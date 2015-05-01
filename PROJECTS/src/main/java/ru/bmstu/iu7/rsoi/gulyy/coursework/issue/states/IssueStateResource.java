package ru.bmstu.iu7.rsoi.gulyy.coursework.issue.states;

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
public class IssueStateResource {

    @PersistenceContext(unitName = "PROJECTS")
    private EntityManager em;
    @Context
    private UriInfo uriInfo;

    @GET
    @Path("{projectName}/issuestates/{id}")
    public IssueState getIssueState(@PathParam("id") int id, @PathParam("projectName") String projectName) {
        IssueStatePK pk = new IssueStatePK(id, projectName);
        IssueState issueState = em.find(IssueState.class, pk);
        return issueState;
    }

    @GET
    @Path("{projectName}/issuestates")
    public List<IssueState> getAllIssueStateForProject(@PathParam("projectName") String projectName) {

        Query query = em.createNamedQuery(IssueState.FIND_ALL_FOR_PROJECT);

        query.setParameter(1, projectName);

        List<IssueState> issueStates = query.getResultList();
        return issueStates;
    }

    @POST
    @Path("{projectName}/issuestates")
    public Response createNewIssueType(@PathParam("projectName") String projectName, JAXBElement<IssueState> issueStateJAXB) {

        Project project = em.find(Project.class, projectName);

        if (project == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        IssueState issueState = issueStateJAXB.getValue();

        issueState.setId(project.incAndGetLastStateId());
        issueState.setProjectName(project.getName());

        em.persist(project);
        em.persist(issueState);

        URI issueStateUri = uriInfo.getAbsolutePathBuilder().path(String.valueOf(issueState.getId())).build();
        return Response.created(issueStateUri).build();
    }

    @DELETE
    @Path("{projectName}/issuestates/{id}")
    public void deleteIssueType(@PathParam("id") int id, @PathParam("projectName") String projectName) {
        IssueStatePK pk = new IssueStatePK(id, projectName);
        IssueState issueState = em.find(IssueState.class, pk);
        em.remove(issueState);
    }
}
