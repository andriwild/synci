--
-- PostgreSQL database dump
--

-- Dumped from database version 15.2
-- Dumped by pg_dump version 16.3 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
-- SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;

-- Grant necessary permissions to the user

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: source; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS public.SOURCES_TABLE
(
    id serial PRIMARY KEY,
    name varchar(100)
);

--
-- Name: event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.EVENTS_TABLE
(
    id varchar(255) NOT NULL,
    source_id integer NOT NULL,
    name character varying(100),
    starts_on timestamp without time zone,
    ends_on timestamp without time zone,
    sport_id uuid,
    location_id uuid,
    CONSTRAINT pk_event PRIMARY KEY (id, source_id),
    CONSTRAINT fk_event_source FOREIGN KEY (source_id)
        REFERENCES public.SOURCES_TABLE (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

);


ALTER TABLE public.EVENTS_TABLE OWNER TO postgres;

--
-- Name: event_person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.EVENTS_PERSONS_TABLE
(
    event_id varchar(255) NOT NULL,
    source_event_id int NOT NULL,
    person_id varchar(255) NOT NULL,
    source_person_id int NOT NULL
);


ALTER TABLE public.EVENTS_PERSONS_TABLE OWNER TO postgres;

--
-- Name: event_team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.EVENTS_TEAMS_TABLE (
    id uuid NOT NULL,
    event_id varchar(255) NOT NULL,
    source_event_id integer NOT NULL,
    team_id varchar(255) NOT NULL,
    source_team_id integer NOT NULL
);


ALTER TABLE public.EVENTS_TABLE OWNER TO postgres;

--
-- Name: location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.LOCATIONS_TABLE(
    id uuid NOT NULL,
    name character varying(100)
);


ALTER TABLE public.LOCATIONS_TABLE OWNER TO postgres;

--
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.PERSONS_TABLE(
    id varchar(255) NOT NULL,
    source_id integer NOT NULL,
    name character varying(100),
    CONSTRAINT pk_person PRIMARY KEY (id, source_id),
    CONSTRAINT fk_person_source FOREIGN KEY (source_id)
        REFERENCES public.SOURCES_TABLE (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


ALTER TABLE public.PERSONS_TABLE OWNER TO postgres;

--
-- Name: sport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.SPORTS_TABLE(
    id uuid NOT NULL,
    name character varying(100),
    parent_id uuid
);


ALTER TABLE public.SPORTS_TABLE OWNER TO postgres;

--
-- Name: sync_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.SYNC_CONFIGS_TABLE(
    id uuid NOT NULL,
    ical_url character varying(255)
);


ALTER TABLE public.SYNC_CONFIGS_TABLE OWNER TO postgres;

--
-- Name: sync_config_location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.SYNC_CONFIGS_LOCATIONS_TABLE(
    sync_config_id uuid NOT NULL,
    location_id uuid NOT NULL
);


ALTER TABLE public.SYNC_CONFIGS_LOCATIONS_TABLE OWNER TO postgres;

--
-- Name: sync_config_person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.SYNC_CONFIGS_PERSONS_TABLE(
    sync_config_id uuid NOT NULL,
    person_id varchar(255) NOT NULL,
    source_person_id int NOT NULL
);


ALTER TABLE public.SYNC_CONFIGS_PERSONS_TABLE OWNER TO postgres;

--
-- Name: sync_config_sport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.SYNC_CONFIGS_SPORTS_TABLE(
    sync_config_id uuid NOT NULL,
    sport_id uuid NOT NULL
);


ALTER TABLE public.SYNC_CONFIGS_SPORTS_TABLE OWNER TO postgres;

--
-- Name: sync_config_team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.SYNC_CONFIGS_TEAMS_TABLE(
    sync_config_id uuid NOT NULL,
    team_id varchar(255) NOT NULL,
    source_team_id integer NOT NULL
);


ALTER TABLE public.SYNC_CONFIGS_TEAMS_TABLE OWNER TO postgres;


--
-- Name: team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.TEAMS_TABLE(
    id varchar(255) NOT NULL,
    source_id integer NOT NULL,
    name character varying(100),
    CONSTRAINT pk_team PRIMARY KEY (id, source_id),
    CONSTRAINT fk_team_source FOREIGN KEY (source_id)
        REFERENCES public.SOURCES_TABLE (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


ALTER TABLE public.TEAMS_TABLE OWNER TO postgres;

--
-- Data for Name: event; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: event_person; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: event_team; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: location; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sport; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sync_config; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sync_config_location; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sync_config_person; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sync_config_sport; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sync_config_team; Type: TABLE DATA; Schema: public; Owner: postgres
--





--
-- Data for Name: team; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: event_person event_person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.EVENTS_PERSONS_TABLE
    ADD CONSTRAINT event_person_pkey PRIMARY KEY (event_id, person_id);


--
-- Name: location location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.LOCATIONS_TABLE
    ADD CONSTRAINT location_pkey PRIMARY KEY (id);

--
-- Name: sync_config_location sync_config_location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_LOCATIONS_TABLE
    ADD CONSTRAINT sync_config_location_pkey PRIMARY KEY (sync_config_id, location_id);


--
-- Name: sync_config_person sync_config_person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_PERSONS_TABLE
    ADD CONSTRAINT sync_config_person_pkey PRIMARY KEY (sync_config_id, person_id);


--
-- Name: sync_config sync_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_TABLE
    ADD CONSTRAINT sync_config_pkey PRIMARY KEY (id);


--
-- Name: sync_config_team sync_config_team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_TEAMS_TABLE
    ADD CONSTRAINT sync_config_team_pkey PRIMARY KEY (sync_config_id, team_id);


--
-- Name: sync_config_sport sync_config_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_SPORTS_TABLE
    ADD CONSTRAINT sync_config_type_pkey PRIMARY KEY (sync_config_id, sport_id);

--
-- Name: sport type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SPORTS_TABLE
    ADD CONSTRAINT type_pkey PRIMARY KEY (id);

--
-- Name: event_person fk_event; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.EVENTS_PERSONS_TABLE
    ADD CONSTRAINT fk_event FOREIGN KEY (event_id, source_event_id) REFERENCES public.EVENTS_TABLE(id, source_id) ON DELETE CASCADE;


--
-- Name: event fk_event_location; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.EVENTS_TABLE
    ADD CONSTRAINT fk_event_location FOREIGN KEY (location_id) REFERENCES public.LOCATIONS_TABLE (id) ON DELETE SET NULL;


--
-- Name: event fk_event_sport; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.EVENTS_TABLE
    ADD CONSTRAINT fk_event_sport FOREIGN KEY (sport_id) REFERENCES public.SPORTS_TABLE (id) ON DELETE SET NULL;


--
-- Name: sync_config_location fk_location; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_LOCATIONS_TABLE
    ADD CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES public.LOCATIONS_TABLE (id) ON DELETE CASCADE;


--
-- Name: event_person fk_person; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.EVENTS_PERSONS_TABLE
    ADD CONSTRAINT fk_person FOREIGN KEY (person_id, source_person_id) REFERENCES public.PERSONS_TABLE (id, source_id) ON DELETE CASCADE;

--
-- Name: sync_config_person fk_person; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_PERSONS_TABLE
    ADD CONSTRAINT fk_person FOREIGN KEY (person_id, source_person_id) REFERENCES public.PERSONS_TABLE (id, source_id) ON DELETE CASCADE;

--
-- Name: sync_config_team fk_sync_config; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_TEAMS_TABLE
    ADD CONSTRAINT fk_sync_config FOREIGN KEY (sync_config_id) REFERENCES public.SYNC_CONFIGS_TABLE (id) ON DELETE CASCADE;


--
-- Name: sync_config_person fk_sync_config; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_PERSONS_TABLE
    ADD CONSTRAINT fk_sync_config FOREIGN KEY (sync_config_id) REFERENCES public.SYNC_CONFIGS_TABLE (id) ON DELETE CASCADE;


--
-- Name: sync_config_location fk_sync_config; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_LOCATIONS_TABLE
    ADD CONSTRAINT fk_sync_config FOREIGN KEY (sync_config_id) REFERENCES public.SYNC_CONFIGS_TABLE(id) ON DELETE CASCADE;


--
-- Name: sync_config_sport fk_sync_config; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_SPORTS_TABLE
    ADD CONSTRAINT fk_sync_config FOREIGN KEY (sync_config_id) REFERENCES public.SYNC_CONFIGS_TABLE (id) ON DELETE CASCADE;

--
-- Name: sync_config_team fk_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
--
ALTER TABLE ONLY public.SYNC_CONFIGS_TEAMS_TABLE
    ADD CONSTRAINT fk_team FOREIGN KEY (team_id, source_team_id) REFERENCES public.TEAMS_TABLE (id, source_id) ON DELETE CASCADE;


--
-- Name: sync_config_sport fk_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_SPORTS_TABLE
    ADD CONSTRAINT fk_type FOREIGN KEY (sport_id) REFERENCES public.SPORTS_TABLE (id) ON DELETE CASCADE;


--
-- Name: sport fk_type_parent; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SPORTS_TABLE
    ADD CONSTRAINT fk_type_parent FOREIGN KEY (parent_id) REFERENCES public.SPORTS_TABLE (id);


--
-- PostgreSQL database dump complete
--

INSERT INTO SOURCES_TABLE (name) values ('FOT_MOB');


--
-- Name: sync_config_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.SYNC_CONFIGS_USERS_TABLE(
    sync_config_id uuid NOT NULL,
    e_mail character varying(100) NOT NULL
);


ALTER TABLE public.SYNC_CONFIGS_USERS_TABLE OWNER TO postgres;

--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.USERS_TABLE (
    name character varying(100),
    e_mail character varying(100) NOT NULL
);


ALTER TABLE public.USERS_TABLE OWNER TO postgres;

--
-- Data for Name: sync_config_user; Type: TABLE DATA; Schema: public; Owner: postgres
--


--
-- Name: sync_config_user sync_config_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_USERS_TABLE
    ADD CONSTRAINT sync_config_user_pkey PRIMARY KEY (sync_config_id, e_mail);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.USERS_TABLE
    ADD CONSTRAINT user_pkey PRIMARY KEY (e_mail);


--
-- Name: sync_config_user fk_sync_config; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_USERS_TABLE
    ADD CONSTRAINT fk_sync_config FOREIGN KEY (sync_config_id) REFERENCES public.SYNC_CONFIGS_TABLE (id) ON DELETE CASCADE;


--
-- Name: sync_config_user fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.SYNC_CONFIGS_USERS_TABLE
    ADD CONSTRAINT fk_user FOREIGN KEY (e_mail) REFERENCES public.USERS_TABLE(e_mail) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--
