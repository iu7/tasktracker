package ru.bmstu.iu7.rsoi.gulyy.coursework.projects;

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
import java.util.Arrays;
import java.util.List;

/**
 * @author Konstantin Gulyy
 */

@Path("projects")
@Produces({MediaType.APPLICATION_JSON})
@Consumes({MediaType.APPLICATION_JSON})
@Stateless
public class ProjectResource {

    @PersistenceContext(unitName = "PROJECTS")
    private EntityManager em;
    @Context
    private UriInfo uriInfo;

    @GET
    @Path("{projectName}")
    public Project getProjectByLogin(@PathParam("projectName") String projectName) {
        Project project = em.find(Project.class, projectName);
        return project;
    }

    @GET
    public List<Project> getProjects(@QueryParam("names") @DefaultValue("") String names) {

        names = (names.equals(",")) ? "" : names;

        List<String> inclList = Arrays.asList(names.split("\\s*,\\s*"));

        Query query = em.createNamedQuery(Project.FIND_ALL);

        query.setParameter("inclList", inclList);

        List<Project> projects = query.getResultList();
        return projects;
    }

    @GET
    @Path("{projectName}/exist")
    public Response isExist(@PathParam("projectName") String projectName) {

        if (em.find(Project.class, projectName) != null) {
            return Response.status(Response.Status.OK).build();
        } else {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
    }

    @POST
    public Response createNewProject(JAXBElement<Project> projectJaxb) {
        Project project = projectJaxb.getValue();
        em.persist(project);
        URI projectUri = uriInfo.getAbsolutePathBuilder().path(project.getName()).build();
        return Response.created(projectUri).build();
    }

    @PUT
    @Path("{projectName}/updateManager")
    public Response updateManagerId(@PathParam("projectName") String projectName, JAXBElement<Project> projectJaxb) {

        // find project by projectName
        Project project = em.find(Project.class, projectName);

        // check exist project
        if (project == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        // get json data (new manager id)
        Project newProject = projectJaxb.getValue();

        // set new manager id
        project.setManagerId(newProject.getManagerId());

        // merge and return response
        em.merge(project);

        URI userUri = uriInfo.getBaseUriBuilder().path("projects").path(project.getName()).build();
        return Response.ok(userUri).build();
    }

    @PUT
    @Path("{projectName}/updateDescription")
    public Response updateDescription(@PathParam("projectName") String projectName, JAXBElement<Project> projectJaxb) {

        // find project by projectName
        Project project = em.find(Project.class, projectName);

        // check exist project
        if (project == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        // get json data (new description)
        Project newProject = projectJaxb.getValue();

        // set new description
        project.setDescription(newProject.getDescription());

        // merge and return response
        em.merge(project);

        URI userUri = uriInfo.getBaseUriBuilder().path("projects").path(project.getName()).build();
        return Response.ok(userUri).build();
    }

    @POST
    @Path("{projectName}/incAndGetLastTaskId")
    public Response incAndGetLastTaskId(@PathParam("projectName") String projectName) {
        // find project by projectName
        Project project = em.find(Project.class, projectName);

        // check exist project
        if (project == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        return Response.ok("{\"LastTaskId\" : "+ project.incAndGetLastTaskId() +"}").build();
    }
}
