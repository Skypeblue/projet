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

--
-- Name: after_insert(); Type: FUNCTION; Schema: public; Owner: fredo
--

CREATE FUNCTION after_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
update station set place_dispo=place_dispo+1 where id=new.id_station;
return new;
end;
$$;


ALTER FUNCTION public.after_insert() OWNER TO fredo;

--
-- Name: after_veloc(); Type: FUNCTION; Schema: public; Owner: fredo
--

CREATE FUNCTION after_veloc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
update centre_reparation set place_dispo=place_dispo+1 where id_centre=new.id_centres;
return new;
end;
$$;


ALTER FUNCTION public.after_veloc() OWNER TO fredo;

--
-- Name: before_delete(); Type: FUNCTION; Schema: public; Owner: fredo
--

CREATE FUNCTION before_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
update station set place_dispo=place_dispo-1 where id=old.id_station;
return old;
end;
$$;


ALTER FUNCTION public.before_delete() OWNER TO fredo;

--
-- Name: before_velod(); Type: FUNCTION; Schema: public; Owner: fredo
--

CREATE FUNCTION before_velod() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
res velo_loue%ROWTYPE;
begin
select * into res from velo_loue where id=new.id;
if found then 
raise exception 'Vélo non disponible';
end if;
return new;
end;
$$;


ALTER FUNCTION public.before_velod() OWNER TO fredo;

--
-- Name: cout(); Type: FUNCTION; Schema: public; Owner: fredo
--

CREATE FUNCTION cout() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
res integer;
begin
select cast(date_part('minutes',duree) as integer) into res from trajet where id_trajet=new.id_trajet;
if res < 30 then
update trajet set cout=0 where id_trajet=new.id_trajet;
else 
update trajet set cout=((res-30)/15)*2 where id_trajet=new.id_trajet;
end if;
return new;
end;
$$;


ALTER FUNCTION public.cout() OWNER TO fredo;

--
-- Name: credit(); Type: FUNCTION; Schema: public; Owner: fredo
--

CREATE FUNCTION credit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
res station.velib_plus%TYPE;
begin
select velib_plus into res from station where id=new.station_arr;
if res then 
update users set credit=credit+15 where id_user=new.id_users;
end if;
return new;
end;
$$;


ALTER FUNCTION public.credit() OWNER TO fredo;

--
-- Name: delete_veloc(); Type: FUNCTION; Schema: public; Owner: fredo
--

CREATE FUNCTION delete_veloc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
update centre_reparation set place_dispo=place_dispo-1 where id_centre=old.id_centres;
return old;
end;
$$;


ALTER FUNCTION public.delete_veloc() OWNER TO fredo;

--
-- Name: dont(); Type: FUNCTION; Schema: public; Owner: fredo
--

CREATE FUNCTION dont() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
nb_id int;
begin
select count(*) as nb_id from station where id=new.id;
if nb_id<>0 then
raise notice 'pas possible';
end if;
end;
$$;


ALTER FUNCTION public.dont() OWNER TO fredo;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: centre_reparation; Type: TABLE; Schema: public; Owner: fredo
--

CREATE TABLE centre_reparation (
    id_centre integer NOT NULL,
    adresse character varying(100),
    place_tot integer NOT NULL,
    place_dispos integer NOT NULL,
    CONSTRAINT centre_reparation_check CHECK (((place_dispos >= 0) AND (place_dispos <= place_tot))),
    CONSTRAINT centre_reparation_place_tot_check CHECK ((place_tot > 0))
);


ALTER TABLE centre_reparation OWNER TO fredo;

--
-- Name: centre_reparation_id_centre_seq; Type: SEQUENCE; Schema: public; Owner: fredo
--

CREATE SEQUENCE centre_reparation_id_centre_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE centre_reparation_id_centre_seq OWNER TO fredo;

--
-- Name: centre_reparation_id_centre_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fredo
--

ALTER SEQUENCE centre_reparation_id_centre_seq OWNED BY centre_reparation.id_centre;


--
-- Name: signale; Type: TABLE; Schema: public; Owner: fredo
--

CREATE TABLE signale (
    id_users integer NOT NULL,
    id_velo integer NOT NULL,
    motif character varying(100)
);


ALTER TABLE signale OWNER TO fredo;

--
-- Name: station; Type: TABLE; Schema: public; Owner: fredo
--

CREATE TABLE station (
    id integer NOT NULL,
    adresse character varying(100),
    place_totale integer NOT NULL,
    place_dispo integer NOT NULL,
    velib_plus boolean,
    CONSTRAINT pos CHECK ((place_totale >= 0)),
    CONSTRAINT station_check CHECK (((place_dispo >= 0) AND (place_dispo <= place_totale)))
);


ALTER TABLE station OWNER TO fredo;

--
-- Name: station_id_seq; Type: SEQUENCE; Schema: public; Owner: fredo
--

CREATE SEQUENCE station_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE station_id_seq OWNER TO fredo;

--
-- Name: station_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fredo
--

ALTER SEQUENCE station_id_seq OWNED BY station.id;


--
-- Name: trajet; Type: TABLE; Schema: public; Owner: fredo
--

CREATE TABLE trajet (
    id_trajet integer NOT NULL,
    date_trajet date NOT NULL,
    duree time without time zone,
    id_users integer NOT NULL,
    id_velo integer NOT NULL,
    station_dep integer NOT NULL,
    station_arr integer,
    cout integer,
    CONSTRAINT trajet_check CHECK ((station_dep <> station_arr)),
    CONSTRAINT trajet_cout_check CHECK ((cout >= 0))
);


ALTER TABLE trajet OWNER TO fredo;

--
-- Name: trajet_id_trajet_seq; Type: SEQUENCE; Schema: public; Owner: fredo
--

CREATE SEQUENCE trajet_id_trajet_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE trajet_id_trajet_seq OWNER TO fredo;

--
-- Name: trajet_id_trajet_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fredo
--

ALTER SEQUENCE trajet_id_trajet_seq OWNED BY trajet.id_trajet;


--
-- Name: users; Type: TABLE; Schema: public; Owner: fredo
--

CREATE TABLE users (
    id_user integer NOT NULL,
    prenom character varying(25) NOT NULL,
    nom character varying(25) NOT NULL,
    annaiss integer NOT NULL,
    credit integer,
    abonnement character varying(25),
    CONSTRAINT users_annaiss_check CHECK ((annaiss <= 2002)),
    CONSTRAINT users_credit_check CHECK ((credit >= 0))
);


ALTER TABLE users OWNER TO fredo;

--
-- Name: users_id_user_seq; Type: SEQUENCE; Schema: public; Owner: fredo
--

CREATE SEQUENCE users_id_user_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_id_user_seq OWNER TO fredo;

--
-- Name: users_id_user_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fredo
--

ALTER SEQUENCE users_id_user_seq OWNED BY users.id_user;


--
-- Name: velo_casse; Type: TABLE; Schema: public; Owner: fredo
--

CREATE TABLE velo_casse (
    id integer NOT NULL,
    id_centres integer NOT NULL,
    elec boolean NOT NULL
);


ALTER TABLE velo_casse OWNER TO fredo;

--
-- Name: velo_dispo; Type: TABLE; Schema: public; Owner: fredo
--

CREATE TABLE velo_dispo (
    id integer NOT NULL,
    id_station integer NOT NULL,
    elec boolean
);


ALTER TABLE velo_dispo OWNER TO fredo;

--
-- Name: velo_loue; Type: TABLE; Schema: public; Owner: fredo
--

CREATE TABLE velo_loue (
    id integer NOT NULL,
    elec boolean
);


ALTER TABLE velo_loue OWNER TO fredo;

--
-- Name: id_centre; Type: DEFAULT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY centre_reparation ALTER COLUMN id_centre SET DEFAULT nextval('centre_reparation_id_centre_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY station ALTER COLUMN id SET DEFAULT nextval('station_id_seq'::regclass);


--
-- Name: id_trajet; Type: DEFAULT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY trajet ALTER COLUMN id_trajet SET DEFAULT nextval('trajet_id_trajet_seq'::regclass);


--
-- Name: id_user; Type: DEFAULT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY users ALTER COLUMN id_user SET DEFAULT nextval('users_id_user_seq'::regclass);


--
-- Data for Name: centre_reparation; Type: TABLE DATA; Schema: public; Owner: fredo
--

COPY centre_reparation (id_centre, adresse, place_tot, place_dispos) FROM stdin;
1	82 AVENUE SAINT MANDE 	20	20
2	37 RUE CASANOVA 	10	10
3	PLACE DU LIEUTENANT HENRI KARCHER 	10	10
4	14 AVENUE VICTORIA 	10	10
5	12 RUE DES HALLES 	10	10
6	3 RUE DE LA COSSONNERIE 	20	20
7	165 RUE SAINT HONORE 	15	15
8	46 RUE DE MONTMARTRE 	10	10
9	20 RUE SAINT FIACRE 	10	10
10	32 RUE ETIENNE MARCEL 	10	10
11	2 RUE DABOUKIR 	20	20
12	8 RUE SAINT MARC 	10	10
13	1 RUE CHABANAIS 	10	10
14	62 RUE MESLAY 	15	15
15	FACE 34 RUE GRENIER SAINT LAZARE 	10	10
16	7 PLACE DE LHOTEL DE VILLE 	20	20
17	FACE 40 BOULEVARD SEBASTOPOL 	10	10
18	22 AVENUE DES GOBELINS 	10	10
19	8	10	10
20	21 RUE CENSIER 	10	10
21	42 RUE SAINT SEVERIN 	20	20
22	22 RUE CUJAS 	10	10
23	41 RUE NOTRE DAME DES CHAMPS 	10	10
24	29 RUE DU CHERCHE MIDI 	10	10
25	17 RUE DES BEAUX ARTS 	10	10
26	1 RUE JACQUES CALLOT 	20	20
27	55 RUE DES SAINTS PERES 	10	10
28	28 RUE SAINT PLACIDE 	15	15
29	FACE 119 RUE DE LILLE 	10	10
30	35 BOULEVARD DES INVALIDES 	10	10
31	QUAI DORSAY 	20	20
32	10 RUE DE VILLERSEXEL 	10	10
33	FACE 19 RUE CASIMIR PERIER 	10	10
34	2 RUE JEAN MERMOZ 	10	10
35	87 BD COURCELLES 	15	15
36	56 RUE FRANCOIS 1ER 	20	20
37	45 AVENUE MARCEAU 	10	10
38	DEV 32 RUE PASQUIER 	10	10
39	10 BOULEVARD DES BATIGNOLLES SUR TPC 	10	10
40	AV. DUTUIT 	10	10
41	4 RUE ROQUEPINE 	20	20
42	14 RUE ROCHER 	15	15
43	39 RUE DE LISBONNE 	10	10
44	22 RUE FRANCOIS 1ER 	10	10
45	PLACE GEORGES GUILLAUMIN 	10	10
46	28 RUE DE MADRID 	20	20
47	27 AVENUE MATIGNON 	10	10
48	FACE 3 AVENUE MONTAIGNE 	10	10
49	10 RUE VERNET 	15	15
50	95 RUE DE DUNKERQUE 	10	10
51	19 RUE GUERANDO 	20	20
52	26 RUE MONTHOLON 	10	10
53	PLACE BARBES 	10	10
54	4 RUE MONCEY 	10	10
55	27 RUE TAITBOUT 	10	10
56	2 RUE DE LONDRES 	20	20
57	81 RUE DUNKERQUE 	10	10
58	12 RUE DES MATHURINS 	10	10
59	14 RUE DE MARSEILLE 	10	10
60	12 BIS RUE DE LA GRANGE AUX BELLES 	10	10
61	48 RUE LOUIS BLANC 	20	20
62	EGLISE SAINT JOSEPH ARTISAN 	10	10
63	4 RUE DE DUNKERQUE 	15	15
64	29 RUE DES RECOLLETS 	10	10
65	8	10	10
66	57 RUE DU CHATEAU DEAU 	20	20
67	FACE 77 BOULEVARD DE CHARONNE 	10	10
68	17 RUE SAINT AMBROISE 	10	10
69	5 PLACE DE LA NATION 	10	10
70	FACE 121 BOULEVARD RICHARD LENOIR 	15	15
71	8 place de la république 	20	20
72	1 RUE JACQUARD 	10	10
73	29 RUE KELLER 	10	10
74	3 RUE ALEXANDRE DUMAS 	10	10
75	FACE 23 BD RICHARD LENOIR 	10	10
76	FACE 20 RUE GUILLAUME BERTRAND 	20	20
77	GARE DE BERCY 	15	15
78	1 PLACE EDOUARD RENARD 	10	10
79	3 RUE ROLAND BARTHES 	10	10
80	71 BOULEVARD DIDEROT 	10	10
81	4 PLACE DU CARDINAL LAVIGERIE 	20	20
82	2 RUE MONTGALLET 	10	10
83	245 RUE DE CHARENTON 	10	10
84	FACE 71 AVENUE DE GRAVELLE 	15	15
85	FACE 29 RUE DU SAHEL 	10	10
86	81 RUE DE BERCY 	20	20
87	FACE 124 RUE DE CHARENTON 	10	10
88	FACE 2 AV. DE LA PORTE DE CHARENTON 	10	10
89	FACE 1 RUE JEAN COLLY 	10	10
90	46 BOULEVARD AUGUSTE BLANQUI 	10	10
91	FACE 11 PLACE DITALIE 	20	20
92	10 RUE EUGENE OUDINE 	10	10
93	121 AVENUE DITALIE 	10	10
94	FACE 2 PLACE DITALIE 	10	10
95	20 RUE WURTZ 	10	10
96	9 QUAI FRANCOIS MAURIAC 	20	20
97	55 BD ARAGO 	10	10
98	88 BOULEVARD AUGUSTE BLANQUI (SUR TPC) 	15	15
99	163 AVENUE DITALIE 	10	10
100	FACE 15 RUE PAUL KLEE 	10	10
\.


--
-- Name: centre_reparation_id_centre_seq; Type: SEQUENCE SET; Schema: public; Owner: fredo
--

SELECT pg_catalog.setval('centre_reparation_id_centre_seq', 100, true);


--
-- Data for Name: signale; Type: TABLE DATA; Schema: public; Owner: fredo
--

COPY signale (id_users, id_velo, motif) FROM stdin;
1821	5046	frein_avant
251	941	frein_avant
40	3771	guidon_absent
523	4343	selle_manquante
760	5181	guidon_absent
1202	587	pneu_dégonflé
1433	583	bruit_inquétant_clic
1930	1331	pneu_dégonflé
1657	6436	frein_avant
1279	5366	dérailleur_non_réglé
1649	667	bruit_inquétant_clic
966	6319	bruit_inquétant_clic
126	1594	frein_avant
163	1792	dérailleur_non_réglé
1600	6267	bruit_inquétant_clic
384	332	pneu_dégonflé
1294	3503	selle_manquante
513	1087	guidon_absent
1137	5751	selle_manquante
1607	3487	dérailleur_non_réglé
428	2645	pneu_dégonflé
329	4406	bruit_inquétant_clic
1926	1887	bruit_inquétant_clic
1789	3991	frein_avant
851	4939	bruit_inquétant_clic
1767	3891	selle_manquante
77	2687	dérailleur_non_réglé
353	5729	guidon_absent
110	2020	frein_gauche
1738	3068	selle_manquante
1399	2913	pneu_dégonflé
1083	5463	frein_gauche
1885	4539	selle_manquante
1720	2991	dérailleur_non_réglé
1602	3024	bruit_inquétant_clic
462	4229	frein_gauche
1725	152	selle_manquante
1202	6263	guidon_absent
792	5674	selle_manquante
1123	440	dérailleur_non_réglé
1575	5958	frein_gauche
1063	6113	pneu_dégonflé
1610	41	bruit_inquétant_clic
897	365	guidon_absent
625	2361	frein_avant
783	5179	guidon_absent
37	2803	frein_gauche
1004	3388	frein_avant
667	1552	bruit_inquétant_clic
1687	4818	frein_gauche
1634	1732	pneu_dégonflé
148	3118	dérailleur_non_réglé
867	5588	pneu_dégonflé
992	3584	frein_gauche
1640	3619	frein_gauche
1585	1161	frein_avant
1466	504	dérailleur_non_réglé
1852	2506	guidon_absent
1006	3972	dérailleur_non_réglé
1347	356	selle_manquante
1773	4054	frein_gauche
1171	5960	selle_manquante
1574	2325	selle_manquante
1305	3724	pneu_dégonflé
541	2417	bruit_inquétant_clic
59	510	selle_manquante
1585	4355	pneu_dégonflé
1589	973	frein_gauche
1671	5088	selle_manquante
1026	5143	frein_avant
608	6244	pneu_dégonflé
1096	5813	bruit_inquétant_clic
1037	2343	guidon_absent
161	832	pneu_dégonflé
1586	1078	pneu_dégonflé
1429	6397	guidon_absent
1462	595	dérailleur_non_réglé
2002	2598	guidon_absent
1716	4845	selle_manquante
1813	2690	guidon_absent
1533	1799	dérailleur_non_réglé
997	5307	frein_avant
1604	35	dérailleur_non_réglé
1448	1885	frein_avant
427	1845	frein_gauche
486	2694	selle_manquante
203	1444	bruit_inquétant_clic
1396	3781	frein_avant
1581	4929	pneu_dégonflé
1399	6265	pneu_dégonflé
213	6651	frein_avant
984	2320	pneu_dégonflé
1304	4232	frein_gauche
1942	849	pneu_dégonflé
864	4884	selle_manquante
1997	2025	pneu_dégonflé
442	5356	bruit_inquétant_clic
186	3517	frein_gauche
1748	6188	bruit_inquétant_clic
1917	4680	pneu_dégonflé
1268	4441	frein_gauche
65	2853	bruit_inquétant_clic
191	6070	pneu_dégonflé
1824	6508	bruit_inquétant_clic
874	3928	frein_gauche
1222	4813	guidon_absent
688	1603	bruit_inquétant_clic
983	106	dérailleur_non_réglé
411	4617	pneu_dégonflé
142	3309	selle_manquante
1168	5257	frein_avant
161	1787	dérailleur_non_réglé
1715	2762	selle_manquante
1620	3366	frein_avant
957	5010	selle_manquante
1379	4512	frein_gauche
755	4688	frein_avant
880	5514	bruit_inquétant_clic
1198	3931	frein_gauche
1050	2541	bruit_inquétant_clic
1583	752	frein_gauche
1441	414	frein_avant
1915	2354	dérailleur_non_réglé
1632	3143	selle_manquante
907	1751	pneu_dégonflé
1594	2496	guidon_absent
1772	4388	frein_gauche
205	3996	frein_avant
21	776	selle_manquante
1366	2270	dérailleur_non_réglé
1536	653	frein_gauche
630	1397	pneu_dégonflé
1639	3338	dérailleur_non_réglé
554	5466	dérailleur_non_réglé
344	4245	dérailleur_non_réglé
1400	1536	frein_avant
787	3614	guidon_absent
1843	1534	bruit_inquétant_clic
1464	5024	guidon_absent
1364	5835	pneu_dégonflé
243	3765	frein_avant
1013	3409	guidon_absent
489	361	frein_avant
1814	1233	selle_manquante
481	6530	guidon_absent
1442	5592	guidon_absent
798	3193	pneu_dégonflé
692	4855	guidon_absent
171	1191	guidon_absent
1043	3739	bruit_inquétant_clic
1330	5317	guidon_absent
140	2768	bruit_inquétant_clic
1187	3332	frein_gauche
1026	2702	bruit_inquétant_clic
1650	5545	pneu_dégonflé
554	2572	frein_avant
1946	6214	selle_manquante
1855	4334	selle_manquante
1050	2528	selle_manquante
1237	6212	frein_gauche
1894	1908	dérailleur_non_réglé
1009	4178	pneu_dégonflé
1626	5812	guidon_absent
469	5500	guidon_absent
1296	1473	guidon_absent
1510	2345	frein_avant
817	2218	guidon_absent
1037	2758	guidon_absent
1443	2614	frein_avant
1762	5480	dérailleur_non_réglé
930	6478	bruit_inquétant_clic
817	3571	bruit_inquétant_clic
1857	4262	guidon_absent
227	1921	frein_gauche
1314	2276	guidon_absent
274	1361	dérailleur_non_réglé
1200	6501	selle_manquante
626	248	pneu_dégonflé
60	4973	dérailleur_non_réglé
38	2401	frein_gauche
340	1141	dérailleur_non_réglé
330	2729	dérailleur_non_réglé
637	5172	selle_manquante
1137	5160	bruit_inquétant_clic
212	1619	frein_gauche
1790	1002	selle_manquante
1158	4506	selle_manquante
1675	516	frein_avant
1446	2406	guidon_absent
1928	4604	frein_gauche
472	6192	pneu_dégonflé
716	656	bruit_inquétant_clic
1123	3998	frein_avant
920	1306	frein_gauche
1944	5484	pneu_dégonflé
461	2073	pneu_dégonflé
1263	4475	pneu_dégonflé
1830	2183	guidon_absent
1271	5790	frein_avant
545	6187	frein_avant
630	1135	frein_gauche
72	1854	guidon_absent
490	4771	frein_avant
138	6280	frein_avant
598	2719	bruit_inquétant_clic
1647	2976	frein_gauche
578	5693	frein_avant
350	5168	selle_manquante
1940	3974	selle_manquante
862	3045	frein_gauche
844	2296	pneu_dégonflé
478	1342	frein_avant
96	6658	frein_avant
1061	783	guidon_absent
145	946	pneu_dégonflé
820	827	guidon_absent
1164	5954	guidon_absent
874	5881	bruit_inquétant_clic
216	3914	pneu_dégonflé
39	6106	pneu_dégonflé
474	3387	selle_manquante
688	5375	dérailleur_non_réglé
976	3626	bruit_inquétant_clic
145	5062	bruit_inquétant_clic
684	6299	frein_avant
918	2636	frein_gauche
50	4736	dérailleur_non_réglé
808	5432	guidon_absent
897	993	frein_gauche
1439	4501	selle_manquante
1586	4030	frein_gauche
1202	3587	pneu_dégonflé
1889	3008	selle_manquante
574	1873	guidon_absent
481	3994	selle_manquante
889	5973	selle_manquante
915	3913	dérailleur_non_réglé
1872	5469	guidon_absent
1097	4887	frein_avant
1976	3227	pneu_dégonflé
992	1156	bruit_inquétant_clic
49	1425	dérailleur_non_réglé
547	489	frein_avant
669	2770	dérailleur_non_réglé
1956	5638	frein_gauche
337	4731	dérailleur_non_réglé
537	1773	frein_avant
595	5626	pneu_dégonflé
1834	3476	guidon_absent
1	6375	guidon_absent
966	3369	frein_avant
1470	873	dérailleur_non_réglé
1489	3518	frein_avant
1549	1905	selle_manquante
1540	1848	dérailleur_non_réglé
1474	4638	guidon_absent
1244	948	guidon_absent
1929	4071	guidon_absent
1318	4393	frein_avant
152	6112	pneu_dégonflé
113	2413	dérailleur_non_réglé
538	2575	frein_gauche
288	3715	guidon_absent
5	3056	dérailleur_non_réglé
1109	2272	frein_gauche
517	4748	bruit_inquétant_clic
853	6638	selle_manquante
1363	4564	bruit_inquétant_clic
1138	5879	selle_manquante
1520	4003	guidon_absent
102	681	dérailleur_non_réglé
183	3817	frein_gauche
1705	2291	dérailleur_non_réglé
1735	4227	pneu_dégonflé
1054	863	pneu_dégonflé
237	4545	frein_gauche
1069	940	guidon_absent
20	1252	frein_gauche
301	6324	dérailleur_non_réglé
746	5544	frein_gauche
1359	4496	bruit_inquétant_clic
1907	592	selle_manquante
1629	1595	pneu_dégonflé
1835	4091	frein_gauche
812	671	frein_gauche
1405	1150	dérailleur_non_réglé
839	3038	frein_gauche
1104	3102	selle_manquante
712	967	bruit_inquétant_clic
422	3396	guidon_absent
1806	4598	dérailleur_non_réglé
1937	449	guidon_absent
401	2647	bruit_inquétant_clic
913	1389	frein_gauche
1046	5041	frein_avant
75	3440	dérailleur_non_réglé
1371	1468	frein_avant
84	1211	guidon_absent
614	97	frein_avant
1626	4529	bruit_inquétant_clic
646	4889	pneu_dégonflé
1548	830	frein_avant
1325	5975	dérailleur_non_réglé
538	1783	bruit_inquétant_clic
745	5756	selle_manquante
627	3862	pneu_dégonflé
370	4900	selle_manquante
1466	6135	dérailleur_non_réglé
614	4065	pneu_dégonflé
90	6566	guidon_absent
1272	3243	frein_gauche
1915	4437	bruit_inquétant_clic
1366	2328	bruit_inquétant_clic
887	4724	pneu_dégonflé
956	3129	frein_avant
1834	4377	guidon_absent
1197	1415	frein_avant
42	190	pneu_dégonflé
1327	3926	selle_manquante
1352	5869	bruit_inquétant_clic
1612	354	dérailleur_non_réglé
1004	5549	dérailleur_non_réglé
1627	5073	frein_gauche
1163	5595	selle_manquante
1561	2638	dérailleur_non_réglé
1999	3018	frein_avant
1928	1079	pneu_dégonflé
75	2278	guidon_absent
397	5427	dérailleur_non_réglé
343	6120	frein_gauche
1341	4405	selle_manquante
1980	3357	dérailleur_non_réglé
483	4615	bruit_inquétant_clic
1681	5397	bruit_inquétant_clic
377	6392	pneu_dégonflé
1893	6359	selle_manquante
1152	2267	selle_manquante
549	1869	frein_gauche
301	3044	pneu_dégonflé
1457	6381	pneu_dégonflé
1893	6612	dérailleur_non_réglé
406	1676	selle_manquante
232	2606	frein_avant
1195	2033	bruit_inquétant_clic
1485	5923	frein_avant
1076	68	bruit_inquétant_clic
1153	939	selle_manquante
177	3968	dérailleur_non_réglé
1477	6432	selle_manquante
1269	3048	frein_gauche
336	6518	guidon_absent
938	1328	pneu_dégonflé
1098	5832	bruit_inquétant_clic
372	5494	guidon_absent
1982	1939	bruit_inquétant_clic
933	5234	frein_gauche
1870	5487	frein_gauche
381	4443	pneu_dégonflé
377	2780	frein_avant
1787	6457	frein_avant
1480	109	guidon_absent
1192	1073	selle_manquante
1754	5880	frein_gauche
847	1824	frein_avant
1031	4802	frein_gauche
1600	5475	pneu_dégonflé
1637	5745	frein_avant
647	1634	dérailleur_non_réglé
1748	1895	guidon_absent
769	2084	frein_avant
1235	2334	bruit_inquétant_clic
1389	3840	dérailleur_non_réglé
537	6428	pneu_dégonflé
1920	3853	frein_avant
1002	6128	selle_manquante
1753	5119	frein_avant
1674	607	selle_manquante
854	4079	pneu_dégonflé
1812	6509	pneu_dégonflé
150	6018	dérailleur_non_réglé
1937	3581	bruit_inquétant_clic
1789	3714	frein_avant
371	3516	frein_gauche
1585	302	frein_avant
1805	3984	frein_gauche
730	3922	guidon_absent
1995	1642	bruit_inquétant_clic
393	5311	guidon_absent
1644	3812	selle_manquante
1371	4578	guidon_absent
1342	5094	frein_avant
1668	1080	frein_avant
839	4110	dérailleur_non_réglé
1147	659	guidon_absent
408	3417	guidon_absent
1376	3799	frein_gauche
1438	4082	bruit_inquétant_clic
192	1668	selle_manquante
1860	1758	bruit_inquétant_clic
1698	6238	guidon_absent
694	2970	pneu_dégonflé
448	6369	bruit_inquétant_clic
1354	3221	bruit_inquétant_clic
1458	908	selle_manquante
1152	5917	pneu_dégonflé
1276	930	frein_gauche
843	4624	frein_avant
1803	6663	dérailleur_non_réglé
267	1066	pneu_dégonflé
1923	769	frein_avant
627	24	dérailleur_non_réglé
1969	2939	frein_avant
1808	2120	selle_manquante
150	5567	bruit_inquétant_clic
1691	2796	guidon_absent
704	1040	frein_avant
66	1700	frein_avant
244	5383	frein_gauche
1641	3965	frein_avant
398	2789	guidon_absent
1935	3176	guidon_absent
1973	3352	guidon_absent
396	4031	pneu_dégonflé
1614	685	frein_avant
354	6219	selle_manquante
1842	3407	selle_manquante
129	5131	pneu_dégonflé
849	4200	guidon_absent
810	4041	bruit_inquétant_clic
215	6061	dérailleur_non_réglé
514	2644	bruit_inquétant_clic
482	1664	selle_manquante
1764	4125	frein_avant
484	3446	guidon_absent
1236	1573	bruit_inquétant_clic
1633	682	bruit_inquétant_clic
1327	4480	guidon_absent
866	2388	selle_manquante
381	5938	guidon_absent
343	2067	frein_avant
1093	1442	selle_manquante
1199	5027	pneu_dégonflé
254	3718	bruit_inquétant_clic
1824	1372	selle_manquante
143	5974	selle_manquante
1525	2064	dérailleur_non_réglé
734	5822	dérailleur_non_réglé
824	5779	bruit_inquétant_clic
1589	5575	pneu_dégonflé
942	2987	pneu_dégonflé
1361	1817	selle_manquante
981	6066	frein_gauche
894	2384	dérailleur_non_réglé
625	5291	bruit_inquétant_clic
1688	4029	pneu_dégonflé
1041	5008	frein_avant
773	4653	frein_avant
895	4295	frein_avant
1169	5714	selle_manquante
1796	2368	bruit_inquétant_clic
142	3474	frein_avant
1412	2437	frein_gauche
221	6648	frein_avant
835	5905	guidon_absent
1330	5098	pneu_dégonflé
1122	270	guidon_absent
895	542	guidon_absent
1458	4953	dérailleur_non_réglé
1747	6157	frein_avant
1908	4863	bruit_inquétant_clic
193	5584	frein_gauche
1016	3178	guidon_absent
347	1013	bruit_inquétant_clic
462	3758	guidon_absent
1463	3058	pneu_dégonflé
1454	4455	pneu_dégonflé
807	244	frein_gauche
1097	3647	bruit_inquétant_clic
617	1627	frein_avant
441	503	pneu_dégonflé
142	4382	frein_avant
1372	2607	frein_avant
1843	5613	frein_avant
518	6004	frein_gauche
316	4697	selle_manquante
375	3225	dérailleur_non_réglé
575	4497	bruit_inquétant_clic
94	5401	frein_avant
1922	4741	frein_gauche
1646	4866	guidon_absent
1147	262	frein_gauche
176	1626	bruit_inquétant_clic
677	3157	guidon_absent
1655	5417	dérailleur_non_réglé
632	38	bruit_inquétant_clic
149	3464	frein_avant
1869	694	frein_avant
1302	4685	bruit_inquétant_clic
215	2480	frein_avant
645	1166	bruit_inquétant_clic
1444	6431	dérailleur_non_réglé
1985	569	dérailleur_non_réglé
1205	2269	selle_manquante
632	1721	guidon_absent
1243	3306	frein_avant
1356	723	selle_manquante
129	3349	frein_gauche
1669	4586	frein_avant
167	3988	pneu_dégonflé
332	1270	frein_gauche
1997	1210	pneu_dégonflé
1271	2114	frein_gauche
759	4442	pneu_dégonflé
1308	3927	frein_avant
157	2431	guidon_absent
1378	2004	guidon_absent
860	4786	bruit_inquétant_clic
1104	380	frein_gauche
1078	1660	dérailleur_non_réglé
269	5851	guidon_absent
1727	3120	dérailleur_non_réglé
505	200	selle_manquante
390	6114	bruit_inquétant_clic
1757	66	bruit_inquétant_clic
971	2920	guidon_absent
1557	482	pneu_dégonflé
669	2139	selle_manquante
1379	6503	frein_avant
106	3509	frein_gauche
79	4446	dérailleur_non_réglé
1181	4993	frein_gauche
25	1572	dérailleur_non_réglé
1696	413	bruit_inquétant_clic
1671	826	frein_gauche
820	6177	pneu_dégonflé
1533	664	frein_avant
718	615	selle_manquante
190	1564	pneu_dégonflé
313	4878	bruit_inquétant_clic
1044	1948	frein_avant
1617	5591	selle_manquante
925	1008	frein_gauche
389	4325	selle_manquante
1270	238	pneu_dégonflé
1283	3034	frein_gauche
232	6121	bruit_inquétant_clic
664	6115	selle_manquante
536	96	frein_gauche
1362	6668	guidon_absent
1158	2167	selle_manquante
28	5139	frein_gauche
1440	4985	bruit_inquétant_clic
1334	3558	pneu_dégonflé
1147	4257	bruit_inquétant_clic
40	2540	frein_avant
372	1655	pneu_dégonflé
453	2934	bruit_inquétant_clic
829	6423	bruit_inquétant_clic
553	2279	guidon_absent
1433	5710	frein_avant
1661	1840	guidon_absent
1527	4515	pneu_dégonflé
1442	5447	pneu_dégonflé
624	6255	frein_avant
1766	6446	frein_avant
878	1020	frein_avant
439	5284	bruit_inquétant_clic
313	4872	selle_manquante
564	2599	pneu_dégonflé
492	2858	frein_avant
1684	368	selle_manquante
356	6262	frein_avant
1756	3907	guidon_absent
1511	1802	dérailleur_non_réglé
273	353	selle_manquante
1396	108	dérailleur_non_réglé
1998	1978	bruit_inquétant_clic
921	3462	selle_manquante
1332	5337	guidon_absent
1773	5635	bruit_inquétant_clic
1613	2524	dérailleur_non_réglé
1798	1922	dérailleur_non_réglé
1989	3428	frein_avant
1306	696	guidon_absent
240	3500	pneu_dégonflé
95	1376	frein_avant
1868	2193	frein_avant
507	2481	frein_avant
984	2790	dérailleur_non_réglé
1666	490	dérailleur_non_réglé
926	2141	dérailleur_non_réglé
1949	1373	guidon_absent
349	3436	pneu_dégonflé
252	1788	frein_gauche
1738	3686	selle_manquante
1832	2570	dérailleur_non_réglé
675	3903	frein_avant
321	4228	bruit_inquétant_clic
775	2973	frein_avant
1341	5467	selle_manquante
973	6220	pneu_dégonflé
602	5857	dérailleur_non_réglé
440	1180	dérailleur_non_réglé
390	1493	frein_gauche
1396	4634	frein_gauche
1145	3828	pneu_dégonflé
834	1246	frein_avant
799	5815	frein_avant
1077	1795	frein_avant
33	4153	frein_gauche
841	3470	frein_gauche
1127	5028	frein_gauche
1833	5461	guidon_absent
977	4519	bruit_inquétant_clic
903	2424	dérailleur_non_réglé
271	6520	bruit_inquétant_clic
1906	6481	frein_gauche
1042	4875	frein_gauche
896	5209	dérailleur_non_réglé
1405	214	guidon_absent
1911	1441	frein_avant
275	5770	dérailleur_non_réglé
1363	2103	frein_avant
554	3886	bruit_inquétant_clic
1386	1523	guidon_absent
1185	6268	frein_avant
279	5523	frein_avant
1914	558	selle_manquante
64	3762	frein_gauche
1356	750	guidon_absent
1879	4935	selle_manquante
976	1849	bruit_inquétant_clic
820	2608	dérailleur_non_réglé
90	5922	dérailleur_non_réglé
262	3465	dérailleur_non_réglé
1542	5402	frein_gauche
1603	4132	dérailleur_non_réglé
188	4421	frein_avant
1919	790	guidon_absent
67	1479	selle_manquante
1021	1864	dérailleur_non_réglé
909	2240	bruit_inquétant_clic
694	2439	bruit_inquétant_clic
206	381	bruit_inquétant_clic
920	1806	pneu_dégonflé
1272	1651	frein_avant
214	2047	frein_gauche
63	4022	bruit_inquétant_clic
1730	5876	selle_manquante
604	3318	frein_gauche
395	1516	pneu_dégonflé
434	4327	frein_gauche
1463	706	selle_manquante
816	2952	pneu_dégonflé
1294	539	guidon_absent
1145	1429	dérailleur_non_réglé
1469	2363	frein_gauche
1246	2373	selle_manquante
1691	1302	dérailleur_non_réglé
392	6443	pneu_dégonflé
187	4311	frein_gauche
1263	267	guidon_absent
1280	2249	dérailleur_non_réglé
553	2149	frein_avant
86	5614	bruit_inquétant_clic
163	780	frein_avant
1042	405	frein_gauche
1135	4068	selle_manquante
826	5465	selle_manquante
921	2285	bruit_inquétant_clic
1977	1653	frein_avant
254	3798	frein_avant
923	3182	bruit_inquétant_clic
310	603	guidon_absent
818	6472	bruit_inquétant_clic
1533	2356	guidon_absent
788	4827	selle_manquante
1197	1930	bruit_inquétant_clic
1673	1606	frein_gauche
1424	1964	frein_gauche
1862	6046	frein_avant
1486	6337	dérailleur_non_réglé
657	1224	frein_avant
428	191	pneu_dégonflé
637	3859	dérailleur_non_réglé
382	5972	frein_avant
1384	2212	frein_avant
282	5579	frein_gauche
1822	6398	selle_manquante
266	6670	selle_manquante
547	5722	dérailleur_non_réglé
1742	602	guidon_absent
208	5968	frein_gauche
1297	3552	pneu_dégonflé
1175	6281	pneu_dégonflé
1162	807	frein_gauche
269	566	selle_manquante
1568	4510	frein_avant
337	149	bruit_inquétant_clic
546	3025	dérailleur_non_réglé
1825	4243	dérailleur_non_réglé
1274	1085	pneu_dégonflé
1150	5877	selle_manquante
1301	3512	frein_avant
115	5702	pneu_dégonflé
354	4581	frein_avant
1558	5218	bruit_inquétant_clic
1979	3505	frein_gauche
762	187	frein_gauche
1263	6414	pneu_dégonflé
251	1496	frein_avant
884	6257	bruit_inquétant_clic
650	2192	guidon_absent
40	364	selle_manquante
1149	2664	dérailleur_non_réglé
488	3222	bruit_inquétant_clic
98	2449	frein_avant
777	660	frein_avant
1627	4537	dérailleur_non_réglé
4	5149	frein_gauche
480	4796	guidon_absent
237	2785	guidon_absent
789	2634	guidon_absent
1869	2007	frein_gauche
406	5171	pneu_dégonflé
1780	324	frein_avant
1079	2016	guidon_absent
98	5260	frein_gauche
1645	5665	selle_manquante
207	6309	bruit_inquétant_clic
931	1108	guidon_absent
1343	2335	bruit_inquétant_clic
1933	3386	frein_avant
1615	6326	pneu_dégonflé
71	2217	pneu_dégonflé
212	6415	dérailleur_non_réglé
220	3283	pneu_dégonflé
823	4487	bruit_inquétant_clic
1735	3740	dérailleur_non_réglé
298	5121	bruit_inquétant_clic
85	2672	frein_gauche
482	1689	frein_avant
1512	3435	frein_avant
1335	695	frein_avant
589	2734	guidon_absent
1643	2460	selle_manquante
1803	4189	pneu_dégonflé
545	5331	frein_avant
220	1856	frein_gauche
327	5235	frein_avant
845	402	pneu_dégonflé
360	5570	frein_gauche
1120	5952	frein_gauche
1999	1518	pneu_dégonflé
163	2747	frein_avant
1699	2712	bruit_inquétant_clic
1981	1599	selle_manquante
1636	841	frein_avant
847	2397	pneu_dégonflé
1476	5328	dérailleur_non_réglé
1188	4308	pneu_dégonflé
842	6041	bruit_inquétant_clic
1150	2053	frein_gauche
1199	6125	guidon_absent
1489	4456	pneu_dégonflé
1998	1823	pneu_dégonflé
1115	4758	bruit_inquétant_clic
677	3597	guidon_absent
653	1508	frein_gauche
542	3174	pneu_dégonflé
468	2435	frein_gauche
1406	2327	selle_manquante
1842	2550	bruit_inquétant_clic
259	6137	frein_avant
1630	4984	bruit_inquétant_clic
1939	2206	bruit_inquétant_clic
335	142	guidon_absent
63	1970	dérailleur_non_réglé
669	639	frein_gauche
1288	4817	pneu_dégonflé
1829	5724	bruit_inquétant_clic
867	4150	bruit_inquétant_clic
676	2261	frein_avant
402	4165	selle_manquante
1533	4145	guidon_absent
645	3232	bruit_inquétant_clic
1740	4078	frein_avant
121	3134	frein_avant
1695	40	frein_gauche
1664	4042	selle_manquante
1468	4373	frein_avant
858	385	selle_manquante
1656	1742	guidon_absent
554	6506	frein_avant
1892	5594	bruit_inquétant_clic
1929	2454	frein_avant
1958	2229	frein_avant
1753	6547	selle_manquante
321	2546	selle_manquante
39	1352	guidon_absent
1854	259	frein_avant
200	3504	guidon_absent
437	3671	bruit_inquétant_clic
386	5	selle_manquante
572	5875	bruit_inquétant_clic
1389	1707	frein_gauche
955	2704	pneu_dégonflé
514	658	frein_avant
445	5934	bruit_inquétant_clic
991	3055	bruit_inquétant_clic
364	3743	frein_gauche
905	2763	bruit_inquétant_clic
66	970	frein_avant
3	5376	frein_avant
\.


--
-- Data for Name: station; Type: TABLE DATA; Schema: public; Owner: fredo
--

COPY station (id, adresse, place_totale, place_dispo, velib_plus) FROM stdin;
60	24 RUE DAUVERGNE 	15	10	f
109	67 RUE DES ARCHIVES 	20	13	f
83	21 RUE DU DR LERAY ET LANDOUZY 	15	7	f
96	2 RUE DE LA VISCULE 	15	10	f
105	9 rue COQUILLIERE 75001 PARIS	15	10	t
10	29 RUE DES BLANCS MANTEAUX 	20	14	f
69	FACE 124 RUE DU FAUBOURG SAINT DENIS 	15	10	f
40	QUAI BRANLY 	20	10	f
51	25 RUE BAYARD 	15	12	f
95	1 RUE PAU CASALS 	15	9	f
14	2 QUAI DES CELESTINS 	15	14	f
49	24 RUE DE MARIGNAN 	20	9	t
56	1 RUE CLAPEYRON 	15	11	f
22	8 RUE JEAN CALVIN 	20	12	f
17	50 RUE VIEILLE DU TEMPLE 	15	13	t
29	15 RUE DU VIEUX COLOMBIER 	15	12	f
98	36 RUE DE LA SANTE 	15	10	f
117	4 RUE DU CLOITRE SAINT MERRI 	15	12	f
110	76 RUE DU TEMPLE 	15	12	f
32	19 RUE DU REGARD 	15	13	f
116	49 RUE RAMBUTEAU 	15	11	f
93	4 AVENUE DIVRY 	15	11	f
7	11 RUE THOREL 	20	12	f
74	PLACE PASDELOUP 	15	11	f
3	36 RUE DE LARBRE SEC 	15	10	f
38	22 RUE DASSAS 	15	14	f
41	37 AVENUE BOSQUET 	15	7	t
53	5 PLACE SAINT AUGUSTIN 	15	8	f
25	10 RUE ANDRE MAZET 	20	12	t
97	116 AVENUE DE CHOISY 	20	13	t
75	93 RUE DE MONTREUIL 	15	9	f
44	39 QUAI DORSAY 	15	9	f
45	17 RUE DUROC 	15	12	f
92	5 BIS BOULEVARD DE LHOPITAL 	15	11	f
59	63 RUE GALILEE 	15	12	f
90	FACE 35 RUE DE LA FONTAINE A MULARD 	15	12	f
39	QUAI DORSAY 	15	11	f
80	153 RUE DE BERCY 	15	12	f
103	2 RUE DE LORATOIRE 	20	17	f
114	1 RUE DES ARCHIVES 	15	10	f
27	90 RUE DASSAS 	15	9	f
84	1 AVENUE BOUTROUX 	15	11	f
52	04 PLACE DE LA MADELEINE 	20	15	f
78	58 RUE DE LA GARE DE REUILLY 	15	11	f
73	223 RUE DU FAUBOURG SAINT ANTOINE 	20	16	t
102	10 RUE BOUCHER 	15	13	f
26	FACE 1 RUE DE VAUGIRARD 	15	10	f
58	1 RUE DE LISLY 	20	14	f
20	40 RUE BOU LANGERS 	15	10	f
21	1 RUE DE PONTOISE 	15	8	f
47	74 BOULEVARD DES BATIGNOLLES 	15	9	f
9	27 BOULEVARD BEAUMARCHAIS 	15	10	t
107	21 RUE DUZES 	15	13	f
2	49 RUE BERGER 	15	13	f
63	8 BOULEVARD DE LA VILETTE 	15	14	f
15	11 RUE DE LA BASTILLE 	15	7	f
43	43 AVENUE RAPP 	20	12	f
101	2 RUE DE TURBIGO 	15	13	f
91	9 RUE PRIMO LEVI 	20	12	f
46	QUAI VOLTAIRE 	20	12	f
48	10 AVENUE BERTHIER ALBRECHT 	15	12	f
88	GARE DAUSTERLITZ 	20	15	f
28	2 RUE BLAISE DESGOFFE 	20	15	f
82	55 RUE BOUSSINGAULT 	20	12	f
104	2 RUE DALGER 	15	10	f
115	PLACE LOUIS LEPINE 	20	14	f
12	1 QUAI AUX FLEURS 	15	9	f
87	RUE BRUNESEAU 	15	9	f
65	3 BOULEVARD DE DENAIN 	15	8	t
5	2 RUE CAMBON 	15	12	f
113	46 RUE BEAUBOURG 	15	10	t
1	27 RUE THERESE 	20	15	t
57	6 RUE DE STOCKOLM 	15	9	t
31	7 RUE DU PONT DE LODI 	20	13	f
68	2 RUE DE CHATEAU LANDON 	15	14	f
6	14 RUE BACHAUMONT 	15	9	f
70	15 RUE SAINT VINCENT DE PAUL 	20	14	f
72	10 RUE LOUIS BLANC 	15	11	f
106	108 RUE DABOUKIR 	20	15	f
33	40 RUE DU MONTPARNASSE 	15	8	t
34	16 RUE DASSAS 	20	12	f
112	22 RUE DE LA PERLE 	20	14	f
35	5 RUE PIERRE SARAZIN 	15	11	f
64	1 RUE DE LA FIDELITE 	20	18	f
89	86 RUE TOLBIAC 	15	8	t
86	27 ET 36 RUE DE LA BUTTE AUX CAILLES 	15	9	f
79	224 RUE DE BERCY 	20	12	f
11	25 RUE DU PONT LOUIS PHILIPPE 	15	11	f
94	16 RUE BRILLAT SAVARIN 	20	14	f
50	1 RUE JOSEPH SANSBOEUF 	15	10	f
37	18 RUE BREA 	20	13	f
18	47 RUE BUFFON 	15	11	f
16	3 RUE LOBAU 	20	11	f
8	7 RUE SAINTE ELISABETH 	15	8	f
54	1 RUE ARSENE HOUSSAYE 	15	13	f
61	24	20	16	f
13	BOULEVARD BOURDON 	20	16	f
119	2 RUE LACEPEDE 	15	11	f
66	148 QUAI DE JEMMAPES 	15	11	f
108	11 RUE DE LA BANQUE 	15	9	f
24	6 RUE CENSIER 	15	13	f
55	21 RUE BEAUJON 	20	13	f
42	2 RUE DE BELGRADE 	15	9	f
23	32 RUE DE LA HARPE 	15	11	f
100	61 AVENUE RENE COTY 	20	12	f
118	4 RUE DOLOMIEU 	20	14	f
30	7 RUE HERSCHEL 	15	12	f
19	20 RUE SOMMERARD 	20	14	f
99	112 RUE VERCINGETORIX 	15	12	f
67	2 RUE DE MAZAGRAN 	20	16	f
36	20 RUE SAINT ROMAIN 	15	10	f
174	87 RUE DE SAINT MAUR 	15	15	f
196	2 RUE LOUIS WEISS 	20	20	f
198	6 RUE SARRETTE 	15	15	f
147	1/3 RUE DE ROCHECHOUART 	15	10	f
173	22 RUE JULES VALLES 	15	12	f
204	10 RUE DE CHOISEUL 	15	8	f
223	272 RUE SAINT JACQUES 	20	14	f
161	1 AVENUE DE VERDUN 	15	12	t
128	RUE VELPEAU 	15	11	f
139	16 RUE DE LINCOLN 	20	17	f
133	2 AVENUE OCTAVE CREARD 	20	14	f
215	17 BOULEVARD DU MORLAND 	15	10	f
151	43 RUE LAMARTINE 	20	16	f
162	1 BOULEVARD DE LA CHAPELLE 	15	9	f
157	GARDE DE LEST	20	12	f
182	FACE 4 BOULEVARD DE REUILLY 	15	10	f
221	1 RUE HENRI BARBUSSE 	15	12	f
202	2	20	12	f
124	5 QUAI MALAQAIS 	20	12	f
155	80 RUE DE LAQUEDUC 	15	11	f
148	5 RUE BLEUE 	20	14	f
136	10	20	16	f
237	1 RUE DU CDT RIVIERE 	15	12	f
238	2 RUE BALZAC 	20	16	f
189	FETE DE LOH (BERCY) 	15	11	f
190	81 RUE BOBILLOT 	20	16	f
214	6 RUE SAINT PAUL 	20	16	f
226	20 RUE DE LESTRAPADE 	20	13	f
201	4 RUE DE VENTADOUR 	15	11	t
227	1 RUE THOUIN 	15	13	f
195	30 AVENUE DITALIE 	15	11	f
216	10 RUE DARCOLE 	15	11	f
234	39 AVENUE GEORGE V 	15	11	f
171	37 RUE DE LA ROQUETTE 	15	13	f
130	ECOLE MILITAIRE	20	14	f
209	4 RUE DE CLERY 	15	11	t
185	160 RUE CHARENTON 	15	14	t
127	FACE 28 BOULEVARD RASPAIL 	20	13	f
217	FACE 1 BOULEVARD BOURBON 	20	14	t
181	PYRAMIDE ENTREE PARC FLORAL 	20	11	f
158	FACE 8 PLACE JACQUES BONSERGENT 	15	10	f
228	5 RUE DE CHEVREUSE 	15	10	f
194	02 RUE DUMERIL 	15	6	f
170	1 RUE DE LA PIERRE LEVEE 	15	14	f
176	AVENUE DAUMESNIL 	15	9	f
141	38 RUE VICTOR MASSE 	15	13	f
205	1 RUE DES FILLES SAINT THOMAS 	20	13	f
233	FACE 3 RUE DE CONSTANTINE 	15	11	t
186	23 QUAI PANHARD ET LEVASSOR 	15	13	f
177	42 ALLEE VIVALDI 	15	12	t
132	86 RUE VANEAU 	15	10	f
212	FACE 8 RUE SALOMON DE CAUS 	15	12	f
184	ROUTE DOM PERIGNON 	20	15	f
222	12 RUE DE LEPEE DE BOIS 	15	10	f
150	1 RUE LAFFITE 	15	12	f
179	16 PLACE DE LA NATION SUR TPC 	15	10	f
164	1 RUE DHAUTEVILLE 	15	12	f
203	237 RUE SAINT HONORE 	15	13	f
126	6 RUE DES QUATRE VENTS 	15	14	f
134	1 AVENUE FRANKLIN ROOSEVELT 	15	9	f
135	6 RUE DU COLISEE 	15	12	f
138	22 RUE DE LIEGE 	15	13	f
123	39 RUE DES ECOLES 	15	11	f
235	28 AVENUE GEORGE V 	20	13	f
121	13 RUE JUSSIEU 	20	11	t
224	6 RUE DU FOUARRE 	15	13	f
178	5 AVENUE SAINT MANDE 	20	14	f
137	1 RUE DE ROME 	15	8	t
197	66 RUE DU MOULIN DE LA POINTE 	15	14	f
131	FACE 2 BOULEVARD RASPAIL 	15	10	f
122	1 RUE BUFFON 	15	11	f
187	17 RUE BOBILLOT 	20	14	f
200	56 AVENUE JEAN MOULIN 	15	10	f
163	3 RUE DU CHATEAU DEAU 	20	9	f
180	AVENUE DU POLYGONE 	15	13	f
232	85 AVENUE BOSQUET 	20	13	f
143	55 RUE DU FAUBOURG MONTMARTRE 	15	13	f
220	3 RUE PASCAL 	20	16	f
146	FACE 45 RUE CAUMARTIN 	15	7	f
154	46 RUE LUCIE SAMPAIX 	20	12	f
156	58 RUE DES VINAIGRIERS 	15	12	f
129	BOULEVARD RASPAIL 	15	10	t
142	FACE 27 RUE CLAUZEL 	20	12	f
219	13 RUE ERASME 	15	11	f
140	34 RUE CONDORCET 	15	9	f
160	3 BD STRASBOURG 	20	18	f
236	2 AVENUE MESSINE 	15	9	f
149	24 RUE DE CHORON 	15	13	f
211	4 RUE DES FILLES DU CALVAIRE 	20	11	f
166	24 RUE DE DUNKERQUE 	20	11	f
230	62 RUE DE LILLE 	15	11	f
152	05 RUE DUPERRE 	15	8	f
210	1  3 RUE DAUNOU 	15	11	f
193	2 RUE LEREDDE 	20	15	t
192	15 AVENUE DE LA PORTE DITALIE 	15	11	f
225	8 RUE GEOFFROY SAINT HILAIRE 	15	10	t
165	59 RUE DES PETITES ECURIES 	15	14	f
229	11 RUE DANTON 	20	14	f
231	3 AVENUE BOSQUET 	15	12	f
172	5 RUE DU PASSAGE PHILIPPE AUGUSTE 	20	15	f
207	12 RUE GRENETA 	15	9	f
218	27 RUE GAY LUSSAC 	15	11	f
144	01 RUE LALLIER 	15	9	f
120	9 RUE LE GOFF 	15	12	f
206	71 RUE DE RICHELIEU 	15	11	f
125	1 RUE SAINT BENOIT 	15	11	f
183	43 AVENUE DE SAINT MANDE 	15	9	f
188	150 RUE NATIONALE 	15	11	f
208	20 RUE FAVART 	20	13	f
175	146 BOULEVARD DIDEROT 	20	15	f
199	2 AVENUE DE LA PORTE DE MONTROUGE 	20	16	f
191	55 RUE DUNOIS 	15	9	f
354	31 RUE DARTOIS 	15	15	f
327	41 RUE JUSSIEU 	15	9	f
248	25 RUE DE ROCHECHOUART 	15	12	f
266	1 	15	10	f
252	69 RUE DE PROVENCE 	15	10	f
289	251 AVENUE DAUMESNIL 	20	12	t
256	39 RUE DE DUNKERQUE 	20	14	f
349	30 BIS RUE LAS CASES 	20	15	f
309	5 RUE DE LECHELLE 	15	11	f
265	23 RUE PARADIS 	20	13	t
253	28 RUE DE LA VICTOIRE 	20	18	f
344	63 BOULEVARD DES INVALIDES 	15	11	f
325	FACE 41 AVENUE GEORGES BERNANOS 	20	15	f
280	142 RUE DE LA ROQUETTE 	20	17	f
311	189 RUE SAINT DENIS 	15	9	f
273	80 RUE OBERKAMPF 	15	9	t
328	17 RUE DESCARTES 	20	10	f
335	2 RUE DANTON 	15	10	f
283	11 RUE FAIDHERBE 	20	18	f
315	55 RUE TURBIGO 	15	13	f
274	48 BOULEVARD DE CHARONNE 	20	14	f
261	7 RUE DE METZ 	15	12	f
243	54 RUE DE LA BIENFAISANCE 	15	12	f
306	41 QUAI DE LHORLOGE 	15	10	f
301	2 PLACE ANDRE MALRAUX 	20	14	f
331	174 RUE SAINT JACQUES 	20	16	f
332	03 RUE DES FOSSES SAINT BERNARD 	15	13	f
316	69 BOULEVARD BEAUMARCHAIS 	20	16	f
330	5 RUE DE LA SORBONNE 	15	11	f
269	1 RUE DU GRAND PRIEURE 	15	10	f
353	1 RUE LAMENNAIS 	15	9	t
322	FACE 18 RUE DE LHOTEL DE VILLE 	20	18	f
272	140 AVENUE PARMENTIER 	15	10	f
282	2 RUE LACHARRIERE 	15	9	f
342	7 CITE VANEAU 	15	9	f
288	36	15	10	f
329	2 RUE VALETTE 	15	10	t
304	7 RUE SAINT DENIS 	20	15	f
270	31 RUE LEON FROT 	15	9	f
284	169 AVENUE LEDRU ROLLIN 	15	9	f
251	5 RUE DE BELLEFOND 	15	13	f
305	14 RUE DU PONT NEUF 	15	12	t
240	2 Avenue MARCEAU 	15	9	f
308	20 RUE COQUILLIERE 	15	12	f
333	27 RUE LACEPEDE 	15	10	f
268	44 BD DU TEMPLE 	20	15	f
320	FACE 27 RUE QUINCAMPOIX 	15	12	f
310	02 RUE DANIEL CASANOVA 	20	16	f
275	18 BD DU TEMPLE 	15	12	f
279	FACE 28 RUE JULES FERRY 	15	13	f
260	5 RUE DES PETITES ECURIES 	15	10	f
293	15 BIS RUE HECTOR MALOT 	15	9	f
343	QUAI ANATOLE FRANCE 	20	15	f
296	76 RUE TRAVERSIERE 	15	12	f
286	212 RUE DE CHARENTON 	20	15	f
271	156 RUE DE CHARONNE 	20	13	f
290	74 RUE CROZATIER 	15	10	f
319	10 RUE PERREE 	20	10	f
307	186 RUE SAINT HONORE 	20	14	f
338	26 RUE GUYNEMER 	15	11	f
340	141 BD SAINT GERMAIN 	20	16	f
263	37 RUE SAMBRE ET MEUSE 	15	11	f
291	53 BOULEVARD DE REUILLY 	15	9	f
239	FACE 4 BD MALESHERBES 	15	12	f
334	16 RUE DE MEZIERES 	20	16	f
294	33 AVENUE COURTELINE 	15	6	f
241	65 RUE PIERRE CHARRON 	20	16	t
287	FACE 14 PL. DU BATAILLON DU PACIFIQUE 	15	10	f
262	FACE 50 RUE RENE BOULANGER 	20	16	f
250	19 RUE ROSSINI 	20	14	f
347	1 AVENUE DE LA MOTTE PICQUET 	15	10	f
356	27/31 RUE DE CHATEAUBRIAND 	15	11	f
323	105	15	11	f
276	2 RUE DU FAUBOURG DU TEMPLE 	15	11	f
257	2 RUE DU BUISSON SAINT LOUIS 	15	14	t
350	FACE 3 RUE DU CHAMP DE MARS 	15	9	f
242	116 RUE DE LA BOETIE 	15	9	f
303	6 RUE FRANCAISE 	15	11	f
292	FACE 39 RUE MONTGALLET 	20	13	f
314	42 RUE VIVIENNE 	15	12	f
352	49 RUE DE BERRI 	20	16	f
259	100 QUAI DE JEMMAPES 	20	18	f
324	20 RUE MONGE 	15	10	f
337	7 RUE DU SABOT 	20	12	t
336	13 RUE MICHELET 	15	6	f
313	83 ALLEE PIERRE LAZAREF 	20	14	t
326	9 RUE DE DANTE 	15	10	f
258	FACE 14 RUE HITTORFF 	15	13	f
278	212 BOULEVARD CHARONNE 	15	12	f
339	34 RUE CONDE 	15	10	f
298	20 RUE DES PIROGUES DE BERCY 	20	16	f
345	23 AVENUE DE SEGUR 	15	10	t
318	19 PLACE DE LA REPUBLIQUE 	15	10	f
341	17 RUE LOBINEAU 	15	13	f
246	62 RUE SAINT LAZARE 	15	13	f
317	36 RUE DE SEVIGNE 	15	13	f
312	25 RUE LOUIS LE GRAND 	15	13	f
302	FACE 29 RUE JEAN JACQUES ROUSSEAU 	15	10	f
300	89 BOULEVARD DE LHOPITAL 	15	11	f
295	73 RUE CLAUDE DECAEN 	20	15	f
348	13 RUE SURCOUF 	15	12	f
249	28 RUE J.B.PIGALLE 	15	12	t
247	19 RUE DABBEVILLE 	20	18	f
281	2 RUE SAINT MAUR 	15	10	t
299	76 AVENUE DIVRY 	15	11	f
267	2 RUE ALIBERT 	15	9	f
346	9 BOULEVARD DES INVALIDES 	20	14	f
245	115 rue de provence 	15	7	f
297	89 TER RUE DE CHARENTON 	15	9	t
351	39 RUE DE MIROMESNIL 	15	12	f
77	FACE 67 BOULEVARD DE PICPUS 	15	11	f
355	42 AVENUE GEORGE V 	20	15	f
388	17 RUE JEAN MACE 	20	15	f
85	51 BOULEVARD PORT ROYAL 	20	11	f
395	176 RUE DE LA ROQUETTE 	15	11	f
394	21 RUE PELEE 	20	18	f
368	3	15	9	f
168	FACE 104 BOULEVARD RICHARD LENOIR 	15	10	f
255	12 RUE CITE RIVERIN / ANGLE RUE DU CHATEAU DEAU 	15	9	f
377	9 RUE AMBROISE PARE 	15	12	t
71	FACE 39 BOULEVARD DE LA CHAPELLE 	15	9	f
4	215 RUE SAINT HONORE 	20	14	f
382	1 RUE DE BELFORT 	20	15	f
371	14 RUE GEOFFROY MARIE 	15	11	f
397	49 RUE GABRIEL LAME 	20	19	f
378	110	15	10	f
389	170 RUE DE CHARONNE 	15	9	f
380	137 BOULEVARD MENILMONTANT 	15	11	f
213	2 RUE TIRON 	15	10	f
357	18 PLACE HENRI BERGSON 	15	8	f
362	56 RUE SAINT GEORGES 	15	12	f
358	45 BD BATIGNOLLES 	20	13	f
383	3 RUE DE CHARONNE 	15	11	f
385	1 RUE DES BOULETS 	20	17	t
367	24 RUE DE DOUAI 	20	12	f
372	N° 12	15	12	f
145	2 RUE GODOT DE MAUROY 	20	13	t
396	82 RUE SEDAINE 	15	13	f
62	52 RUE DENGHIEN / ANGLE RUE DU FAUBOURG POISSONIERE 	15	9	f
153	20 RUE DE LA GRANGE BATELIERE 	15	9	t
375	151 AVENUE PARMENTIER 	15	12	f
111	26 RUE SAINT GILLES 	15	10	f
76	45 RUE DES BOULETS 	20	14	f
400	82 AVENUE SAINT MANDE 	20	14	f
167	FACE 140 BOULEVARD RICHARD LENOIR 	15	12	f
376	7 BOULEVARD DE DENAIN 	20	10	f
359	03 RUE DE NAPLES 	15	10	f
254	50 BIS RUE DOUAI 	15	7	f
321	1 RUE SAINT BON 	15	9	t
363	4 RUE DATHENES 	15	11	f
366	38 RUE DE LONDRES 	15	11	f
81	22 AVENUE DE LA PORTE DE VINCENNES 	15	11	t
264	69 RUE DE LA GRANGE AUX BELLES 	15	10	f
169	2 BOULEVARD RICHARD LENOIR 	20	16	t
365	3 RUE BOUDREAU 	15	11	f
387	FACE 21 PLACE DE LA NATION 	15	10	f
379	59 RUE CHABROL 	20	16	f
391	FACE 86 BOULEVARD RICHARD LENOIR 	20	9	f
159	FACE 129 RUE DU FBG SAINT MARTIN 	15	9	f
370	01 RUE DE PARME 	20	18	f
393	124 AVENUE PARMENTIER 	15	10	t
361	2 RUE ALFRED DE VIGNY 	20	14	t
386	9 RUE FROMENT 	15	9	f
369	77 RUE TAITBOUT 	15	10	t
244	75 RUE DE MONCEAU 	20	12	f
398	GARE DE LYON 	15	10	f
390	105 RUE DU CHEMIN VERT 	15	13	f
384	12 BD DES FILLES DU CALVAIRE 	15	8	f
360	42 RUE DE LONDRES 	15	14	f
392	82 AVENUE PARMENTIER 	15	12	f
285	ROUTE DE LARTILLERIE 	15	9	f
364	79 RUE DE LA VICTOIRE 	20	14	f
399	15 RUE VAN GOGH 	15	11	f
374	68 RUE LOUIS BLANC 	15	13	f
277	15 RUE CHARLES DELESCLUZE 	20	14	f
381	81 BIS RUE JP TIMBAUD 	15	11	f
373	4 RUE DES PETITS HOTELS 	20	14	f
\.


--
-- Name: station_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fredo
--

SELECT pg_catalog.setval('station_id_seq', 400, true);


--
-- Data for Name: trajet; Type: TABLE DATA; Schema: public; Owner: fredo
--

COPY trajet (id_trajet, date_trajet, duree, id_users, id_velo, station_dep, station_arr, cout) FROM stdin;
3	2017-04-22	00:27:21	382	5078	244	234	0
4	2017-04-20	00:31:07	764	1183	398	71	0
5	2017-12-04	00:37:23	1032	2079	9	124	0
6	2016-04-23	00:38:29	23	826	138	248	0
7	2016-12-07	00:03:45	1225	2737	211	232	0
9	2017-08-08	00:40:44	850	5936	230	221	0
10	2017-07-17	00:07:35	1007	3424	116	247	0
11	2016-03-07	00:54:04	1504	5103	155	276	2
12	2016-02-10	00:09:11	594	1580	188	75	0
13	2016-04-15	00:43:50	1899	4075	104	275	0
15	2017-10-01	00:51:56	1099	4449	337	43	2
16	2016-02-16	00:21:11	791	2413	127	12	0
17	2016-01-19	00:53:46	530	4463	290	157	2
18	2017-04-06	00:01:16	1711	1905	12	180	0
20	2016-12-28	00:19:06	668	5098	167	148	0
21	2017-12-25	00:28:56	794	4404	199	371	0
22	2016-01-20	00:19:23	13	4590	383	212	0
23	2016-05-24	00:42:35	1067	1089	21	183	0
24	2016-06-25	00:49:47	73	4882	89	101	2
26	2017-12-17	00:02:10	1181	3393	93	169	0
27	2017-10-06	00:53:41	938	1782	367	252	2
28	2017-11-20	00:43:20	315	6549	61	198	0
29	2016-06-23	00:36:00	1399	70	93	313	0
30	2016-01-13	00:44:17	1105	3829	162	211	0
32	2017-01-19	00:25:53	572	2763	243	349	0
33	2016-03-23	00:40:58	1737	5357	380	377	0
34	2016-09-20	00:23:04	565	4421	88	355	0
35	2017-05-08	00:05:52	452	4373	38	169	0
37	2017-04-07	00:27:35	380	694	83	42	0
38	2016-07-02	00:00:57	1338	93	272	9	0
39	2017-06-04	00:30:28	1719	2609	146	238	0
40	2016-12-26	00:04:29	1724	3117	71	201	0
41	2016-09-14	00:50:49	1046	1845	218	336	2
43	2016-11-22	00:29:53	479	2680	266	66	0
44	2017-04-13	00:41:28	625	2020	77	161	0
45	2016-11-26	00:56:41	78	2903	339	245	2
46	2017-12-13	00:00:54	840	4372	67	300	0
47	2016-10-10	00:55:29	1683	3784	299	279	2
49	2017-04-16	00:44:48	1655	3114	98	341	0
50	2017-08-23	00:20:12	1192	5564	266	26	0
51	2016-01-27	00:15:26	1925	3146	221	376	0
52	2016-02-28	00:33:33	273	1607	20	173	0
54	2016-08-14	00:34:22	1947	4849	190	150	0
55	2016-12-06	00:11:45	239	5321	201	147	0
56	2017-12-15	00:11:01	1254	1594	32	364	0
57	2016-09-08	00:30:56	49	376	146	365	0
58	2017-02-15	00:05:55	884	4544	200	43	0
60	2016-10-16	00:32:38	603	5078	220	393	0
61	2016-12-13	00:16:41	1997	946	295	329	0
62	2016-08-16	00:38:30	1125	4528	191	338	0
63	2016-05-26	00:53:37	12	4461	106	178	2
64	2017-02-14	00:41:27	1665	6171	287	252	0
66	2016-01-15	00:43:19	1761	2852	196	26	0
67	2017-05-13	00:46:16	1038	1193	366	119	2
68	2017-12-16	00:45:10	1186	2457	243	25	2
69	2016-04-27	00:52:29	1487	1665	179	71	2
71	2017-05-03	00:23:01	733	557	301	86	0
72	2017-05-15	00:40:07	558	589	131	362	0
73	2016-06-01	00:33:37	1468	3753	37	369	0
74	2016-02-16	00:59:25	1087	5886	379	105	2
75	2016-10-11	00:02:57	1202	4645	227	290	0
77	2017-06-12	00:28:58	1908	771	87	96	0
78	2017-10-06	00:34:19	1152	461	53	253	0
79	2016-01-26	00:43:45	619	1665	24	49	0
80	2017-02-28	00:40:04	521	806	116	335	0
81	2017-08-25	00:58:36	1902	2917	67	275	2
83	2016-05-13	00:56:34	1320	5340	108	212	2
84	2017-12-25	00:10:16	420	6414	260	366	0
85	2016-06-23	00:24:50	756	6337	105	82	0
86	2017-08-19	00:29:44	1062	6143	333	235	0
88	2017-12-15	00:40:46	711	1267	241	317	0
89	2016-05-14	00:49:28	1817	3910	66	399	2
90	2017-04-07	00:52:11	1714	1049	278	400	2
91	2017-06-08	00:48:08	272	5172	139	223	2
92	2016-01-12	00:54:53	1066	2135	147	345	2
94	2016-08-14	00:09:02	1996	4111	294	74	0
95	2016-08-09	00:53:13	538	115	1	392	2
96	2016-12-14	00:39:17	1476	1834	306	387	0
97	2017-03-10	00:19:45	1144	2683	42	335	0
98	2016-10-05	00:21:49	1158	947	144	389	0
100	2016-10-09	00:11:37	870	2273	109	347	0
101	2016-01-22	00:59:52	1083	2	58	190	2
102	2016-03-18	00:45:34	843	5154	231	242	2
103	2017-09-25	00:33:30	906	2585	233	285	0
105	2016-11-26	00:23:00	292	2111	255	17	0
106	2016-08-15	00:03:02	1099	4903	148	103	0
107	2016-02-10	00:55:21	1606	4806	156	359	2
108	2017-08-18	00:46:35	931	404	397	312	2
109	2017-04-01	00:09:37	1816	5427	397	30	0
111	2016-12-15	00:26:22	1284	3054	20	109	0
112	2017-02-19	00:07:35	1642	333	186	97	0
113	2017-02-22	00:40:27	716	5175	267	337	0
114	2016-05-02	00:30:15	818	2349	50	14	0
115	2017-05-26	00:16:26	203	1867	5	162	0
117	2016-03-07	00:16:37	1150	3914	7	249	0
118	2016-10-08	00:29:10	522	1970	27	108	0
119	2017-01-10	00:54:24	196	5757	360	337	2
120	2017-11-05	00:11:46	670	311	328	183	0
122	2016-11-09	00:48:39	1317	5177	62	155	2
123	2016-10-21	00:52:25	461	2496	291	341	2
124	2017-07-06	00:10:32	606	2835	182	78	0
125	2016-03-28	00:21:24	1071	5839	378	392	0
126	2016-05-20	00:41:29	208	3549	260	272	0
128	2016-02-09	00:33:07	899	2034	114	323	0
129	2017-05-04	00:52:28	337	5022	63	272	2
130	2017-10-13	00:03:32	745	5469	9	313	0
131	2016-09-19	00:29:04	484	2295	77	76	0
132	2017-01-23	00:00:09	243	3660	75	339	0
134	2017-08-17	00:56:00	1416	3567	315	127	2
135	2016-02-27	00:42:04	1733	5921	278	151	0
136	2016-04-24	00:04:49	583	4921	137	20	0
139	2016-10-10	00:11:04	1532	5680	400	343	0
140	2016-04-21	00:51:00	952	545	171	221	2
141	2016-08-25	00:46:23	490	5622	171	335	2
142	2016-01-02	00:39:31	1645	3678	113	68	0
143	2016-01-21	00:00:58	1642	2387	61	341	0
145	2016-10-15	00:37:11	1962	5894	321	22	0
146	2017-07-11	00:16:34	340	4044	317	35	0
147	2017-03-01	00:52:15	1855	5197	150	244	2
148	2017-08-25	00:43:09	474	6524	393	51	0
149	2016-03-06	00:59:43	847	3124	354	340	2
151	2016-01-15	00:04:43	734	5797	217	82	0
152	2017-04-17	00:03:22	1433	329	388	184	0
153	2017-11-22	00:20:32	559	5146	157	90	0
154	2016-02-21	00:34:28	870	599	54	103	0
156	2016-02-03	00:29:36	401	3	41	119	0
157	2017-01-04	00:36:22	1685	1734	291	276	0
158	2016-08-08	00:22:57	160	6464	223	312	0
159	2017-06-26	00:07:10	247	5107	97	33	0
160	2016-03-15	00:24:45	179	1912	50	14	0
162	2016-02-08	00:46:41	1934	48	213	43	2
163	2016-09-21	00:23:31	83	4016	254	199	0
164	2016-10-24	00:18:54	1996	1866	129	357	0
165	2016-02-14	00:36:14	166	5191	132	324	0
166	2017-08-19	00:14:04	629	898	31	140	0
168	2016-08-18	00:04:38	1672	5962	254	238	0
169	2017-08-04	00:04:52	1546	772	354	341	0
170	2016-01-24	00:09:58	1057	5860	198	27	0
171	2017-07-13	00:20:32	1622	452	228	70	0
173	2017-09-26	00:21:03	1950	1539	84	279	0
174	2017-04-27	00:29:13	1130	2241	221	385	0
175	2017-10-24	00:59:44	481	6084	200	141	2
176	2016-05-21	00:46:57	712	2126	242	12	2
177	2017-04-25	00:42:20	106	2547	154	279	0
179	2016-05-23	00:01:45	1962	999	83	15	0
180	2017-07-05	00:26:35	1669	6494	367	185	0
181	2016-10-05	00:59:25	92	2229	93	182	2
182	2016-03-21	00:34:52	1899	4198	51	83	0
183	2017-04-18	00:48:50	1210	4074	248	107	2
185	2016-02-18	00:22:13	153	6196	187	112	0
186	2016-02-15	00:07:34	1879	4567	292	135	0
187	2017-01-03	00:26:54	1363	3297	279	301	0
188	2017-06-03	00:55:55	1783	5869	317	249	2
190	2016-11-10	00:33:15	431	6047	28	167	0
191	2016-01-28	00:49:17	1865	2837	168	174	2
192	2017-03-01	00:01:00	10	4901	180	248	0
193	2016-03-25	00:55:51	522	524	293	178	2
194	2017-02-18	00:20:16	1225	3220	375	174	0
196	2016-05-25	00:48:44	1301	205	161	4	2
197	2017-01-05	00:46:09	1326	4613	383	331	2
198	2016-10-28	00:35:03	728	5768	132	29	0
199	2016-08-17	00:02:42	1663	2780	146	195	0
200	2016-04-09	00:14:04	12	6088	366	381	0
202	2016-02-16	00:59:54	179	3277	376	8	2
203	2016-09-21	00:52:09	1651	3089	377	331	2
204	2016-10-14	00:08:37	1147	5487	102	374	0
205	2017-02-01	00:34:28	290	736	121	271	0
207	2016-02-11	00:54:46	319	6009	377	212	2
208	2017-04-28	00:23:20	985	3045	125	140	0
209	2016-07-03	00:01:12	1262	2007	358	340	0
210	2016-03-22	00:45:42	1365	6213	38	19	2
211	2016-04-27	00:16:33	1621	6397	102	38	0
213	2017-06-16	00:23:07	1091	4665	19	302	0
214	2016-05-04	00:11:06	392	5969	81	56	0
215	2017-06-26	00:24:52	1400	4256	2	25	0
216	2017-04-14	00:40:17	1070	506	266	294	0
217	2017-07-06	00:00:19	167	3469	293	29	0
219	2016-12-16	00:09:08	1532	3986	167	334	0
220	2016-10-17	00:47:40	1411	2217	360	351	2
221	2017-05-03	00:37:07	71	2708	106	127	0
222	2017-06-14	00:13:05	1735	6266	49	305	0
224	2017-02-01	00:03:37	327	908	5	400	0
225	2017-07-05	00:50:05	58	5888	251	316	2
226	2016-02-27	00:40:09	404	2827	262	53	0
227	2016-04-09	00:14:53	1153	1111	366	228	0
228	2017-10-08	00:35:58	587	5735	245	344	0
230	2017-12-23	00:44:33	360	2788	102	1	0
231	2017-02-10	00:37:50	1372	383	189	160	0
232	2016-09-28	00:16:34	587	6357	244	100	0
233	2016-01-15	00:11:39	1076	1725	34	308	0
234	2017-03-24	00:36:07	1341	3245	104	259	0
236	2016-07-06	00:39:42	370	6095	338	222	0
237	2016-08-06	00:27:45	67	6552	106	329	0
238	2017-07-27	00:44:00	1461	4620	274	46	0
239	2017-09-06	00:10:56	329	3643	300	185	0
241	2017-06-27	00:00:33	1243	4321	56	194	0
242	2016-10-26	00:40:23	816	3988	141	103	0
243	2017-08-22	00:48:24	478	1134	318	357	2
244	2016-08-20	00:22:28	630	5779	192	132	0
245	2017-11-12	00:44:26	808	2128	400	12	0
247	2017-07-08	00:25:30	154	3852	201	399	0
248	2016-03-24	00:46:59	1481	5703	85	14	2
249	2016-03-25	00:49:53	1423	753	191	220	2
250	2017-06-24	00:53:17	479	5739	291	202	2
251	2017-05-15	00:11:32	6	1653	266	308	0
253	2017-02-10	00:48:54	1641	4650	187	196	2
254	2017-08-08	00:10:03	1633	3737	234	189	0
255	2016-11-14	00:46:30	408	241	254	112	2
256	2017-10-13	00:27:23	832	3350	329	145	0
258	2017-08-17	00:43:28	18	3995	312	214	0
259	2017-01-07	00:46:36	570	3348	243	394	2
260	2017-11-22	00:31:24	606	5163	11	306	0
261	2016-11-12	00:52:12	1902	4569	310	200	2
262	2016-11-24	00:07:17	1212	340	298	325	0
264	2017-12-16	00:46:04	1837	4271	40	139	2
265	2017-04-10	00:18:24	1729	3845	183	354	0
266	2017-04-08	00:19:55	288	3191	303	376	0
267	2017-11-24	00:52:32	244	1380	120	380	2
268	2016-05-15	00:36:56	1558	6458	74	127	0
270	2016-12-03	00:36:33	1722	6263	318	228	0
271	2017-05-26	00:48:16	694	3604	59	290	2
272	2017-01-14	00:44:26	1076	1982	394	16	0
275	2016-06-21	00:05:48	1797	3059	394	231	0
276	2016-02-14	00:44:34	1089	2024	41	164	0
277	2016-06-08	00:52:36	1286	1466	241	251	2
278	2017-04-03	00:58:34	1216	4949	184	169	2
279	2016-10-07	00:39:06	1036	4984	340	190	0
281	2017-12-25	00:36:50	1719	5518	17	22	0
282	2017-12-18	00:57:38	1400	5464	393	106	2
283	2016-06-20	00:30:16	1674	5804	90	385	0
284	2016-03-17	00:18:45	1556	4325	75	290	0
285	2017-06-10	00:05:26	1209	5017	33	360	0
287	2016-01-07	00:51:35	1642	4285	248	346	2
288	2017-09-15	00:03:23	1769	2111	217	131	0
289	2017-11-17	00:58:07	335	5726	142	306	2
290	2017-05-11	00:19:46	1531	6521	7	13	0
292	2016-11-16	00:41:18	442	4430	316	233	0
293	2017-02-07	00:47:59	1169	6253	306	171	2
294	2017-05-27	00:40:21	1303	720	159	382	0
295	2017-08-01	00:21:03	1117	3885	221	4	0
296	2016-04-23	00:13:01	1847	6132	235	275	0
298	2017-12-21	00:50:54	1263	5316	255	220	2
299	2017-02-16	00:36:22	1849	2216	29	341	0
300	2017-08-14	00:00:48	1148	209	159	237	0
301	2017-06-07	00:09:57	681	4910	263	173	0
302	2017-08-19	00:51:49	152	416	295	8	2
304	2016-04-06	00:14:22	658	1636	383	131	0
305	2017-10-13	00:36:33	538	5932	166	318	0
306	2016-09-15	00:05:04	1763	169	392	333	0
307	2017-12-13	00:55:47	93	5836	46	304	2
309	2016-05-16	00:36:50	211	1820	233	79	0
310	2016-03-14	00:34:30	336	498	360	91	0
311	2017-02-28	00:32:57	1122	4651	169	379	0
312	2016-08-14	00:29:25	1271	2329	81	399	0
313	2017-03-25	00:09:28	1523	4140	367	80	0
315	2017-06-07	00:20:31	877	2057	268	283	0
316	2016-06-08	00:46:09	1960	6054	376	129	2
317	2017-07-02	00:41:46	1260	6216	160	109	0
318	2016-06-24	00:42:19	989	5308	344	367	0
319	2016-08-03	00:09:15	413	3311	341	391	0
321	2017-10-19	00:58:29	1533	1442	306	382	2
322	2016-09-09	00:21:09	1268	2006	168	205	0
323	2017-05-28	00:40:02	648	797	356	289	0
324	2017-11-23	00:23:49	690	4374	394	240	0
326	2016-10-25	00:00:26	1533	2220	152	370	0
327	2016-07-22	00:57:41	1232	1332	220	318	2
328	2016-08-12	00:58:05	286	6584	146	272	2
329	2016-03-04	00:33:08	1326	2764	212	291	0
330	2016-04-11	00:47:16	1789	4404	383	209	2
332	2017-04-06	00:53:09	1606	3955	168	301	2
333	2017-07-01	00:01:53	1157	1897	236	127	0
334	2017-05-01	00:38:10	1922	1680	304	368	0
335	2016-01-26	00:05:09	1273	2376	253	336	0
336	2016-07-06	00:51:11	86	5279	381	44	2
338	2017-01-28	00:59:26	565	4787	245	327	2
339	2017-05-10	00:07:56	730	6255	350	195	0
340	2017-11-13	00:14:29	1738	6583	282	131	0
341	2016-07-25	00:43:55	1345	5409	269	268	0
343	2016-08-09	00:36:34	1392	1678	138	200	0
344	2016-10-26	00:38:42	418	1221	138	144	0
345	2016-07-26	00:11:53	311	2553	125	285	0
346	2016-05-07	00:00:32	1110	162	292	30	0
347	2016-07-16	00:04:17	786	1267	291	212	0
349	2016-12-16	00:42:42	133	1132	203	73	0
350	2017-10-14	00:18:17	215	4917	262	190	0
351	2016-11-09	00:16:06	1621	429	279	218	0
352	2017-02-11	00:46:41	714	55	25	342	2
353	2016-07-07	00:54:56	185	1715	214	138	2
355	2016-09-11	00:06:25	1475	5976	104	89	0
356	2016-07-10	00:06:56	266	1224	377	252	0
357	2016-11-28	00:10:34	1826	2319	394	306	0
358	2016-11-02	00:02:56	531	3171	248	243	0
360	2017-05-27	00:20:35	294	6313	114	230	0
361	2016-10-11	00:00:27	1574	5729	51	349	0
362	2017-03-22	00:34:42	1904	2676	80	173	0
363	2016-04-22	00:37:47	479	4251	291	205	0
364	2016-12-19	00:04:59	59	1332	167	146	0
366	2017-02-27	00:44:01	765	4585	271	126	0
367	2016-06-07	00:32:58	1879	2023	343	302	0
368	2017-05-05	00:42:35	1076	968	375	190	0
369	2017-05-13	00:27:44	965	6418	80	275	0
370	2016-02-27	00:13:52	907	6247	193	112	0
372	2016-07-09	00:13:06	1232	5610	298	27	0
373	2017-01-01	00:29:55	212	844	400	278	0
374	2017-09-08	00:15:30	253	774	165	390	0
375	2017-03-25	00:17:46	1225	4189	108	299	0
377	2017-05-27	00:00:54	119	6647	15	130	0
378	2017-03-22	00:38:09	1556	1231	274	139	0
379	2017-03-02	00:18:42	989	4075	3	353	0
380	2016-04-19	00:29:27	345	5377	155	124	0
381	2016-05-19	00:12:55	842	1842	263	62	0
383	2017-07-13	00:27:33	1782	3440	323	151	0
384	2017-07-22	00:12:51	458	2675	130	95	0
385	2017-02-04	00:20:52	1429	4087	112	315	0
386	2017-07-20	00:14:47	114	6273	285	200	0
387	2017-05-24	00:31:12	1922	36	174	233	0
389	2017-10-06	00:30:29	1960	1922	271	270	0
390	2016-06-13	00:02:30	1981	1343	244	182	0
391	2017-06-10	00:23:21	1969	4881	393	200	0
392	2016-01-14	00:20:21	99	5091	222	169	0
394	2016-06-09	00:41:59	251	2222	344	276	0
395	2017-03-09	00:30:17	201	1880	334	259	0
396	2017-10-13	00:41:59	972	2619	321	273	0
397	2017-06-24	00:17:55	50	5346	228	134	0
398	2017-10-01	00:42:01	1260	3409	310	71	0
400	2017-07-05	00:56:15	1903	812	324	47	2
401	2017-04-03	00:38:32	946	3565	398	49	0
402	2017-11-13	00:19:59	427	109	161	333	0
403	2016-07-06	00:54:59	1493	6303	3	249	2
404	2016-08-08	00:03:21	956	452	186	77	0
406	2017-11-03	00:08:26	82	1860	139	232	0
407	2017-07-21	00:13:08	515	2522	355	103	0
408	2016-12-04	00:55:34	965	2895	103	39	2
411	2016-11-06	00:47:26	1683	2	336	181	2
412	2016-11-27	00:53:26	15	4651	378	130	2
413	2016-03-07	00:01:48	1660	3965	263	273	0
414	2016-04-18	00:18:43	694	2813	145	217	0
415	2017-10-11	00:47:44	1652	4152	45	338	2
417	2017-08-07	00:45:36	1399	3401	147	356	2
418	2017-11-02	00:09:41	255	4631	186	267	0
419	2016-03-12	00:27:56	809	3294	378	151	0
420	2016-02-24	00:04:52	140	4717	173	369	0
421	2017-01-26	00:15:14	962	373	185	197	0
423	2017-02-28	00:48:00	454	1902	272	256	2
424	2017-07-27	00:41:25	1161	1704	202	126	0
425	2016-02-12	00:14:18	1980	5036	200	186	0
426	2016-12-14	00:26:54	418	2723	187	200	0
428	2017-04-24	00:20:01	1231	2101	281	14	0
429	2017-09-24	00:24:02	748	1079	64	356	0
430	2017-11-18	00:07:24	1843	3656	58	191	0
431	2017-01-21	00:09:40	1152	4617	340	329	0
432	2016-07-07	00:36:48	29	1450	149	323	0
434	2016-09-24	00:29:10	1335	190	88	288	0
435	2016-04-17	00:17:42	539	6257	336	357	0
436	2017-03-16	00:37:43	755	2284	253	333	0
437	2016-04-25	00:16:53	1244	1894	373	144	0
438	2017-10-23	00:09:01	513	3453	395	33	0
440	2016-05-26	00:54:37	548	4686	50	341	2
441	2016-02-12	00:43:16	268	4534	175	177	0
442	2017-09-16	00:46:25	467	5432	356	189	2
443	2017-11-20	00:49:53	887	3639	255	165	2
445	2017-08-28	00:16:09	658	6582	272	198	0
446	2016-06-16	00:57:55	372	432	8	334	2
447	2016-03-16	00:08:26	1106	3456	376	400	0
448	2017-04-25	00:49:12	1517	5938	201	246	2
449	2017-01-19	00:01:41	257	4549	18	41	0
451	2016-05-03	00:50:19	555	1202	193	373	2
452	2017-10-23	00:46:25	1261	1935	394	146	2
453	2017-06-19	00:25:00	1875	2949	252	282	0
454	2016-01-25	00:01:52	859	2692	81	321	0
455	2016-06-18	00:47:56	1865	6655	209	175	2
457	2016-10-17	00:58:05	852	4549	389	348	2
458	2016-08-15	00:01:40	1261	3488	175	57	0
459	2017-02-17	00:16:42	912	1072	72	365	0
460	2017-09-19	00:07:22	1079	4347	76	70	0
462	2017-06-20	00:23:14	598	726	90	208	0
463	2016-06-12	00:54:21	129	3539	63	246	2
464	2016-10-16	00:16:03	108	4870	92	341	0
465	2016-04-04	00:55:27	260	3163	329	172	2
466	2016-05-03	00:32:12	1503	2538	191	122	0
468	2016-11-18	00:52:07	1107	2889	145	72	2
469	2017-01-02	00:31:12	154	4379	153	387	0
470	2017-03-23	00:38:08	1673	2805	70	115	0
471	2017-02-13	00:00:17	462	4200	346	96	0
472	2016-08-22	00:25:01	1921	6253	314	110	0
474	2017-08-12	00:45:38	111	2469	186	185	2
475	2017-12-03	00:54:29	463	2955	309	106	2
476	2017-01-21	00:28:31	326	5257	351	324	0
477	2017-05-03	00:58:37	183	3353	161	19	2
479	2017-03-06	00:48:17	441	1184	147	233	2
480	2016-05-22	00:36:08	670	5327	396	313	0
481	2017-01-05	00:48:52	1577	5080	175	194	2
482	2017-05-22	00:36:54	890	3850	82	367	0
483	2017-01-13	00:18:47	551	5422	56	147	0
485	2016-03-22	00:03:43	590	5511	67	88	0
486	2016-07-25	00:36:22	39	1498	194	1	0
487	2016-11-01	00:48:05	1306	3497	202	57	2
488	2016-01-05	00:22:49	1527	3791	393	143	0
489	2017-11-24	00:20:17	265	1585	109	141	0
491	2016-12-18	00:21:17	62	1658	15	195	0
492	2017-10-18	00:36:23	1985	4984	176	374	0
493	2017-01-28	00:30:28	1557	3822	167	391	0
494	2017-02-19	00:29:23	272	1399	91	238	0
496	2017-12-01	00:44:20	1094	5313	143	369	0
497	2016-04-26	00:31:45	310	1427	106	17	0
498	2017-11-28	00:24:22	1397	4899	398	186	0
499	2016-05-24	00:54:58	303	5084	191	158	2
500	2017-12-25	00:14:02	1793	6074	394	354	0
502	2017-04-09	00:22:17	1818	3693	250	279	0
503	2016-10-08	00:14:26	914	4334	25	215	0
504	2017-03-05	00:18:06	1875	2699	347	286	0
505	2017-06-10	00:41:00	51	6085	94	214	0
506	2017-02-10	00:51:37	768	471	208	337	2
508	2016-07-13	00:57:38	905	4653	383	341	2
509	2016-04-18	00:08:48	175	1497	358	154	0
510	2017-08-10	00:31:37	115	248	57	398	0
511	2017-08-16	00:57:49	915	5919	33	271	2
513	2017-12-18	00:38:53	1235	4432	89	340	0
514	2016-06-03	00:37:05	718	339	14	143	0
515	2016-06-27	00:46:52	980	1006	339	346	2
516	2017-02-23	00:35:20	1783	3854	311	185	0
517	2016-01-16	00:32:16	905	599	162	256	0
519	2016-04-19	00:01:24	316	3013	51	338	0
520	2017-06-11	00:59:41	1007	1980	184	139	2
521	2016-10-15	00:24:52	1325	2036	150	182	0
522	2017-02-08	00:01:38	331	2662	387	13	0
523	2016-02-24	00:03:29	903	5559	163	202	0
525	2016-05-14	00:43:15	1956	3383	20	400	0
526	2016-09-01	00:00:04	952	1789	183	3	0
527	2016-05-13	00:29:43	718	243	48	34	0
528	2016-02-09	00:00:19	1822	6592	352	135	0
530	2016-04-21	00:11:14	1843	1257	399	351	0
531	2016-07-26	00:43:32	659	3372	54	214	0
532	2017-07-08	00:55:36	139	3061	398	297	2
533	2016-06-01	00:25:30	1329	5053	293	315	0
534	2016-05-07	00:44:04	197	4067	99	103	0
536	2016-03-23	00:32:30	631	1953	154	260	0
537	2016-02-28	00:57:49	608	5328	36	346	2
538	2017-03-16	00:37:17	1447	3241	354	371	0
539	2016-01-03	00:44:33	524	5065	211	9	0
540	2016-08-09	00:48:05	446	3661	154	270	2
542	2016-07-22	00:58:06	774	619	361	103	2
543	2017-12-23	00:41:35	1260	1568	333	124	0
544	2017-05-18	00:41:02	1188	3305	127	146	0
547	2016-05-16	00:37:20	713	2950	395	228	0
548	2016-02-05	00:53:38	112	3476	66	217	2
549	2017-05-02	00:21:36	258	37	205	12	0
550	2016-11-02	00:27:05	1995	2849	172	150	0
551	2017-07-23	00:54:08	582	6358	336	259	2
553	2016-04-17	00:49:04	148	2212	213	397	2
554	2017-06-20	00:41:21	496	1841	345	292	0
555	2017-11-05	00:50:29	1170	5370	234	294	2
556	2017-05-23	00:32:25	1231	4002	263	375	0
557	2016-09-15	00:43:32	1682	1299	105	311	0
559	2017-12-16	00:07:22	99	561	50	84	0
560	2017-07-27	00:08:31	1128	283	19	122	0
561	2016-03-04	00:27:35	95	4973	29	278	0
562	2016-03-22	00:14:14	701	2393	376	303	0
564	2016-05-13	00:35:19	6	5123	145	175	0
565	2017-02-16	00:13:00	1036	6031	112	295	0
566	2016-11-17	00:18:41	1040	3669	355	104	0
567	2017-03-24	00:18:37	1823	1992	247	250	0
568	2016-12-05	00:15:24	500	5441	156	85	0
570	2016-12-04	00:40:00	1718	3615	116	35	0
571	2017-02-06	00:19:23	452	5087	138	209	0
572	2017-11-01	00:56:47	168	6558	53	389	2
573	2017-01-18	00:45:37	44	278	13	145	2
574	2017-03-22	00:25:21	692	4426	296	260	0
576	2016-06-04	00:46:01	1431	5875	212	191	2
577	2017-11-03	00:34:59	625	4288	139	89	0
578	2016-05-17	00:21:11	31	5255	169	34	0
579	2017-11-07	00:01:07	265	3257	180	389	0
581	2017-07-10	00:16:24	1934	1878	230	257	0
582	2017-12-12	00:13:44	169	1951	349	390	0
583	2017-10-13	00:19:03	1996	4701	211	176	0
584	2016-08-07	00:50:15	1932	3030	46	25	2
585	2016-08-28	00:20:19	1666	6057	174	229	0
587	2017-05-23	00:18:05	496	3743	246	218	0
588	2016-02-04	00:01:18	1244	5186	148	271	0
589	2017-08-03	00:45:53	563	1742	106	64	2
590	2017-02-12	00:15:32	898	2983	272	179	0
591	2016-02-21	00:06:52	1790	1188	241	35	0
593	2016-02-09	00:52:18	1070	4915	101	382	2
594	2017-03-27	00:54:04	1432	918	236	11	2
595	2016-12-11	00:47:00	1724	1094	189	154	2
596	2016-04-14	00:05:05	1702	6377	102	394	0
598	2016-05-24	00:14:47	1549	1835	47	300	0
599	2017-03-22	00:03:50	1921	741	126	111	0
600	2016-01-22	00:55:30	1163	893	214	340	2
601	2017-08-10	00:24:44	1405	487	257	291	0
602	2016-07-20	00:29:36	1379	6264	363	247	0
604	2017-03-17	00:22:16	1132	5274	20	12	0
605	2017-03-06	00:55:44	936	3377	215	376	2
606	2017-08-05	00:32:44	1363	2594	45	171	0
607	2016-02-02	00:01:32	170	4793	303	298	0
608	2016-08-05	00:17:08	122	3382	2	376	0
610	2017-02-03	00:04:27	710	4711	384	93	0
611	2016-12-14	00:16:14	1448	1876	113	290	0
612	2016-02-15	00:26:39	100	2473	333	91	0
613	2017-06-04	00:17:43	785	2586	162	226	0
615	2016-01-12	00:18:47	402	1299	18	222	0
616	2017-01-22	00:40:09	1353	69	124	211	0
617	2016-07-10	00:53:24	1036	1825	99	242	2
618	2016-05-05	00:04:55	1671	3162	303	16	0
619	2016-06-21	00:59:10	631	3236	27	90	2
621	2016-06-09	00:45:58	188	5652	347	159	2
622	2017-03-25	00:43:31	508	6008	36	166	0
623	2017-09-21	00:59:54	673	1326	48	307	2
624	2016-05-12	00:11:49	1012	6226	287	249	0
625	2016-04-06	00:55:49	1048	3524	345	292	2
627	2017-08-09	00:38:46	793	1269	308	78	0
628	2016-06-05	00:45:22	1359	5499	338	92	2
629	2016-11-08	00:30:00	1858	2751	277	131	0
630	2016-03-06	00:32:22	1314	4901	283	73	0
632	2016-03-11	00:00:30	145	3535	298	261	0
633	2016-10-18	00:00:13	726	5305	161	224	0
634	2017-01-17	00:59:39	1778	2685	74	321	2
635	2016-10-11	00:26:54	1738	6047	74	67	0
636	2016-01-17	00:28:32	638	4442	106	105	0
638	2016-02-12	00:58:44	165	546	314	191	2
639	2016-12-27	00:41:12	1527	1521	221	20	0
640	2016-09-12	00:58:02	1793	2225	300	368	2
641	2016-08-27	00:45:49	343	6128	46	350	2
642	2016-02-23	00:49:33	1931	1961	40	388	2
644	2016-02-11	00:09:30	24	6395	182	116	0
645	2016-12-19	00:42:27	94	1744	373	85	0
646	2017-06-27	00:35:56	1535	827	398	180	0
647	2016-06-25	00:45:14	1435	3981	400	319	2
649	2017-01-16	00:36:23	340	5851	186	393	0
650	2016-12-26	00:10:06	626	791	344	93	0
651	2016-03-03	00:25:32	378	451	31	156	0
652	2016-11-25	00:14:00	164	1135	209	5	0
653	2016-03-01	00:23:12	1184	6126	128	359	0
655	2017-04-15	00:14:26	1345	3323	323	296	0
656	2017-06-18	00:26:35	461	4333	161	268	0
657	2016-09-13	00:20:14	291	2437	170	349	0
658	2017-06-11	00:33:58	1423	2616	198	302	0
659	2017-09-24	00:15:57	826	1866	318	132	0
661	2016-03-05	00:40:46	550	4404	55	220	0
662	2017-06-17	00:46:11	753	5912	299	49	2
663	2017-07-13	00:22:47	1245	164	351	290	0
664	2017-01-11	00:45:49	827	5473	285	365	2
666	2016-06-14	00:30:59	1397	6095	261	198	0
667	2017-12-08	00:46:31	1185	5065	60	262	2
668	2016-06-21	00:02:00	1458	4994	363	254	0
669	2017-06-12	00:17:38	1122	555	366	194	0
670	2017-06-17	00:25:39	63	5256	389	3	0
672	2017-06-10	00:45:01	785	6288	166	171	2
673	2017-07-15	00:24:04	1843	5286	75	237	0
674	2016-11-24	00:48:39	802	6328	134	362	2
675	2016-11-14	00:19:58	420	1512	26	335	0
676	2017-02-05	00:24:49	3	5392	27	180	0
678	2016-06-27	00:51:09	63	6314	149	346	2
679	2016-07-15	00:52:42	1437	1974	17	216	2
680	2016-11-07	00:32:32	1457	497	212	128	0
683	2016-04-05	00:04:57	637	4816	180	337	0
684	2017-12-28	00:18:21	1688	617	121	330	0
685	2016-07-28	00:44:43	1300	5820	141	317	0
686	2016-08-15	00:36:18	1261	4989	386	21	0
687	2016-03-04	00:14:49	1826	4180	110	358	0
689	2017-11-08	00:53:15	146	106	14	396	2
690	2016-08-03	00:29:59	1667	113	36	348	0
691	2016-06-20	00:54:14	997	1230	350	127	2
692	2017-11-18	00:33:17	1465	310	301	376	0
693	2017-12-06	00:57:43	58	7	78	283	2
695	2016-11-10	00:03:40	1071	5177	49	377	0
696	2016-04-03	00:48:31	1963	5711	228	303	2
697	2017-07-03	00:06:01	653	751	231	385	0
698	2016-02-21	00:46:34	499	5614	112	73	2
700	2017-07-17	00:10:23	91	4231	300	144	0
701	2017-03-25	00:57:36	1127	2965	115	348	2
702	2016-08-23	00:22:01	1701	5586	336	206	0
703	2016-04-10	00:14:03	1842	2623	57	81	0
704	2017-02-14	00:22:47	348	2562	211	350	0
706	2016-04-03	00:06:40	1952	4091	189	293	0
707	2016-08-14	00:11:35	154	4840	13	246	0
708	2016-03-23	00:56:49	1977	4375	128	174	2
709	2016-06-25	00:17:36	536	4803	272	268	0
710	2017-01-26	00:24:46	376	2868	54	331	0
712	2017-08-06	00:31:57	885	5816	229	283	0
713	2016-07-24	00:15:28	353	5616	381	18	0
714	2017-01-08	00:35:20	777	2918	119	56	0
715	2017-05-07	00:53:15	405	3399	94	175	2
717	2017-10-21	00:43:39	1260	4902	294	197	0
718	2017-08-17	00:57:15	1629	1975	307	25	2
719	2017-07-04	00:44:50	1960	281	389	112	0
720	2016-09-25	00:05:28	1369	156	285	367	0
721	2016-11-16	00:16:59	1016	1519	360	85	0
723	2017-08-14	00:31:01	1822	922	313	388	0
724	2016-08-26	00:04:12	372	6576	36	266	0
725	2017-08-02	00:25:32	67	3208	206	149	0
726	2017-01-05	00:40:06	1360	2949	197	119	0
727	2017-08-11	00:39:13	1232	6392	309	174	0
729	2017-06-17	00:08:07	1188	6054	197	332	0
730	2016-09-28	00:03:51	1773	6150	144	239	0
731	2017-02-14	00:59:16	1993	3056	230	243	2
732	2017-11-09	00:43:50	445	891	129	211	0
734	2017-03-26	00:20:21	1451	6308	191	273	0
735	2016-01-17	00:44:46	1336	3213	381	268	0
736	2017-11-25	00:57:04	1288	3015	57	285	2
737	2017-10-20	00:52:17	1298	4273	12	184	2
738	2017-05-28	00:58:39	408	4088	2	54	2
740	2017-04-07	00:36:04	1661	2917	202	341	0
741	2016-06-12	00:11:06	1661	420	80	57	0
742	2016-10-20	00:57:43	14	6088	69	346	2
743	2017-03-02	00:28:16	519	6583	205	211	0
744	2017-03-23	00:24:26	1054	6444	48	158	0
746	2017-03-09	00:34:19	670	3902	87	175	0
747	2016-01-22	00:42:10	756	3708	83	346	0
748	2017-09-13	00:44:15	1490	6103	372	301	0
749	2016-05-17	00:45:43	955	1232	174	51	2
751	2016-11-22	00:59:19	934	1024	348	301	2
752	2016-05-23	00:41:07	724	5313	320	39	0
753	2016-12-21	00:27:18	1259	5835	29	348	0
754	2016-07-02	00:06:52	608	3803	6	276	0
755	2017-07-24	00:06:44	327	4626	291	167	0
757	2017-05-17	00:53:12	1573	5621	203	189	2
758	2016-05-24	00:37:28	1048	5406	72	12	0
759	2017-03-03	00:09:17	1506	5183	173	117	0
760	2016-08-21	00:00:02	834	3624	138	3	0
761	2016-06-24	00:59:45	1113	5415	43	159	2
763	2016-10-26	00:33:52	755	5880	7	133	0
764	2017-06-25	00:06:47	1485	3355	189	267	0
765	2017-01-25	00:00:14	1030	3417	193	305	0
766	2017-07-11	00:17:24	325	2513	40	385	0
768	2017-10-10	00:22:46	552	5191	299	155	0
769	2016-05-17	00:29:35	1676	5345	74	237	0
770	2017-09-11	00:00:38	894	4556	151	132	0
771	2016-07-28	00:50:32	22	285	358	284	2
772	2017-08-16	00:17:08	1604	2196	189	334	0
774	2016-06-11	00:07:55	229	970	133	10	0
775	2017-02-21	00:25:30	359	207	16	12	0
776	2016-06-17	00:33:20	448	6466	343	158	0
777	2017-08-04	00:41:57	555	3962	117	304	0
778	2017-05-01	00:57:34	990	6570	160	311	2
780	2017-05-19	00:41:08	705	5391	189	179	0
781	2016-02-23	00:44:36	597	874	91	10	0
782	2017-05-04	00:04:49	798	1195	237	126	0
783	2017-07-20	00:35:59	1265	300	200	382	0
785	2017-03-19	00:48:21	1070	3861	336	70	2
786	2017-11-09	00:06:20	1825	6523	210	135	0
787	2016-11-24	00:55:09	134	972	400	187	2
788	2016-02-01	00:07:53	646	503	251	266	0
789	2016-01-28	00:36:25	323	1611	184	105	0
791	2016-07-03	00:53:58	1450	2658	191	226	2
792	2016-09-07	00:53:36	480	1008	17	253	2
793	2016-10-09	00:05:59	526	1887	188	13	0
794	2017-03-13	00:29:38	1931	263	108	179	0
795	2016-07-24	00:21:15	1531	4959	303	346	0
797	2016-09-24	00:45:52	1416	2241	243	51	2
798	2016-08-09	00:57:29	263	6590	285	195	2
799	2017-10-28	00:46:58	359	1814	137	367	2
800	2016-02-19	00:17:15	1248	3732	77	284	0
802	2016-10-28	00:32:36	695	1410	50	353	0
803	2016-08-06	00:02:35	517	1742	131	291	0
804	2017-01-25	00:02:33	1409	74	252	94	0
805	2016-04-06	00:57:41	506	5852	104	185	2
806	2017-12-25	00:06:26	1761	5602	235	305	0
808	2016-02-12	00:08:15	1583	4108	288	158	0
809	2016-02-26	00:28:11	1914	5089	303	225	0
810	2017-09-24	00:54:01	46	1101	40	115	2
811	2017-01-11	00:59:52	1229	766	104	309	2
812	2016-10-23	00:39:02	1787	5854	180	220	0
814	2016-07-08	00:38:15	1399	3046	206	312	0
815	2016-07-19	00:34:05	237	1557	268	8	0
816	2016-06-26	00:39:19	41	3076	245	246	0
819	2017-11-09	00:06:52	718	655	339	388	0
820	2016-05-06	00:09:03	1895	3649	178	400	0
821	2017-10-10	00:14:48	737	1368	43	155	0
822	2016-06-05	00:24:52	637	2628	94	159	0
823	2016-08-26	00:29:06	940	1132	398	377	0
825	2016-11-01	00:07:38	537	3891	236	346	0
826	2017-10-10	00:14:49	294	3893	353	153	0
827	2017-03-28	00:00:32	1717	4904	19	70	0
828	2016-09-05	00:32:32	1479	2922	76	42	0
829	2017-06-07	00:05:26	283	3460	135	324	0
831	2017-06-12	00:39:51	1993	939	265	191	0
832	2016-12-12	00:37:16	1316	4452	307	20	0
833	2016-09-16	00:30:35	299	564	290	53	0
834	2016-02-18	00:38:37	1527	5598	6	386	0
836	2017-03-16	00:35:29	1561	1242	12	231	0
837	2016-02-02	00:39:35	1674	5087	56	388	0
838	2016-09-13	00:49:25	1094	1843	219	66	2
839	2017-01-13	00:00:12	1220	2383	51	123	0
840	2017-06-26	00:18:51	1007	4320	237	355	0
842	2017-09-01	00:07:57	657	1084	98	391	0
843	2016-01-26	00:52:32	14	3133	49	237	2
844	2016-12-08	00:27:29	1301	2590	300	60	0
845	2017-09-26	00:50:28	701	1713	240	54	2
846	2017-08-27	00:18:10	598	5709	194	81	0
848	2016-01-07	00:02:24	1931	1686	303	182	0
849	2016-10-14	00:30:23	1155	4101	82	48	0
850	2016-12-03	00:31:38	1757	1650	211	14	0
851	2016-09-11	00:27:16	1108	4996	369	7	0
853	2016-02-28	00:55:16	1316	3710	342	24	2
854	2017-03-10	00:45:26	162	2678	376	85	2
855	2016-02-17	00:50:11	1932	4223	46	78	2
856	2017-06-19	00:10:21	662	1857	141	35	0
857	2016-08-02	00:45:28	300	4929	160	330	2
859	2016-12-19	00:11:19	965	782	310	172	0
860	2016-05-25	00:22:52	1832	1408	310	169	0
861	2017-12-27	00:22:34	228	812	208	234	0
862	2016-04-13	00:58:35	802	4646	398	265	2
863	2017-09-14	00:23:06	1282	1697	30	350	0
865	2016-09-26	00:13:17	1255	3827	68	82	0
866	2016-02-18	00:38:21	849	2964	328	138	0
867	2016-12-24	00:45:24	1176	5774	68	298	2
868	2017-08-28	00:21:50	1952	1255	272	190	0
870	2016-12-28	00:21:44	200	5035	313	146	0
871	2016-05-18	00:43:40	968	4461	379	233	0
872	2017-08-20	00:03:11	1397	1541	276	368	0
873	2017-01-09	00:45:17	850	3561	99	347	2
874	2016-03-25	00:39:40	315	5907	339	57	0
876	2016-07-04	00:16:14	755	5050	58	167	0
877	2016-03-03	00:37:55	546	516	64	227	0
878	2016-09-18	00:35:49	575	4370	189	77	0
879	2017-05-07	00:59:27	1096	2967	395	375	2
880	2017-03-26	00:45:26	711	6313	130	139	2
882	2017-02-09	00:40:33	272	5475	257	297	0
883	2016-07-11	00:31:17	1002	3886	29	8	0
884	2017-12-03	00:46:02	1833	5071	251	395	2
885	2016-07-01	00:56:38	1584	565	319	20	2
887	2016-10-04	00:07:51	1261	6351	243	389	0
888	2016-09-19	00:54:51	406	2497	106	151	2
889	2017-06-09	00:31:47	1148	5570	315	114	0
890	2017-06-16	00:19:52	248	577	11	145	0
891	2017-11-28	00:16:01	576	66	206	96	0
893	2017-03-03	00:07:56	583	87	356	199	0
894	2016-10-10	00:13:24	1300	6126	178	214	0
895	2017-01-23	00:58:17	1397	4331	286	145	2
896	2016-05-20	00:44:38	1313	6441	187	380	0
897	2016-03-22	00:05:24	977	5505	60	191	0
899	2017-10-11	00:41:26	965	5396	207	50	0
900	2016-01-17	00:23:48	1418	5658	173	311	0
901	2017-09-17	00:01:48	1426	1669	150	293	0
902	2017-09-24	00:38:26	1706	6473	152	275	0
904	2016-01-01	00:27:05	420	2335	375	361	0
905	2016-11-15	00:02:53	1187	2787	341	172	0
906	2016-09-25	00:31:47	1409	3758	78	379	0
907	2016-08-05	00:47:41	540	1891	5	263	2
908	2017-04-18	00:42:11	616	6332	386	96	0
910	2017-09-16	00:38:57	902	3101	18	16	0
911	2016-02-18	00:21:14	462	6525	368	180	0
912	2016-05-25	00:39:30	769	453	116	266	0
913	2016-02-24	00:15:46	73	738	157	323	0
914	2017-02-08	00:05:13	138	5522	386	123	0
916	2017-09-26	00:12:43	820	4516	278	57	0
917	2017-04-09	00:08:58	280	2511	232	227	0
918	2016-07-16	00:43:15	68	4174	288	221	0
919	2017-07-27	00:29:31	68	5341	209	194	0
921	2017-09-26	00:32:54	590	653	177	373	0
922	2016-10-16	00:44:21	823	437	184	138	0
923	2016-03-15	00:28:05	1592	4995	125	119	0
924	2017-08-02	00:00:37	1304	1149	167	249	0
925	2017-08-27	00:33:54	470	6503	86	320	0
927	2017-12-22	00:41:21	1399	645	332	218	0
928	2017-12-08	00:50:22	1138	5964	325	323	2
929	2016-06-18	00:50:04	718	768	347	385	2
930	2017-03-24	00:05:22	835	3076	243	146	0
931	2016-11-05	00:01:43	1161	1039	7	63	0
933	2016-01-24	00:42:04	242	1494	299	2	0
934	2016-05-19	00:31:59	1554	442	221	11	0
935	2016-08-12	00:02:37	591	5494	348	4	0
936	2017-05-26	00:58:39	895	4207	172	291	2
938	2016-04-26	00:05:19	1223	4020	167	130	0
939	2017-03-08	00:47:18	449	6176	167	337	2
940	2016-06-21	00:30:23	1273	5490	135	141	0
941	2016-09-17	00:57:06	1363	3985	112	62	2
942	2016-12-01	00:47:45	1967	1272	183	222	2
944	2017-02-13	00:42:44	318	4998	151	326	0
945	2017-11-02	00:58:40	136	6023	292	85	2
946	2017-11-14	00:15:46	578	5506	282	150	0
947	2017-01-09	00:11:20	571	1958	242	129	0
948	2016-01-20	00:00:50	991	703	255	166	0
950	2016-05-26	00:00:30	778	3118	165	167	0
951	2017-05-09	00:31:07	1909	5315	365	153	0
952	2016-01-04	00:01:40	819	4502	372	136	0
955	2016-10-16	00:08:04	372	1743	7	85	0
956	2017-09-06	00:36:26	398	2688	20	131	0
957	2016-09-04	00:22:34	24	6010	9	104	0
958	2016-02-10	00:20:49	1170	472	36	8	0
959	2017-06-05	00:56:42	924	3067	219	238	2
961	2016-03-16	00:20:17	1008	1017	167	171	0
962	2017-11-06	00:48:35	772	4555	388	281	2
963	2016-02-15	00:44:03	1097	2866	400	179	0
964	2017-01-26	00:57:47	1365	4619	112	271	2
965	2017-07-25	00:32:32	885	164	79	312	0
967	2017-07-01	00:42:15	170	212	206	345	0
968	2017-03-26	00:08:37	1117	2961	310	241	0
969	2017-10-25	00:22:40	321	6215	62	393	0
970	2016-12-07	00:46:06	1407	1134	146	209	2
972	2016-01-27	00:31:15	1210	2885	334	128	0
973	2017-08-10	00:26:35	1718	4599	312	244	0
974	2017-03-25	00:05:53	990	6362	382	27	0
975	2016-02-02	00:20:26	1777	6174	132	13	0
976	2017-03-13	00:13:12	64	3396	145	19	0
978	2016-11-16	00:16:32	1769	1214	334	206	0
979	2017-06-23	00:37:14	1934	4539	34	275	0
980	2017-02-25	00:43:27	142	2481	250	55	0
981	2017-09-16	00:42:43	1806	5283	157	168	0
982	2017-08-08	00:56:07	1074	3991	119	261	2
984	2017-06-24	00:20:23	1880	1167	26	156	0
985	2016-11-21	00:14:56	724	5495	81	77	0
986	2016-08-02	00:20:37	245	5117	200	158	0
987	2017-06-11	00:10:49	1797	5613	209	61	0
989	2017-07-21	00:20:28	783	1579	131	245	0
990	2016-04-07	00:26:30	1784	6186	202	356	0
991	2017-05-21	00:22:00	1784	170	2	161	0
992	2017-07-19	00:12:39	1100	3401	9	155	0
993	2016-09-02	00:38:59	221	3859	67	113	0
995	2016-08-20	00:48:27	1575	5513	77	258	2
996	2017-11-22	00:44:37	1950	6142	158	357	0
997	2017-03-20	00:24:23	1966	575	230	316	0
998	2016-07-12	00:44:57	320	3493	361	204	0
999	2017-08-04	00:54:14	245	3323	219	175	2
1001	2016-07-07	00:12:47	375	2195	157	302	0
1002	2017-05-14	00:35:33	1583	4754	340	381	0
1003	2016-12-15	00:45:29	685	3708	65	146	2
1004	2016-01-07	00:14:45	350	2495	58	255	0
1006	2016-06-17	00:33:03	1158	3440	156	76	0
1007	2017-08-05	00:47:38	486	3496	285	146	2
1008	2016-11-23	00:59:33	1037	1923	340	358	2
1009	2016-01-02	00:52:10	1410	3119	106	90	2
1010	2017-08-22	00:30:51	181	452	96	265	0
1012	2017-05-13	00:12:23	1655	4069	124	32	0
1013	2017-02-10	00:04:36	1076	3915	97	343	0
1014	2017-07-14	00:11:17	705	4030	392	124	0
1015	2016-10-04	00:29:27	804	5374	123	373	0
1016	2017-03-19	00:39:16	524	2027	362	194	0
1018	2016-05-28	00:35:28	1517	1465	386	96	0
1019	2017-08-08	00:52:20	561	4090	15	180	2
1020	2016-03-26	00:14:50	588	3908	189	348	0
1021	2016-11-10	00:27:58	31	6530	310	73	0
1023	2017-07-02	00:23:03	1823	4398	34	71	0
1024	2017-07-16	00:44:11	109	5741	123	324	0
1025	2017-01-22	00:06:47	279	2099	116	7	0
1026	2017-06-10	00:16:06	1017	2165	83	307	0
1027	2017-02-04	00:08:30	1481	2987	35	145	0
1029	2016-01-19	00:53:46	593	5793	20	223	2
1030	2017-06-26	00:11:05	1406	4739	328	286	0
1031	2016-01-01	00:19:51	532	1680	231	393	0
1032	2016-11-05	00:12:25	1082	291	344	43	0
1033	2016-11-28	00:00:28	1435	1755	93	316	0
1035	2016-11-27	00:03:35	492	880	160	66	0
1036	2017-10-01	00:14:12	1802	617	191	172	0
1037	2016-08-10	00:12:51	24	2183	332	325	0
1038	2017-03-20	00:19:36	1933	1274	196	148	0
1040	2017-08-03	00:06:28	1159	854	326	162	0
1041	2016-05-23	00:19:53	1637	118	96	5	0
1042	2017-03-19	00:51:15	538	3785	6	329	2
1043	2017-05-08	00:09:17	859	2163	387	65	0
1044	2017-07-16	00:52:25	508	2753	233	341	2
1046	2016-11-05	00:04:48	1084	1955	237	190	0
1047	2017-12-17	00:18:10	570	6496	358	354	0
1048	2016-02-25	00:44:05	547	1984	26	239	0
1049	2017-12-28	00:28:27	1710	5422	365	338	0
1050	2016-12-27	00:24:25	297	6500	104	381	0
1052	2017-02-11	00:24:50	603	4001	97	228	0
1053	2017-07-08	00:41:02	1245	107	135	25	0
1054	2017-12-11	00:42:18	130	4645	132	168	0
1055	2017-07-27	00:17:39	1204	465	288	101	0
1057	2017-02-25	00:54:32	1908	1602	61	386	2
1058	2016-10-17	00:25:40	822	1601	248	365	0
1059	2017-01-07	00:16:57	1971	5019	277	227	0
1060	2016-07-16	00:05:58	173	4006	56	221	0
1061	2016-10-08	00:55:33	3	6050	349	232	2
1063	2017-06-07	00:37:43	1771	5745	150	282	0
1064	2016-09-09	00:46:31	131	391	361	222	2
1065	2016-05-13	00:06:55	1347	5324	98	167	0
1066	2017-06-17	00:26:48	1526	3350	362	235	0
1067	2016-01-19	00:43:13	1114	6256	193	118	0
1069	2017-05-13	00:44:29	1487	136	255	9	0
1070	2017-04-18	00:26:58	5	2880	316	279	0
1071	2017-09-13	00:50:06	1177	2517	223	205	2
1072	2017-04-14	00:44:49	1332	4703	137	140	0
1074	2017-01-16	00:53:12	1307	2179	324	370	2
1075	2017-08-11	00:37:43	525	4863	76	199	0
1076	2016-07-22	00:42:49	465	830	20	42	0
1077	2016-03-10	00:29:14	1977	4533	368	273	0
1078	2017-11-15	00:40:29	1013	3766	122	97	0
1080	2016-09-07	00:05:16	338	677	77	294	0
1081	2017-09-23	00:40:39	1937	2559	9	217	0
1082	2017-11-15	00:34:52	575	4962	335	72	0
1083	2016-02-05	00:56:39	1991	2415	134	93	2
1084	2016-12-07	00:38:52	1424	2689	4	89	0
1086	2016-02-28	00:16:06	351	726	272	312	0
1087	2016-09-12	00:01:08	1084	1296	49	317	0
1088	2017-12-27	00:14:50	892	4081	163	164	0
1091	2017-08-21	00:28:23	647	4253	41	157	0
1092	2016-01-27	00:29:49	1498	1632	204	261	0
1093	2017-08-19	00:51:15	1544	6018	149	57	2
1094	2016-07-09	00:40:56	637	3632	90	169	0
1095	2016-05-11	00:19:48	221	2483	188	232	0
1097	2017-10-10	00:50:20	1057	4230	241	276	2
1098	2016-10-25	00:52:20	1924	1644	214	101	2
1099	2016-07-19	00:23:48	189	5582	279	194	0
1100	2016-04-23	00:10:22	1593	5019	199	195	0
1101	2016-08-15	00:34:25	217	2879	191	238	0
1103	2016-12-20	00:02:43	1360	3807	400	141	0
1104	2016-03-15	00:54:32	23	4521	115	167	2
1105	2017-08-28	00:38:42	187	2936	120	196	0
1106	2016-08-05	00:51:59	1884	3922	76	266	2
1108	2016-05-03	00:22:04	219	2154	114	19	0
1109	2016-08-23	00:33:52	560	3063	386	325	0
1110	2016-03-06	00:18:52	161	2666	306	168	0
1111	2016-04-14	00:15:14	392	4624	104	15	0
1112	2016-04-17	00:24:29	1196	5279	279	92	0
1114	2016-05-12	00:21:45	1123	2700	154	134	0
1115	2017-09-17	00:30:41	1178	8	295	55	0
1116	2017-06-28	00:39:18	1070	6075	59	191	0
1117	2016-11-02	00:15:33	434	2865	3	205	0
1118	2017-06-27	00:37:21	1916	1	129	306	0
1120	2016-09-05	00:28:05	801	1552	17	275	0
1121	2016-09-20	00:24:00	675	6446	153	212	0
1122	2017-01-12	00:35:17	1509	3442	130	49	0
1123	2016-05-11	00:32:32	1547	5990	384	67	0
1125	2016-08-23	00:12:37	451	642	335	152	0
1126	2016-02-05	00:21:43	102	4856	342	329	0
1127	2017-08-25	00:18:43	1344	1568	397	246	0
1128	2017-10-25	00:28:35	1563	2006	238	230	0
1129	2017-06-10	00:11:32	107	4330	349	310	0
1131	2016-05-12	00:17:04	521	1557	167	11	0
1132	2016-09-23	00:51:49	1827	1138	49	117	2
1133	2016-02-08	00:39:05	1834	2477	110	185	0
1134	2017-01-17	00:09:29	508	2355	327	398	0
1135	2017-03-07	00:00:51	528	3271	113	349	0
1137	2016-06-16	00:54:47	1798	2504	194	79	2
1138	2016-05-22	00:57:54	1538	2176	196	323	2
1139	2017-08-18	00:22:35	350	3857	128	227	0
1140	2016-01-19	00:37:05	574	6498	22	212	0
1142	2017-08-02	00:11:32	932	4775	235	71	0
1143	2016-10-22	00:52:17	1272	6329	326	166	2
1144	2017-01-02	00:43:26	197	3196	284	180	0
1145	2016-09-18	00:28:43	5	3761	350	262	0
1146	2017-09-17	00:50:04	1752	1539	222	154	2
1148	2017-07-20	00:48:07	1722	3749	10	122	2
1149	2017-03-17	00:26:29	1889	1781	358	248	0
1150	2017-11-27	00:38:14	1532	555	187	168	0
1151	2016-01-22	00:01:08	1845	988	24	271	0
1152	2016-03-23	00:47:32	923	2218	252	274	2
1154	2017-09-08	00:26:48	1825	5875	31	210	0
1155	2017-02-27	00:20:29	642	803	257	248	0
1156	2016-11-09	00:56:11	1253	1245	246	244	2
1157	2016-03-04	00:42:55	1497	6368	177	39	0
1159	2017-02-21	00:33:40	134	886	270	216	0
1160	2017-08-14	00:47:43	643	6554	121	307	2
1161	2016-04-15	00:42:13	468	1781	74	209	0
1162	2017-12-09	00:54:39	1915	2839	278	211	2
1163	2016-06-28	00:28:36	928	2119	309	389	0
1165	2017-08-27	00:02:50	1655	2482	18	302	0
1166	2017-04-05	00:46:32	354	6636	339	346	2
1167	2016-03-04	00:51:29	1677	1727	87	131	2
1168	2017-02-26	00:23:51	64	229	297	257	0
1169	2016-05-21	00:28:31	193	6424	170	380	0
1171	2016-05-12	00:27:49	1172	4932	117	50	0
1172	2016-03-02	00:26:08	958	4063	181	129	0
1173	2016-02-10	00:46:24	461	3532	258	316	2
1174	2017-02-25	00:59:37	1969	6059	39	34	2
1176	2017-06-27	00:11:34	1329	2143	159	162	0
1177	2016-03-10	00:19:55	367	1047	352	163	0
1178	2017-09-27	00:03:33	1842	3139	157	9	0
1179	2016-05-07	00:25:22	1314	2398	375	59	0
1180	2016-11-20	00:28:47	1128	5066	164	302	0
1182	2016-06-20	00:31:57	581	2222	194	191	0
1183	2016-10-10	00:41:12	205	5326	279	400	0
1184	2016-04-11	00:17:42	669	4750	278	4	0
1185	2017-11-23	00:34:54	1354	4168	22	71	0
1186	2017-08-06	00:04:35	1694	2416	82	259	0
1188	2017-10-23	00:22:03	1163	6174	99	290	0
1189	2016-11-23	00:45:17	1037	900	61	282	2
1190	2016-05-06	00:10:55	1455	85	376	229	0
1191	2016-11-10	00:29:34	291	6439	289	194	0
1193	2016-12-28	00:55:29	1872	4700	189	105	2
1194	2017-02-21	00:57:43	604	6348	113	383	2
1195	2016-11-09	00:27:36	248	5801	341	179	0
1196	2017-10-04	00:32:34	1348	1427	278	106	0
1197	2017-05-24	00:39:39	851	3358	317	97	0
1199	2016-03-19	00:11:06	170	3604	20	321	0
1200	2017-04-27	00:12:31	1518	5674	332	121	0
1201	2016-10-03	00:33:31	1808	777	292	383	0
1202	2016-08-19	00:46:23	699	4283	194	58	2
1203	2017-02-15	00:11:20	515	205	368	261	0
1205	2016-07-13	00:31:31	1482	5383	280	247	0
1206	2017-07-17	00:05:48	1118	6383	283	142	0
1207	2017-02-26	00:45:44	1740	766	35	171	2
1208	2016-07-15	00:36:40	1172	345	86	315	0
1210	2017-03-10	00:22:08	1318	3079	381	391	0
1211	2017-06-21	00:40:28	511	3743	255	349	0
1212	2016-10-17	00:55:51	1260	4953	333	63	2
1213	2017-05-28	00:06:29	1835	1951	186	118	0
1214	2017-10-15	00:47:19	10	1492	138	60	2
1216	2016-10-02	00:32:25	475	6156	180	93	0
1217	2017-08-16	00:58:20	237	3920	373	307	2
1218	2016-11-10	00:52:04	867	1673	45	168	2
1219	2017-06-22	00:36:01	1306	5426	76	49	0
1220	2017-01-14	00:04:35	747	2480	50	330	0
1222	2016-10-09	00:37:09	1958	6223	309	104	0
1223	2016-08-12	00:54:55	1341	2009	364	103	2
1224	2016-04-03	00:54:36	1278	2818	152	145	2
1227	2016-12-10	00:32:52	180	4726	202	186	0
1228	2017-02-22	00:16:45	1874	2723	233	244	0
1229	2016-08-28	00:27:01	1923	1145	372	149	0
1230	2017-05-07	00:59:34	377	3901	123	88	2
1231	2017-07-05	00:42:23	284	5378	222	284	0
1233	2017-08-22	00:37:45	616	4751	133	397	0
1234	2017-07-15	00:53:57	1301	4519	368	287	2
1235	2016-05-23	00:24:21	1536	5036	181	179	0
1236	2016-10-09	00:40:05	1427	2901	354	238	0
1237	2016-04-16	00:44:03	1035	6311	294	382	0
1239	2017-11-05	00:53:19	1065	1909	104	384	2
1240	2016-06-07	00:30:33	610	4114	340	274	0
1241	2017-10-28	00:58:51	1238	1641	6	111	2
1242	2017-05-02	00:50:29	1655	3710	273	280	2
1244	2017-08-26	00:42:17	1577	1648	315	208	0
1245	2016-03-01	00:46:53	734	700	290	65	2
1246	2016-11-10	00:11:12	622	2940	374	161	0
1247	2017-11-11	00:54:25	1322	4153	288	88	2
1248	2017-05-23	00:45:51	26	2957	27	178	2
1250	2016-02-27	00:38:56	1777	1025	294	84	0
1251	2016-03-20	00:16:40	1587	1766	190	364	0
1252	2016-04-02	00:39:03	185	3170	292	368	0
1253	2016-02-21	00:20:02	1457	2114	215	48	0
1254	2016-02-23	00:49:22	1499	950	240	73	2
1256	2017-02-08	00:22:46	1722	715	211	235	0
1257	2016-09-05	00:19:31	944	1907	212	370	0
1258	2017-10-09	00:46:46	1627	402	210	373	2
1259	2017-05-27	00:02:01	824	6209	360	157	0
1261	2016-03-02	00:49:16	1787	1695	267	367	2
1262	2017-10-17	00:32:31	225	4240	79	242	0
1263	2017-11-06	00:05:26	1335	6233	264	393	0
1264	2016-04-04	00:32:36	223	4114	42	47	0
1265	2016-04-25	00:40:27	635	5633	336	313	0
1267	2016-09-04	00:00:48	1966	518	138	270	0
1268	2017-07-13	00:08:59	272	3293	328	374	0
1269	2016-01-06	00:08:13	869	5996	97	3	0
1270	2016-04-02	00:18:07	1060	3048	314	53	0
1271	2017-03-03	00:59:34	1288	4135	292	119	2
1273	2017-03-22	00:49:12	27	1295	242	54	2
1274	2017-09-26	00:23:08	874	4554	270	287	0
1275	2017-08-16	00:41:51	1841	6121	34	196	0
1276	2016-02-14	00:12:12	724	5108	271	23	0
1278	2017-10-04	00:46:11	1862	3078	315	4	2
1279	2016-11-17	00:32:35	1447	910	385	199	0
1280	2016-06-08	00:49:09	1836	1576	381	87	2
1281	2016-10-09	00:40:29	1668	5008	216	99	0
1282	2017-09-15	00:23:55	1790	3811	320	92	0
1284	2016-11-15	00:18:44	1835	1145	383	56	0
1285	2016-05-08	00:31:11	969	104	124	170	0
1286	2017-04-23	00:21:02	913	6588	397	108	0
1287	2017-11-15	00:44:06	147	5212	391	247	0
1288	2016-11-23	00:33:45	302	1917	139	33	0
1290	2017-07-14	00:15:50	818	1382	352	167	0
1291	2016-10-08	00:13:31	121	3531	37	80	0
1292	2016-06-13	00:33:02	1357	4727	116	30	0
1293	2016-04-18	00:05:43	1486	6540	230	51	0
1295	2016-08-22	00:22:16	1215	5272	390	42	0
1296	2016-02-17	00:26:14	811	294	92	279	0
1297	2016-09-18	00:45:48	1310	3892	202	199	2
1298	2017-02-15	00:47:49	1485	5858	125	68	2
1299	2016-09-22	00:06:23	561	5834	193	170	0
1301	2016-02-07	00:52:25	428	5417	206	43	2
1302	2017-11-03	00:13:07	1366	2083	333	137	0
1303	2016-03-10	00:29:01	1837	3145	88	309	0
1304	2016-12-21	00:45:11	1888	6630	229	75	2
1305	2017-07-26	00:08:13	145	3051	233	105	0
1307	2017-10-01	00:06:28	1453	2526	308	322	0
1308	2017-06-07	00:01:37	240	3979	191	294	0
1309	2017-12-23	00:32:37	1045	1370	390	194	0
1310	2017-02-02	00:13:13	327	750	253	168	0
1312	2016-09-17	00:38:31	263	5159	335	14	0
1313	2016-04-15	00:23:07	305	1527	101	112	0
1314	2017-04-24	00:33:54	1454	5483	384	179	0
1315	2017-12-02	00:48:00	738	2553	353	86	2
1316	2017-11-17	00:29:49	627	494	7	134	0
1318	2017-05-01	00:39:42	11	2529	80	374	0
1319	2017-06-27	00:54:17	136	3132	112	217	2
1320	2016-02-23	00:15:28	992	4379	388	152	0
1321	2017-03-18	00:33:26	1229	2752	111	320	0
1322	2016-09-01	00:31:45	760	3012	45	46	0
1324	2017-09-13	00:06:25	465	1814	195	150	0
1325	2017-01-01	00:11:51	800	5238	185	213	0
1326	2017-12-11	00:24:24	366	5986	300	111	0
1327	2017-05-24	00:41:21	327	943	156	21	0
1329	2016-09-07	00:26:20	645	3292	166	379	0
1330	2016-06-10	00:14:10	721	4439	69	315	0
1331	2016-10-10	00:09:28	510	1914	174	252	0
1332	2017-03-19	00:08:33	469	826	121	143	0
1333	2017-11-12	00:26:26	259	1518	111	10	0
1335	2017-05-12	00:32:32	1323	675	41	60	0
1336	2017-08-16	00:17:40	56	1512	384	374	0
1337	2017-01-19	00:02:02	971	1879	144	283	0
1338	2017-10-14	00:32:05	1107	5130	336	1	0
1339	2016-02-16	00:01:04	1916	6665	323	150	0
1341	2016-01-28	00:01:29	1937	5496	24	240	0
1342	2016-07-06	00:44:41	435	5937	239	162	0
1343	2016-10-23	00:02:23	481	3386	99	285	0
1344	2017-10-15	00:33:33	109	4078	86	157	0
1346	2017-07-03	00:18:59	612	5944	280	127	0
1347	2016-05-17	00:57:42	1457	5844	362	253	2
1348	2016-10-13	00:33:38	1237	6184	303	333	0
1349	2017-04-22	00:45:34	1928	5697	91	385	2
1350	2017-04-18	00:56:10	542	4302	172	249	2
1352	2017-08-17	00:23:04	3	3890	18	115	0
1353	2016-08-18	00:19:56	628	6202	265	102	0
1354	2017-12-23	00:02:29	1601	1359	220	381	0
1355	2016-03-23	00:17:11	1919	746	263	153	0
1356	2016-10-07	00:48:40	710	4515	244	308	2
1358	2017-11-23	00:58:27	1260	1262	396	218	2
1359	2017-02-01	00:05:29	1285	5242	271	301	0
1360	2017-04-02	00:29:06	334	3284	362	386	0
1363	2016-12-19	00:43:47	1384	4637	103	392	0
1364	2016-02-12	00:20:18	1973	6182	59	23	0
1365	2016-12-20	00:20:25	1390	3187	296	355	0
1366	2017-06-05	00:41:31	153	711	159	261	0
1367	2017-07-13	00:10:19	855	2519	268	146	0
1369	2016-03-07	00:21:15	319	4696	26	399	0
1370	2016-03-05	00:36:02	1458	2554	13	68	0
1371	2016-12-13	00:04:34	785	370	353	260	0
1372	2016-01-04	00:19:18	462	6075	98	96	0
1373	2016-12-10	00:22:55	1922	5362	32	258	0
1375	2017-01-02	00:59:23	758	3559	219	333	2
1376	2017-12-21	00:38:22	68	5539	84	280	0
1377	2016-12-05	00:58:06	577	4483	279	359	2
1378	2016-10-11	00:37:52	404	1055	302	97	0
1380	2016-10-09	00:54:15	1607	4066	348	259	2
1381	2016-09-14	00:32:33	1847	1430	397	229	0
1382	2016-09-09	00:55:37	1918	3320	118	59	2
1383	2016-01-03	00:55:23	1482	309	10	373	2
1384	2016-01-20	00:55:25	1595	6384	249	327	2
1386	2016-04-16	00:13:45	482	2057	353	153	0
1387	2016-03-12	00:59:42	573	568	356	71	2
1388	2017-04-19	00:12:22	286	2197	362	269	0
1389	2017-12-22	00:03:41	692	2856	103	337	0
1390	2016-10-02	00:09:02	1203	2695	259	265	0
1392	2017-08-18	00:22:49	316	68	46	254	0
1393	2017-03-28	00:06:25	736	5425	86	359	0
1394	2017-05-13	00:44:00	1886	608	138	342	0
1395	2016-10-28	00:51:55	1459	24	286	321	2
1397	2017-01-03	00:33:02	466	6414	383	380	0
1398	2017-10-18	00:36:55	596	6302	70	85	0
1399	2017-12-03	00:03:53	389	1749	131	121	0
1400	2016-11-03	00:02:43	1709	3418	239	74	0
1401	2017-09-09	00:47:56	176	5915	300	172	2
1403	2017-03-08	00:30:42	1680	3773	259	129	0
1404	2017-11-13	00:14:09	1672	4586	317	146	0
1405	2016-04-13	00:44:20	1661	420	370	347	0
1406	2017-03-21	00:17:18	671	6521	263	339	0
1407	2017-10-03	00:39:17	582	3613	45	159	0
1409	2016-06-04	00:23:03	1707	3036	84	136	0
1410	2016-09-14	00:26:19	1955	4816	70	400	0
1411	2016-12-02	00:09:14	464	5867	141	304	0
1412	2016-06-10	00:50:33	1819	2454	369	202	2
1414	2017-09-10	00:38:23	1328	6389	258	175	0
1415	2016-09-08	00:23:27	814	1546	243	359	0
1416	2016-05-09	00:37:23	396	5218	221	295	0
1417	2016-06-02	00:33:59	823	3542	58	248	0
1418	2016-05-15	00:42:37	575	3174	208	150	0
1420	2016-11-13	00:41:00	830	683	138	149	0
1421	2017-05-04	00:36:23	1741	2776	89	244	0
1422	2017-01-04	00:31:50	1161	6514	213	46	0
1423	2017-05-23	00:22:14	1917	3333	232	115	0
1424	2016-05-01	00:56:46	1049	2346	48	371	2
1426	2016-03-08	00:24:13	384	6118	271	354	0
1427	2017-06-27	00:52:28	1876	4059	103	219	2
1428	2016-03-28	00:22:35	498	3458	230	243	0
1429	2017-11-02	00:30:52	147	4565	23	135	0
1431	2016-05-04	00:07:36	409	2121	100	295	0
1432	2016-05-12	00:25:17	1939	1173	44	235	0
1433	2016-12-12	00:29:09	1602	1825	105	323	0
1434	2016-05-05	00:45:31	1400	5255	164	2	2
1435	2016-12-17	00:59:21	877	5358	28	145	2
1437	2016-09-24	00:05:16	533	3220	242	321	0
1438	2016-12-16	00:15:45	775	2798	244	148	0
1439	2017-09-08	00:10:08	1765	4852	45	265	0
1440	2017-05-20	00:17:20	771	4939	57	207	0
1441	2016-10-26	00:00:58	1384	6278	330	398	0
1443	2016-09-15	00:09:42	681	5193	79	68	0
1444	2016-06-05	00:56:11	629	1093	131	56	2
1445	2016-08-12	00:30:23	89	95	42	133	0
1446	2016-04-22	00:54:14	374	357	260	217	2
1448	2017-11-23	00:19:01	907	221	82	7	0
1449	2017-07-06	00:12:36	1947	5327	56	42	0
1450	2016-03-09	00:03:17	251	1705	317	391	0
1451	2017-02-16	00:22:24	1456	2534	236	247	0
1452	2016-12-18	00:23:20	1369	3862	152	336	0
1454	2017-03-06	00:30:23	1344	4615	182	351	0
1455	2016-03-04	00:51:58	1185	5233	391	266	2
1456	2017-04-14	00:29:08	471	4556	164	341	0
1457	2017-07-02	00:58:11	1243	1026	271	92	2
1458	2017-11-18	00:08:42	1213	608	172	247	0
1460	2017-01-10	00:53:58	1511	3395	168	143	2
1461	2016-12-20	00:38:12	100	280	164	89	0
1462	2017-03-14	00:24:45	653	5761	82	15	0
1463	2017-04-12	00:44:54	1942	5130	114	94	0
1465	2016-07-13	00:39:27	9	81	181	330	0
1466	2017-03-02	00:13:34	1367	1161	183	293	0
1467	2017-03-17	00:27:22	1837	1531	161	247	0
1468	2017-04-10	00:52:01	1187	5141	361	5	2
1469	2016-06-15	00:12:35	1119	6100	260	102	0
1471	2017-07-09	00:13:52	1654	6666	207	94	0
1472	2017-08-04	00:16:41	1922	1466	104	388	0
1473	2017-03-11	00:22:18	1819	2789	125	45	0
1474	2017-06-28	00:58:51	1579	1297	8	64	2
1475	2016-01-23	00:46:13	1053	2003	34	113	2
1477	2016-03-28	00:09:25	676	5626	140	295	0
1478	2016-08-19	00:38:35	213	1652	367	61	0
1479	2017-08-26	00:47:57	578	1232	100	135	2
1480	2016-03-15	00:19:33	698	2129	317	28	0
1482	2017-01-23	00:43:52	1018	5539	125	305	0
1483	2017-05-10	00:47:08	1167	992	46	178	2
1484	2017-01-24	00:51:49	1140	4350	119	2	2
1485	2017-06-28	00:30:53	1682	6006	266	312	0
1486	2017-04-15	00:23:16	1453	1922	362	159	0
1488	2017-12-18	00:22:56	572	5260	206	297	0
1489	2017-09-27	00:20:43	1170	4806	83	364	0
1490	2016-05-13	00:48:13	412	4052	260	219	2
1491	2016-07-05	00:18:35	1172	713	2	389	0
1492	2016-09-07	00:34:40	1089	3936	348	399	0
1494	2016-09-05	00:11:06	1572	3148	176	399	0
1495	2017-12-09	00:45:33	497	6555	241	180	2
1496	2017-03-05	00:26:08	807	3311	289	338	0
1499	2017-08-07	00:22:21	1507	4609	246	136	0
1500	2017-12-27	00:06:06	734	2997	306	206	0
1501	2017-01-27	00:30:56	31	3498	44	383	0
1502	2017-04-27	00:01:57	1231	8	116	201	0
1503	2016-11-16	00:44:00	399	2010	296	177	0
1505	2017-02-15	00:13:47	1064	3290	271	391	0
1506	2017-12-16	00:50:55	669	1493	11	282	2
1507	2016-04-22	00:38:59	1856	2158	122	313	0
1508	2016-11-04	00:59:08	1039	5445	172	116	2
1509	2017-07-01	00:13:27	342	4345	226	87	0
1511	2017-06-19	00:17:39	1881	5234	308	381	0
1512	2017-11-04	00:42:45	1023	5674	16	121	0
1513	2016-08-09	00:56:05	1004	5229	36	344	2
1514	2016-01-22	00:42:28	528	2356	387	247	0
1516	2017-04-08	00:08:23	275	6022	396	399	0
1517	2017-01-05	00:26:13	950	5117	145	96	0
1518	2017-05-11	00:57:58	1925	6411	20	226	2
1519	2017-04-01	00:01:52	155	307	205	370	0
1520	2017-07-16	00:19:02	555	934	98	19	0
1522	2016-05-11	00:16:48	1998	6481	11	47	0
1523	2016-08-11	00:18:48	685	2714	300	396	0
1524	2017-07-20	00:46:08	1764	4713	294	198	2
1525	2017-06-03	00:47:17	920	4879	380	129	2
1526	2017-02-12	00:32:56	1985	1932	382	360	0
1528	2016-04-28	00:05:06	1933	1140	226	95	0
1529	2017-04-06	00:45:19	903	5863	268	181	2
1530	2017-03-15	00:12:51	1217	3859	236	248	0
1531	2017-03-18	00:24:11	323	3815	158	103	0
1533	2017-01-23	00:21:32	1032	4663	350	160	0
1534	2016-10-07	00:02:16	1718	2672	303	325	0
1535	2017-09-11	00:18:02	1298	2150	75	200	0
1536	2016-04-22	00:47:18	565	4770	289	244	2
1537	2017-06-05	00:13:25	675	2308	343	2	0
1539	2016-01-01	00:22:53	167	3597	394	160	0
1540	2017-11-14	00:53:22	789	5843	43	363	2
1541	2016-06-15	00:46:09	690	6224	14	231	2
1542	2017-01-02	00:49:53	1997	6385	68	100	2
1543	2016-11-03	00:30:19	1429	4493	274	360	0
1545	2017-04-01	00:49:28	273	262	43	202	2
1546	2017-05-25	00:41:56	466	4059	356	14	0
1547	2017-11-03	00:32:17	184	6124	84	273	0
1548	2017-03-06	00:27:42	1833	2479	154	315	0
1550	2017-09-23	00:41:12	1754	615	9	156	0
1551	2017-07-10	00:23:58	1737	6251	396	204	0
1552	2017-06-09	00:08:42	1353	1139	308	101	0
1553	2017-10-22	00:57:40	1769	5731	382	395	2
1554	2016-11-13	00:00:17	297	1078	262	202	0
1556	2017-11-11	00:36:55	1812	38	172	42	0
1557	2016-03-15	00:12:14	563	1031	79	303	0
1558	2016-01-18	00:07:12	1466	2013	143	93	0
1559	2016-04-16	00:01:57	33	3577	195	41	0
1560	2016-04-12	00:36:27	1591	4739	322	18	0
1562	2017-05-06	00:27:20	1620	3474	39	351	0
1563	2017-11-16	00:57:16	1393	6529	126	201	2
1564	2016-04-09	00:36:02	176	4191	336	243	0
1565	2016-06-23	00:56:30	750	5069	14	221	2
1567	2017-06-06	00:16:00	1588	4124	171	294	0
1568	2017-08-07	00:39:46	1857	2912	371	311	0
1569	2016-08-11	00:30:44	1168	1434	54	145	0
1570	2016-05-17	00:11:34	1264	3164	73	36	0
1571	2017-02-06	00:11:50	1716	2165	376	251	0
1573	2016-07-27	00:53:10	908	6417	69	76	2
1574	2017-08-10	00:12:13	623	1114	69	175	0
1575	2017-08-20	00:52:13	1512	4051	180	234	2
1576	2017-09-15	00:17:11	1608	663	225	188	0
1577	2017-07-08	00:55:42	873	1145	295	10	2
1579	2017-10-17	00:56:34	1707	5954	159	142	2
1580	2017-12-23	00:39:43	1467	4494	261	169	0
1581	2016-04-11	00:45:15	292	6654	381	34	2
1582	2017-05-06	00:15:51	865	2548	237	306	0
1584	2016-04-16	00:01:51	1400	4742	88	310	0
1585	2016-06-15	00:00:09	1857	321	77	1	0
1586	2016-10-27	00:52:34	1296	1253	168	238	2
1587	2017-02-23	00:40:51	1329	636	171	323	0
1588	2016-09-14	00:57:15	948	2194	63	173	2
1590	2017-03-02	00:58:42	1346	4969	281	35	2
1591	2016-04-08	00:25:48	846	6220	158	353	0
1592	2017-10-26	00:12:59	168	648	374	208	0
1593	2017-03-02	00:07:43	1480	1984	113	190	0
1594	2016-03-15	00:48:16	481	3255	66	340	2
1596	2016-09-17	00:24:29	783	5417	108	102	0
1597	2017-08-20	00:15:31	1735	1344	192	73	0
1598	2016-06-13	00:26:35	1969	2344	336	53	0
1599	2017-09-19	00:01:23	1832	5699	319	111	0
1601	2017-07-16	00:59:48	1427	3529	258	360	2
1602	2017-03-26	00:25:55	393	2911	28	396	0
1603	2017-09-23	00:27:50	861	3189	229	286	0
1604	2016-09-12	00:35:05	394	3673	292	79	0
1605	2017-06-24	00:45:15	1241	6127	60	90	2
1607	2017-04-10	00:39:24	1879	6591	268	280	0
1608	2016-05-17	00:13:06	1492	1158	88	27	0
1609	2017-08-20	00:11:10	1705	1272	172	251	0
1610	2016-09-11	00:11:56	937	3549	387	175	0
1611	2017-01-04	00:57:44	323	49	240	163	2
1613	2017-12-04	00:16:05	422	834	283	244	0
1614	2016-04-20	00:19:38	462	912	52	166	0
1615	2016-06-16	00:38:37	587	3473	311	79	0
1616	2016-02-02	00:41:06	1406	1311	242	215	0
1618	2017-08-20	00:33:49	296	741	245	400	0
1619	2017-06-17	00:06:21	1333	475	265	59	0
1620	2016-02-07	00:19:02	889	1703	133	21	0
1621	2017-10-23	00:29:24	158	1618	57	356	0
1622	2017-10-09	00:35:05	1004	6076	254	204	0
1624	2017-12-16	00:44:01	613	4171	176	188	0
1625	2016-09-13	00:36:09	100	1370	214	61	0
1626	2017-07-12	00:34:09	1131	2853	226	301	0
1627	2016-05-15	00:08:52	1913	4448	197	372	0
1628	2017-10-06	00:00:55	1096	5355	251	219	0
1630	2016-08-21	00:18:38	29	3885	206	368	0
1631	2017-10-20	00:50:55	228	3715	56	375	2
1632	2016-01-28	00:34:06	1345	1220	9	311	0
1635	2016-03-23	00:40:26	822	263	88	156	0
1636	2017-02-16	00:15:01	609	6033	341	116	0
1637	2016-07-14	00:19:51	141	5158	341	117	0
1638	2016-03-06	00:47:09	257	982	248	327	2
1639	2016-03-23	00:58:02	373	5873	320	54	2
1641	2017-04-23	00:29:28	1683	3652	95	337	0
1642	2016-12-06	00:03:00	1317	3090	170	16	0
1643	2016-07-23	00:19:05	818	6137	203	4	0
1644	2017-10-14	00:51:41	450	6520	117	351	2
1645	2017-03-23	00:49:28	1120	3829	89	108	2
1647	2016-06-01	00:32:11	1239	2161	331	336	0
1648	2016-04-07	00:50:12	381	2013	22	62	2
1649	2017-05-03	00:21:45	1580	5656	35	290	0
1650	2017-11-05	00:29:37	964	4614	353	371	0
1652	2017-04-12	00:17:20	1398	1039	114	180	0
1653	2017-12-25	00:45:42	1527	1322	327	130	2
1654	2017-05-13	00:26:13	1502	6335	259	190	0
1655	2017-11-25	00:45:28	1556	3959	218	47	2
1656	2016-07-02	00:46:06	64	6489	149	202	2
1658	2016-06-22	00:12:09	262	5699	186	156	0
1659	2017-11-23	00:58:03	1611	1766	180	229	2
1660	2017-01-11	00:15:09	671	4786	194	180	0
1661	2017-03-11	00:23:21	1099	3928	233	97	0
1662	2017-04-21	00:10:23	1468	5511	132	393	0
1664	2016-02-15	00:00:57	669	6483	164	44	0
1665	2017-10-17	00:52:52	379	2287	351	128	2
1666	2017-03-14	00:32:12	1567	6398	78	104	0
1667	2017-03-06	00:32:58	497	4461	115	217	0
1669	2017-01-10	00:49:00	587	2939	181	81	2
1670	2016-06-18	00:39:59	1833	115	82	348	0
1671	2017-10-20	00:22:13	120	3095	147	73	0
1672	2017-03-18	00:58:09	704	803	147	388	2
1673	2016-03-14	00:01:16	492	3614	147	177	0
1675	2016-01-06	00:10:32	958	1239	3	310	0
1676	2017-02-28	00:55:53	1839	1986	258	191	2
1677	2016-05-28	00:17:07	374	385	11	205	0
1678	2016-04-10	00:38:50	617	5621	42	189	0
1679	2016-10-28	00:08:32	912	5277	179	261	0
1681	2016-08-14	00:56:08	936	1496	194	67	2
1682	2017-05-02	00:42:41	1497	3983	273	125	0
1683	2017-05-04	00:56:25	229	1693	260	103	2
1684	2017-01-23	00:56:39	1680	2679	217	255	2
1686	2016-05-21	00:08:15	954	3279	299	59	0
1687	2016-03-15	00:12:33	406	5831	181	12	0
1688	2017-02-23	00:09:34	1151	5386	138	335	0
1689	2016-03-08	00:32:14	1256	2081	76	69	0
1690	2017-04-08	00:08:59	1735	1192	94	293	0
1692	2017-07-08	00:02:18	1191	4808	101	54	0
1693	2016-04-09	00:39:02	32	1352	56	85	0
1694	2017-01-03	00:33:11	3	2519	263	371	0
1695	2017-11-03	00:50:22	447	2467	141	244	2
1696	2016-05-07	00:08:36	1954	2317	382	292	0
1698	2016-08-20	00:04:34	1043	797	5	259	0
1699	2017-07-09	00:57:28	1924	510	58	330	2
1700	2017-01-01	00:55:37	666	5054	356	392	2
1701	2016-06-20	00:25:48	328	3701	384	241	0
1703	2017-08-12	00:03:15	2	5371	41	291	0
1704	2016-03-16	00:02:58	567	3220	257	56	0
1705	2017-08-17	00:59:02	1864	2507	236	158	2
1706	2017-09-08	00:56:48	1028	4670	396	72	2
1707	2016-07-05	00:50:30	1739	1223	349	221	2
1709	2017-06-12	00:06:03	523	3313	181	140	0
1710	2017-05-22	00:47:31	288	440	257	182	2
1711	2017-10-26	00:13:12	346	296	99	36	0
1712	2017-07-03	00:35:35	1403	1396	269	316	0
1713	2016-06-14	00:37:22	87	3146	131	75	0
1715	2017-03-18	00:56:35	889	3706	377	3	2
1716	2016-08-26	00:38:57	555	3413	15	90	0
1717	2017-06-01	00:54:27	705	2202	10	28	2
1718	2017-05-22	00:33:39	1605	4022	12	297	0
1720	2016-06-20	00:16:09	1252	3229	385	126	0
1721	2016-10-17	00:44:57	967	4064	275	198	0
1722	2016-05-16	00:58:30	609	3772	130	158	2
1723	2017-03-15	00:16:06	188	2702	45	99	0
1724	2016-05-05	00:31:06	1653	422	279	38	0
1726	2017-03-06	00:35:30	934	4068	283	274	0
1727	2017-03-26	00:01:01	566	3626	64	241	0
1728	2016-09-15	00:42:39	946	2394	109	100	0
1729	2016-04-15	00:44:49	92	2484	350	312	0
1730	2016-10-16	00:47:16	1246	3197	69	339	2
1732	2017-06-16	00:04:05	565	5142	59	126	0
1733	2016-05-14	00:06:07	1751	2336	266	298	0
1734	2017-12-16	00:06:56	1229	216	140	205	0
1735	2017-01-13	00:03:06	872	449	135	249	0
1737	2017-07-04	00:18:26	1580	2890	399	124	0
1738	2017-02-11	00:33:09	1166	1860	286	360	0
1739	2017-12-08	00:47:50	1435	2811	397	204	2
1740	2017-06-23	00:24:14	864	1121	23	26	0
1741	2017-10-22	00:10:03	1235	173	219	317	0
1743	2016-03-11	00:12:39	1577	5203	255	272	0
1744	2016-11-19	00:51:01	738	1835	215	139	2
1745	2016-12-23	00:10:23	1663	364	394	173	0
1746	2016-09-12	00:00:46	1276	2039	186	176	0
1747	2017-10-20	00:26:50	619	5379	233	185	0
1749	2016-08-22	00:35:46	1611	2800	262	31	0
1750	2016-06-02	00:01:32	995	3514	120	379	0
1751	2016-02-03	00:23:05	1179	4424	228	186	0
1752	2016-11-20	00:05:34	1797	5624	399	92	0
1754	2016-04-20	00:08:36	377	4743	267	41	0
1755	2016-10-09	00:27:53	228	3037	335	328	0
1756	2017-10-02	00:29:01	1325	5148	188	230	0
1757	2016-01-06	00:52:00	1026	5488	368	335	2
1758	2016-07-14	00:46:03	1657	2683	356	106	2
1760	2017-03-28	00:46:42	803	4878	212	304	2
1761	2016-07-10	00:54:11	1913	2414	20	213	2
1762	2016-08-15	00:15:45	403	3198	355	41	0
1763	2016-06-07	00:38:56	991	4365	224	359	0
1764	2017-12-05	00:25:26	1918	6425	374	147	0
1766	2017-10-18	00:24:05	656	226	228	64	0
1767	2016-09-28	00:25:55	1630	4268	207	176	0
1768	2016-09-22	00:04:10	1502	1265	175	32	0
1771	2016-10-04	00:06:09	100	1331	38	88	0
1772	2016-02-28	00:16:51	188	138	344	158	0
1773	2016-05-15	00:17:48	1139	1109	320	228	0
1774	2017-10-19	00:32:03	67	2024	364	204	0
1775	2017-11-26	00:32:33	80	5713	396	381	0
1777	2017-09-13	00:09:31	1251	85	44	173	0
1778	2017-04-12	00:22:10	449	4140	332	338	0
1779	2016-02-08	00:18:35	989	6504	264	45	0
1780	2017-04-20	00:02:04	1186	2026	86	48	0
1781	2016-09-10	00:23:06	1181	3909	192	177	0
1783	2016-02-28	00:42:27	1942	5543	162	290	0
1784	2016-09-20	00:30:11	1749	6212	25	60	0
1785	2017-03-04	00:23:27	549	1042	209	102	0
1786	2016-07-01	00:07:56	1010	3226	12	298	0
1788	2017-10-27	00:09:04	82	4285	217	59	0
1789	2016-05-02	00:01:22	343	1262	273	238	0
1790	2017-04-24	00:24:47	912	3335	150	96	0
1791	2017-06-26	00:03:38	1390	2793	78	300	0
1792	2017-07-18	00:12:37	1144	3027	215	139	0
1794	2017-05-06	00:10:41	1014	1590	49	380	0
1795	2017-02-06	00:31:49	1488	4327	293	235	0
1796	2016-02-19	00:31:31	1002	6139	26	25	0
1797	2017-01-16	00:00:53	1373	2870	202	38	0
1798	2017-11-23	00:51:30	1028	2528	61	310	2
1800	2017-04-13	00:21:53	1141	4032	151	125	0
1801	2016-02-18	00:30:09	1623	1349	241	316	0
1802	2017-01-10	00:21:09	1005	3557	89	384	0
1803	2016-07-08	00:17:13	1849	4335	45	324	0
1805	2017-11-10	00:49:54	207	1660	282	196	2
1806	2016-05-01	00:26:41	1239	701	167	47	0
1807	2017-09-24	00:13:58	1156	6659	284	111	0
1808	2016-08-23	00:12:31	688	6359	126	94	0
1809	2017-02-24	00:39:23	38	1274	156	176	0
1811	2017-11-21	00:28:33	1733	59	138	290	0
1812	2017-02-04	00:35:53	1351	534	80	147	0
1813	2016-07-14	00:43:25	1917	4711	43	181	0
1814	2017-08-24	00:48:11	1688	2404	84	348	2
1815	2016-07-25	00:00:56	1463	3043	168	304	0
1817	2017-05-06	00:47:02	91	5661	255	125	2
1818	2017-09-15	00:48:49	560	2754	73	183	2
1819	2016-10-14	00:54:21	1720	2613	162	273	2
1820	2017-05-28	00:13:42	1465	2119	2	217	0
1822	2016-07-11	00:25:13	703	371	228	102	0
1823	2017-12-23	00:17:19	886	6008	48	178	0
1824	2017-04-11	00:59:51	405	6463	170	121	2
1825	2016-09-25	00:11:55	785	2230	322	116	0
1826	2017-11-16	00:03:11	924	1709	197	78	0
1828	2017-04-09	00:05:56	540	1652	74	245	0
1829	2016-02-03	00:45:32	1084	1328	281	322	2
1830	2016-02-13	00:43:59	893	6165	300	114	0
1831	2017-04-15	00:37:03	1993	2358	161	156	0
1832	2016-10-09	00:38:05	1033	103	1	394	0
1834	2016-09-06	00:31:25	1002	3199	9	33	0
1835	2016-12-07	00:05:49	1359	1137	342	85	0
1836	2017-01-27	00:33:36	479	5314	346	311	0
1837	2017-08-27	00:56:33	1738	4697	187	274	2
1839	2017-02-01	00:29:57	1065	1784	293	299	0
1840	2016-08-11	00:24:39	481	607	306	57	0
1841	2017-06-20	00:32:25	30	2655	111	57	0
1842	2016-04-05	00:13:36	490	1901	76	315	0
1843	2017-04-19	00:52:12	182	3169	82	300	2
1845	2016-08-13	00:58:36	1036	271	330	304	2
1846	2017-06-26	00:08:49	1367	736	123	322	0
1847	2016-01-25	00:08:53	1682	2103	252	232	0
1848	2016-01-15	00:08:35	739	2516	205	131	0
1849	2016-11-10	00:38:18	262	3416	236	307	0
1851	2016-06-23	00:19:31	875	3349	283	110	0
1852	2017-11-02	00:53:11	518	2443	298	291	2
1853	2016-01-09	00:28:48	1742	6668	273	52	0
1854	2017-07-23	00:11:46	1546	193	371	162	0
1856	2017-03-18	00:17:29	494	4312	193	302	0
1857	2017-09-17	00:02:12	1989	1439	273	285	0
1858	2017-08-23	00:38:21	1305	1642	274	116	0
1859	2016-02-23	00:40:09	1147	2610	219	161	0
1860	2017-06-09	00:39:46	1273	2149	378	140	0
1862	2016-11-03	00:32:19	446	2405	357	8	0
1863	2017-10-27	00:56:34	838	343	307	395	2
1864	2016-07-16	00:33:30	1743	5136	239	156	0
1865	2016-03-24	00:49:49	607	5066	185	289	2
1866	2016-03-13	00:25:13	746	3952	237	171	0
1868	2016-12-21	00:54:28	302	3108	323	228	2
1869	2017-05-11	00:50:40	264	1354	329	306	2
1870	2017-10-07	00:13:32	1898	720	334	92	0
1871	2017-08-24	00:49:00	627	5209	74	179	2
1873	2017-10-13	00:03:47	1310	1341	376	124	0
1874	2016-05-12	00:03:39	85	2351	52	394	0
1875	2016-03-18	00:11:01	996	1973	85	400	0
1876	2017-07-09	00:49:33	454	4673	82	381	2
1877	2016-06-08	00:21:18	160	5798	19	278	0
1879	2016-04-13	00:59:35	155	5384	241	94	2
1880	2017-05-21	00:44:44	8	6424	256	83	0
1881	2017-01-20	00:41:13	1291	1189	285	269	0
1882	2017-05-05	00:37:03	1518	1207	264	159	0
1883	2016-08-19	00:06:56	820	4946	147	389	0
1885	2016-12-14	00:26:01	696	6609	296	306	0
1886	2017-08-21	00:20:29	388	3595	279	167	0
1887	2016-01-07	00:27:57	1011	561	287	115	0
1888	2016-08-17	00:48:31	520	6364	111	95	2
1890	2017-01-01	00:16:06	303	738	349	289	0
1891	2016-10-04	00:01:12	1966	5628	50	107	0
1892	2016-04-22	00:22:28	709	1285	48	352	0
1893	2016-07-25	00:43:23	1941	5464	134	55	0
1894	2016-03-10	00:57:14	797	3738	396	92	2
1896	2016-02-23	00:11:31	1321	4913	343	358	0
1897	2016-07-10	00:57:40	850	999	343	338	2
1898	2016-01-18	00:26:58	81	201	374	289	0
1899	2016-05-27	00:53:03	890	2825	188	52	2
1900	2017-01-02	00:48:46	401	1302	242	332	2
1902	2016-08-10	00:12:04	48	1242	50	317	0
1903	2016-02-11	00:08:01	997	4215	319	268	0
1904	2017-02-02	00:40:12	217	2744	49	296	0
1907	2017-10-06	00:47:00	868	3674	198	306	2
1908	2017-07-01	00:14:44	857	3286	275	27	0
1909	2017-12-14	00:11:17	1245	2489	296	347	0
1910	2017-03-18	00:23:41	162	474	241	256	0
1911	2016-09-25	00:24:08	1253	4619	12	102	0
1913	2017-12-28	00:43:17	284	6257	389	109	0
1914	2016-07-17	00:37:31	1460	4975	354	307	0
1915	2016-04-24	00:40:19	840	279	16	394	0
1916	2017-05-12	00:02:07	1152	3443	41	112	0
1917	2017-04-27	00:32:52	1900	5131	41	120	0
1919	2016-11-22	00:56:21	623	5293	323	310	2
1920	2016-07-20	00:53:17	117	5207	314	80	2
1921	2017-01-17	00:36:27	1181	2077	357	185	0
1922	2016-03-07	00:55:26	68	1187	153	378	2
1924	2017-03-28	00:26:34	292	6527	189	166	0
1925	2016-10-28	00:04:45	1992	5322	302	297	0
1926	2017-10-04	00:02:05	173	5003	244	99	0
1927	2017-09-11	00:28:17	1300	347	13	284	0
1928	2017-04-21	00:36:13	1805	2180	219	316	0
1930	2017-08-18	00:06:34	612	1524	138	136	0
1931	2017-01-16	00:08:01	201	4543	145	282	0
1932	2017-03-13	00:52:08	1307	6105	155	50	2
1933	2017-02-10	00:59:36	400	5861	39	232	2
1934	2017-05-05	00:20:08	724	1534	385	5	0
1936	2016-09-25	00:32:41	936	545	36	148	0
1937	2017-08-21	00:11:00	166	1002	253	130	0
1938	2016-12-11	00:03:20	637	1735	52	209	0
1939	2017-05-15	00:33:36	1641	4037	154	341	0
1941	2017-01-15	00:35:50	230	1651	14	291	0
1942	2016-10-04	00:34:43	1909	770	312	63	0
1943	2016-07-13	00:00:25	1749	1294	223	324	0
1944	2017-02-12	00:35:57	293	1240	106	188	0
1945	2017-11-02	00:06:45	1263	2021	152	9	0
1947	2017-10-20	00:30:28	1898	6207	180	115	0
1948	2016-05-17	00:56:14	453	4879	344	9	2
1949	2017-02-08	00:54:03	1852	2096	247	42	2
1950	2016-08-11	00:29:48	57	4641	301	364	0
1951	2017-03-13	00:56:19	1675	4893	342	352	2
1953	2016-01-02	00:14:56	411	5150	337	308	0
1954	2017-08-04	00:05:49	1084	5249	10	51	0
1955	2017-03-12	00:42:09	689	3011	15	258	0
1956	2017-09-19	00:13:29	329	2545	376	226	0
1958	2016-10-16	00:01:32	209	1050	2	319	0
1959	2017-05-04	00:56:34	1821	2123	236	199	2
1960	2016-12-07	00:52:12	1470	552	241	371	2
1961	2017-07-19	00:07:13	1448	1035	107	179	0
1962	2017-05-25	00:34:58	855	4372	380	20	0
1964	2016-01-26	00:20:37	1473	559	337	60	0
1965	2017-03-05	00:27:49	465	461	32	5	0
1966	2016-09-15	00:37:05	650	2293	382	136	0
1967	2016-11-19	00:25:28	165	4013	169	161	0
1968	2016-11-19	00:11:40	1001	5878	40	301	0
1970	2016-03-27	00:45:58	1025	628	6	273	2
1971	2016-02-02	00:05:37	1335	502	261	109	0
1972	2017-05-20	00:34:02	1624	1272	377	224	0
1973	2017-03-20	00:32:44	704	1720	41	385	0
1975	2016-02-24	00:34:22	383	5851	335	364	0
1976	2016-07-18	00:41:50	20	4628	249	239	0
1977	2016-11-10	00:40:25	406	3564	91	341	0
1978	2016-03-13	00:32:37	1528	875	240	198	0
1979	2017-02-27	00:16:37	322	290	305	350	0
1981	2016-06-18	00:48:06	1184	2463	28	50	2
1982	2017-09-22	00:58:10	1534	3305	212	190	2
1983	2016-09-12	00:29:36	198	4062	245	100	0
1984	2017-09-07	00:31:20	1804	5210	223	7	0
1985	2016-01-26	00:22:45	877	6326	166	307	0
1987	2017-03-28	00:18:12	1393	1207	343	248	0
1988	2016-10-02	00:47:59	1310	5367	7	214	2
1989	2016-07-26	00:31:55	617	6217	142	315	0
1990	2017-02-13	00:34:18	1427	3877	6	387	0
1992	2016-08-03	00:16:55	465	1891	30	196	0
1993	2016-05-10	00:19:18	1343	1382	267	216	0
1994	2016-10-09	00:23:43	1156	1924	40	140	0
1995	2016-05-15	00:29:21	381	3691	280	61	0
1996	2017-12-16	00:58:34	481	5287	220	158	2
1998	2016-05-10	00:11:16	551	141	154	12	0
1999	2017-05-25	00:58:49	1983	2061	357	162	2
2000	2017-11-04	00:01:44	425	3402	88	318	0
2001	2017-05-06	00:37:53	233	2144	64	324	0
2002	2016-05-20	00:33:41	919	5126	143	70	0
2004	2016-06-15	00:13:12	1485	1133	174	139	0
2005	2017-04-20	00:36:49	807	15	186	397	0
2006	2017-06-18	00:57:56	1596	3945	65	345	2
2007	2017-03-08	00:59:50	216	4808	322	42	2
2009	2017-04-27	00:17:10	1141	6568	291	301	0
2010	2016-10-21	00:50:48	522	5292	256	211	2
2011	2017-02-11	00:58:51	902	1942	26	133	2
2012	2017-08-26	00:34:41	1204	5716	375	376	0
2013	2016-12-13	00:59:34	108	250	145	379	2
2015	2016-06-07	00:24:40	1732	5720	282	364	0
2016	2016-06-26	00:00:22	1214	4761	326	360	0
2017	2016-03-25	00:34:59	1829	1456	309	334	0
2018	2017-03-24	00:32:29	1330	4133	131	255	0
2019	2017-05-25	00:39:36	479	3746	88	211	0
2021	2016-10-19	00:15:29	1165	3794	346	237	0
2022	2017-06-16	00:40:28	809	4705	11	373	0
2023	2017-07-16	00:13:48	1850	839	340	165	0
2024	2016-01-13	00:01:26	50	4074	18	311	0
2026	2017-03-11	00:07:56	1174	2394	137	11	0
2027	2016-09-26	00:44:28	1902	6178	152	270	0
2028	2017-09-27	00:25:59	1983	956	136	279	0
2029	2016-10-07	00:10:41	587	3909	9	374	0
2030	2016-01-11	00:49:14	302	5138	256	130	2
2032	2016-02-23	00:39:21	1877	2529	183	273	0
2033	2017-02-20	00:51:25	255	4760	195	372	2
2034	2016-12-03	00:25:42	1182	3240	366	294	0
2035	2016-03-17	00:15:43	980	5903	239	4	0
2036	2017-03-13	00:21:25	1072	6198	36	126	0
2038	2017-09-02	00:52:00	462	3702	365	96	2
2039	2017-09-19	00:52:11	1868	420	394	350	2
2040	2016-10-15	00:13:06	1429	2397	211	394	0
2043	2016-09-01	00:50:40	1866	2640	162	253	2
2044	2017-09-06	00:43:35	963	5447	52	385	0
2045	2016-11-12	00:29:23	1736	2458	63	276	0
2046	2017-03-12	00:24:15	118	3383	276	267	0
2047	2017-12-02	00:44:52	905	5309	177	397	0
2049	2017-01-02	00:54:14	117	5191	245	24	2
2050	2017-09-24	00:08:00	567	1972	259	12	0
2051	2017-02-10	00:31:51	1490	3354	119	346	0
2052	2016-05-28	00:10:15	36	44	209	279	0
2053	2016-03-13	00:15:05	1852	5120	167	387	0
2055	2017-01-06	00:03:24	1446	510	46	164	0
2056	2017-01-26	00:22:14	1482	5649	242	147	0
2057	2016-10-06	00:41:43	1667	652	400	125	0
2058	2017-10-16	00:08:33	1171	3626	251	81	0
2060	2017-12-24	00:01:24	960	2427	178	137	0
2061	2017-08-14	00:57:53	201	4649	376	159	2
2062	2017-09-21	00:48:14	1761	5102	93	116	2
2063	2017-09-07	00:27:17	814	5484	197	114	0
2064	2016-11-27	00:51:29	1640	4028	193	86	2
2066	2016-11-17	00:58:59	873	2333	275	399	2
2067	2017-01-19	00:09:13	1898	6544	192	125	0
2068	2017-03-21	00:28:55	1126	4488	118	132	0
2069	2016-10-05	00:17:31	851	3860	237	254	0
2070	2016-08-24	00:00:55	1942	3516	52	180	0
2072	2016-10-08	00:18:54	681	4168	13	271	0
2073	2016-09-18	00:14:54	1452	2301	202	283	0
2074	2017-01-24	00:16:38	669	3808	248	257	0
2075	2017-05-03	00:25:11	1762	6124	108	280	0
2077	2016-10-12	00:06:42	358	1375	200	370	0
2078	2016-04-03	00:02:13	644	1191	116	293	0
2079	2017-06-16	00:17:02	1401	5230	255	317	0
2080	2017-02-10	00:06:43	1989	805	389	107	0
2081	2016-05-07	00:36:56	1507	251	200	21	0
2083	2016-10-19	00:39:29	1999	5694	187	227	0
2084	2017-08-17	00:45:59	1766	3772	316	75	2
2085	2016-09-08	00:55:33	204	2167	137	259	2
2086	2017-06-17	00:54:03	897	6285	31	302	2
2087	2017-08-09	00:47:40	1938	5052	225	365	2
2089	2017-12-13	00:41:43	1498	61	356	65	0
2090	2017-12-16	00:16:29	271	6006	113	51	0
2091	2017-03-14	00:35:39	1717	6169	126	33	0
2092	2016-01-27	00:42:40	440	3945	143	152	0
2094	2016-01-21	00:47:39	1987	3468	116	359	2
2095	2017-11-14	00:42:36	436	5863	184	77	0
2096	2016-03-10	00:25:31	726	888	7	97	0
2097	2017-12-15	00:03:21	520	2627	19	194	0
2098	2017-01-20	00:08:17	1949	5344	322	21	0
2100	2017-02-08	00:46:37	884	6587	312	384	2
2101	2017-01-03	00:19:15	782	547	319	378	0
2102	2016-12-20	00:42:30	1350	1301	60	393	0
2103	2016-01-26	00:29:20	1081	3970	273	159	0
2104	2016-01-11	00:18:10	344	4601	209	354	0
2106	2017-06-19	00:44:41	38	352	265	314	0
2107	2016-12-19	00:10:08	1428	5559	173	283	0
2108	2017-08-08	00:06:05	915	5535	27	215	0
2109	2017-05-28	00:22:35	1868	3070	49	215	0
2111	2017-05-18	00:46:35	440	1459	185	144	2
2112	2017-12-15	00:38:53	115	1424	198	149	0
2113	2016-04-17	00:35:39	211	5982	100	392	0
2114	2016-11-27	00:17:21	151	3044	245	264	0
2115	2016-09-12	00:22:38	1770	1949	326	240	0
2117	2016-09-05	00:22:42	1711	6123	3	383	0
2118	2017-06-23	00:34:04	1963	2325	390	13	0
2119	2016-09-12	00:33:47	1907	2975	224	295	0
2120	2017-04-28	00:11:31	522	4349	343	290	0
2121	2016-06-22	00:35:55	912	552	266	241	0
2123	2016-05-07	00:43:19	1346	2824	139	12	0
2124	2017-04-15	00:37:41	762	5664	307	8	0
2125	2017-08-10	00:41:55	1761	5492	386	383	0
2126	2017-11-27	00:39:06	634	2870	155	317	0
2128	2016-02-17	00:53:19	723	4076	271	132	2
2129	2017-04-21	00:10:49	1539	1383	120	88	0
2130	2017-03-19	00:03:31	1501	2440	318	187	0
2131	2017-12-22	00:24:41	1572	405	359	53	0
2132	2016-04-10	00:25:41	653	5555	142	245	0
2134	2017-08-08	00:38:35	99	3789	280	355	0
2135	2016-06-21	00:06:54	1915	5305	359	259	0
2136	2017-08-02	00:17:13	1896	1249	355	56	0
2137	2017-02-17	00:56:03	101	747	398	63	2
2138	2016-04-23	00:58:53	1269	4358	156	69	2
2140	2016-09-02	00:13:05	1532	147	206	173	0
2141	2016-09-16	00:28:57	844	756	109	121	0
2142	2017-03-04	00:39:21	1674	3870	263	51	0
2143	2016-12-03	00:57:47	1899	1264	321	41	2
2145	2017-02-27	00:47:21	56	6161	364	229	2
2146	2016-06-21	00:03:11	507	6535	272	112	0
2147	2016-12-01	00:56:27	150	5633	332	134	2
2148	2017-01-25	00:33:46	330	2626	21	191	0
2149	2016-06-07	00:17:10	874	4259	90	301	0
2151	2016-12-16	00:05:30	75	2310	15	307	0
2152	2016-08-13	00:19:34	331	994	4	78	0
2153	2017-04-28	00:35:50	1704	5008	117	16	0
2154	2017-08-01	00:13:51	1013	381	140	170	0
2155	2017-06-26	00:15:43	390	4149	293	45	0
2157	2016-10-16	00:46:18	515	6550	390	399	2
2158	2017-09-03	00:47:00	488	4178	230	123	2
2159	2017-06-14	00:24:41	1726	434	138	220	0
2160	2016-07-09	00:39:25	436	5443	157	21	0
2162	2016-01-27	00:56:46	541	657	380	262	2
2163	2017-06-27	00:13:47	225	5350	53	395	0
2164	2016-05-26	00:47:45	694	6313	76	120	2
2165	2017-08-23	00:06:52	337	1530	150	107	0
2166	2016-08-10	00:03:07	337	5351	60	214	0
2168	2017-02-14	00:34:15	1915	1370	88	227	0
2169	2017-09-13	00:53:36	1226	343	249	102	2
2170	2017-06-16	00:30:03	109	411	5	133	0
2171	2017-12-09	00:28:30	417	5322	18	346	0
2172	2016-03-28	00:43:14	102	4381	230	25	0
2174	2017-08-22	00:29:30	1082	6170	98	127	0
2175	2016-08-28	00:53:18	341	1729	92	332	2
2176	2017-07-02	00:14:10	724	1114	126	272	0
2179	2017-01-10	00:50:11	840	47	163	330	2
2180	2017-03-07	00:22:26	1988	3377	266	38	0
2181	2016-04-10	00:52:53	1217	2406	194	64	2
2182	2016-03-12	00:41:45	287	1109	148	292	0
2183	2016-12-08	00:11:37	112	3881	273	135	0
2185	2016-01-24	00:06:23	167	2572	329	355	0
2186	2017-06-18	00:34:53	40	5122	393	279	0
2187	2017-12-26	00:56:08	36	6028	16	199	2
2188	2016-12-07	00:54:24	1422	3521	272	313	2
2189	2017-01-04	00:36:31	989	4987	52	200	0
2191	2016-08-18	00:04:39	1706	5581	240	232	0
2192	2016-06-12	00:30:10	1931	4584	244	183	0
2193	2017-03-24	00:33:49	509	5402	98	389	0
2194	2017-02-02	00:25:33	226	1355	368	345	0
2196	2016-09-28	00:27:01	835	4231	262	13	0
2197	2017-04-02	00:56:45	226	5234	260	312	2
2198	2017-01-27	00:01:29	1684	5367	349	150	0
2199	2016-08-02	00:19:09	665	2846	318	248	0
2200	2017-04-23	00:55:40	743	2263	4	154	2
2202	2016-09-03	00:52:23	514	1056	217	127	2
2203	2017-01-19	00:57:42	116	3799	238	349	2
2204	2016-12-13	00:12:09	1380	867	231	240	0
2205	2017-02-17	00:37:06	861	817	258	241	0
2206	2017-06-28	00:42:20	439	2906	239	376	0
2208	2016-03-04	00:26:17	1441	1612	29	40	0
2209	2016-03-19	00:22:34	865	1343	209	289	0
2210	2017-06-09	00:14:02	717	2066	76	327	0
2211	2016-02-03	00:19:31	1508	5247	300	238	0
2213	2016-12-22	00:27:34	1032	6353	111	109	0
2214	2016-02-08	00:32:49	338	2551	129	84	0
2215	2017-10-05	00:23:32	485	6549	364	38	0
2216	2017-01-08	00:45:14	739	851	184	20	2
2217	2016-03-15	00:07:40	704	3428	282	366	0
2219	2017-01-14	00:13:25	1522	6039	31	352	0
2220	2016-01-07	00:36:51	632	1485	241	307	0
2221	2017-08-18	00:30:25	1540	4885	368	32	0
2222	2017-11-23	00:26:56	684	6119	371	224	0
2223	2017-01-27	00:02:41	460	723	288	12	0
2225	2017-05-19	00:02:49	35	349	31	21	0
2226	2016-04-05	00:23:21	767	4543	221	136	0
2227	2016-08-26	00:53:26	1261	5506	281	192	2
2228	2017-12-12	00:53:22	1463	2831	399	232	2
2230	2017-10-06	00:33:55	1327	261	61	199	0
2231	2016-01-01	00:31:14	701	934	230	305	0
2232	2016-01-18	00:02:28	63	6227	154	142	0
2233	2016-02-02	00:47:39	41	161	165	177	2
2234	2016-09-14	00:16:47	281	4985	220	183	0
2236	2016-06-25	00:13:49	1034	3802	196	118	0
2237	2017-03-26	00:27:33	1446	3507	274	335	0
2238	2017-06-17	00:21:18	1814	4890	192	324	0
2239	2016-07-04	00:18:04	1934	1962	140	82	0
2240	2017-12-05	00:37:53	1898	4738	387	88	0
2242	2016-11-22	00:04:27	531	3561	38	190	0
2243	2017-02-12	00:36:29	1821	2292	365	295	0
2244	2016-07-17	00:00:53	637	5963	27	324	0
2245	2017-05-28	00:53:42	1155	2791	277	278	2
2247	2017-06-26	00:53:55	1454	374	387	149	2
2248	2016-05-26	00:19:21	387	5798	87	309	0
2249	2017-09-10	00:50:20	600	837	141	85	2
2250	2017-11-11	00:51:28	1150	5920	227	343	2
2251	2016-03-12	00:31:22	1345	5836	230	42	0
2253	2017-04-03	00:13:38	1356	4899	349	393	0
2254	2016-11-24	00:20:23	826	1570	255	62	0
2255	2016-12-03	00:32:16	136	298	252	157	0
2256	2017-01-01	00:18:37	1839	1599	94	320	0
2257	2017-01-23	00:45:17	1252	136	309	262	2
2259	2016-09-12	00:51:04	1301	5901	152	263	2
2260	2017-06-11	00:46:04	1846	2953	29	12	2
2261	2016-04-19	00:49:46	1476	5109	24	368	2
2262	2016-11-16	00:23:12	455	5868	65	29	0
2264	2017-10-20	00:48:35	1719	2893	14	293	2
2265	2017-07-03	00:13:00	1051	5324	318	317	0
2266	2016-10-07	00:18:10	1573	1410	129	16	0
2267	2016-01-19	00:45:45	201	2844	111	366	2
2268	2017-11-01	00:53:55	1069	994	339	126	2
2270	2016-06-02	00:42:51	1547	1276	171	342	0
2271	2016-01-07	00:05:39	1573	5429	41	172	0
2272	2017-02-19	00:49:32	1540	1	389	339	2
2273	2016-11-10	00:54:24	529	1621	184	374	2
2274	2016-06-09	00:38:51	760	4285	311	136	0
2276	2017-04-13	00:09:41	724	5108	125	323	0
2277	2017-04-19	00:58:56	1654	3269	87	144	2
2278	2017-05-25	00:40:11	667	814	368	17	0
2279	2017-07-08	00:44:49	191	6448	282	119	0
2281	2017-06-04	00:43:59	322	3064	357	11	0
2282	2016-02-22	00:12:20	858	6406	201	354	0
2283	2017-03-06	00:07:03	246	5465	171	246	0
2284	2016-11-18	00:20:42	1917	2948	285	169	0
2285	2017-10-18	00:02:12	864	5192	121	27	0
2287	2016-07-21	00:28:43	1013	3761	350	356	0
2288	2017-08-20	00:24:06	1231	5392	78	107	0
2289	2017-07-17	00:49:16	338	6123	75	254	2
2290	2016-05-20	00:01:36	687	3438	349	365	0
2291	2016-01-19	00:11:15	13	2094	17	123	0
2293	2016-12-09	00:17:02	1766	666	210	390	0
2294	2017-01-23	00:03:55	408	5381	60	94	0
2295	2016-06-04	00:51:39	733	3262	354	97	2
2296	2017-04-22	00:22:33	744	4620	354	269	0
2298	2016-09-16	00:49:37	112	813	398	242	2
2299	2016-02-06	00:04:05	844	4132	53	138	0
2300	2017-04-25	00:43:16	598	929	349	226	0
2301	2017-08-28	00:23:32	9	3001	148	88	0
2302	2017-06-24	00:29:01	243	666	50	111	0
2304	2017-11-21	00:43:35	702	197	189	116	0
2305	2016-08-17	00:31:04	1194	1872	149	340	0
2306	2016-03-23	00:33:18	537	4820	201	149	0
2307	2016-02-12	00:48:32	924	4202	216	22	2
2308	2017-01-15	00:07:19	272	1924	34	152	0
2310	2016-07-15	00:38:09	846	667	22	21	0
2311	2017-11-11	00:19:31	1835	1005	209	63	0
2312	2016-11-18	00:51:46	1595	3914	264	118	2
2315	2016-06-04	00:09:32	1001	5460	373	136	0
2316	2017-12-16	00:23:51	613	803	293	96	0
2317	2017-03-26	00:30:54	856	1654	163	38	0
2318	2017-06-14	00:35:03	1194	1746	23	279	0
2319	2016-09-08	00:53:32	552	5947	67	29	2
2321	2016-02-23	00:46:56	508	4371	9	23	2
2322	2017-01-21	00:22:26	1562	3997	235	77	0
2323	2017-08-20	00:11:42	543	4554	242	121	0
2324	2017-01-03	00:18:03	832	471	354	214	0
2325	2017-04-13	00:40:42	1298	185	196	176	0
2327	2017-08-20	00:57:58	1846	5267	291	335	2
2328	2016-01-01	00:43:45	12	3701	153	177	0
2329	2017-02-21	00:08:56	1907	2080	341	174	0
2330	2016-12-18	00:58:27	135	6195	326	290	2
2332	2016-06-11	00:21:40	1187	1442	391	159	0
2333	2016-10-11	00:22:46	211	4420	259	350	0
2334	2017-06-26	00:30:58	1191	2013	284	28	0
2335	2017-01-21	00:21:48	1100	5219	244	128	0
2336	2016-05-12	00:47:11	1511	1971	362	280	2
2338	2016-10-10	00:58:04	934	2816	132	329	2
2339	2016-07-03	00:45:42	597	3691	167	329	2
2340	2017-02-13	00:12:49	221	4556	228	13	0
2341	2017-12-18	00:36:50	929	6064	57	19	0
2342	2016-09-28	00:57:31	1291	6602	122	175	2
2344	2017-06-07	00:22:55	1305	4720	322	370	0
2345	2016-09-20	00:18:28	1870	740	230	191	0
2346	2017-01-14	00:55:30	1616	416	3	94	2
2347	2016-03-07	00:19:48	985	6593	205	37	0
2349	2016-06-03	00:34:52	1855	1219	332	24	0
2350	2017-07-13	00:28:36	325	1774	266	93	0
2351	2017-01-18	00:50:23	1789	2629	241	219	2
2352	2016-01-02	00:44:36	495	4609	289	360	0
2353	2016-11-20	00:38:27	1580	5681	99	164	0
2355	2017-04-18	00:13:45	1471	2429	190	43	0
2356	2017-03-15	00:14:53	1950	3411	332	360	0
2357	2016-12-28	00:52:28	1190	1682	329	146	2
2358	2017-10-22	00:39:08	232	6581	373	190	0
2359	2017-04-04	00:20:31	1250	3613	137	185	0
2361	2016-02-15	00:56:39	1253	1470	378	41	2
2362	2016-04-06	00:12:35	667	6558	124	197	0
2363	2016-09-24	00:29:14	1310	3988	146	397	0
2364	2016-08-05	00:28:25	1155	984	256	104	0
2366	2016-10-20	00:15:40	318	6042	392	7	0
2367	2017-07-06	00:40:44	1187	2923	42	29	0
2368	2017-01-22	00:11:17	1197	3019	143	101	0
2369	2016-04-12	00:13:44	276	757	383	399	0
2370	2016-08-01	00:44:35	1395	6179	189	397	0
2372	2016-07-03	00:32:56	505	97	46	65	0
2373	2017-07-02	00:10:21	710	455	367	259	0
2374	2016-12-24	00:02:47	1920	4463	369	355	0
2375	2016-09-12	00:23:38	260	2212	283	125	0
2376	2016-03-24	00:21:55	144	1114	188	125	0
2378	2016-01-11	00:01:20	905	5024	113	350	0
2379	2017-05-14	00:53:10	1675	3660	295	114	2
2380	2017-01-16	00:30:33	497	6452	192	359	0
2381	2016-04-01	00:53:44	1192	1343	326	372	2
2383	2016-10-27	00:52:38	264	933	380	370	2
2384	2017-08-08	00:13:38	14	4910	15	178	0
2385	2017-11-16	00:26:50	1912	5774	238	8	0
2386	2017-05-03	00:32:50	250	737	47	225	0
2387	2016-03-01	00:12:31	1442	142	8	373	0
2389	2017-03-24	00:17:32	678	4421	373	64	0
2390	2017-11-22	00:19:51	1311	3260	183	171	0
2391	2016-12-24	00:01:34	1733	2974	265	357	0
2392	2016-09-01	00:16:17	1703	1360	102	301	0
2393	2016-09-05	00:29:39	1388	5560	84	395	0
2395	2016-09-07	00:27:37	1362	5632	177	120	0
2396	2017-10-18	00:25:38	1576	1888	172	80	0
2397	2016-07-23	00:09:46	1375	5665	268	120	0
2398	2017-02-15	00:20:56	1627	1429	26	387	0
2400	2017-03-21	00:46:03	211	361	351	272	2
2401	2016-05-21	00:39:28	1219	4835	274	369	0
2402	2017-08-02	00:02:33	1109	3348	313	5	0
2403	2016-05-07	00:24:51	204	3786	202	359	0
2404	2016-08-26	00:26:45	440	5846	388	170	0
2406	2017-07-24	00:39:03	239	1614	191	261	0
2407	2016-09-07	00:00:12	972	3779	338	95	0
2408	2017-08-02	00:55:52	852	2575	106	395	2
2409	2017-12-25	00:36:37	932	2039	176	277	0
2410	2016-01-03	00:55:41	140	1899	130	222	2
2412	2016-01-22	00:03:14	1901	2435	346	366	0
2413	2016-04-23	00:04:24	1305	2407	39	128	0
2414	2017-03-10	00:47:42	788	494	47	193	2
2415	2017-05-19	00:23:35	1005	2799	279	212	0
2417	2017-10-03	00:15:16	19	4846	350	376	0
2418	2017-06-07	00:30:37	806	4519	382	127	0
2419	2016-12-22	00:36:41	1563	5671	230	333	0
2420	2016-10-08	00:51:36	729	5815	161	334	2
2421	2017-05-21	00:30:10	21	1565	92	286	0
2423	2017-01-19	00:36:56	659	2321	134	7	0
2424	2017-05-09	00:55:17	102	4019	372	123	2
2425	2016-05-19	00:31:08	314	1087	200	315	0
2426	2017-12-13	00:05:42	805	6278	223	227	0
2427	2017-11-05	00:43:49	318	902	159	344	0
2429	2017-05-25	00:05:33	297	36	224	213	0
2430	2017-09-14	00:49:22	1650	5539	198	372	2
2431	2017-01-11	00:15:51	1022	3072	140	331	0
2432	2017-11-19	00:14:03	29	5686	30	237	0
2434	2017-06-26	00:01:29	1984	1182	156	85	0
2435	2017-03-12	00:18:47	1826	1983	36	299	0
2436	2017-02-17	00:55:12	1550	5730	346	315	2
2437	2016-08-22	00:13:46	1454	2557	274	288	0
2438	2017-07-12	00:21:17	46	4513	9	346	0
2440	2016-03-05	00:49:20	1642	4516	321	223	2
2441	2017-11-25	00:02:15	1692	4945	368	268	0
2442	2016-07-16	00:25:54	332	3851	363	36	0
2443	2016-12-18	00:42:23	499	3031	17	60	0
2444	2016-03-06	00:48:50	1389	3471	253	194	2
2446	2017-10-11	00:53:14	832	1719	233	153	2
2447	2017-09-10	00:07:13	80	3783	54	247	0
2448	2017-05-18	00:06:42	1473	1523	151	305	0
2451	2017-11-12	00:02:11	1327	5676	186	37	0
2452	2017-04-03	00:05:13	141	2811	244	251	0
2453	2017-10-25	00:28:01	1657	434	3	224	0
2454	2017-12-18	00:41:52	1490	3875	251	370	0
2455	2016-06-03	00:49:11	1040	4235	84	1	2
2457	2016-03-18	00:54:04	1205	5652	138	379	2
2458	2017-08-03	00:00:45	1587	796	181	167	0
2459	2017-01-08	00:09:54	1861	3766	289	275	0
2460	2016-07-02	00:55:18	132	3630	380	77	2
2461	2016-04-02	00:46:30	975	3561	279	215	2
2463	2017-02-10	00:27:05	1418	4096	177	212	0
2464	2017-01-21	00:19:51	1936	6615	241	192	0
2465	2017-09-15	00:28:40	649	1315	376	321	0
2466	2016-06-22	00:47:40	616	4626	361	64	2
2468	2016-12-04	00:51:48	542	4687	227	360	2
2469	2017-07-22	00:39:04	1513	5150	104	326	0
2470	2016-12-11	00:56:29	1680	5976	81	117	2
2471	2017-07-19	00:38:59	359	6411	220	77	0
2472	2016-02-04	00:52:25	805	933	228	142	2
2474	2016-05-21	00:58:09	525	4897	383	323	2
2475	2017-05-06	00:57:18	1906	6209	360	225	2
2476	2017-07-07	00:28:24	596	4044	333	103	0
2477	2016-07-26	00:11:12	1902	4949	170	341	0
2478	2017-02-13	00:10:42	660	5475	260	388	0
2480	2016-03-05	00:10:52	1851	623	57	13	0
2481	2017-12-23	00:59:07	519	4433	347	283	2
2482	2017-03-23	00:44:51	1626	5071	73	179	0
2483	2016-07-28	00:44:16	1858	6337	298	243	0
2485	2016-07-09	00:38:59	52	450	44	378	0
2486	2016-01-27	00:34:57	821	6562	132	84	0
2487	2016-09-11	00:11:33	1280	750	360	377	0
2488	2017-03-01	00:47:25	9	5401	371	318	2
2489	2016-06-12	00:46:53	1712	2944	109	271	2
2491	2016-06-19	00:06:23	684	159	172	75	0
2492	2017-02-13	00:09:56	1075	6002	119	250	0
2493	2016-03-17	00:25:26	1829	2246	22	369	0
2494	2016-06-18	00:15:27	207	1215	77	375	0
2495	2017-02-15	00:42:34	73	110	265	386	0
2497	2017-04-08	00:52:17	424	5516	227	375	2
2498	2016-04-16	00:20:21	1040	1743	85	172	0
2499	2016-05-13	00:08:42	648	5822	64	110	0
2500	2016-06-23	00:17:49	78	5435	181	309	0
2502	2016-10-10	00:44:05	1897	5499	220	203	0
2503	2016-04-08	00:39:06	1779	3993	102	273	0
2504	2016-07-01	00:45:09	10	868	71	252	2
2505	2017-01-07	00:32:22	283	1298	316	86	0
2506	2017-02-06	00:54:40	901	243	67	350	2
2508	2017-03-01	00:32:24	920	3098	286	385	0
2509	2016-06-02	00:29:47	1578	2252	165	229	0
2510	2017-11-11	00:32:10	548	4433	259	214	0
2511	2017-03-16	00:33:45	1712	2476	354	205	0
2512	2017-05-10	00:48:38	1132	4694	84	174	2
2514	2017-12-18	00:27:14	1402	3900	61	386	0
2515	2016-02-25	00:20:53	1143	5760	312	360	0
2516	2016-10-10	00:55:09	586	3646	224	314	2
2517	2017-11-12	00:33:47	1051	4212	93	65	0
2519	2017-10-14	00:23:52	1143	1826	261	370	0
2520	2017-01-01	00:32:01	214	3470	92	347	0
2521	2016-01-19	00:03:51	1536	6091	134	284	0
2522	2016-11-10	00:05:52	1143	5769	62	315	0
2523	2016-10-19	00:25:49	758	3366	82	260	0
2525	2016-03-12	00:34:10	1105	1236	2	281	0
2526	2017-08-20	00:40:55	1901	1016	239	384	0
2527	2017-06-24	00:11:23	1153	1217	390	315	0
2528	2017-10-16	00:32:08	1472	1042	32	70	0
2529	2016-12-22	00:46:10	372	1515	232	343	2
2531	2016-07-20	00:53:58	928	720	281	118	2
2532	2016-01-18	00:58:24	1536	6276	114	183	2
2533	2017-04-12	00:21:08	592	646	206	115	0
2534	2016-04-08	00:25:51	941	1814	302	175	0
2536	2016-07-18	00:34:18	1980	1126	223	220	0
2537	2016-01-02	00:03:07	858	766	191	177	0
2538	2016-02-23	00:29:51	726	2841	331	59	0
2539	2016-06-01	00:32:43	40	6262	321	237	0
2540	2017-06-24	00:08:39	267	2097	148	373	0
2542	2017-03-14	00:16:38	1460	3369	201	116	0
2543	2017-11-07	00:23:30	53	5322	22	361	0
2544	2017-03-25	00:56:54	1128	1247	92	70	2
2545	2017-01-20	00:44:44	185	6099	139	299	0
2546	2016-05-19	00:58:22	409	542	214	287	2
2548	2016-03-23	00:59:24	505	4556	160	245	2
2549	2017-02-20	00:20:36	753	3375	153	263	0
2550	2017-10-16	00:52:43	610	6403	90	361	2
2551	2017-02-13	00:49:30	1561	3209	32	16	2
2553	2017-07-10	00:42:01	1272	5576	217	150	0
2554	2017-06-22	00:36:08	1876	2869	233	356	0
2555	2017-09-02	00:50:27	280	4693	104	68	2
2556	2017-07-20	00:01:48	1207	4956	300	103	0
2557	2017-11-28	00:00:32	805	4749	62	338	0
2559	2016-09-03	00:11:22	612	5036	207	371	0
2560	2016-10-21	00:12:47	580	3595	84	49	0
2561	2017-05-09	00:10:50	1954	6303	189	228	0
2562	2017-07-18	00:44:25	1202	5527	40	50	0
2563	2017-12-23	00:16:52	448	2436	15	13	0
2565	2016-02-27	00:14:14	660	942	343	243	0
2566	2017-07-02	00:50:24	641	2689	76	53	2
2567	2016-05-24	00:16:22	1496	4357	345	183	0
2568	2016-10-08	00:49:18	1919	168	287	291	2
2570	2016-10-16	00:52:36	1557	3278	394	316	2
2571	2017-02-26	00:32:45	775	653	139	317	0
2572	2017-01-16	00:15:25	1714	6175	98	214	0
2573	2017-10-21	00:42:37	1228	1893	194	376	0
2574	2017-08-05	00:02:37	1352	3738	156	161	0
2576	2017-01-22	00:26:58	450	5681	5	362	0
2577	2017-01-19	00:57:35	988	3905	382	241	2
2578	2016-06-05	00:58:42	1226	3646	24	349	2
2579	2016-02-04	00:04:13	1065	4963	145	95	0
2580	2016-02-03	00:15:31	553	5717	194	307	0
2582	2017-11-25	00:50:59	517	2910	110	100	2
2583	2016-04-13	00:41:58	795	4502	348	296	0
2584	2017-04-10	00:10:21	474	4744	37	398	0
2587	2017-07-19	00:58:47	1701	1409	2	317	2
2588	2016-01-09	00:04:00	516	347	220	189	0
2589	2016-11-20	00:39:53	390	2330	174	288	0
2590	2016-07-27	00:25:46	1818	1172	373	200	0
2591	2016-03-14	00:10:57	1816	4522	197	92	0
2593	2016-07-09	00:40:02	116	1483	35	19	0
2594	2016-12-14	00:44:20	1716	2187	23	38	0
2595	2017-05-21	00:55:20	717	5678	310	54	2
2596	2017-04-14	00:04:19	30	4981	63	358	0
2597	2016-10-25	00:42:00	1438	6427	313	89	0
2599	2017-04-22	00:16:49	1226	6140	153	80	0
2600	2016-04-02	00:29:11	504	3385	379	85	0
2601	2017-02-05	00:38:05	267	4573	53	198	0
2602	2017-04-05	00:39:45	229	1363	116	263	0
2604	2016-10-22	00:18:01	17	5586	110	328	0
2605	2016-04-15	00:34:03	265	2433	395	242	0
2606	2017-11-25	00:06:08	1365	4292	15	50	0
2607	2016-10-23	00:54:01	61	6137	48	277	2
2608	2017-11-08	00:31:09	1742	6084	20	333	0
2610	2017-07-11	00:19:38	1394	157	182	114	0
2611	2017-03-01	00:28:09	510	2720	52	23	0
2612	2017-03-25	00:16:17	63	4967	42	70	0
2613	2017-11-06	00:36:37	206	4308	82	51	0
2614	2017-10-28	00:15:12	372	1470	371	47	0
2616	2016-05-22	00:04:49	1977	4821	269	28	0
2617	2017-11-20	00:29:14	1824	4589	187	14	0
2618	2017-04-01	00:14:14	618	3577	223	149	0
2619	2017-04-23	00:55:26	1730	3325	195	244	2
2621	2016-11-10	00:45:45	1000	4245	118	279	2
2622	2016-12-09	00:37:35	1970	2286	177	14	0
2623	2017-06-02	00:35:35	320	6397	158	284	0
2624	2016-02-27	00:30:02	1545	3724	283	317	0
2625	2016-05-22	00:20:28	1488	3438	65	119	0
2627	2016-07-02	00:37:01	747	4042	370	390	0
2628	2017-09-27	00:33:23	1585	5204	392	252	0
2629	2016-03-07	00:48:58	1250	2785	217	201	2
2630	2016-06-08	00:09:39	69	4154	40	41	0
2631	2016-12-03	00:52:24	530	5380	345	233	2
2633	2017-07-13	00:46:41	181	4770	351	185	2
2634	2016-06-26	00:05:17	1563	5267	318	382	0
2635	2017-05-07	00:24:06	1282	4357	251	372	0
2636	2017-05-25	00:49:16	1452	3390	73	319	2
2638	2016-03-05	00:40:39	909	885	214	122	0
2639	2017-07-03	00:43:22	1992	3600	30	333	0
2640	2017-12-25	00:21:11	161	2054	156	84	0
2641	2016-11-15	00:38:04	749	1178	286	187	0
2642	2017-01-03	00:28:26	1556	2648	356	97	0
2644	2017-03-21	00:34:43	1149	6202	268	259	0
2645	2016-08-03	00:37:52	1340	6172	183	322	0
2646	2016-04-28	00:22:14	677	3517	270	127	0
2647	2016-05-03	00:14:29	618	4277	296	83	0
2648	2017-03-17	00:50:29	1563	1032	199	35	2
2650	2016-11-12	00:25:05	74	1451	18	263	0
2651	2016-04-09	00:16:59	179	1727	145	269	0
2652	2017-11-28	00:03:50	1591	2296	301	208	0
2653	2016-08-11	00:23:40	607	3170	90	27	0
2655	2016-03-04	00:32:12	703	4490	317	278	0
2656	2017-08-20	00:19:40	899	6145	149	166	0
2657	2016-04-17	00:06:47	1930	2491	105	373	0
2658	2016-08-22	00:06:26	1502	1187	309	16	0
2659	2016-08-19	00:50:08	1517	6370	199	129	2
2661	2016-09-01	00:08:07	323	3249	73	23	0
2662	2017-11-08	00:21:52	1438	73	382	223	0
2663	2017-08-22	00:44:43	194	2163	364	6	0
2664	2017-05-10	00:41:04	570	2008	248	280	0
2665	2016-06-04	00:21:32	182	2786	377	134	0
2667	2017-04-02	00:29:36	1461	4936	283	83	0
2668	2017-12-13	00:27:57	1031	1851	186	31	0
2669	2017-06-10	00:56:21	31	5558	137	43	2
2670	2017-09-22	00:48:38	646	3198	132	285	2
2672	2016-10-03	00:54:55	1054	3789	354	3	2
2673	2016-12-03	00:15:37	99	5217	355	359	0
2674	2016-11-08	00:53:39	1734	4906	248	221	2
2675	2016-07-16	00:20:24	1762	5806	91	86	0
2676	2016-09-15	00:00:13	1912	5886	300	367	0
2678	2017-01-05	00:56:48	379	2958	209	216	2
2679	2017-03-14	00:11:28	833	1599	241	270	0
2680	2017-09-28	00:10:49	1493	5397	247	343	0
2681	2017-06-15	00:52:16	649	3710	340	153	2
2682	2017-07-24	00:30:30	622	4035	235	275	0
2684	2016-11-14	00:26:44	117	2994	278	101	0
2685	2017-04-06	00:35:17	1342	1007	14	272	0
2686	2017-06-08	00:50:22	1785	2987	368	129	2
2687	2017-05-06	00:23:48	923	5704	391	62	0
2689	2017-12-01	00:11:16	1284	5236	48	368	0
2690	2016-07-19	00:17:57	606	3014	396	63	0
2691	2016-02-04	00:55:32	87	2258	296	395	2
2692	2017-02-20	00:15:26	1829	1072	352	8	0
2693	2016-01-26	00:28:17	1478	4311	31	7	0
2695	2017-05-18	00:03:46	1535	2050	198	393	0
2696	2016-07-07	00:16:36	1707	4907	241	146	0
2697	2016-07-17	00:48:25	1232	1359	311	81	2
2698	2016-06-20	00:55:43	104	6433	1	275	2
2699	2016-12-09	00:54:17	515	3101	116	330	2
2701	2016-03-18	00:10:34	528	2433	293	386	0
2702	2016-01-15	00:42:53	243	3319	31	96	0
2703	2017-03-08	00:34:19	1137	5161	110	55	0
2704	2017-04-10	00:29:59	1370	1353	392	334	0
2706	2017-04-01	00:46:24	585	2884	179	315	2
2707	2017-06-25	00:59:51	1435	574	22	260	2
2708	2016-02-20	00:35:42	1060	1946	29	141	0
2709	2017-04-14	00:52:16	1036	5134	263	371	2
2710	2016-08-04	00:46:27	794	2005	82	124	2
2712	2017-05-04	00:22:45	1579	6582	178	172	0
2713	2016-03-26	00:20:16	406	4483	243	77	0
2714	2017-04-15	00:31:12	1210	512	30	158	0
2715	2016-02-05	00:43:10	1934	1061	144	308	0
2716	2016-07-24	00:36:47	1665	3239	137	48	0
2718	2017-10-05	00:14:28	1215	4602	10	39	0
2719	2017-09-17	00:45:56	599	1105	79	57	2
2720	2016-12-17	00:58:21	1079	4533	43	95	2
2723	2017-11-07	00:02:26	1550	2933	379	327	0
2724	2017-04-25	00:04:07	509	5284	376	87	0
2725	2017-06-03	00:05:10	975	3864	253	141	0
2726	2017-03-23	00:37:32	849	2617	160	166	0
2727	2016-02-24	00:07:57	878	4840	108	168	0
2729	2017-06-09	00:21:13	745	2453	60	287	0
2730	2017-09-25	00:47:01	343	5235	242	361	2
2731	2016-01-09	00:39:37	1278	4460	395	77	0
2732	2017-12-26	00:59:59	1197	6323	202	75	2
2733	2017-10-15	00:20:48	1280	5250	143	288	0
2735	2017-05-17	00:05:08	838	5102	185	385	0
2736	2017-05-28	00:18:22	615	2722	340	24	0
2737	2017-03-10	00:24:43	1211	309	331	114	0
2738	2016-06-12	00:48:58	692	403	235	320	2
2740	2016-01-10	00:07:22	1205	4303	228	353	0
2741	2017-11-17	00:15:21	1733	4938	90	189	0
2742	2017-02-01	00:54:23	1414	4087	275	370	2
2743	2016-06-07	00:11:35	958	1703	201	101	0
2744	2016-10-28	00:28:34	543	528	395	21	0
2746	2016-02-15	00:43:31	1729	5533	30	60	0
2747	2016-07-06	00:45:21	1601	2299	154	346	2
2748	2017-09-21	00:19:26	1024	4492	235	247	0
2749	2016-07-01	00:20:01	551	5334	312	269	0
2750	2016-05-12	00:46:19	1576	94	199	251	2
2752	2017-03-17	00:36:23	474	2820	79	297	0
2753	2017-06-19	00:17:18	1821	3531	138	16	0
2754	2017-08-13	00:58:21	728	2787	253	244	2
2755	2016-09-26	00:18:46	534	3719	339	58	0
2757	2016-12-27	00:17:24	162	524	121	140	0
2758	2017-05-22	00:24:53	211	4151	100	271	0
2759	2017-08-12	00:54:25	1489	5825	369	102	2
2760	2016-06-27	00:27:10	946	5492	252	105	0
2761	2016-06-06	00:29:47	68	1589	285	259	0
2763	2017-11-21	00:37:47	970	2346	116	288	0
2764	2017-04-02	00:44:32	256	147	113	271	0
2765	2017-11-17	00:38:34	1475	4973	219	169	0
2766	2017-01-15	00:31:13	1129	5328	393	244	0
2767	2017-01-01	00:52:33	1569	4528	352	194	2
2769	2017-04-04	00:53:34	22	1626	278	184	2
2770	2017-05-28	00:11:51	1529	5496	324	206	0
2771	2016-10-04	00:39:39	251	4959	34	228	0
2772	2017-07-04	00:11:30	1567	3323	373	351	0
2774	2017-03-19	00:41:44	1876	5728	74	219	0
2775	2017-12-14	00:17:48	270	6240	290	72	0
2776	2017-07-15	00:06:02	1463	4553	310	135	0
2777	2017-04-02	00:41:37	1349	2784	346	39	0
2778	2017-09-22	00:15:35	1464	4903	47	400	0
2780	2017-08-22	00:47:57	52	2538	64	173	2
2781	2016-09-12	00:05:52	169	2316	388	13	0
2782	2017-05-27	00:34:53	1223	5731	313	320	0
2783	2016-06-09	00:29:56	1263	3493	91	85	0
2784	2016-03-13	00:49:10	829	5068	143	96	2
2786	2016-10-11	00:08:02	426	1407	240	19	0
2787	2017-11-05	00:32:28	1698	6282	115	297	0
2788	2017-12-21	00:58:04	1341	754	162	56	2
2789	2016-07-11	00:08:37	339	1153	6	282	0
2791	2016-11-15	00:21:24	429	5159	298	296	0
2792	2016-05-15	00:01:55	1999	1712	245	31	0
2793	2016-12-05	00:20:51	213	1960	173	51	0
2794	2016-05-23	00:45:34	1770	6301	326	128	2
2795	2016-11-09	00:55:20	236	2611	34	22	2
2797	2016-02-07	00:15:41	317	936	238	81	0
2798	2016-10-02	00:34:47	715	2374	112	109	0
2799	2016-10-08	00:13:48	823	3222	152	352	0
2800	2017-08-21	00:23:37	1563	6059	92	27	0
2801	2016-12-01	00:29:22	1057	5413	342	315	0
2803	2016-03-10	00:42:41	811	782	187	189	0
2804	2016-03-19	00:40:22	181	3478	372	27	0
2805	2016-07-26	00:41:53	1055	4267	265	42	0
2806	2016-06-11	00:43:05	54	4401	105	13	0
2808	2017-02-12	00:35:38	967	808	151	213	0
2809	2017-09-14	00:36:31	47	4037	10	293	0
2810	2016-06-23	00:45:41	227	4074	326	112	2
2811	2017-10-20	00:58:40	6	2974	132	256	2
2812	2017-09-25	00:10:57	98	5062	44	229	0
2814	2016-08-19	00:42:52	224	3893	6	138	0
2815	2016-01-15	00:36:41	450	1199	342	351	0
2816	2016-10-12	00:59:38	1252	4036	254	137	2
2817	2017-12-07	00:11:17	1611	806	142	117	0
2818	2016-02-12	00:09:09	1125	5	377	41	0
2820	2017-10-07	00:02:17	14	758	46	147	0
2821	2017-12-19	00:05:50	69	6660	376	122	0
2822	2017-05-07	00:01:45	1102	1944	164	128	0
2823	2017-09-23	00:11:20	1079	132	154	144	0
2825	2016-08-19	00:47:02	465	5315	130	320	2
2826	2017-02-17	00:51:34	1094	6447	161	264	2
2827	2017-07-18	00:53:44	1063	5459	219	388	2
2828	2017-09-22	00:30:17	1161	1232	130	341	0
2829	2016-08-14	00:39:14	593	6434	74	237	0
2831	2016-04-17	00:54:48	1034	6431	260	366	2
2832	2016-09-28	00:18:41	1416	6308	320	108	0
2833	2016-03-18	00:22:12	943	852	238	124	0
2834	2016-05-14	00:17:43	835	899	23	136	0
2835	2017-06-25	00:07:35	1749	5858	234	135	0
2837	2016-08-17	00:41:48	1704	3040	126	293	0
2838	2016-04-20	00:48:15	322	2694	214	172	2
2839	2016-03-19	00:59:37	1154	312	239	99	2
2840	2016-01-16	00:23:23	34	6622	307	116	0
2842	2017-11-01	00:21:27	485	2299	231	383	0
2843	2017-05-05	00:16:08	1600	4657	13	232	0
2844	2017-02-16	00:10:54	1118	3320	291	374	0
2845	2016-09-03	00:19:13	1035	6369	19	260	0
2846	2016-06-11	00:50:49	167	258	224	173	2
2848	2017-11-27	00:33:47	1908	294	175	183	0
2849	2016-12-04	00:30:25	1832	1067	362	224	0
2850	2017-04-28	00:00:19	860	4092	44	380	0
2851	2016-06-16	00:35:48	488	5483	191	245	0
2852	2016-01-17	00:46:23	633	1624	300	330	2
2854	2017-01-08	00:19:00	461	3661	72	336	0
2855	2016-01-21	00:14:28	1057	6478	342	132	0
2856	2016-09-12	00:23:21	1810	2903	166	130	0
2859	2016-04-28	00:23:38	112	6022	386	366	0
2860	2016-09-03	00:22:01	1639	5301	115	305	0
2861	2016-08-13	00:51:59	213	5218	101	175	2
2862	2017-08-06	00:07:18	430	5503	166	241	0
2863	2016-05-22	00:56:25	95	1065	9	305	2
2865	2017-05-05	00:59:26	100	2237	323	114	2
2866	2016-08-09	00:37:50	113	4394	185	364	0
2867	2016-07-06	00:49:00	1614	5470	260	357	2
2868	2017-02-01	00:56:39	1722	5384	235	366	2
2869	2016-08-22	00:50:48	569	5202	181	359	2
2871	2017-04-22	00:55:00	1342	5958	204	242	2
2872	2016-05-23	00:31:47	684	1259	349	216	0
2873	2017-01-11	00:03:42	1116	6294	230	54	0
2874	2017-10-14	00:58:40	659	244	293	80	2
2876	2016-03-06	00:11:43	1324	3237	40	321	0
2877	2017-08-02	00:24:13	1075	4604	204	84	0
2878	2016-01-08	00:38:52	656	2008	253	142	0
2879	2016-07-05	00:25:12	1742	3876	12	29	0
2880	2017-01-23	00:20:57	1760	2441	217	367	0
2882	2017-08-23	00:57:03	852	4919	334	126	2
2883	2016-12-13	00:03:58	1545	4974	242	331	0
2884	2017-09-24	00:40:31	1652	3646	259	257	0
2885	2016-09-02	00:04:48	511	3894	44	385	0
2886	2016-03-21	00:50:56	260	1673	384	122	2
2888	2017-09-09	00:21:29	591	6321	229	328	0
2889	2016-09-21	00:41:31	1287	5268	309	215	0
2890	2017-12-23	00:22:59	1479	2651	222	360	0
2891	2016-06-09	00:14:15	330	4210	378	56	0
2893	2017-06-05	00:47:53	235	5317	50	108	2
2894	2017-02-22	00:52:59	1368	3150	189	100	2
2895	2017-02-01	00:11:15	299	5373	169	75	0
2896	2017-03-11	00:32:38	461	1688	155	17	0
2897	2016-06-20	00:40:59	548	755	201	319	0
2899	2016-07-24	00:52:17	586	4372	253	268	2
2900	2017-05-19	00:35:58	415	4859	315	157	0
2901	2016-03-20	00:07:27	1109	787	292	358	0
2902	2017-04-27	00:03:50	1877	216	86	318	0
2903	2016-04-28	00:45:06	882	5244	194	66	2
2905	2016-09-20	00:25:36	295	4903	235	82	0
2906	2017-10-09	00:48:21	1633	424	276	185	2
2907	2017-06-10	00:34:07	678	4642	283	308	0
2908	2017-11-08	00:30:37	1184	4825	32	91	0
2910	2017-03-21	00:13:33	1616	6097	127	369	0
2911	2017-01-13	00:15:06	1118	2614	335	185	0
2912	2017-06-13	00:18:08	717	1874	205	181	0
2913	2016-06-23	00:24:45	1714	2348	378	235	0
2914	2017-02-25	00:09:30	1152	5843	371	53	0
2916	2017-01-23	00:29:56	1489	5192	6	188	0
2917	2016-10-05	00:12:57	1855	5843	342	223	0
2918	2016-05-18	00:25:16	902	3628	111	259	0
2919	2017-09-22	00:54:48	1194	3634	159	254	2
2920	2016-04-04	00:53:23	1706	1751	8	336	2
2922	2016-06-28	00:38:45	531	5635	392	24	0
2923	2017-10-19	00:01:15	1162	2613	377	38	0
2924	2017-10-26	00:42:37	1148	3395	60	266	0
2925	2016-10-18	00:14:12	39	6649	309	136	0
2927	2016-10-24	00:26:19	1536	2536	91	146	0
2928	2016-08-27	00:34:15	238	4089	235	157	0
2929	2017-09-26	00:04:32	1748	4850	51	23	0
2930	2016-02-22	00:41:24	1199	3014	259	373	0
2931	2016-04-07	00:25:45	364	2363	377	304	0
2933	2017-06-05	00:53:59	385	6417	45	308	2
2934	2016-05-05	00:32:15	452	2303	258	377	0
2935	2016-06-14	00:56:02	96	6269	214	328	2
2936	2016-04-25	00:03:08	1375	3067	156	13	0
2937	2017-09-08	00:35:39	1434	1332	330	58	0
2939	2017-10-05	00:55:54	1930	1443	56	97	2
2940	2017-10-28	00:15:47	1245	6544	367	185	0
2941	2017-06-09	00:20:40	886	505	279	189	0
2942	2017-12-23	00:41:03	393	799	268	185	0
2944	2016-04-08	00:09:44	702	2717	113	172	0
2945	2017-12-07	00:01:49	887	5338	54	115	0
2946	2017-11-26	00:15:10	1686	4929	302	211	0
2947	2017-07-05	00:49:04	1134	510	71	333	2
2948	2016-01-06	00:16:47	1750	4600	8	128	0
2950	2017-04-14	00:26:15	1288	630	120	174	0
2951	2016-10-22	00:48:28	1647	2811	165	364	2
2952	2017-06-15	00:21:51	742	2158	323	191	0
2953	2017-01-19	00:07:18	1366	37	39	344	0
2954	2016-11-26	00:38:50	1262	3721	361	76	0
2956	2017-06-26	00:17:45	1098	2878	140	33	0
2957	2017-01-20	00:45:08	1231	3032	354	295	2
2958	2017-10-09	00:28:13	1888	1704	183	97	0
2959	2017-10-05	00:11:27	1284	1759	241	170	0
2961	2017-07-19	00:01:20	1735	84	22	271	0
2962	2016-09-04	00:22:35	280	3588	371	131	0
2963	2016-11-08	00:47:41	1816	3909	236	277	2
2964	2016-06-10	00:11:24	245	3341	264	361	0
2965	2016-08-10	00:55:49	577	2555	22	135	2
2967	2016-03-16	00:29:43	734	1260	122	215	0
2968	2017-07-08	00:59:24	479	3334	361	327	2
2969	2017-12-05	00:31:18	1098	5188	214	258	0
2970	2016-09-01	00:53:52	1979	3722	232	30	2
2971	2016-08-12	00:42:05	586	1694	217	8	0
2973	2017-01-24	00:13:52	1912	639	337	127	0
2974	2017-02-09	00:40:59	81	4885	231	314	0
2975	2017-03-17	00:25:44	550	5131	391	321	0
2976	2017-08-27	00:47:53	1496	2980	376	25	2
2978	2017-06-22	00:12:21	1320	4406	68	173	0
2979	2017-05-20	00:11:19	634	5335	305	223	0
2980	2016-01-17	00:22:08	533	6170	350	159	0
2981	2016-03-21	00:50:23	200	2748	365	101	2
2982	2016-03-13	00:56:52	1468	6293	17	16	2
2984	2017-03-23	00:07:49	1944	612	394	56	0
2985	2016-06-24	00:28:44	1505	3094	186	218	0
2986	2016-04-15	00:42:02	474	1419	246	345	0
2987	2017-04-01	00:48:26	971	1019	23	92	2
2988	2017-08-04	00:56:00	2000	2820	185	89	2
2990	2016-09-07	00:27:50	198	770	130	178	0
2991	2016-01-17	00:44:33	1193	3987	143	341	0
2992	2017-01-09	00:52:06	1230	3547	258	364	2
2995	2016-08-14	00:38:17	1955	4332	138	143	0
2996	2016-05-15	00:52:53	1965	843	301	110	2
2997	2016-09-02	00:17:29	873	4757	34	18	0
2998	2016-09-09	00:08:22	1122	4093	388	266	0
2999	2016-06-02	00:40:16	1199	474	229	51	0
3001	2017-11-02	00:03:30	1337	673	340	159	0
3002	2016-09-21	00:59:49	1231	5303	324	131	2
3003	2017-01-24	00:11:00	185	3769	306	300	0
3004	2017-07-04	00:18:05	630	5096	177	221	0
3005	2016-01-02	00:17:58	1163	5258	131	43	0
3007	2017-12-28	00:04:36	934	511	373	260	0
3008	2017-06-25	00:54:19	909	3960	150	320	2
3009	2016-07-09	00:31:13	276	3173	234	155	0
3010	2016-10-01	00:51:31	666	1452	248	39	2
3012	2016-06-01	00:03:10	499	6372	252	159	0
3013	2017-03-27	00:50:39	1881	4484	34	245	2
3014	2017-11-21	00:06:24	1512	2791	237	172	0
3015	2016-06-03	00:26:50	401	2511	246	62	0
3016	2016-10-12	00:06:17	83	3277	114	160	0
3018	2016-11-12	00:28:50	1932	3483	210	195	0
3019	2016-10-28	00:32:38	1252	482	351	381	0
3020	2017-11-26	00:55:25	354	6302	6	310	2
3021	2017-05-05	00:48:19	974	6507	107	63	2
3022	2017-05-22	00:16:26	1929	885	81	123	0
3024	2017-06-11	00:40:08	1893	5566	65	151	0
3025	2016-03-02	00:43:43	807	3693	54	221	0
3026	2017-07-27	00:49:54	1106	1049	13	324	2
3027	2017-12-18	00:43:20	1601	6277	199	241	0
3029	2017-02-23	00:17:44	1532	428	149	360	0
3030	2017-11-04	00:07:13	40	5270	3	326	0
3031	2016-04-28	00:33:10	598	2905	153	81	0
3032	2016-12-14	00:31:33	243	386	273	140	0
3033	2016-06-15	00:49:30	1053	2312	359	69	2
3035	2016-06-15	00:30:05	396	4172	310	98	0
3036	2016-08-26	00:36:21	1978	6144	12	172	0
3037	2017-01-27	00:02:40	1443	1633	97	243	0
3038	2016-03-11	00:35:29	1867	1520	358	9	0
3039	2016-04-16	00:22:03	574	5879	153	273	0
3041	2016-07-09	00:18:41	421	148	138	259	0
3042	2016-01-07	00:32:26	1873	1397	159	133	0
3043	2016-05-20	00:37:27	214	4657	87	77	0
3044	2017-04-05	00:15:17	1620	6653	341	211	0
3046	2017-08-11	00:53:11	1806	3208	80	279	2
3047	2016-09-24	00:40:35	1750	4054	330	185	0
3048	2016-09-18	00:51:43	1548	4026	222	91	2
3049	2016-01-15	00:04:21	1602	2712	70	22	0
3050	2017-10-06	00:54:48	712	6110	162	286	2
3052	2016-12-10	00:33:08	500	932	280	364	0
3053	2017-03-28	00:22:41	446	4436	47	15	0
3054	2017-07-17	00:03:42	1275	3911	41	400	0
3055	2016-10-06	00:48:56	666	5911	164	41	2
3056	2016-07-10	00:59:05	1895	540	30	90	2
3058	2016-11-20	00:47:47	59	3457	30	287	2
3059	2016-01-15	00:37:47	1093	5191	246	225	0
3060	2016-01-13	00:52:49	956	5544	42	27	2
3061	2017-10-10	00:16:40	319	5988	52	255	0
3063	2016-05-18	00:03:50	1929	650	90	228	0
3064	2016-05-18	00:57:22	1325	4849	213	224	2
3065	2017-09-01	00:39:10	505	796	293	327	0
3066	2017-11-05	00:40:36	1291	2900	101	166	0
3067	2016-05-25	00:16:10	38	1159	59	206	0
3069	2017-09-14	00:52:29	692	5217	223	141	2
3070	2017-03-16	00:58:55	229	5644	147	30	2
3071	2016-03-25	00:30:45	1058	1242	296	269	0
3072	2016-09-09	00:40:06	1790	3120	281	202	0
3073	2016-08-11	00:46:39	1319	1449	249	153	2
3075	2017-02-21	00:09:11	95	2893	268	208	0
3076	2016-10-22	00:45:54	572	5987	62	143	2
3077	2016-12-21	00:59:56	1352	6206	323	4	2
3078	2016-05-01	00:50:28	1204	6190	302	180	2
3080	2016-11-12	00:24:11	934	1520	210	125	0
3081	2016-11-10	00:11:31	256	1108	327	248	0
3082	2017-04-03	00:20:26	1281	2373	202	238	0
3083	2016-10-28	00:24:45	1481	5892	101	286	0
3084	2016-06-23	00:55:59	682	2784	179	47	2
3086	2017-03-05	00:59:02	258	5433	300	3	2
3087	2017-09-15	00:44:01	366	4833	243	314	0
3088	2017-11-07	00:08:57	1112	6656	396	136	0
3089	2016-11-26	00:01:03	19	1374	376	266	0
3090	2017-11-18	00:17:23	1415	5737	376	317	0
3092	2017-02-21	00:31:53	523	5102	72	346	0
3093	2016-01-18	00:49:41	1238	6023	289	26	2
3094	2017-10-05	00:00:34	409	3597	32	45	0
3095	2017-11-12	00:28:29	1259	5243	204	384	0
3097	2016-08-22	00:43:47	1970	944	223	361	0
3098	2016-06-12	00:31:25	1067	4747	98	156	0
3099	2017-08-05	00:48:36	140	1819	115	324	2
3100	2017-09-17	00:57:54	898	6072	315	168	2
3101	2016-02-24	00:52:20	642	2033	66	315	2
3103	2016-07-11	00:09:46	998	3114	197	27	0
3104	2017-04-06	00:52:55	546	4111	197	86	2
3105	2016-10-01	00:17:38	1998	6079	170	304	0
3106	2017-02-12	00:34:00	1374	1062	388	268	0
3107	2016-04-10	00:36:41	180	6274	273	70	0
3109	2017-12-14	00:47:33	94	4012	120	218	2
3110	2017-11-27	00:03:29	493	1552	106	199	0
3111	2016-12-09	00:25:05	1787	4063	204	299	0
3112	2017-03-27	00:34:41	853	5493	355	41	0
3114	2016-01-09	00:41:16	1948	2691	141	343	0
3115	2016-04-09	00:17:57	143	2690	395	246	0
3116	2017-05-09	00:48:03	727	3035	11	163	2
3117	2016-05-05	00:51:05	1698	456	345	77	2
3118	2016-12-25	00:54:38	849	895	367	362	2
3120	2016-03-18	00:55:01	811	2836	208	214	2
3121	2016-07-27	00:30:57	307	1191	354	396	0
3122	2016-02-17	00:20:32	601	829	255	80	0
3123	2016-06-17	00:16:32	769	5821	126	133	0
3124	2017-02-11	00:47:32	926	2632	205	96	2
3126	2017-12-16	00:43:11	667	4344	390	15	0
3127	2017-09-13	00:30:54	736	464	52	281	0
3128	2017-07-09	00:27:11	1721	5312	383	269	0
3131	2017-02-03	00:35:50	17	3810	115	88	0
3132	2016-01-18	00:48:19	1071	3274	215	12	2
3133	2016-06-05	00:18:35	1648	5787	108	370	0
3134	2017-03-26	00:40:59	1288	2190	26	41	0
3135	2016-05-10	00:16:34	543	6052	20	400	0
3137	2017-05-21	00:17:38	1534	4019	338	13	0
3138	2016-07-27	00:39:30	1403	5604	314	318	0
3139	2016-06-10	00:27:33	426	3182	188	371	0
3140	2016-03-15	00:33:13	320	6623	384	80	0
3141	2016-10-26	00:53:09	607	1078	378	10	2
3143	2016-04-12	00:18:18	354	298	83	296	0
3144	2017-10-07	00:14:45	1598	2570	4	212	0
3145	2016-05-15	00:09:31	1386	6490	325	71	0
3146	2017-05-02	00:13:20	796	4834	240	349	0
3148	2016-06-17	00:38:10	1057	4860	307	285	0
3149	2016-02-02	00:39:51	1663	2	295	3	0
3150	2017-07-06	00:50:06	1644	4980	38	265	2
3151	2017-03-02	00:37:31	63	3272	223	139	0
3152	2017-12-07	00:32:39	132	5215	204	359	0
3154	2017-07-25	00:32:29	102	3168	70	125	0
3155	2016-09-06	00:10:22	720	659	47	83	0
3156	2017-09-27	00:27:54	171	2663	251	320	0
3157	2017-01-12	00:51:19	1424	1914	250	44	2
3158	2016-09-21	00:25:57	383	2753	273	166	0
3160	2016-03-09	00:47:43	194	2767	158	95	2
3161	2017-12-18	00:33:42	1832	2379	46	400	0
3162	2017-07-24	00:49:39	1905	6138	248	372	2
3163	2016-02-08	00:59:41	1850	5218	16	285	2
3165	2016-11-12	00:49:56	931	5248	131	391	2
3166	2016-02-10	00:47:26	1689	2115	205	279	2
3167	2016-08-25	00:21:34	639	6065	42	30	0
3168	2016-06-09	00:55:21	945	4047	343	334	2
3169	2016-01-10	00:52:08	1804	3793	133	355	2
3171	2016-08-25	00:37:07	1060	4609	143	394	0
3172	2016-02-12	00:23:35	117	6527	273	316	0
3173	2016-12-15	00:51:05	317	6159	29	105	2
3174	2016-09-01	00:00:50	1257	3851	81	369	0
3175	2016-05-17	00:26:19	691	2347	204	41	0
3177	2016-04-24	00:33:16	1151	3420	89	332	0
3178	2016-08-12	00:41:36	470	3401	6	195	0
3179	2016-02-15	00:19:48	1025	2647	192	282	0
3180	2016-05-17	00:26:04	1066	2155	353	144	0
3182	2017-03-07	00:12:33	888	4501	102	259	0
3183	2016-11-23	00:43:47	1573	1134	308	197	0
3184	2016-08-26	00:59:08	583	1189	86	129	2
3185	2016-07-22	00:32:17	599	202	381	57	0
3186	2016-03-06	00:43:38	482	943	17	40	0
3188	2017-05-06	00:20:20	1397	2993	151	238	0
3189	2016-06-17	00:01:07	1546	2663	333	362	0
3190	2017-08-23	00:02:00	1735	3774	5	197	0
3191	2017-07-24	00:59:41	834	3457	116	308	2
3192	2016-09-24	00:53:16	642	2049	179	333	2
3194	2016-09-05	00:16:52	1327	2316	313	303	0
3195	2016-02-19	00:02:41	171	2421	236	264	0
3196	2017-07-01	00:47:24	1967	1753	106	215	2
3197	2016-01-26	00:26:36	623	2575	42	220	0
3199	2017-05-18	00:00:25	59	4828	315	123	0
3200	2016-11-10	00:43:09	1717	4466	21	82	0
3201	2017-09-08	00:33:03	139	476	310	375	0
3202	2017-05-22	00:19:58	1080	3909	226	113	0
3203	2016-02-28	00:02:58	1959	1471	191	48	0
3205	2016-09-06	00:18:17	1244	887	181	137	0
3206	2016-05-14	00:56:47	1667	3001	51	240	2
3207	2016-02-16	00:06:05	1889	397	173	385	0
3208	2016-10-21	00:57:39	43	5315	215	325	2
3209	2017-02-24	00:20:44	206	174	226	224	0
3211	2016-10-09	00:41:27	151	3964	24	189	0
3212	2016-12-04	00:31:48	1192	708	375	80	0
3213	2017-09-07	00:41:52	1167	2862	266	95	0
3214	2017-02-13	00:57:44	519	3446	177	284	2
3216	2016-12-26	00:00:40	1321	2156	225	102	0
3217	2017-04-12	00:57:37	196	2892	85	30	2
3218	2017-11-01	00:43:52	1360	1692	246	293	0
3219	2016-06-25	00:29:29	1527	303	108	56	0
3220	2016-04-07	00:49:21	1263	1464	181	399	2
3222	2016-02-18	00:14:07	681	5802	150	48	0
3223	2017-08-18	00:14:53	1816	5311	69	285	0
3224	2016-07-17	00:35:45	1998	300	290	348	0
3225	2017-12-14	00:36:06	879	985	83	217	0
3226	2016-05-04	00:12:06	1701	2736	196	329	0
3228	2017-05-19	00:58:26	1114	3098	42	245	2
3229	2016-02-27	00:20:07	408	4364	21	391	0
3230	2016-08-27	00:28:01	1405	663	389	343	0
3231	2017-11-07	00:47:18	471	612	281	90	2
3233	2017-03-24	00:35:36	528	6353	266	13	0
3234	2016-01-02	00:35:51	1919	4342	92	186	0
3235	2017-08-22	00:54:50	1623	3091	224	73	2
3236	2017-09-19	00:11:31	1047	6266	38	146	0
3237	2017-10-06	00:32:13	1218	4774	214	160	0
3239	2016-12-17	00:26:39	1216	2764	41	276	0
3240	2016-10-04	00:20:33	1768	1985	16	308	0
3241	2016-01-21	00:17:46	1115	2898	273	151	0
3242	2016-12-07	00:23:09	1032	813	140	291	0
3243	2017-12-07	00:22:57	1083	2499	173	380	0
3245	2017-01-27	00:59:24	1276	1729	262	157	2
3246	2017-06-19	00:35:23	1279	5331	172	361	0
3247	2016-02-15	00:57:56	207	2529	366	12	2
3248	2016-08-24	00:20:24	574	3400	322	26	0
3250	2017-08-16	00:40:17	21	3981	278	327	0
3251	2016-12-18	00:10:42	151	2004	161	232	0
3252	2016-02-15	00:32:26	1583	3482	73	69	0
3253	2016-01-25	00:26:28	398	4002	356	184	0
3254	2016-02-28	00:29:52	807	4011	8	140	0
3256	2016-02-05	00:05:18	89	3502	191	64	0
3257	2016-09-16	00:17:21	1985	3385	302	218	0
3258	2016-02-09	00:46:58	1655	4750	189	229	2
3259	2017-06-24	00:39:02	994	5450	260	336	0
3260	2016-06-08	00:08:10	1015	5109	249	286	0
3262	2017-06-23	00:55:25	1816	4746	369	65	2
3263	2016-12-22	00:20:15	440	3817	346	240	0
3264	2017-12-19	00:39:57	987	6598	335	209	0
3267	2016-06-20	00:14:00	871	4811	6	217	0
3268	2016-02-01	00:17:49	764	4837	290	243	0
3269	2017-05-25	00:25:13	17	3749	4	320	0
3270	2017-02-17	00:42:05	1542	399	104	228	0
3271	2017-10-07	00:05:33	836	4504	133	39	0
3273	2017-01-09	00:14:15	635	5990	397	260	0
3274	2017-09-05	00:09:07	1015	4303	21	68	0
3275	2017-11-22	00:52:58	863	290	69	124	2
3276	2017-08-16	00:27:52	14	5653	109	55	0
3277	2017-10-15	00:13:33	843	2158	101	183	0
3279	2016-11-09	00:17:28	1946	6182	76	242	0
3280	2016-12-16	00:22:02	201	3285	331	242	0
3281	2016-09-10	00:12:10	1625	511	191	341	0
3282	2016-12-04	00:01:20	1045	5529	151	180	0
3284	2017-06-20	00:46:55	1207	1454	182	390	2
3285	2016-08-11	00:38:49	880	752	97	47	0
3286	2017-05-14	00:07:05	1479	5346	287	76	0
3287	2016-02-08	00:11:37	1777	985	329	283	0
3288	2016-02-28	00:57:42	8	4218	207	348	2
3290	2017-03-21	00:57:22	1113	1042	263	40	2
3291	2017-11-07	00:04:24	1154	6245	39	228	0
3292	2017-03-01	00:55:26	1290	4008	42	70	2
3293	2016-03-20	00:41:58	287	674	8	267	0
3294	2016-08-02	00:17:15	1657	1353	260	396	0
3296	2017-12-11	00:43:00	117	3016	387	34	0
3297	2017-08-02	00:07:29	872	4876	186	12	0
3298	2017-03-16	00:58:24	1123	4871	303	192	2
3299	2016-04-17	00:13:44	956	4951	117	228	0
3301	2017-12-27	00:40:21	1086	2526	260	111	0
3302	2016-12-08	00:17:06	438	5029	339	146	0
3303	2016-01-24	00:40:43	1793	1710	36	45	0
3304	2017-03-11	00:58:04	627	4486	185	322	2
3305	2016-04-15	00:26:26	993	4136	296	235	0
3307	2016-07-25	00:23:54	266	5930	162	206	0
3308	2016-08-22	00:02:40	1279	3853	374	358	0
3309	2017-02-23	00:27:31	1730	3378	346	352	0
3310	2017-10-14	00:09:12	966	3995	211	28	0
3311	2017-08-19	00:38:49	1152	4238	250	52	0
3313	2017-01-02	00:37:16	1976	6442	361	79	0
3314	2016-09-09	00:02:34	515	4516	45	47	0
3315	2017-05-13	00:53:39	1057	2467	44	166	2
3316	2017-01-08	00:06:19	1388	5210	81	180	0
3318	2017-11-10	00:59:39	444	1468	383	84	2
3319	2017-03-09	00:15:35	92	3693	166	328	0
3320	2016-11-26	00:21:35	366	3849	149	293	0
3321	2017-11-21	00:17:52	149	18	377	394	0
3322	2016-10-26	00:42:57	1662	65	198	262	0
3324	2016-11-25	00:44:11	1494	3853	291	17	0
3325	2017-09-16	00:04:14	1030	413	135	125	0
3326	2016-05-23	00:28:47	1301	974	65	349	0
3327	2017-04-01	00:03:07	196	6471	148	173	0
3328	2016-09-27	00:39:01	1235	1011	182	277	0
3330	2016-05-13	00:45:25	440	5551	177	358	2
3331	2016-07-09	00:31:38	169	1843	145	397	0
3332	2016-07-14	00:01:10	1460	5834	225	53	0
3333	2017-02-10	00:18:29	1805	1899	89	383	0
3335	2016-04-02	00:44:09	1803	510	155	90	0
3336	2016-12-07	00:52:24	536	6426	271	185	2
3337	2017-08-11	00:21:39	1345	5372	247	177	0
3338	2017-08-04	00:11:00	934	4090	229	30	0
3339	2017-11-12	00:41:12	1550	5090	329	313	0
3341	2016-04-01	00:00:26	179	4859	361	11	0
3342	2017-07-06	00:01:26	1070	6670	247	283	0
3343	2016-03-07	00:07:00	996	5860	77	231	0
3344	2017-03-25	00:19:28	1298	1255	107	238	0
3345	2016-09-17	00:22:13	170	4587	284	362	0
3347	2017-09-27	00:14:47	1284	1945	154	316	0
3348	2017-09-22	00:30:11	818	5900	238	181	0
3349	2017-11-01	00:38:09	230	3515	319	241	0
3350	2016-11-08	00:27:14	1915	4233	28	393	0
3352	2017-12-23	00:43:12	911	590	357	287	0
3353	2017-04-08	00:29:08	336	480	178	337	0
3354	2017-03-01	00:32:20	379	2876	351	372	0
3355	2016-05-10	00:43:09	1690	285	195	83	0
3356	2017-02-25	00:38:12	1873	2789	374	388	0
3358	2017-02-23	00:02:49	1502	2517	172	215	0
3359	2017-07-06	00:44:45	425	1462	292	190	0
3360	2016-08-27	00:28:50	745	1486	45	222	0
3361	2016-07-04	00:26:49	1062	5733	165	290	0
3362	2017-06-10	00:58:23	1450	5725	109	198	2
3364	2017-01-21	00:31:49	1902	4853	61	111	0
3365	2017-12-04	00:46:48	866	227	134	182	2
3366	2017-02-24	00:45:00	1191	2166	238	217	2
3367	2017-12-23	00:35:43	1606	2617	93	291	0
3369	2016-03-22	00:55:35	1935	1902	333	234	2
3370	2017-06-02	00:59:56	190	5066	356	302	2
3371	2016-05-16	00:32:13	223	2727	238	384	0
3372	2017-08-02	00:28:19	17	3731	69	80	0
3373	2016-01-27	00:52:58	18	6303	134	190	2
3375	2016-04-14	00:26:23	762	6599	200	30	0
3376	2016-11-14	00:44:23	8	6226	104	169	0
3377	2016-11-07	00:20:13	1636	3242	283	312	0
3378	2016-03-15	00:34:24	1612	5824	294	78	0
3379	2016-03-14	00:05:15	709	2361	211	23	0
3381	2017-08-08	00:11:40	1731	4399	25	36	0
3382	2016-06-11	00:01:21	1462	2249	42	126	0
3383	2017-04-11	00:54:09	1779	1853	39	146	2
3384	2016-03-06	00:41:53	1088	5665	292	221	0
3386	2016-04-10	00:15:49	467	2050	70	52	0
3387	2016-07-24	00:51:53	620	1539	66	292	2
3388	2017-01-16	00:42:57	1709	4207	120	98	0
3389	2017-11-21	00:10:03	1967	5618	119	355	0
3390	2016-03-05	00:28:20	1002	3962	169	286	0
3392	2016-05-23	00:33:45	1916	797	266	97	0
3393	2017-09-26	00:47:04	1232	2071	18	395	2
3394	2017-08-01	00:38:59	956	6632	264	295	0
3395	2017-07-12	00:41:34	717	5406	335	284	0
3396	2016-11-04	00:36:49	247	4489	272	185	0
3398	2016-10-10	00:26:14	1601	6092	119	170	0
3399	2016-05-25	00:45:54	406	5118	223	298	2
3400	2017-02-15	00:17:39	86	4384	101	154	0
3403	2016-08-20	00:43:08	514	3616	325	70	0
3404	2016-08-11	00:27:47	922	2200	307	19	0
3405	2017-03-21	00:29:14	597	1602	246	300	0
3406	2016-10-03	00:10:18	43	4416	226	7	0
3407	2017-06-08	00:13:24	1462	4979	223	157	0
3409	2016-04-08	00:29:09	1832	4229	171	269	0
3410	2016-04-23	00:25:11	1726	984	34	74	0
3411	2016-10-15	00:45:50	1881	6501	90	11	2
3412	2016-02-06	00:21:16	1393	678	270	142	0
3413	2017-08-13	00:57:01	1132	2277	74	259	2
3415	2017-08-24	00:48:45	39	4136	243	151	2
3416	2016-11-08	00:06:38	788	4370	276	52	0
3417	2017-05-10	00:44:14	1866	3942	219	288	0
3418	2017-10-01	00:52:35	1355	4105	46	346	2
3420	2017-08-25	00:24:36	1903	2057	236	335	0
3421	2016-10-10	00:13:47	360	3187	319	304	0
3422	2016-04-10	00:02:25	60	393	300	55	0
3423	2016-01-11	00:00:20	1441	754	240	229	0
3424	2016-08-10	00:54:16	79	5846	339	97	2
3426	2016-05-07	00:12:06	404	1699	117	396	0
3427	2017-01-27	00:05:29	1515	5746	394	42	0
3428	2016-01-24	00:27:11	1859	5075	191	22	0
3429	2016-09-03	00:47:23	1260	5322	238	309	2
3430	2016-02-23	00:16:10	1893	5546	182	89	0
3432	2017-04-18	00:55:41	904	1324	301	45	2
3433	2016-12-09	00:12:37	71	6142	97	275	0
3434	2016-08-13	00:45:57	451	4970	198	217	2
3435	2017-08-13	00:55:14	1530	3183	34	208	2
3437	2016-12-01	00:40:52	1742	6407	347	40	0
3438	2017-08-25	00:20:07	535	631	241	92	0
3439	2016-10-21	00:05:26	1228	5941	215	89	0
3440	2016-09-14	00:18:03	1483	3856	115	206	0
3441	2017-08-04	00:34:12	365	4939	320	270	0
3443	2016-08-13	00:38:13	516	795	181	156	0
3444	2017-06-15	00:07:47	1730	4894	8	365	0
3445	2017-11-20	00:43:56	1413	2674	310	291	0
3446	2017-12-23	00:42:47	1812	2968	313	10	0
3447	2016-03-21	00:16:51	342	4513	45	290	0
3449	2016-05-09	00:39:03	1042	5522	4	209	0
3450	2017-02-03	00:58:50	311	5764	171	188	2
3451	2017-04-18	00:59:58	1454	3837	153	225	2
3452	2016-05-23	00:16:58	796	3757	168	95	0
3454	2016-04-21	00:52:08	552	6660	361	5	2
3455	2017-07-23	00:02:24	78	3652	307	212	0
3456	2016-05-21	00:59:29	1815	3210	188	371	2
3457	2017-01-11	00:39:20	1570	3070	17	302	0
3458	2016-12-05	00:21:04	1779	49	248	25	0
3460	2017-12-07	00:45:39	374	888	334	236	2
3461	2017-07-27	00:06:27	1434	4966	335	197	0
3462	2016-04-27	00:23:53	697	3208	128	363	0
3463	2016-07-04	00:14:48	1653	5673	272	376	0
3464	2017-04-10	00:26:26	395	3128	397	198	0
3466	2016-03-07	00:56:06	1768	1632	111	220	2
3467	2017-05-06	00:19:15	316	4087	233	98	0
3468	2016-09-07	00:59:13	1008	4615	211	200	2
3469	2017-12-09	00:51:54	386	2694	171	24	2
3471	2016-11-20	00:26:05	912	840	51	53	0
3472	2017-09-01	00:37:32	1456	6373	121	241	0
3473	2016-11-24	00:24:23	4	5935	46	142	0
3474	2017-03-03	00:19:50	1795	575	362	288	0
3475	2017-08-08	00:13:28	1689	2319	358	157	0
3477	2017-06-24	00:46:33	913	4680	98	214	2
3478	2016-07-18	00:01:09	1391	1751	227	73	0
3479	2016-04-17	00:34:16	756	1541	57	53	0
3480	2016-05-24	00:29:51	663	5064	189	236	0
3481	2017-05-21	00:47:01	1014	240	42	370	2
3483	2017-11-11	00:46:28	166	3368	200	277	2
3484	2017-07-07	00:21:05	918	1884	14	214	0
3485	2017-02-19	00:16:41	137	1825	371	112	0
3486	2017-04-15	00:30:37	930	3378	293	221	0
3488	2016-12-20	00:56:14	1015	1516	183	58	2
3489	2016-09-20	00:14:28	1568	4836	154	320	0
3490	2017-09-09	00:24:03	624	2793	118	209	0
3491	2017-02-19	00:47:59	1702	1617	58	229	2
3492	2017-07-27	00:06:04	1475	5798	176	318	0
3494	2016-06-04	00:15:03	1104	164	345	67	0
3495	2017-01-16	00:56:35	332	3643	7	85	2
3496	2017-11-22	00:43:44	339	4778	169	186	0
3497	2016-05-21	00:37:46	488	1459	307	117	0
3498	2017-10-17	00:26:35	335	3296	149	183	0
3500	2017-01-28	00:08:28	1764	1007	60	242	0
3501	2017-05-09	00:50:18	1397	4363	281	127	2
3502	2017-08-22	00:56:26	865	3337	281	249	2
3503	2017-02-27	00:04:29	1814	5440	392	37	0
3505	2016-12-02	00:01:09	1779	175	168	2	0
3506	2017-09-15	00:43:06	1405	873	191	386	0
3507	2016-06-04	00:56:18	1132	6581	211	387	2
3508	2016-06-28	00:21:13	522	479	6	278	0
3509	2016-07-06	00:21:04	1013	1657	144	289	0
3511	2017-12-06	00:21:26	677	3021	122	294	0
3512	2016-11-15	00:28:00	1309	3785	316	132	0
3513	2016-09-04	00:12:35	810	1041	83	151	0
3514	2017-04-03	00:59:20	1129	4170	295	369	2
3515	2017-09-14	00:48:38	798	230	224	54	2
3517	2017-10-27	00:32:34	201	5749	151	396	0
3518	2017-07-27	00:16:51	463	2050	226	66	0
3519	2016-01-13	00:58:17	1195	5870	265	190	2
3520	2016-08-07	00:17:41	1171	2714	154	267	0
3522	2017-09-09	00:02:01	1005	3610	259	234	0
3523	2017-08-04	00:33:19	187	4088	279	43	0
3524	2016-11-23	00:53:26	1776	6017	330	1	2
3525	2017-04-08	00:22:37	1724	5266	65	301	0
3526	2016-04-07	00:24:23	62	4429	278	294	0
3528	2016-06-23	00:48:33	84	186	277	333	2
3529	2016-12-14	00:34:34	1305	5569	364	119	0
3530	2017-04-07	00:35:47	811	2921	90	144	0
3531	2016-10-25	00:27:53	77	4078	36	92	0
3532	2017-03-23	00:25:30	69	1402	214	178	0
3534	2016-03-25	00:00:46	1830	6473	360	264	0
3535	2017-03-25	00:26:30	434	3750	233	269	0
3536	2017-03-23	00:57:58	1766	3240	7	152	2
3539	2016-01-15	00:49:20	1922	2231	174	162	2
3540	2017-09-03	00:37:18	1082	6416	290	88	0
3541	2017-12-06	00:21:24	1509	5514	182	104	0
3542	2016-09-19	00:24:27	752	3004	268	219	0
3543	2016-10-14	00:22:39	1438	4993	116	152	0
3545	2016-12-08	00:34:53	1458	6273	113	117	0
3546	2016-04-03	00:49:39	984	3916	77	347	2
3547	2016-02-08	00:32:37	457	247	131	232	0
3548	2017-07-10	00:04:25	836	5808	187	186	0
3549	2017-07-02	00:58:38	1246	980	8	277	2
3551	2017-10-24	00:16:39	1667	848	276	400	0
3552	2016-03-10	00:11:24	304	3032	232	202	0
3553	2017-10-20	00:57:24	93	588	52	24	2
3554	2017-10-27	00:33:53	175	3028	338	262	0
3556	2017-07-08	00:19:06	1327	4779	320	215	0
3557	2017-06-12	00:49:00	103	701	378	268	2
3558	2016-03-18	00:34:47	1431	549	329	135	0
3559	2016-07-02	00:35:05	1182	6449	137	131	0
3560	2016-07-14	00:03:15	211	3141	357	258	0
3562	2016-09-13	00:03:22	929	5061	386	249	0
3563	2016-06-20	00:56:05	1508	1351	353	158	2
3564	2016-02-20	00:10:06	501	4826	277	122	0
3565	2017-07-13	00:42:55	727	4068	127	2	0
3566	2017-07-28	00:49:59	875	6634	320	387	2
3568	2016-10-27	00:02:56	847	125	153	293	0
3569	2016-11-17	00:40:35	1654	2983	386	357	0
3570	2016-09-05	00:08:19	1573	3392	350	200	0
3571	2017-11-10	00:32:37	975	2837	380	142	0
3573	2016-01-19	00:17:39	1541	4881	55	63	0
3574	2017-04-07	00:12:51	414	1896	36	279	0
3575	2016-07-10	00:29:14	1329	1248	59	79	0
3576	2017-10-20	00:14:18	776	4838	247	52	0
3577	2017-07-28	00:41:12	1107	3715	24	80	0
3579	2017-02-16	00:50:29	924	4931	54	129	2
3580	2017-10-05	00:58:42	1471	2067	249	46	2
3581	2017-07-12	00:49:26	1179	6054	57	351	2
3582	2017-01-04	00:27:34	846	2203	258	341	0
3583	2017-02-27	00:29:39	280	1078	9	128	0
3585	2017-04-12	00:30:40	772	4763	157	326	0
3586	2017-10-17	00:44:23	25	6081	8	107	0
3587	2016-05-04	00:06:51	293	4479	96	332	0
3588	2017-07-21	00:44:24	886	551	38	118	0
3590	2017-11-05	00:41:29	1712	1201	55	138	0
3591	2017-03-27	00:01:21	1344	4783	347	26	0
3592	2017-03-28	00:51:08	1236	6022	14	142	2
3593	2016-08-07	00:01:40	1972	1809	400	365	0
3594	2017-06-15	00:35:52	1733	3945	354	40	0
3596	2017-11-01	00:06:52	1929	2425	140	160	0
3597	2016-08-23	00:39:41	702	2008	320	22	0
3598	2017-01-21	00:24:08	1620	2834	132	45	0
3599	2017-12-21	00:09:12	1772	1890	256	71	0
3600	2017-09-09	00:37:17	518	6637	251	110	0
3602	2016-07-15	00:09:52	1708	6575	17	324	0
3603	2017-11-11	00:43:51	582	2856	33	250	0
3604	2016-07-26	00:07:46	20	3176	374	90	0
3605	2016-12-14	00:58:59	1289	220	7	107	2
3607	2017-11-11	00:18:59	867	1249	229	16	0
3608	2017-07-19	00:02:56	1845	2905	201	51	0
3609	2017-10-20	00:46:19	1584	1572	94	59	2
3610	2017-01-12	00:26:33	1300	6397	158	117	0
3611	2017-01-06	00:35:33	1547	5053	109	19	0
3613	2016-04-01	00:09:28	1093	1991	318	238	0
3614	2017-03-24	00:57:57	1593	6275	349	330	2
3615	2016-02-08	00:53:35	1037	1885	61	194	2
3616	2017-02-26	00:26:19	1099	5206	262	321	0
3617	2017-10-22	00:57:54	31	6154	313	150	2
3619	2017-07-15	00:58:47	1091	4936	164	270	2
3620	2017-08-14	00:27:27	327	42	160	128	0
3621	2016-06-11	00:16:10	1767	1322	335	99	0
3622	2017-11-15	00:56:34	859	5855	357	68	2
3624	2016-06-28	00:12:46	1882	1958	355	389	0
3625	2016-04-10	00:27:19	421	4421	308	138	0
3626	2016-05-28	00:03:02	554	2149	46	383	0
3627	2016-05-22	00:22:51	306	1523	396	235	0
3628	2017-01-20	00:46:49	1413	2899	32	327	2
3630	2017-09-01	00:21:20	646	6311	103	91	0
3631	2016-05-27	00:50:37	178	5449	110	320	2
3632	2016-08-24	00:46:32	351	878	179	54	2
3633	2017-01-16	00:19:16	502	5453	158	309	0
3634	2016-10-11	00:42:38	1833	1799	208	70	0
3636	2016-09-05	00:57:54	22	851	199	195	2
3637	2017-07-10	00:11:50	852	6175	58	14	0
3638	2016-02-21	00:24:42	139	2893	384	40	0
3639	2017-09-27	00:49:22	1416	6563	307	382	2
3641	2017-01-16	00:51:43	350	5176	293	298	2
3642	2016-04-09	00:13:20	1754	1721	81	284	0
3643	2016-07-19	00:22:34	1289	2429	11	227	0
3644	2017-11-07	00:11:30	21	3862	170	33	0
3645	2016-06-20	00:32:53	480	3561	75	310	0
3647	2017-09-25	00:04:38	229	4955	307	395	0
3648	2016-02-04	00:08:21	1345	4126	78	97	0
3649	2016-02-16	00:19:48	1588	3840	12	155	0
3650	2016-08-01	00:28:58	1192	3729	7	187	0
3651	2016-02-01	00:49:33	113	1197	381	183	2
3653	2016-04-10	00:31:29	692	2181	147	340	0
3654	2017-05-17	00:25:13	1182	941	21	8	0
3655	2017-04-05	00:55:32	1755	6425	68	79	2
3656	2017-08-13	00:26:51	265	767	201	298	0
3658	2016-12-14	00:38:55	1941	5488	9	211	0
3659	2016-04-25	00:11:08	1105	2607	50	224	0
3660	2016-08-08	00:54:25	1678	578	101	115	2
3661	2017-07-11	00:36:44	1389	2618	143	262	0
3662	2017-03-11	00:08:48	1027	5630	351	368	0
3664	2017-03-14	00:22:27	1263	2969	340	322	0
3665	2016-09-11	00:25:47	870	6621	244	119	0
3666	2017-12-16	00:40:11	1792	3753	15	49	0
3667	2016-05-01	00:42:52	500	1259	144	310	0
3668	2016-06-18	00:28:01	321	2553	290	165	0
3670	2017-05-06	00:05:52	1248	837	236	212	0
3671	2017-09-11	00:57:32	1813	3019	251	109	2
3672	2016-12-09	00:56:22	288	1196	109	83	2
3675	2016-12-06	00:35:59	442	485	118	309	0
3676	2017-05-15	00:46:36	934	724	341	39	2
3677	2017-11-01	00:27:16	1599	5715	20	27	0
3678	2016-11-27	00:40:54	857	43	46	81	0
3679	2016-12-23	00:13:28	1318	6647	255	238	0
3681	2016-02-15	00:42:33	471	2028	361	170	0
3682	2016-02-12	00:53:24	1620	2817	152	399	2
3683	2016-08-07	00:19:53	1732	4425	31	283	0
3684	2017-02-17	00:09:18	778	6611	30	266	0
3685	2016-03-21	00:37:55	494	1470	120	355	0
3687	2016-01-08	00:44:52	445	3626	341	20	0
3688	2016-05-06	00:33:30	182	3867	51	338	0
3689	2017-02-20	00:13:05	1	1353	338	27	0
3690	2017-05-09	00:28:36	842	4250	103	280	0
3692	2016-09-05	00:45:07	1606	5152	207	296	2
3693	2016-10-15	00:08:33	1932	2060	358	395	0
3694	2017-06-05	00:09:08	1073	5615	159	160	0
3695	2017-11-04	00:38:26	5	4999	276	303	0
3696	2016-01-17	00:20:45	1065	2086	131	22	0
3698	2016-03-01	00:22:57	1750	1854	179	43	0
3699	2016-07-06	00:34:32	819	1946	162	205	0
3700	2017-05-01	00:23:51	169	6617	251	22	0
3701	2016-03-12	00:47:32	1490	4758	250	29	2
3702	2017-07-24	00:36:00	971	4023	112	106	0
3704	2016-04-04	00:37:59	407	744	118	139	0
3705	2016-10-09	00:32:48	1385	5381	120	183	0
3706	2017-08-14	00:58:34	1160	3339	287	387	2
3707	2016-04-08	00:30:22	435	1265	161	93	0
3709	2016-05-06	00:44:03	1912	4482	189	97	0
3710	2016-01-27	00:09:44	886	2830	155	27	0
3711	2016-06-06	00:25:29	739	4696	134	400	0
3712	2016-12-03	00:49:10	466	73	308	77	2
3713	2016-11-20	00:43:15	1338	890	293	102	0
3715	2016-03-24	00:29:47	240	2230	382	222	0
3716	2016-12-11	00:21:13	1108	1428	171	66	0
3717	2017-08-15	00:29:34	1450	2449	307	388	0
3718	2017-09-11	00:05:49	1161	4520	175	112	0
3719	2016-03-26	00:12:28	379	5523	92	273	0
3721	2017-04-06	00:24:27	324	772	309	183	0
3722	2017-02-23	00:30:07	1276	2018	382	274	0
3723	2016-05-21	00:51:09	116	2347	324	120	2
3724	2016-07-08	00:33:40	1473	6467	258	11	0
3726	2016-02-07	00:27:07	1939	3895	59	400	0
3727	2017-09-07	00:53:03	297	6041	35	349	2
3728	2016-08-09	00:52:34	1505	6185	146	198	2
3729	2016-03-17	00:48:35	1222	2688	336	33	2
3730	2016-02-16	00:53:43	271	275	384	198	2
3732	2017-07-27	00:32:21	306	676	229	168	0
3733	2016-08-02	00:50:44	780	1390	302	224	2
3734	2016-07-28	00:39:52	1999	1823	209	252	0
3735	2016-02-19	00:19:37	786	4630	151	159	0
3736	2017-04-18	00:29:00	1545	6570	266	261	0
3738	2016-10-22	00:01:25	1305	807	163	267	0
3739	2016-11-20	00:04:04	1896	4563	383	334	0
3740	2017-02-14	00:37:22	1339	1096	291	177	0
3741	2016-03-21	00:39:25	621	6426	235	332	0
3743	2016-12-10	00:12:21	704	6524	123	131	0
3744	2016-06-12	00:51:44	805	1105	202	130	2
3745	2016-01-14	00:10:06	1235	3128	227	260	0
3746	2017-12-10	00:55:33	59	759	339	275	2
3747	2016-01-17	00:26:30	904	4951	173	196	0
3749	2016-10-17	00:51:48	1196	3576	263	331	2
3750	2016-12-08	00:20:25	1049	342	304	43	0
3751	2016-01-13	00:00:20	1882	382	127	25	0
3752	2016-11-11	00:31:25	727	5504	243	58	0
3753	2016-12-14	00:06:47	694	2119	319	358	0
3755	2016-11-26	00:45:54	1584	2561	376	132	2
3756	2017-07-12	00:59:59	501	5892	1	94	2
3757	2017-04-10	00:27:13	1760	2650	38	387	0
3758	2016-09-02	00:48:26	797	5928	167	211	2
3760	2016-06-04	00:02:49	1324	5087	359	181	0
3761	2017-07-05	00:57:37	527	484	32	369	2
3762	2017-05-16	00:52:21	1695	6063	393	343	2
3763	2016-09-21	00:20:51	964	5621	318	17	0
3764	2016-03-19	00:44:51	1056	5723	261	337	0
3766	2017-06-14	00:24:37	1169	4641	148	286	0
3767	2017-02-10	00:49:33	716	2048	131	378	2
3768	2017-02-26	00:41:45	395	969	44	227	0
3769	2016-10-10	00:54:42	1845	3141	1	118	2
3770	2016-05-08	00:13:09	1333	4144	68	198	0
3772	2017-06-08	00:37:58	214	1797	335	125	0
3773	2016-02-07	00:43:17	83	2071	193	240	0
3774	2016-10-06	00:55:55	1552	3759	276	46	2
3775	2016-09-07	00:50:53	1280	6360	83	301	2
3777	2017-03-25	00:55:38	1061	4123	8	152	2
3778	2017-01-22	00:04:57	381	4950	132	202	0
3779	2016-04-13	00:34:19	336	1311	66	224	0
3780	2017-10-28	00:11:17	285	2923	149	168	0
3781	2017-01-02	00:45:27	1832	2124	248	332	2
3783	2017-08-26	00:04:57	831	3814	225	208	0
3784	2017-12-06	00:14:14	276	822	257	306	0
3785	2017-09-05	00:19:02	970	540	117	76	0
3786	2017-06-23	00:47:04	1226	3658	16	277	2
3787	2017-06-19	00:12:49	397	4648	366	79	0
3789	2017-10-13	00:05:20	1052	497	167	317	0
3790	2017-01-09	00:35:58	1123	6564	23	14	0
3791	2017-09-22	00:37:19	1003	4334	352	266	0
3792	2016-05-24	00:14:56	1758	3127	37	343	0
3794	2017-12-17	00:47:44	1929	995	67	114	2
3795	2016-09-18	00:31:27	1726	4892	256	246	0
3796	2017-09-17	00:06:04	1383	2070	31	117	0
3797	2016-11-14	00:13:50	1165	6090	133	35	0
3798	2016-11-17	00:08:02	723	1084	124	212	0
3800	2016-01-18	00:00:39	1712	954	288	282	0
3801	2016-04-07	00:28:32	1680	1862	252	280	0
3802	2016-10-15	00:11:54	1185	3231	102	280	0
3803	2017-06-07	00:38:52	915	4154	328	174	0
3804	2017-06-21	00:35:27	1607	2856	285	135	0
3806	2016-11-05	00:04:50	147	4797	295	192	0
3807	2017-10-05	00:15:04	409	6404	305	50	0
3808	2017-04-06	00:25:23	1381	399	367	204	0
3811	2017-02-21	00:21:49	1037	2548	47	199	0
3812	2017-09-02	00:38:10	1204	721	73	192	0
3813	2017-05-19	00:44:53	946	5800	218	27	0
3814	2017-04-23	00:53:01	1875	5325	336	214	2
3815	2016-07-25	00:16:33	1900	5973	183	234	0
3817	2017-12-21	00:44:16	996	2558	346	124	0
3818	2016-04-09	00:39:34	557	5961	5	198	0
3819	2016-10-05	00:15:27	1728	3464	170	159	0
3820	2016-06-08	00:07:29	1013	146	38	89	0
3821	2016-10-08	00:07:33	1438	2114	382	358	0
3823	2016-07-06	00:07:34	1778	2597	20	337	0
3824	2016-03-27	00:08:38	633	5840	161	162	0
3825	2017-11-22	00:13:21	1270	4745	116	172	0
3826	2017-07-22	00:19:27	594	6259	241	396	0
3828	2016-10-01	00:48:08	715	1447	119	262	2
3829	2017-09-17	00:14:31	1067	4176	319	395	0
3830	2017-04-22	00:55:05	27	3140	108	19	2
3831	2017-05-22	00:41:11	1432	3219	91	200	0
3832	2017-08-04	00:26:00	1741	4785	394	349	0
3834	2016-11-09	00:54:29	657	2078	46	181	2
3835	2016-03-14	00:58:45	2	5163	186	197	2
3836	2017-08-14	00:18:40	1379	2091	17	261	0
3837	2016-07-22	00:12:27	1601	3696	293	291	0
3838	2017-07-19	00:01:58	1585	288	21	167	0
3840	2017-04-07	00:07:12	1529	834	199	234	0
3841	2017-03-06	00:07:36	1045	5596	7	239	0
3842	2017-05-10	00:33:48	308	3100	33	154	0
3843	2017-01-24	00:12:29	1731	1684	90	333	0
3845	2016-07-28	00:39:35	1325	4841	65	76	0
3846	2016-09-10	00:35:50	949	3119	231	396	0
3847	2016-11-10	00:52:42	1607	1704	212	108	2
3848	2016-12-08	00:59:01	10	1106	351	318	2
3849	2017-05-28	00:43:28	905	6134	84	26	0
3851	2017-04-22	00:06:52	28	4371	112	38	0
3852	2016-06-11	00:09:12	1128	5104	84	8	0
3853	2016-01-04	00:17:02	1532	5327	96	290	0
3854	2016-10-02	00:33:11	180	3719	179	121	0
3855	2016-06-20	00:29:31	1222	5809	125	312	0
3857	2017-03-24	00:59:33	1117	1249	130	335	2
3858	2017-11-09	00:03:22	765	5258	152	375	0
3859	2016-07-01	00:54:32	346	6131	34	378	2
3860	2016-06-12	00:46:52	1503	1880	80	25	2
3862	2017-11-08	00:41:12	283	3178	282	303	0
3863	2017-01-17	00:16:37	1042	514	32	307	0
3864	2016-04-21	00:15:41	757	708	159	337	0
3865	2016-07-22	00:08:40	434	2892	340	390	0
3866	2017-02-13	00:50:56	1864	1656	112	48	2
3868	2017-02-14	00:23:14	636	5234	33	298	0
3869	2017-11-12	00:05:44	1890	2355	75	138	0
3870	2016-06-11	00:54:36	557	6462	96	152	2
3871	2016-03-07	00:28:18	947	6019	288	281	0
3872	2017-05-23	00:23:29	1094	1013	322	350	0
3874	2016-12-15	00:21:14	1184	3461	246	361	0
3875	2017-04-26	00:54:51	1525	3047	277	165	2
3877	2017-10-09	00:35:17	1998	3237	353	35	0
3885	2017-10-20	00:10:04	1288	194	80	5	0
3886	2017-03-27	00:58:26	615	6100	327	194	2
3887	2016-04-06	00:40:21	1629	6442	191	307	0
3888	2016-07-08	00:51:51	208	855	144	350	2
3889	2017-01-16	00:20:36	1435	598	139	197	0
3890	2016-10-09	00:40:05	479	5704	27	359	0
3891	2016-02-06	00:01:38	1220	2710	297	34	0
3892	2016-07-09	00:30:24	665	865	352	67	0
3893	2016-08-10	00:17:13	902	709	261	58	0
3894	2017-08-12	00:18:00	665	4734	264	43	0
3895	2016-07-01	00:49:58	1648	6613	105	123	2
3896	2016-05-25	00:15:19	220	5740	274	298	0
3897	2017-08-11	00:41:39	514	6641	200	282	0
3898	2017-06-10	00:32:22	171	3444	79	335	0
3899	2016-12-16	00:02:21	119	3546	286	148	0
3900	2016-08-25	00:18:08	1126	1849	255	379	0
3901	2017-10-20	00:59:24	131	487	265	27	2
3902	2017-10-06	00:19:52	1596	3065	350	6	0
3903	2016-02-27	00:41:55	188	2792	249	372	0
3904	2017-09-11	00:30:00	559	6177	228	75	0
3905	2016-05-08	00:48:15	250	5174	79	349	2
3906	2017-01-15	00:15:56	13	6468	233	376	0
3907	2016-02-20	00:35:39	1032	2047	117	357	0
3908	2017-09-21	00:20:24	1906	6133	5	360	0
3909	2016-06-09	00:23:55	1849	4449	159	36	0
3910	2017-09-27	00:34:07	1669	3984	373	289	0
3911	2016-05-18	00:50:08	259	3948	276	69	2
3912	2017-12-24	00:01:49	1862	5387	206	164	0
3913	2016-12-20	00:03:47	1729	4263	289	275	0
3914	2016-02-12	00:43:14	1545	2757	320	358	0
3915	2016-09-12	00:33:21	1697	6300	57	44	0
3916	2016-10-23	00:15:25	395	2758	345	349	0
3917	2016-05-10	00:50:15	1143	2672	370	99	2
3918	2016-10-16	00:28:32	166	3812	367	322	0
3919	2016-06-10	00:24:49	1865	913	317	103	0
3920	2017-01-20	00:04:30	1971	2757	379	279	0
3921	2016-07-24	00:18:30	1973	4623	262	339	0
3922	2017-06-22	00:57:29	300	5634	207	210	2
3923	2016-10-05	00:21:40	161	4733	383	322	0
3925	2016-05-18	00:19:56	1772	3697	345	25	0
3926	2016-08-09	00:34:25	1544	12	76	235	0
3927	2016-04-24	00:20:00	372	3482	396	36	0
3928	2017-07-24	00:23:04	1271	6350	279	123	0
3930	2016-06-26	00:55:12	334	75	335	196	2
3931	2016-10-02	00:21:15	1285	1280	392	244	0
3932	2016-09-03	00:50:10	1351	2537	16	90	2
3933	2016-06-07	00:11:32	1929	5241	4	40	0
3934	2017-05-07	00:59:14	1008	3626	193	101	2
3936	2017-02-15	00:33:32	1241	1180	338	261	0
3937	2017-11-01	00:35:46	1687	3547	306	296	0
3938	2016-04-18	00:52:59	383	124	254	380	2
3939	2016-09-09	00:20:04	735	2975	398	271	0
3940	2017-02-20	00:14:54	428	258	240	296	0
3942	2017-12-24	00:39:28	716	2875	213	263	0
3943	2017-06-25	00:01:17	636	3328	96	357	0
3944	2016-08-16	00:05:44	1309	6360	250	386	0
8	2016-12-07	00:50:07	317	6272	305	204	2
14	2017-10-15	00:16:50	659	568	201	327	0
19	2016-09-26	00:36:52	1072	673	373	52	0
25	2016-02-17	00:17:16	136	4863	284	227	0
31	2016-05-26	00:53:32	803	4491	115	82	2
36	2016-03-09	00:25:36	913	5236	116	215	0
42	2017-04-05	00:07:01	1891	2514	378	381	0
48	2017-04-28	00:02:54	1605	4740	395	357	0
53	2017-08-04	00:13:32	1883	6582	42	132	0
59	2016-06-16	00:30:57	1434	2404	293	117	0
65	2016-01-02	00:52:49	1307	1935	234	211	2
70	2016-11-02	00:36:58	187	740	157	321	0
76	2017-03-24	00:11:56	836	2140	363	190	0
82	2016-09-22	00:14:35	1289	4823	40	125	0
87	2016-07-14	00:05:17	424	2991	98	293	0
93	2016-08-01	00:38:05	1752	2810	307	385	0
99	2016-01-14	00:42:45	841	5009	79	56	0
104	2017-04-13	00:03:25	501	3926	44	281	0
110	2017-06-14	00:01:55	198	2725	181	116	0
116	2016-08-10	00:01:23	1174	5869	236	17	0
121	2017-10-11	00:54:01	672	1653	86	384	2
127	2017-02-22	00:42:27	809	4171	229	389	0
133	2016-11-12	00:09:20	1244	3885	51	166	0
137	2017-01-19	00:28:52	1346	3302	98	54	0
138	2017-06-06	00:00:31	107	2227	220	108	0
144	2016-07-11	00:20:08	1923	5229	142	116	0
150	2017-12-02	00:13:53	1669	5258	39	338	0
155	2017-12-26	00:22:12	428	1436	129	40	0
161	2017-04-05	00:19:54	1499	5600	44	43	0
167	2016-07-09	00:34:16	1759	6105	391	135	0
172	2016-11-25	00:05:07	838	5095	330	48	0
178	2017-02-01	00:12:26	1729	3718	395	111	0
184	2017-08-20	00:48:21	525	3898	202	34	2
189	2016-11-21	00:53:09	144	2960	81	297	2
195	2017-12-28	00:48:13	874	659	197	283	2
201	2016-09-13	00:06:47	1248	4381	243	18	0
206	2017-07-07	00:31:35	1957	3199	287	354	0
212	2017-12-25	00:43:53	1841	4983	295	127	0
218	2017-09-13	00:01:29	481	936	271	231	0
223	2016-01-15	00:05:49	1347	1257	241	387	0
229	2017-02-18	00:06:26	1455	849	288	256	0
235	2017-03-17	00:56:14	1203	2157	355	277	2
240	2016-12-25	00:12:45	247	2521	187	143	0
246	2017-02-06	00:30:16	937	2487	257	302	0
252	2017-07-02	00:38:53	1380	2253	279	51	0
257	2016-04-08	00:57:38	746	5446	280	243	2
263	2017-01-04	00:42:58	168	3667	170	368	0
269	2016-04-11	00:55:24	26	3278	334	231	2
273	2016-02-22	00:31:02	1363	5485	146	398	0
274	2017-05-11	00:22:05	307	334	135	95	0
280	2017-08-11	00:16:21	219	1008	118	37	0
286	2017-04-15	00:03:49	882	2615	261	198	0
291	2017-03-08	00:54:51	1227	909	78	189	2
297	2016-08-28	00:49:43	137	4964	326	102	2
303	2016-09-18	00:57:22	954	1977	298	115	2
308	2016-02-06	00:57:34	1030	1064	342	18	2
314	2017-04-19	00:30:53	1790	3685	34	346	0
320	2017-04-10	00:20:25	933	6665	151	248	0
325	2016-10-17	00:00:28	1580	558	391	333	0
331	2016-02-19	00:53:26	1526	3652	84	164	2
337	2017-04-07	00:05:27	468	4898	314	131	0
342	2016-07-16	00:14:33	1246	3603	294	153	0
348	2017-03-10	00:53:21	1059	6541	97	35	2
354	2016-03-11	00:00:15	1215	865	302	154	0
359	2016-08-06	00:31:35	102	4912	137	196	0
365	2016-05-03	00:24:47	161	4240	271	385	0
3946	2017-09-06	00:48:40	363	2167	171	130	2
3947	2017-10-23	00:29:58	834	4963	68	50	0
3948	2016-02-10	00:08:32	1538	1696	281	396	0
3949	2016-06-03	00:26:59	285	2078	282	161	0
3950	2017-06-18	00:04:54	261	2248	79	398	0
3952	2017-03-05	00:27:08	1488	4004	84	104	0
3953	2016-03-27	00:32:32	957	1492	5	141	0
3954	2017-02-28	00:58:45	72	2674	343	283	2
3955	2017-04-22	00:07:29	84	963	392	399	0
3956	2017-10-06	00:38:38	619	3888	351	168	0
3958	2016-03-16	00:52:43	1964	5398	393	227	2
3959	2016-07-15	00:12:41	452	4610	77	371	0
3960	2017-10-21	00:46:17	1129	3680	227	234	2
3961	2017-09-22	00:35:14	626	163	245	335	0
3963	2017-06-27	00:11:11	714	5471	18	282	0
3964	2017-01-17	00:44:38	1538	1701	264	45	0
3965	2016-02-17	00:57:18	1303	505	142	294	2
3966	2017-11-27	00:00:17	1263	2289	79	58	0
3967	2016-08-19	00:31:04	986	5964	323	237	0
3969	2017-07-23	00:49:43	885	4632	323	337	2
3970	2017-10-08	00:15:13	633	5322	346	135	0
3971	2017-04-02	00:04:58	1247	3527	356	328	0
3972	2017-07-01	00:18:54	845	5704	299	49	0
3973	2017-03-08	00:05:43	1148	3154	65	36	0
3975	2017-12-25	00:00:43	1555	2635	163	76	0
3976	2017-07-04	00:15:49	1783	3878	286	54	0
3977	2016-06-16	00:27:43	1810	3931	365	310	0
3978	2016-11-08	00:49:54	1899	6195	334	211	2
3980	2017-11-19	00:20:13	637	4188	210	23	0
3981	2017-02-26	00:42:52	477	5877	284	161	0
3982	2017-12-17	00:26:32	1832	4796	299	105	0
3983	2017-12-16	00:49:14	1284	1451	398	103	2
3984	2017-09-28	00:48:21	1548	676	318	213	2
3986	2016-06-27	00:04:10	1254	4153	40	294	0
3987	2016-08-12	00:54:18	993	1672	120	125	2
3988	2017-11-22	00:48:12	1643	938	312	268	2
3989	2017-11-10	00:12:57	1658	393	37	397	0
3990	2016-01-12	00:50:09	1050	3440	290	56	2
3992	2017-06-13	00:07:07	22	682	361	216	0
3993	2016-02-16	00:48:39	554	1210	263	329	2
3994	2016-08-20	00:58:05	1458	77	261	84	2
3995	2016-05-18	00:27:43	747	2734	384	282	0
3997	2017-03-17	00:07:50	1299	4105	253	265	0
3998	2016-10-01	00:56:14	1532	75	299	152	2
3999	2016-10-14	00:40:26	503	2834	11	307	0
4000	2017-07-18	00:28:28	190	6013	142	260	0
4001	2017-12-11	23:55:13.11091	1	678	2	1	2
4002	2017-12-12	13:19:17.939942	2003	1179	452	\N	0
2	2016-05-27	00:14:33	467	2393	220	55	0
371	2016-08-07	00:08:15	1217	937	94	85	0
376	2016-10-22	00:47:07	1296	6522	213	172	2
382	2016-04-17	00:43:02	1267	4596	50	293	0
388	2016-11-13	00:54:12	599	923	95	336	2
393	2016-12-08	00:23:56	1796	6213	312	217	0
399	2017-03-27	00:53:52	600	2187	110	272	2
405	2016-05-09	00:31:14	1089	2619	279	161	0
409	2017-01-05	00:26:15	1463	1532	313	82	0
410	2016-07-07	00:46:34	1901	2166	177	68	2
416	2017-08-23	00:58:23	1082	3887	294	152	2
422	2017-12-22	00:16:21	1326	4258	193	79	0
427	2016-09-23	00:55:36	1896	4149	311	250	2
433	2017-07-12	00:18:10	1629	1949	134	194	0
439	2017-09-19	00:52:57	512	1470	115	256	2
444	2016-05-14	00:25:07	520	693	113	7	0
450	2017-12-20	00:34:58	524	5591	9	40	0
456	2016-08-03	00:28:20	1595	6223	90	311	0
461	2016-07-03	00:54:05	227	374	157	392	2
467	2017-05-26	00:15:33	1071	62	155	184	0
473	2017-03-02	00:40:32	119	3337	84	78	0
478	2016-04-27	00:27:10	1848	4379	375	7	0
484	2016-03-15	00:58:30	1142	5849	152	143	2
490	2016-06-18	00:24:43	1478	4405	188	347	0
495	2017-08-26	00:32:51	121	4211	246	313	0
501	2017-02-22	00:52:50	1320	4404	254	229	2
507	2016-02-22	00:55:38	807	4406	376	233	2
512	2016-02-22	00:58:35	1757	368	157	92	2
518	2017-04-07	00:29:18	1959	5511	68	272	0
524	2017-01-27	00:49:57	114	1923	317	293	2
529	2017-04-21	00:38:42	1161	1206	186	344	0
535	2017-04-18	00:47:15	860	6072	130	67	2
541	2016-12-06	00:50:37	100	4262	216	366	2
545	2017-09-19	00:46:35	495	5478	172	106	2
546	2017-07-25	00:28:42	1699	3313	287	15	0
552	2017-02-22	00:31:58	933	3192	392	184	0
558	2017-04-19	00:33:50	82	4184	82	388	0
563	2017-01-14	00:14:07	1921	1332	356	307	0
569	2017-03-28	00:37:51	834	604	265	252	0
575	2016-10-10	00:50:05	1784	4838	203	211	2
580	2016-10-07	00:55:56	851	5946	157	51	2
586	2016-07-03	00:41:00	1656	4115	241	84	0
592	2017-08-28	00:19:25	1785	3007	380	287	0
597	2016-02-19	00:24:47	10	1274	340	78	0
603	2017-01-11	00:41:47	1794	917	48	130	0
609	2016-07-21	00:59:59	413	5595	74	355	2
614	2017-12-12	00:51:42	323	2203	77	324	2
620	2017-04-19	00:06:05	1916	5191	85	131	0
626	2016-10-15	00:49:47	1815	6111	384	58	2
631	2017-12-24	00:39:07	356	3009	282	166	0
637	2017-06-03	00:22:42	1038	3419	220	71	0
643	2017-04-12	00:08:17	1675	5826	327	207	0
648	2016-04-26	00:57:08	862	499	151	105	2
654	2016-08-28	00:33:07	1620	4838	68	400	0
660	2016-09-20	00:16:56	1732	4038	184	394	0
665	2016-12-24	00:11:03	287	3547	285	393	0
671	2016-01-24	00:03:53	1219	379	298	21	0
677	2017-08-23	00:29:17	1066	4479	115	76	0
681	2016-08-22	00:28:36	655	3892	199	349	0
682	2017-04-18	00:03:49	1244	3157	174	142	0
688	2016-02-26	00:42:07	872	2026	212	205	0
694	2016-09-25	00:38:38	1855	1028	50	394	0
699	2017-12-24	00:05:26	778	1661	249	15	0
705	2017-08-02	00:16:16	150	4780	291	341	0
711	2016-11-28	00:28:32	1018	5465	74	62	0
716	2016-02-02	00:16:19	891	2298	20	70	0
722	2017-09-06	00:53:05	615	4837	286	7	2
728	2016-12-06	00:35:51	1111	4614	353	224	0
733	2017-01-07	00:04:38	690	1537	333	331	0
739	2016-04-18	00:30:20	1182	3594	197	154	0
745	2017-12-10	00:51:25	767	1091	304	364	2
750	2017-03-03	00:32:36	1574	2999	250	112	0
756	2017-06-22	00:10:10	1991	4006	98	356	0
762	2016-10-08	00:26:09	1465	22	40	331	0
767	2016-08-28	00:09:05	424	992	204	250	0
773	2017-04-04	00:13:40	1420	3809	214	262	0
779	2016-09-04	00:24:53	385	1645	213	21	0
784	2017-12-23	00:32:44	206	3013	290	56	0
790	2016-01-21	00:09:59	251	4935	271	270	0
796	2016-04-05	00:21:28	415	1297	309	12	0
801	2017-10-21	00:11:22	56	4323	48	229	0
807	2017-12-02	00:58:02	688	2475	390	286	2
813	2016-06-15	00:06:10	1135	1283	127	335	0
817	2016-03-02	00:11:46	949	2571	358	118	0
818	2016-05-12	00:51:52	1711	2923	85	275	2
824	2017-11-01	00:03:45	614	1297	252	369	0
830	2016-03-24	00:54:13	1748	1127	227	281	2
835	2017-09-27	00:05:46	1183	6228	209	192	0
841	2016-10-20	00:14:59	1953	5307	354	35	0
847	2016-04-26	00:37:55	1230	4733	251	191	0
852	2016-09-07	00:42:00	524	1590	395	106	0
858	2016-09-13	00:20:06	1022	2646	330	337	0
864	2017-08-02	00:04:17	1273	2389	113	168	0
869	2016-02-06	00:25:59	481	2204	60	268	0
875	2016-08-05	00:53:32	1415	370	52	274	2
881	2016-12-18	00:55:43	1630	4683	104	201	2
886	2016-09-19	00:49:26	1886	3588	178	323	2
892	2017-09-09	00:39:15	551	5402	361	333	0
898	2017-07-16	00:25:36	1609	6533	251	174	0
903	2017-05-28	00:38:10	1679	3657	98	250	0
909	2017-05-19	00:34:50	1251	3674	356	57	0
915	2016-10-27	00:44:20	918	4340	60	346	0
920	2016-08-28	00:47:12	1497	3768	245	115	2
926	2017-09-18	00:49:27	909	558	82	292	2
932	2017-07-03	00:06:09	1386	1867	390	310	0
937	2016-03-16	00:25:44	1462	88	221	218	0
943	2016-04-09	00:34:36	1989	4497	316	186	0
949	2016-12-17	00:27:24	1457	5975	38	264	0
953	2016-08-25	00:41:33	325	749	359	199	0
954	2017-02-09	00:53:24	1359	6026	70	307	2
960	2017-01-27	00:58:39	1839	2192	259	17	2
966	2017-03-17	00:05:57	722	5416	188	364	0
971	2017-02-28	00:55:07	1227	2567	143	67	2
977	2016-08-14	00:24:29	255	5006	98	112	0
983	2017-05-27	00:47:59	1140	3095	186	14	2
988	2016-10-14	00:23:39	1662	3228	5	141	0
994	2016-06-25	00:33:39	1104	2057	307	184	0
1000	2017-08-06	00:08:45	111	4471	40	328	0
1005	2017-11-04	00:22:48	1842	2994	128	288	0
1011	2016-03-23	00:36:25	1362	1504	66	49	0
1017	2016-07-16	00:19:43	1217	2745	337	314	0
1022	2016-03-18	00:04:53	1281	3619	8	14	0
1028	2016-09-02	00:08:35	1434	5907	133	174	0
1034	2016-11-24	00:11:21	1947	1370	15	394	0
1039	2016-02-12	00:40:28	1271	4095	10	123	0
1045	2017-03-04	00:57:42	1366	6629	198	297	2
1051	2017-12-11	00:08:26	1147	3720	293	77	0
1056	2016-09-25	00:58:18	950	83	253	80	2
1062	2016-04-02	00:23:01	753	4437	236	214	0
1068	2016-05-21	00:27:28	1937	890	162	220	0
1073	2016-01-17	00:17:20	1596	2740	185	360	0
1079	2017-11-06	00:17:22	1226	1677	15	74	0
1085	2017-05-15	00:00:48	605	1302	362	41	0
1089	2017-05-03	00:07:25	1846	138	51	228	0
1090	2016-10-22	00:05:57	1176	6525	118	235	0
1096	2016-02-06	00:08:04	1036	3704	287	38	0
1102	2016-01-16	00:07:53	1428	6013	374	41	0
1107	2016-07-06	00:50:06	269	5651	351	326	2
1113	2017-06-15	00:44:39	173	5189	376	292	0
1119	2017-10-11	00:30:42	475	1749	39	197	0
1124	2016-08-08	00:26:40	1798	3672	5	11	0
1130	2016-02-04	00:17:11	1882	5926	249	44	0
1136	2016-03-23	00:56:56	437	5694	343	87	2
1141	2017-09-11	00:44:59	1456	4008	66	103	0
1147	2016-10-11	00:08:42	1367	699	91	320	0
1153	2016-03-12	00:51:33	125	4039	179	115	2
1158	2017-10-28	00:43:22	128	4449	212	60	0
1164	2017-07-24	00:44:49	1862	597	117	102	0
1170	2016-03-27	00:48:34	1696	1375	224	177	2
1175	2016-09-06	00:59:56	1325	4970	366	355	2
1181	2016-11-12	00:30:28	1037	4215	71	319	0
1187	2017-05-15	00:04:37	208	4362	62	289	0
1192	2016-01-24	00:49:39	1672	1098	134	384	2
1198	2016-11-04	00:51:13	299	5541	189	322	2
1204	2017-04-28	00:30:17	1310	2048	290	29	0
1209	2016-03-20	00:27:19	1358	2618	337	32	0
1215	2016-01-26	00:36:00	1992	3447	264	125	0
1221	2017-10-07	00:30:54	676	1294	185	375	0
1225	2017-07-24	00:54:39	1955	6074	170	259	2
1226	2017-10-08	00:28:58	1408	405	383	308	0
1232	2016-10-18	00:26:05	1873	5384	262	369	0
1238	2017-05-21	00:14:09	718	3464	299	365	0
1243	2017-12-18	00:19:20	883	6470	39	249	0
1249	2017-02-17	00:11:12	681	5258	228	283	0
1255	2016-12-09	00:38:38	694	6573	290	109	0
1260	2017-11-15	00:46:37	675	2360	274	170	2
1266	2017-12-23	00:12:45	1829	2670	141	295	0
1272	2017-12-23	00:05:44	1216	4637	189	76	0
1277	2017-07-06	00:35:08	651	2773	341	324	0
1283	2016-06-21	00:56:54	1103	2688	314	88	2
1289	2017-09-25	00:25:49	1405	3952	383	186	0
1294	2017-03-06	00:03:45	1030	4452	110	115	0
1300	2016-06-20	00:39:31	1675	5465	297	379	0
1306	2016-12-12	00:01:38	1266	5687	263	97	0
1311	2016-01-19	00:17:15	291	3355	49	348	0
1317	2017-05-05	00:47:27	1087	4113	284	297	2
1323	2016-02-01	00:52:37	794	24	275	345	2
1328	2016-07-04	00:19:13	841	280	16	284	0
1334	2016-02-08	00:38:08	1734	4587	248	397	0
1340	2017-06-15	00:46:10	1170	3037	175	131	2
1345	2017-07-16	00:22:30	1556	5240	77	85	0
1351	2016-04-16	00:52:21	537	755	319	119	2
1357	2017-05-07	00:28:00	1367	4279	280	264	0
1361	2016-08-25	00:13:03	389	2370	313	234	0
1362	2017-05-18	00:45:53	1653	4168	184	256	2
1368	2017-01-10	00:55:36	427	4661	98	271	2
1374	2017-06-07	00:11:52	591	6214	119	68	0
1379	2016-05-12	00:09:30	1823	971	295	14	0
1385	2017-08-02	00:11:57	1542	1501	97	114	0
1391	2016-03-01	00:11:16	427	1446	209	133	0
1396	2016-04-28	00:58:53	125	3281	371	391	2
1402	2016-03-12	00:02:54	2	5205	387	190	0
1408	2017-04-12	00:21:43	815	1298	223	290	0
1413	2017-11-26	00:08:24	17	4821	390	27	0
1419	2016-06-18	00:10:05	1638	115	47	149	0
1425	2017-09-17	00:43:55	731	1298	385	135	0
1430	2017-10-12	00:29:01	873	2968	352	338	0
1436	2016-08-05	00:58:39	867	125	83	285	2
1442	2017-11-26	00:49:21	1652	1786	130	302	2
1447	2017-09-18	00:47:13	42	3583	352	65	2
1453	2016-02-25	00:44:42	598	6138	308	101	0
1459	2016-10-27	00:56:23	1405	1619	263	59	2
1464	2016-08-25	00:09:09	607	5554	315	391	0
1470	2017-03-21	00:40:24	715	486	369	266	0
1476	2016-10-08	00:49:17	763	3471	85	303	2
1481	2016-06-09	00:37:28	966	6383	191	254	0
1487	2016-10-19	00:18:06	1545	2446	66	29	0
1493	2016-01-26	00:41:58	298	12	393	213	0
1497	2017-03-01	00:04:33	74	5756	53	244	0
1498	2017-03-24	00:34:32	1987	2904	157	395	0
1504	2017-01-24	00:41:42	1777	1814	286	228	0
1510	2017-03-03	00:40:04	400	1149	153	288	0
1515	2017-08-24	00:25:24	1301	595	202	9	0
1521	2016-06-10	00:09:14	1286	501	225	74	0
1527	2017-05-01	00:08:27	798	3348	326	236	0
1532	2016-07-24	00:35:51	630	4748	339	60	0
1538	2016-06-06	00:32:43	1229	674	336	191	0
1544	2016-09-11	00:28:18	1597	6302	144	306	0
1549	2017-03-13	00:40:42	981	661	107	339	0
1555	2017-07-07	00:40:47	1002	2315	136	133	0
1561	2016-01-09	00:42:49	725	682	127	226	0
1566	2016-01-19	00:38:42	502	438	39	114	0
1572	2016-04-08	00:20:38	754	288	295	232	0
1578	2016-02-07	00:30:08	1156	5632	274	346	0
1583	2017-02-02	00:14:54	471	1853	83	79	0
1589	2016-05-15	00:57:04	1630	6369	135	180	2
1595	2016-01-28	00:13:54	450	5632	42	113	0
1600	2017-06-25	00:06:46	553	887	298	49	0
1606	2017-03-09	00:19:53	1289	3096	224	292	0
1612	2017-02-13	00:56:29	77	5393	195	351	2
1617	2017-06-24	00:45:30	1888	4614	163	370	2
1623	2016-09-10	00:52:54	1304	6501	137	7	2
1629	2016-03-05	00:15:07	1508	6052	39	377	0
1633	2016-08-07	00:21:14	496	4949	367	156	0
1634	2016-09-01	00:21:12	157	2732	189	124	0
1640	2017-03-17	00:32:13	1525	3794	295	321	0
1646	2016-02-13	00:52:58	1332	2633	194	238	2
1651	2016-03-04	00:50:48	1355	255	21	400	2
1657	2017-07-25	00:36:52	61	1086	307	292	0
1663	2017-09-25	00:02:08	1162	2154	187	98	0
1668	2017-11-18	00:43:45	1002	3344	238	187	0
1674	2017-08-16	00:37:36	1949	4929	236	306	0
1680	2016-06-26	00:47:38	1963	1664	73	78	2
1685	2016-01-19	00:04:34	1308	1004	246	308	0
1691	2017-02-26	00:23:41	554	4251	27	361	0
1697	2017-10-11	00:16:44	633	250	137	344	0
1702	2017-08-12	00:16:54	902	4561	290	359	0
1708	2017-11-25	00:05:47	1224	386	235	49	0
1714	2017-04-23	00:11:31	186	2709	216	63	0
1719	2017-04-17	00:18:47	1282	4486	332	20	0
1725	2017-06-27	00:15:54	1846	149	169	312	0
1731	2017-05-10	00:25:14	1122	4327	307	147	0
1736	2017-04-12	00:26:03	832	3988	371	96	0
1742	2016-02-01	00:17:37	204	5061	107	64	0
1748	2017-01-16	00:55:25	794	5272	344	169	2
1753	2016-07-27	00:00:28	223	6144	14	395	0
1759	2016-05-18	00:08:37	1669	6459	10	253	0
1765	2016-02-22	00:21:54	29	5968	166	48	0
1769	2017-09-27	00:19:49	698	3139	127	255	0
1770	2017-09-26	00:25:13	928	1294	38	291	0
1776	2016-12-10	00:56:38	738	2420	156	368	2
1782	2016-07-27	00:59:15	472	3932	116	294	2
1787	2017-07-15	00:37:14	87	691	245	107	0
1793	2016-11-28	00:24:22	340	4182	239	194	0
1799	2017-01-13	00:51:02	1272	5363	375	234	2
1804	2016-11-10	00:46:21	320	3400	242	129	2
1810	2017-01-13	00:11:26	144	2644	368	394	0
1816	2016-07-20	00:04:42	72	2837	1	226	0
1821	2017-03-01	00:18:25	426	5776	320	265	0
1827	2017-09-21	00:27:57	1848	3049	344	98	0
1833	2017-01-05	00:43:52	824	1302	88	230	0
1838	2016-08-18	00:37:56	1693	3098	305	30	0
1844	2016-05-11	00:59:28	1692	6326	232	198	2
1850	2016-05-01	00:02:25	1336	4303	183	81	0
1855	2017-06-01	00:42:06	417	6612	388	227	0
1861	2016-01-03	00:27:06	413	1616	38	166	0
1867	2017-12-19	00:39:46	392	4227	68	254	0
1872	2017-03-17	00:24:57	760	1282	301	214	0
1878	2017-04-24	00:30:44	1833	1484	318	301	0
1884	2017-08-19	00:28:31	1532	2104	374	175	0
1889	2016-02-23	00:23:51	1490	2798	353	291	0
1895	2017-04-08	00:24:43	1939	2708	353	329	0
1901	2016-04-25	00:45:12	238	2428	54	88	2
1905	2016-10-03	00:42:56	826	4087	187	30	0
1906	2017-12-12	00:44:23	1797	5915	186	139	0
1912	2017-01-11	00:01:55	1549	3915	205	36	0
1918	2017-11-23	00:08:51	563	2508	84	9	0
1923	2016-09-09	00:21:59	516	96	210	149	0
1929	2016-05-13	00:27:22	1667	1945	230	380	0
1935	2017-08-27	00:07:33	373	1267	24	154	0
1940	2016-09-09	00:05:58	1688	4680	351	6	0
1946	2016-04-14	00:46:16	1568	2046	201	146	2
1952	2016-03-08	00:13:10	1963	6167	213	324	0
1957	2016-11-09	00:06:58	1321	3562	160	383	0
1963	2017-01-28	00:37:23	1351	6286	137	389	0
1969	2016-11-05	00:18:15	1558	6125	177	332	0
1974	2017-09-23	00:00:47	648	5992	391	366	0
1980	2016-02-14	00:08:44	965	2666	112	118	0
1986	2017-03-02	00:35:53	1439	819	31	314	0
1991	2017-03-14	00:48:56	235	5002	109	366	2
1997	2016-06-06	00:31:17	133	1036	292	71	0
2003	2017-06-17	00:23:18	1422	4387	400	65	0
2008	2017-10-02	00:50:05	1369	3784	224	79	2
2014	2017-03-21	00:00:37	469	1614	373	176	0
2020	2016-03-23	00:06:42	1144	1543	11	327	0
2025	2016-08-21	00:59:57	1222	5241	57	385	2
2031	2016-09-09	00:47:22	894	5911	203	224	2
2037	2017-11-15	00:10:52	2	1900	242	310	0
2041	2017-04-13	00:18:24	816	4528	345	149	0
2042	2017-05-14	00:38:12	709	1447	391	261	0
2048	2017-07-15	00:45:12	389	2219	332	359	2
2054	2016-05-21	00:01:03	561	6615	98	162	0
2059	2017-02-13	00:55:23	746	34	233	377	2
2065	2016-09-24	00:23:25	1735	2141	376	45	0
2071	2016-11-25	00:45:26	597	821	40	308	2
2076	2017-06-17	00:35:47	935	2245	329	101	0
2082	2017-01-18	00:27:17	1666	2372	258	290	0
2088	2017-02-05	00:28:32	443	5339	98	74	0
2093	2016-05-19	00:33:16	997	5751	180	278	0
2099	2017-04-24	00:40:24	1187	6126	39	2	0
2105	2016-01-19	00:39:46	1484	2563	139	162	0
2110	2016-11-02	00:55:51	340	200	233	353	2
2116	2017-12-27	00:41:33	833	2895	306	167	0
2122	2017-08-23	00:57:52	1279	1226	385	245	2
2127	2017-07-07	00:16:36	1074	6649	249	164	0
2133	2016-03-07	00:41:47	38	5803	139	173	0
2139	2016-05-15	00:06:52	722	4367	168	26	0
2144	2016-03-13	00:50:44	1537	1493	210	27	2
2150	2017-03-21	00:46:10	420	1275	220	371	2
2156	2017-01-04	00:09:00	1531	2022	322	140	0
2161	2016-09-13	00:32:33	686	2268	300	66	0
2167	2017-12-22	00:30:35	1263	2075	111	149	0
2173	2017-09-20	00:33:25	971	6169	258	251	0
2177	2016-03-11	00:40:57	1510	6209	21	178	0
2178	2016-03-26	00:07:27	193	2178	86	14	0
2184	2017-10-09	00:40:11	1410	6107	366	243	0
2190	2017-02-04	00:08:39	674	3559	295	213	0
2195	2016-01-01	00:52:58	845	456	53	232	2
2201	2016-06-26	00:50:59	1775	508	96	267	2
2207	2016-01-04	00:41:27	250	4087	47	109	0
2212	2016-11-02	00:35:40	1764	3424	133	353	0
2218	2016-03-07	00:42:31	1625	1150	10	399	0
2224	2017-08-19	00:43:44	77	2233	24	399	0
2229	2017-08-13	00:23:47	1788	5736	265	168	0
2235	2016-04-28	00:20:12	384	622	289	200	0
2241	2016-05-12	00:46:42	1743	527	390	166	2
2246	2016-02-16	00:38:54	1631	2571	41	87	0
2252	2016-08-05	00:52:42	940	5123	72	285	2
2258	2017-01-01	00:06:05	1656	803	200	73	0
2263	2016-05-10	00:55:28	704	4357	140	259	2
2269	2016-04-03	00:32:21	1466	4149	326	169	0
2275	2017-05-09	00:48:07	1512	5686	106	329	2
2280	2016-07-27	00:06:09	708	2815	285	122	0
2286	2016-10-15	00:28:54	599	6424	165	69	0
2292	2017-09-06	00:31:00	1735	5436	46	58	0
2297	2016-03-03	00:18:49	706	4642	50	40	0
2303	2017-02-25	00:40:10	441	117	145	136	0
2309	2017-11-13	00:33:16	69	2166	240	190	0
2313	2017-03-15	00:33:41	921	2470	164	7	0
2314	2016-04-09	00:20:56	1901	291	277	107	0
2320	2016-03-14	00:13:38	646	661	365	2	0
2326	2017-08-28	00:42:25	1777	5589	56	374	0
2331	2016-04-20	00:33:19	653	4961	208	117	0
2337	2016-12-04	00:53:17	611	318	71	39	2
2343	2017-06-18	00:37:12	1077	3328	230	222	0
2348	2017-02-28	00:00:43	405	1964	234	313	0
2354	2017-09-11	00:31:12	573	4514	20	162	0
2360	2016-11-24	00:36:41	1360	3638	286	299	0
2365	2016-12-07	00:55:03	1375	3394	265	364	2
2371	2017-08-10	00:49:38	1774	6028	92	355	2
2377	2017-12-04	00:13:57	1430	278	195	125	0
2382	2017-02-21	00:34:45	1773	3613	96	121	0
2388	2017-03-08	00:26:51	309	1784	192	244	0
2394	2017-02-16	00:20:20	1422	4070	147	319	0
2399	2016-04-16	00:19:44	1299	5353	118	325	0
2405	2016-07-22	00:14:03	1129	932	374	97	0
2411	2016-08-18	00:59:04	418	4394	295	115	2
2416	2016-06-16	00:57:54	1320	5870	234	275	2
2422	2016-10-07	00:02:59	396	1568	306	288	0
2428	2017-10-10	00:39:43	135	377	398	267	0
2433	2017-06-24	00:19:53	84	1348	260	32	0
2439	2017-06-16	00:45:29	1505	5056	226	120	2
2445	2016-02-14	00:42:06	1380	467	385	31	0
2449	2017-07-18	00:43:22	978	1074	358	312	0
2450	2017-06-28	00:41:04	789	3304	117	190	0
2456	2017-09-07	00:58:41	1072	938	45	202	2
2462	2017-04-15	00:14:18	776	5117	256	47	0
2467	2016-04-09	00:20:16	1221	6443	79	337	0
2473	2016-11-03	00:59:59	1490	6241	152	118	2
2479	2017-03-03	00:36:17	869	959	366	254	0
2484	2017-04-19	00:28:57	999	1654	381	350	0
2490	2017-01-23	00:48:22	1869	6543	89	30	2
2496	2016-05-03	00:31:29	32	2248	171	236	0
2501	2017-11-09	00:51:18	1630	2645	283	22	2
2507	2016-03-07	00:16:43	34	2978	178	325	0
2513	2016-11-16	00:44:44	872	5161	257	165	0
2518	2017-12-09	00:25:20	1433	1238	290	394	0
2524	2016-09-19	00:36:00	216	5166	262	7	0
2530	2017-09-02	00:23:44	1756	5390	323	347	0
2535	2017-10-15	00:56:12	327	3641	212	152	2
2541	2016-11-23	00:53:52	1406	3674	327	357	2
2547	2017-11-28	00:06:33	723	750	41	203	0
2552	2017-12-28	00:59:25	42	2441	27	196	2
2558	2017-10-28	00:20:28	1428	4058	203	287	0
2564	2017-01-06	00:42:09	762	5567	31	177	0
2569	2017-11-18	00:33:15	612	2490	86	362	0
2575	2017-06-22	00:54:09	888	4306	335	245	2
2581	2017-01-22	00:08:44	1516	3458	340	369	0
2585	2017-05-01	00:37:27	1516	2378	297	208	0
2586	2016-07-17	00:12:00	89	2472	349	91	0
2592	2016-03-11	00:41:08	656	1788	172	178	0
2598	2016-06-23	00:05:00	1591	5424	24	370	0
2603	2017-07-28	00:40:34	1076	5872	162	313	0
2609	2016-09-17	00:29:50	119	5024	110	378	0
2615	2017-09-20	00:15:05	1007	2606	270	141	0
2620	2016-10-21	00:57:01	370	3156	395	159	2
2626	2016-07-01	00:14:02	1847	5574	373	153	0
2632	2017-01-26	00:06:55	378	2843	55	69	0
2637	2017-12-26	00:13:29	360	5483	311	391	0
2643	2016-10-20	00:57:53	789	2452	278	344	2
2649	2017-12-15	00:34:45	1000	6548	211	182	0
2654	2016-09-21	00:14:25	1104	677	164	245	0
2660	2017-05-03	00:45:28	584	2428	300	278	2
2666	2017-02-23	00:34:36	1563	5014	188	262	0
2671	2017-06-06	00:28:56	14	5058	140	338	0
2677	2017-04-10	00:42:09	938	5895	376	352	0
2683	2016-12-26	00:54:16	1019	4523	223	300	2
2688	2016-07-09	00:53:04	497	6169	63	80	2
2694	2017-12-24	00:38:53	1174	6244	351	119	0
2700	2016-02-15	00:49:17	1862	1283	228	44	2
2705	2017-08-11	00:47:38	795	1329	33	370	2
2711	2017-11-17	00:10:52	1702	6345	362	371	0
2717	2016-06-16	00:37:50	698	3140	375	26	0
2721	2017-01-01	00:01:06	1972	5235	281	301	0
2722	2016-05-19	00:51:14	267	626	397	90	2
2728	2016-01-01	00:21:22	1154	6053	390	166	0
2734	2016-06-25	00:57:59	488	1905	154	70	2
2739	2017-07-04	00:28:21	2	2221	317	312	0
2745	2017-08-22	00:28:33	548	1538	308	246	0
2751	2016-10-09	00:54:38	343	4098	314	106	2
2756	2016-01-15	00:31:36	1555	5766	327	165	0
2762	2016-08-26	00:50:02	1851	645	338	12	2
2768	2016-02-07	00:53:56	1308	5093	138	5	2
2773	2016-05-12	00:38:48	602	1244	148	163	0
2779	2016-07-06	00:03:32	1592	1502	303	338	0
2785	2016-05-15	00:51:07	52	2862	388	252	2
2790	2016-09-05	00:40:18	1041	5544	222	134	0
2796	2016-02-16	00:53:15	1922	3955	301	251	2
2802	2016-11-12	00:38:25	1165	1289	385	362	0
2807	2017-12-25	00:49:15	488	2987	152	289	2
2813	2016-07-02	00:23:09	932	6356	257	334	0
2819	2016-12-07	00:54:47	1206	5620	384	373	2
2824	2016-03-15	00:22:47	766	2114	120	11	0
2830	2017-12-06	00:52:29	512	1519	307	5	2
2836	2017-09-01	00:30:53	109	5369	148	378	0
2841	2017-09-27	00:31:32	198	4888	199	260	0
2847	2017-04-14	00:49:57	406	5066	400	331	2
2853	2017-10-27	00:17:03	1005	6237	196	177	0
2857	2017-06-23	00:00:03	523	3323	173	80	0
2858	2017-01-10	00:09:41	1331	2524	344	154	0
2864	2017-06-20	00:40:56	1863	3726	9	141	0
2870	2016-08-19	00:40:30	395	2429	179	122	0
2875	2016-06-20	00:04:09	1417	79	222	285	0
2881	2016-08-03	00:30:06	158	5702	269	97	0
2887	2017-01-08	00:20:32	1825	2539	273	200	0
2892	2017-10-28	00:18:00	1922	5222	165	321	0
2898	2016-11-01	00:49:49	136	6415	28	218	2
2904	2016-02-20	00:01:39	1322	4705	345	228	0
2909	2017-10-12	00:15:11	336	5646	273	128	0
2915	2016-05-21	00:06:34	1519	3137	318	381	0
2921	2017-10-13	00:56:53	713	3297	396	216	2
2926	2016-09-27	00:47:04	866	961	108	3	2
2932	2017-10-24	00:11:03	161	2413	136	218	0
2938	2017-07-14	00:40:56	1378	137	57	300	0
2943	2017-10-19	00:41:31	218	102	380	164	0
2949	2017-08-27	00:52:02	736	2172	213	271	2
2955	2017-02-26	00:52:41	1636	1690	257	363	2
2960	2016-09-01	00:34:47	92	780	300	213	0
2966	2016-02-04	00:33:28	1068	6390	203	97	0
2972	2016-01-05	00:18:18	1609	253	361	237	0
2977	2016-03-06	00:51:22	1105	866	261	236	2
2983	2016-08-19	00:57:53	630	3	358	373	2
2989	2016-10-02	00:23:17	1733	4700	334	238	0
2993	2017-08-11	00:26:32	289	5127	293	378	0
2994	2017-04-27	00:11:22	696	5557	368	167	0
3000	2016-03-26	00:31:41	15	1454	132	373	0
3006	2016-07-09	00:32:05	1707	2021	35	329	0
3011	2016-11-26	00:37:16	789	486	335	201	0
3017	2016-09-15	00:17:34	590	2768	136	131	0
3023	2016-01-20	00:06:40	1525	3044	185	121	0
3028	2017-09-27	00:34:18	1694	2997	109	381	0
3034	2016-09-12	00:19:12	51	6618	178	367	0
3040	2017-07-27	00:05:38	900	5994	96	356	0
3045	2016-01-24	00:33:56	1063	5936	360	275	0
3051	2016-10-04	00:44:04	1858	6634	397	257	0
3057	2016-10-04	00:12:38	91	2830	107	44	0
3062	2016-07-08	00:00:01	1700	2305	219	348	0
3068	2016-05-04	00:44:57	695	3818	398	94	0
3074	2017-11-20	00:00:08	1665	936	220	314	0
3079	2016-08-04	00:04:35	1976	4967	134	236	0
3085	2016-11-24	00:54:41	1225	1590	269	371	2
3091	2017-01-17	00:04:58	1395	1940	13	97	0
3096	2016-08-28	00:10:10	1363	1779	163	68	0
3102	2017-07-16	00:37:42	1309	2972	61	237	0
3108	2016-08-14	00:38:05	1983	2012	332	135	0
3113	2016-03-07	00:29:28	1148	4778	256	300	0
3119	2017-09-15	00:40:43	996	4349	267	334	0
3125	2016-03-12	00:46:37	565	5931	194	45	2
3129	2016-06-16	00:44:36	491	5803	12	224	0
3130	2017-06-01	00:47:43	1958	1121	44	309	2
3136	2017-06-20	00:35:10	449	3712	137	27	0
3142	2017-09-04	00:05:20	1358	4239	138	245	0
3147	2017-02-06	00:58:35	1733	6235	179	174	2
3153	2017-10-15	00:39:01	1853	5731	141	245	0
3159	2016-05-03	00:25:12	1019	943	150	132	0
3164	2017-12-02	00:36:01	1122	3488	117	64	0
3170	2017-07-25	00:10:47	669	4328	35	227	0
3176	2016-09-08	00:31:15	964	1770	361	385	0
3181	2017-12-16	00:06:57	738	816	43	327	0
3187	2017-07-09	00:09:48	1415	4008	338	381	0
3193	2017-10-20	00:56:44	1229	1342	250	124	2
3198	2017-01-17	00:50:55	100	1018	154	282	2
3204	2017-01-10	00:24:38	1761	2760	146	177	0
3210	2016-10-17	00:16:19	670	5328	179	143	0
3215	2017-08-08	00:25:25	985	2264	109	62	0
3221	2016-02-28	00:07:36	392	5279	239	61	0
3227	2016-12-12	00:59:01	87	4503	156	365	2
3232	2016-07-07	00:59:38	930	2424	375	13	2
3238	2017-05-09	00:32:18	481	3895	148	53	0
3244	2016-09-03	00:07:27	1293	5225	138	65	0
3249	2016-11-17	00:27:48	137	1187	154	5	0
3255	2017-08-07	00:16:14	961	2360	26	388	0
3261	2016-04-10	00:36:37	209	1169	232	91	0
3265	2016-09-08	00:36:58	589	882	277	88	0
3266	2017-03-14	00:21:19	1271	3856	5	179	0
3272	2016-09-19	00:44:26	15	51	58	386	0
3278	2016-03-18	00:27:33	1186	6114	252	317	0
3283	2016-08-17	00:29:23	1849	42	373	1	0
3289	2016-02-11	00:23:45	599	6167	351	292	0
3295	2016-04-05	00:08:12	416	3636	354	127	0
3300	2017-02-08	00:58:37	741	1506	218	104	2
3306	2017-09-18	00:38:16	1343	5112	49	199	0
3312	2017-03-18	00:01:08	46	2981	82	194	0
3317	2016-02-03	00:26:52	1825	11	184	262	0
3323	2016-03-07	00:20:22	1160	2958	187	383	0
3329	2017-11-09	00:35:18	36	1096	94	206	0
3334	2017-11-22	00:40:46	1797	2930	265	242	0
3340	2017-01-17	00:38:34	1301	4443	295	67	0
3346	2017-10-16	00:48:45	180	6236	155	27	2
3351	2017-06-22	00:42:55	1750	6665	115	31	0
3357	2017-08-15	00:24:37	1450	5933	11	3	0
3363	2017-09-09	00:32:33	1330	839	94	121	0
3368	2016-07-05	00:32:19	1858	2499	386	90	0
3374	2017-06-18	00:26:16	127	339	154	173	0
3380	2017-09-15	00:07:30	957	864	65	76	0
3385	2016-09-03	00:38:25	603	1905	43	332	0
3391	2017-02-04	00:49:07	81	3327	151	260	2
3397	2017-04-25	00:09:08	96	3013	369	310	0
3401	2016-03-18	00:56:05	1264	5750	255	185	2
3402	2016-07-15	00:46:23	1324	6303	243	331	2
3408	2017-10-17	00:46:06	1140	1517	239	8	2
3414	2017-04-04	00:10:46	146	1968	221	72	0
3419	2016-08-08	00:58:53	1233	5853	398	344	2
3425	2017-06-24	00:34:21	312	4372	106	286	0
3431	2017-06-21	00:52:29	943	6629	147	374	2
3436	2016-02-02	00:09:49	739	3516	71	303	0
3442	2017-06-25	00:20:22	1359	4589	273	388	0
3448	2016-11-21	00:10:43	160	3415	171	247	0
3453	2017-02-17	00:30:47	10	3946	295	254	0
3459	2017-07-05	00:16:49	243	2848	305	70	0
3465	2016-08-22	00:51:08	216	2840	198	187	2
3470	2017-03-19	00:43:37	1256	4973	253	289	0
3476	2017-01-18	00:05:32	212	1767	52	111	0
3482	2016-11-14	00:14:10	810	3299	322	45	0
3487	2017-08-08	00:14:55	1146	2871	261	102	0
3493	2016-07-12	00:45:42	878	5866	345	204	2
3499	2017-11-28	00:19:51	1836	4378	126	255	0
3504	2017-08-25	00:38:44	232	3545	259	162	0
3510	2016-01-20	00:19:07	1303	4873	349	280	0
3516	2017-03-27	00:04:21	162	5059	3	120	0
3521	2017-01-25	00:27:25	104	1514	10	327	0
3527	2016-04-10	00:18:42	1368	4662	190	306	0
3533	2016-09-15	00:44:54	779	457	185	17	0
3537	2017-04-04	00:54:51	621	910	66	158	2
3538	2016-03-03	00:27:55	1890	713	180	62	0
3544	2017-10-12	00:38:33	23	6603	174	278	0
3550	2016-02-10	00:54:52	1393	192	213	153	2
3555	2017-06-04	00:58:56	52	4167	189	236	2
3561	2016-05-05	00:10:40	834	3254	228	98	0
3567	2016-12-09	00:29:21	1832	1020	26	370	0
3572	2016-10-06	00:18:03	758	499	363	88	0
3578	2016-08-04	00:29:16	394	2955	73	193	0
3584	2017-03-08	00:36:57	1649	6643	150	203	0
3589	2016-05-12	00:59:07	1556	3053	280	364	2
3595	2017-07-18	00:41:33	228	4199	151	199	0
3601	2016-01-05	00:13:20	1763	6347	234	363	0
3606	2016-10-01	00:35:20	134	4954	10	47	0
3612	2017-09-02	00:26:44	57	352	210	218	0
3618	2017-08-21	00:24:24	928	4110	120	395	0
3623	2017-11-27	00:10:24	387	2079	264	221	0
3629	2017-06-23	00:12:24	820	6145	286	144	0
3635	2016-09-25	00:08:47	1404	5574	305	332	0
3640	2016-01-12	00:37:45	785	1795	106	134	0
3646	2016-05-18	00:50:15	1398	3040	75	333	2
3652	2016-01-23	00:25:00	1239	2986	145	395	0
3657	2016-06-16	00:56:17	904	5645	307	173	2
3663	2016-11-20	00:27:07	1022	5936	169	33	0
3669	2017-05-13	00:53:50	731	5020	340	189	2
3673	2016-12-20	00:09:07	351	2416	273	114	0
3674	2016-07-13	00:09:00	1103	5776	165	106	0
3680	2016-08-14	00:58:45	183	5589	65	46	2
3686	2016-06-23	00:46:04	620	1842	188	347	2
3691	2017-12-01	00:53:47	965	4847	110	56	2
3697	2017-03-12	00:30:25	1780	6378	318	244	0
3703	2016-12-07	00:47:59	236	4757	16	225	2
3708	2017-06-19	00:43:55	82	6290	359	81	0
3714	2016-10-05	00:37:03	1561	4116	224	331	0
3720	2016-08-24	00:50:46	660	4071	325	337	2
3725	2016-08-04	00:08:26	599	1696	374	179	0
3731	2016-03-17	00:22:00	1132	6426	282	292	0
3737	2016-08-22	00:08:57	1727	21	235	156	0
3742	2017-02-21	00:34:51	818	3848	87	14	0
3748	2016-11-01	00:55:59	1881	3172	332	309	2
3754	2016-06-05	00:47:38	320	3272	63	261	2
3759	2017-04-09	00:41:56	1967	3883	59	303	0
3765	2017-12-25	00:33:54	143	4934	342	204	0
3771	2017-01-06	00:36:16	572	5708	278	317	0
3776	2016-06-09	00:10:43	1685	2904	135	48	0
3782	2016-04-24	00:52:28	496	4128	85	209	2
3788	2016-04-09	00:50:33	677	3409	161	55	2
3793	2017-05-16	00:55:21	387	2297	176	121	2
3799	2017-04-10	00:28:27	1900	5885	184	342	0
3805	2017-12-19	00:41:53	1934	1017	243	161	0
3809	2016-02-05	00:06:40	1476	235	264	133	0
3810	2017-04-17	00:11:43	1412	2774	183	230	0
3816	2017-01-18	00:06:52	606	783	68	317	0
3822	2017-03-13	00:55:09	762	47	143	20	2
3827	2017-11-25	00:16:33	847	1133	230	344	0
3833	2016-02-20	00:55:30	1539	5956	385	359	2
3839	2017-03-03	00:46:37	734	4381	329	260	2
3844	2016-04-02	00:40:00	946	4942	13	224	0
3850	2017-10-07	00:54:51	1054	1401	225	124	2
3856	2016-01-23	00:13:55	211	2184	62	200	0
3861	2017-03-13	00:39:39	1757	1976	41	182	0
3867	2017-06-16	00:49:38	173	491	80	22	2
3873	2017-11-05	00:35:08	1531	1454	216	379	0
3876	2016-05-05	00:33:03	362	2007	165	44	0
3878	2016-07-13	00:42:21	713	2458	221	265	0
3879	2017-08-01	00:35:51	626	1493	365	393	0
3880	2017-02-14	00:41:20	1275	4808	71	234	0
3881	2017-08-17	00:10:10	1180	1453	4	187	0
3882	2016-02-13	00:09:43	273	2418	9	330	0
3883	2017-10-25	00:21:19	54	2777	35	89	0
3884	2016-11-20	00:10:33	1747	6624	206	88	0
3924	2016-12-28	00:10:55	1403	3191	105	342	0
3929	2016-09-09	00:16:31	1990	5171	322	199	0
3935	2016-05-21	00:29:46	1197	3273	41	185	0
3941	2016-12-13	00:37:25	434	5980	237	307	0
3945	2017-10-17	00:24:58	1069	3866	221	53	0
3951	2017-03-26	00:32:09	1215	653	299	359	0
3957	2016-08-19	00:53:30	385	1274	215	377	2
3962	2016-01-28	00:12:04	1348	3811	357	341	0
3968	2017-06-27	00:57:42	695	6637	286	178	2
3974	2017-08-17	00:36:51	243	67	160	79	0
3979	2016-07-22	00:33:53	797	484	313	32	0
3985	2016-02-01	00:54:33	1097	5704	349	358	2
3991	2016-09-22	00:38:20	562	4650	175	363	0
3996	2016-12-02	00:24:25	1930	6023	187	54	0
1	2017-07-25	00:54:10	1035	678	193	181	2
4003	2017-12-12	00:46:45	2004	801	45	150	\N
4004	2017-12-12	00:24:45	2004	801	5	41	0
\.


--
-- Name: trajet_id_trajet_seq; Type: SEQUENCE SET; Schema: public; Owner: fredo
--

SELECT pg_catalog.setval('trajet_id_trajet_seq', 4004, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: fredo
--

COPY users (id_user, prenom, nom, annaiss, credit, abonnement) FROM stdin;
2	Luci	Atay	1967	0	normal
3	Kittie	Albe	1996	0	jeune
4	Dwain	Almodova	1995	0	jeune
5	Tracy	Arabia	1970	0	normal
6	Deanna	Able	1997	0	jeune
7	Nicky	Bagnaschi	1980	0	normal
8	Lilly	Agudelo	1988	0	normal
9	Casey	Atengco	1960	0	normal
10	Brigida	Arora	1986	0	normal
11	Broderick	Alven	1984	0	normal
12	Verna	Alvira	1981	0	normal
13	Christel	Babena	2001	0	jeune
14	Hollis	Albee	1986	0	normal
15	Syble	Alepin	1974	0	normal
16	Les	Bailony	1994	0	jeune
17	Brandy	Baculpo	1976	0	normal
18	Glennis	Bah	1988	0	normal
19	Mitchell	Banco	1972	0	normal
20	Lorelei	Altwies	1979	0	normal
21	Winnifred	Bachner	1982	0	normal
22	Lura	Balistrieri	1963	0	normal
23	Ruthann	Agle	1976	0	normal
24	Wei	Aeschbacher	1989	0	normal
25	Jose	Abubakr	1967	0	normal
26	Laurence	Bailiff	1968	0	normal
27	Salvador	Astrella	1992	0	normal
28	Syble	Beilinson	1965	0	normal
29	Miriam	Bavelas	1991	0	normal
30	Susy	Abundis	1975	0	normal
31	Amberly	Arritola	1965	0	normal
32	Pennie	Aswegan	1966	0	normal
33	Diane	Abruzzino	1967	0	normal
34	Sylvia	Baunleuang	1968	0	normal
35	Olga	Annicchiarico	1981	0	normal
36	Rodney	Anewalt	1985	0	normal
37	Heath	Abts	1986	0	normal
38	Contessa	Armen	1985	0	normal
39	Akilah	Astry	1970	0	normal
40	Jamal	Beacom	1964	0	normal
41	Minta	Balangatan	1961	0	normal
42	Lyndia	Ashkettle	1977	0	normal
43	Esta	Barera	1992	0	normal
44	Meredith	Amott	1977	0	normal
45	Dwight	Auton	1993	0	jeune
46	Marylyn	Barile	1961	0	normal
47	Louise	Alf	1974	0	normal
48	Ramon	Altaras	1969	0	normal
49	Roberta	Aguele	1963	0	normal
50	Karl	Agnelli	1988	0	normal
51	Sylvia	Barbagelata	1978	0	normal
52	Delicia	Alario	1989	0	normal
53	Ila	Arnst	1965	0	normal
54	Nina	Bacho	1982	0	normal
55	Alona	Behrman	1968	0	normal
56	Malvina	Abt	1969	0	normal
57	Vada	Bayete	2002	0	jeune
58	Tanya	Agamao	1989	0	normal
59	Nathaniel	Angeletti	1969	0	normal
60	Adelia	Ahlbrecht	1986	0	normal
61	Chi	Ammirati	2002	0	jeune
62	William	Baetz	1977	0	normal
63	Lorelei	Apshire	1974	0	normal
64	Marylouise	Baillargeon	1981	0	normal
65	Luetta	Abele	1991	0	normal
66	Deirdre	Agresti	1993	0	jeune
67	Jerry	Allenbaugh	1989	0	normal
68	Allison	Alejos	1984	0	normal
69	Candi	Arko	1997	0	jeune
70	Kiley	Barlett	1998	0	jeune
71	Darcy	Beauchesne	1989	0	normal
72	Jerry	Andes	1963	0	normal
73	Danuta	Asta	1986	0	normal
74	Val	Aylock	1989	0	normal
75	Bronwyn	Amorello	1985	0	normal
76	Amado	Bartlone	2002	0	jeune
77	Darius	Aivao	1966	0	normal
78	Polly	Abdulaziz	1973	0	normal
79	Ina	Abetrani	1996	0	jeune
80	Marshall	Abigantus	1975	0	normal
81	Pamela	Azatyan	1969	0	normal
82	Maris	Auyeung	1964	0	normal
83	Dorthea	Baltrip	1961	0	normal
84	Necole	Beirise	1975	0	normal
85	Sherilyn	Beigert	1973	0	normal
86	Glayds	Antill	1963	0	normal
87	Bong	Balckwell	1974	0	normal
88	Ryan	Bartolotto	1978	0	normal
89	Sandee	Aucter	1984	0	normal
90	Lizzie	Asamoah	1960	0	normal
91	Karie	Acheson	1973	0	normal
92	Derek	Beachell	1980	0	normal
93	Denisha	Albus	1982	0	normal
94	Kyla	Androes	1964	0	normal
95	Katina	Aring	2001	0	jeune
96	Kathline	Bastille	1960	0	normal
97	Van	Alegria	1985	0	normal
98	Gearldine	Bedsaul	1976	0	normal
99	Josefine	Arndell	1966	0	normal
100	Marylyn	Begley	1998	0	jeune
101	Drusilla	Ar	1976	0	normal
102	Kendal	Balzer	1960	0	normal
103	Philomena	Baldyga	1984	0	normal
104	Ruthe	Agrela	1985	0	normal
105	Victor	Baumiester	1979	0	normal
106	Consuelo	Ahrendt	1981	0	normal
107	Rufina	Alfonso	1976	0	normal
108	Fumiko	Behrends	1976	0	normal
109	Susie	Andreozzi	1991	0	normal
110	Delphine	Aubel	2001	0	jeune
111	Judie	Andren	1973	0	normal
112	Na	Arnot	1995	0	jeune
113	Berneice	Azer	1984	0	normal
114	Suanne	Ballman	1967	0	normal
115	Maybelle	Baird	1983	0	normal
116	Lessie	Barnell	1976	0	normal
117	Sherrell	Arter	1970	0	normal
118	Coreen	Armato	1965	0	normal
119	Tuan	Agostinelli	1981	0	normal
120	Denese	Ballreich	1986	0	normal
121	Larissa	Angelico	1966	0	normal
122	Bernie	Bahlmann	1963	0	normal
123	Lucilla	Ballinger	1977	0	normal
124	Roosevelt	Aragan	1980	0	normal
125	Ahmad	Bartin	1998	0	jeune
126	Fernanda	Aukes	1990	0	normal
127	Maribeth	Auyeung	1999	0	jeune
128	Ceola	Barrientes	1985	0	normal
129	Ena	Altavilla	1961	0	normal
130	Many	Aronow	1981	0	normal
131	Karleen	Ballard	1986	0	normal
132	Carlita	Balliett	1984	0	normal
133	Roselee	Aragon	1991	0	normal
134	Shanel	Babinski	1967	0	normal
135	Gil	Appl	1988	0	normal
136	Audrey	Attanasio	1981	0	normal
137	Dino	Arrison	1996	0	jeune
138	Zula	Abramek	1987	0	normal
139	Dessie	Arroyos	1995	0	jeune
140	Cristobal	Auguste	1984	0	normal
141	Garrett	Behal	1965	0	normal
142	Nery	Appell	1979	0	normal
143	Lindy	Affronti	1980	0	normal
144	Valrie	Alamo	2001	0	jeune
145	Owen	Abling	1994	0	jeune
146	Naida	Anway	1978	0	normal
147	Dewitt	Beedles	1997	0	jeune
148	Tisha	Azhocar	1974	0	normal
149	Devona	Atherton	1998	0	jeune
150	Louvenia	Barrasa	1965	0	normal
151	Sima	Baughan	1969	0	normal
152	Sherice	Abdullai	1976	0	normal
153	Dwana	Andrews	1968	0	normal
154	Charita	Bankey	1995	0	jeune
155	Tiny	Balasubramani	1970	0	normal
156	Andrew	Akinyooye	1976	0	normal
157	Meghann	Baisten	1978	0	normal
158	Ila	Anastasia	2000	0	jeune
159	Dotty	Barcelona	1979	0	normal
160	Joya	Beliles	1995	0	jeune
161	Nolan	Ashraf	1972	0	normal
162	Anika	Araneo	1972	0	normal
163	Muriel	Alquisira	1990	0	normal
164	Yi	Badley	1985	0	normal
165	Gita	Asato	1981	0	normal
166	Donita	Beau	1966	0	normal
167	Charleen	Aubertine	1997	0	jeune
168	Zana	Barte	1968	0	normal
169	Celena	Aikin	1982	0	normal
170	Valencia	Balkey	1992	0	normal
171	Laurinda	Agler	1971	0	normal
172	Dell	Aiola	1961	0	normal
173	Alexa	Angelico	1999	0	jeune
174	Alaine	Batkin	1980	0	normal
175	Leena	Abadie	1991	0	normal
176	Charmain	Barlock	2000	0	jeune
177	Troy	Assum	1988	0	normal
178	Erna	Arons	1969	0	normal
179	Christiane	Basten	1996	0	jeune
180	Shondra	Alphonse	1967	0	normal
181	Julie	Basey	1989	0	normal
182	Altha	Arab	1994	0	jeune
183	Leland	Awalt	1985	0	normal
184	Renita	Axline	1971	0	normal
185	Keneth	Alva	1990	0	normal
186	Rene	Bacha	1983	0	normal
187	Soila	Andrae	1998	0	jeune
188	Shaunda	Addams	1965	0	normal
189	Joel	Atzinger	1971	0	normal
190	Francesco	Allvin	1995	0	jeune
191	Hannah	Baumert	1996	0	jeune
192	William	Beakley	1992	0	normal
193	Neil	Banderas	2001	0	jeune
194	Verdell	Bacchi	1996	0	jeune
195	Elizabet	Balkcom	2002	0	jeune
196	Luisa	Balkus	1989	0	normal
197	Craig	Anzideo	2001	0	jeune
198	Nell	Ayotte	1994	0	jeune
199	Maryanne	Acly	1998	0	jeune
200	Nickolas	Baydal	1975	0	normal
201	Alton	Balcer	1987	0	normal
202	Norberto	Barretta	1960	0	normal
203	Winter	Allphin	1993	0	jeune
204	Ignacia	Arturo	2002	0	jeune
205	Lucy	America	1988	0	normal
206	Thurman	Angelilli	1976	0	normal
207	Rosaria	Allegra	1965	0	normal
208	Idella	Avie	1982	0	normal
209	Ewa	Battin	1994	0	jeune
210	Cherie	Beaushaw	1962	0	normal
211	Randolph	Almodova	1965	0	normal
212	Michelina	Balay	1972	0	normal
213	Tammy	Barus	1960	0	normal
214	Danita	Arizaga	1962	0	normal
215	Dann	Backman	1969	0	normal
216	Lena	Basora	1990	0	normal
217	Loraine	Banko	1965	0	normal
218	Vernie	Bagron	1964	0	normal
219	Solomon	Aldrige	1986	0	normal
220	Cheryl	Banta	1965	0	normal
221	Noelle	Beerle	2002	0	jeune
222	Santiago	Atamian	1982	0	normal
223	Maida	Balloon	1991	0	normal
224	India	Beatson	1994	0	jeune
225	Kirstie	Applegarth	1978	0	normal
226	Nanci	Ahle	1966	0	normal
227	Emerald	Andreasen	1972	0	normal
228	Clarinda	Ahern	1966	0	normal
229	Sebrina	Balsiger	1992	0	normal
230	Amie	Abbinanti	1962	0	normal
231	Elli	Becht	1965	0	normal
232	Marlyn	Alexaki	1982	0	normal
233	Kip	Bauce	1992	0	normal
234	Joseph	Althaus	1995	0	jeune
235	Irena	Apostol	1969	0	normal
236	Tyrone	Alterio	1982	0	normal
237	Leland	Adamo	1973	0	normal
238	Noah	Alvelo	1997	0	jeune
239	Patricia	Baez	1974	0	normal
240	Regan	Belcourt	1998	0	jeune
241	Arline	Bamforth	1997	0	jeune
242	Salina	Accardo	1973	0	normal
243	Reyes	Bachus	1973	0	normal
244	Ara	Beauchemin	1993	0	jeune
245	Scot	Abedelah	1997	0	jeune
246	Erick	Balmores	1983	0	normal
247	Stacy	Alfero	1983	0	normal
248	Birdie	Baldo	1972	0	normal
249	Hosea	Bejarano	1964	0	normal
250	Shiloh	Barut	1996	0	jeune
251	Evan	Arline	1999	0	jeune
252	Mardell	Astley	1962	0	normal
253	Ethan	Averill	1986	0	normal
254	Francesca	Amparo	1982	0	normal
255	Marilee	Beadle	1975	0	normal
256	Terry	Aggas	1975	0	normal
257	Becky	Bartone	1970	0	normal
258	Tobie	Balles	1994	0	jeune
259	Jackie	Barschdoor	1991	0	normal
260	Ed	Barrero	1995	0	jeune
261	Ashlyn	Bard	1982	0	normal
262	Tashia	Airth	1983	0	normal
263	Terrell	Aono	1991	0	normal
264	Janelle	Avitia	1961	0	normal
265	Angel	Adauto	1982	0	normal
266	Billie	Bax	1976	0	normal
267	Otelia	Barcelo	1980	0	normal
268	Zachary	Barretto	1990	0	normal
269	Lashell	Ao	1973	0	normal
270	Garland	Altom	1983	0	normal
271	Kareem	Abeb	1971	0	normal
272	Joanna	Baumhoer	2000	0	jeune
273	Sanford	Aldrow	1978	0	normal
274	Casie	Bautch	1977	0	normal
275	Madonna	Araiza	1962	0	normal
276	Arnoldo	Asante	1989	0	normal
277	Rhett	Abdou	1989	0	normal
278	Candy	Amer	1987	0	normal
279	Dena	Babjeck	1973	0	normal
280	Verdell	Baribeau	1979	0	normal
281	Breana	Barthen	1968	0	normal
282	Loriann	Arredla	1966	0	normal
283	Rene	Abdon	1995	0	jeune
284	Erika	Bai	1976	0	normal
285	Addie	Amen	1974	0	normal
286	Vanesa	Avirett	1977	0	normal
287	Arcelia	Ahler	1996	0	jeune
288	Candace	Beggs	1980	0	normal
289	Delois	Bartnik	1966	0	normal
290	Salvatore	Arntzen	1994	0	jeune
291	Colby	Beisser	1970	0	normal
292	Leandro	Abreu	1973	0	normal
293	Jovan	Alessio	1984	0	normal
294	Digna	Adens	1997	0	jeune
295	Adriane	Agent	1969	0	normal
296	Stephanie	Avery	1961	0	normal
297	Brenda	Barrois	1995	0	jeune
298	Ramona	Arcia	1995	0	jeune
299	Jacquiline	Agumga	1967	0	normal
300	Nestor	Awtry	1961	0	normal
301	Elsy	Adu	1971	0	normal
302	Chere	Allum	1976	0	normal
303	David	Alstad	1985	0	normal
304	Sima	Aines	1974	0	normal
305	Glayds	Baltodano	1969	0	normal
306	Mitsuko	Behymer	1995	0	jeune
307	Trenton	Abbey	1964	0	normal
308	Vickie	Alvarengo	1999	0	jeune
309	Jutta	Arcizo	1980	0	normal
310	Arlean	Baksi	1988	0	normal
311	Kristy	Belardo	1989	0	normal
312	Clemmie	Bamberger	1990	0	normal
313	Benny	Abeta	1977	0	normal
314	Kenyetta	Angviano	1984	0	normal
315	Robbi	Barsotti	2001	0	jeune
316	Larita	Bascetta	2001	0	jeune
317	Ethel	Axelrod	1974	0	normal
318	Leslee	Bartolotta	1999	0	jeune
319	Robin	Achor	1964	0	normal
320	Salvador	Alexandria	1964	0	normal
321	Coralie	Bechler	1961	0	normal
322	Augustus	Bazin	2001	0	jeune
323	Amee	Ajayi	1971	0	normal
324	Augustina	Beaber	2002	0	jeune
325	Erik	Abellera	1992	0	normal
326	Destiny	Bazzle	1963	0	normal
327	Maria	Aderman	1987	0	normal
328	Amparo	Asselin	1985	0	normal
329	Ward	Amarillas	1991	0	normal
330	Georgiann	Bednarowicz	1978	0	normal
331	Louann	Barios	1960	0	normal
332	Asia	Armendariz	1971	0	normal
333	Jason	Apresa	1990	0	normal
334	Leonel	Baccouche	1962	0	normal
335	Sonny	Arcilla	2001	0	jeune
336	Cleta	Aslin	1998	0	jeune
337	Cathryn	Ackison	1962	0	normal
338	Laverna	Akoni	1984	0	normal
339	Emmett	Auchmoody	1971	0	normal
340	Alice	Beckerdite	1960	0	normal
341	Theodora	Andras	1984	0	normal
342	Christy	Allanson	1977	0	normal
343	Ruth	Allmon	1998	0	jeune
344	Loyd	Bansbach	1968	0	normal
345	Nan	Aldas	1979	0	normal
346	Bruce	Amoros	1986	0	normal
347	Theda	Baltz	1992	0	normal
348	Yuriko	Bargo	1965	0	normal
349	Janeth	Becklund	1996	0	jeune
350	Valerie	Albers	1985	0	normal
351	Colin	Baltimore	1985	0	normal
352	James	Abundis	1973	0	normal
353	Jesica	Amacher	1991	0	normal
354	Morris	Basye	1974	0	normal
355	Robt	Bayouth	1979	0	normal
356	Magdalene	Abramowitz	1972	0	normal
357	Vesta	Aldape	1988	0	normal
358	Lachelle	Abramowski	2002	0	jeune
359	Della	Armeli	1997	0	jeune
360	Warner	Adickes	1980	0	normal
361	Ashlie	Auyon	1960	0	normal
362	Spencer	Batts	1985	0	normal
363	Fran	Banaszak	1998	0	jeune
364	Fredia	Atha	1999	0	jeune
365	Sherryl	Arimoto	1974	0	normal
366	Cinda	Barefield	1966	0	normal
367	Perry	Atchity	1975	0	normal
368	Amiee	Alberto	1999	0	jeune
369	Sang	Amoa	1990	0	normal
370	Griselda	Baisden	2002	0	jeune
371	Stefanie	Arcudi	1983	0	normal
372	Billie	Ailstock	1967	0	normal
373	Josefine	Bagi	1994	0	jeune
374	Trinidad	Barberis	1979	0	normal
375	Kerry	Abbs	1998	0	jeune
376	Nilda	Abbey	1993	0	jeune
377	Keren	Baillet	1987	0	normal
378	Lanelle	Allerman	1998	0	jeune
379	Dewitt	Baliga	1998	0	jeune
380	Neville	Ashdown	1991	0	normal
381	Georgia	Beady	1980	0	normal
382	Edward	Acierno	1962	0	normal
383	Herma	Aye	1986	0	normal
384	Dee	Beaumont	1990	0	normal
385	Theo	Acoff	1989	0	normal
386	Mechelle	Beecroft	1991	0	normal
387	Alberto	Beckley	1974	0	normal
388	Sheri	Ackroyd	1994	0	jeune
389	Shana	Baro	1983	0	normal
390	Agatha	Arzu	1988	0	normal
391	Antonetta	Bartholomeu	1972	0	normal
392	Rosia	Ballou	1974	0	normal
393	Suzie	Bechtold	1961	0	normal
394	Emily	Aplin	1991	0	normal
395	Matilde	Ambeau	1968	0	normal
396	Annabell	Allday	1990	0	normal
397	Trudy	Arnio	1983	0	normal
398	Marcela	Alvara	1978	0	normal
399	Bobette	Arquero	1963	0	normal
400	Letisha	Ambrosini	1963	0	normal
401	Holly	Bekis	1984	0	normal
402	Quinton	Athans	1984	0	normal
403	Lee	Almazan	1978	0	normal
404	Ardath	Banville	1969	0	normal
405	Octavio	Alicea	1984	0	normal
406	Dewey	Beam	1980	0	normal
407	Britt	Barthell	2001	0	jeune
408	Trish	Barbiere	1970	0	normal
409	Damon	Alsaqri	1981	0	normal
410	Heide	Bacchus	1976	0	normal
411	Devin	Bagshaw	2000	0	jeune
412	Ginger	Anker	1979	0	normal
413	Freddy	Atmore	1988	0	normal
414	Malena	Balerio	1980	0	normal
415	Hannelore	Bedenfield	1994	0	jeune
416	Golden	Ayer	1999	0	jeune
417	Kristeen	Baringer	1964	0	normal
418	Delilah	Abugn	1994	0	jeune
419	Shawnna	Ansoategui	1987	0	normal
420	Jaunita	Aragus	1997	0	jeune
421	Marcelle	Alfreds	1972	0	normal
422	Ying	Adami	1999	0	jeune
423	Macy	Bastien	2000	0	jeune
424	Lona	Ashly	1961	0	normal
425	Lacy	Bartleson	1994	0	jeune
426	Tanya	Alesci	1987	0	normal
427	Lona	Baver	1999	0	jeune
428	Numbers	Arnaldo	1982	0	normal
429	Elden	Aruiso	1997	0	jeune
430	Donn	Arcement	1999	0	jeune
431	Ron	Bardeen	1993	0	jeune
432	Karly	Alvarran	1961	0	normal
433	Dian	Babbs	1967	0	normal
434	Agnes	Bedney	1989	0	normal
435	Sol	Barra	1971	0	normal
436	Consuelo	Acevado	1989	0	normal
437	Lloyd	Arcudi	1990	0	normal
438	Albertine	Andrle	1961	0	normal
439	Emma	Amory	1991	0	normal
440	Holley	Bashline	1996	0	jeune
441	Tatum	Bearse	1966	0	normal
442	Janette	Bahner	1999	0	jeune
443	Brant	Armeli	1969	0	normal
444	Kacey	Barclay	1975	0	normal
445	Isabella	Arollo	1987	0	normal
446	Tai	Bastow	1991	0	normal
447	Lamonica	Alsberry	1978	0	normal
448	Jolyn	Ashton	2002	0	jeune
449	Alvin	Bartle	1982	0	normal
450	Cleta	Abramov	1968	0	normal
451	Luci	Ayars	2000	0	jeune
452	Minta	Bartleson	1995	0	jeune
453	Clarice	Banke	1965	0	normal
454	Reuben	Amour	1965	0	normal
455	Macy	Aiton	1964	0	normal
456	Ella	Beecken	1993	0	jeune
457	Regine	Bandin	1984	0	normal
458	Darin	Belden	1990	0	normal
459	Tenesha	Aber	1973	0	normal
460	Babara	Anzora	1970	0	normal
461	George	Ankeny	1997	0	jeune
462	Devona	Beckmann	1970	0	normal
463	Walter	Bashir	2001	0	jeune
464	Margy	Angelino	1964	0	normal
465	Chloe	Barcley	1962	0	normal
466	Abe	Albin	1969	0	normal
467	Isobel	Armas	1999	0	jeune
468	Gwenda	Amirian	1995	0	jeune
469	Yan	Beall	1970	0	normal
470	Ailene	Arndorfer	1977	0	normal
471	Edie	Barnar	1993	0	jeune
472	Daryl	Aikens	1975	0	normal
473	Jacqueline	Ahia	1968	0	normal
474	Margarett	Arca	1987	0	normal
475	Jammie	Artinger	1977	0	normal
476	Belva	Been	1974	0	normal
477	Cassi	Anderl	1963	0	normal
478	Lynda	Arel	1964	0	normal
479	Nichelle	Anes	1978	0	normal
480	Celestina	Baruffa	1992	0	normal
481	Eugenie	Battuello	1988	0	normal
482	Shon	Baquet	1974	0	normal
483	Stefania	Alfero	1989	0	normal
484	Nieves	Altmann	1968	0	normal
485	Mi	Ammann	1972	0	normal
486	Pei	Alvanez	1971	0	normal
487	Shemika	Antonio	1964	0	normal
488	Lucas	Belback	1975	0	normal
489	Steven	Adami	2000	0	jeune
490	Lurlene	Alessi	1989	0	normal
491	Albina	Bacca	1991	0	normal
492	Susy	Adderley	1972	0	normal
493	Nyla	Archila	1966	0	normal
494	Leeann	Aurand	1999	0	jeune
495	Reva	Bartosiak	1986	0	normal
496	Marcelle	Arline	1997	0	jeune
497	Annabel	Batson	1998	0	jeune
498	Lakenya	Allsbrooks	1991	0	normal
499	Angele	Andrus	1998	0	jeune
500	Bo	Backmon	1968	0	normal
501	Theresia	Barrett	1961	0	normal
502	Ileana	Banick	1964	0	normal
503	Ginette	Aue	2000	0	jeune
504	Herman	Aquilina	1999	0	jeune
505	Kerstin	Ambers	1990	0	normal
506	Robert	Bazan	1966	0	normal
507	Elinor	Balitas	1989	0	normal
508	Brittni	Almodova	1998	0	jeune
509	Odessa	Batte	1960	0	normal
510	Chance	Arnott	1975	0	normal
511	Queenie	Alhambra	1992	0	normal
512	Cristin	Badoni	1962	0	normal
513	Noah	Bayuk	1971	0	normal
514	Alva	Alexakis	1995	0	jeune
515	Kendrick	Alarid	1984	0	normal
516	Marva	Angalich	2002	0	jeune
517	Jamel	Babat	1985	0	normal
518	Reginald	Alcaide	1975	0	normal
519	Tayna	Bayly	2000	0	jeune
520	Von	Alberson	1966	0	normal
521	Nathalie	Barak	1970	0	normal
522	Charline	Ailiff	1985	0	normal
523	Kip	Ballenger	1994	0	jeune
524	Maisha	Baroldy	1973	0	normal
525	Charlott	Axsom	2000	0	jeune
526	Malissa	Barbara	1983	0	normal
527	Annabel	Barwell	1992	0	normal
528	Rosie	Bagent	2000	0	jeune
529	Johanne	Banton	1976	0	normal
530	Virgilio	Amolsch	1995	0	jeune
531	Marc	Adens	1970	0	normal
532	Lacy	Baze	1998	0	jeune
533	Carlene	Bacolor	1966	0	normal
534	Detra	Beckerle	1983	0	normal
535	Soila	Barchick	1995	0	jeune
536	Stephen	Belfiore	1974	0	normal
537	Keturah	Basich	2002	0	jeune
538	Phillis	Arquitt	1989	0	normal
539	Nam	Beckendorf	1968	0	normal
540	Christeen	Adriance	1985	0	normal
541	Danny	Amstutz	1987	0	normal
542	Alix	Beckstead	1982	0	normal
543	Merilyn	Alicia	1984	0	normal
544	Jon	Baden	1986	0	normal
545	Devin	Balfour	1985	0	normal
546	In	Bartos	1970	0	normal
547	Zana	Bedre	1982	0	normal
548	Kathryne	Alvirez	1998	0	jeune
549	Trista	Alcantas	1997	0	jeune
550	Bud	Beaubrun	1999	0	jeune
551	Iesha	Asevedo	1966	0	normal
552	Glendora	Bayuk	1967	0	normal
553	Nilsa	Bandy	2000	0	jeune
554	Jung	Bartoldus	1972	0	normal
555	Shanel	Belarmino	1995	0	jeune
556	Iva	Ando	1960	0	normal
557	Burma	Abramowski	1974	0	normal
558	Johnny	Avina	1993	0	jeune
559	Basil	Beilstein	1970	0	normal
560	Hosea	Barsh	1998	0	jeune
561	Andreas	Apo	1993	0	jeune
562	Anne	Beaner	1976	0	normal
563	Louie	Augustine	1973	0	normal
564	Cordell	Bagwill	1994	0	jeune
565	Wilbert	Aldi	2001	0	jeune
566	Blondell	Belgarde	1978	0	normal
567	Gabriel	Annable	2001	0	jeune
568	Lynda	Afoa	1973	0	normal
569	Oscar	Auther	1968	0	normal
570	Desmond	Arietta	1963	0	normal
571	Magaret	Batzer	1979	0	normal
572	Fausto	Aldridge	1968	0	normal
573	Rodrick	Aramini	1978	0	normal
574	Helena	Bechthold	1971	0	normal
575	Dayle	Barends	1982	0	normal
576	Lekisha	Albarado	1968	0	normal
577	Irving	Ageboi	1990	0	normal
578	Beverly	Anagnost	1962	0	normal
579	Markus	Ansbro	1994	0	jeune
580	Chong	Auala	1988	0	normal
581	Natalya	Agosto	1999	0	jeune
582	Otilia	Applewhite	1983	0	normal
583	Desmond	Arnitz	1996	0	jeune
584	Dulce	Acrey	1963	0	normal
585	Gladis	Archbell	2000	0	jeune
586	Misty	Almgren	1960	0	normal
587	Marylynn	Allende	1972	0	normal
588	Staci	Aumann	1991	0	normal
589	Harmony	Alberson	1993	0	jeune
590	Reuben	Balestrieri	1960	0	normal
591	Greta	Barayuga	1967	0	normal
592	Sylvester	Baumgartel	1996	0	jeune
593	Rolf	Bartnick	1975	0	normal
594	Cleveland	Babine	1993	0	jeune
595	Ronnie	Barkes	1996	0	jeune
596	Nelida	Bamfield	1960	0	normal
597	Cecil	Bedore	1991	0	normal
598	Halina	Adamczak	1970	0	normal
599	Rudolf	Bablak	1975	0	normal
600	Kermit	Austill	1978	0	normal
601	Catheryn	Allis	1962	0	normal
602	Yuonne	Autman	1989	0	normal
603	An	Allhands	1991	0	normal
604	Wendy	Bela	1978	0	normal
605	Mae	Barillaro	1963	0	normal
606	Meghann	Armfield	1987	0	normal
607	Apryl	Achord	1960	0	normal
608	Ella	Barnscater	1993	0	jeune
609	Ashley	Bargar	1971	0	normal
610	Whitley	Adamczak	1990	0	normal
611	Ilene	Barda	1992	0	normal
612	Alexandra	Barchick	1995	0	jeune
613	Clara	Atwater	1993	0	jeune
614	Benjamin	Asaeli	1976	0	normal
615	Lucille	Abdo	1967	0	normal
616	Jone	Arave	1997	0	jeune
617	Branden	Battles	1998	0	jeune
618	Fleta	Bagner	1970	0	normal
619	Elizabet	Asar	1982	0	normal
620	Jimmy	Bagg	1969	0	normal
621	Wanita	Ambrose	1965	0	normal
622	Leeanne	Allevato	1986	0	normal
623	Jasper	Ackison	1999	0	jeune
624	Sari	Amboise	1987	0	normal
625	Deeanna	Aljemal	1985	0	normal
626	Thomasina	Bagnall	1982	0	normal
627	Lise	Afoa	1967	0	normal
628	George	Avon	1986	0	normal
629	Gretta	Armenteros	1965	0	normal
630	Mammie	Beichner	1991	0	normal
631	Meryl	Balerio	1960	0	normal
632	Herschel	Auer	1965	0	normal
633	Afton	Bagger	1993	0	jeune
634	Stan	Baksh	1963	0	normal
635	Santa	Arabajian	1968	0	normal
636	Alisha	Amert	2002	0	jeune
637	Kaylene	Agnes	1989	0	normal
638	Kenna	Bazemore	1988	0	normal
639	Karyl	Arnaldo	1967	0	normal
640	Niesha	Addy	1978	0	normal
641	Cheyenne	Banter	1972	0	normal
642	Lanell	Aurelio	1993	0	jeune
643	Cordia	Amoe	2002	0	jeune
644	Paula	Anick	1991	0	normal
645	Flor	Beerly	1969	0	normal
646	Debi	Alvear	1960	0	normal
647	Leona	Ablin	1968	0	normal
648	Alishia	Ashcraft	1963	0	normal
649	Carmelia	Behrend	1969	0	normal
650	Gary	Adamson	1977	0	normal
651	Sofia	Balogun	1994	0	jeune
652	Haley	Aboud	1965	0	normal
653	Chrissy	Azuma	1990	0	normal
654	Freddie	Beerbohm	1966	0	normal
655	Luisa	Bartlet	1996	0	jeune
656	Lien	Beaz	1973	0	normal
657	Cathie	Barnaba	1987	0	normal
658	Phylis	Abdelmuti	1998	0	jeune
659	Rubin	Arau	1975	0	normal
660	Granville	Bayas	1988	0	normal
661	Ahmad	Agtarap	1981	0	normal
662	Susannah	Abston	1968	0	normal
663	Lily	Baria	1979	0	normal
664	Caroll	Balaz	1974	0	normal
665	Rea	Aksoy	1964	0	normal
666	Betty	Batte	1964	0	normal
667	Owen	Barillaro	1985	0	normal
668	Sherlene	Andre	1971	0	normal
669	Asha	Ampy	1967	0	normal
670	Maxine	Alaimo	1979	0	normal
671	Liz	Arneson	1989	0	normal
672	Danyell	Becera	1984	0	normal
673	Veronique	Amezcua	1962	0	normal
674	Shamika	Alviar	1973	0	normal
675	Chandra	Avona	2000	0	jeune
676	Jonah	Arnaudet	1999	0	jeune
677	Phil	Ahluwalia	1971	0	normal
678	Kasie	Bachar	1996	0	jeune
679	Marcelina	Aguirre	1998	0	jeune
680	Andree	Asen	1986	0	normal
681	Jetta	Appling	1964	0	normal
682	Elenore	Asner	1964	0	normal
683	Marge	Badenoch	1961	0	normal
684	Denisse	Abatiell	1985	0	normal
685	Tamatha	Begnoche	1993	0	jeune
686	Eden	Aud	1964	0	normal
687	Simonne	Agriesti	1986	0	normal
688	Kami	Bakanauskas	1963	0	normal
689	Kizzie	Amorin	1983	0	normal
690	Elidia	Balluch	1976	0	normal
691	Darron	Baratto	1960	0	normal
692	Gerald	Baragar	1963	0	normal
693	Shane	Beldon	1988	0	normal
694	Shery	Achterhof	1994	0	jeune
695	Milan	Alhaddad	1986	0	normal
696	Jutta	Bazzle	1967	0	normal
697	Sung	Antonovich	1964	0	normal
698	Efrain	Alvara	1968	0	normal
699	Tommie	Alegria	1962	0	normal
700	Ranee	Bastress	1988	0	normal
701	Althea	Baley	1978	0	normal
702	Hilde	Beidleman	1974	0	normal
703	Vaughn	Archiopoli	1988	0	normal
704	Valerie	Alfonzo	1987	0	normal
705	Martin	Barcenas	1970	0	normal
706	Cherelle	Andeson	1976	0	normal
707	Dennise	Ambrose	1963	0	normal
708	Jacquelynn	Barthell	1999	0	jeune
709	Breanna	Barhydt	1979	0	normal
710	Kelley	Abo	1978	0	normal
711	Xiao	Barkus	1992	0	normal
712	Lorna	Alvine	1997	0	jeune
713	Raymon	Archuletta	1988	0	normal
714	Evalyn	Amiot	1989	0	normal
715	Sixta	Ailiff	1982	0	normal
716	Elayne	Arzate	1984	0	normal
717	Annabel	Bamforth	1960	0	normal
718	Pamella	Baldinger	1993	0	jeune
719	Oma	Barbero	1986	0	normal
720	Gabrielle	Basiliere	1990	0	normal
721	Bee	Albach	1975	0	normal
722	Ligia	Beldon	1978	0	normal
723	Sherri	Baysmore	1992	0	normal
724	Garrett	Arenas	1993	0	jeune
725	Kaley	Arand	1992	0	normal
726	Zana	Bazil	1988	0	normal
727	Cordelia	Alfieri	1966	0	normal
728	Dee	Abella	1982	0	normal
729	Odette	Antos	1993	0	jeune
730	Abbey	Beene	1976	0	normal
731	Ronnie	Barricelli	1983	0	normal
732	Eloise	Beidler	1992	0	normal
733	Lillia	Alwazan	1990	0	normal
734	Maple	Arrojo	2001	0	jeune
735	Vannesa	Ameduri	1984	0	normal
736	Graig	Barris	1994	0	jeune
737	Coreen	Barnell	1996	0	jeune
738	Hortencia	Bednarz	1980	0	normal
739	Merlyn	Abell	1977	0	normal
740	Sebrina	Ayscue	1985	0	normal
741	Wynell	Ahlman	2000	0	jeune
742	Marceline	Acton	1986	0	normal
743	Lanita	Alton	1993	0	jeune
744	Krystina	Aseltine	1997	0	jeune
745	Silvia	Baldenegro	1976	0	normal
746	Juliann	Akerley	1963	0	normal
747	Staci	Almaguer	1996	0	jeune
748	Azucena	Affolter	1978	0	normal
749	Jerri	Anzualda	1974	0	normal
750	Romona	Askew	1963	0	normal
751	Carleen	Bairam	1976	0	normal
752	Tonisha	Autovino	1992	0	normal
753	Merrill	Acebo	2000	0	jeune
754	Yen	Alevras	2000	0	jeune
755	Malia	Alpert	2001	0	jeune
756	Sabine	Bakkala	1997	0	jeune
757	Alejandrina	Beagley	1972	0	normal
758	Long	Allie	1994	0	jeune
759	Chester	Baillie	1980	0	normal
760	Tara	Barocio	1993	0	jeune
761	Rickie	Allgeyer	2002	0	jeune
762	Sheri	Bartula	1981	0	normal
763	Elliott	Barnet	1998	0	jeune
764	Margit	Auter	1986	0	normal
765	Christopher	Barde	1990	0	normal
766	Reagan	Aversano	1979	0	normal
767	Kerrie	Badia	1973	0	normal
768	Dorian	Akpan	1973	0	normal
769	Latoya	Albertson	1987	0	normal
770	Glenn	Babbish	1975	0	normal
771	Wiley	Arocha	1997	0	jeune
772	Hector	Ammirato	1990	0	normal
773	Jocelyn	Affronti	1980	0	normal
774	Teofila	Auslander	1989	0	normal
775	Novella	Alves	1983	0	normal
776	Felicitas	Allery	1985	0	normal
777	Karren	Barriner	1988	0	normal
778	Shila	Augustyniak	1977	0	normal
779	Starla	Aguinaga	1976	0	normal
780	Cary	Andis	1968	0	normal
781	Kristle	Baitner	1980	0	normal
782	Carletta	Adamec	1996	0	jeune
783	Douglass	Ayars	1985	0	normal
784	Voncile	Almodovar	2002	0	jeune
785	Martha	Asby	1974	0	normal
786	Carolin	Antosh	2002	0	jeune
787	Adriane	Barbre	1972	0	normal
788	Maire	Arrey	1965	0	normal
789	Kendra	Armintrout	1978	0	normal
790	Rosalinda	Astrup	1996	0	jeune
791	Lael	Avolio	1960	0	normal
792	Antione	Banter	1970	0	normal
793	Margart	Barut	1983	0	normal
794	Britany	Annibale	1962	0	normal
795	Kylee	Beckner	1979	0	normal
796	Johana	Ballar	2002	0	jeune
797	Jacob	Bayne	1978	0	normal
798	Ernie	Bahl	1993	0	jeune
799	Hobert	Aske	1962	0	normal
800	Maud	Adling	1984	0	normal
801	Eileen	Arkontaky	1973	0	normal
802	Shawnta	Bailin	1988	0	normal
803	Ludivina	Ayersman	1972	0	normal
804	Maurine	Baese	1961	0	normal
805	Ricarda	Alderete	1999	0	jeune
806	Guadalupe	Beiter	1999	0	jeune
807	Brandon	Apana	1972	0	normal
808	Terrie	Agamao	1966	0	normal
809	William	Baro	1981	0	normal
810	Agripina	Bartolomei	1997	0	jeune
811	Narcisa	Aeschlimann	1960	0	normal
812	Shanna	Alverio	1963	0	normal
813	Michael	Abbington	1961	0	normal
814	Rafaela	Barriger	1972	0	normal
815	Lynwood	Arico	1993	0	jeune
816	Calandra	Arciola	1999	0	jeune
817	Shera	Aslinger	1961	0	normal
818	Davis	Ascensio	1960	0	normal
819	Alia	Amiri	1972	0	normal
820	Maurita	Androlewicz	1979	0	normal
821	Jay	Beachy	1975	0	normal
822	Katheryn	Barajos	1996	0	jeune
823	Krystle	Amodei	1967	0	normal
824	Tashia	Bachrodt	1970	0	normal
825	Elsie	Andebe	1999	0	jeune
826	Sulema	Amderson	1975	0	normal
827	Una	Adomaitis	1987	0	normal
828	Kandis	Baldiviez	1979	0	normal
829	Cary	Augustine	1970	0	normal
830	Pearline	Amass	1961	0	normal
831	Valery	Asel	1969	0	normal
832	Jodi	Abdelhamid	1991	0	normal
833	Hsiu	Beiter	1997	0	jeune
834	June	Abolt	1977	0	normal
835	Evelyne	Begg	1990	0	normal
836	Jennefer	Baenziger	1971	0	normal
837	Stevie	Alnutt	1970	0	normal
838	Olympia	Alvira	1968	0	normal
839	Meg	Aschim	1965	0	normal
840	Larissa	Allgaeuer	1978	0	normal
841	Jeanelle	Aono	1995	0	jeune
842	Carlota	Almendarez	1992	0	normal
843	Joshua	Arrollo	1984	0	normal
844	Celina	Arigo	1986	0	normal
845	Iris	Bagent	1987	0	normal
846	Leif	Allor	1982	0	normal
847	Rubi	Aliaga	2000	0	jeune
848	Joanne	Amor	1971	0	normal
849	Marlana	Arnold	1971	0	normal
850	Oretha	Baibak	1976	0	normal
851	Chuck	Baugham	1988	0	normal
852	Kizzie	Albany	1998	0	jeune
853	Cathie	Bairo	2001	0	jeune
854	Carline	Beckstrom	1993	0	jeune
855	Darlene	Ashely	1980	0	normal
856	Lindsy	Atala	1985	0	normal
857	Hiroko	Arriazola	1982	0	normal
858	Tory	Arrow	1971	0	normal
859	Nina	Bambrick	1988	0	normal
860	Jarrod	Behanna	1967	0	normal
861	Raylene	Barscewski	1985	0	normal
862	Roberta	Barnwell	1987	0	normal
863	Malvina	Baim	1996	0	jeune
864	Melisa	Barbee	1996	0	jeune
865	Marita	Baro	1991	0	normal
866	Hilma	Arlinghaus	1992	0	normal
867	Carolyn	Aurich	1970	0	normal
868	Vernon	Argandona	1997	0	jeune
869	Zenaida	Barsh	1994	0	jeune
870	Modesta	Balius	2000	0	jeune
871	Adelaide	Bangura	1992	0	normal
872	Lakendra	Barry	1973	0	normal
873	Floretta	Algeo	1961	0	normal
874	Magdalene	Beggs	1967	0	normal
875	Carlena	Androes	1986	0	normal
876	Towanda	Battershell	1980	0	normal
877	Alise	Ack	1983	0	normal
878	Cleotilde	Armitage	1979	0	normal
879	Noelle	Arenivar	1986	0	normal
880	Adriene	Amescua	1970	0	normal
881	Mariana	Becklund	1990	0	normal
882	Herminia	Arntzen	1980	0	normal
883	Marvis	Antigua	2000	0	jeune
884	Willena	Avirett	1980	0	normal
885	Dante	Baish	1991	0	normal
886	Latina	Arnhold	1990	0	normal
887	Jamel	Ambeau	1969	0	normal
888	Patrice	Ausley	1967	0	normal
889	Ollie	Bedore	1968	0	normal
890	Toni	Arment	1975	0	normal
891	Merle	Almengor	1961	0	normal
892	Twanna	Barrus	1993	0	jeune
893	Sherlene	Amas	1982	0	normal
894	Lindsey	Avellar	1988	0	normal
895	Martin	Barrientes	1978	0	normal
896	Monserrate	Apo	1996	0	jeune
897	Andres	Barut	1961	0	normal
898	Mechelle	Altmiller	1986	0	normal
899	Zena	Amano	1971	0	normal
900	Paris	Andringa	2002	0	jeune
901	Albert	Armlin	1986	0	normal
902	Jonna	Badal	1978	0	normal
903	Demetra	Arrospide	1985	0	normal
904	Claribel	Amailla	1996	0	jeune
905	Toccara	Bartrum	1997	0	jeune
906	Janell	Apthorpe	1993	0	jeune
907	Sunni	Alquesta	2001	0	jeune
908	Sari	Ayola	1964	0	normal
909	Evon	Achziger	1995	0	jeune
910	Tamala	Altieri	1969	0	normal
911	Gwyn	Alleman	1995	0	jeune
912	Lavenia	Amacher	1982	0	normal
913	Gilberto	Beel	1980	0	normal
914	Felicia	Bastick	1960	0	normal
915	Mattie	Adelgren	1970	0	normal
916	Essie	Bash	1998	0	jeune
917	Shaun	Apple	1962	0	normal
918	Michel	Aniello	1998	0	jeune
919	Teresia	Awyie	1975	0	normal
920	Staci	Antal	1980	0	normal
921	Marietta	Ashly	1963	0	normal
922	Esmeralda	Aldrow	1971	0	normal
923	Kaylene	Appell	1996	0	jeune
924	Olin	Ayer	1963	0	normal
925	Riva	Beightol	1977	0	normal
926	Cleotilde	Asbury	1968	0	normal
927	Leon	Arya	1980	0	normal
928	Whitney	Beadnell	1963	0	normal
929	Rochell	Abbasi	1984	0	normal
930	Orval	Almos	1984	0	normal
931	Yasuko	Alambar	1978	0	normal
932	Samatha	Bassham	1967	0	normal
933	Bruce	Arif	1972	0	normal
934	Simona	Becerra	1979	0	normal
935	Maegan	Abeln	1972	0	normal
936	Inga	Agbayani	1975	0	normal
937	Celesta	Bartels	1981	0	normal
938	Marlyn	Bartmess	1976	0	normal
939	Libbie	Behning	1969	0	normal
940	Samuel	Allder	1965	0	normal
941	Milo	Altreche	1997	0	jeune
942	Zelda	Balagtas	2001	0	jeune
943	Tommye	Banghart	1976	0	normal
944	Ronny	Aberson	1962	0	normal
945	Ludie	Beckner	1976	0	normal
946	Neal	Bawks	1981	0	normal
947	Tamisha	Barnhardt	1993	0	jeune
948	Kenny	Alspach	1996	0	jeune
949	Clyde	Austin	1973	0	normal
950	Caprice	Allon	1970	0	normal
951	Rudolph	Bayus	1964	0	normal
952	Rozella	Bedee	1963	0	normal
953	Lisabeth	Barch	1993	0	jeune
954	Neville	Armant	2000	0	jeune
955	Jake	Apa	1963	0	normal
956	Omar	Ahlers	1970	0	normal
957	Renaldo	Barrington	1968	0	normal
958	Creola	Arellano	1986	0	normal
959	Ailene	Applebaum	1997	0	jeune
960	Merry	Beasly	1969	0	normal
961	Leisha	Basini	1968	0	normal
962	Fatima	Basse	2000	0	jeune
963	Eric	Amsdell	1990	0	normal
964	Caterina	Bankson	2000	0	jeune
965	Adella	Bahner	1967	0	normal
966	Pierre	Antonaccio	1988	0	normal
967	Aiko	Akerson	1981	0	normal
968	Natisha	Andros	1986	0	normal
969	Abel	Anelli	1973	0	normal
970	Arletta	Bable	1968	0	normal
971	Shera	Adil	1991	0	normal
972	Frieda	Beacher	1992	0	normal
973	Azucena	Agre	1992	0	normal
974	Vikki	Ahumada	1993	0	jeune
975	Tamar	Aring	1983	0	normal
976	Mark	Ancheta	1961	0	normal
977	Silas	Alderfer	1975	0	normal
978	Mariella	Baskind	1988	0	normal
979	Christiana	Battiata	1960	0	normal
980	Janella	Beed	1963	0	normal
981	Ka	Arras	1975	0	normal
982	Rodrick	Antila	1966	0	normal
983	Emanuel	Armocida	1974	0	normal
984	An	Aydin	1974	0	normal
985	Randy	Amistoso	1963	0	normal
986	Aldo	Bandel	1970	0	normal
987	Garnet	Alverado	1985	0	normal
988	Karyl	Auler	1990	0	normal
989	Ayako	Anesi	1988	0	normal
990	Micheline	Beaureguard	1960	0	normal
991	Dorthy	Archambeault	1963	0	normal
992	Vito	Adney	1966	0	normal
993	Walker	Baack	1976	0	normal
994	Hyman	Arizola	1977	0	normal
995	Rene	Arena	1990	0	normal
996	Kelley	Abubakr	1985	0	normal
997	Kristen	Barck	2000	0	jeune
998	Zack	Ballmer	1972	0	normal
999	Chan	Amason	1994	0	jeune
1000	Sparkle	Barden	2002	0	jeune
1001	Otha	Be	1992	0	normal
1002	Nicolas	Beem	1981	0	normal
1003	Janey	Angilello	1995	0	jeune
1004	Ammie	Balwin	1984	0	normal
1005	Melisa	Angalich	1994	0	jeune
1006	Cory	Appelt	1995	0	jeune
1007	Amie	Bakkum	1995	0	jeune
1008	Natalie	Abed	1976	0	normal
1009	Fiona	Adil	1970	0	normal
1010	Deetta	Avirett	1994	0	jeune
1011	Carma	Arntson	1966	0	normal
1012	Lissette	Bagheri	1980	0	normal
1013	Kamilah	Albin	2000	0	jeune
1014	Georgianna	Alli	1980	0	normal
1015	Lore	Amejorado	1965	0	normal
1016	Demetria	Aday	1979	0	normal
1017	Zelda	Ahlberg	1974	0	normal
1018	Nigel	Antell	1975	0	normal
1019	Corrin	Bankowski	1987	0	normal
1020	Laronda	Agueda	1994	0	jeune
1021	Doyle	Aguire	1975	0	normal
1022	Arnoldo	Battisto	1981	0	normal
1023	Carolina	Albaladejo	1993	0	jeune
1024	Billy	Ascenzo	1984	0	normal
1025	Margrett	Allocca	1969	0	normal
1026	Takako	Bathe	1988	0	normal
1027	Carlota	Acerno	1996	0	jeune
1028	Steven	Alguire	1964	0	normal
1029	Melonie	Azzaro	1995	0	jeune
1030	Opal	Barthol	1978	0	normal
1031	Mack	Basgall	2001	0	jeune
1032	Peggy	Babione	2000	0	jeune
1033	Josh	Beaubrun	1979	0	normal
1034	Merrill	Beam	1961	0	normal
1035	Vernice	Amis	1994	0	jeune
1036	Christina	Beckim	1995	0	jeune
1037	Doloris	Bekerman	1990	0	normal
1038	Kelley	Barbagallo	1998	0	jeune
1039	Leighann	Baumgardner	1981	0	normal
1040	Donnetta	Achin	1980	0	normal
1041	Shirlene	Basone	1995	0	jeune
1042	Bradly	Abshire	1963	0	normal
1043	Eliza	Abitong	1978	0	normal
1044	Charmain	Amacher	1963	0	normal
1045	Kendall	Anders	1988	0	normal
1046	Merle	Ahlborn	1975	0	normal
1047	Edison	Alberico	1989	0	normal
1048	Laci	Babula	1989	0	normal
1049	Galen	Aubrey	1961	0	normal
1050	Cecil	Anglea	1982	0	normal
1051	Tawana	Auld	1963	0	normal
1052	Amal	Badgett	1981	0	normal
1053	Starla	Balliet	1985	0	normal
1054	Hermine	Arellanes	2001	0	jeune
1055	Juliana	Alpers	1981	0	normal
1056	Dayna	Adduci	1978	0	normal
1057	Erline	Balding	1968	0	normal
1058	Clarice	Albrashi	2002	0	jeune
1059	Sherilyn	Askam	1995	0	jeune
1060	Tommye	Adelmann	1965	0	normal
1061	Dung	Barribeau	1994	0	jeune
1062	Clayton	Arrocha	1976	0	normal
1063	Lance	Belgrade	1987	0	normal
1064	Allena	Agar	1970	0	normal
1065	Harley	Addicks	1998	0	jeune
1066	Noel	Affeltranger	1988	0	normal
1067	Casey	Avance	1999	0	jeune
1068	Lula	Behmer	1966	0	normal
1069	Constance	Baune	1976	0	normal
1070	Donald	Alsip	1976	0	normal
1071	Danna	Asal	1989	0	normal
1072	Beverlee	Antignani	1981	0	normal
1073	Suzie	Beldin	1982	0	normal
1074	Donella	Beehler	1966	0	normal
1075	Veta	Bedolla	1967	0	normal
1076	Kelley	Baldelli	1981	0	normal
1077	Nana	Bearden	1988	0	normal
1078	Cleta	Auch	1969	0	normal
1079	Niki	Anslinger	1996	0	jeune
1080	Arnulfo	Bagnaschi	1972	0	normal
1081	Christia	Anders	1980	0	normal
1082	Yoko	Ashurst	1994	0	jeune
1083	Lucio	Alawdi	2002	0	jeune
1084	Hilary	Bartron	1982	0	normal
1085	Dovie	Bartelt	1997	0	jeune
1086	Lynn	Averette	1996	0	jeune
1087	Christa	Balmaceda	1975	0	normal
1088	Sheron	Balduf	1994	0	jeune
1089	Karon	Aleshire	1985	0	normal
1090	Glory	Bair	1984	0	normal
1091	Mia	Atchley	1978	0	normal
1092	Arnoldo	Altavilla	1966	0	normal
1093	Sherwood	Bakula	1998	0	jeune
1094	Samuel	Abson	1963	0	normal
1095	Denny	Asnicar	1972	0	normal
1096	Abram	Andelman	1964	0	normal
1097	Lili	Arrequin	1995	0	jeune
1098	Brandee	Auler	1967	0	normal
1099	Jasmin	Amesquieto	1976	0	normal
1100	Jacinda	Antczak	1982	0	normal
1101	Hester	Aveado	1965	0	normal
1102	Eileen	Bartnick	1985	0	normal
1103	Ingeborg	Akiyama	1983	0	normal
1104	Zella	Arruda	1995	0	jeune
1105	Starr	Alfson	1966	0	normal
1106	Young	Basley	1971	0	normal
1107	Lilliana	Apuzzo	1962	0	normal
1108	Sena	Bainter	1983	0	normal
1109	Arica	Austerberry	1984	0	normal
1110	Brian	Astorga	1983	0	normal
1111	Yael	Abee	1984	0	normal
1112	Celestina	Bedlion	1960	0	normal
1113	Avery	Alo	1987	0	normal
1114	Luetta	Albertine	1966	0	normal
1115	Detra	Bartle	1998	0	jeune
1116	Alexis	Angela	1984	0	normal
1117	Kristi	Arden	1990	0	normal
1118	Elva	Avellar	1973	0	normal
1119	Morton	Avitia	2001	0	jeune
1120	Florencia	An	1967	0	normal
1121	Ivory	Bandura	1993	0	jeune
1122	Jackie	Baylock	1991	0	normal
1123	Richard	Arnsworth	1988	0	normal
1124	Raymon	Aberson	2002	0	jeune
1125	Etta	Andrle	1989	0	normal
1126	Amina	Abington	1975	0	normal
1127	Katheleen	Afalava	1978	0	normal
1128	Golda	Amailla	1995	0	jeune
1129	Lamonica	Bejger	1964	0	normal
1130	Jesusa	Artison	1991	0	normal
1131	Rosella	Aery	1985	0	normal
1132	Bobette	Achenbach	1980	0	normal
1133	Librada	Barsoum	1996	0	jeune
1134	Donnetta	Behn	1973	0	normal
1135	Hazel	Baczewski	1988	0	normal
1136	Clemente	Atwill	1977	0	normal
1137	Vincenza	Adachi	1969	0	normal
1138	Joan	Ahlgren	1976	0	normal
1139	Adrian	Alspach	1986	0	normal
1140	Kyoko	Antenor	1980	0	normal
1141	Leanora	Baden	1961	0	normal
1142	Renna	Armendariz	1987	0	normal
1143	Sergio	Bahri	1974	0	normal
1144	Tomi	Ballman	1989	0	normal
1145	Zackary	Acevedo	1983	0	normal
1146	Marquis	Alix	1991	0	normal
1147	Norman	Amey	1998	0	jeune
1148	Jesusa	Averitt	1985	0	normal
1149	Rashad	Balint	1990	0	normal
1150	Cherlyn	Asturias	1982	0	normal
1151	Charisse	Angilletta	1977	0	normal
1152	Lissa	Beckham	1973	0	normal
1153	Domingo	Artinger	1969	0	normal
1154	Anja	Anness	1976	0	normal
1155	Linn	Annarummo	1969	0	normal
1156	Giovanna	Banowetz	1990	0	normal
1157	Loretta	Abate	2000	0	jeune
1158	Cherry	Antunes	1992	0	normal
1159	Marcela	Aagaard	1992	0	normal
1160	Shemeka	Battisti	2001	0	jeune
1161	Angelo	Adell	1972	0	normal
1162	Lurline	Abeyta	1980	0	normal
1163	Judson	Ausbrooks	1980	0	normal
1164	Kayce	Acimovic	1987	0	normal
1165	Nancy	Arthurs	1963	0	normal
1166	Alfonso	Beeler	1968	0	normal
1167	Jimmie	Annable	1973	0	normal
1168	Arthur	Arlia	1997	0	jeune
1169	Candace	Almajhoub	1994	0	jeune
1170	Cythia	Arhelger	1991	0	normal
1171	Annalisa	Angelone	1983	0	normal
1172	Kayleigh	Asencio	1994	0	jeune
1173	Clelia	Aharonof	1966	0	normal
1174	Naomi	Althaus	2001	0	jeune
1175	Brad	Abrahamian	1992	0	normal
1176	Jackson	Behlen	1978	0	normal
1177	Gema	Bartula	1990	0	normal
1178	Josefine	Banick	2002	0	jeune
1179	Hipolito	Balsley	1983	0	normal
1180	Barney	Antich	1988	0	normal
1181	Lesha	Amoruso	1972	0	normal
1182	Carlyn	Bauguess	1980	0	normal
1183	Roberto	Baas	1984	0	normal
1184	Cornelius	Backman	1976	0	normal
1185	Nancie	Baranowski	1975	0	normal
1186	Keri	Balestra	1971	0	normal
1187	Cleo	Aromin	1993	0	jeune
1188	Yvette	Bartek	2000	0	jeune
1189	Elfriede	Barimah	1978	0	normal
1190	Tasha	Bamberger	1989	0	normal
1191	Ingeborg	Bealle	1978	0	normal
1192	Caitlin	Aramboles	1978	0	normal
1193	Santina	Baldo	1998	0	jeune
1194	Mariana	Bartoldus	1984	0	normal
1195	Dori	Ailshire	1966	0	normal
1196	Charisse	Ameigh	2000	0	jeune
1197	Peggy	Aguon	1960	0	normal
1198	Hang	Astor	1965	0	normal
1199	Cathryn	Amis	1973	0	normal
1200	Fritz	Ballenger	1976	0	normal
1201	Georgina	Aredondo	1995	0	jeune
1202	Ellsworth	Anerton	1999	0	jeune
1203	Carlene	Bartosiak	1981	0	normal
1204	Ehtel	Bast	1984	0	normal
1205	Ted	Alexzander	1992	0	normal
1206	Margene	Batie	1970	0	normal
1207	Garth	Anglemyer	1975	0	normal
1208	Chaya	Belanger	1998	0	jeune
1209	Eloisa	Augusto	1982	0	normal
1210	Shirely	Abdeldayen	1962	0	normal
1211	Mittie	Akal	1991	0	normal
1212	Lanita	Alls	1970	0	normal
1213	Leo	Alvord	1987	0	normal
1214	Gail	Ardner	1966	0	normal
1215	Danyell	Ballagas	1979	0	normal
1216	Mozelle	Aguiniga	1991	0	normal
1217	Tony	Archuleta	1970	0	normal
1218	Annette	Basner	1994	0	jeune
1219	Kirby	Banse	1962	0	normal
1220	Elton	Aken	1976	0	normal
1221	Ileen	Alvear	1979	0	normal
1222	Horacio	Apollo	1982	0	normal
1223	Lindsey	Alexandre	1960	0	normal
1224	Georgetta	Barick	1966	0	normal
1225	Mitchell	Abare	1989	0	normal
1226	Renaldo	Barker	1974	0	normal
1227	Carly	Allegretti	1984	0	normal
1228	Juliette	Baldus	2000	0	jeune
1229	Freeman	Barcenas	1968	0	normal
1230	Maryrose	Arns	1985	0	normal
1231	Juli	Bachman	1965	0	normal
1232	Christian	Ater	1981	0	normal
1233	Merilyn	Bali	1964	0	normal
1234	Kyra	Belardo	1985	0	normal
1235	Carla	Balassi	1962	0	normal
1236	Arthur	Archangel	2000	0	jeune
1237	Otilia	Bainey	1997	0	jeune
1238	Magdalene	Agoro	1960	0	normal
1239	Matthew	Balzarini	1979	0	normal
1240	Huey	Beliveau	1966	0	normal
1241	Bianca	Aldo	1993	0	jeune
1242	Linda	Acors	1964	0	normal
1243	Michel	Annonio	1965	0	normal
1244	Shery	Babula	1971	0	normal
1245	Gena	Alejos	1983	0	normal
1246	Jarrod	Barginear	1960	0	normal
1247	Tayna	Arambula	1982	0	normal
1248	Vannessa	Baginski	2001	0	jeune
1249	Stacy	Alberthal	1995	0	jeune
1250	Dannie	Basher	1981	0	normal
1251	Bryanna	Balbin	2001	0	jeune
1252	Victor	Almiron	1972	0	normal
1253	Nelson	Barstad	1998	0	jeune
1254	Harry	Altobell	1992	0	normal
1255	Jolynn	Allington	1967	0	normal
1256	Amee	Albin	1966	0	normal
1257	Fidel	Acocella	1973	0	normal
1258	Lashonda	Ave	2002	0	jeune
1259	Lavina	Adkerson	1963	0	normal
1260	Hermelinda	Balder	1964	0	normal
1261	Catherina	Arguello	1980	0	normal
1262	Verona	Antolos	1977	0	normal
1263	Dane	Barbetta	1974	0	normal
1264	Otilia	Anderholm	1977	0	normal
1265	Timmy	Bandley	1963	0	normal
1266	Bret	Allwood	1993	0	jeune
1267	Eldora	Arietta	1971	0	normal
1268	Marlin	Belasco	1999	0	jeune
1269	Kerstin	Beddia	1979	0	normal
1270	Sook	Balogh	1992	0	normal
1271	Yen	Bearse	1961	0	normal
1272	Katherin	Barr	1973	0	normal
1273	Khadijah	Abusufait	1998	0	jeune
1274	Daisy	Askins	1996	0	jeune
1275	Karyn	Alexzander	1982	0	normal
1276	Suk	Basch	1979	0	normal
1277	Lael	Alben	1978	0	normal
1278	Wanetta	Averett	1976	0	normal
1279	Jerrell	Barbati	1976	0	normal
1280	Barrie	Asmus	1963	0	normal
1281	Rochel	Alwan	1974	0	normal
1282	Augusta	Aldrich	1964	0	normal
1283	Jeane	Aguayo	2001	0	jeune
1284	Celena	Aslinger	1967	0	normal
1285	Kayleigh	Barrasa	1983	0	normal
1286	Berna	Arrey	1993	0	jeune
1287	Teodora	Arizaga	1964	0	normal
1288	Nell	Barg	1997	0	jeune
1289	Lea	Alawdi	1977	0	normal
1290	Roosevelt	Amonette	1964	0	normal
1291	Maegan	Bartucca	1976	0	normal
1292	Melida	Batdorf	1969	0	normal
1293	Stevie	Actis	1988	0	normal
1294	Bernarda	Art	1960	0	normal
1295	Blossom	Addie	1973	0	normal
1296	Wilburn	Babineaux	1960	0	normal
1297	Hilton	Antona	1980	0	normal
1298	Joella	Baille	1977	0	normal
1299	Emily	Adragna	1984	0	normal
1300	Annabelle	Arzola	1969	0	normal
1301	Shante	Beckler	1974	0	normal
1302	Percy	Bedgood	1992	0	normal
1303	Jocelyn	Aucoin	1967	0	normal
1304	Darlene	Beam	1994	0	jeune
1305	Greta	Balette	1960	0	normal
1306	Raeann	Afurong	1998	0	jeune
1307	Jeannie	Allums	1969	0	normal
1308	Phylis	Balich	1998	0	jeune
1309	Adena	Becher	1987	0	normal
1310	Cherish	Alsandor	1974	0	normal
1311	Carolann	Barnhill	1996	0	jeune
1312	Denisha	Avance	1982	0	normal
1313	Daniele	Beam	1981	0	normal
1314	Bennett	Agumga	1968	0	normal
1315	Zada	Askiew	1984	0	normal
1316	Tijuana	Baily	1963	0	normal
1317	Rocio	Allridge	1989	0	normal
1318	Isaac	Belieu	1965	0	normal
1319	Jonie	Amato	1994	0	jeune
1320	Marquetta	Baerga	1972	0	normal
1321	Hortencia	Alire	1965	0	normal
1322	Adell	Baughman	1966	0	normal
1323	Deane	Alcina	1999	0	jeune
1324	Tanna	Batters	1977	0	normal
1325	Carmen	Batley	1998	0	jeune
1326	Arnita	Atiles	1980	0	normal
1327	Elsy	Abts	1966	0	normal
1328	Leonarda	Arabia	1987	0	normal
1329	Elton	Akemon	1995	0	jeune
1330	Leeanna	Allum	1988	0	normal
1331	Maryland	Akhavan	1970	0	normal
1332	Elfriede	Armesto	1970	0	normal
1333	Alisha	Avarbuch	1980	0	normal
1334	Ilona	Archacki	1981	0	normal
1335	Bob	Amos	1999	0	jeune
1336	Catrice	Ardeneaux	1988	0	normal
1337	Alphonse	Bayn	1966	0	normal
1338	Natalie	Arzola	1974	0	normal
1339	Kellie	Bejger	1985	0	normal
1340	Kurt	Abbitt	1961	0	normal
1341	Jung	Bayala	1960	0	normal
1342	Kristine	Alkbsh	1985	0	normal
1343	Darcie	Arriano	1990	0	normal
1344	Bari	Avetisyan	1984	0	normal
1345	Darrell	Anene	1992	0	normal
1346	Soraya	Art	1990	0	normal
1347	Arlean	Adragna	1973	0	normal
1348	Daine	Baysmore	2001	0	jeune
1349	Celeste	Armijo	1982	0	normal
1350	Kim	Beadles	1987	0	normal
1351	Tomas	Bahm	1981	0	normal
1352	Kacie	Baloy	1984	0	normal
1353	Jae	Beauchaine	1991	0	normal
1354	Galen	Ballester	1976	0	normal
1355	Bobbie	Agard	1993	0	jeune
1356	Adelina	Banister	1963	0	normal
1357	Penelope	Amboree	1981	0	normal
1358	Kelle	Bartholomew	1997	0	jeune
1359	Kris	Ake	1980	0	normal
1360	Caron	Barios	1979	0	normal
1361	Bernadette	Beese	1965	0	normal
1362	Gina	Bandt	1961	0	normal
1363	Wendie	Beermudez	1996	0	jeune
1364	Modesto	Amerson	1971	0	normal
1365	Molly	Akright	1997	0	jeune
1366	Laverne	Akemon	1989	0	normal
1367	Theodore	Barocio	1992	0	normal
1368	Talisha	Apkin	1963	0	normal
1369	Demarcus	Amir	1994	0	jeune
1370	Lou	Ballenger	2001	0	jeune
1371	Cameron	Arvizu	1980	0	normal
1372	Tomi	Bastos	1964	0	normal
1373	Britt	Aceves	1970	0	normal
1374	Windy	Bayon	1990	0	normal
1375	Lai	Bachert	1998	0	jeune
1376	Allene	Athalone	1971	0	normal
1377	Beverley	Amous	1999	0	jeune
1378	Porsche	Apruzzese	1968	0	normal
1379	Yelena	Arey	1977	0	normal
1380	Bettina	Andzulis	1980	0	normal
1381	Maximina	Anyan	1980	0	normal
1382	Tuan	Bandley	1976	0	normal
1383	Zena	Balmores	1967	0	normal
1384	Alda	Beggs	1971	0	normal
1385	Alaina	Beelby	1971	0	normal
1386	Arlean	Beaulac	1990	0	normal
1387	Na	Ballester	1971	0	normal
1388	Hwa	Anawalt	1993	0	jeune
1389	Angelena	Angleberger	1964	0	normal
1390	Julieann	Ako	1999	0	jeune
1391	Lizabeth	Achille	1997	0	jeune
1392	Ramona	Aldi	1961	0	normal
1393	Nadia	Abby	1969	0	normal
1394	Melissa	Balog	1979	0	normal
1395	Les	Aggarwal	1967	0	normal
1396	Jose	Agoras	1981	0	normal
1397	Peter	Annichiarico	1975	0	normal
1398	Dannette	Alcide	1972	0	normal
1399	Ara	Arrequin	1962	0	normal
1400	Lannie	Abedelah	1962	0	normal
1401	Penelope	Ahn	1989	0	normal
1402	Dion	Barkalow	1976	0	normal
1403	Karen	Anawalt	1992	0	normal
1404	Clare	Aurora	2002	0	jeune
1405	Josette	Aites	1981	0	normal
1406	Zula	Altstatt	1976	0	normal
1407	Shonda	Bassage	1997	0	jeune
1408	Clora	Bassi	1982	0	normal
1409	Cythia	Arita	1966	0	normal
1410	Bruna	Arnau	1964	0	normal
1411	Daren	Abeta	1981	0	normal
1412	Keith	Anciso	1996	0	jeune
1413	Owen	Baeringer	1973	0	normal
1414	August	Andrew	1960	0	normal
1415	Joesph	Barney	1969	0	normal
1416	Shellie	Barias	1962	0	normal
1417	Violeta	Bandy	1962	0	normal
1418	Robbie	Beerling	1987	0	normal
1419	Annemarie	Baginski	2001	0	jeune
1420	Palmer	Afanador	1984	0	normal
1421	Odelia	Bahner	1984	0	normal
1422	Claude	Agrios	1962	0	normal
1423	Marlin	Bahlmann	1974	0	normal
1424	Merrilee	Barb	1968	0	normal
1425	Hortensia	Atta	2000	0	jeune
1426	Elisha	Ashpole	1982	0	normal
1427	Charlie	Beed	1989	0	normal
1428	Myriam	Battle	1988	0	normal
1429	Trinity	Ahmann	1980	0	normal
1430	Charline	Anneler	2002	0	jeune
1431	Jamey	Beene	1987	0	normal
1432	Perry	Argenbright	1980	0	normal
1433	Ernest	Ba	1970	0	normal
1434	Karl	Alesse	2002	0	jeune
1435	Brittni	Bawany	1998	0	jeune
1436	Virgil	Atmore	1991	0	normal
1437	May	Augusta	1998	0	jeune
1438	Stephania	Balandran	1978	0	normal
1439	Maribel	Badgero	1983	0	normal
1440	Amie	Arciga	1991	0	normal
1441	Erin	Aikman	1996	0	jeune
1442	Krysten	Baymon	2002	0	jeune
1443	Suzie	Alpheaus	1992	0	normal
1444	Diego	Bashaw	1965	0	normal
1445	Audrey	Altermatt	1976	0	normal
1446	Amelia	Beasly	1967	0	normal
1447	Devon	Barish	1987	0	normal
1448	Ardell	Amy	1971	0	normal
1449	Pamella	Altic	1971	0	normal
1450	Twana	Bartholomay	1997	0	jeune
1451	Josphine	Barrack	1988	0	normal
1452	Juliane	Altomari	1979	0	normal
1453	Karoline	Bagni	1977	0	normal
1454	Doris	Amar	1978	0	normal
1455	Max	Ansell	1994	0	jeune
1456	Darrel	Anolick	1982	0	normal
1457	Mickie	Aakre	2001	0	jeune
1458	Gretta	Atencio	1997	0	jeune
1459	Mervin	Bacco	1978	0	normal
1460	Lucilla	Alvez	1972	0	normal
1461	Michael	Adolphus	1969	0	normal
1462	Kristina	Attianese	1988	0	normal
1463	Jordon	Badgero	1996	0	jeune
1464	Gwenn	Abbas	1994	0	jeune
1465	Jewell	Armand	2000	0	jeune
1466	Josh	Ares	1963	0	normal
1467	Valrie	Baese	1971	0	normal
1468	Librada	Barillaro	1999	0	jeune
1469	Margo	Arkenberg	1988	0	normal
1470	Herman	Barrentine	1972	0	normal
1471	Chaya	Argall	1962	0	normal
1472	Wilbur	Baczewski	1982	0	normal
1473	Claretta	Beadell	1961	0	normal
1474	Octavia	Amanza	1972	0	normal
1475	Edwardo	Ahlbrecht	1993	0	jeune
1476	Elvira	Achenbach	1968	0	normal
1477	Eleonora	Alley	1988	0	normal
1478	Bernadette	Barager	1991	0	normal
1479	Elvin	Barlett	1970	0	normal
1480	Sherrill	Alim	1972	0	normal
1481	Hector	Barwell	1962	0	normal
1482	Carmon	Arnsworth	1991	0	normal
1483	Bud	Backous	1979	0	normal
1484	Mertie	Begin	1973	0	normal
1485	Elana	Ates	1984	0	normal
1486	Norris	Astle	1972	0	normal
1487	Ricardo	Allard	1961	0	normal
1488	Ali	Bassford	1962	0	normal
1489	Victorina	Alt	1961	0	normal
1490	Deidra	Bajko	2001	0	jeune
1491	Gearldine	Barnett	1960	0	normal
1492	Ignacio	Basore	1979	0	normal
1493	Lisha	Beardon	1966	0	normal
1494	Crissy	Adkison	1960	0	normal
1495	Delta	Baccari	1962	0	normal
1496	Floyd	Awyie	1980	0	normal
1497	Marielle	Baruffi	1996	0	jeune
1498	Josiah	Amy	1975	0	normal
1499	Sanda	Abson	1966	0	normal
1500	Alena	Amsbaugh	1993	0	jeune
1501	Nicolette	Baddour	1987	0	normal
1502	Felice	Barbero	2001	0	jeune
1503	Lashunda	Barayuga	1964	0	normal
1504	Jolanda	Allbritton	1970	0	normal
1505	Lina	Ayling	1984	0	normal
1506	Johana	Baumbusch	1982	0	normal
1507	Lakita	Barvick	1991	0	normal
1508	Myong	Artiles	1997	0	jeune
1509	Pinkie	Barkman	2000	0	jeune
1510	Ina	Averitte	1991	0	normal
1511	Carin	Abson	1962	0	normal
1512	Emily	Anable	1960	0	normal
1513	Staci	Bacchi	1960	0	normal
1514	Nelson	Aardema	2000	0	jeune
1515	Magali	Bacus	2001	0	jeune
1516	Rossana	Acocella	1963	0	normal
1517	Glennie	Bahun	1960	0	normal
1518	Raul	Arthurs	1967	0	normal
1519	Sharmaine	Anes	1998	0	jeune
1520	Kathleen	Barges	1989	0	normal
1521	Albert	Balistrieri	1981	0	normal
1522	Ila	Adebisi	1960	0	normal
1523	Noelia	Beaumonte	1995	0	jeune
1524	Byron	Adens	2001	0	jeune
1525	Cassondra	Anestos	1975	0	normal
1526	Corey	Bagoyo	1981	0	normal
1527	Raul	Bastidas	1989	0	normal
1528	Fritz	Belardo	1963	0	normal
1529	Hannah	Basley	1991	0	normal
1530	Evonne	Aspden	1991	0	normal
1531	Clyde	Arkell	1987	0	normal
1532	Jaime	Ailsworth	1991	0	normal
1533	Janina	Babiracki	1984	0	normal
1534	Lacresha	Beardall	1988	0	normal
1535	Tommie	Armson	1999	0	jeune
1536	Theresia	Abboud	1988	0	normal
1537	Kent	Abrecht	2001	0	jeune
1538	Shirl	Aardema	1966	0	normal
1539	Johnnie	Bassano	1983	0	normal
1540	Melany	Bankes	1993	0	jeune
1541	Gertha	Athy	1983	0	normal
1542	Darrin	Albornoz	1972	0	normal
1543	Danyell	Alcorn	2000	0	jeune
1544	Sandie	Baba	1986	0	normal
1545	Glynis	Baynes	1974	0	normal
1546	Emil	Africa	1977	0	normal
1547	Imogene	Badillo	1960	0	normal
1548	Tennille	Barraco	1969	0	normal
1549	Booker	Aponta	1960	0	normal
1550	Victorina	Abedelah	1966	0	normal
1551	Rozella	Ahrends	1973	0	normal
1552	Jeff	Arseneault	1990	0	normal
1553	Fernanda	Bartz	1968	0	normal
1554	Stephani	Behizadeh	1976	0	normal
1555	Brandee	Baldearena	2001	0	jeune
1556	Heide	Ask	1965	0	normal
1557	Eugene	Batra	1989	0	normal
1558	Vertie	Arruda	1977	0	normal
1559	Phylicia	Barth	1991	0	normal
1560	Raymond	Axelrad	1966	0	normal
1561	Ernesto	Achorn	1968	0	normal
1562	Georgiann	Barbish	1989	0	normal
1563	Julie	Amoah	1999	0	jeune
1564	Isa	Angelillo	1989	0	normal
1565	Hwa	Avon	1961	0	normal
1566	Suzi	Ansoategui	1962	0	normal
1567	Jenna	Beardon	1970	0	normal
1568	Jc	Barbagelata	1992	0	normal
1569	Sharda	Arbogust	1973	0	normal
1570	Ariel	Barbo	1963	0	normal
1571	Marline	Babbish	1964	0	normal
1572	Yolonda	Barn	1992	0	normal
1573	Belkis	Beirne	1962	0	normal
1574	Lavera	Arline	1986	0	normal
1575	Bronwyn	Ballam	1989	0	normal
1576	Bobby	Altidor	1995	0	jeune
1577	Karey	Aschmann	1979	0	normal
1578	Gladis	Acencio	1977	0	normal
1579	Winifred	Aeschlimann	1969	0	normal
1580	Kyoko	Aguayo	1998	0	jeune
1581	Enriqueta	Aperges	1970	0	normal
1582	Fausto	Bartlebaugh	1985	0	normal
1583	Divina	Basley	1991	0	normal
1584	Allyn	Baell	1983	0	normal
1585	Elenora	Balich	1981	0	normal
1586	Tomika	Basse	1980	0	normal
1587	Shannan	Amoss	1992	0	normal
1588	Shaunte	Balzarine	1978	0	normal
1589	Violette	Antu	1982	0	normal
1590	Marilou	Bartolomucci	1999	0	jeune
1591	Hisako	Aken	1966	0	normal
1592	Eleanore	Aguillon	1990	0	normal
1593	Lorina	Balck	1995	0	jeune
1594	Teisha	Annonio	1997	0	jeune
1595	Maud	Bachhuber	1968	0	normal
1596	Mercedez	Aubuchon	1971	0	normal
1597	Lashawna	Antonopoulos	1996	0	jeune
1598	Loraine	Baun	1962	0	normal
1599	Kaitlyn	Ardrey	1984	0	normal
1600	Delores	Ashenfelter	1986	0	normal
1601	Fern	Akhavan	1995	0	jeune
1602	Cristin	Bagby	1991	0	normal
1603	Irmgard	Aho	1977	0	normal
1604	Alethea	Bakalar	1972	0	normal
1605	Millicent	Amburgy	1987	0	normal
1606	Deneen	Auiles	1979	0	normal
1607	Jennefer	Belina	1977	0	normal
1608	Jamel	Barges	1967	0	normal
1609	Sally	Barrus	1996	0	jeune
1610	Taneka	Belgarde	1962	0	normal
1611	Edwin	Alicia	1986	0	normal
1612	Carman	Beekman	1997	0	jeune
1613	Joey	Audain	1985	0	normal
1614	Azucena	Acor	1996	0	jeune
1615	Shawanna	Baysmore	1982	0	normal
1616	Veta	Adolf	1990	0	normal
1617	Carlie	Armijo	1969	0	normal
1618	Sudie	Balford	1982	0	normal
1619	Ardell	Anecelle	2000	0	jeune
1620	Piedad	Baldonado	1998	0	jeune
1621	Joey	Allton	1972	0	normal
1622	Cindi	Bassford	1986	0	normal
1623	Klara	Bedonie	2002	0	jeune
1624	Nery	Arneson	1984	0	normal
1625	Devorah	Behun	1975	0	normal
1626	Jaymie	Alge	1961	0	normal
1627	Ezra	Aikins	1996	0	jeune
1628	Nan	Arrospide	1992	0	normal
1629	Juliana	Arelleano	1976	0	normal
1630	Kristyn	Bahadue	1987	0	normal
1631	Mohamed	Arking	1996	0	jeune
1632	Osvaldo	Alltop	1965	0	normal
1633	Russell	Auna	1980	0	normal
1634	Jennell	Baunleuang	1963	0	normal
1635	Emmy	Adell	1985	0	normal
1636	Renda	Barschdoor	1979	0	normal
1637	Gigi	Altomonte	1994	0	jeune
1638	Ilene	Bartholomay	1976	0	normal
1639	Johnnie	Angland	2001	0	jeune
1640	Kory	Arrigo	1994	0	jeune
1641	Lisbeth	Basich	1999	0	jeune
1642	Delinda	Agre	2001	0	jeune
1643	Macy	Adkin	1972	0	normal
1644	Domingo	Aggas	1997	0	jeune
1645	Lili	Amick	1962	0	normal
1646	Agnes	Alfiero	1969	0	normal
1647	Arletha	Auck	1986	0	normal
1648	Sharika	Allaman	1978	0	normal
1649	Stanford	Amano	1999	0	jeune
1650	Lahoma	Ausiello	1965	0	normal
1651	Evalyn	Back	1987	0	normal
1652	Austin	Barke	1992	0	normal
1653	Alverta	Arbour	1965	0	normal
1654	Jeanelle	Bareford	1984	0	normal
1655	Delorse	Ahrens	1990	0	normal
1656	Pei	Beaudrie	1976	0	normal
1657	Lise	Akawanzie	2000	0	jeune
1658	Allen	Amici	1994	0	jeune
1659	Alice	Bahr	1989	0	normal
1660	Jude	Ahlf	1977	0	normal
1661	Carlene	Banh	1994	0	jeune
1662	Thresa	Almestica	1992	0	normal
1663	German	Aid	1970	0	normal
1664	Madlyn	Adonis	1995	0	jeune
1665	Velda	Beitzel	1986	0	normal
1666	Shana	Ariza	1969	0	normal
1667	Esperanza	Balsiger	1964	0	normal
1668	Nina	Barcellos	1976	0	normal
1669	Brooks	Aytes	1960	0	normal
1670	Javier	Apt	1961	0	normal
1671	Marcene	Argenbright	1972	0	normal
1672	Burl	Batliner	1998	0	jeune
1673	Verdie	Airola	1978	0	normal
1674	Marlin	Autry	2002	0	jeune
1675	Roderick	Barientos	1990	0	normal
1676	Doretha	Beeker	1964	0	normal
1677	Randa	Annino	1968	0	normal
1678	Leanna	Bardon	1960	0	normal
1679	Kandace	Allhands	1965	0	normal
1680	Tamisha	Audibert	1987	0	normal
1681	Tuyet	Abdur	1966	0	normal
1682	Loreen	Angelica	1978	0	normal
1683	Joycelyn	Altomari	1985	0	normal
1684	Rosanne	Agel	1977	0	normal
1685	Elouise	Aldrige	1989	0	normal
1686	Coy	Arismendez	1995	0	jeune
1687	Jenell	Alexader	1983	0	normal
1688	Oscar	Alexander	1968	0	normal
1689	Roxanna	Aniol	1995	0	jeune
1690	Millie	Baka	1982	0	normal
1691	Dominica	Belgarde	1983	0	normal
1692	Ivory	Baim	1972	0	normal
1693	Kari	Bartelson	1972	0	normal
1694	Breann	Arriaza	1984	0	normal
1695	Frida	Bankey	1967	0	normal
1696	Dorcas	Barrett	1968	0	normal
1697	China	Aylock	1981	0	normal
1698	Sima	Bakes	1995	0	jeune
1699	Noah	Andaya	1983	0	normal
1700	Lakiesha	Baldiviez	1970	0	normal
1701	Lauran	Ardon	2000	0	jeune
1702	Franklyn	Bauerle	1965	0	normal
1703	Sharron	Alcantara	2000	0	jeune
1704	Lawrence	Arakawa	1988	0	normal
1705	Candace	Ao	1977	0	normal
1706	Essie	Baransky	1986	0	normal
1707	Xiomara	Alviso	1989	0	normal
1708	Lori	Becvar	1994	0	jeune
1709	Leonia	Allbright	1993	0	jeune
1710	Jule	Areizaga	1991	0	normal
1711	Lucia	Arico	1977	0	normal
1712	Rod	Aasen	1993	0	jeune
1713	Mandie	Aris	1966	0	normal
1714	Matthew	Backey	1970	0	normal
1715	Rosemarie	Barett	1972	0	normal
1716	Shona	Arrospide	1961	0	normal
1717	Karon	Astrup	1970	0	normal
1718	Christal	Alder	1987	0	normal
1719	Tuyet	Alfiero	1966	0	normal
1720	Elma	Baskow	1975	0	normal
1721	Lisha	Arcaute	1990	0	normal
1722	Adam	Bautch	1997	0	jeune
1723	Kerry	Ameling	1984	0	normal
1724	Jannie	Angeloni	1990	0	normal
1725	Mitch	Balder	1989	0	normal
1726	Kathleen	Battin	1968	0	normal
1727	Luigi	Almarza	1977	0	normal
1728	Everett	Barke	1981	0	normal
1729	Shemika	Bartos	1960	0	normal
1730	Rolanda	Battino	1980	0	normal
1731	Lillie	Arambuia	1985	0	normal
1732	Lekisha	Belfield	1998	0	jeune
1733	Beatriz	Baumbach	1973	0	normal
1734	Kasey	Balmos	1997	0	jeune
1735	Jackson	Baldree	1966	0	normal
1736	Gerald	Allbritton	2000	0	jeune
1737	Randa	Agyeman	1993	0	jeune
1738	Bettye	Akim	1998	0	jeune
1739	Joleen	Alvelo	1998	0	jeune
1740	Robby	Beerman	1983	0	normal
1741	Sharda	Bar	1992	0	normal
1742	Hildegard	Barillo	1984	0	normal
1743	Francoise	Alverio	1998	0	jeune
1744	Rosendo	Almstead	1960	0	normal
1745	Keven	Aeschliman	1961	0	normal
1746	Gena	Beisner	1977	0	normal
1747	Chance	Balwin	1967	0	normal
1748	Camilla	Abbassi	1985	0	normal
1749	Trevor	Arreaga	1975	0	normal
1750	Rebeca	Beckenbach	1970	0	normal
1751	Mitch	Amaro	1962	0	normal
1752	Danae	Barthe	1964	0	normal
1753	Raelene	Bachan	1977	0	normal
1754	Joeann	Bares	1963	0	normal
1755	Belva	Bahri	1966	0	normal
1756	Alix	Batten	2000	0	jeune
1757	Danae	Baltazor	1991	0	normal
1758	Nannette	Arango	1991	0	normal
1759	Clair	Baranga	1967	0	normal
1760	Nikole	Ahn	1979	0	normal
1761	Cuc	Appenzeller	1989	0	normal
1762	Veronique	Anawaty	1998	0	jeune
1763	Robena	Baile	1963	0	normal
1764	Katheleen	Bedgood	1967	0	normal
1765	Lindy	Aller	1961	0	normal
1766	Tad	Applin	1983	0	normal
1767	Reba	Barios	1995	0	jeune
1768	Sidney	Adon	1975	0	normal
1769	Demetrius	Aldred	1963	0	normal
1770	Lilla	Aperges	1991	0	normal
1771	Jene	Alce	1973	0	normal
1772	Berenice	Alcorn	2000	0	jeune
1773	Maryanna	Banzhaf	1982	0	normal
1774	Roger	Balentine	1960	0	normal
1775	Matt	Albertson	1970	0	normal
1776	Darby	Audelhuk	2000	0	jeune
1777	Mellie	Bailard	1976	0	normal
1778	Noah	Amas	1973	0	normal
1779	Dannie	Agarwal	1992	0	normal
1780	Alfredia	Ackles	1998	0	jeune
1781	Esmeralda	Beckum	1965	0	normal
1782	Albina	Beales	1986	0	normal
1783	Hildegard	Affeltranger	1964	0	normal
1784	Velvet	Abrahamian	1968	0	normal
1785	Dahlia	Aguon	1996	0	jeune
1786	Dirk	Barrieau	1994	0	jeune
1787	Van	Ascenzo	1996	0	jeune
1788	Loraine	Bastedo	1996	0	jeune
1789	Fleta	Avey	1970	0	normal
1790	Spencer	Ahyou	2000	0	jeune
1791	Marybelle	Apel	1988	0	normal
1792	Merlin	Bame	1975	0	normal
1793	Will	Baynes	1964	0	normal
1794	Ocie	Alameida	1963	0	normal
1795	Winona	Argandona	1989	0	normal
1796	Jc	Andregg	1986	0	normal
1797	Margert	Bazzell	1967	0	normal
1798	Renay	Avitabile	1963	0	normal
1799	Dorian	Aumavae	1993	0	jeune
1800	Sol	Aurges	1983	0	normal
1801	Don	Aarestad	1974	0	normal
1802	Zulma	Ainscough	1972	0	normal
1803	Laverne	Bartolo	1973	0	normal
1804	Ladawn	Abalos	1971	0	normal
1805	Lavon	Asato	1969	0	normal
1806	Susan	Angst	1962	0	normal
1807	Eve	Barahona	1971	0	normal
1808	Tabetha	Andert	1966	0	normal
1809	Lorenzo	Alvanas	1994	0	jeune
1810	Cristie	Alderete	2002	0	jeune
1811	Aubrey	Alme	1983	0	normal
1812	Freida	Balza	1981	0	normal
1813	Ressie	Athearn	1982	0	normal
1814	Deloras	Annicchiarico	2001	0	jeune
1815	Claudio	Abdulla	1995	0	jeune
1816	Mike	Alessandroni	1973	0	normal
1817	Marylin	Araque	1969	0	normal
1818	Monte	Beckem	1977	0	normal
1819	Doyle	Abasta	1973	0	normal
1820	Nerissa	Balzarine	1986	0	normal
1821	Rachell	Althaus	1999	0	jeune
1822	Cris	Amrein	1992	0	normal
1823	Emmanuel	Bambeck	1980	0	normal
1824	Carmel	Aaby	1976	0	normal
1825	Alisa	Amaya	1974	0	normal
1826	Ewa	Beebe	2001	0	jeune
1827	Sherwood	Abshear	1985	0	normal
1828	Faviola	Acocella	1964	0	normal
1829	Alvina	Alfreds	1982	0	normal
1830	Reena	Abood	1984	0	normal
1831	Claretta	Arledge	1977	0	normal
1832	Carole	Aley	1965	0	normal
1833	Cheri	Beandoin	2002	0	jeune
1834	Elinor	Adamitis	1966	0	normal
1835	Jae	Agreda	1969	0	normal
1836	Roxanna	Bainard	1976	0	normal
1837	Pearle	Almonte	2001	0	jeune
1838	Aura	Astillero	1962	0	normal
1839	Jay	Baillio	1997	0	jeune
1840	Danica	Ashmen	1988	0	normal
1841	Caroyln	Baute	2000	0	jeune
1842	Krysta	Agostino	1960	0	normal
1843	Sammy	Baitner	1966	0	normal
1844	Leola	Beebout	1997	0	jeune
1845	Jeffrey	Bayerl	1988	0	normal
1846	Mitch	Baquiran	1985	0	normal
1847	Sharice	Akinrefon	1971	0	normal
1848	Leticia	Barber	1962	0	normal
1849	Nerissa	Artega	1991	0	normal
1850	Chasidy	Batzli	2002	0	jeune
1851	Chu	Alpern	1977	0	normal
1852	Priscilla	Balley	1966	0	normal
1853	Loida	Bari	1970	0	normal
1854	Lady	Behringer	1985	0	normal
1855	Lanell	Bankemper	1962	0	normal
1856	Dortha	Barnhardt	1995	0	jeune
1857	Ollie	Ardon	1998	0	jeune
1858	Jaqueline	Ackerly	1984	0	normal
1859	Eugene	Bachorski	1964	0	normal
1860	Morgan	Accardi	2000	0	jeune
1861	Versie	Badolato	1962	0	normal
1862	Elnora	Aly	1970	0	normal
1863	Bob	Armento	1996	0	jeune
1864	Vernie	Baumeister	1961	0	normal
1865	Towanda	Aguilar	1984	0	normal
1866	Charity	Badami	1971	0	normal
1867	Wanda	Baars	1975	0	normal
1868	Peggie	Aslett	1974	0	normal
1869	Ahmad	Barlett	1988	0	normal
1870	Abraham	Addesso	1971	0	normal
1871	Elina	Apperson	1983	0	normal
1872	Antonio	Bauerle	1974	0	normal
1873	Cliff	Belcourt	2000	0	jeune
1874	Dee	Agricola	1964	0	normal
1875	Galina	Angelone	1963	0	normal
1876	Florinda	Aldinger	1997	0	jeune
1877	Elaina	Aase	1984	0	normal
1878	Doretha	Aredondo	1964	0	normal
1879	Dana	Affleck	1962	0	normal
1880	Silas	Beggs	1983	0	normal
1881	Staci	Alcorta	1984	0	normal
1882	Louie	Baierl	1972	0	normal
1883	Amy	Aslett	1974	0	normal
1884	Ileen	Anstine	1979	0	normal
1885	Deirdre	Annino	1988	0	normal
1886	Hildegarde	Arnitz	1986	0	normal
1887	Carley	Asaeli	1968	0	normal
1888	Kathe	Baumgardner	1968	0	normal
1889	Chung	Bavelas	1989	0	normal
1890	Mark	Arciola	1973	0	normal
1891	Chantelle	Barbur	1981	0	normal
1892	Alix	Balladares	1974	0	normal
1893	Janey	Alling	1993	0	jeune
1894	Kenya	Alger	1996	0	jeune
1895	Maureen	Bartnik	1972	0	normal
1896	Robin	Aubert	1995	0	jeune
1897	Kristal	Aykroid	1968	0	normal
1898	Gabrielle	Beckler	1970	0	normal
1899	Stacey	Alier	1960	0	normal
1900	Drew	Akuchie	1964	0	normal
1901	Candace	Abato	1999	0	jeune
1902	Karyl	Alman	1967	0	normal
1903	Wilbert	Apadoca	1989	0	normal
1904	Elwood	Armout	1990	0	normal
1905	Catharine	Alexnder	1968	0	normal
1906	Eve	Albarado	1980	0	normal
1907	Cordie	Baty	1983	0	normal
1908	Lucille	Amos	1969	0	normal
1909	Josh	Beier	1977	0	normal
1910	Sondra	Apostol	1998	0	jeune
1911	Madeleine	Bangura	1973	0	normal
1912	Evangelina	Amante	1992	0	normal
1913	Natacha	Bartram	1996	0	jeune
1914	Lavette	Beljan	1996	0	jeune
1915	Agueda	Arbon	1965	0	normal
1916	Hoa	Abramovitz	1978	0	normal
1917	Rodrick	Ablin	1981	0	normal
1918	Shaniqua	Bedford	1978	0	normal
1919	Nevada	Acoff	1966	0	normal
1920	Indira	Bail	1989	0	normal
1921	Fidelia	Belardo	1985	0	normal
1922	Melvina	Armengol	1979	0	normal
1923	Joline	Bartlome	1962	0	normal
1924	Aleta	Barrington	1982	0	normal
1925	Georgina	Angeline	1977	0	normal
1926	Seymour	Autobee	1981	0	normal
1927	Devorah	Bausley	1990	0	normal
1928	Rema	Bad	1974	0	normal
1929	Adela	Aduddell	1996	0	jeune
1930	Monica	Attebery	2000	0	jeune
1931	Londa	Arunachalam	1987	0	normal
1932	Angila	Arizzi	1977	0	normal
1933	Elizabet	Appleman	1989	0	normal
1934	Alda	Almanzar	1986	0	normal
1935	Deirdre	Baruth	2000	0	jeune
1936	Doreen	Anderholm	1976	0	normal
1937	Floyd	Abdool	1989	0	normal
1938	Donald	Askegren	2001	0	jeune
1939	Nicholle	Ahonen	1998	0	jeune
1940	Ruben	Arbogust	1975	0	normal
1941	Griselda	Basilone	1961	0	normal
1942	Anya	Astafan	1960	0	normal
1943	Alexis	Arroyd	1971	0	normal
1944	Yolande	Apresa	1992	0	normal
1945	Beata	Averitt	1974	0	normal
1946	Rubie	Barrete	1970	0	normal
1947	Cherry	Begen	1971	0	normal
1948	Gricelda	Behrns	1969	0	normal
1949	Lynwood	Barentine	1990	0	normal
1950	Ruben	Ali	1969	0	normal
1951	Youlanda	Aragoni	1960	0	normal
1952	Doloris	Augenstein	1975	0	normal
1953	Renea	Ariano	1983	0	normal
1954	Herta	Anhalt	1961	0	normal
1955	Maryjo	Barscewski	1960	0	normal
1956	Mertie	Andrulis	1961	0	normal
1957	Violet	Apuzzo	1995	0	jeune
1958	Latesha	Allam	1973	0	normal
1959	Galina	Ammar	1966	0	normal
1960	Emerita	Aken	1997	0	jeune
1961	Dalene	Ayoub	1974	0	normal
1962	Lakiesha	Aguiler	1978	0	normal
1963	Kum	Alven	1982	0	normal
1964	Stewart	Abbington	1963	0	normal
1965	Tula	Armand	1986	0	normal
1966	Sherise	Baudler	1976	0	normal
1967	Brandon	Beker	2001	0	jeune
1968	Marlon	Abdulkarim	1999	0	jeune
1969	Dean	Bazzle	1980	0	normal
1970	Elvia	Armesto	1961	0	normal
1971	Eustolia	Banes	1975	0	normal
1972	Rima	Bealmear	1972	0	normal
1973	Melvin	Bearden	1969	0	normal
1974	Dionna	Aleksey	1963	0	normal
1975	Bari	Baba	1974	0	normal
1976	Shelly	Alvis	1967	0	normal
1977	Izetta	Baj	1968	0	normal
1978	Lynetta	Angelucci	1978	0	normal
1979	Norma	Austin	1996	0	jeune
1980	Stanford	Annibale	1994	0	jeune
1981	Sharee	Allensworth	1982	0	normal
1982	Jewel	Araujo	1962	0	normal
1983	Hugh	Andera	1991	0	normal
1984	Gaynell	Ankrum	1983	0	normal
1985	Nolan	Barcomb	1977	0	normal
1986	Lyman	Aller	1999	0	jeune
1987	Brianne	Adank	1990	0	normal
1988	Ligia	Abdou	1977	0	normal
1989	Patience	Angilletta	1992	0	normal
1990	Brent	Adamson	1976	0	normal
1991	Sharri	Artiga	1993	0	jeune
1992	Kary	Arrisola	1971	0	normal
1993	Suanne	Abalos	1974	0	normal
1994	Temika	Allateef	2002	0	jeune
1995	Alysa	Banta	1983	0	normal
1996	Kathlene	Beattle	1963	0	normal
1997	Loria	Angeloni	1987	0	normal
1998	Yuki	Aneshansley	1986	0	normal
1999	Sydney	Abrahams	1976	0	normal
2000	Lezlie	Alicea	1984	0	normal
2001	Faridah	Akinotcho	1999	0	jeune
2002	Clara	Savy	1998	0	jeune
1	Concepcion	Bayon	1999	15	jeune
2003	Inès	Dardouri	1998	0	jeune
2004	Théo	Michot	1998	15	jeune
0	Pierre	Gimalac	1999	0	jeune
\.


--
-- Name: users_id_user_seq; Type: SEQUENCE SET; Schema: public; Owner: fredo
--

SELECT pg_catalog.setval('users_id_user_seq', 2005, true);


--
-- Data for Name: velo_casse; Type: TABLE DATA; Schema: public; Owner: fredo
--

COPY velo_casse (id, id_centres, elec) FROM stdin;
5046	3	f
941	57	t
3771	39	f
4343	21	f
5181	82	f
587	98	t
583	37	t
1331	55	t
6436	87	f
5366	22	f
667	37	t
6319	86	f
1594	43	t
1792	85	t
6267	24	f
332	84	t
3503	48	f
1087	9	t
5751	14	f
3487	3	f
2645	23	f
4406	59	f
1887	26	t
3991	70	f
4939	57	f
3891	72	f
2687	73	f
5729	99	f
2020	78	f
3068	73	f
2913	33	f
5463	16	f
4539	71	f
2991	28	f
3024	75	f
4229	44	f
152	45	t
6263	49	f
5674	84	f
440	77	t
5958	53	f
6113	11	f
41	69	t
365	89	t
2361	88	f
5179	83	f
2803	8	f
3388	63	f
1552	58	t
4818	50	f
1732	100	t
3118	56	f
5588	80	f
3584	65	f
3619	9	f
1161	100	t
504	8	t
2506	30	f
3972	14	f
356	72	t
4054	25	f
5960	97	f
2325	64	f
3724	83	f
2417	29	f
510	33	t
4355	70	f
973	83	t
5088	36	f
5143	22	f
6244	45	f
5813	39	f
2343	77	f
832	14	t
1078	35	t
6397	76	f
595	45	t
2598	82	f
4845	78	f
2690	1	f
1799	88	t
5307	20	f
35	60	t
1885	89	t
1845	6	t
2694	52	f
1444	93	t
3781	61	f
4929	59	f
6265	97	f
6651	6	f
2320	61	f
4232	85	f
849	95	t
4884	22	f
2025	1	f
5356	40	f
3517	24	f
6188	72	f
4680	22	f
4441	72	f
2853	84	f
6070	69	f
6508	36	f
3928	40	f
4813	71	f
1603	81	t
106	58	t
4617	59	f
3309	27	f
5257	99	f
1787	3	t
2762	71	f
3366	64	f
5010	19	f
4512	73	f
4688	100	f
5514	2	f
3931	85	f
2541	18	f
752	100	t
414	66	t
2354	28	f
3143	89	f
1751	42	t
2496	32	f
4388	46	f
3996	34	f
776	13	t
2270	74	f
653	53	t
1397	38	t
3338	70	f
5466	61	f
4245	30	f
1536	14	t
3614	81	f
1534	90	t
5024	33	f
5835	55	f
3765	18	f
3409	99	f
361	95	t
1233	27	t
6530	8	f
5592	33	f
3193	11	f
4855	79	f
1191	97	t
3739	57	f
5317	75	f
2768	55	f
3332	56	f
2702	50	f
5545	26	f
2572	72	f
6214	75	f
4334	84	f
2528	32	f
6212	80	f
1908	79	t
4178	55	f
5812	57	f
5500	35	f
1473	82	t
2345	75	f
2218	1	f
2758	27	f
2614	77	f
5480	80	f
6478	54	f
3571	24	f
4262	15	f
1921	52	t
2276	72	f
1361	24	t
6501	15	f
248	12	t
4973	83	f
2401	95	f
1141	45	t
2729	82	f
5172	93	f
5160	8	f
1619	89	t
1002	89	t
4506	89	f
516	30	t
2406	45	f
4604	58	f
6192	56	f
656	63	t
3998	67	f
1306	69	t
5484	55	f
2073	36	f
4475	13	f
2183	57	f
5790	18	f
6187	46	f
1135	79	t
1854	27	t
4771	75	f
6280	10	f
2719	92	f
2976	64	f
5693	72	f
5168	25	f
3974	76	f
3045	69	f
2296	96	f
1342	97	t
6658	30	f
783	38	t
946	2	t
827	98	t
5954	47	f
5881	83	f
3914	32	f
6106	17	f
3387	73	f
5375	96	f
3626	49	f
5062	31	f
6299	45	f
2636	23	f
4736	26	f
5432	68	f
993	94	t
4501	90	f
4030	37	f
3587	28	f
3008	91	f
1873	92	t
3994	32	f
5973	62	f
3913	17	f
5469	28	f
4887	63	f
3227	99	f
1156	82	t
1425	1	t
489	91	t
2770	18	f
5638	93	f
4731	64	f
1773	65	t
5626	84	f
3476	81	f
6375	95	f
3369	65	f
873	32	t
3518	8	f
1905	37	t
1848	45	t
4638	6	f
948	94	t
4071	53	f
4393	97	f
6112	52	f
2413	7	f
2575	90	f
3715	76	f
3056	88	f
2272	26	f
4748	89	f
6638	54	f
4564	1	f
5879	14	f
4003	20	f
681	84	t
3817	34	f
2291	86	f
4227	15	f
863	20	t
4545	36	f
940	85	t
1252	63	t
6324	62	f
5544	18	f
4496	6	f
592	36	t
1595	40	t
4091	26	f
671	79	t
1150	60	t
3038	82	f
3102	36	f
967	2	t
3396	49	f
4598	23	f
449	83	t
2647	19	f
1389	92	t
5041	75	f
3440	74	f
1468	88	t
1211	19	t
97	34	t
4529	50	f
4889	99	f
830	9	t
5975	6	f
1783	8	t
5756	21	f
3862	59	f
4900	62	f
6135	38	f
4065	2	f
6566	23	f
3243	14	f
4437	18	f
2328	9	f
4724	39	f
3129	37	f
4377	88	f
1415	63	t
190	62	t
3926	80	f
5869	91	f
354	62	t
5549	81	f
5073	70	f
5595	12	f
2638	60	f
3018	19	f
1079	83	t
2278	21	f
5427	87	f
6120	47	f
4405	68	f
3357	65	f
4615	91	f
5397	12	f
6392	82	f
6359	62	f
2267	64	f
1869	93	t
3044	25	f
6381	27	f
6612	100	f
1676	72	t
2606	59	f
2033	79	f
5923	45	f
68	28	t
939	36	t
3968	67	f
6432	62	f
3048	83	f
6518	66	f
1328	53	t
5832	7	f
5494	92	f
1939	44	t
5234	50	f
5487	40	f
4443	32	f
2780	63	f
6457	77	f
109	14	t
1073	45	t
5880	15	f
1824	33	t
4802	40	f
5475	54	f
5745	78	f
1634	82	t
1895	11	t
2084	100	f
2334	45	f
3840	12	f
6428	54	f
3853	64	f
6128	8	f
5119	54	f
607	54	t
4079	69	f
6509	66	f
6018	96	f
3581	39	f
3714	99	f
3516	8	f
302	81	t
3984	91	f
3922	54	f
1642	19	t
5311	1	f
3812	66	f
4578	72	f
5094	96	f
1080	21	t
4110	30	f
659	76	t
3417	95	f
3799	53	f
4082	15	f
1668	35	t
1758	90	t
6238	64	f
2970	85	f
6369	68	f
3221	2	f
908	11	t
5917	22	f
930	15	t
4624	63	f
6663	42	f
1066	85	t
769	27	t
24	79	t
2939	62	f
2120	79	f
5567	46	f
2796	72	f
1040	84	t
1700	100	t
5383	71	f
3965	90	f
2789	84	f
3176	97	f
3352	33	f
4031	89	f
685	49	t
6219	39	f
3407	14	f
5131	73	f
4200	84	f
4041	21	f
6061	20	f
2644	92	f
1664	11	t
4125	77	f
3446	4	f
1573	20	t
682	88	t
4480	29	f
2388	88	f
5938	52	f
2067	64	f
1442	10	t
5027	37	f
3718	65	f
1372	45	t
5974	84	f
2064	16	f
5822	20	f
5779	80	f
5575	27	f
2987	82	f
1817	24	t
6066	62	f
2384	82	f
5291	66	f
4029	37	f
5008	7	f
4653	51	f
4295	86	f
5714	55	f
2368	64	f
3474	35	f
2437	74	f
6648	72	f
5905	75	f
5098	54	f
270	8	t
542	63	t
4953	73	f
6157	37	f
4863	38	f
5584	7	f
3178	20	f
1013	33	t
3758	48	f
3058	23	f
4455	78	f
244	5	t
3647	44	f
1627	92	t
503	70	t
4382	51	f
2607	14	f
5613	57	f
6004	52	f
4697	66	f
3225	72	f
4497	82	f
5401	63	f
4741	40	f
4866	13	f
262	6	t
1626	75	t
3157	51	f
5417	74	f
38	86	t
3464	6	f
694	6	t
4685	67	f
2480	90	f
1166	75	t
6431	51	f
569	75	t
2269	75	f
1721	72	t
3306	99	f
723	95	t
3349	52	f
4586	68	f
3988	91	f
1270	70	t
1210	71	t
2114	27	f
4442	55	f
3927	40	f
2431	85	f
2004	3	f
4786	58	f
380	35	t
1660	95	t
5851	67	f
3120	23	f
200	55	t
6114	6	f
66	67	t
2920	32	f
482	85	t
2139	7	f
6503	99	f
3509	26	f
4446	60	f
4993	68	f
1572	33	t
413	81	t
826	30	t
6177	43	f
664	21	t
615	55	t
1564	56	t
4878	9	f
1948	87	t
5591	62	f
1008	15	t
4325	2	f
238	6	t
3034	63	f
6121	24	f
6115	30	f
96	5	t
6668	37	f
2167	92	f
5139	41	f
4985	43	f
3558	66	f
4257	48	f
2540	28	f
1655	47	t
2934	63	f
6423	43	f
2279	99	f
5710	19	f
1840	69	t
4515	5	f
5447	29	f
6255	57	f
6446	80	f
1020	93	t
5284	100	f
4872	74	f
2599	75	f
2858	39	f
368	73	t
6262	69	f
3907	38	f
1802	54	t
353	23	t
108	8	t
1978	84	t
3462	34	f
5337	96	f
5635	86	f
2524	43	f
1922	43	t
3428	7	f
696	83	t
3500	58	f
1376	58	t
2193	37	f
2481	12	f
2790	45	f
490	98	t
2141	51	f
1373	34	t
3436	25	f
1788	1	t
3686	72	f
2570	40	f
3903	29	f
4228	64	f
2973	73	f
5467	47	f
6220	86	f
5857	95	f
1180	15	t
1493	42	t
4634	31	f
3828	92	f
1246	23	t
5815	43	f
1795	43	t
4153	37	f
3470	48	f
5028	35	f
5461	24	f
4519	12	f
2424	39	f
6520	74	f
6481	70	f
4875	39	f
5209	100	f
214	60	t
1441	71	t
5770	94	f
2103	34	f
3886	70	f
1523	94	t
6268	25	f
5523	7	f
558	32	t
3762	16	f
750	69	t
4935	87	f
1849	35	t
2608	66	f
5922	61	f
3465	9	f
5402	12	f
4132	12	f
4421	4	f
790	10	t
1479	96	t
1864	82	t
2240	65	f
2439	71	f
381	73	t
1806	66	t
1651	1	t
2047	59	f
4022	32	f
5876	73	f
3318	54	f
1516	56	t
4327	47	f
706	54	t
2952	6	f
539	8	t
1429	74	t
2363	33	f
2373	94	f
1302	33	t
6443	13	f
4311	1	f
267	80	t
2249	13	f
2149	27	f
5614	94	f
780	60	t
405	70	t
4068	60	f
5465	97	f
2285	74	f
1653	94	t
3798	8	f
3182	33	f
603	17	t
6472	15	f
2356	17	f
4827	35	f
1930	43	t
1606	2	t
1964	71	t
6046	57	f
6337	5	f
1224	45	t
191	93	t
3859	71	f
5972	45	f
2212	11	f
5579	87	f
6398	31	f
6670	20	f
5722	18	f
602	87	t
5968	85	f
3552	57	f
6281	21	f
807	73	t
566	42	t
4510	89	f
149	85	t
3025	52	f
4243	20	f
1085	27	t
5877	67	f
3512	91	f
5702	30	f
4581	31	f
5218	85	f
3505	80	f
187	60	t
6414	51	f
1496	17	t
6257	93	f
2192	72	f
364	90	t
2664	38	f
3222	20	f
2449	49	f
660	46	t
4537	97	f
5149	50	f
4796	18	f
2785	82	f
2634	58	f
2007	42	f
5171	14	f
324	28	t
2016	35	f
5260	51	f
5665	35	f
6309	56	f
1108	29	t
2335	6	f
3386	60	f
6326	15	f
2217	44	f
6415	20	f
3283	71	f
4487	94	f
3740	85	f
5121	100	f
2672	89	f
1689	45	t
3435	34	f
695	68	t
2734	93	f
2460	84	f
4189	38	f
5331	5	f
1856	49	t
5235	57	f
402	9	t
5570	2	f
5952	25	f
1518	69	t
2747	29	f
2712	11	f
1599	35	t
841	38	t
2397	76	f
5328	13	f
4308	79	f
6041	84	f
2053	64	f
6125	97	f
4456	47	f
1823	21	t
4758	51	f
3597	50	f
1508	28	t
3174	41	f
2435	71	f
2327	66	f
2550	42	f
6137	2	f
4984	100	f
2206	61	f
142	2	t
1970	36	t
639	27	t
4817	59	f
5724	100	f
4150	58	f
2261	20	f
4165	81	f
4145	83	f
3232	47	f
4078	25	f
3134	73	f
40	9	t
4042	6	f
4373	55	f
385	71	t
1742	54	t
6506	72	f
5594	99	f
2454	64	f
2229	46	f
6547	35	f
2546	63	f
1352	99	t
259	51	t
3504	53	f
3671	14	f
5	71	t
5875	34	f
1707	83	t
2704	19	f
658	72	t
5934	60	f
3055	16	f
3743	55	f
2763	12	f
970	40	t
5376	48	f
\.


--
-- Data for Name: velo_dispo; Type: TABLE DATA; Schema: public; Owner: fredo
--

COPY velo_dispo (id, id_station, elec) FROM stdin;
2	1	t
3	1	t
4	1	t
6	1	t
7	1	t
8	1	t
10	1	t
11	1	t
12	1	t
14	1	t
16	1	t
17	1	t
18	1	t
19	1	t
20	1	t
21	2	t
22	2	t
23	2	t
25	2	t
26	2	t
27	2	t
28	2	t
29	2	t
30	2	t
31	2	t
32	2	t
33	2	t
34	2	t
37	3	t
39	3	t
43	3	t
44	3	t
45	3	t
46	3	t
47	3	t
48	3	t
49	3	t
50	3	t
51	4	t
53	4	t
55	4	t
57	4	t
59	4	t
61	4	t
62	4	t
63	4	t
64	4	t
65	4	t
67	4	t
69	4	t
70	4	t
71	5	t
72	5	t
73	5	t
74	5	t
75	5	t
76	5	t
78	5	t
79	5	t
80	5	t
82	5	t
84	5	t
85	5	t
86	6	t
87	6	t
89	6	t
90	6	t
91	6	t
92	6	t
93	6	t
99	6	t
100	6	t
101	7	t
102	7	t
103	7	t
105	7	t
107	7	t
110	7	t
111	7	t
115	7	t
117	7	t
118	7	t
119	7	t
120	7	t
121	8	t
124	8	t
127	8	t
129	8	t
131	8	t
133	8	t
134	8	t
135	8	t
137	9	t
138	9	t
139	9	t
140	9	t
143	9	t
144	9	t
145	9	t
147	9	t
148	9	t
150	9	t
151	10	t
153	10	t
154	10	t
156	10	t
158	10	t
159	10	t
160	10	t
161	10	t
162	10	t
165	10	t
166	10	t
168	10	t
169	10	t
170	10	t
171	11	t
172	11	t
173	11	t
174	11	t
176	11	t
177	11	t
179	11	t
180	11	t
181	11	t
183	11	t
185	11	t
186	12	t
189	12	t
192	12	t
193	12	t
194	12	t
195	12	t
197	12	t
198	12	t
199	12	t
201	13	t
202	13	t
203	13	t
204	13	t
205	13	t
206	13	t
207	13	t
208	13	t
209	13	t
210	13	t
211	13	t
212	13	t
216	13	t
217	13	t
218	13	t
219	13	t
221	14	t
222	14	t
223	14	t
224	14	t
225	14	t
226	14	t
227	14	t
228	14	t
229	14	t
231	14	t
232	14	t
233	14	t
234	14	t
235	14	t
236	15	t
239	15	t
240	15	t
241	15	t
245	15	t
246	15	t
249	15	t
251	16	t
252	16	t
253	16	t
254	16	t
255	16	t
258	16	t
261	16	t
263	16	t
265	16	t
266	16	t
269	16	t
271	17	t
272	17	t
273	17	t
275	17	t
276	17	t
277	17	t
278	17	t
279	17	t
281	17	t
282	17	t
283	17	t
284	17	t
285	17	t
286	18	t
287	18	t
288	18	t
289	18	t
290	18	t
291	18	t
294	18	t
296	18	t
297	18	t
298	18	t
299	18	t
301	19	t
303	19	t
304	19	t
305	19	t
306	19	t
307	19	t
308	19	t
309	19	t
311	19	t
313	19	t
316	19	t
317	19	t
318	19	t
320	19	t
322	20	t
323	20	t
325	20	t
326	20	t
327	20	t
330	20	t
331	20	t
333	20	t
334	20	t
335	20	t
337	21	t
338	21	t
340	21	t
342	21	t
343	21	t
345	21	t
346	21	t
349	21	t
351	22	t
355	22	t
357	22	t
358	22	t
359	22	t
360	22	t
362	22	t
363	22	t
366	22	t
367	22	t
369	22	t
370	22	t
371	23	t
372	23	t
373	23	t
374	23	t
375	23	t
376	23	t
377	23	t
378	23	t
382	23	t
383	23	t
384	23	t
386	24	t
387	24	t
388	24	t
389	24	t
390	24	t
391	24	t
392	24	t
393	24	t
394	24	t
395	24	t
398	24	t
399	24	t
400	24	t
401	25	t
403	25	t
409	25	t
410	25	t
411	25	t
412	25	t
415	25	t
416	25	t
417	25	t
418	25	t
419	25	t
420	25	t
421	26	t
422	26	t
424	26	t
425	26	t
426	26	t
427	26	t
429	26	t
430	26	t
434	26	t
435	26	t
436	27	t
437	27	t
438	27	t
441	27	t
442	27	t
444	27	t
446	27	t
447	27	t
450	27	t
451	28	t
452	28	t
453	28	t
455	28	t
456	28	t
457	28	t
458	28	t
460	28	t
461	28	t
462	28	t
463	28	t
464	28	t
466	28	t
467	28	t
470	28	t
471	29	t
472	29	t
473	29	t
474	29	t
475	29	t
477	29	t
478	29	t
480	29	t
481	29	t
483	29	t
484	29	t
485	29	t
486	30	t
487	30	t
491	30	t
492	30	t
493	30	t
494	30	t
495	30	t
496	30	t
497	30	t
498	30	t
499	30	t
500	30	t
501	31	t
502	31	t
505	31	t
506	31	t
507	31	t
508	31	t
509	31	t
511	31	t
513	31	t
514	31	t
515	31	t
517	31	t
520	31	t
522	32	t
523	32	t
524	32	t
525	32	t
526	32	t
527	32	t
528	32	t
529	32	t
530	32	t
532	32	t
533	32	t
534	32	t
535	32	t
537	33	t
543	33	t
544	33	t
546	33	t
547	33	t
548	33	t
549	33	t
550	33	t
551	34	t
552	34	t
554	34	t
555	34	t
556	34	t
559	34	t
560	34	t
561	34	t
564	34	t
567	34	t
568	34	t
570	34	t
571	35	t
572	35	t
574	35	t
575	35	t
576	35	t
577	35	t
580	35	t
581	35	t
582	35	t
584	35	t
585	35	t
586	36	t
589	36	t
590	36	t
591	36	t
593	36	t
594	36	t
596	36	t
597	36	t
598	36	t
599	36	t
601	37	t
604	37	t
605	37	t
606	37	t
609	37	t
610	37	t
611	37	t
612	37	t
614	37	t
616	37	t
617	37	t
619	37	t
620	37	t
621	38	t
623	38	t
624	38	t
625	38	t
626	38	t
627	38	t
628	38	t
629	38	t
630	38	t
631	38	t
632	38	t
633	38	t
634	38	t
635	38	t
636	39	t
637	39	t
640	39	t
641	39	t
642	39	t
643	39	t
644	39	t
646	39	t
647	39	t
648	39	t
650	39	t
651	40	t
652	40	t
654	40	t
655	40	t
657	40	t
661	40	t
662	40	t
663	40	t
665	40	t
666	40	t
673	41	t
674	41	t
675	41	t
677	41	t
678	41	t
679	41	t
683	41	t
686	42	t
688	42	t
689	42	t
690	42	t
691	42	t
693	42	t
697	42	t
698	42	t
699	42	t
701	43	t
702	43	t
703	43	t
705	43	t
709	43	t
711	43	t
712	43	t
713	43	t
715	43	t
716	43	t
719	43	t
720	43	t
721	44	t
722	44	t
725	44	t
726	44	t
727	44	t
728	44	t
732	44	t
733	44	t
734	44	t
736	45	t
737	45	t
738	45	t
739	45	t
741	45	t
742	45	t
743	45	t
744	45	t
745	45	t
746	45	t
747	45	t
748	45	t
753	46	t
756	46	t
757	46	t
759	46	t
760	46	t
761	46	t
762	46	t
763	46	t
764	46	t
765	46	t
766	46	t
770	46	t
771	47	t
772	47	t
773	47	t
774	47	t
775	47	t
777	47	t
779	47	t
784	47	t
785	47	t
786	48	t
787	48	t
789	48	t
791	48	t
793	48	t
794	48	t
795	48	t
796	48	t
797	48	t
798	48	t
799	48	t
800	48	t
802	49	t
804	49	t
808	49	t
809	49	t
813	49	t
814	49	t
817	49	t
818	49	t
819	49	t
821	50	t
822	50	t
823	50	t
824	50	t
825	50	t
829	50	t
831	50	t
833	50	t
834	50	t
835	50	t
836	51	t
837	51	t
838	51	t
839	51	t
840	51	t
842	51	t
843	51	t
844	51	t
845	51	t
846	51	t
848	51	t
850	51	t
851	52	t
853	52	t
854	52	t
855	52	t
857	52	t
858	52	t
859	52	t
860	52	t
862	52	t
864	52	t
865	52	t
866	52	t
867	52	t
868	52	t
870	52	t
872	53	t
875	53	t
878	53	t
879	53	t
880	53	t
883	53	t
884	53	t
885	53	t
886	54	t
887	54	t
888	54	t
889	54	t
891	54	t
892	54	t
893	54	t
894	54	t
895	54	t
896	54	t
897	54	t
898	54	t
900	54	t
901	55	t
902	55	t
903	55	t
904	55	t
906	55	t
909	55	t
910	55	t
911	55	t
912	55	t
916	55	t
917	55	t
918	55	t
920	55	t
921	56	t
922	56	t
923	56	t
924	56	t
925	56	t
926	56	t
927	56	t
928	56	t
929	56	t
931	56	t
933	56	t
936	57	t
937	57	t
938	57	t
942	57	t
943	57	t
945	57	t
947	57	t
949	57	t
950	57	t
952	58	t
953	58	t
954	58	t
955	58	t
956	58	t
958	58	t
959	58	t
960	58	t
961	58	t
962	58	t
963	58	t
966	58	t
968	58	t
969	58	t
971	59	t
972	59	t
974	59	t
975	59	t
977	59	t
978	59	t
979	59	t
981	59	t
982	59	t
983	59	t
984	59	t
985	59	t
986	60	t
988	60	t
989	60	t
990	60	t
991	60	t
992	60	t
994	60	t
995	60	t
996	60	t
998	60	t
1001	61	t
1003	61	t
1004	61	t
1005	61	t
1006	61	t
1007	61	t
1009	61	t
1010	61	t
1011	61	t
1012	61	t
1014	61	t
1015	61	t
1016	61	t
1017	61	t
1018	61	t
1019	61	t
1022	62	t
1023	62	t
1024	62	t
1026	62	t
1029	62	t
1030	62	t
1031	62	t
1032	62	t
1035	62	t
1036	63	t
1037	63	t
1038	63	t
1039	63	t
1041	63	t
1042	63	t
1043	63	t
1044	63	t
1045	63	t
1046	63	t
1047	63	t
1048	63	t
1049	63	t
1050	63	t
1051	64	t
1052	64	t
1053	64	t
1054	64	t
1055	64	t
1056	64	t
1057	64	t
1058	64	t
1059	64	t
1060	64	t
1061	64	t
1063	64	t
1064	64	t
1065	64	t
1067	64	t
1068	64	t
1069	64	t
1070	64	t
1071	65	t
1072	65	t
1074	65	t
1075	65	t
1076	65	t
1081	65	t
1082	65	t
1083	65	t
1086	66	t
1088	66	t
1089	66	t
1090	66	t
1091	66	t
1092	66	t
1094	66	t
1097	66	t
1098	66	t
1099	66	t
1100	66	t
1102	67	t
1103	67	t
1104	67	t
1105	67	t
1106	67	t
1107	67	t
1109	67	t
1110	67	t
1111	67	t
1112	67	t
1113	67	t
1114	67	t
1116	67	t
1117	67	t
1118	67	t
1119	67	t
1121	68	t
1122	68	t
1123	68	t
1124	68	t
1125	68	t
1126	68	t
1127	68	t
1128	68	t
1129	68	t
1130	68	t
1131	68	t
1132	68	t
1133	68	t
1134	68	t
1136	69	t
1137	69	t
1138	69	t
1140	69	t
1143	69	t
1144	69	t
1146	69	t
1147	69	t
1148	69	t
1149	69	t
1151	70	t
1152	70	t
1153	70	t
1154	70	t
1155	70	t
1157	70	t
1158	70	t
1159	70	t
1160	70	t
1163	70	t
1164	70	t
1165	70	t
1167	70	t
1169	70	t
1172	71	t
1173	71	t
1174	71	t
1175	71	t
1178	71	t
1181	71	t
1182	71	t
1184	71	t
1185	71	t
1186	72	t
1187	72	t
1188	72	t
1189	72	t
1190	72	t
1193	72	t
1194	72	t
1195	72	t
1196	72	t
1197	72	t
1200	72	t
1202	73	t
1203	73	t
1205	73	t
1206	73	t
1207	73	t
1208	73	t
1209	73	t
1212	73	t
1213	73	t
1214	73	t
1215	73	t
1216	73	t
1217	73	t
1218	73	t
1219	73	t
1220	73	t
1221	74	t
1222	74	t
1223	74	t
1225	74	t
1226	74	t
1227	74	t
1228	74	t
1230	74	t
1231	74	t
1234	74	t
1235	74	t
1237	75	t
1239	75	t
1240	75	t
1241	75	t
1242	75	t
1243	75	t
1245	75	t
1249	75	t
1250	75	t
1251	76	t
1253	76	t
1254	76	t
1256	76	t
1257	76	t
1259	76	t
1260	76	t
1261	76	t
1263	76	t
1264	76	t
1266	76	t
1267	76	t
1268	76	t
1269	76	t
1271	77	t
1272	77	t
1274	77	t
1276	77	t
1278	77	t
1280	77	t
1281	77	t
1282	77	t
1283	77	t
1284	77	t
1285	77	t
1287	78	t
1288	78	t
1289	78	t
1291	78	t
1292	78	t
1293	78	t
1295	78	t
1296	78	t
1297	78	t
1299	78	t
1300	78	t
1304	79	t
1307	79	t
1309	79	t
1310	79	t
1311	79	t
1314	79	t
1315	79	t
1316	79	t
1317	79	t
1318	79	t
1319	79	t
1320	79	t
1321	80	t
1322	80	t
1323	80	t
1324	80	t
1325	80	t
1326	80	t
1327	80	t
1329	80	t
1330	80	t
1332	80	t
1333	80	t
1334	80	t
1336	81	t
1337	81	t
1339	81	t
1340	81	t
1341	81	t
1343	81	t
1344	81	t
1345	81	t
1347	81	t
1348	81	t
1349	81	t
1353	82	t
1354	82	t
1355	82	t
1357	82	t
1359	82	t
1360	82	t
1362	82	t
1363	82	t
1365	82	t
1367	82	t
1368	82	t
1369	82	t
1371	83	t
1375	83	t
1378	83	t
1381	83	t
1382	83	t
1383	83	t
1384	83	t
1386	84	t
1387	84	t
1388	84	t
1391	84	t
1393	84	t
1394	84	t
1395	84	t
1396	84	t
1398	84	t
1399	84	t
1400	84	t
1402	85	t
1404	85	t
1405	85	t
1406	85	t
1408	85	t
1410	85	t
1412	85	t
1413	85	t
1414	85	t
1416	85	t
1419	85	t
1421	86	t
1422	86	t
1423	86	t
1424	86	t
1430	86	t
1431	86	t
1432	86	t
1434	86	t
1435	86	t
1436	87	t
1437	87	t
1438	87	t
1439	87	t
1440	87	t
1443	87	t
1446	87	t
1448	87	t
1450	87	t
1451	88	t
1452	88	t
1454	88	t
1456	88	t
1457	88	t
1459	88	t
1460	88	t
1461	88	t
1463	88	t
1464	88	t
1465	88	t
1466	88	t
1467	88	t
1469	88	t
1470	88	t
1471	89	t
1474	89	t
1475	89	t
1476	89	t
1478	89	t
1482	89	t
1483	89	t
1484	89	t
1486	90	t
1488	90	t
1489	90	t
1490	90	t
1491	90	t
1492	90	t
1494	90	t
1495	90	t
1497	90	t
1498	90	t
1499	90	t
1500	90	t
1501	91	t
1502	91	t
1503	91	t
1504	91	t
1506	91	t
1507	91	t
1511	91	t
1513	91	t
1514	91	t
1515	91	t
1517	91	t
1519	91	t
1521	92	t
1524	92	t
1526	92	t
1527	92	t
1528	92	t
1529	92	t
1530	92	t
1531	92	t
1532	92	t
1533	92	t
1535	92	t
1537	93	t
1538	93	t
1539	93	t
1540	93	t
1542	93	t
1543	93	t
1544	93	t
1545	93	t
1547	93	t
1548	93	t
1549	93	t
1553	94	t
1554	94	t
1555	94	t
1556	94	t
1557	94	t
1558	94	t
1559	94	t
1561	94	t
1562	94	t
1563	94	t
1565	94	t
1568	94	t
1569	94	t
1570	94	t
1571	95	t
1576	95	t
1578	95	t
1579	95	t
1580	95	t
1581	95	t
1582	95	t
1583	95	t
1585	95	t
1586	96	t
1587	96	t
1588	96	t
1589	96	t
1590	96	t
1591	96	t
1593	96	t
1597	96	t
1598	96	t
1600	96	t
1601	97	t
1602	97	t
1604	97	t
1605	97	t
1608	97	t
1609	97	t
1610	97	t
1612	97	t
1613	97	t
1614	97	t
1616	97	t
1618	97	t
1620	97	t
1621	98	t
1622	98	t
1623	98	t
1624	98	t
1625	98	t
1628	98	t
1630	98	t
1632	98	t
1633	98	t
1635	98	t
1636	99	t
1637	99	t
1638	99	t
1639	99	t
1643	99	t
1644	99	t
1645	99	t
1646	99	t
1647	99	t
1648	99	t
1649	99	t
1650	99	t
1652	100	t
1654	100	t
1657	100	t
1658	100	t
1659	100	t
1661	100	t
1662	100	t
1663	100	t
1665	100	t
1666	100	t
1667	100	t
1669	100	t
1671	101	t
1672	101	t
1673	101	t
1674	101	t
1675	101	t
1678	101	t
1679	101	t
1680	101	t
1681	101	t
1682	101	t
1683	101	t
1684	101	t
1685	101	t
1686	102	t
1687	102	t
1688	102	t
1690	102	t
1691	102	t
1692	102	t
1693	102	t
1694	102	t
1695	102	t
1696	102	t
1697	102	t
1698	102	t
1699	102	t
1701	103	t
1702	103	t
1703	103	t
1704	103	t
1705	103	t
1706	103	t
1708	103	t
1710	103	t
1711	103	t
1712	103	t
1714	103	t
1715	103	t
1716	103	t
1717	103	t
1718	103	t
1719	103	t
1720	103	t
1722	104	t
1723	104	t
1725	104	t
1726	104	t
1728	104	t
1729	104	t
1730	104	t
1731	104	t
1734	104	t
1735	104	t
1739	105	t
1741	105	t
1743	105	t
1744	105	t
1745	105	t
1746	105	t
1747	105	t
1748	105	t
1749	105	t
1750	105	t
1753	106	t
1755	106	t
1756	106	t
1757	106	t
1759	106	t
1760	106	t
1762	106	t
1763	106	t
1764	106	t
1765	106	t
1766	106	t
1767	106	t
1768	106	t
1769	106	t
1770	106	t
1771	107	t
1772	107	t
1774	107	t
1775	107	t
1776	107	t
1777	107	t
1778	107	t
1779	107	t
1780	107	t
1781	107	t
1782	107	t
1784	107	t
1785	107	t
1789	108	t
1790	108	t
1791	108	t
1793	108	t
1794	108	t
1796	108	t
1797	108	t
1798	108	t
1800	108	t
1801	109	t
1803	109	t
1805	109	t
1807	109	t
1810	109	t
1812	109	t
1813	109	t
1814	109	t
1815	109	t
1816	109	t
1818	109	t
1819	109	t
1820	109	t
1821	110	t
1822	110	t
1825	110	t
1826	110	t
1827	110	t
1828	110	t
1829	110	t
1830	110	t
1831	110	t
1832	110	t
1833	110	t
1834	110	t
1836	111	t
1837	111	t
1838	111	t
1839	111	t
1841	111	t
1842	111	t
1843	111	t
1846	111	t
1847	111	t
1850	111	t
1851	112	t
1853	112	t
1855	112	t
1857	112	t
1859	112	t
1860	112	t
1861	112	t
1862	112	t
1863	112	t
1865	112	t
1866	112	t
1867	112	t
1868	112	t
1870	112	t
1871	113	t
1872	113	t
1874	113	t
1875	113	t
1876	113	t
1879	113	t
1880	113	t
1882	113	t
1883	113	t
1884	113	t
1888	114	t
1889	114	t
1890	114	t
1891	114	t
1892	114	t
1893	114	t
1894	114	t
1896	114	t
1898	114	t
1900	114	t
1901	115	t
1902	115	t
1903	115	t
1906	115	t
1907	115	t
1909	115	t
1910	115	t
1913	115	t
1914	115	t
1915	115	t
1916	115	t
1917	115	t
1919	115	t
1920	115	t
1923	116	t
1924	116	t
1925	116	t
1927	116	t
1928	116	t
1929	116	t
1931	116	t
1932	116	t
1933	116	t
1934	116	t
1935	116	t
1936	117	t
1937	117	t
1938	117	t
1940	117	t
1941	117	t
1942	117	t
1943	117	t
1944	117	t
1945	117	t
1946	117	t
1949	117	t
1950	117	t
1951	118	t
1952	118	t
1954	118	t
1955	118	t
1956	118	t
1957	118	t
1958	118	t
1959	118	t
1960	118	t
1962	118	t
1963	118	t
1965	118	t
1967	118	t
1969	118	t
1972	119	t
1973	119	t
1974	119	t
1975	119	t
1976	119	t
1977	119	t
1980	119	t
1981	119	t
1983	119	t
1984	119	t
1985	119	t
1987	120	t
1988	120	t
1989	120	t
1991	120	t
1992	120	t
1993	120	t
1994	120	t
1995	120	t
1996	120	t
1997	120	t
1998	120	t
2000	120	t
2001	121	t
2002	121	f
2003	121	f
2005	121	f
2006	121	f
2008	121	f
2009	121	f
2010	121	f
2015	121	f
2017	121	f
2018	121	f
2021	122	f
2022	122	f
2024	122	f
2026	122	f
2027	122	f
2028	122	f
2030	122	f
2031	122	f
2032	122	f
2034	122	f
2035	122	f
2037	123	f
2038	123	f
2039	123	f
2040	123	f
2041	123	f
2042	123	f
2043	123	f
2044	123	f
2046	123	f
2048	123	f
2049	123	f
2051	124	f
2054	124	f
2055	124	f
2056	124	f
2058	124	f
2059	124	f
2061	124	f
2062	124	f
2063	124	f
2065	124	f
2069	124	f
2070	124	f
2071	125	f
2074	125	f
2075	125	f
2076	125	f
2077	125	f
2078	125	f
2079	125	f
2080	125	f
2081	125	f
2083	125	f
2085	125	f
2086	126	f
2087	126	f
2089	126	f
2090	126	f
2091	126	f
2092	126	f
2093	126	f
2094	126	f
2095	126	f
2096	126	f
2097	126	f
2098	126	f
2099	126	f
2100	126	f
2101	127	f
2104	127	f
2105	127	f
2107	127	f
2108	127	f
2109	127	f
2110	127	f
2111	127	f
2112	127	f
2113	127	f
2117	127	f
2118	127	f
2119	127	f
2122	128	f
2123	128	f
2124	128	f
2125	128	f
2127	128	f
2128	128	f
2129	128	f
2130	128	f
2131	128	f
2132	128	f
2133	128	f
2136	129	f
2137	129	f
2138	129	f
2140	129	f
2142	129	f
2143	129	f
2145	129	f
2146	129	f
2147	129	f
2148	129	f
2151	130	f
2152	130	f
2153	130	f
2154	130	f
2155	130	f
2156	130	f
2157	130	f
2158	130	f
2159	130	f
2160	130	f
2164	130	f
2168	130	f
2169	130	f
2170	130	f
2171	131	f
2172	131	f
2175	131	f
2176	131	f
2177	131	f
2178	131	f
2180	131	f
2181	131	f
2182	131	f
2185	131	f
2186	132	f
2188	132	f
2190	132	f
2194	132	f
2195	132	f
2196	132	f
2197	132	f
2198	132	f
2199	132	f
2200	132	f
2201	133	f
2202	133	f
2203	133	f
2204	133	f
2205	133	f
2207	133	f
2209	133	f
2210	133	f
2211	133	f
2213	133	f
2215	133	f
2216	133	f
2219	133	f
2220	133	f
2222	134	f
2223	134	f
2224	134	f
2225	134	f
2226	134	f
2230	134	f
2231	134	f
2232	134	f
2233	134	f
2236	135	f
2237	135	f
2239	135	f
2241	135	f
2242	135	f
2243	135	f
2244	135	f
2245	135	f
2246	135	f
2247	135	f
2248	135	f
2250	135	f
2251	136	f
2252	136	f
2253	136	f
2254	136	f
2255	136	f
2256	136	f
2257	136	f
2258	136	f
2259	136	f
2260	136	f
2262	136	f
2263	136	f
2264	136	f
2265	136	f
2266	136	f
2268	136	f
2274	137	f
2275	137	f
2277	137	f
2280	137	f
2281	137	f
2282	137	f
2283	137	f
2284	137	f
2286	138	f
2287	138	f
2288	138	f
2289	138	f
2290	138	f
2292	138	f
2293	138	f
2294	138	f
2295	138	f
2297	138	f
2298	138	f
2299	138	f
2300	138	f
2301	139	f
2302	139	f
2303	139	f
2304	139	f
2305	139	f
2306	139	f
2307	139	f
2309	139	f
2310	139	f
2311	139	f
2312	139	f
2313	139	f
2314	139	f
2316	139	f
2317	139	f
2318	139	f
2319	139	f
2321	140	f
2322	140	f
2323	140	f
2326	140	f
2329	140	f
2330	140	f
2331	140	f
2332	140	f
2333	140	f
2336	141	f
2337	141	f
2338	141	f
2339	141	f
2340	141	f
2341	141	f
2342	141	f
2344	141	f
2346	141	f
2347	141	f
2348	141	f
2349	141	f
2350	141	f
2351	142	f
2352	142	f
2355	142	f
2357	142	f
2358	142	f
2359	142	f
2360	142	f
2364	142	f
2365	142	f
2366	142	f
2369	142	f
2370	142	f
2371	143	f
2372	143	f
2374	143	f
2375	143	f
2376	143	f
2377	143	f
2378	143	f
2379	143	f
2380	143	f
2381	143	f
2382	143	f
2383	143	f
2385	143	f
2386	144	f
2387	144	f
2390	144	f
2391	144	f
2392	144	f
2396	144	f
2398	144	f
2399	144	f
2400	144	f
2402	145	f
2403	145	f
2404	145	f
2405	145	f
2408	145	f
2409	145	f
2410	145	f
2411	145	f
2414	145	f
2416	145	f
2418	145	f
2419	145	f
2420	145	f
2425	146	f
2426	146	f
2427	146	f
2428	146	f
2430	146	f
2432	146	f
2433	146	f
2438	147	f
2440	147	f
2441	147	f
2442	147	f
2443	147	f
2444	147	f
2445	147	f
2446	147	f
2447	147	f
2450	147	f
2452	148	f
2453	148	f
2457	148	f
2458	148	f
2459	148	f
2462	148	f
2463	148	f
2464	148	f
2465	148	f
2466	148	f
2467	148	f
2468	148	f
2469	148	f
2470	148	f
2471	149	f
2472	149	f
2473	149	f
2474	149	f
2475	149	f
2476	149	f
2477	149	f
2478	149	f
2479	149	f
2482	149	f
2483	149	f
2484	149	f
2485	149	f
2487	150	f
2489	150	f
2490	150	f
2491	150	f
2492	150	f
2493	150	f
2494	150	f
2495	150	f
2497	150	f
2498	150	f
2499	150	f
2500	150	f
2501	151	f
2503	151	f
2504	151	f
2505	151	f
2508	151	f
2509	151	f
2510	151	f
2511	151	f
2512	151	f
2513	151	f
2514	151	f
2515	151	f
2516	151	f
2517	151	f
2518	151	f
2519	151	f
2521	152	f
2523	152	f
2525	152	f
2527	152	f
2529	152	f
2530	152	f
2533	152	f
2534	152	f
2536	153	f
2537	153	f
2538	153	f
2543	153	f
2544	153	f
2545	153	f
2547	153	f
2548	153	f
2549	153	f
2551	154	f
2552	154	f
2553	154	f
2556	154	f
2557	154	f
2560	154	f
2562	154	f
2563	154	f
2564	154	f
2566	154	f
2568	154	f
2569	154	f
2571	155	f
2573	155	f
2574	155	f
2576	155	f
2577	155	f
2578	155	f
2579	155	f
2580	155	f
2583	155	f
2584	155	f
2585	155	f
2586	156	f
2587	156	f
2588	156	f
2590	156	f
2591	156	f
2592	156	f
2593	156	f
2594	156	f
2595	156	f
2596	156	f
2597	156	f
2600	156	f
2601	157	f
2603	157	f
2604	157	f
2609	157	f
2610	157	f
2611	157	f
2612	157	f
2613	157	f
2615	157	f
2617	157	f
2618	157	f
2619	157	f
2621	158	f
2623	158	f
2624	158	f
2625	158	f
2627	158	f
2628	158	f
2630	158	f
2632	158	f
2633	158	f
2635	158	f
2637	159	f
2639	159	f
2640	159	f
2641	159	f
2642	159	f
2643	159	f
2646	159	f
2648	159	f
2650	159	f
2651	160	f
2652	160	f
2653	160	f
2654	160	f
2655	160	f
2656	160	f
2657	160	f
2658	160	f
2659	160	f
2660	160	f
2661	160	f
2662	160	f
2663	160	f
2665	160	f
2666	160	f
2668	160	f
2669	160	f
2670	160	f
2671	161	f
2673	161	f
2675	161	f
2676	161	f
2677	161	f
2678	161	f
2679	161	f
2681	161	f
2682	161	f
2683	161	f
2684	161	f
2685	161	f
2686	162	f
2688	162	f
2689	162	f
2691	162	f
2693	162	f
2697	162	f
2698	162	f
2699	162	f
2700	162	f
2701	163	f
2703	163	f
2705	163	f
2706	163	f
2707	163	f
2711	163	f
2714	163	f
2718	163	f
2720	163	f
2721	164	f
2722	164	f
2723	164	f
2724	164	f
2725	164	f
2726	164	f
2727	164	f
2728	164	f
2731	164	f
2732	164	f
2733	164	f
2735	164	f
2736	165	f
2737	165	f
2738	165	f
2739	165	f
2740	165	f
2741	165	f
2742	165	f
2743	165	f
2744	165	f
2745	165	f
2746	165	f
2748	165	f
2749	165	f
2750	165	f
2752	166	f
2753	166	f
2754	166	f
2755	166	f
2756	166	f
2757	166	f
2759	166	f
2760	166	f
2761	166	f
2765	166	f
2767	166	f
2771	167	f
2772	167	f
2773	167	f
2774	167	f
2775	167	f
2776	167	f
2777	167	f
2778	167	f
2781	167	f
2782	167	f
2783	167	f
2784	167	f
2786	168	f
2787	168	f
2791	168	f
2792	168	f
2793	168	f
2794	168	f
2795	168	f
2797	168	f
2798	168	f
2799	168	f
2801	169	f
2802	169	f
2804	169	f
2805	169	f
2806	169	f
2807	169	f
2808	169	f
2809	169	f
2810	169	f
2811	169	f
2812	169	f
2813	169	f
2816	169	f
2818	169	f
2819	169	f
2820	169	f
2822	170	f
2823	170	f
2824	170	f
2825	170	f
2826	170	f
2827	170	f
2828	170	f
2829	170	f
2830	170	f
2831	170	f
2832	170	f
2833	170	f
2834	170	f
2835	170	f
2836	171	f
2837	171	f
2838	171	f
2839	171	f
2840	171	f
2841	171	f
2842	171	f
2843	171	f
2844	171	f
2845	171	f
2846	171	f
2847	171	f
2850	171	f
2851	172	f
2852	172	f
2854	172	f
2855	172	f
2856	172	f
2857	172	f
2859	172	f
2860	172	f
2861	172	f
2862	172	f
2863	172	f
2864	172	f
2866	172	f
2867	172	f
2868	172	f
2871	173	f
2872	173	f
2873	173	f
2875	173	f
2876	173	f
2877	173	f
2878	173	f
2880	173	f
2881	173	f
2882	173	f
2884	173	f
2885	173	f
2886	174	f
2887	174	f
2888	174	f
2889	174	f
2890	174	f
2891	174	f
2892	174	f
2893	174	f
2894	174	f
2895	174	f
2896	174	f
2897	174	f
2898	174	f
2899	174	f
2900	174	f
2901	175	f
2902	175	f
2906	175	f
2907	175	f
2908	175	f
2909	175	f
2910	175	f
2911	175	f
2912	175	f
2914	175	f
2915	175	f
2916	175	f
2917	175	f
2918	175	f
2919	175	f
2923	176	f
2924	176	f
2927	176	f
2928	176	f
2929	176	f
2930	176	f
2931	176	f
2932	176	f
2935	176	f
2936	177	f
2937	177	f
2938	177	f
2942	177	f
2943	177	f
2944	177	f
2945	177	f
2946	177	f
2947	177	f
2948	177	f
2949	177	f
2950	177	f
2951	178	f
2953	178	f
2955	178	f
2956	178	f
2957	178	f
2958	178	f
2959	178	f
2960	178	f
2961	178	f
2962	178	f
2964	178	f
2965	178	f
2966	178	f
2968	178	f
2971	179	f
2972	179	f
2974	179	f
2975	179	f
2979	179	f
2980	179	f
2981	179	f
2982	179	f
2983	179	f
2985	179	f
2986	180	f
2988	180	f
2989	180	f
2990	180	f
2992	180	f
2993	180	f
2994	180	f
2995	180	f
2996	180	f
2997	180	f
2998	180	f
2999	180	f
3000	180	f
3002	181	f
3004	181	f
3005	181	f
3006	181	f
3007	181	f
3009	181	f
3012	181	f
3014	181	f
3015	181	f
3017	181	f
3019	181	f
3021	182	f
3022	182	f
3023	182	f
3026	182	f
3027	182	f
3029	182	f
3030	182	f
3031	182	f
3032	182	f
3033	182	f
3036	183	f
3039	183	f
3040	183	f
3041	183	f
3042	183	f
3046	183	f
3047	183	f
3049	183	f
3050	183	f
3051	184	f
3053	184	f
3054	184	f
3057	184	f
3059	184	f
3060	184	f
3061	184	f
3062	184	f
3063	184	f
3064	184	f
3065	184	f
3066	184	f
3067	184	f
3069	184	f
3070	184	f
3071	185	f
3072	185	f
3073	185	f
3074	185	f
3075	185	f
3076	185	f
3077	185	f
3078	185	f
3079	185	f
3080	185	f
3081	185	f
3082	185	f
3083	185	f
3085	185	f
3086	186	f
3087	186	f
3088	186	f
3089	186	f
3090	186	f
3091	186	f
3093	186	f
3094	186	f
3095	186	f
3096	186	f
3097	186	f
3098	186	f
3100	186	f
3101	187	f
3103	187	f
3104	187	f
3105	187	f
3107	187	f
3108	187	f
3109	187	f
3110	187	f
3111	187	f
3112	187	f
3113	187	f
3116	187	f
3117	187	f
3119	187	f
3122	188	f
3124	188	f
3125	188	f
3126	188	f
3127	188	f
3128	188	f
3130	188	f
3131	188	f
3132	188	f
3133	188	f
3135	188	f
3136	189	f
3137	189	f
3138	189	f
3139	189	f
3140	189	f
3141	189	f
3145	189	f
3147	189	f
3148	189	f
3149	189	f
3150	189	f
3151	190	f
3152	190	f
3153	190	f
3154	190	f
3155	190	f
3158	190	f
3159	190	f
3160	190	f
3161	190	f
3162	190	f
3163	190	f
3164	190	f
3166	190	f
3167	190	f
3168	190	f
3169	190	f
3172	191	f
3175	191	f
3177	191	f
3179	191	f
3180	191	f
3181	191	f
3183	191	f
3184	191	f
3185	191	f
3186	192	f
3187	192	f
3188	192	f
3189	192	f
3190	192	f
3191	192	f
3194	192	f
3195	192	f
3197	192	f
3198	192	f
3200	192	f
3202	193	f
3203	193	f
3204	193	f
3205	193	f
3210	193	f
3211	193	f
3212	193	f
3213	193	f
3214	193	f
3215	193	f
3216	193	f
3217	193	f
3218	193	f
3219	193	f
3220	193	f
3224	194	f
3226	194	f
3228	194	f
3229	194	f
3234	194	f
3235	194	f
3236	195	f
3237	195	f
3238	195	f
3240	195	f
3242	195	f
3244	195	f
3245	195	f
3246	195	f
3247	195	f
3249	195	f
3250	195	f
3251	196	f
3252	196	f
3253	196	f
3254	196	f
3255	196	f
3256	196	f
3257	196	f
3258	196	f
3259	196	f
3260	196	f
3261	196	f
3262	196	f
3263	196	f
3264	196	f
3265	196	f
3266	196	f
3267	196	f
3268	196	f
3269	196	f
3270	196	f
3271	197	f
3272	197	f
3273	197	f
3274	197	f
3275	197	f
3276	197	f
3277	197	f
3278	197	f
3279	197	f
3280	197	f
3281	197	f
3282	197	f
3284	197	f
3285	197	f
3286	198	f
3287	198	f
3288	198	f
3289	198	f
3290	198	f
3291	198	f
3292	198	f
3293	198	f
3294	198	f
3295	198	f
3296	198	f
3297	198	f
3298	198	f
3299	198	f
3300	198	f
3302	199	f
3303	199	f
3304	199	f
3305	199	f
3307	199	f
3308	199	f
3310	199	f
3311	199	f
3312	199	f
3313	199	f
3314	199	f
3315	199	f
3316	199	f
3317	199	f
3319	199	f
3320	199	f
3322	200	f
3323	200	f
3325	200	f
3326	200	f
3327	200	f
3328	200	f
3330	200	f
3331	200	f
3333	200	f
3334	200	f
3336	201	f
3337	201	f
3339	201	f
3340	201	f
3341	201	f
3342	201	f
3343	201	f
3345	201	f
3347	201	f
3348	201	f
3350	201	f
3351	202	f
3353	202	f
3354	202	f
3358	202	f
3359	202	f
3360	202	f
3361	202	f
3362	202	f
3363	202	f
3364	202	f
3365	202	f
3367	202	f
3371	203	f
3373	203	f
3374	203	f
3375	203	f
3376	203	f
3377	203	f
3378	203	f
3380	203	f
3381	203	f
3382	203	f
3383	203	f
3384	203	f
3385	203	f
3389	204	f
3391	204	f
3392	204	f
3393	204	f
3395	204	f
3397	204	f
3398	204	f
3400	204	f
3401	205	f
3402	205	f
3403	205	f
3404	205	f
3405	205	f
3406	205	f
3408	205	f
3410	205	f
3411	205	f
3413	205	f
3414	205	f
3419	205	f
3420	205	f
3421	206	f
3422	206	f
3423	206	f
3426	206	f
3427	206	f
3429	206	f
3430	206	f
3431	206	f
3432	206	f
3433	206	f
3434	206	f
3437	207	f
3438	207	f
3439	207	f
3442	207	f
3444	207	f
3445	207	f
3447	207	f
3448	207	f
3449	207	f
3451	208	f
3453	208	f
3454	208	f
3455	208	f
3456	208	f
3457	208	f
3458	208	f
3459	208	f
3460	208	f
3461	208	f
3463	208	f
3468	208	f
3469	208	f
3472	209	f
3473	209	f
3475	209	f
3477	209	f
3478	209	f
3479	209	f
3480	209	f
3481	209	f
3482	209	f
3483	209	f
3485	209	f
3486	210	f
3488	210	f
3489	210	f
3490	210	f
3492	210	f
3493	210	f
3494	210	f
3496	210	f
3497	210	f
3498	210	f
3499	210	f
3501	211	f
3502	211	f
3506	211	f
3507	211	f
3508	211	f
3510	211	f
3511	211	f
3513	211	f
3514	211	f
3515	211	f
3519	211	f
3521	212	f
3522	212	f
3523	212	f
3525	212	f
3526	212	f
3528	212	f
3529	212	f
3530	212	f
3531	212	f
3533	212	f
3534	212	f
3535	212	f
3536	213	f
3538	213	f
3539	213	f
3541	213	f
3544	213	f
3545	213	f
3546	213	f
3548	213	f
3549	213	f
3550	213	f
3551	214	f
3554	214	f
3555	214	f
3556	214	f
3557	214	f
3559	214	f
3561	214	f
3562	214	f
3563	214	f
3564	214	f
3565	214	f
3566	214	f
3567	214	f
3568	214	f
3569	214	f
3570	214	f
3572	215	f
3573	215	f
3574	215	f
3575	215	f
3576	215	f
3578	215	f
3579	215	f
3580	215	f
3582	215	f
3583	215	f
3586	216	f
3588	216	f
3590	216	f
3591	216	f
3593	216	f
3594	216	f
3595	216	f
3596	216	f
3598	216	f
3599	216	f
3600	216	f
3602	217	f
3603	217	f
3604	217	f
3606	217	f
3607	217	f
3609	217	f
3610	217	f
3612	217	f
3613	217	f
3615	217	f
3616	217	f
3617	217	f
3618	217	f
3620	217	f
3621	218	f
3623	218	f
3624	218	f
3625	218	f
3627	218	f
3629	218	f
3631	218	f
3632	218	f
3633	218	f
3634	218	f
3635	218	f
3636	219	f
3637	219	f
3638	219	f
3640	219	f
3642	219	f
3643	219	f
3644	219	f
3645	219	f
3646	219	f
3648	219	f
3650	219	f
3651	220	f
3652	220	f
3654	220	f
3655	220	f
3656	220	f
3657	220	f
3658	220	f
3659	220	f
3660	220	f
3662	220	f
3663	220	f
3664	220	f
3665	220	f
3666	220	f
3668	220	f
3670	220	f
3672	221	f
3674	221	f
3675	221	f
3677	221	f
3678	221	f
3679	221	f
3680	221	f
3681	221	f
3682	221	f
3683	221	f
3684	221	f
3685	221	f
3687	222	f
3690	222	f
3692	222	f
3693	222	f
3694	222	f
3695	222	f
3696	222	f
3697	222	f
3698	222	f
3699	222	f
3701	223	f
3702	223	f
3705	223	f
3706	223	f
3707	223	f
3708	223	f
3709	223	f
3710	223	f
3712	223	f
3713	223	f
3716	223	f
3717	223	f
3719	223	f
3720	223	f
3721	224	f
3722	224	f
3723	224	f
3725	224	f
3726	224	f
3727	224	f
3728	224	f
3730	224	f
3731	224	f
3732	224	f
3733	224	f
3734	224	f
3735	224	f
3736	225	f
3737	225	f
3738	225	f
3741	225	f
3742	225	f
3744	225	f
3745	225	f
3746	225	f
3747	225	f
3749	225	f
3751	226	f
3752	226	f
3753	226	f
3755	226	f
3756	226	f
3757	226	f
3759	226	f
3760	226	f
3761	226	f
3763	226	f
3764	226	f
3768	226	f
3769	226	f
3772	227	f
3773	227	f
3774	227	f
3775	227	f
3776	227	f
3777	227	f
3778	227	f
3779	227	f
3780	227	f
3782	227	f
3783	227	f
3784	227	f
3785	227	f
3786	228	f
3787	228	f
3788	228	f
3791	228	f
3792	228	f
3793	228	f
3794	228	f
3795	228	f
3796	228	f
3800	228	f
3801	229	f
3804	229	f
3806	229	f
3807	229	f
3808	229	f
3809	229	f
3810	229	f
3811	229	f
3814	229	f
3815	229	f
3816	229	f
3818	229	f
3819	229	f
3820	229	f
3821	230	f
3822	230	f
3823	230	f
3825	230	f
3827	230	f
3829	230	f
3830	230	f
3832	230	f
3833	230	f
3834	230	f
3835	230	f
3836	231	f
3837	231	f
3838	231	f
3839	231	f
3841	231	f
3843	231	f
3844	231	f
3845	231	f
3847	231	f
3848	231	f
3849	231	f
3850	231	f
3851	232	f
3852	232	f
3855	232	f
3856	232	f
3857	232	f
3861	232	f
3864	232	f
3865	232	f
3866	232	f
3867	232	f
3868	232	f
3869	232	f
3870	232	f
3871	233	f
3872	233	f
3874	233	f
3876	233	f
3877	233	f
3879	233	f
3880	233	f
3881	233	f
3882	233	f
3883	233	f
3884	233	f
3887	234	f
3888	234	f
3889	234	f
3890	234	f
3892	234	f
3893	234	f
3894	234	f
3895	234	f
3896	234	f
3897	234	f
3899	234	f
3901	235	f
3902	235	f
3905	235	f
3906	235	f
3908	235	f
3910	235	f
3911	235	f
3912	235	f
3915	235	f
3916	235	f
3917	235	f
3918	235	f
3920	235	f
3921	236	f
3923	236	f
3924	236	f
3925	236	f
3929	236	f
3932	236	f
3933	236	f
3934	236	f
3935	236	f
3936	237	f
3937	237	f
3938	237	f
3939	237	f
3940	237	f
3941	237	f
3942	237	f
3944	237	f
3946	237	f
3947	237	f
3949	237	f
3950	237	f
3951	238	f
3952	238	f
3953	238	f
3954	238	f
3955	238	f
3956	238	f
3957	238	f
3958	238	f
3959	238	f
3961	238	f
3962	238	f
3963	238	f
3964	238	f
3966	238	f
3967	238	f
3969	238	f
3971	239	f
3973	239	f
3975	239	f
3976	239	f
3977	239	f
3978	239	f
3979	239	f
3980	239	f
3981	239	f
3982	239	f
3983	239	f
3985	239	f
3986	240	f
3987	240	f
3989	240	f
3992	240	f
3993	240	f
3995	240	f
3997	240	f
3999	240	f
4000	240	f
4001	241	f
4002	241	f
4004	241	f
4005	241	f
4006	241	f
4007	241	f
4008	241	f
4009	241	f
4010	241	f
4012	241	f
4014	241	f
4015	241	f
4017	241	f
4018	241	f
4019	241	f
4020	241	f
4021	242	f
4023	242	f
4025	242	f
4027	242	f
4028	242	f
4032	242	f
4033	242	f
4034	242	f
4035	242	f
4036	243	f
4037	243	f
4038	243	f
4039	243	f
4040	243	f
4044	243	f
4045	243	f
4046	243	f
4047	243	f
4048	243	f
4049	243	f
4050	243	f
4053	244	f
4055	244	f
4057	244	f
4058	244	f
4059	244	f
4060	244	f
4061	244	f
4062	244	f
4063	244	f
4064	244	f
4066	244	f
4069	244	f
4073	245	f
4076	245	f
4077	245	f
4080	245	f
4081	245	f
4083	245	f
4085	245	f
4086	246	f
4087	246	f
4088	246	f
4089	246	f
4092	246	f
4093	246	f
4094	246	f
4095	246	f
4096	246	f
4097	246	f
4098	246	f
4099	246	f
4100	246	f
4101	247	f
4102	247	f
4103	247	f
4104	247	f
4105	247	f
4106	247	f
4107	247	f
4108	247	f
4109	247	f
4111	247	f
4112	247	f
4113	247	f
4114	247	f
4115	247	f
4116	247	f
4118	247	f
4119	247	f
4120	247	f
4122	248	f
4123	248	f
4124	248	f
4126	248	f
4127	248	f
4128	248	f
4129	248	f
4130	248	f
4131	248	f
4133	248	f
4134	248	f
4135	248	f
4136	249	f
4137	249	f
4138	249	f
4139	249	f
4140	249	f
4141	249	f
4142	249	f
4143	249	f
4144	249	f
4146	249	f
4147	249	f
4149	249	f
4152	250	f
4154	250	f
4155	250	f
4156	250	f
4157	250	f
4158	250	f
4159	250	f
4160	250	f
4162	250	f
4163	250	f
4164	250	f
4167	250	f
4168	250	f
4169	250	f
4171	251	f
4172	251	f
4174	251	f
4175	251	f
4176	251	f
4177	251	f
4179	251	f
4180	251	f
4181	251	f
4182	251	f
4183	251	f
4184	251	f
4185	251	f
4186	252	f
4187	252	f
4188	252	f
4191	252	f
4193	252	f
4195	252	f
4196	252	f
4197	252	f
4198	252	f
4199	252	f
4201	253	f
4202	253	f
4203	253	f
4204	253	f
4205	253	f
4206	253	f
4207	253	f
4208	253	f
4209	253	f
4210	253	f
4212	253	f
4213	253	f
4214	253	f
4215	253	f
4216	253	f
4217	253	f
4218	253	f
4220	253	f
4222	254	f
4224	254	f
4225	254	f
4226	254	f
4230	254	f
4231	254	f
4235	254	f
4236	255	f
4237	255	f
4238	255	f
4241	255	f
4242	255	f
4244	255	f
4246	255	f
4247	255	f
4250	255	f
4251	256	f
4253	256	f
4254	256	f
4255	256	f
4256	256	f
4258	256	f
4259	256	f
4260	256	f
4261	256	f
4263	256	f
4264	256	f
4265	256	f
4268	256	f
4269	256	f
4271	257	f
4272	257	f
4273	257	f
4274	257	f
4275	257	f
4276	257	f
4277	257	f
4278	257	f
4279	257	f
4281	257	f
4282	257	f
4283	257	f
4284	257	f
4285	257	f
4286	258	f
4287	258	f
4288	258	f
4289	258	f
4290	258	f
4291	258	f
4292	258	f
4293	258	f
4294	258	f
4296	258	f
4297	258	f
4298	258	f
4300	258	f
4301	259	f
4302	259	f
4303	259	f
4304	259	f
4305	259	f
4306	259	f
4307	259	f
4309	259	f
4310	259	f
4312	259	f
4313	259	f
4314	259	f
4315	259	f
4316	259	f
4317	259	f
4318	259	f
4319	259	f
4320	259	f
4321	260	f
4322	260	f
4323	260	f
4324	260	f
4326	260	f
4328	260	f
4329	260	f
4331	260	f
4333	260	f
4335	260	f
4336	261	f
4337	261	f
4338	261	f
4341	261	f
4342	261	f
4344	261	f
4345	261	f
4346	261	f
4347	261	f
4348	261	f
4349	261	f
4350	261	f
4351	262	f
4353	262	f
4356	262	f
4357	262	f
4358	262	f
4359	262	f
4360	262	f
4361	262	f
4362	262	f
4364	262	f
4365	262	f
4366	262	f
4367	262	f
4368	262	f
4369	262	f
4370	262	f
4371	263	f
4372	263	f
4375	263	f
4376	263	f
4378	263	f
4379	263	f
4380	263	f
4381	263	f
4383	263	f
4384	263	f
4385	263	f
4386	264	f
4387	264	f
4390	264	f
4391	264	f
4392	264	f
4394	264	f
4397	264	f
4398	264	f
4399	264	f
4400	264	f
4401	265	f
4402	265	f
4403	265	f
4404	265	f
4408	265	f
4412	265	f
4413	265	f
4414	265	f
4416	265	f
4417	265	f
4418	265	f
4419	265	f
4420	265	f
4422	266	f
4423	266	f
4425	266	f
4426	266	f
4428	266	f
4429	266	f
4430	266	f
4432	266	f
4433	266	f
4435	266	f
4438	267	f
4439	267	f
4440	267	f
4444	267	f
4445	267	f
4447	267	f
4448	267	f
4449	267	f
4450	267	f
4452	268	f
4453	268	f
4454	268	f
4457	268	f
4458	268	f
4459	268	f
4461	268	f
4462	268	f
4464	268	f
4465	268	f
4466	268	f
4467	268	f
4468	268	f
4469	268	f
4470	268	f
4473	269	f
4474	269	f
4476	269	f
4477	269	f
4478	269	f
4479	269	f
4481	269	f
4482	269	f
4484	269	f
4485	269	f
4488	270	f
4489	270	f
4491	270	f
4492	270	f
4493	270	f
4494	270	f
4495	270	f
4498	270	f
4500	270	f
4502	271	f
4503	271	f
4504	271	f
4507	271	f
4508	271	f
4509	271	f
4511	271	f
4513	271	f
4514	271	f
4516	271	f
4517	271	f
4518	271	f
4520	271	f
4521	272	f
4522	272	f
4523	272	f
4524	272	f
4525	272	f
4527	272	f
4530	272	f
4532	272	f
4534	272	f
4535	272	f
4536	273	f
4540	273	f
4541	273	f
4543	273	f
4544	273	f
4546	273	f
4547	273	f
4548	273	f
4549	273	f
4551	274	f
4552	274	f
4553	274	f
4554	274	f
4556	274	f
4557	274	f
4559	274	f
4560	274	f
4561	274	f
4562	274	f
4563	274	f
4568	274	f
4569	274	f
4570	274	f
4571	275	f
4573	275	f
4574	275	f
4575	275	f
4576	275	f
4577	275	f
4579	275	f
4580	275	f
4582	275	f
4583	275	f
4584	275	f
4585	275	f
4587	276	f
4589	276	f
4590	276	f
4592	276	f
4593	276	f
4594	276	f
4595	276	f
4596	276	f
4597	276	f
4599	276	f
4600	276	f
4601	277	f
4602	277	f
4603	277	f
4605	277	f
4606	277	f
4608	277	f
4609	277	f
4610	277	f
4611	277	f
4612	277	f
4613	277	f
4614	277	f
4616	277	f
4620	277	f
4621	278	f
4622	278	f
4623	278	f
4625	278	f
4626	278	f
4627	278	f
4629	278	f
4630	278	f
4631	278	f
4632	278	f
4633	278	f
4635	278	f
4636	279	f
4639	279	f
4640	279	f
4641	279	f
4642	279	f
4643	279	f
4644	279	f
4645	279	f
4646	279	f
4647	279	f
4648	279	f
4649	279	f
4650	279	f
4651	280	f
4652	280	f
4654	280	f
4655	280	f
4656	280	f
4657	280	f
4658	280	f
4659	280	f
4660	280	f
4661	280	f
4663	280	f
4664	280	f
4665	280	f
4667	280	f
4668	280	f
4669	280	f
4670	280	f
4671	281	f
4674	281	f
4675	281	f
4676	281	f
4678	281	f
4679	281	f
4681	281	f
4682	281	f
4683	281	f
4684	281	f
4686	282	f
4689	282	f
4690	282	f
4691	282	f
4693	282	f
4694	282	f
4695	282	f
4696	282	f
4698	282	f
4701	283	f
4702	283	f
4703	283	f
4704	283	f
4706	283	f
4707	283	f
4708	283	f
4709	283	f
4710	283	f
4711	283	f
4712	283	f
4713	283	f
4714	283	f
4715	283	f
4716	283	f
4717	283	f
4718	283	f
4720	283	f
4721	284	f
4722	284	f
4723	284	f
4726	284	f
4728	284	f
4729	284	f
4732	284	f
4734	284	f
4735	284	f
4737	285	f
4738	285	f
4740	285	f
4742	285	f
4743	285	f
4745	285	f
4746	285	f
4747	285	f
4749	285	f
4752	286	f
4754	286	f
4755	286	f
4756	286	f
4757	286	f
4760	286	f
4761	286	f
4762	286	f
4764	286	f
4765	286	f
4766	286	f
4767	286	f
4768	286	f
4769	286	f
4770	286	f
4772	287	f
4773	287	f
4775	287	f
4776	287	f
4777	287	f
4781	287	f
4782	287	f
4783	287	f
4784	287	f
4785	287	f
4789	288	f
4790	288	f
4791	288	f
4792	288	f
4794	288	f
4795	288	f
4797	288	f
4798	288	f
4799	288	f
4800	288	f
4801	289	f
4803	289	f
4804	289	f
4805	289	f
4807	289	f
4809	289	f
4810	289	f
4812	289	f
4814	289	f
4816	289	f
4819	289	f
4820	289	f
4821	290	f
4822	290	f
4823	290	f
4824	290	f
4825	290	f
4826	290	f
4828	290	f
4830	290	f
4833	290	f
4834	290	f
4838	291	f
4839	291	f
4840	291	f
4842	291	f
4843	291	f
4844	291	f
4846	291	f
4847	291	f
4849	291	f
4851	292	f
4852	292	f
4856	292	f
4857	292	f
4858	292	f
4859	292	f
4860	292	f
4861	292	f
4862	292	f
4867	292	f
4868	292	f
4869	292	f
4870	292	f
4871	293	f
4873	293	f
4874	293	f
4876	293	f
4877	293	f
4879	293	f
4880	293	f
4881	293	f
4883	293	f
4886	294	f
4888	294	f
4890	294	f
4894	294	f
4897	294	f
4899	294	f
4901	295	f
4902	295	f
4903	295	f
4904	295	f
4905	295	f
4906	295	f
4907	295	f
4908	295	f
4909	295	f
4910	295	f
4912	295	f
4915	295	f
4916	295	f
4917	295	f
4918	295	f
4921	296	f
4922	296	f
4923	296	f
4924	296	f
4925	296	f
4926	296	f
4927	296	f
4930	296	f
4931	296	f
4932	296	f
4933	296	f
4934	296	f
4936	297	f
4937	297	f
4940	297	f
4942	297	f
4943	297	f
4946	297	f
4947	297	f
4949	297	f
4950	297	f
4951	298	f
4952	298	f
4954	298	f
4955	298	f
4956	298	f
4957	298	f
4958	298	f
4959	298	f
4960	298	f
4961	298	f
4963	298	f
4965	298	f
4966	298	f
4967	298	f
4968	298	f
4969	298	f
4971	299	f
4972	299	f
4974	299	f
4975	299	f
4976	299	f
4977	299	f
4979	299	f
4980	299	f
4981	299	f
4982	299	f
4983	299	f
4986	300	f
4987	300	f
4988	300	f
4990	300	f
4991	300	f
4992	300	f
4994	300	f
4997	300	f
4998	300	f
4999	300	f
5000	300	f
5001	301	f
5002	301	f
5003	301	f
5004	301	f
5005	301	f
5006	301	f
5007	301	f
5012	301	f
5013	301	f
5014	301	f
5015	301	f
5016	301	f
5018	301	f
5020	301	f
5022	302	f
5023	302	f
5026	302	f
5029	302	f
5030	302	f
5031	302	f
5032	302	f
5033	302	f
5034	302	f
5035	302	f
5036	303	f
5038	303	f
5039	303	f
5040	303	f
5042	303	f
5043	303	f
5044	303	f
5045	303	f
5048	303	f
5049	303	f
5050	303	f
5051	304	f
5052	304	f
5053	304	f
5054	304	f
5055	304	f
5056	304	f
5057	304	f
5058	304	f
5059	304	f
5060	304	f
5063	304	f
5064	304	f
5065	304	f
5068	304	f
5070	304	f
5071	305	f
5072	305	f
5074	305	f
5075	305	f
5076	305	f
5077	305	f
5078	305	f
5080	305	f
5081	305	f
5082	305	f
5083	305	f
5084	305	f
5086	306	f
5087	306	f
5089	306	f
5091	306	f
5092	306	f
5093	306	f
5096	306	f
5097	306	f
5099	306	f
5100	306	f
5101	307	f
5102	307	f
5104	307	f
5106	307	f
5107	307	f
5108	307	f
5109	307	f
5110	307	f
5111	307	f
5113	307	f
5116	307	f
5117	307	f
5118	307	f
5120	307	f
5122	308	f
5123	308	f
5124	308	f
5125	308	f
5126	308	f
5127	308	f
5129	308	f
5130	308	f
5132	308	f
5133	308	f
5134	308	f
5135	308	f
5136	309	f
5137	309	f
5138	309	f
5140	309	f
5141	309	f
5142	309	f
5144	309	f
5145	309	f
5146	309	f
5147	309	f
5148	309	f
5151	310	f
5152	310	f
5153	310	f
5154	310	f
5155	310	f
5156	310	f
5157	310	f
5158	310	f
5161	310	f
5163	310	f
5164	310	f
5165	310	f
5166	310	f
5167	310	f
5169	310	f
5170	310	f
5173	311	f
5174	311	f
5175	311	f
5176	311	f
5177	311	f
5180	311	f
5182	311	f
5184	311	f
5185	311	f
5186	312	f
5187	312	f
5188	312	f
5189	312	f
5190	312	f
5191	312	f
5192	312	f
5193	312	f
5194	312	f
5195	312	f
5196	312	f
5197	312	f
5198	312	f
5201	313	f
5203	313	f
5204	313	f
5205	313	f
5206	313	f
5207	313	f
5208	313	f
5212	313	f
5213	313	f
5214	313	f
5215	313	f
5216	313	f
5217	313	f
5220	313	f
5221	314	f
5222	314	f
5223	314	f
5224	314	f
5225	314	f
5226	314	f
5228	314	f
5229	314	f
5230	314	f
5231	314	f
5232	314	f
5233	314	f
5236	315	f
5237	315	f
5238	315	f
5239	315	f
5240	315	f
5241	315	f
5243	315	f
5245	315	f
5246	315	f
5247	315	f
5248	315	f
5249	315	f
5250	315	f
5251	316	f
5252	316	f
5253	316	f
5254	316	f
5255	316	f
5256	316	f
5258	316	f
5259	316	f
5262	316	f
5264	316	f
5265	316	f
5266	316	f
5267	316	f
5268	316	f
5269	316	f
5270	316	f
5271	317	f
5272	317	f
5273	317	f
5274	317	f
5275	317	f
5276	317	f
5277	317	f
5279	317	f
5280	317	f
5281	317	f
5282	317	f
5283	317	f
5285	317	f
5287	318	f
5288	318	f
5289	318	f
5290	318	f
5292	318	f
5293	318	f
5294	318	f
5297	318	f
5299	318	f
5300	318	f
5301	319	f
5304	319	f
5305	319	f
5306	319	f
5308	319	f
5310	319	f
5312	319	f
5314	319	f
5316	319	f
5318	319	f
5321	320	f
5323	320	f
5324	320	f
5325	320	f
5326	320	f
5327	320	f
5329	320	f
5330	320	f
5332	320	f
5333	320	f
5334	320	f
5335	320	f
5336	321	f
5338	321	f
5339	321	f
5342	321	f
5343	321	f
5344	321	f
5345	321	f
5347	321	f
5348	321	f
5351	322	f
5352	322	f
5353	322	f
5354	322	f
5355	322	f
5357	322	f
5358	322	f
5359	322	f
5360	322	f
5361	322	f
5362	322	f
5363	322	f
5364	322	f
5365	322	f
5367	322	f
5368	322	f
5369	322	f
5370	322	f
5371	323	f
5372	323	f
5374	323	f
5377	323	f
5378	323	f
5379	323	f
5380	323	f
5381	323	f
5382	323	f
5384	323	f
5385	323	f
5387	324	f
5388	324	f
5390	324	f
5391	324	f
5392	324	f
5394	324	f
5395	324	f
5396	324	f
5399	324	f
5400	324	f
5404	325	f
5406	325	f
5407	325	f
5408	325	f
5409	325	f
5410	325	f
5411	325	f
5412	325	f
5413	325	f
5414	325	f
5415	325	f
5416	325	f
5418	325	f
5419	325	f
5420	325	f
5422	326	f
5423	326	f
5424	326	f
5425	326	f
5426	326	f
5429	326	f
5430	326	f
5431	326	f
5434	326	f
5435	326	f
5436	327	f
5437	327	f
5438	327	f
5439	327	f
5443	327	f
5444	327	f
5446	327	f
5449	327	f
5450	327	f
5451	328	f
5453	328	f
5454	328	f
5458	328	f
5459	328	f
5460	328	f
5462	328	f
5464	328	f
5468	328	f
5470	328	f
5472	329	f
5473	329	f
5474	329	f
5476	329	f
5477	329	f
5478	329	f
5479	329	f
5481	329	f
5482	329	f
5485	329	f
5488	330	f
5489	330	f
5490	330	f
5491	330	f
5492	330	f
5493	330	f
5495	330	f
5496	330	f
5497	330	f
5498	330	f
5499	330	f
5501	331	f
5502	331	f
5504	331	f
5505	331	f
5506	331	f
5507	331	f
5508	331	f
5509	331	f
5510	331	f
5511	331	f
5512	331	f
5513	331	f
5515	331	f
5516	331	f
5517	331	f
5520	331	f
5521	332	f
5522	332	f
5524	332	f
5525	332	f
5526	332	f
5527	332	f
5528	332	f
5529	332	f
5530	332	f
5531	332	f
5533	332	f
5534	332	f
5535	332	f
5536	333	f
5537	333	f
5538	333	f
5539	333	f
5540	333	f
5541	333	f
5542	333	f
5543	333	f
5546	333	f
5547	333	f
5551	334	f
5552	334	f
5553	334	f
5554	334	f
5555	334	f
5556	334	f
5557	334	f
5560	334	f
5561	334	f
5562	334	f
5563	334	f
5564	334	f
5565	334	f
5566	334	f
5568	334	f
5569	334	f
5571	335	f
5572	335	f
5573	335	f
5576	335	f
5577	335	f
5578	335	f
5580	335	f
5581	335	f
5583	335	f
5585	335	f
5586	336	f
5590	336	f
5593	336	f
5596	336	f
5598	336	f
5599	336	f
5601	337	f
5602	337	f
5604	337	f
5605	337	f
5606	337	f
5608	337	f
5609	337	f
5610	337	f
5615	337	f
5617	337	f
5618	337	f
5619	337	f
5621	338	f
5622	338	f
5623	338	f
5624	338	f
5625	338	f
5627	338	f
5628	338	f
5629	338	f
5631	338	f
5632	338	f
5633	338	f
5636	339	f
5639	339	f
5640	339	f
5641	339	f
5642	339	f
5643	339	f
5644	339	f
5645	339	f
5648	339	f
5650	339	f
5651	340	f
5653	340	f
5654	340	f
5655	340	f
5656	340	f
5657	340	f
5658	340	f
5659	340	f
5661	340	f
5662	340	f
5663	340	f
5664	340	f
5666	340	f
5667	340	f
5668	340	f
5670	340	f
5671	341	f
5672	341	f
5673	341	f
5675	341	f
5676	341	f
5677	341	f
5678	341	f
5679	341	f
5680	341	f
5681	341	f
5682	341	f
5684	341	f
5685	341	f
5686	342	f
5689	342	f
5691	342	f
5692	342	f
5694	342	f
5695	342	f
5697	342	f
5699	342	f
5700	342	f
5701	343	f
5703	343	f
5704	343	f
5705	343	f
5706	343	f
5707	343	f
5708	343	f
5709	343	f
5713	343	f
5715	343	f
5716	343	f
5717	343	f
5718	343	f
5719	343	f
5720	343	f
5721	344	f
5723	344	f
5725	344	f
5726	344	f
5727	344	f
5728	344	f
5731	344	f
5732	344	f
5733	344	f
5734	344	f
5735	344	f
5736	345	f
5737	345	f
5738	345	f
5739	345	f
5741	345	f
5743	345	f
5744	345	f
5746	345	f
5748	345	f
5750	345	f
5752	346	f
5753	346	f
5754	346	f
5755	346	f
5757	346	f
5758	346	f
5759	346	f
5761	346	f
5764	346	f
5765	346	f
5766	346	f
5767	346	f
5768	346	f
5769	346	f
5771	347	f
5774	347	f
5776	347	f
5777	347	f
5778	347	f
5780	347	f
5781	347	f
5782	347	f
5783	347	f
5785	347	f
5786	348	f
5787	348	f
5789	348	f
5791	348	f
5792	348	f
5793	348	f
5794	348	f
5795	348	f
5797	348	f
5798	348	f
5799	348	f
5800	348	f
5801	349	f
5802	349	f
5803	349	f
5804	349	f
5805	349	f
5806	349	f
5807	349	f
5808	349	f
5809	349	f
5810	349	f
5811	349	f
5814	349	f
5817	349	f
5819	349	f
5820	349	f
5821	350	f
5823	350	f
5824	350	f
5825	350	f
5827	350	f
5828	350	f
5829	350	f
5830	350	f
5831	350	f
5836	351	f
5837	351	f
5839	351	f
5840	351	f
5841	351	f
5842	351	f
5843	351	f
5844	351	f
5845	351	f
5847	351	f
5849	351	f
5850	351	f
5852	352	f
5853	352	f
5855	352	f
5856	352	f
5858	352	f
5859	352	f
5860	352	f
5861	352	f
5862	352	f
5863	352	f
5864	352	f
5865	352	f
5866	352	f
5867	352	f
5868	352	f
5870	352	f
5871	353	f
5872	353	f
5873	353	f
5874	353	f
5878	353	f
5882	353	f
5883	353	f
5884	353	f
5885	353	f
5886	354	f
5887	354	f
5888	354	f
5889	354	f
5890	354	f
5891	354	f
5892	354	f
5893	354	f
5894	354	f
5895	354	f
5896	354	f
5897	354	f
5898	354	f
5899	354	f
5900	354	f
5901	355	f
5903	355	f
5906	355	f
5907	355	f
5908	355	f
5909	355	f
5910	355	f
5911	355	f
5912	355	f
5913	355	f
5915	355	f
5916	355	f
5918	355	f
5919	355	f
5920	355	f
5921	356	f
5924	356	f
5925	356	f
5926	356	f
5927	356	f
5928	356	f
5929	356	f
5930	356	f
5932	356	f
5933	356	f
5935	356	f
5936	357	f
5939	357	f
5940	357	f
5941	357	f
5943	357	f
5944	357	f
5947	357	f
5950	357	f
5951	358	f
5953	358	f
5955	358	f
5957	358	f
5959	358	f
5961	358	f
5963	358	f
5964	358	f
5965	358	f
5966	358	f
5967	358	f
5969	358	f
5970	358	f
5971	359	f
5976	359	f
5977	359	f
5978	359	f
5979	359	f
5980	359	f
5981	359	f
5982	359	f
5983	359	f
5984	359	f
5986	360	f
5987	360	f
5988	360	f
5989	360	f
5990	360	f
5991	360	f
5992	360	f
5994	360	f
5995	360	f
5996	360	f
5997	360	f
5998	360	f
5999	360	f
6000	360	f
6001	361	f
6002	361	f
6005	361	f
6006	361	f
6007	361	f
6010	361	f
6011	361	f
6013	361	f
6014	361	f
6015	361	f
6016	361	f
6017	361	f
6019	361	f
6020	361	f
6023	362	f
6024	362	f
6025	362	f
6027	362	f
6028	362	f
6029	362	f
6030	362	f
6031	362	f
6032	362	f
6033	362	f
6034	362	f
6035	362	f
6036	363	f
6037	363	f
6038	363	f
6040	363	f
6042	363	f
6043	363	f
6044	363	f
6045	363	f
6047	363	f
6049	363	f
6050	363	f
6051	364	f
6053	364	f
6054	364	f
6055	364	f
6056	364	f
6057	364	f
6058	364	f
6059	364	f
6060	364	f
6062	364	f
6063	364	f
6065	364	f
6068	364	f
6069	364	f
6071	365	f
6073	365	f
6074	365	f
6076	365	f
6078	365	f
6079	365	f
6080	365	f
6082	365	f
6083	365	f
6084	365	f
6085	365	f
6087	366	f
6088	366	f
6090	366	f
6091	366	f
6092	366	f
6093	366	f
6095	366	f
6096	366	f
6097	366	f
6098	366	f
6100	366	f
6101	367	f
6102	367	f
6103	367	f
6104	367	f
6105	367	f
6108	367	f
6109	367	f
6110	367	f
6111	367	f
6117	367	f
6118	367	f
6119	367	f
6122	368	f
6124	368	f
6126	368	f
6129	368	f
6130	368	f
6131	368	f
6132	368	f
6133	368	f
6134	368	f
6136	369	f
6139	369	f
6140	369	f
6141	369	f
6142	369	f
6143	369	f
6145	369	f
6146	369	f
6147	369	f
6148	369	f
6151	370	f
6152	370	f
6153	370	f
6154	370	f
6155	370	f
6156	370	f
6158	370	f
6159	370	f
6160	370	f
6161	370	f
6162	370	f
6164	370	f
6165	370	f
6166	370	f
6167	370	f
6168	370	f
6169	370	f
6170	370	f
6171	371	f
6172	371	f
6173	371	f
6174	371	f
6175	371	f
6176	371	f
6178	371	f
6181	371	f
6182	371	f
6183	371	f
6185	371	f
6186	372	f
6189	372	f
6190	372	f
6191	372	f
6193	372	f
6194	372	f
6195	372	f
6196	372	f
6197	372	f
6198	372	f
6199	372	f
6200	372	f
6202	373	f
6203	373	f
6204	373	f
6205	373	f
6206	373	f
6207	373	f
6208	373	f
6209	373	f
6210	373	f
6211	373	f
6213	373	f
6215	373	f
6217	373	f
6218	373	f
6222	374	f
6224	374	f
6225	374	f
6226	374	f
6227	374	f
6228	374	f
6229	374	f
6230	374	f
6231	374	f
6232	374	f
6233	374	f
6234	374	f
6235	374	f
6236	375	f
6237	375	f
6239	375	f
6240	375	f
6241	375	f
6242	375	f
6245	375	f
6246	375	f
6247	375	f
6248	375	f
6249	375	f
6250	375	f
6251	376	f
6252	376	f
6253	376	f
6254	376	f
6259	376	f
6260	376	f
6261	376	f
6264	376	f
6269	376	f
6270	376	f
6271	377	f
6272	377	f
6273	377	f
6274	377	f
6275	377	f
6277	377	f
6278	377	f
6279	377	f
6282	377	f
6283	377	f
6284	377	f
6285	377	f
6287	378	f
6288	378	f
6289	378	f
6290	378	f
6292	378	f
6293	378	f
6295	378	f
6297	378	f
6298	378	f
6300	378	f
6301	379	f
6302	379	f
6303	379	f
6304	379	f
6305	379	f
6307	379	f
6308	379	f
6310	379	f
6311	379	f
6312	379	f
6313	379	f
6314	379	f
6316	379	f
6317	379	f
6318	379	f
6320	379	f
6321	380	f
6322	380	f
6325	380	f
6327	380	f
6328	380	f
6329	380	f
6330	380	f
6331	380	f
6333	380	f
6334	380	f
6335	380	f
6336	381	f
6338	381	f
6339	381	f
6341	381	f
6342	381	f
6344	381	f
6345	381	f
6346	381	f
6347	381	f
6348	381	f
6350	381	f
6351	382	f
6352	382	f
6353	382	f
6354	382	f
6355	382	f
6356	382	f
6357	382	f
6358	382	f
6360	382	f
6361	382	f
6362	382	f
6363	382	f
6365	382	f
6366	382	f
6370	382	f
6371	383	f
6373	383	f
6374	383	f
6376	383	f
6377	383	f
6379	383	f
6380	383	f
6382	383	f
6383	383	f
6384	383	f
6385	383	f
6388	384	f
6389	384	f
6390	384	f
6391	384	f
6393	384	f
6394	384	f
6399	384	f
6400	384	f
6401	385	f
6402	385	f
6403	385	f
6404	385	f
6405	385	f
6406	385	f
6408	385	f
6409	385	f
6410	385	f
6411	385	f
6412	385	f
6413	385	f
6416	385	f
6417	385	f
6418	385	f
6419	385	f
6420	385	f
6421	386	f
6422	386	f
6424	386	f
6425	386	f
6426	386	f
6427	386	f
6433	386	f
6434	386	f
6435	386	f
6437	387	f
6438	387	f
6439	387	f
6440	387	f
6441	387	f
6444	387	f
6447	387	f
6448	387	f
6449	387	f
6450	387	f
6452	388	f
6453	388	f
6454	388	f
6455	388	f
6456	388	f
6458	388	f
6459	388	f
6460	388	f
6463	388	f
6464	388	f
6465	388	f
6466	388	f
6467	388	f
6469	388	f
6470	388	f
6471	389	f
6475	389	f
6476	389	f
6477	389	f
6479	389	f
6480	389	f
6482	389	f
6483	389	f
6484	389	f
6486	390	f
6487	390	f
6488	390	f
6489	390	f
6491	390	f
6492	390	f
6493	390	f
6495	390	f
6496	390	f
6497	390	f
6498	390	f
6499	390	f
6500	390	f
6502	391	f
6504	391	f
6507	391	f
6510	391	f
6511	391	f
6513	391	f
6516	391	f
6517	391	f
6519	391	f
6521	392	f
6522	392	f
6523	392	f
6524	392	f
6526	392	f
6527	392	f
6529	392	f
6531	392	f
6532	392	f
6533	392	f
6534	392	f
6535	392	f
6536	393	f
6537	393	f
6538	393	f
6540	393	f
6542	393	f
6543	393	f
6545	393	f
6548	393	f
6549	393	f
6550	393	f
6551	394	f
6552	394	f
6553	394	f
6554	394	f
6555	394	f
6556	394	f
6557	394	f
6558	394	f
6559	394	f
6560	394	f
6562	394	f
6563	394	f
6564	394	f
6565	394	f
6567	394	f
6568	394	f
6569	394	f
6570	394	f
6572	395	f
6573	395	f
6574	395	f
6577	395	f
6578	395	f
6580	395	f
6581	395	f
6582	395	f
6583	395	f
6584	395	f
6585	395	f
6586	396	f
6587	396	f
6589	396	f
6590	396	f
6591	396	f
6592	396	f
6593	396	f
6594	396	f
6595	396	f
6596	396	f
6598	396	f
6599	396	f
6600	396	f
6601	397	f
6602	397	f
6603	397	f
6604	397	f
6605	397	f
6606	397	f
6607	397	f
6608	397	f
6609	397	f
6610	397	f
6611	397	f
6613	397	f
6614	397	f
6615	397	f
6616	397	f
6617	397	f
6618	397	f
6619	397	f
6620	397	f
6621	398	f
6622	398	f
6625	398	f
6626	398	f
6627	398	f
6628	398	f
6630	398	f
6632	398	f
6633	398	f
6634	398	f
6636	399	f
6637	399	f
6639	399	f
6640	399	f
6641	399	f
6642	399	f
6643	399	f
6644	399	f
6645	399	f
6646	399	f
6649	399	f
6652	400	f
6653	400	f
6654	400	f
6655	400	f
6656	400	f
6657	400	f
6659	400	f
6660	400	f
6662	400	f
6664	400	f
6665	400	f
6666	400	f
6667	400	f
6669	400	f
58	4	t
\.


--
-- Data for Name: velo_loue; Type: TABLE DATA; Schema: public; Owner: fredo
--

COPY velo_loue (id, elec) FROM stdin;
1179	t
314	t
1262	t
1392	t
1177	t
536	t
811	t
300	t
1480	t
1084	t
810	t
1420	t
230	t
328	t
1335	t
1265	t
1021	t
768	t
801	t
815	t
439	t
1183	t
951	t
112	t
125	t
540	t
36	t
781	t
588	t
717	t
1236	t
432	t
704	t
1449	t
622	t
519	t
1418	t
476	t
312	t
1370	t
730	t
708	t
668	t
758	t
521	t
423	t
60	t
1380	t
1433	t
1201	t
578	t
88	t
914	t
852	t
803	t
130	t
563	t
847	t
406	t
680	t
1407	t
670	t
518	t
778	t
1095	t
1356	t
220	t
443	t
1279	t
1351	t
321	t
724	t
714	t
5340	f
934	t
1120	t
6515	f
1575	t
3543	f
3560	f
1615	t
428	t
6386	f
4533	f
1176	t
1238	t
3943	f
4463	f
404	t
1713	t
4490	f
3770	f
1986	t
1740	t
2415	f
4389	f
4431	f
4460	f
1852	t
4221	f
5200	f
2581	f
1232	t
5278	f
4619	f
820	t
2905	f
935	t
4896	f
3020	f
4891	f
1403	t
1358	t
237	t
3084	f
5320	f
1835	t
6387	f
6107	f
4407	f
6429	f
5115	f
6474	f
4280	f
1736	t
3669	f
4978	f
2189	f
5587	f
4211	f
6378	f
5760	f
4854	f
6576	f
2429	f
6258	f
5616	f
5456	f
5742	f
806	t
2561	f
3114	f
2135	f
3858	f
6561	f
2174	f
2708	f
2567	f
2954	f
3173	f
4811	f
3016	f
1481	t
4252	f
3052	f
3826	f
2821	f
163	t
256	t
3372	f
6064	f
2221	f
4340	f
1472	t
1171	t
1505	t
638	t
1426	t
3704	f
3207	f
5440	f
123	t
98	t
1275	t
3201	f
5405	f
5946	f
3394	f
2315	f
1000	t
5019	f
293	t
5945	f
2308	f
397	t
816	t
4831	f
4451	f
1198	t
2520	f
3653	f
5558	f
2115	f
1733	t
3831	f
1947	t
2019	f
890	t
1453	t
6451	f
1312	t
1385	t
687	t
6026	f
5532	f
4486	f
3003	f
2362	f
6116	f
755	t
4299	f
3035	f
3344	f
5816	f
792	t
1754	t
3399	f
6462	f
6077	f
4865	f
3001	f
6571	f
2815	f
6003	f
2558	f
729	t
1510	t
4815	f
3356	f
83	t
2273	f
2589	f
4566	f
5559	f
861	t
5985	f
3547	f
2163	f
1809	t
132	t
1374	t
5202	f
6072	f
5762	f
3452	f
6180	f
2870	f
788	t
1298	t
5061	f
3767	f
6539	f
1401	t
433	t
329	t
4944	f
2451	f
4410	f
2522	f
4662	f
4588	f
5730	f
4911	f
6650	f
6623	f
3711	f
4895	f
749	t
4396	f
1911	t
1093	t
919	t
5949	f
684	t
3673	f
1566	t
3199	f
5611	f
9	t
1294	t
1313	t
999	t
5712	f
4472	f
6575	f
3813	f
1670	t
4892	f
5902	f
3729	f
2412	f
2977	f
5548	f
6588	f
4779	f
6022	f
754	t
3900	f
5518	f
4499	f
5302	f
1560	t
6395	f
3628	f
2709	f
348	t
3689	f
5854	f
2389	f
104	t
4011	f
707	t
6396	f
876	t
5848	f
4411	f
957	t
4948	f
2542	f
2969	f
141	t
1912	t
4505	f
1286	t
3390	f
3542	f
3790	f
5389	f
1596	t
341	t
2667	f
6461	f
2144	f
1447	t
1346	t
4223	f
579	t
1258	t
3824	f
4699	f
3092	f
2526	f
4730	f
5315	f
2817	f
6340	f
1926	t
6494	f
3123	f
5162	f
3424	f
881	t
2191	f
4528	f
5634	f
6372	f
2235	f
4780	f
250	t
1546	t
5211	f
710	t
1811	t
1458	t
987	t
932	t
5931	f
3425	f
4565	f
268	t
2717	f
4687	f
718	t
4666	f
4759	f
5114	f
3878	f
1961	t
3335	f
5647	f
613	t
146	t
4567	f
3846	f
3622	f
1229	t
1248	t
5603	f
5403	f
13	t
5788	f
4013	f
3970	f
531	t
1168	t
5690	f
6407	f
4739	f
3412	f
3676	f
6099	f
1953	t
6286	f
3321	f
122	t
3748	f
5263	f
4572	f
2179	f
1101	t
5066	f
3165	f
4436	f
4161	f
4072	f
4339	f
5159	f
5442	f
3223	f
1525	t
3789	f
2559	f
3691	f
2166	f
6048	f
448	t
3241	f
3885	f
6631	f
3037	f
5687	f
5582	f
6546	f
3540	f
5846	f
2874	f
6323	f
3115	f
3520	f
3013	f
6445	f
4043	f
6315	f
1305	t
3661	f
2696	f
1509	t
1918	t
3873	f
5747	f
469	t
1115	t
5519	f
6343	f
1192	t
3196	f
4913	f
1142	t
2422	f
5914	f
1574	t
1611	t
4538	f
3206	f
3443	f
2029	f
77	t
5818	f
5833	f
6150	f
4914	f
2984	f
4267	f
871	t
3010	f
980	t
5445	f
4555	f
1308	t
2173	f
116	t
6012	f
5448	f
6512	f
4919	f
4850	f
5079	f
6430	f
213	t
5178	f
5620	f
5349	f
3805	f
5574	f
2121	f
735	t
6490	f
1512	t
5698	f
1761	t
2036	f
4151	f
5993	f
767	t
347	t
2940	f
2082	f
4788	f
350	t
5303	f
5433	f
2271	f
1886	t
6221	f
5296	f
3860	f
5649	f
4808	f
2903	f
5242	f
3329	f
184	t
5009	f
6544	f
6291	f
2620	f
1350	t
5286	f
5085	f
1162	t
459	t
6647	f
5261	f
3441	f
4763	f
5942	f
2674	f
6223	f
408	t
4750	f
915	t
4558	f
3797	f
4052	f
2626	f
6127	f
1290	t
4774	f
2455	f
2165	f
5904	f
4550	f
4836	f
4753	f
2187	f
4170	f
5150	f
4793	f
4841	f
6525	f
2502	f
5457	f
4938	f
1033	t
2045	f
1417	t
1027	t
856	t
4542	f
4090	f
488	t
5962	f
1904	t
4893	f
1485	t
243	t
4075	f
964	t
1550	t
196	t
6052	f
6201	f
2883	f
167	t
4409	f
5455	f
6021	f
1096	t
4898	f
5784	f
5373	f
2764	f
1411	t
5011	f
2532	f
2102	f
1881	t
3484	f
3231	f
5956	f
1971	t
2407	f
6597	f
182	t
1808	t
5749	f
4864	f
4352	f
976	t
5386	f
264	t
52	t
2367	f
4848	f
4166	f
1858	t
5711	f
4945	f
2507	f
877	t
5105	f
3750	f
4026	f
2865	f
944	t
573	t
5298	f
1804	t
2565	f
6094	f
4190	f
5696	f
1844	t
1255	t
5607	f
2068	f
672	t
4173	f
5313	f
3592	f
3990	f
5589	f
2692	f
2713	f
4117	f
4354	f
4853	f
6505	f
4249	f
700	t
5037	f
2106	f
6075	f
5600	f
740	t
1899	t
3043	f
1379	t
1338	t
260	t
965	t
54	t
1786	t
3919	f
4778	f
6089	f
4424	f
3766	f
2227	f
3630	f
4705	f
2531	f
175	t
3192	f
1990	t
1062	t
5838	f
1640	t
1427	t
5796	f
2814	f
907	t
553	t
1584	t
3688	f
4084	f
1738	t
2353	f
1541	t
1752	t
4725	f
557	t
6138	f
1631	t
257	t
2023	f
2436	f
4733	f
1455	t
1390	t
2926	f
2555	f
1677	t
541	t
2434	f
3649	f
812	t
5025	f
3239	f
6442	f
5775	f
2800	f
6163	f
5350	f
5948	f
4672	f
1727	t
2456	f
2716	f
15	t
731	t
2228	f
1204	t
805	t
5652	f
407	t
3346	f
4234	f
5688	f
2324	f
782	t
6149	f
1034	t
4637	f
1377	t
4882	f
5421	f
6294	f
4192	f
2393	f
2848	f
997	t
1982	t
4270	f
4885	f
1170	t
1366	t
2134	f
3524	f
4837	f
3170	f
1139	t
5772	f
1364	t
242	t
2184	f
4332	f
1	t
136	t
869	t
5441	f
1724	t
2057	f
5210	f
4051	f
1656	t
5773	f
1897	t
5452	f
4067	f
5660	f
465	t
6349	f
5486	f
94	t
5483	f
2751	f
6216	f
1577	t
5309	f
4964	f
649	t
4024	f
608	t
6123	f
3466	f
5219	f
3945	f
2395	f
3379	f
1999	t
1445	t
2052	f
1966	t
3904	f
2461	f
2788	f
899	t
2730	f
1520	t
5630	f
2925	f
545	t
95	t
352	t
4434	f
3700	f
5183	f
3703	f
2715	f
6179	f
2162	f
3146	f
1244	t
4719	f
5612	f
6276	f
2582	f
4531	f
3639	f
396	t
6008	f
6184	f
1145	t
3641	f
5090	f
4962	f
3415	f
3802	f
645	t
1709	t
5128	f
379	t
1301	t
3960	f
6485	f
1028	t
6473	f
512	t
5103	f
2921	f
2014	f
3803	f
1477	t
4835	f
2066	f
3909	f
6332	f
4751	f
751	t
1979	t
4727	f
5740	f
468	t
1567	t
6629	f
4941	f
5826	f
2622	f
2150	f
5937	f
4628	f
2488	f
2126	f
5346	f
2904	f
2922	f
3233	f
3898	f
2963	f
5683	f
618	t
2539	f
5244	f
292	t
5021	f
5597	f
2769	f
454	t
1968	t
4363	f
2849	f
3948	f
4240	f
5067	f
5322	f
3601	f
3011	f
431	t
5341	f
344	t
3553	f
5227	f
164	t
3754	f
178	t
479	t
4395	f
882	t
669	t
6635	f
6081	f
6306	f
4148	f
6514	f
2766	f
336	t
274	t
4989	f
155	t
2649	f
5112	f
3208	f
1522	t
4618	f
247	t
1878	t
4248	f
2933	f
2394	f
5069	f
2879	f
315	t
3028	f
1277	t
6541	f
2616	f
913	t
5017	f
4832	f
6009	f
4920	f
5503	f
5669	f
6144	f
4074	f
4070	f
5319	f
565	t
4471	f
4692	f
3416	f
3589	f
4194	f
828	t
1247	t
3605	f
2060	f
1629	t
4526	f
3585	f
2050	f
3368	f
4219	f
1877	t
4056	f
2869	f
3121	f
4266	f
5471	f
3863	f
3324	f
2088	f
113	t
4591	f
3171	f
2234	f
1737	t
5646	f
188	t
3144	f
6624	f
6528	f
4744	f
6067	f
5428	f
339	t
2695	f
5637	f
6256	f
4787	f
2629	f
4016	f
4330	f
3842	f
445	t
2161	f
3355	f
2941	f
4607	f
3418	f
3099	f
3471	f
295	t
2012	f
5199	f
1077	t
905	t
2680	f
1303	t
4121	f
2072	f
126	t
3495	f
6368	f
1592	t
676	t
3930	f
1428	t
1273	t
3106	f
4970	f
874	t
6468	f
5834	f
2602	f
3532	f
2421	f
5295	f
4806	f
4996	f
2423	f
1409	t
1617	t
5550	f
5763	f
2631	f
6579	f
3875	f
4239	f
56	t
6367	f
2011	f
5393	f
3450	f
3248	f
4677	f
157	t
2238	f
3370	f
2116	f
3209	f
600	t
3527	f
3667	f
81	t
4427	f
6364	f
3854	f
215	t
6296	f
1641	t
3156	f
3301	f
1607	t
3491	f
1199	t
310	t
538	t
1551	t
2486	f
4415	f
4673	f
2208	f
3537	f
1025	t
1487	t
42	t
1462	t
6243	f
6661	f
2535	f
128	t
2013	f
2605	f
280	t
3467	f
2779	f
2967	f
5095	f
4928	f
2214	f
4995	f
4829	f
3577	f
2710	f
692	t
2554	f
4483	f
6266	f
4700	f
4233	f
114	t
6039	f
2448	f
4374	f
3608	f
5398	f
2978	f
319	t
6086	f
3230	f
3611	f
562	t
\.


--
-- Name: centre_reparation_pkey; Type: CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY centre_reparation
    ADD CONSTRAINT centre_reparation_pkey PRIMARY KEY (id_centre);


--
-- Name: signale_pkey; Type: CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY signale
    ADD CONSTRAINT signale_pkey PRIMARY KEY (id_users, id_velo);


--
-- Name: station_pkey; Type: CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY station
    ADD CONSTRAINT station_pkey PRIMARY KEY (id);


--
-- Name: trajet_pkey; Type: CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY trajet
    ADD CONSTRAINT trajet_pkey PRIMARY KEY (id_trajet);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id_user);


--
-- Name: velo_casse_pkey; Type: CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY velo_casse
    ADD CONSTRAINT velo_casse_pkey PRIMARY KEY (id);


--
-- Name: velo_dispo_pkey; Type: CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY velo_dispo
    ADD CONSTRAINT velo_dispo_pkey PRIMARY KEY (id);


--
-- Name: velo_loue_pkey; Type: CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY velo_loue
    ADD CONSTRAINT velo_loue_pkey PRIMARY KEY (id);


--
-- Name: after_insert; Type: TRIGGER; Schema: public; Owner: fredo
--

CREATE TRIGGER after_insert AFTER INSERT ON velo_dispo FOR EACH ROW EXECUTE PROCEDURE after_insert();


--
-- Name: after_veloc; Type: TRIGGER; Schema: public; Owner: fredo
--

CREATE TRIGGER after_veloc AFTER INSERT ON velo_casse FOR EACH ROW EXECUTE PROCEDURE after_veloc();

ALTER TABLE velo_casse DISABLE TRIGGER after_veloc;


--
-- Name: before_delete; Type: TRIGGER; Schema: public; Owner: fredo
--

CREATE TRIGGER before_delete BEFORE DELETE ON velo_dispo FOR EACH ROW EXECUTE PROCEDURE before_delete();


--
-- Name: before_velod; Type: TRIGGER; Schema: public; Owner: fredo
--

CREATE TRIGGER before_velod BEFORE INSERT ON velo_dispo FOR EACH ROW EXECUTE PROCEDURE before_velod();


--
-- Name: cout; Type: TRIGGER; Schema: public; Owner: fredo
--

CREATE TRIGGER cout AFTER INSERT ON trajet FOR EACH ROW EXECUTE PROCEDURE cout();


--
-- Name: credit; Type: TRIGGER; Schema: public; Owner: fredo
--

CREATE TRIGGER credit BEFORE INSERT ON trajet FOR EACH ROW EXECUTE PROCEDURE credit();


--
-- Name: delete_veloc; Type: TRIGGER; Schema: public; Owner: fredo
--

CREATE TRIGGER delete_veloc AFTER DELETE ON velo_casse FOR EACH ROW EXECUTE PROCEDURE delete_veloc();

ALTER TABLE velo_casse DISABLE TRIGGER delete_veloc;


--
-- Name: signale_id_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY signale
    ADD CONSTRAINT signale_id_users_fkey FOREIGN KEY (id_users) REFERENCES users(id_user) ON DELETE CASCADE;


--
-- Name: signale_id_velo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY signale
    ADD CONSTRAINT signale_id_velo_fkey FOREIGN KEY (id_velo) REFERENCES velo_casse(id);


--
-- Name: trajet_id_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY trajet
    ADD CONSTRAINT trajet_id_users_fkey FOREIGN KEY (id_users) REFERENCES users(id_user) ON DELETE CASCADE;


--
-- Name: trajet_station_arr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY trajet
    ADD CONSTRAINT trajet_station_arr_fkey FOREIGN KEY (station_arr) REFERENCES station(id) ON DELETE CASCADE;


--
-- Name: trajet_station_dep_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY trajet
    ADD CONSTRAINT trajet_station_dep_fkey FOREIGN KEY (station_arr) REFERENCES station(id) ON DELETE CASCADE;


--
-- Name: velo_casse_id_centres_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY velo_casse
    ADD CONSTRAINT velo_casse_id_centres_fkey FOREIGN KEY (id_centres) REFERENCES centre_reparation(id_centre) ON DELETE CASCADE;


--
-- Name: velo_dispo_id_station_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fredo
--

ALTER TABLE ONLY velo_dispo
    ADD CONSTRAINT velo_dispo_id_station_fkey FOREIGN KEY (id_station) REFERENCES station(id);


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

