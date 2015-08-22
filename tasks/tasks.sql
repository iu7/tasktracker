--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    user_id text NOT NULL,
    task_id bigint NOT NULL,
    project_id text NOT NULL,
    comment text NOT NULL,
    date timestamp without time zone NOT NULL
);


ALTER TABLE comments OWNER TO postgres;

--
-- Name: files; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE files (
    id integer NOT NULL,
    user_id text NOT NULL,
    task_id bigint NOT NULL,
    project_id text NOT NULL,
    path text NOT NULL
);


ALTER TABLE files OWNER TO postgres;

--
-- Name: tasks; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tasks (
    id bigint NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    project_id text NOT NULL,
    priority_id integer NOT NULL,
    type_id integer NOT NULL,
    state_id integer NOT NULL,
    assignee_id text NOT NULL,
    creator_id text NOT NULL,
    creation_date timestamp without time zone,
    modification_date timestamp without time zone,
    last_comment_id integer DEFAULT 0,
    last_file_id integer DEFAULT 0
);


ALTER TABLE tasks OWNER TO postgres;

--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id, task_id, project_id);


--
-- Name: files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY files
    ADD CONSTRAINT files_pkey PRIMARY KEY (id, task_id, project_id);


--
-- Name: tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id, project_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

