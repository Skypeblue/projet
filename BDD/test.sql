--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.10
-- Dumped by pg_dump version 9.5.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

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
-- Name: film; Type: TABLE; Schema: public; Owner: fredo
--

CREATE TABLE film (
    id integer NOT NULL,
    titre character varying(50) NOT NULL,
    annee integer NOT NULL,
    CONSTRAINT film_annee_check CHECK (((annee >= 1950) AND (annee <= 2018)))
);


ALTER TABLE film OWNER TO fredo;

--
-- Name: film_id_seq; Type: SEQUENCE; Schema: public; Owner: fredo
--

CREATE SEQUENCE film_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE film_id_seq OWNER TO fredo;

--
-- Name: film_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fredo
--

ALTER SEQUENCE film_id_seq OWNED BY film.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY film ALTER COLUMN id SET DEFAULT nextval('film_id_seq'::regclass);


--
-- Data for Name: film; Type: TABLE DATA; Schema: public; Owner: fredo
--

COPY film (id, titre, annee) FROM stdin;
1	La La Land	2016
2	Moonlight	2016
3	Interstellar	2014
\.


--
-- Name: film_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fredo
--

SELECT pg_catalog.setval('film_id_seq', 4, true);


--
-- Name: film_pkey; Type: CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY film
    ADD CONSTRAINT film_pkey PRIMARY KEY (id);


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

