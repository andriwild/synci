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


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event (
    id uuid NOT NULL,
    name character varying(100),
    starts_on timestamp without time zone,
    ends_on timestamp without time zone,
    sport_id uuid,
    location_id uuid
);


ALTER TABLE public.event OWNER TO postgres;

--
-- Name: event_person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_person (
    event_id uuid NOT NULL,
    person_id uuid NOT NULL
);


ALTER TABLE public.event_person OWNER TO postgres;

--
-- Name: event_team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_team (
    event_id uuid NOT NULL,
    team_id uuid NOT NULL
);


ALTER TABLE public.event_team OWNER TO postgres;

--
-- Name: location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.location (
    id uuid NOT NULL,
    name character varying(100)
);


ALTER TABLE public.location OWNER TO postgres;

--
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person (
    id uuid NOT NULL,
    name character varying(100)
);


ALTER TABLE public.person OWNER TO postgres;

--
-- Name: sport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sport (
    id uuid NOT NULL,
    name character varying(100),
    parent_id uuid
);


ALTER TABLE public.sport OWNER TO postgres;

--
-- Name: sync_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sync_config (
    id uuid NOT NULL,
    ical_url character varying(255)
);


ALTER TABLE public.sync_config OWNER TO postgres;

--
-- Name: sync_config_location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sync_config_location (
    sync_config_id uuid NOT NULL,
    location_id uuid NOT NULL
);


ALTER TABLE public.sync_config_location OWNER TO postgres;

--
-- Name: sync_config_person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sync_config_person (
    sync_config_id uuid NOT NULL,
    person_id uuid NOT NULL
);


ALTER TABLE public.sync_config_person OWNER TO postgres;

--
-- Name: sync_config_sport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sync_config_sport (
    sync_config_id uuid NOT NULL,
    sport_id uuid NOT NULL
);


ALTER TABLE public.sync_config_sport OWNER TO postgres;

--
-- Name: sync_config_team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sync_config_team (
    sync_config_id uuid NOT NULL,
    team_id uuid NOT NULL
);


ALTER TABLE public.sync_config_team OWNER TO postgres;

--
-- Name: sync_config_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sync_config_user (
    sync_config_id uuid NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE public.sync_config_user OWNER TO postgres;

--
-- Name: team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team (
    id uuid NOT NULL,
    name character varying(100)
);


ALTER TABLE public.team OWNER TO postgres;

--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    uid uuid NOT NULL,
    first_name character varying(100),
    last_name character varying(100)
);


ALTER TABLE public."user" OWNER TO postgres;

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
-- Data for Name: sync_config_user; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: team; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: event_person event_person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_person
    ADD CONSTRAINT event_person_pkey PRIMARY KEY (event_id, person_id);


--
-- Name: event event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: event_team event_team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_team
    ADD CONSTRAINT event_team_pkey PRIMARY KEY (event_id, team_id);


--
-- Name: location location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location
    ADD CONSTRAINT location_pkey PRIMARY KEY (id);


--
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (id);


--
-- Name: sync_config_location sync_config_location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_location
    ADD CONSTRAINT sync_config_location_pkey PRIMARY KEY (sync_config_id, location_id);


--
-- Name: sync_config_person sync_config_person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_person
    ADD CONSTRAINT sync_config_person_pkey PRIMARY KEY (sync_config_id, person_id);


--
-- Name: sync_config sync_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config
    ADD CONSTRAINT sync_config_pkey PRIMARY KEY (id);


--
-- Name: sync_config_team sync_config_team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_team
    ADD CONSTRAINT sync_config_team_pkey PRIMARY KEY (sync_config_id, team_id);


--
-- Name: sync_config_sport sync_config_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_sport
    ADD CONSTRAINT sync_config_type_pkey PRIMARY KEY (sync_config_id, sport_id);


--
-- Name: sync_config_user sync_config_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_user
    ADD CONSTRAINT sync_config_user_pkey PRIMARY KEY (sync_config_id, user_id);


--
-- Name: team team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (id);


--
-- Name: sport type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sport
    ADD CONSTRAINT type_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (uid);


--
-- Name: event_team fk_event; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_team
    ADD CONSTRAINT fk_event FOREIGN KEY (event_id) REFERENCES public.event(id) ON DELETE CASCADE;


--
-- Name: event_person fk_event; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_person
    ADD CONSTRAINT fk_event FOREIGN KEY (event_id) REFERENCES public.event(id) ON DELETE CASCADE;


--
-- Name: event fk_event_location; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT fk_event_location FOREIGN KEY (location_id) REFERENCES public.location(id) ON DELETE SET NULL;


--
-- Name: event fk_event_sport; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT fk_event_sport FOREIGN KEY (sport_id) REFERENCES public.sport(id) ON DELETE SET NULL;


--
-- Name: sync_config_location fk_location; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_location
    ADD CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES public.location(id) ON DELETE CASCADE;


--
-- Name: event_person fk_person; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_person
    ADD CONSTRAINT fk_person FOREIGN KEY (person_id) REFERENCES public.person(id) ON DELETE CASCADE;


--
-- Name: sync_config_person fk_person; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_person
    ADD CONSTRAINT fk_person FOREIGN KEY (person_id) REFERENCES public.person(id) ON DELETE CASCADE;


--
-- Name: sync_config_user fk_sync_config; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_user
    ADD CONSTRAINT fk_sync_config FOREIGN KEY (sync_config_id) REFERENCES public.sync_config(id) ON DELETE CASCADE;


--
-- Name: sync_config_team fk_sync_config; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_team
    ADD CONSTRAINT fk_sync_config FOREIGN KEY (sync_config_id) REFERENCES public.sync_config(id) ON DELETE CASCADE;


--
-- Name: sync_config_person fk_sync_config; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_person
    ADD CONSTRAINT fk_sync_config FOREIGN KEY (sync_config_id) REFERENCES public.sync_config(id) ON DELETE CASCADE;


--
-- Name: sync_config_location fk_sync_config; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_location
    ADD CONSTRAINT fk_sync_config FOREIGN KEY (sync_config_id) REFERENCES public.sync_config(id) ON DELETE CASCADE;


--
-- Name: sync_config_sport fk_sync_config; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_sport
    ADD CONSTRAINT fk_sync_config FOREIGN KEY (sync_config_id) REFERENCES public.sync_config(id) ON DELETE CASCADE;


--
-- Name: event_team fk_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_team
    ADD CONSTRAINT fk_team FOREIGN KEY (team_id) REFERENCES public.team(id) ON DELETE CASCADE;


--
-- Name: sync_config_team fk_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_team
    ADD CONSTRAINT fk_team FOREIGN KEY (team_id) REFERENCES public.team(id) ON DELETE CASCADE;


--
-- Name: sync_config_sport fk_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_sport
    ADD CONSTRAINT fk_type FOREIGN KEY (sport_id) REFERENCES public.sport(id) ON DELETE CASCADE;


--
-- Name: sport fk_type_parent; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sport
    ADD CONSTRAINT fk_type_parent FOREIGN KEY (parent_id) REFERENCES public.sport(id);


--
-- Name: sync_config_user fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_config_user
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public."user"(uid) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--
