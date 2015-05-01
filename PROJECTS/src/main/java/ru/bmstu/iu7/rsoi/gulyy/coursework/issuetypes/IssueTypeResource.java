package ru.bmstu.iu7.rsoi.gulyy.coursework.issuetypes;

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
public class IssueTypeResource {

    @PersistenceContext(unitName = "PROJECTS")
    private EntityManager em;
    @Context
    private UriInfo uriInfo;

    @GET
    @Path("{projectName}/issuetype/{id}")
    public IssueType getIssueType(@PathParam("id") int id, @PathParam("projectName") String projectName) {
        IssueTypePK pk = new IssueTypePK(id, projectName);
        IssueType issueType = em.find(IssueType.class, pk);
        return issueType;
    }

    @GET
    @Path("{projectName}/issuetype")
    public List<IssueType> getAllIssueTypesForProject(@PathParam("projectName") String projectName) {

        Query query = em.createNamedQuery(IssueType.FIND_ALL_FOR_PROJECT);

        query.setParameter(1, projectName);

        List<IssueType> issueTypes = query.getResultList();
        return issueTypes;
    }

    @POST
    @Path("{projectName}/issuetype")
    public Response createNewIssueType(@PathParam("projectName") String projectName, JAXBElement<IssueType> issueTypeJAXB) {

        Project project = em.find(Project.class, projectName);

        if (project == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        IssueType issueType = issueTypeJAXB.getValue();

        issueType.setId(project.incAndGetLastIssueTypeId());
        issueType.setProjectName(project.getName());

        em.persist(project);
        em.persist(issueType);

        URI issueTypeUri = uriInfo.getAbsolutePathBuilder().path(String.valueOf(issueType.getId())).build();
        return Response.created(issueTypeUri).build();
    }

    @DELETE
    @Path("{projectName}/issuetype/{id}")
    public void deleteIssueType(@PathParam("id") int id, @PathParam("projectName") String projectName) {
        IssueTypePK pk = new IssueTypePK(id, projectName);
        IssueType issueType = em.find(IssueType.class, pk);
        em.remove(issueType);
    }
}
