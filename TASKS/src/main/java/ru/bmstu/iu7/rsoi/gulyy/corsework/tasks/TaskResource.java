package ru.bmstu.iu7.rsoi.gulyy.corsework.tasks;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriInfo;
import javax.xml.bind.JAXBElement;
import java.net.URI;

/**
 * @author Konstantin Gulyy
 */
@Path("tasks")
@Produces({MediaType.APPLICATION_JSON})
@Consumes({MediaType.APPLICATION_JSON})
@Stateless
public class TaskResource {

    @PersistenceContext(unitName = "TASKS")
    private EntityManager em;
    @Context
    private UriInfo uriInfo;

    @POST
    public Response createNewTask(JAXBElement<Task> taskJAXBElement) {
        Task task = taskJAXBElement.getValue();
        em.persist(task);
        URI uri = uriInfo.getAbsolutePathBuilder().path(task.getId().toString()).build();
        return Response.created(uri).build();
    }

    @PUT
    @Path("{id}/updateName")
    public Response updateName(@PathParam("id") int id, JAXBElement<Task> taskJAXBElement) {

        // find task by id
        Task task = em.find(Task.class, id);

        // check exist task
        if (task == null) {
            return Response.noContent().build();
        }

        // get json data (new name)
        Task newTask = taskJAXBElement.getValue();

        // set new name
        task.setName(newTask.getName());

        // merge and return response
        em.merge(task);

        URI uri = uriInfo.getBaseUriBuilder().path("tasks").path(task.getId().toString()).build();
        return Response.ok(uri).build();
    }

    @PUT
    @Path("{id}/updateDescription")
    public Response updateDescription(@PathParam("id") int id, JAXBElement<Task> taskJAXBElement) {

        // find task by id
        Task task = em.find(Task.class, id);

        // check exist task
        if (task == null) {
            return Response.noContent().build();
        }

        // get json data (new description)
        Task newTask = taskJAXBElement.getValue();

        // set new description
        task.setDescription(newTask.getDescription());

        // merge and return response
        em.merge(task);

        URI uri = uriInfo.getBaseUriBuilder().path("tasks").path(task.getId().toString()).build();
        return Response.ok(uri).build();
    }

    @PUT
    @Path("{id}/updatePriority")
    public Response updatePriority(@PathParam("id") int id, JAXBElement<Task> taskJAXBElement) {

        // find task by id
        Task task = em.find(Task.class, id);

        // check exist task
        if (task == null) {
            return Response.noContent().build();
        }

        // get json data (new priority)
        Task newTask = taskJAXBElement.getValue();

        // set new priority
        task.setPriorityId(newTask.getPriorityId());

        // merge and return response
        em.merge(task);

        URI uri = uriInfo.getBaseUriBuilder().path("tasks").path(task.getId().toString()).build();
        return Response.ok(uri).build();
    }

    @PUT
    @Path("{id}/updateType")
    public Response updateType(@PathParam("id") int id, JAXBElement<Task> taskJAXBElement) {

        // find task by id
        Task task = em.find(Task.class, id);

        // check exist task
        if (task == null) {
            return Response.noContent().build();
        }

        // get json data (new type)
        Task newTask = taskJAXBElement.getValue();

        // set new type
        task.setPriorityId(newTask.getPriorityId());

        // merge and return response
        em.merge(task);

        URI uri = uriInfo.getBaseUriBuilder().path("tasks").path(task.getId().toString()).build();
        return Response.ok(uri).build();
    }

    @PUT
    @Path("{id}/updateState")
    public Response updateState(@PathParam("id") int id, JAXBElement<Task> taskJAXBElement) {

        // find task by id
        Task task = em.find(Task.class, id);

        // check exist task
        if (task == null) {
            return Response.noContent().build();
        }

        // get json data (new state)
        Task newTask = taskJAXBElement.getValue();

        // set new state
        task.setStateId(newTask.getStateId());

        // merge and return response
        em.merge(task);

        URI uri = uriInfo.getBaseUriBuilder().path("tasks").path(task.getId().toString()).build();
        return Response.ok(uri).build();
    }

    @PUT
    @Path("{id}/updateAssignee")
    public Response updateAssignee(@PathParam("id") int id, JAXBElement<Task> taskJAXBElement) {

        // find task by id
        Task task = em.find(Task.class, id);

        // check exist task
        if (task == null) {
            return Response.noContent().build();
        }

        // get json data (new assignee)
        Task newTask = taskJAXBElement.getValue();

        // set new assignee
        task.setAssigneeId(newTask.getAssigneeId());

        // merge and return response
        em.merge(task);

        URI uri = uriInfo.getBaseUriBuilder().path("tasks").path(task.getId().toString()).build();
        return Response.ok(uri).build();
    }

    @PUT
    @Path("{id}/updateModificationDate")
    public Response updateModificationDate(@PathParam("id") int id, JAXBElement<Task> taskJAXBElement) {

        // find task by id
        Task task = em.find(Task.class, id);

        // check exist task
        if (task == null) {
            return Response.noContent().build();
        }

        // get json data (new modification date)
        Task newTask = taskJAXBElement.getValue();

        // set new modification date
        task.setModificationDate(newTask.getModificationDate());

        // merge and return response
        em.merge(task);

        URI uri = uriInfo.getBaseUriBuilder().path("tasks").path(task.getId().toString()).build();
        return Response.ok(uri).build();
    }
}
