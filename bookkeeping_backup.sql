--
-- PostgreSQL database dump
--

\restrict oRSgkdMq64lDV0WK9TYMBWHuuJ36Qif839Pffbr5MdVVuveFOqe6elpSCrPqdz1

-- Dumped from database version 14.19 (Homebrew)
-- Dumped by pg_dump version 14.19 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: jean
--

CREATE TABLE public.accounts (
    account_id integer NOT NULL,
    coa_id integer,
    code character varying(50) NOT NULL,
    number character varying(50),
    description character varying(255),
    dc character(1),
    level integer,
    parent_code character varying(50),
    is_active boolean DEFAULT true,
    CONSTRAINT accounts_dc_check CHECK ((dc = ANY (ARRAY['D'::bpchar, 'C'::bpchar])))
);


ALTER TABLE public.accounts OWNER TO jean;

--
-- Name: accounts_account_id_seq; Type: SEQUENCE; Schema: public; Owner: jean
--

CREATE SEQUENCE public.accounts_account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounts_account_id_seq OWNER TO jean;

--
-- Name: accounts_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jean
--

ALTER SEQUENCE public.accounts_account_id_seq OWNED BY public.accounts.account_id;


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: jean
--

CREATE TABLE public.bookings (
    id integer NOT NULL,
    invoice_id text NOT NULL,
    account_code text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    confidence_score numeric
);


ALTER TABLE public.bookings OWNER TO jean;

--
-- Name: bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: jean
--

CREATE SEQUENCE public.bookings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bookings_id_seq OWNER TO jean;

--
-- Name: bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jean
--

ALTER SEQUENCE public.bookings_id_seq OWNED BY public.bookings.id;


--
-- Name: coa; Type: TABLE; Schema: public; Owner: jean
--

CREATE TABLE public.coa (
    number character varying(50),
    description character varying(255),
    parent_code character varying(50),
    level integer
);


ALTER TABLE public.coa OWNER TO jean;

--
-- Name: coa_definitions; Type: TABLE; Schema: public; Owner: jean
--

CREATE TABLE public.coa_definitions (
    coa_id integer NOT NULL,
    name character varying(100) NOT NULL,
    country character varying(50),
    version character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.coa_definitions OWNER TO jean;

--
-- Name: coa_definitions_coa_id_seq; Type: SEQUENCE; Schema: public; Owner: jean
--

CREATE SEQUENCE public.coa_definitions_coa_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.coa_definitions_coa_id_seq OWNER TO jean;

--
-- Name: coa_definitions_coa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jean
--

ALTER SEQUENCE public.coa_definitions_coa_id_seq OWNED BY public.coa_definitions.coa_id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: jean
--

CREATE TABLE public.companies (
    company_id integer NOT NULL,
    name character varying(255) NOT NULL,
    kvk_number character varying(50),
    vat_number character varying(50),
    coa_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.companies OWNER TO jean;

--
-- Name: companies_company_id_seq; Type: SEQUENCE; Schema: public; Owner: jean
--

CREATE SEQUENCE public.companies_company_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.companies_company_id_seq OWNER TO jean;

--
-- Name: companies_company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jean
--

ALTER SEQUENCE public.companies_company_id_seq OWNED BY public.companies.company_id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: jean
--

CREATE TABLE public.invoices (
    invoice_number text NOT NULL,
    sender_company text,
    sender_address text,
    sender_vat text,
    sender_kvk text,
    sender_iban text,
    receiver_company text,
    receiver_address text,
    receiver_vat text,
    invoice_date date,
    due_date date,
    payment_terms text,
    reference text,
    subtotal numeric,
    vat numeric,
    total numeric,
    currency text,
    notes text
);


ALTER TABLE public.invoices OWNER TO jean;

--
-- Name: line_items; Type: TABLE; Schema: public; Owner: jean
--

CREATE TABLE public.line_items (
    id integer NOT NULL,
    invoice_number text,
    description text,
    quantity numeric,
    unit_price numeric,
    line_total numeric
);


ALTER TABLE public.line_items OWNER TO jean;

--
-- Name: line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: jean
--

CREATE SEQUENCE public.line_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.line_items_id_seq OWNER TO jean;

--
-- Name: line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jean
--

ALTER SEQUENCE public.line_items_id_seq OWNED BY public.line_items.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: jean
--

CREATE TABLE public.transactions (
    transaction_id integer NOT NULL,
    company_id integer,
    account_id integer,
    date date NOT NULL,
    description text,
    debit numeric(12,2) DEFAULT 0,
    credit numeric(12,2) DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.transactions OWNER TO jean;

--
-- Name: transactions_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: jean
--

CREATE SEQUENCE public.transactions_transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transactions_transaction_id_seq OWNER TO jean;

--
-- Name: transactions_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jean
--

ALTER SEQUENCE public.transactions_transaction_id_seq OWNED BY public.transactions.transaction_id;


--
-- Name: accounts account_id; Type: DEFAULT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.accounts ALTER COLUMN account_id SET DEFAULT nextval('public.accounts_account_id_seq'::regclass);


--
-- Name: bookings id; Type: DEFAULT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.bookings ALTER COLUMN id SET DEFAULT nextval('public.bookings_id_seq'::regclass);


--
-- Name: coa_definitions coa_id; Type: DEFAULT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.coa_definitions ALTER COLUMN coa_id SET DEFAULT nextval('public.coa_definitions_coa_id_seq'::regclass);


--
-- Name: companies company_id; Type: DEFAULT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.companies ALTER COLUMN company_id SET DEFAULT nextval('public.companies_company_id_seq'::regclass);


--
-- Name: line_items id; Type: DEFAULT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.line_items ALTER COLUMN id SET DEFAULT nextval('public.line_items_id_seq'::regclass);


--
-- Name: transactions transaction_id; Type: DEFAULT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.transactions ALTER COLUMN transaction_id SET DEFAULT nextval('public.transactions_transaction_id_seq'::regclass);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY public.accounts (account_id, coa_id, code, number, description, dc, level, parent_code, is_active) FROM stdin;
1	1	B	\N	BALANS	\N	1	\N	t
2	1	BIva	01	Immateriële vaste activa	D	2	\N	t
3	1	BIvaKou	0101000	Kosten van oprichting en van uitgifte van aandelen	D	3	\N	t
4	1	BIvaKouVvp	0101010	Verkrijgings- of vervaardigingsprijs kosten van oprichting en van uitgifte van aandelen	D	4	\N	t
5	1	BIvaKouVvpBeg	0101010.01	Beginbalans (overname eindsaldo vorig jaar) kosten van oprichting en van uitgifte van aandelen	D	5	\N	t
6	1	BIvaKouVvpInv	0101010.02	Investeringen kosten van oprichting en van uitgifte van aandelen	D	5	\N	t
7	1	BIvaKouVvpAdo	0101010.03	Bij overname verkregen activa kosten van oprichting en van uitgifte van aandelen	D	5	\N	t
8	1	BIvaKouVvpDes	0101010.04	Desinvesteringen kosten van oprichting en van uitgifte van aandelen	C	5	\N	t
9	1	BIvaKouVvpDda	0101010.05	Afstotingen kosten van oprichting en van uitgifte van aandelen	C	5	\N	t
10	1	BIvaKouVvpOmv	0101010.06	Omrekeningsverschillen kosten van oprichting en van uitgifte van aandelen	D	5	\N	t
11	1	BIvaKouVvpOvm	0101010.07	Overige mutaties kosten van oprichting en van uitgifte van aandelen	D	5	\N	t
12	1	BIvaKouAkp	101015	Actuele kostprijs kosten van oprichting en van uitgifte van aandelen	D	4	\N	t
13	1	BIvaKouAkpBeg	0101015.01	Beginbalans (overname eindsaldo vorig jaar) kosten van oprichting en van uitgifte van aandelen	D	5	\N	t
14	1	BIvaKouAkpInv	0101015.02	Investeringen kosten van oprichting en van uitgifte van aandelen	D	5	\N	t
15	1	BIvaKouAkpAdo	0101015.03	Bij overname verkregen activa kosten van oprichting en van uitgifte van aandelen	D	5	\N	t
16	1	BIvaKouAkpDes	0101015.04	Desinvesteringen kosten van oprichting en van uitgifte van aandelen	C	5	\N	t
17	1	BIvaKouAkpDda	0101015.05	Afstotingen kosten van oprichting en van uitgifte van aandelen	C	5	\N	t
18	1	BIvaKouAkpOmv	0101015.06	Omrekeningsverschillen kosten van oprichting en van uitgifte van aandelen	D	5	\N	t
19	1	BIvaKouAkpOvm	0101015.07	Overige mutaties kosten van oprichting en van uitgifte van aandelen	D	5	\N	t
20	1	BIvaKouCae	0101020	Cumulatieve afschrijvingen en waardeverminderingen kosten van oprichting en van uitgifte van aandelen	C	4	\N	t
21	1	BIvaKouCaeBeg	0101020.01	Beginbalans (overname eindsaldo vorig jaar) kosten van oprichting en van uitgifte van aandelen	C	5	\N	t
22	1	BIvaKouCaeAfs	0101020.02	Afschrijvingen kosten van oprichting en van uitgifte van aandelen	C	5	\N	t
23	1	BIvaKouCaeDca	0101020.03	Afschrijving op desinvesteringen kosten van oprichting en van uitgifte van aandelen	D	5	\N	t
24	1	BIvaKouCaeWvr	0101020.04	Bijzondere waardeverminderingen kosten van oprichting en van uitgifte van aandelen	C	5	\N	t
25	1	BIvaKouCaeTvw	0101020.05	Terugneming van bijzondere waardeverminderingen kosten van oprichting en van uitgifte van aandelen	D	5	\N	t
26	1	BIvaKouCuh	0101030	Cumulatieve herwaarderingen kosten van oprichting en van uitgifte van aandelen	D	4	\N	t
27	1	BIvaKouCuhBeg	0101030.01	Beginbalans (overname eindsaldo vorig jaar) kosten van oprichting en van uitgifte van aandelen	D	5	\N	t
28	1	BIvaKouCuhHer	0101030.02	Herwaarderingen kosten van oprichting en van uitgifte van aandelen	D	5	\N	t
29	1	BIvaKouCuhAfh	0101030.03	Afschrijving herwaarderingen kosten van oprichting en van uitgifte van aandelen	C	5	\N	t
30	1	BIvaKouCuhDeh	0101030.04	Desinvestering herwaarderingen kosten van oprichting en van uitgifte van aandelen	C	5	\N	t
31	1	BIvaKoo	0102000	Kosten van ontwikkeling	D	3	\N	t
32	1	BIvaKooVvp	0102010	Verkrijgings- of vervaardigingsprijs kosten van ontwikkeling	D	4	\N	t
33	1	BIvaKooVvpBeg	0102010.01	Beginbalans (overname eindsaldo vorig jaar) kosten van ontwikkeling	D	5	\N	t
34	1	BIvaKooVvpInv	0102010.02	Investeringen kosten van ontwikkeling	D	5	\N	t
35	1	BIvaKooVvpAdo	0102010.03	Bij overname verkregen activa kosten van ontwikkeling	D	5	\N	t
36	1	BIvaKooVvpDes	0102010.04	Desinvesteringen kosten van ontwikkeling	C	5	\N	t
37	1	BIvaKooVvpDda	0102010.05	Afstotingen kosten van ontwikkeling	C	5	\N	t
38	1	BIvaKooVvpOmv	0102010.06	Omrekeningsverschillen kosten van ontwikkeling	D	5	\N	t
39	1	BIvaKooVvpOvm	0102010.07	Overige mutaties kosten van ontwikkeling	D	5	\N	t
40	1	BIvaKooAkp	102015	Actuele kostprijs kosten van ontwikkeling	D	4	\N	t
41	1	BIvaKooAkpBeg	0102015.01	Beginbalans (overname eindsaldo vorig jaar) kosten van ontwikkeling	D	5	\N	t
42	1	BIvaKooAkpInv	0102015.02	Investeringen kosten van ontwikkeling	D	5	\N	t
43	1	BIvaKooAkpAdo	0102015.03	Bij overname verkregen activa kosten van ontwikkeling	D	5	\N	t
44	1	BIvaKooAkpDes	0102015.04	Desinvesteringen kosten van ontwikkeling	C	5	\N	t
45	1	BIvaKooAkpDda	0102015.05	Afstotingen kosten van ontwikkeling	C	5	\N	t
46	1	BIvaKooAkpOmv	0102015.06	Omrekeningsverschillen kosten van ontwikkeling	D	5	\N	t
47	1	BIvaKooAkpOvm	0102015.07	Overige mutaties kosten van ontwikkeling	D	5	\N	t
48	1	BIvaKooCae	0102020	Cumulatieve afschrijvingen en waardeverminderingen kosten van ontwikkeling	C	4	\N	t
49	1	BIvaKooCaeBeg	0102020.01	Beginbalans (overname eindsaldo vorig jaar) kosten van ontwikkeling	C	5	\N	t
50	1	BIvaKooCaeAfs	0102020.02	Afschrijvingen kosten van ontwikkeling	C	5	\N	t
51	1	BIvaKooCaeDca	0102020.03	Afschrijving op desinvesteringen kosten van ontwikkeling	D	5	\N	t
52	1	BIvaKooCaeWvr	0102020.04	Bijzondere waardeverminderingen kosten van ontwikkeling	C	5	\N	t
53	1	BIvaKooCaeTvw	0102020.05	Terugneming van bijzondere waardeverminderingen kosten van ontwikkeling	D	5	\N	t
54	1	BIvaKooCuh	0102030	Cumulatieve herwaarderingen kosten van ontwikkeling	D	4	\N	t
55	1	BIvaKooCuhBeg	0102030.01	Beginbalans (overname eindsaldo vorig jaar) kosten van ontwikkeling	D	5	\N	t
56	1	BIvaKooCuhHer	0102030.02	Herwaarderingen kosten van ontwikkeling	D	5	\N	t
239	1	BMvaBeg	0202000	Bedrijfsgebouwen	D	3	\N	t
57	1	BIvaKooCuhAfh	0102030.03	Afschrijving herwaarderingen kosten van ontwikkeling	C	5	\N	t
58	1	BIvaKooCuhDeh	0102030.04	Desinvestering herwaarderingen kosten van ontwikkeling	C	5	\N	t
59	1	BIvaCev	0106000	Concessies, vergunningen en intellectuele eigendom	D	3	\N	t
60	1	BIvaCevVvp	0106010	Verkrijgings- of vervaardigingsprijs concessies, vergunningen en intellectuele eigendom	D	4	\N	t
61	1	BIvaCevVvpBeg	0106010.01	Beginbalans (overname eindsaldo vorig jaar) concessies, vergunningen en intellectuele eigendom	D	5	\N	t
62	1	BIvaCevVvpInv	0106010.02	Investeringen concessies, vergunningen en intellectuele eigendom	D	5	\N	t
63	1	BIvaCevVvpAdo	0106010.03	Bij overname verkregen activa concessies, vergunningen en intellectuele eigendom	D	5	\N	t
64	1	BIvaCevVvpDes	0106010.04	Desinvesteringen concessies, vergunningen en intellectuele eigendom	C	5	\N	t
65	1	BIvaCevVvpDda	0106010.05	Afstotingen concessies, vergunningen en intellectuele eigendom	C	5	\N	t
66	1	BIvaCevVvpOmv	0106010.06	Omrekeningsverschillen concessies, vergunningen en intellectuele eigendom	D	5	\N	t
67	1	BIvaCevVvpOvm	0106010.07	Overige mutaties concessies, vergunningen en intellectuele eigendom	D	5	\N	t
68	1	BIvaCevAkp	106015	Actuele kostprijs concessies, vergunningen en intellectuele eigendom	D	4	\N	t
69	1	BIvaCevAkpBeg	0106015.01	Beginbalans (overname eindsaldo vorig jaar) concessies, vergunningen en intellectuele eigendom	D	5	\N	t
70	1	BIvaCevAkpInv	0106015.02	Investeringen concessies, vergunningen en intellectuele eigendom	D	5	\N	t
71	1	BIvaCevAkpAdo	0106015.03	Bij overname verkregen activa concessies, vergunningen en intellectuele eigendom	D	5	\N	t
72	1	BIvaCevAkpDes	0106015.04	Desinvesteringen concessies, vergunningen en intellectuele eigendom	C	5	\N	t
73	1	BIvaCevAkpDda	0106015.05	Afstotingen concessies, vergunningen en intellectuele eigendom	C	5	\N	t
74	1	BIvaCevAkpOmv	0106015.06	Omrekeningsverschillen concessies, vergunningen en intellectuele eigendom	D	5	\N	t
75	1	BIvaCevAkpOvm	0106015.07	Overige mutaties concessies, vergunningen en intellectuele eigendom	D	5	\N	t
76	1	BIvaCevCae	0106020	Cumulatieve afschrijvingen en waardeverminderingen concessies, vergunningen en intellectuele eigendom	C	4	\N	t
77	1	BIvaCevCaeBeg	0106020.01	Beginbalans (overname eindsaldo vorig jaar) concessies, vergunningen en intellectuele eigendom	C	5	\N	t
78	1	BIvaCevCaeAfs	0106020.02	Afschrijvingen concessies, vergunningen en intellectuele eigendom	C	5	\N	t
79	1	BIvaCevCaeDca	0106020.03	Afschrijving op desinvesteringen concessies, vergunningen en intellectuele eigendom	D	5	\N	t
80	1	BIvaCevCaeWvr	0106020.04	Bijzondere waardeverminderingen concessies, vergunningen en intellectuele eigendom	C	5	\N	t
81	1	BIvaCevCaeTvw	0106020.05	Terugneming van bijzondere waardeverminderingen concessies, vergunningen en intellectuele eigendom	D	5	\N	t
82	1	BIvaCevCuh	0106030	Cumulatieve herwaarderingen concessies, vergunningen en intellectuele eigendom	D	4	\N	t
83	1	BIvaCevCuhBeg	0106030.01	Beginbalans (overname eindsaldo vorig jaar) concessies, vergunningen en intellectuele eigendom	D	5	\N	t
84	1	BIvaCevCuhHer	0106030.02	Herwaarderingen concessies, vergunningen en intellectuele eigendom	D	5	\N	t
85	1	BIvaCevCuhAfh	0106030.03	Afschrijving herwaarderingen concessies, vergunningen en intellectuele eigendom	C	5	\N	t
86	1	BIvaCevCuhDeh	0106030.04	Desinvestering herwaarderingen concessies, vergunningen en intellectuele eigendom	C	5	\N	t
87	1	BIvaGoo	0107000	Goodwill	D	3	\N	t
88	1	BIvaGooVvp	0107010	Verkrijgings- of vervaardigingsprijs goodwill	D	4	\N	t
89	1	BIvaGooVvpBeg	0107010.01	Beginbalans (overname eindsaldo vorig jaar) goodwill	D	5	\N	t
90	1	BIvaGooVvpInv	0107010.02	Investeringen goodwill	D	5	\N	t
91	1	BIvaGooVvpAdo	0107010.03	Bij overname verkregen activa goodwill	D	5	\N	t
92	1	BIvaGooVvpDes	0107010.04	Desinvesteringen goodwill	C	5	\N	t
93	1	BIvaGooVvpDda	0107010.05	Afstotingen goodwill	C	5	\N	t
94	1	BIvaGooVvpOmv	0107010.06	Omrekeningsverschillen goodwill	D	5	\N	t
95	1	BIvaGooVvpOvm	0107010.07	Overige mutaties goodwill	D	5	\N	t
96	1	BIvaGooAkp	107015	Actuele kostprijs goodwill	D	4	\N	t
97	1	BIvaGooAkpBeg	0107015.01	Beginbalans (overname eindsaldo vorig jaar) goodwill	D	5	\N	t
98	1	BIvaGooAkpInv	0107015.02	Investeringen goodwill	D	5	\N	t
99	1	BIvaGooAkpAdo	0107015.03	Bij overname verkregen activa goodwill	D	5	\N	t
100	1	BIvaGooAkpDes	0107015.04	Desinvesteringen goodwill	C	5	\N	t
101	1	BIvaGooAkpDda	0107015.05	Afstotingen goodwill	C	5	\N	t
102	1	BIvaGooAkpOmv	0107015.06	Omrekeningsverschillen goodwill	D	5	\N	t
103	1	BIvaGooAkpOvm	0107015.07	Overige mutaties goodwill	D	5	\N	t
104	1	BIvaGooCae	0107020	Cumulatieve afschrijvingen en waardeverminderingen goodwill	C	4	\N	t
105	1	BIvaGooCaeBeg	0107020.01	Beginbalans (overname eindsaldo vorig jaar) goodwill	C	5	\N	t
106	1	BIvaGooCaeAfs	0107020.02	Afschrijvingen goodwill	C	5	\N	t
107	1	BIvaGooCaeDca	0107020.03	Afschrijving op desinvesteringen goodwill	D	5	\N	t
108	1	BIvaGooCaeWvr	0107020.04	Bijzondere waardeverminderingen goodwill	C	5	\N	t
109	1	BIvaGooCaeTvw	0107020.05	Terugneming van bijzondere waardeverminderingen goodwill	D	5	\N	t
110	1	BIvaGooCaeOvm	0107020.06	Overige mutaties waardeveranderingen goodwill	D	5	\N	t
111	1	BIvaGooCuh	0107030	Cumulatieve herwaarderingen goodwill	D	4	\N	t
112	1	BIvaGooCuhBeg	0107030.01	Beginbalans (overname eindsaldo vorig jaar) goodwill	D	5	\N	t
113	1	BIvaGooCuhHer	0107030.02	Herwaarderingen goodwill	D	5	\N	t
114	1	BIvaGooCuhAfh	0107030.03	Afschrijving herwaarderingen concessies, goodwill	C	5	\N	t
238	1	BMvaTerCuhOvm	0201030.06	Overige mutaties herwaarderingen terreinen	D	5	\N	t
115	1	BIvaGooCuhAvg	0107030.05	Aanpassingen van de goodwill als gevolg van later geïdentificeerde activa en passiva en veranderingen in de waarde ervan	D	5	\N	t
116	1	BIvaGooCuhDeh	0107030.04	Desinvestering herwaarderingen goodwill	C	5	\N	t
117	1	BIvaVoi	0109000	Vooruitbetalingen op immateriële vaste activa	D	3	\N	t
118	1	BIvaVoiVvp	0109010	Verkrijgings- of vervaardigingsprijs vooruitbetalingen op immateriële vaste activa	D	4	\N	t
119	1	BIvaVoiVvpBeg	0109010.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op immateriële vaste activa	D	5	\N	t
120	1	BIvaVoiVvpInv	0109010.02	Investeringen vooruitbetalingen op immateriële vaste activa	D	5	\N	t
121	1	BIvaVoiVvpAdo	0109010.03	Bij overname verkregen activa vooruitbetalingen op immateriële vaste activa	D	5	\N	t
122	1	BIvaVoiVvpDes	0109010.04	Desinvesteringen vooruitbetalingen op immateriële vaste activa	C	5	\N	t
123	1	BIvaVoiVvpDda	0109010.05	Afstotingen vooruitbetalingen op immateriële vaste activa	C	5	\N	t
124	1	BIvaVoiVvpOmv	0109010.06	Omrekeningsverschillen vooruitbetalingen op immateriële vaste activa	D	5	\N	t
125	1	BIvaVoiVvpOvm	0109010.07	Overige mutaties vooruitbetalingen op immateriële vaste activa	D	5	\N	t
126	1	BIvaVoiAkp	109015	Actuele kostprijs vooruitbetalingen op immateriële vaste activa	D	4	\N	t
127	1	BIvaVoiAkpBeg	0109015.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op immateriële vaste activa	D	5	\N	t
128	1	BIvaVoiAkpInv	0109015.02	Investeringen vooruitbetalingen op immateriële vaste activa	D	5	\N	t
129	1	BIvaVoiAkpAdo	0109015.03	Bij overname verkregen activa vooruitbetalingen op immateriële vaste activa	D	5	\N	t
130	1	BIvaVoiAkpDes	0109015.04	Desinvesteringen vooruitbetalingen op immateriële vaste activa	C	5	\N	t
131	1	BIvaVoiAkpDda	0109015.05	Afstotingen vooruitbetalingen op immateriële vaste activa	C	5	\N	t
132	1	BIvaVoiAkpOmv	0109015.06	Omrekeningsverschillen vooruitbetalingen op immateriële vaste activa	D	5	\N	t
133	1	BIvaVoiAkpOvm	0109015.07	Overige mutaties vooruitbetalingen op immateriële vaste activa	D	5	\N	t
134	1	BIvaVoiCae	0109020	Cumulatieve afschrijvingen en waardeverminderingen vooruitbetalingen op immateriële vaste activa	C	4	\N	t
135	1	BIvaVoiCaeBeg	0109020.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op immateriële vaste activa	C	5	\N	t
136	1	BIvaVoiCaeAfs	0109020.02	Afschrijvingen vooruitbetalingen op immateriële vaste activa	C	5	\N	t
137	1	BIvaVoiCaeDca	0109020.03	Afschrijving op desinvesteringen vooruitbetalingen op immateriële vaste activa	D	5	\N	t
138	1	BIvaVoiCaeWvr	0109020.04	Bijzondere waardeverminderingen vooruitbetalingen op immateriële vaste activa	C	5	\N	t
139	1	BIvaVoiCaeTvw	0109020.05	Terugneming van bijzondere waardeverminderingen vooruitbetalingen op immateriële vaste activa	D	5	\N	t
140	1	BIvaVoiCuh	0109030	Cumulatieve herwaarderingen vooruitbetalingen op immateriële vaste activa	D	4	\N	t
141	1	BIvaVoiCuhBeg	0109030.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op immateriële vaste activa	D	5	\N	t
142	1	BIvaVoiCuhHer	0109030.02	Herwaarderingen vooruitbetalingen op immateriële vaste activa	D	5	\N	t
143	1	BIvaVoiCuhAfh	0109030.03	Afschrijving herwaarderingen vooruitbetalingen op immateriële vaste activa	C	5	\N	t
144	1	BIvaVoiCuhDeh	0109030.04	Desinvestering herwaarderingen vooruitbetalingen op immateriële vaste activa	C	5	\N	t
145	1	BIvaBou	0105000	Bouwclaims	D	3	\N	t
146	1	BIvaBouVvp	0105010	Verkrijgings- of vervaardigingsprijs bouwclaims	D	4	\N	t
147	1	BIvaBouVvpBeg	0105010.01	Beginbalans bouwclaims	D	5	\N	t
148	1	BIvaBouVvpInv	0105010.02	Investeringen bouwclaims	D	5	\N	t
149	1	BIvaBouVvpAdo	0105010.03	Aankopen door overnames bouwclaims	D	5	\N	t
150	1	BIvaBouVvpDes	0105010.04	Desinvesteringen bouwclaims	C	5	\N	t
151	1	BIvaBouVvpDda	0105010.05	Desinvesteringen door afstotingen bouwclaims	C	5	\N	t
152	1	BIvaBouVvpOmv	0105010.06	Omrekeningsverschillen bouwclaims	D	5	\N	t
153	1	BIvaBouVvpOvm	0105010.07	Overige mutaties bouwclaims	D	5	\N	t
154	1	BIvaBouAkp	105015	Actuele kostprijs bouwclaims	D	4	\N	t
155	1	BIvaBouAkpBeg	0105015.01	Beginbalans bouwclaims	D	5	\N	t
156	1	BIvaBouAkpInv	0105015.02	Investeringen bouwclaims	D	5	\N	t
157	1	BIvaBouAkpAdo	0105015.03	Aankopen door overnames bouwclaims	D	5	\N	t
158	1	BIvaBouAkpDes	0105015.04	Desinvesteringen bouwclaims	C	5	\N	t
159	1	BIvaBouAkpDda	0105015.05	Desinvesteringen door afstotingen bouwclaims	C	5	\N	t
160	1	BIvaBouAkpOmv	0105015.06	Omrekeningsverschillen bouwclaims	D	5	\N	t
161	1	BIvaBouAkpOvm	0105015.07	Overige mutaties bouwclaims	D	5	\N	t
162	1	BIvaBouCae	0105020	Cumulatieve afschrijvingen en waardeverminderingen bouwclaims	C	4	\N	t
163	1	BIvaBouCaeBeg	0105020.01	Beginbalans bouwclaims	C	5	\N	t
164	1	BIvaBouCaeAfs	0105020.02	Afschrijvingen bouwclaims	C	5	\N	t
165	1	BIvaBouCaeDca	0105020.03	Desinvestering cumulatieve afschrijvingen en waardeverminderingen bouwclaims	D	5	\N	t
166	1	BIvaBouCaeWvr	0105020.04	Waardeverminderingen bouwclaims	C	5	\N	t
167	1	BIvaBouCaeTvw	0105020.05	Terugneming van waardeverminderingen bouwclaims	D	5	\N	t
168	1	BIvaBouCaeOvm	0105020.06	Overige mutaties waardeveranderingen bouwclaims	D	5	\N	t
169	1	BIvaBouCuh	0105030	Cumulatieve herwaarderingen bouwclaims	D	4	\N	t
170	1	BIvaBouCuhBeg	0105030.01	Beginbalans bouwclaims	D	5	\N	t
171	1	BIvaBouCuhHer	0105030.02	Herwaarderingen bouwclaims	D	5	\N	t
172	1	BIvaBouCuhAfh	0105030.03	Afschrijving herwaarderingen bouwclaims	C	5	\N	t
173	1	BIvaBouCuhDeh	0105030.04	Desinvestering herwaarderingen bouwclaims	C	5	\N	t
174	1	BIvaOiv	0110000	Overige immateriële vaste activa	D	3	\N	t
175	1	BIvaOivVvp	0110010	Verkrijgings- of vervaardigingsprijs overige immateriële vaste activa	D	4	\N	t
176	1	BIvaOivVvpBeg	0110010.01	Beginbalans (overname eindsaldo vorig jaar) overige immateriële vaste activa	D	5	\N	t
177	1	BIvaOivVvpInv	0110010.02	Investeringen overige immateriële vaste activa	D	5	\N	t
178	1	BIvaOivVvpAdo	0110010.03	Bij overname verkregen activa overige immateriële vaste activa	D	5	\N	t
179	1	BIvaOivVvpDes	0110010.04	Desinvesteringen overige immateriële vaste activa	C	5	\N	t
180	1	BIvaOivVvpDda	0110010.05	Afstotingen overige immateriële vaste activa	C	5	\N	t
181	1	BIvaOivVvpOmv	0110010.06	Omrekeningsverschillen overige immateriële vaste activa	D	5	\N	t
182	1	BIvaOivVvpOvm	0110010.07	Overige mutaties overige immateriële vaste activa	D	5	\N	t
183	1	BIvaOivAkp	110015	Actuele kostprijs overige immateriële vaste activa	D	4	\N	t
184	1	BIvaOivAkpBeg	0110015.01	Beginbalans (overname eindsaldo vorig jaar) overige immateriële vaste activa	D	5	\N	t
185	1	BIvaOivAkpInv	0110015.02	Investeringen overige immateriële vaste activa	D	5	\N	t
186	1	BIvaOivAkpAdo	0110015.03	Bij overname verkregen activa overige immateriële vaste activa	D	5	\N	t
187	1	BIvaOivAkpDes	0110015.04	Desinvesteringen overige immateriële vaste activa	C	5	\N	t
188	1	BIvaOivAkpDda	0110015.05	Afstotingen overige immateriële vaste activa	C	5	\N	t
189	1	BIvaOivAkpOmv	0110015.06	Omrekeningsverschillen overige immateriële vaste activa	D	5	\N	t
190	1	BIvaOivAkpOvm	0110015.07	Overige mutaties overige immateriële vaste activa	D	5	\N	t
191	1	BIvaOivCae	0110020	Cumulatieve afschrijvingen en waardeverminderingen overige immateriële vaste activa	C	4	\N	t
192	1	BIvaOivCaeBeg	0110020.01	Beginbalans (overname eindsaldo vorig jaar) overige immateriële vaste activa	C	5	\N	t
193	1	BIvaOivCaeAfs	0110020.02	Afschrijvingen overige immateriële vaste activa	C	5	\N	t
194	1	BIvaOivCaeDca	0110020.03	Afschrijving op desinvesteringen overige immateriële vaste activa	D	5	\N	t
195	1	BIvaOivCaeWvr	0110020.04	Bijzondere waardeverminderingen overige immateriële vaste activa	C	5	\N	t
196	1	BIvaOivCaeTvw	0110020.05	Terugneming van bijzondere waardeverminderingen overige immateriële vaste activa	D	5	\N	t
197	1	BIvaOivCaeOvm	0110020.06	Overige mutaties waardeveranderingen overige immateriële vaste activa	D	5	\N	t
198	1	BIvaOivCuh	0110030	Cumulatieve herwaarderingen overige immateriële vaste activa	D	4	\N	t
199	1	BIvaOivCuhBeg	0110030.01	Beginbalans (overname eindsaldo vorig jaar) overige immateriële vaste activa	D	5	\N	t
200	1	BIvaOivCuhHer	0110030.02	Herwaarderingen overige immateriële vaste activa	D	5	\N	t
201	1	BIvaOivCuhAfh	0110030.03	Afschrijving herwaarderingen overige immateriële vaste activa	C	5	\N	t
202	1	BIvaOivCuhDeh	0110030.04	Desinvestering herwaarderingen overige immateriële vaste activa	C	5	\N	t
203	1	BMva	02	Materiële vaste activa	D	2	\N	t
204	1	BMvaTer	0201000	Terreinen	D	3	\N	t
205	1	BMvaTerVvp	0201010	Verkrijgings- of vervaardigingsprijs terreinen	D	4	\N	t
206	1	BMvaTerVvpBeg	0201010.01	Beginbalans (overname eindsaldo vorig jaar) terreinen	D	5	\N	t
207	1	BMvaTerVvpIna	0201010.02	Investeringen terreinen	D	5	\N	t
208	1	BMvaTerVvpAdo	0201010.04	Verwervingen via fusies en overnames terreinen	D	5	\N	t
209	1	BMvaTerVvpDes	0201010.05	Desinvesteringen terreinen	C	5	\N	t
210	1	BMvaTerVvpDda	0201010.06	Afstotingen terreinen	C	5	\N	t
211	1	BMvaTerVvpHcv	0201010.10	Herclassificatie terreinen	D	5	\N	t
212	1	BMvaTerVvpOmv	0201010.07	Omrekeningsverschillen terreinen	D	5	\N	t
213	1	BMvaTerVvpOve	0201010.08	Overboekingen terreinen	D	5	\N	t
214	1	BMvaTerVvpOvm	0201010.09	Overige mutaties terreinen	D	5	\N	t
215	1	BMvaTerAkp	201015	Actuele kostprijs terreinen	D	4	\N	t
216	1	BMvaTerAkpBeg	0201015.01	Beginbalans (overname eindsaldo vorig jaar) terreinen	D	5	\N	t
217	1	BMvaTerAkpIna	0201015.02	Investeringen terreinen	D	5	\N	t
218	1	BMvaTerAkpAdo	0201015.04	Verwervingen via fusies en overnames terreinen	D	5	\N	t
219	1	BMvaTerAkpDes	0201015.05	Desinvesteringen terreinen	C	5	\N	t
220	1	BMvaTerAkpDda	0201015.06	Afstotingen terreinen	C	5	\N	t
221	1	BMvaTerAkpOmv	0201015.07	Omrekeningsverschillen terreinen	D	5	\N	t
222	1	BMvaTerAkpOve	0201015.08	Overboekingen terreinen	D	5	\N	t
223	1	BMvaTerAkpOvm	0201015.09	Overige mutaties terreinen	D	5	\N	t
224	1	BMvaTerCae	0201020	Cumulatieve afschrijvingen en waardeverminderingen terreinen	C	4	\N	t
225	1	BMvaTerCaeBeg	0201020.01	Beginbalans (overname eindsaldo vorig jaar) terreinen	C	5	\N	t
226	1	BMvaTerCaeAfs	0201020.02	Afschrijvingen terreinen	C	5	\N	t
227	1	BMvaTerCaeDca	0201020.03	Afschrijving op desinvesteringen terreinen	D	5	\N	t
228	1	BMvaTerCaeWvr	0201020.04	Bijzondere waardeverminderingen terreinen	C	5	\N	t
229	1	BMvaTerCaeTvw	0201020.05	Terugneming van bijzondere waardeverminderingen terreinen	D	5	\N	t
230	1	BMvaTerCaeHca	0201020.06	Herclassificatie afschrijvingen terreinen	C	5	\N	t
231	1	BMvaTerCaeOvm	0201020.07	Overige mutaties afschrijvingen terreinen	C	5	\N	t
232	1	BMvaTerCuh	0201030	Cumulatieve herwaarderingen terreinen	D	4	\N	t
233	1	BMvaTerCuhBeg	0201030.01	Beginbalans (overname eindsaldo vorig jaar) terreinen	D	5	\N	t
234	1	BMvaTerCuhHer	0201030.02	Herwaarderingen terreinen	D	5	\N	t
235	1	BMvaTerCuhAfh	0201030.03	Afschrijving herwaarderingen terreinen	C	5	\N	t
236	1	BMvaTerCuhDeh	0201030.04	Desinvestering herwaarderingen terreinen	C	5	\N	t
237	1	BMvaTerCuhHca	0201030.05	Herclassificatie herwaarderingen terreinen	D	5	\N	t
240	1	BMvaBegVvp	0202010	Verkrijgings- of vervaardigingsprijs bedrijfsgebouwen	D	4	\N	t
241	1	BMvaBegVvpBeg	0202010.01	Beginbalans (overname eindsaldo vorig jaar) bedrijfsgebouwen	D	5	\N	t
242	1	BMvaBegVvpLie	0202010.04	Investeringen bedrijfsgebouwen	D	5	\N	t
243	1	BMvaBegVvpAdo	0202010.05	Verwervingen via fusies en overnames bedrijfsgebouwen	D	5	\N	t
244	1	BMvaBegVvpDes	0202010.06	Desinvesteringen bedrijfsgebouwen	C	5	\N	t
245	1	BMvaBegVvpDda	0202010.07	Afstotingen bedrijfsgebouwen	C	5	\N	t
246	1	BMvaBegVvpHcv	0202010.11	Herclassificatie bedrijfsgebouwen	D	5	\N	t
247	1	BMvaBegVvpOmv	0202010.08	Omrekeningsverschillen bedrijfsgebouwen	D	5	\N	t
248	1	BMvaBegVvpOve	0202010.09	Overboekingen bedrijfsgebouwen	D	5	\N	t
249	1	BMvaBegVvpOvm	0202010.10	Overige mutaties bedrijfsgebouwen	D	5	\N	t
250	1	BMvaBegAkp	202015	Actuele kostprijs bedrijfsgebouwen	D	4	\N	t
251	1	BMvaBegAkpBeg	0202015.01	Beginbalans (overname eindsaldo vorig jaar) bedrijfsgebouwen	D	5	\N	t
252	1	BMvaBegAkpLie	0202015.04	Investeringen bedrijfsgebouwen	D	5	\N	t
253	1	BMvaBegAkpAdo	0202015.05	Verwervingen via fusies en overnames bedrijfsgebouwen	D	5	\N	t
254	1	BMvaBegAkpDes	0202015.06	Desinvesteringen bedrijfsgebouwen	C	5	\N	t
255	1	BMvaBegAkpDda	0202015.07	Afstotingen bedrijfsgebouwen	C	5	\N	t
256	1	BMvaBegAkpOmv	0202015.08	Omrekeningsverschillen bedrijfsgebouwen	D	5	\N	t
257	1	BMvaBegAkpOve	0202015.09	Overboekingen bedrijfsgebouwen	D	5	\N	t
258	1	BMvaBegAkpOvm	0202015.10	Overige mutaties bedrijfsgebouwen	D	5	\N	t
259	1	BMvaBegCae	0202020	Cumulatieve afschrijvingen en waardeverminderingen bedrijfsgebouwen	C	4	\N	t
260	1	BMvaBegCaeBeg	0202020.01	Beginbalans (overname eindsaldo vorig jaar) bedrijfsgebouwen	C	5	\N	t
261	1	BMvaBegCaeAfs	0202020.02	Afschrijvingen bedrijfsgebouwen	C	5	\N	t
262	1	BMvaBegCaeDca	0202020.03	Afschrijving op desinvesteringen bedrijfsgebouwen	D	5	\N	t
263	1	BMvaBegCaeWvr	0202020.04	Bijzondere waardeverminderingen bedrijfsgebouwen	C	5	\N	t
264	1	BMvaBegCaeTvw	0202020.05	Terugneming van bijzondere waardeverminderingen bedrijfsgebouwen	D	5	\N	t
265	1	BMvaBegCaeHca	0202020.06	Herclassificatie afschrijvingen bedrijfsgebouwen	C	5	\N	t
266	1	BMvaBegCaeOvm	0202020.07	Overige mutaties afschrijvingen bedrijfsgebouwen	C	5	\N	t
267	1	BMvaBegCuh	0202030	Cumulatieve herwaarderingen bedrijfsgebouwen	D	4	\N	t
268	1	BMvaBegCuhBeg	0202030.01	Beginbalans (overname eindsaldo vorig jaar) bedrijfsgebouwen	D	5	\N	t
269	1	BMvaBegCuhHer	0202030.02	Herwaarderingen bedrijfsgebouwen	D	5	\N	t
270	1	BMvaBegCuhAfh	0202030.03	Afschrijving herwaarderingen bedrijfsgebouwen	C	5	\N	t
271	1	BMvaBegCuhDeh	0202030.04	Desinvestering herwaarderingen bedrijfsgebouwen	C	5	\N	t
272	1	BMvaBegCuhHch	0202030.05	Herclassificatie herwaarderingen bedrijfsgebouwen	D	5	\N	t
273	1	BMvaBegCuhOvm	0202030.06	Overige mutaties herwaarderingen bedrijfsgebouwen	D	5	\N	t
274	1	BMvaVer	0203000	Verbouwingen	D	3	\N	t
275	1	BMvaVerVvp	0203010	Verkrijgings- of vervaardigingsprijs verbouwingen	D	4	\N	t
276	1	BMvaVerVvpBeg	0203010.01	Beginbalans (overname eindsaldo vorig jaar) verbouwingen	D	5	\N	t
277	1	BMvaVerVvpIna	0203010.02	Investeringen verbouwingen	D	5	\N	t
278	1	BMvaVerVvpAdo	0203010.05	Verwervingen via fusies en overnames verbouwingen	D	5	\N	t
279	1	BMvaVerVvpDes	0203010.06	Desinvesteringen verbouwingen	C	5	\N	t
280	1	BMvaVerVvpDda	0203010.07	Afstotingen verbouwingen	C	5	\N	t
281	1	BMvaVerVvpHcv	0203010.11	Herclassificatie verbouwingen	D	5	\N	t
282	1	BMvaVerVvpOmv	0203010.08	Omrekeningsverschillen verbouwingen	D	5	\N	t
283	1	BMvaVerVvpOve	0203010.09	Overboekingen verbouwingen	D	5	\N	t
284	1	BMvaVerVvpOvm	0203010.10	Overige mutaties verbouwingen	D	5	\N	t
285	1	BMvaVerAkp	203015	Actuele kostprijs verbouwingen	D	4	\N	t
286	1	BMvaVerAkpBeg	0203015.01	Beginbalans (overname eindsaldo vorig jaar) verbouwingen	D	5	\N	t
287	1	BMvaVerAkpIna	0203015.02	Investeringen verbouwingen	D	5	\N	t
288	1	BMvaVerAkpAdo	0203015.05	Verwervingen via fusies en overnames verbouwingen	D	5	\N	t
289	1	BMvaVerAkpDes	0203015.06	Desinvesteringen verbouwingen	C	5	\N	t
290	1	BMvaVerAkpDda	0203015.07	Afstotingen verbouwingen	C	5	\N	t
291	1	BMvaVerAkpOmv	0203015.08	Omrekeningsverschillen verbouwingen	D	5	\N	t
292	1	BMvaVerAkpOve	0203015.09	Overboekingen verbouwingen	D	5	\N	t
293	1	BMvaVerAkpOvm	0203015.10	Overige mutaties verbouwingen	D	5	\N	t
294	1	BMvaVerCae	0203020	Cumulatieve afschrijvingen en waardeverminderingen verbouwingen	C	4	\N	t
295	1	BMvaVerCaeBeg	0203020.01	Beginbalans (overname eindsaldo vorig jaar) verbouwingen	C	5	\N	t
296	1	BMvaVerCaeAfs	0203020.02	Afschrijvingen verbouwingen	C	5	\N	t
297	1	BMvaVerCaeDca	0203020.03	Afschrijving op desinvesteringen verbouwingen	D	5	\N	t
298	1	BMvaVerCaeWvr	0203020.04	Bijzondere waardeverminderingen verbouwingen	C	5	\N	t
299	1	BMvaVerCaeTvw	0203020.05	Terugneming van bijzondere waardeverminderingen verbouwingen	D	5	\N	t
300	1	BMvaVerCaeHca	0203020.06	Herclassificatie afschrijvingen verbouwingen	C	5	\N	t
301	1	BMvaVerCaeOvm	0203020.07	Overige mutaties afschrijvingen verbouwingen	C	5	\N	t
302	1	BMvaVerCuh	0203030	Cumulatieve herwaarderingen verbouwingen	D	4	\N	t
303	1	BMvaVerCuhBeg	0203030.01	Beginbalans (overname eindsaldo vorig jaar) verbouwingen	D	5	\N	t
304	1	BMvaVerCuhHer	0203030.02	Herwaarderingen verbouwingen	D	5	\N	t
305	1	BMvaVerCuhAfh	0203030.03	Afschrijving herwaarderingen verbouwingen	C	5	\N	t
306	1	BMvaVerCuhDeh	0203030.04	Desinvestering herwaarderingen verbouwingen	C	5	\N	t
307	1	BMvaVerCuhHch	0203030.05	Herclassificatie herwaarderingen verbouwingen	D	5	\N	t
308	1	BMvaVerCuhOvm	0203030.06	Overige mutaties herwaarderingen verbouwingen	D	5	\N	t
309	1	BMvaMei	0210000	Machines en installaties	D	3	\N	t
310	1	BMvaMeiVvp	0210010	Verkrijgings- of vervaardigingsprijs machines en installaties	D	4	\N	t
311	1	BMvaMeiVvpBeg	0210010.01	Beginbalans (overname eindsaldo vorig jaar) machines en installaties	D	5	\N	t
312	1	BMvaMeiVvpIna	0210010.02	Investeringen machines en installaties	D	5	\N	t
313	1	BMvaMeiVvpAdo	0210010.05	Verwervingen via fusies en overnames machines en installaties	D	5	\N	t
314	1	BMvaMeiVvpDes	0210010.06	Desinvesteringen machines en installaties	C	5	\N	t
315	1	BMvaMeiVvpDda	0210010.07	Afstotingen machines en installaties	C	5	\N	t
316	1	BMvaMeiVvpHcv	0210010.11	Herclassificatie machines en installaties	D	5	\N	t
317	1	BMvaMeiVvpOmv	0210010.08	Omrekeningsverschillen machines en installaties	D	5	\N	t
318	1	BMvaMeiVvpOve	0210010.09	Overboekingen machines en installaties	D	5	\N	t
319	1	BMvaMeiVvpOvm	0210010.10	Overige mutaties machines en installaties	D	5	\N	t
320	1	BMvaMeiAkp	210015	Actuele kostprijs machines en installaties	D	4	\N	t
321	1	BMvaMeiAkpBeg	0210015.01	Beginbalans (overname eindsaldo vorig jaar) machines en installaties	D	5	\N	t
322	1	BMvaMeiAkpIna	0210015.02	Investeringen machines en installaties	D	5	\N	t
323	1	BMvaMeiAkpAdo	0210015.05	Verwervingen via fusies en overnames machines en installaties	D	5	\N	t
324	1	BMvaMeiAkpDes	0210015.06	Desinvesteringen machines en installaties	C	5	\N	t
325	1	BMvaMeiAkpDda	0210015.07	Afstotingen machines en installaties	C	5	\N	t
326	1	BMvaMeiAkpOmv	0210015.08	Omrekeningsverschillen machines en installaties	D	5	\N	t
327	1	BMvaMeiAkpOve	0210015.09	Overboekingen machines en installaties	D	5	\N	t
328	1	BMvaMeiAkpOvm	0210015.10	Overige mutaties machines en installaties	D	5	\N	t
329	1	BMvaMeiCae	0210020	Cumulatieve afschrijvingen en waardeverminderingen machines en installaties	C	4	\N	t
330	1	BMvaMeiCaeBeg	0210020.01	Beginbalans (overname eindsaldo vorig jaar) machines en installaties	C	5	\N	t
331	1	BMvaMeiCaeAfs	0210020.02	Afschrijvingen machines en installaties	C	5	\N	t
332	1	BMvaMeiCaeDca	0210020.03	Afschrijving op desinvesteringen machines en installaties	D	5	\N	t
333	1	BMvaMeiCaeWvr	0210020.04	Bijzondere waardeverminderingen machines en installaties	C	5	\N	t
334	1	BMvaMeiCaeTvw	0210020.05	Terugneming van bijzondere waardeverminderingen machines en installaties	D	5	\N	t
335	1	BMvaMeiCaeHca	0210020.06	Herclassificatie afschrijvingen machines en installaties	C	5	\N	t
336	1	BMvaMeiCaeOvm	0210020.07	Overige mutaties afschrijvingen machines en installaties	C	5	\N	t
337	1	BMvaMeiCuh	0210030	Cumulatieve herwaarderingen machines en installaties	D	4	\N	t
338	1	BMvaMeiCuhBeg	0210030.01	Beginbalans (overname eindsaldo vorig jaar) machines en installaties	D	5	\N	t
339	1	BMvaMeiCuhHer	0210030.02	Herwaarderingen machines en installaties	D	5	\N	t
340	1	BMvaMeiCuhAfh	0210030.03	Afschrijving herwaarderingen machines en installaties	C	5	\N	t
341	1	BMvaMeiCuhDeh	0210030.04	Desinvestering herwaarderingen machines en installaties	C	5	\N	t
342	1	BMvaMeiCuhHch	0210030.05	Herclassificatie herwaarderingen machines en installaties	D	5	\N	t
343	1	BMvaMeiCuhOvm	0210030.06	Overige mutaties herwaarderingen machines en installaties	D	5	\N	t
344	1	BMvaObe	0214000	Andere vaste bedrijfsmiddelen	D	3	\N	t
345	1	BMvaObeVvp	0214010	Verkrijgings- of vervaardigingsprijs andere vaste bedrijfsmiddelen	D	4	\N	t
346	1	BMvaObeVvpBeg	0214010.01	Beginbalans (overname eindsaldo vorig jaar) andere vaste bedrijfsmiddelen	D	5	\N	t
347	1	BMvaObeVvpIna	0214010.02	Investeringen andere vaste bedrijfsmiddelen	D	5	\N	t
348	1	BMvaObeVvpAdo	0214010.05	Verwervingen via fusies en overnames andere vaste bedrijfsmiddelen	D	5	\N	t
349	1	BMvaObeVvpDes	0214010.06	Desinvesteringen andere vaste bedrijfsmiddelen	C	5	\N	t
350	1	BMvaObeVvpDda	0214010.07	Afstotingen andere vaste bedrijfsmiddelen	C	5	\N	t
351	1	BMvaObeVvpOmv	0214010.08	Omrekeningsverschillen andere vaste bedrijfsmiddelen	D	5	\N	t
352	1	BMvaObeVvpOve	0214010.09	Overboekingen andere vaste bedrijfsmiddelen	D	5	\N	t
353	1	BMvaObeVvpOvm	0214010.10	Overige mutaties andere vaste bedrijfsmiddelen	D	5	\N	t
354	1	BMvaObeAkp	214015	Actuele kostprijs andere vaste bedrijfsmiddelen	D	4	\N	t
355	1	BMvaObeAkpBeg	0214015.01	Beginbalans (overname eindsaldo vorig jaar) andere vaste bedrijfsmiddelen	D	5	\N	t
356	1	BMvaObeAkpIna	0214015.02	Investeringen andere vaste bedrijfsmiddelen	D	5	\N	t
357	1	BMvaObeAkpAdo	0214015.05	Verwervingen via fusies en overnames andere vaste bedrijfsmiddelen	D	5	\N	t
358	1	BMvaObeAkpDes	0214015.06	Desinvesteringen andere vaste bedrijfsmiddelen	C	5	\N	t
359	1	BMvaObeAkpDda	0214015.07	Afstotingen andere vaste bedrijfsmiddelen	C	5	\N	t
360	1	BMvaObeAkpOmv	0214015.08	Omrekeningsverschillen andere vaste bedrijfsmiddelen	D	5	\N	t
361	1	BMvaObeAkpOve	0214015.09	Overboekingen andere vaste bedrijfsmiddelen	D	5	\N	t
362	1	BMvaObeAkpOvm	0214015.10	Overige mutaties andere vaste bedrijfsmiddelen	D	5	\N	t
363	1	BMvaObeCae	0214020	Cumulatieve afschrijvingen en waardeverminderingen andere vaste bedrijfsmiddelen	C	4	\N	t
364	1	BMvaObeCaeBeg	0214020.01	Beginbalans (overname eindsaldo vorig jaar) andere vaste bedrijfsmiddelen	C	5	\N	t
365	1	BMvaObeCaeAfs	0214020.02	Afschrijvingen andere vaste bedrijfsmiddelen	C	5	\N	t
366	1	BMvaObeCaeDca	0214020.03	Afschrijving op desinvesteringen andere vaste bedrijfsmiddelen	D	5	\N	t
367	1	BMvaObeCaeWvr	0214020.04	Bijzondere waardeverminderingen andere vaste bedrijfsmiddelen	C	5	\N	t
368	1	BMvaObeCaeTvw	0214020.05	Terugneming van bijzondere waardeverminderingen andere vaste bedrijfsmiddelen	D	5	\N	t
369	1	BMvaObeCaeOvm	0214020.06	Overige mutaties afschrijvingen andere vaste bedrijfsmiddelen	C	5	\N	t
370	1	BMvaObeCuh	0214030	Cumulatieve herwaarderingen andere vaste bedrijfsmiddelen	D	4	\N	t
371	1	BMvaObeCuhBeg	0214030.01	Beginbalans (overname eindsaldo vorig jaar) andere vaste bedrijfsmiddelen	D	5	\N	t
372	1	BMvaObeCuhHer	0214030.02	Herwaarderingen andere vaste bedrijfsmiddelen	D	5	\N	t
373	1	BMvaObeCuhAfh	0214030.03	Afschrijving herwaarderingen andere vaste bedrijfsmiddelen	C	5	\N	t
374	1	BMvaObeCuhDeh	0214030.04	Desinvestering herwaarderingen andere vaste bedrijfsmiddelen	C	5	\N	t
375	1	BMvaObeCuhOvm	0214030.05	Overige mutaties herwaarderingen andere vaste bedrijfsmiddelen	D	5	\N	t
376	1	BMvaBei	0215000	Inventaris	D	3	\N	t
377	1	BMvaBeiVvp	0215010	Verkrijgings- of vervaardigingsprijs inventaris	D	4	\N	t
378	1	BMvaBeiVvpBeg	0215010.01	Beginbalans (overname eindsaldo vorig jaar) inventaris	D	5	\N	t
379	1	BMvaBeiVvpIna	0215010.02	Investeringen inventaris	D	5	\N	t
380	1	BMvaBeiVvpAdo	0215010.05	Verwervingen via fusies en overnames inventaris	D	5	\N	t
381	1	BMvaBeiVvpDes	0215010.06	Desinvesteringen inventaris	C	5	\N	t
382	1	BMvaBeiVvpDda	0215010.07	Afstotingen inventaris	C	5	\N	t
383	1	BMvaBeiVvpOmv	0215010.08	Omrekeningsverschillen inventaris	D	5	\N	t
384	1	BMvaBeiVvpOve	0215010.09	Overboekingen inventaris	D	5	\N	t
385	1	BMvaBeiVvpOvm	0215010.10	Overige mutaties inventaris	D	5	\N	t
386	1	BMvaBeiAkp	215015	Actuele kostprijs inventaris	D	4	\N	t
387	1	BMvaBeiAkpBeg	0215015.01	Beginbalans (overname eindsaldo vorig jaar) inventaris	D	5	\N	t
388	1	BMvaBeiAkpIna	0215015.02	Investeringen inventaris	D	5	\N	t
389	1	BMvaBeiAkpAdo	0215015.05	Verwervingen via fusies en overnames inventaris	D	5	\N	t
390	1	BMvaBeiAkpDes	0215015.06	Desinvesteringen inventaris	C	5	\N	t
391	1	BMvaBeiAkpDda	0215015.07	Afstotingen inventaris	C	5	\N	t
392	1	BMvaBeiAkpOmv	0215015.08	Omrekeningsverschillen inventaris	D	5	\N	t
393	1	BMvaBeiAkpOve	0215015.09	Overboekingen inventaris	D	5	\N	t
394	1	BMvaBeiAkpOvm	0215015.10	Overige mutaties inventaris	D	5	\N	t
395	1	BMvaBeiCae	0215020	Cumulatieve afschrijvingen en waardeverminderingen inventaris	C	4	\N	t
396	1	BMvaBeiCaeBeg	0215020.01	Beginbalans (overname eindsaldo vorig jaar) inventaris	C	5	\N	t
397	1	BMvaBeiCaeAfs	0215020.02	Afschrijvingen inventaris	C	5	\N	t
398	1	BMvaBeiCaeDca	0215020.03	Afschrijving op desinvesteringen inventaris	D	5	\N	t
399	1	BMvaBeiCaeWvr	0215020.04	Bijzondere waardeverminderingen inventaris	C	5	\N	t
400	1	BMvaBeiCaeTvw	0215020.05	Terugneming van bijzondere waardeverminderingen inventaris	D	5	\N	t
401	1	BMvaBeiCaeOvm	0215020.06	Overige mutaties afschrijvingen inventaris	C	5	\N	t
402	1	BMvaBeiCuh	0215030	Cumulatieve herwaarderingen inventaris	D	4	\N	t
403	1	BMvaBeiCuhBeg	0215030.01	Beginbalans (overname eindsaldo vorig jaar) inventaris	D	5	\N	t
404	1	BMvaBeiCuhHer	0215030.02	Herwaarderingen inventaris	D	5	\N	t
405	1	BMvaBeiCuhAfh	0215030.03	Afschrijving herwaarderingen inventaris	C	5	\N	t
406	1	BMvaBeiCuhDeh	0215030.04	Desinvestering herwaarderingen inventaris	C	5	\N	t
407	1	BMvaBeiCuhOvm	0215030.05	Overige mutaties herwaarderingen inventaris	C	5	\N	t
408	1	BMvaTev	0213000	Automobielen en overige transportmiddelen	D	3	\N	t
409	1	BMvaTevVvp	0213010	Verkrijgings- of vervaardigingsprijs automobielen en overige transportmiddelen	D	4	\N	t
410	1	BMvaTevVvpBeg	0213010.01	Beginbalans (overname eindsaldo vorig jaar) automobielen en overige transportmiddelen	D	5	\N	t
411	1	BMvaTevVvpIna	0213010.02	Investeringen automobielen en overige transportmiddelen	D	5	\N	t
412	1	BMvaTevVvpAdo	0213010.05	Verwervingen via fusies en overnames automobielen en overige transportmiddelen	D	5	\N	t
413	1	BMvaTevVvpDes	0213010.06	Desinvesteringen automobielen en overige transportmiddelen	C	5	\N	t
414	1	BMvaTevVvpDda	0213010.07	Afstotingen automobielen en overige transportmiddelen	C	5	\N	t
415	1	BMvaTevVvpOmv	0213010.08	Omrekeningsverschillen automobielen en overige transportmiddelen	D	5	\N	t
416	1	BMvaTevVvpOve	0213010.09	Overboekingen automobielen en overige transportmiddelen	D	5	\N	t
417	1	BMvaTevVvpOvm	0213010.10	Overige mutaties automobielen en overige transportmiddelen	D	5	\N	t
418	1	BMvaTevAkp	213015	Actuele kostprijs automobielen en overige transportmiddelen	D	4	\N	t
419	1	BMvaTevAkpBeg	0213015.01	Beginbalans (overname eindsaldo vorig jaar) automobielen en overige transportmiddelen	D	5	\N	t
420	1	BMvaTevAkpIna	0213015.02	Investeringen automobielen en overige transportmiddelen	D	5	\N	t
421	1	BMvaTevAkpAdo	0213015.05	Verwervingen via fusies en overnames automobielen en overige transportmiddelen	D	5	\N	t
422	1	BMvaTevAkpDes	0213015.06	Desinvesteringen automobielen en overige transportmiddelen	C	5	\N	t
423	1	BMvaTevAkpDda	0213015.07	Afstotingen automobielen en overige transportmiddelen	C	5	\N	t
424	1	BMvaTevAkpOmv	0213015.08	Omrekeningsverschillen automobielen en overige transportmiddelen	D	5	\N	t
425	1	BMvaTevAkpOve	0213015.09	Overboekingen automobielen en overige transportmiddelen	D	5	\N	t
426	1	BMvaTevAkpOvm	0213015.10	Overige mutaties automobielen en overige transportmiddelen	D	5	\N	t
427	1	BMvaTevCae	0213020	Cumulatieve afschrijvingen en waardeverminderingen automobielen en overige transportmiddelen	C	4	\N	t
726	1	BVasVioCaeAfs	0204020.02	Afschrijvingen 	C	5	\N	t
428	1	BMvaTevCaeBeg	0213020.01	Beginbalans (overname eindsaldo vorig jaar) automobielen en overige transportmiddelen	C	5	\N	t
429	1	BMvaTevCaeAfs	0213020.02	Afschrijvingen automobielen en overige transportmiddelen	C	5	\N	t
430	1	BMvaTevCaeDca	0213020.03	Afschrijving op desinvesteringen automobielen en overige transportmiddelen	D	5	\N	t
431	1	BMvaTevCaeWvr	0213020.04	Bijzondere waardeverminderingen automobielen en overige transportmiddelen	C	5	\N	t
432	1	BMvaTevCaeTvw	0213020.05	Terugneming van bijzondere waardeverminderingen automobielen en overige transportmiddelen	D	5	\N	t
433	1	BMvaTevCaeOvm	0213020.06	Overige mutaties afschrijvingen automobielen en overige transportmiddelen	C	5	\N	t
434	1	BMvaTevCuh	0213030	Cumulatieve herwaarderingen automobielen en overige transportmiddelen	D	4	\N	t
435	1	BMvaTevCuhBeg	0213030.01	Beginbalans (overname eindsaldo vorig jaar) automobielen en overige transportmiddelen	D	5	\N	t
436	1	BMvaTevCuhHer	0213030.02	Herwaarderingen automobielen en overige transportmiddelen	D	5	\N	t
437	1	BMvaTevCuhAfh	0213030.03	Afschrijving herwaarderingen automobielen en overige transportmiddelen	C	5	\N	t
438	1	BMvaTevCuhDeh	0213030.04	Desinvestering herwaarderingen automobielen en overige transportmiddelen	C	5	\N	t
439	1	BMvaTevCuhOvm	0213030.05	Overige mutaties herwaarderingen automobielen en overige transportmiddelen	D	5	\N	t
440	1	BMvaHuu	0209000	Huurdersinvesteringen	D	3	\N	t
441	1	BMvaHuuVvp	0209010	Verkrijgings- of vervaardigingsprijs huurdersinvesteringen	D	4	\N	t
442	1	BMvaHuuVvpBeg	0209010.01	Beginbalans (overname eindsaldo vorig jaar) huurdersinvesteringen	D	5	\N	t
443	1	BMvaHuuVvpIna	0209010.02	Investeringen huurdersinvesteringen	D	5	\N	t
444	1	BMvaHuuVvpAdo	0209010.05	Verwervingen via fusies en overnames huurdersinvesteringen	D	5	\N	t
445	1	BMvaHuuVvpDes	0209010.06	Desinvesteringen huurdersinvesteringen	C	5	\N	t
446	1	BMvaHuuVvpDda	0209010.07	Afstotingen huurdersinvesteringen	C	5	\N	t
447	1	BMvaHuuVvpOmv	0209010.08	Omrekeningsverschillen huurdersinvesteringen	D	5	\N	t
448	1	BMvaHuuVvpOve	0209010.09	Overboekingen huurdersinvesteringen	D	5	\N	t
449	1	BMvaHuuVvpOvm	0209010.10	Overige mutaties huurdersinvesteringen	D	5	\N	t
450	1	BMvaHuuAkp	209015	Actuele kostprijs huurdersinvesteringen	D	4	\N	t
451	1	BMvaHuuAkpBeg	0209015.01	Beginbalans (overname eindsaldo vorig jaar) huurdersinvesteringen	D	5	\N	t
452	1	BMvaHuuAkpIna	0209015.02	Investeringen huurdersinvesteringen	D	5	\N	t
453	1	BMvaHuuAkpAdo	0209015.05	Verwervingen via fusies en overnames huurdersinvesteringen	D	5	\N	t
454	1	BMvaHuuAkpDes	0209015.06	Desinvesteringen huurdersinvesteringen	C	5	\N	t
455	1	BMvaHuuAkpDda	0209015.07	Afstotingen huurdersinvesteringen	C	5	\N	t
456	1	BMvaHuuAkpOmv	0209015.08	Omrekeningsverschillen huurdersinvesteringen	D	5	\N	t
457	1	BMvaHuuAkpOve	0209015.09	Overboekingen huurdersinvesteringen	D	5	\N	t
458	1	BMvaHuuAkpOvm	0209015.10	Overige mutaties huurdersinvesteringen	D	5	\N	t
459	1	BMvaHuuCae	0209020	Cumulatieve afschrijvingen en waardeverminderingen huurdersinvesteringen	C	4	\N	t
460	1	BMvaHuuCaeBeg	0209020.01	Beginbalans (overname eindsaldo vorig jaar) huurdersinvesteringen	C	5	\N	t
461	1	BMvaHuuCaeAfs	0209020.02	Afschrijvingen huurdersinvesteringen	C	5	\N	t
462	1	BMvaHuuCaeDca	0209020.03	Afschrijving op desinvesteringen huurdersinvesteringen	D	5	\N	t
463	1	BMvaHuuCaeWvr	0209020.04	Bijzondere waardeverminderingen huurdersinvesteringen	C	5	\N	t
464	1	BMvaHuuCaeTvw	0209020.05	Terugneming van bijzondere waardeverminderingen huurdersinvesteringen	D	5	\N	t
465	1	BMvaHuuCaeOvm	0209020.06	Overige mutaties afschrijvingen huurdersinvesteringen	C	5	\N	t
466	1	BMvaHuuCuh	0209030	Cumulatieve herwaarderingen huurdersinvesteringen	D	4	\N	t
467	1	BMvaHuuCuhBeg	0209030.01	Beginbalans (overname eindsaldo vorig jaar) huurdersinvesteringen	D	5	\N	t
468	1	BMvaHuuCuhHer	0209030.02	Herwaarderingen huurdersinvesteringen	D	5	\N	t
469	1	BMvaHuuCuhAfh	0209030.03	Afschrijving herwaarderingen huurdersinvesteringen	C	5	\N	t
470	1	BMvaHuuCuhDeh	0209030.04	Desinvestering herwaarderingen huurdersinvesteringen	C	5	\N	t
471	1	BMvaHuuCuhOvm	0209030.05	Overige mutaties herwaarderingen huurdersinvesteringen	D	5	\N	t
472	1	BMvaVli	0211000	Vliegtuigen	D	3	\N	t
473	1	BMvaVliVvp	0211010	Verkrijgings- of vervaardigingsprijs vliegtuigen	D	4	\N	t
474	1	BMvaVliVvpBeg	0211010.01	Beginbalans (overname eindsaldo vorig jaar) vliegtuigen	D	5	\N	t
475	1	BMvaVliVvpIna	0211010.02	Investeringen vliegtuigen	D	5	\N	t
476	1	BMvaVliVvpAdo	0211010.05	Verwervingen via fusies en overnames vliegtuigen	D	5	\N	t
477	1	BMvaVliVvpDes	0211010.06	Desinvesteringen vliegtuigen	C	5	\N	t
478	1	BMvaVliVvpDda	0211010.07	Afstotingen vliegtuigen	C	5	\N	t
479	1	BMvaVliVvpOmv	0211010.08	Omrekeningsverschillen vliegtuigen	D	5	\N	t
480	1	BMvaVliVvpOve	0211010.09	Overboekingen vliegtuigen	D	5	\N	t
481	1	BMvaVliVvpOvm	0211010.10	Overige mutaties vliegtuigen	D	5	\N	t
482	1	BMvaVliAkp	211015	Actuele kostprijs vliegtuigen	D	4	\N	t
483	1	BMvaVliAkpBeg	0211015.01	Beginbalans (overname eindsaldo vorig jaar) vliegtuigen	D	5	\N	t
484	1	BMvaVliAkpIna	0211015.02	Investeringen vliegtuigen	D	5	\N	t
485	1	BMvaVliAkpAdo	0211015.05	Verwervingen via fusies en overnames vliegtuigen	D	5	\N	t
486	1	BMvaVliAkpDes	0211015.06	Desinvesteringen vliegtuigen	C	5	\N	t
487	1	BMvaVliAkpDda	0211015.07	Afstotingen vliegtuigen	C	5	\N	t
488	1	BMvaVliAkpOmv	0211015.08	Omrekeningsverschillen vliegtuigen	D	5	\N	t
489	1	BMvaVliAkpOve	0211015.09	Overboekingen vliegtuigen	D	5	\N	t
490	1	BMvaVliAkpOvm	0211015.10	Overige mutaties vliegtuigen	D	5	\N	t
491	1	BMvaVliCae	0211020	Cumulatieve afschrijvingen en waardeverminderingen vliegtuigen	C	4	\N	t
492	1	BMvaVliCaeBeg	0211020.01	Beginbalans (overname eindsaldo vorig jaar) vliegtuigen	C	5	\N	t
493	1	BMvaVliCaeAfs	0211020.02	Afschrijvingen vliegtuigen	C	5	\N	t
494	1	BMvaVliCaeDca	0211020.03	Afschrijving op desinvesteringen vliegtuigen	D	5	\N	t
495	1	BMvaVliCaeWvr	0211020.04	Bijzondere waardeverminderingen vliegtuigen	C	5	\N	t
496	1	BMvaVliCaeTvw	0211020.05	Terugneming van bijzondere waardeverminderingen vliegtuigen	D	5	\N	t
497	1	BMvaVliCuh	0211030	Cumulatieve herwaarderingen vliegtuigen	D	4	\N	t
498	1	BMvaVliCuhBeg	0211030.01	Beginbalans (overname eindsaldo vorig jaar) vliegtuigen	D	5	\N	t
499	1	BMvaVliCuhHer	0211030.02	Herwaarderingen vliegtuigen	D	5	\N	t
500	1	BMvaVliCuhAfh	0211030.03	Afschrijving herwaarderingen vliegtuigen	C	5	\N	t
501	1	BMvaVliCuhDeh	0211030.04	Desinvestering herwaarderingen vliegtuigen	C	5	\N	t
502	1	BMvaSch	0212000	Schepen	D	3	\N	t
503	1	BMvaSchVvp	0212010	Verkrijgings- of vervaardigingsprijs schepen	D	4	\N	t
504	1	BMvaSchVvpBeg	0212010.01	Beginbalans (overname eindsaldo vorig jaar) schepen	D	5	\N	t
505	1	BMvaSchVvpIna	0212010.02	Investeringen schepen	D	5	\N	t
506	1	BMvaSchVvpAdo	0212010.05	Verwervingen via fusies en overnames schepen	D	5	\N	t
507	1	BMvaSchVvpDes	0212010.06	Desinvesteringen schepen	C	5	\N	t
508	1	BMvaSchVvpDda	0212010.07	Afstotingen schepen	C	5	\N	t
509	1	BMvaSchVvpOmv	0212010.08	Omrekeningsverschillen schepen	D	5	\N	t
510	1	BMvaSchVvpOve	0212010.09	Overboekingen schepen	D	5	\N	t
511	1	BMvaSchVvpOvm	0212010.10	Overige mutaties schepen	D	5	\N	t
512	1	BMvaSchAkp	212015	Actuele kostprijs schepen	D	4	\N	t
513	1	BMvaSchAkpBeg	0212015.01	Beginbalans (overname eindsaldo vorig jaar) schepen	D	5	\N	t
514	1	BMvaSchAkpIna	0212015.02	Investeringen schepen	D	5	\N	t
515	1	BMvaSchAkpAdo	0212015.05	Verwervingen via fusies en overnames schepen	D	5	\N	t
516	1	BMvaSchAkpDes	0212015.06	Desinvesteringen schepen	C	5	\N	t
517	1	BMvaSchAkpDda	0212015.07	Afstotingen schepen	C	5	\N	t
518	1	BMvaSchAkpOmv	0212015.08	Omrekeningsverschillen schepen	D	5	\N	t
519	1	BMvaSchAkpOve	0212015.09	Overboekingen schepen	D	5	\N	t
520	1	BMvaSchAkpOvm	0212015.10	Overige mutaties schepen	D	5	\N	t
521	1	BMvaSchCae	0212020	Cumulatieve afschrijvingen en waardeverminderingen schepen	C	4	\N	t
522	1	BMvaSchCaeBeg	0212020.01	Beginbalans (overname eindsaldo vorig jaar) schepen	C	5	\N	t
523	1	BMvaSchCaeAfs	0212020.02	Afschrijvingen schepen	C	5	\N	t
524	1	BMvaSchCaeDca	0212020.03	Afschrijving op desinvesteringen schepen	D	5	\N	t
525	1	BMvaSchCaeWvr	0212020.04	Bijzondere waardeverminderingen schepen	C	5	\N	t
526	1	BMvaSchCaeTvw	0212020.05	Terugneming van bijzondere waardeverminderingen schepen	D	5	\N	t
527	1	BMvaSchCuh	0212030	Cumulatieve herwaarderingen schepen	D	4	\N	t
528	1	BMvaSchCuhBeg	0212030.01	Beginbalans (overname eindsaldo vorig jaar) schepen	D	5	\N	t
529	1	BMvaSchCuhHer	0212030.02	Herwaarderingen schepen	D	5	\N	t
530	1	BMvaSchCuhAfh	0212030.03	Afschrijving herwaarderingen schepen	C	5	\N	t
531	1	BMvaSchCuhDeh	0212030.04	Desinvestering herwaarderingen schepen	C	5	\N	t
532	1	BMvaMep	0221000	Meerjaren plantopstand	D	3	\N	t
533	1	BMvaMepVvp	0221010	Verkrijgings- of vervaardigingsprijs meerjaren plantopstand	D	4	\N	t
534	1	BMvaMepVvpBeg	0221010.01	Beginbalans (overname eindsaldo vorig jaar) meerjaren plantopstand	D	5	\N	t
535	1	BMvaMepVvpIna	0221010.02	Investeringen meerjaren plantopstand	D	5	\N	t
536	1	BMvaMepVvpAdo	0221010.05	Verwervingen via fusies en overnames meerjaren plantopstand	D	5	\N	t
537	1	BMvaMepVvpDes	0221010.06	Desinvesteringen meerjaren plantopstand	C	5	\N	t
538	1	BMvaMepVvpDda	0221010.07	Afstotingen meerjaren plantopstand	C	5	\N	t
539	1	BMvaMepVvpOmv	0221010.08	Omrekeningsverschillen meerjaren plantopstand	D	5	\N	t
540	1	BMvaMepVvpOve	0221010.09	Overboekingen meerjaren plantopstand	D	5	\N	t
541	1	BMvaMepVvpOvm	0221010.10	Overige mutaties meerjaren plantopstand	D	5	\N	t
542	1	BMvaMepCae	0221020	Cumulatieve afschrijvingen en waardeverminderingen meerjaren plantopstand	C	4	\N	t
543	1	BMvaMepCaeBeg	0221020.01	Beginbalans (overname eindsaldo vorig jaar) meerjaren plantopstand	C	5	\N	t
544	1	BMvaMepCaeAfs	0221020.02	Afschrijvingen meerjaren plantopstand	C	5	\N	t
545	1	BMvaMepCaeDca	0221020.03	Afschrijving op desinvesteringen meerjaren plantopstand	D	5	\N	t
546	1	BMvaMepCaeWvr	0221020.04	Bijzondere waardeverminderingen meerjaren plantopstand	C	5	\N	t
547	1	BMvaMepCaeTvw	0221020.05	Terugneming van bijzondere waardeverminderingen meerjaren plantopstand	D	5	\N	t
548	1	BMvaMepCuh	0221030	Cumulatieve herwaarderingen meerjaren plantopstand	D	4	\N	t
549	1	BMvaMepCuhBeg	0221030.01	Beginbalans (overname eindsaldo vorig jaar) meerjaren plantopstand	D	5	\N	t
550	1	BMvaMepCuhHer	0221030.02	Herwaarderingen meerjaren plantopstand	D	5	\N	t
551	1	BMvaMepCuhAfh	0221030.03	Afschrijving herwaarderingen meerjaren plantopstand	C	5	\N	t
552	1	BMvaMepCuhDeh	0221030.04	Desinvestering herwaarderingen meerjaren plantopstand	C	5	\N	t
553	1	BMvaGeb	0222000	Gebruiksvee	D	3	\N	t
554	1	BMvaGebVvp	0222010	Verkrijgings- of vervaardigingsprijs gebruiksvee	D	4	\N	t
555	1	BMvaGebVvpBeg	0222010.01	Beginbalans (overname eindsaldo vorig jaar) gebruiksvee	D	5	\N	t
556	1	BMvaGebVvpIna	0222010.02	Investeringen gebruiksvee	D	5	\N	t
557	1	BMvaGebVvpAdo	0222010.05	Verwervingen via fusies en overnames gebruiksvee	D	5	\N	t
558	1	BMvaGebVvpDes	0222010.06	Desinvesteringen gebruiksvee	C	5	\N	t
559	1	BMvaGebVvpDda	0222010.07	Afstotingen gebruiksvee	C	5	\N	t
560	1	BMvaGebVvpOmv	0222010.08	Omrekeningsverschillen gebruiksvee	D	5	\N	t
561	1	BMvaGebVvpOve	0222010.09	Overboekingen gebruiksvee	D	5	\N	t
562	1	BMvaGebVvpOvm	0222010.10	Overige mutaties gebruiksvee	D	5	\N	t
563	1	BMvaGebCae	0222020	Cumulatieve afschrijvingen en waardeverminderingen gebruiksvee	C	4	\N	t
564	1	BMvaGebCaeBeg	0222020.01	Beginbalans (overname eindsaldo vorig jaar) gebruiksvee	C	5	\N	t
565	1	BMvaGebCaeAfs	0222020.02	Afschrijvingen gebruiksvee	C	5	\N	t
566	1	BMvaGebCaeDca	0222020.03	Afschrijving op desinvesteringen gebruiksvee	D	5	\N	t
567	1	BMvaGebCaeWvr	0222020.04	Bijzondere waardeverminderingen gebruiksvee	C	5	\N	t
568	1	BMvaGebCaeTvw	0222020.05	Terugneming van bijzondere waardeverminderingen gebruiksvee	D	5	\N	t
569	1	BMvaGebCuh	0222030	Cumulatieve herwaarderingen gebruiksvee	D	4	\N	t
570	1	BMvaGebCuhBeg	0222030.01	Beginbalans (overname eindsaldo vorig jaar) gebruiksvee	D	5	\N	t
571	1	BMvaGebCuhHer	0222030.02	Herwaarderingen gebruiksvee	D	5	\N	t
572	1	BMvaGebCuhAfh	0222030.03	Afschrijving herwaarderingen gebruiksvee	C	5	\N	t
573	1	BMvaGebCuhDeh	0222030.04	Desinvestering herwaarderingen gebruiksvee	C	5	\N	t
574	1	BMvaVbi	0216000	Vaste bedrijfsmiddelen in uitvoering	D	3	\N	t
575	1	BMvaVbiVvp	0216010	Verkrijgings- of vervaardigingsprijs vaste bedrijfsmiddelen in uitvoering	D	4	\N	t
576	1	BMvaVbiVvpBeg	0216010.01	Beginbalans (overname eindsaldo vorig jaar) vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
577	1	BMvaVbiVvpIna	0216010.02	Investeringen vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
578	1	BMvaVbiVvpAdo	0216010.05	Verwervingen via fusies en overnames vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
579	1	BMvaVbiVvpDes	0216010.06	Desinvesteringen vaste bedrijfsmiddelen in uitvoering	C	5	\N	t
580	1	BMvaVbiVvpDda	0216010.07	Afstotingen vaste bedrijfsmiddelen in uitvoering	C	5	\N	t
581	1	BMvaVbiVvpOmv	0216010.08	Omrekeningsverschillen vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
582	1	BMvaVbiVvpOve	0216010.09	Overboekingen vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
583	1	BMvaVbiVvpOvm	0216010.10	Overige mutaties vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
584	1	BMvaVbiAkp	216015	Actuele kostprijs vaste bedrijfsmiddelen in uitvoering	D	4	\N	t
585	1	BMvaVbiAkpBeg	0216015.01	Beginbalans (overname eindsaldo vorig jaar) vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
586	1	BMvaVbiAkpIna	0216015.02	Investeringen vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
587	1	BMvaVbiAkpAdo	0216015.05	Verwervingen via fusies en overnames vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
588	1	BMvaVbiAkpDes	0216015.06	Desinvesteringen vaste bedrijfsmiddelen in uitvoering	C	5	\N	t
589	1	BMvaVbiAkpDda	0216015.07	Afstotingen vaste bedrijfsmiddelen in uitvoering	C	5	\N	t
590	1	BMvaVbiAkpOmv	0216015.08	Omrekeningsverschillen vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
591	1	BMvaVbiAkpOve	0216015.09	Overboekingen vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
592	1	BMvaVbiAkpOvm	0216015.10	Overige mutaties vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
593	1	BMvaVbiCae	0216020	Cumulatieve afschrijvingen en waardeverminderingen vaste bedrijfsmiddelen in uitvoering	C	4	\N	t
594	1	BMvaVbiCaeBeg	0216020.01	Beginbalans (overname eindsaldo vorig jaar) vaste bedrijfsmiddelen in uitvoering	C	5	\N	t
595	1	BMvaVbiCaeAfs	0216020.02	Afschrijvingen vaste bedrijfsmiddelen in uitvoering	C	5	\N	t
596	1	BMvaVbiCaeDca	0216020.03	Afschrijving op desinvesteringen vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
597	1	BMvaVbiCaeWvr	0216020.04	Bijzondere waardeverminderingen vaste bedrijfsmiddelen in uitvoering	C	5	\N	t
598	1	BMvaVbiCaeTvw	0216020.05	Terugneming van bijzondere waardeverminderingen vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
599	1	BMvaVbiCuh	0216030	Cumulatieve herwaarderingen vaste bedrijfsmiddelen in uitvoering	D	4	\N	t
600	1	BMvaVbiCuhBeg	0216030.01	Beginbalans (overname eindsaldo vorig jaar) vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
601	1	BMvaVbiCuhHer	0216030.02	Herwaarderingen vaste bedrijfsmiddelen in uitvoering	D	5	\N	t
602	1	BMvaVbiCuhAfh	0216030.03	Afschrijving herwaarderingen vaste bedrijfsmiddelen in uitvoering	C	5	\N	t
603	1	BMvaVbiCuhDeh	0216030.04	Desinvestering herwaarderingen vaste bedrijfsmiddelen in uitvoering	C	5	\N	t
604	1	BMvaVmv	216100	Vooruitbetalingen op materiële vaste activa	D	3	\N	t
605	1	BMvaVmvVvp	216110	Verkrijgings- of vervaardigingsprijs vooruitbetalingen op materiële vaste activa	D	4	\N	t
606	1	BMvaVmvVvpBeg	0216110.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op materiële vaste activa	D	5	\N	t
607	1	BMvaVmvVvpIna	0216110.02	Investeringen vooruitbetalingen op materiële vaste activa	D	5	\N	t
608	1	BMvaVmvVvpAdo	0216110.05	Verwervingen via fusies en overnames vooruitbetalingen op materiële vaste activa	D	5	\N	t
609	1	BMvaVmvVvpDes	0216110.06	Desinvesteringen vooruitbetalingen op materiële vaste activa	C	5	\N	t
610	1	BMvaVmvVvpDda	0216110.07	Afstotingen vooruitbetalingen op materiële vaste activa	C	5	\N	t
611	1	BMvaVmvVvpOmv	0216110.08	Omrekeningsverschillen vooruitbetalingen op materiële vaste activa	D	5	\N	t
612	1	BMvaVmvVvpOve	0216110.09	Overboekingen vooruitbetalingen op materiële vaste activa	D	5	\N	t
613	1	BMvaVmvVvpOvm	0216110.10	Overige mutaties vooruitbetalingen op materiële vaste activa	D	5	\N	t
614	1	BMvaVmvAkp	216115	Actuele kostprijs vooruitbetalingen op materiële vaste activa	D	4	\N	t
615	1	BMvaVmvAkpBeg	0216115.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op materiële vaste activa	D	5	\N	t
616	1	BMvaVmvAkpIna	0216115.02	Investeringen vooruitbetalingen op materiële vaste activa	D	5	\N	t
617	1	BMvaVmvAkpAdo	0216115.05	Verwervingen via fusies en overnames vooruitbetalingen op materiële vaste activa	D	5	\N	t
618	1	BMvaVmvAkpDes	0216115.06	Desinvesteringen vooruitbetalingen op materiële vaste activa	C	5	\N	t
619	1	BMvaVmvAkpDda	0216115.07	Afstotingen vooruitbetalingen op materiële vaste activa	C	5	\N	t
620	1	BMvaVmvAkpOmv	0216115.08	Omrekeningsverschillen vooruitbetalingen op materiële vaste activa	D	5	\N	t
621	1	BMvaVmvAkpOve	0216115.09	Overboekingen vooruitbetalingen op materiële vaste activa	D	5	\N	t
622	1	BMvaVmvAkpOvm	0216115.10	Overige mutaties vooruitbetalingen op materiële vaste activa	D	5	\N	t
623	1	BMvaVmvCae	216120	Cumulatieve afschrijvingen en waardeverminderingen vooruitbetalingen op materiële vaste activa	C	4	\N	t
624	1	BMvaVmvCaeBeg	0216120.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op materiële vaste activa	C	5	\N	t
625	1	BMvaVmvCaeAfs	0216120.02	Afschrijvingen vooruitbetalingen op materiële vaste activa	C	5	\N	t
626	1	BMvaVmvCaeDca	0216120.03	Afschrijving op desinvesteringen vooruitbetalingen op materiële vaste activa	D	5	\N	t
627	1	BMvaVmvCaeWvr	0216120.04	Bijzondere waardeverminderingen vooruitbetalingen op materiële vaste activa	C	5	\N	t
628	1	BMvaVmvCaeTvw	0216120.05	Terugneming van bijzondere waardeverminderingen vooruitbetalingen op materiële vaste activa	D	5	\N	t
629	1	BMvaVmvCuh	216130	Cumulatieve herwaarderingen vooruitbetalingen op materiële vaste activa	D	4	\N	t
630	1	BMvaVmvCuhBeg	0216130.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op materiële vaste activa	D	5	\N	t
631	1	BMvaVmvCuhHer	0216130.02	Herwaarderingen vooruitbetalingen op materiële vaste activa	D	5	\N	t
632	1	BMvaVmvCuhAfh	0216130.03	Afschrijving herwaarderingen vooruitbetalingen op materiële vaste activa	C	5	\N	t
633	1	BMvaVmvCuhDeh	0216130.04	Desinvestering herwaarderingen vooruitbetalingen op materiële vaste activa	C	5	\N	t
634	1	BMvaNad	0217000	Niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	3	\N	t
635	1	BMvaNadVvp	0217010	Verkrijgings- of vervaardigingsprijs niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	4	\N	t
636	1	BMvaNadVvpBeg	0217010.01	Beginbalans (overname eindsaldo vorig jaar) niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
637	1	BMvaNadVvpIna	0217010.02	Investeringen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
638	1	BMvaNadVvpAdo	0217010.05	Verwervingen via fusies en overnames niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
639	1	BMvaNadVvpDes	0217010.06	Desinvesteringen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	C	5	\N	t
640	1	BMvaNadVvpDda	0217010.07	Afstotingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	C	5	\N	t
641	1	BMvaNadVvpOmv	0217010.08	Omrekeningsverschillen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
642	1	BMvaNadVvpOve	0217010.09	Overboekingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
643	1	BMvaNadVvpOvm	0217010.10	Overige mutaties niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
644	1	BMvaNadAkp	217015	Actuele kostprijs niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	4	\N	t
645	1	BMvaNadAkpBeg	0217015.01	Beginbalans (overname eindsaldo vorig jaar) niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
646	1	BMvaNadAkpIna	0217015.02	Investeringen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
647	1	BMvaNadAkpAdo	0217015.05	Verwervingen via fusies en overnames niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
648	1	BMvaNadAkpDes	0217015.06	Desinvesteringen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	C	5	\N	t
649	1	BMvaNadAkpDda	0217015.07	Afstotingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	C	5	\N	t
650	1	BMvaNadAkpOmv	0217015.08	Omrekeningsverschillen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
651	1	BMvaNadAkpOve	0217015.09	Overboekingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
652	1	BMvaNadAkpOvm	0217015.10	Overige mutaties niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
653	1	BMvaNadCae	0217020	Cumulatieve afschrijvingen en waardeverminderingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	C	4	\N	t
654	1	BMvaNadCaeBeg	0217020.01	Beginbalans (overname eindsaldo vorig jaar) niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	C	5	\N	t
655	1	BMvaNadCaeAfs	0217020.02	Afschrijvingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	C	5	\N	t
656	1	BMvaNadCaeDca	0217020.03	Afschrijving op desinvesteringen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
657	1	BMvaNadCaeWvr	0217020.04	Bijzondere waardeverminderingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	C	5	\N	t
658	1	BMvaNadCaeTvw	0217020.05	Terugneming van bijzondere waardeverminderingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
659	1	BMvaNadCuh	0217030	Cumulatieve herwaarderingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	4	\N	t
660	1	BMvaNadCuhBeg	0217030.01	Beginbalans (overname eindsaldo vorig jaar) niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
661	1	BMvaNadCuhHer	0217030.02	Herwaarderingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	D	5	\N	t
662	1	BMvaNadCuhAfh	0217030.03	Afschrijving herwaarderingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	C	5	\N	t
725	1	BVasVioCaeBeg	0204020.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
663	1	BMvaNadCuhDeh	0217030.04	Desinvestering herwaarderingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	C	5	\N	t
664	1	BMvaOrz	218000	Onroerende en roerende zaken ten dienste van de exploitatie	D	3	\N	t
665	1	BMvaOrzVvp	218010	Verkrijgings- of vervaardigingsprijs ten dienste van de exploitatie	D	4	\N	t
666	1	BMvaOrzVvpBeg	0218010.01	Beginbalans (overname eindsaldo vorig jaar)  ten dienste van de exploitatie	D	5	\N	t
667	1	BMvaOrzVvpIna	0218010.02	Investeringen  ten dienste van de exploitatie	D	5	\N	t
668	1	BMvaOrzVvpAdo	0218010.05	Verwervingen via fusies en overnames  ten dienste van de exploitatie	D	5	\N	t
669	1	BMvaOrzVvpDes	0218010.06	Desinvesteringen  ten dienste van de exploitatie	C	5	\N	t
670	1	BMvaOrzVvpDda	0218010.07	Afstotingen  ten dienste van de exploitatie	C	5	\N	t
671	1	BMvaOrzVvpHcv	0218010.11	Herclassificatie  ten dienste van de exploitatie	D	5	\N	t
672	1	BMvaOrzVvpOmv	0218010.08	Omrekeningsverschillen  ten dienste van de exploitatie	D	5	\N	t
673	1	BMvaOrzVvpOve	0218010.09	Overboekingen  ten dienste van de exploitatie	D	5	\N	t
674	1	BMvaOrzVvpOvm	0218010.10	Overige mutaties  ten dienste van de exploitatie	D	5	\N	t
675	1	BMvaOrzAkp	218015	Actuele kostprijs ten dienste van de exploitatie	D	4	\N	t
676	1	BMvaOrzAkpBeg	0218015.01	Beginbalans (overname eindsaldo vorig jaar)  ten dienste van de exploitatie	D	5	\N	t
677	1	BMvaOrzAkpIna	0218015.02	Investeringen  ten dienste van de exploitatie	D	5	\N	t
678	1	BMvaOrzAkpAdo	0218015.05	Verwervingen via fusies en overnames  ten dienste van de exploitatie	D	5	\N	t
679	1	BMvaOrzAkpDes	0218015.06	Desinvesteringen  ten dienste van de exploitatie	C	5	\N	t
680	1	BMvaOrzAkpDda	0218015.07	Afstotingen  ten dienste van de exploitatie	C	5	\N	t
681	1	BMvaOrzAkpOmv	0218015.08	Omrekeningsverschillen  ten dienste van de exploitatie	D	5	\N	t
682	1	BMvaOrzAkpOve	0218015.09	Overboekingen  ten dienste van de exploitatie	D	5	\N	t
683	1	BMvaOrzAkpOvm	0218015.10	Overige mutaties  ten dienste van de exploitatie	D	5	\N	t
684	1	BMvaOrzCae	218020	Cumulatieve afschrijvingen en waardeverminderingen  ten dienste van de exploitatie	C	4	\N	t
685	1	BMvaOrzCaeBeg	0218020.01	Beginbalans (overname eindsaldo vorig jaar)  ten dienste van de exploitatie	C	5	\N	t
686	1	BMvaOrzCaeAfs	0218020.02	Afschrijvingen niet aan de bedrijfsuitoefening  ten dienste van de exploitatie	C	5	\N	t
687	1	BMvaOrzCaeDca	0218020.03	Afschrijving op desinvesteringen  ten dienste van de exploitatie	D	5	\N	t
688	1	BMvaOrzCaeWvr	0218020.04	Bijzondere waardeverminderingen  ten dienste van de exploitatie	C	5	\N	t
689	1	BMvaOrzCaeTvw	0218020.05	Terugneming van bijzondere waardeverminderingen  ten dienste van de exploitatie	D	5	\N	t
690	1	BMvaOrzCaeOvm	0218020.06	Overige mutaties afschrijvingen  ten dienste van de exploitatie	C	5	\N	t
691	1	BMvaOrzCuh	218030	Cumulatieve herwaarderingen  ten dienste van de exploitatie	D	4	\N	t
692	1	BMvaOrzCuhBeg	0218030.01	Beginbalans (overname eindsaldo vorig jaar)  ten dienste van de exploitatie	D	5	\N	t
693	1	BMvaOrzCuhHer	0218030.02	Herwaarderingen  ten dienste van de exploitatie	D	5	\N	t
694	1	BMvaOrzCuhAfh	0218030.03	Afschrijving herwaarderingen  ten dienste van de exploitatie	C	5	\N	t
695	1	BMvaOrzCuhDeh	0218030.04	Desinvestering herwaarderingen  ten dienste van de exploitatie	C	5	\N	t
696	1	BMvaOrzCuhOvm	0218030.05	Overige mutaties herwaarderingen  ten dienste van de exploitatie	D	5	\N	t
697	1	BVas	02.01	Vastgoedbeleggingen	D	2	\N	t
698	1	BVasVio	0204000	Vastgoedbeleggingen in ontwikkeling bestemd voor eigen exploitatie	D	3	\N	t
699	1	BVasVioVvp	0204010	Kostprijs vastgoedbeleggingen in ontwikkeling	D	4	\N	t
700	1	BVasVioVvpBeg	0204010.01	Beginbalans (overname eindsaldo vorig jaar) vastgoedbeleggingen in ontwikkeling	D	5	\N	t
701	1	BVasVioVvpIna	0204010.02	Initiële verkrijgingen 	D	5	\N	t
702	1	BVasVioVvpInv	0204010.03	Investeringen	D	5	\N	t
703	1	BVasVioVvpIve	0204010.04	Inbreng vanuit vastgoed in exploitatie	D	5	\N	t
704	1	BVasVioVvpOpl	0204010.15	Oplevering naar vastgoed in exploitatie	C	5	\N	t
705	1	BVasVioVvpUne	0204010.11	Uitgaven na eerste waardering 	D	5	\N	t
706	1	BVasVioVvpAdo	0204010.05	Investeringen door overnames 	D	5	\N	t
707	1	BVasVioVvpHcv	0204010.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	D	5	\N	t
708	1	BVasVioVvpDes	0204010.06	Desinvesteringen 	C	5	\N	t
709	1	BVasVioVvpDda	0204010.13	Afstotingen	C	5	\N	t
710	1	BVasVioVvpOmv	0204010.08	Omrekeningsverschillen 	D	5	\N	t
711	1	BVasVioVvpOve	0204010.09	Overboekingen 	D	5	\N	t
712	1	BVasVioVvpOvm	0204010.10	Overige mutaties 	D	5	\N	t
713	1	BVasVioAkp	204015	Actuele kostprijs vastgoedbeleggingen in ontwikkeling	D	4	\N	t
714	1	BVasVioAkpBeg	0204015.01	Beginbalans (overname eindsaldo vorig jaar) vastgoedbeleggingen in ontwikkeling	D	5	\N	t
715	1	BVasVioAkpIna	0204015.02	Initiële verkrijgingen 	D	5	\N	t
716	1	BVasVioAkpUne	0204015.11	Uitgaven na eerste waardering 	D	5	\N	t
717	1	BVasVioAkpAdo	0204015.05	Investeringen door overnames 	D	5	\N	t
718	1	BVasVioAkpHcv	0204015.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	D	5	\N	t
719	1	BVasVioAkpDes	0204015.06	Desinvesteringen 	C	5	\N	t
720	1	BVasVioAkpDda	0204015.13	Afstotingen	C	5	\N	t
721	1	BVasVioAkpOmv	0204015.08	Omrekeningsverschillen 	D	5	\N	t
722	1	BVasVioAkpOve	0204015.09	Overboekingen 	D	5	\N	t
723	1	BVasVioAkpOvm	0204015.10	Overige mutaties 	D	5	\N	t
724	1	BVasVioCae	0204020	Cumulatieve afschrijvingen en waardeverminderingen 	C	4	\N	t
727	1	BVasVioCaeDca	0204020.03	Afschrijving op desinvesteringen 	D	5	\N	t
728	1	BVasVioCaeOnv	0204020.09	Overboeking investeringen naar voorziening (onttrekking)	C	5	\N	t
729	1	BVasVioCaeOpl	0204020.10	Oplevering naar vastgoed in exploitatie	C	5	\N	t
730	1	BVasVioCaeWvr	0204020.04	Bijzondere waardeverminderingen 	C	5	\N	t
731	1	BVasVioCaeTvw	0204020.05	Terugneming van bijzondere waardeverminderingen 	D	5	\N	t
732	1	BVasVioCaeOve	0204020.06	Overboeking van waardevermindering	D	5	\N	t
733	1	BVasVioCaeDes	0204020.07	Desinvestering van waardevermindering	D	5	\N	t
734	1	BVasVioCaeOvm	0204020.08	Overige mutaties waardevermindering	C	5	\N	t
735	1	BVasVioCuh	0204030	Cumulatieve herwaarderingen 	D	4	\N	t
736	1	BVasVioCuhBeg	0204030.01	Beginbalans (overname eindsaldo vorig jaar) 	D	5	\N	t
737	1	BVasVioCuhRaw	0204030.02	Resultaat als gevolg van aanpassingen van de reële waarde 	D	5	\N	t
738	1	BVasVioCuhHer	0204030.03	Herwaarderingen commercieel vastgoed in exploitatie	D	5	\N	t
739	1	BVasVioCuhDeh	0204030.04	Desinvestering herwaarderingen	C	5	\N	t
740	1	BVasVioCuhEfs	0204030.05	Effecten stelselwijziging	D	5	\N	t
741	1	BVasSvi	0205000	Vastgoedbeleggingen in exploitatie	D	3	\N	t
742	1	BVasSviVvp	0205010	Kostprijs vastgoedbeleggingen in exploitatie	D	4	\N	t
743	1	BVasSviVvpBeg	0205010.01	Beginbalans (overname eindsaldo vorig jaar) vastgoedbeleggingen in exploitatie	D	5	\N	t
744	1	BVasSviVvpIna	0205010.02	Initiële verkrijgingen 	D	5	\N	t
745	1	BVasSviVvpVio	0205010.15	Overboekingen van vastgoed in ontwikkeling	D	5	\N	t
746	1	BVasSviVvpUne	0205010.11	Uitgaven na eerste waardering 	D	5	\N	t
747	1	BVasSviVvpAdo	0205010.05	Investeringen door overnames 	D	5	\N	t
748	1	BVasSviVvpHcv	0205010.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	D	5	\N	t
749	1	BVasSviVvpOio	0205010.16	Overboekingen naar vastgoed in ontwikkeling bestemd voor eigen exploitaties	C	5	\N	t
750	1	BVasSviVvpOvr	0205010.17	Overboekingen van en naar voorraden en vastgoed voor eigen gebruik	D	5	\N	t
751	1	BVasSviVvpDes	0205010.06	Desinvesteringen 	C	5	\N	t
752	1	BVasSviVvpDda	0205010.13	Afstotingen	C	5	\N	t
753	1	BVasSviVvpOmv	0205010.08	Omrekeningsverschillen 	D	5	\N	t
754	1	BVasSviVvpOve	0205010.09	Overboekingen 	D	5	\N	t
755	1	BVasSviVvpOvm	0205010.10	Overige mutaties 	D	5	\N	t
756	1	BVasSviVvpHnd	0205010.14	Herclassificaties naar vastgoed Niet Daeb	C	5	\N	t
757	1	BVasSviVvpHvd	0205010.18	Herclassificaties van vastgoed Niet Daeb	D	5	\N	t
758	1	BVasSviAkp	205015	Actuele kostprijs vastgoedbeleggingen in exploitatie	D	4	\N	t
759	1	BVasSviAkpBeg	0205015.01	Beginbalans (overname eindsaldo vorig jaar) vastgoedbeleggingen in exploitatie	D	5	\N	t
760	1	BVasSviAkpIna	0205015.02	Initiële verkrijgingen 	D	5	\N	t
761	1	BVasSviAkpUne	0205015.11	Uitgaven na eerste waardering 	D	5	\N	t
762	1	BVasSviAkpAdo	0205015.05	Investeringen door overnames 	D	5	\N	t
763	1	BVasSviAkpHcv	0205015.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	D	5	\N	t
764	1	BVasSviAkpDes	0205015.06	Desinvesteringen 	C	5	\N	t
765	1	BVasSviAkpDda	0205015.13	Afstotingen	C	5	\N	t
766	1	BVasSviAkpOmv	0205015.08	Omrekeningsverschillen 	D	5	\N	t
767	1	BVasSviAkpOve	0205015.09	Overboekingen 	D	5	\N	t
768	1	BVasSviAkpOvm	0205015.10	Overige mutaties 	D	5	\N	t
769	1	BVasSviAkpHnd	0205015.14	Herclassificaties van en naar vastgoed Niet Daeb	D	5	\N	t
770	1	BVasSviCae	0205020	Cumulatieve afschrijvingen en waardeverminderingen 	C	4	\N	t
771	1	BVasSviCaeBeg	0205020.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
772	1	BVasSviCaeAfs	0205020.02	Afschrijvingen 	C	5	\N	t
773	1	BVasSviCaeDca	0205020.03	Afschrijving op desinvesteringen 	D	5	\N	t
774	1	BVasSviCaeWvr	0205020.04	Bijzondere waardeverminderingen 	C	5	\N	t
775	1	BVasSviCaeTvw	0205020.05	Terugneming van bijzondere waardeverminderingen 	D	5	\N	t
776	1	BVasSviCaeDes	0205020.06	Desinvesteringen bijzondere waardeverminderingen	D	5	\N	t
777	1	BVasSviCaeHcb	0205020.07	Herclassificatie bijzondere waardevermindering en afschrijving	C	5	\N	t
778	1	BVasSviCuh	0205030	Cumulatieve herwaarderingen 	D	4	\N	t
779	1	BVasSviCuhBeg	0205030.01	Beginbalans (overname eindsaldo vorig jaar) 	D	5	\N	t
780	1	BVasSviCuhRaw	0205030.02	Resultaat als gevolg van aanpassingen van de reële waarde 	D	5	\N	t
781	1	BVasSviCuhHer	0205030.03	Herwaarderingen sociaal vastgoed in exploitatie	D	5	\N	t
782	1	BVasSviCuhVio	0205030.07	Overboekingen van vastgoed ontwikkeling herwaardering	D	5	\N	t
783	1	BVasSviCuhDeh	0205030.04	Desinvestering herwaarderingen	C	5	\N	t
784	1	BVasSviCuhHch	0205030.05	Herclassificatie herwaarderingen	D	5	\N	t
785	1	BVasSviCuhHvn	0205030.08	Herclassificatie herwaarderingen van en naar vastgoed verkocht onder voorwaarden	D	5	\N	t
786	1	BVasSviCuhOio	0205030.09	Overboekingen naar vastgoed in ontwikkeling bestemd voor eigen exploitatie	D	5	\N	t
787	1	BVasSviCuhOvr	0205030.10	Overboekingen van en naar voorraden en vastgoed voor eigen gebruik	D	5	\N	t
788	1	BVasSviCuhHvd	0205030.11	Herclassificatie herwaarderingen van vastgoed Niet Daeb	D	5	\N	t
789	1	BVasSviCuhHnd	0205030.12	Herclassificatie herwaarderingen naar vastgoed Niet Daeb	C	5	\N	t
790	1	BVasSviCuhOvm	0205030.13	Overige mutaties	D	5	\N	t
791	1	BVasSviCuhEfs	0205030.06	Effecten stelselwijziging	D	5	\N	t
792	1	BVasCvi	0206000	Niet -Daeb-vastgoed in exploitatie	D	3	\N	t
793	1	BVasCviVvp	0206010	Kostprijs Niet-Daeb- vastgoed in exploitatie	D	4	\N	t
794	1	BVasCviVvpBeg	0206010.01	Beginbalans commercieel vastgoed in exploitatie	D	5	\N	t
795	1	BVasCviVvpIna	0206010.02	Initiële verkrijgingen 	D	5	\N	t
796	1	BVasCviVvpUne	0206010.11	Uitgaven na eerste waardering 	D	5	\N	t
797	1	BVasCviVvpVio	0206010.15	Overboekingen van vastgoed ontwikkeling niet-Daeb	D	5	\N	t
798	1	BVasCviVvpAdo	0206010.05	Aankopen door overnames commercieel vastgoed in exploitatie	D	5	\N	t
799	1	BVasCviVvpHcv	0206010.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	D	5	\N	t
800	1	BVasCviVvpOio	0206010.16	Overboekingen naar vastgoed ontwikkeling bestemd voor eigen exploitatie	C	5	\N	t
801	1	BVasCviVvpOvr	0206010.17	Overboekingen van en naar voorraden en vastgoed voor eigen gebruik	D	5	\N	t
802	1	BVasCviVvpHvd	0206010.18	Herclassificaties van vastgoed Daeb	D	5	\N	t
803	1	BVasCviVvpDes	0206010.06	Desinvesteringen commercieel vastgoed in exploitatie	C	5	\N	t
804	1	BVasCviVvpDda	0206010.13	Afstotingen	C	5	\N	t
805	1	BVasCviVvpOmv	0206010.08	Omrekeningsverschillen commercieel vastgoed in exploitatie	D	5	\N	t
806	1	BVasCviVvpOve	0206010.09	Overboekingen commercieel vastgoed in exploitatie	D	5	\N	t
807	1	BVasCviVvpOvm	0206010.10	Overige mutaties commercieel vastgoed in exploitatie	D	5	\N	t
808	1	BVasCviVvpHcd	0206010.14	Herclassificaties naar vastgoed Daeb	D	5	\N	t
809	1	BVasCviAkp	206015	Actuele kostprijs Niet-Daeb- vastgoed in exploitatie	D	4	\N	t
810	1	BVasCviAkpBeg	0206015.01	Beginbalans commercieel vastgoed in exploitatie	D	5	\N	t
811	1	BVasCviAkpIna	0206015.02	Initiële verkrijgingen 	D	5	\N	t
812	1	BVasCviAkpUne	0206015.11	Uitgaven na eerste waardering 	D	5	\N	t
813	1	BVasCviAkpAdo	0206015.05	Aankopen door overnames commercieel vastgoed in exploitatie	D	5	\N	t
814	1	BVasCviAkpHcv	0206015.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	D	5	\N	t
815	1	BVasCviAkpDes	0206015.06	Desinvesteringen commercieel vastgoed in exploitatie	C	5	\N	t
816	1	BVasCviAkpDda	0206015.13	Afstotingen	C	5	\N	t
817	1	BVasCviAkpOmv	0206015.08	Omrekeningsverschillen commercieel vastgoed in exploitatie	D	5	\N	t
818	1	BVasCviAkpOve	0206015.09	Overboekingen commercieel vastgoed in exploitatie	D	5	\N	t
819	1	BVasCviAkpOvm	0206015.10	Overige mutaties commercieel vastgoed in exploitatie	D	5	\N	t
820	1	BVasCviAkpHcd	0206015.14	Herclassificaties van en naar vastgoed Daeb	D	5	\N	t
821	1	BVasCviCae	0206020	Cumulatieve afschrijvingen en waardeverminderingen Niet-Daeb-vastgoed in exploitatie	C	4	\N	t
822	1	BVasCviCaeBeg	0206020.01	Beginbalans commercieel vastgoed in exploitatie	C	5	\N	t
823	1	BVasCviCaeAfs	0206020.02	Afschrijvingen commercieel vastgoed in exploitatie	C	5	\N	t
824	1	BVasCviCaeDca	0206020.03	Desinvestering cumulatieve afschrijvingen en waardeverminderingen commercieel vastgoed in exploitatie	D	5	\N	t
825	1	BVasCviCaeWvr	0206020.04	Waardeverminderingen commercieel vastgoed in exploitatie	C	5	\N	t
826	1	BVasCviCaeTvw	0206020.05	Terugneming van waardeverminderingen commercieel vastgoed in exploitatie	D	5	\N	t
827	1	BVasCviCaeDes	0206020.06	Desinvesteringen bijzondere waardeverminderingen	D	5	\N	t
828	1	BVasCviCaeHcb	0206020.07	Herclassificatie bijzondere waardevermindering en afschrijving	C	5	\N	t
829	1	BVasCviCuh	0206030	Cumulatieve herwaarderingen Niet-Daeb-vastgoed in exploitatie	D	4	\N	t
830	1	BVasCviCuhBeg	0206030.01	Beginbalans commercieel vastgoed in exploitatie	D	5	\N	t
831	1	BVasCviCuhRaw	0206030.02	Resultaat als gevolg van aanpassingen van de reële waarde 	D	5	\N	t
832	1	BVasCviCuhHer	0206030.03	Herwaarderingen commercieel vastgoed in exploitatie	D	5	\N	t
833	1	BVasCviCuhVio	0206030.07	Overboekingen van vastgoed ontwikkeling herwaardering	D	5	\N	t
834	1	BVasCviCuhDeh	0206030.04	Desinvestering herwaarderingen	C	5	\N	t
835	1	BVasCviCuhHch	0206030.05	Herclassificatie herwaarderingen	D	5	\N	t
836	1	BVasCviCuhHvn	0206030.08	Herclassificatie herwaarderingen van en naar vastgoed verkocht onder voorwaarden niet-Daeb	D	5	\N	t
837	1	BVasCviCuhOio	0206030.09	Overboekingen naar vastgoed in ontwikkeling bestemd voor eigen exploitatie niet-Daeb	C	5	\N	t
838	1	BVasCviCuhOvr	0206030.10	Overboekingen van en naar voorraden en vastgoed voor eigen gebruik niet-Daeb	D	5	\N	t
839	1	BVasCviCuhHvd	0206030.11	Herclassificatie herwaarderingen van vastgoed Daeb	D	5	\N	t
840	1	BVasCviCuhHnd	0206030.12	Herclassificatie herwaarderingen naar vastgoed Daeb	C	5	\N	t
841	1	BVasCviCuhOvm	0206030.13	Overige mutaties niet-Daeb	D	5	\N	t
842	1	BVasCviCuhEfs	0206030.06	Effecten stelselwijziging	D	5	\N	t
843	1	BVasOzv	0207000	Onroerende zaken verkocht onder voorwaarden	D	3	\N	t
844	1	BVasOzvVvp	0207010	Verkrijgings- of vervaardigingsprijs onroerende zaken verkocht onder voorwaarden	D	4	\N	t
845	1	BVasOzvVvpBeg	0207010.01	Beginbalans onroerende zaken verkocht onder voorwaarden	D	5	\N	t
846	1	BVasOzvVvpIna	0207010.02	Investeringen nieuw aangeschaft onroerende zaken verkocht onder voorwaarden	D	5	\N	t
847	1	BVasOzvVvpUne	0207010.11	Uitgaven na eerste waardering 	D	5	\N	t
848	1	BVasOzvVvpAdo	0207010.05	Aankopen door overnames onroerende zaken verkocht onder voorwaarden	D	5	\N	t
849	1	BVasOzvVvpHcv	0207010.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	D	5	\N	t
850	1	BVasOzvVvpDes	0207010.06	Desinvesteringen onroerende zaken verkocht onder voorwaarden	C	5	\N	t
851	1	BVasOzvVvpDda	0207010.13	Afstotingen	C	5	\N	t
852	1	BVasOzvVvpOmv	0207010.08	Omrekeningsverschillen onroerende zaken verkocht onder voorwaarden	D	5	\N	t
1172	1	BFvaOvrLvlBeg	0309024.12	Overige mutaties vorderingen op lid 2	D	5	\N	t
853	1	BVasOzvVvpOve	0207010.09	Overboekingen onroerende zaken verkocht onder voorwaarden	D	5	\N	t
854	1	BVasOzvVvpOvm	0207010.10	Overige mutaties onroerende zaken verkocht onder voorwaarden	D	5	\N	t
855	1	BVasOzvAkp	207015	Actuele kostprijs onroerende zaken verkocht onder voorwaarden	D	4	\N	t
856	1	BVasOzvAkpBeg	0207015.01	Beginbalans onroerende zaken verkocht onder voorwaarden	D	5	\N	t
857	1	BVasOzvAkpIna	0207015.02	Investeringen nieuw aangeschaft onroerende zaken verkocht onder voorwaarden	D	5	\N	t
858	1	BVasOzvAkpUne	0207015.11	Uitgaven na eerste waardering 	D	5	\N	t
859	1	BVasOzvAkpAdo	0207015.05	Aankopen door overnames onroerende zaken verkocht onder voorwaarden	D	5	\N	t
860	1	BVasOzvAkpHcv	0207015.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	D	5	\N	t
861	1	BVasOzvAkpDes	0207015.06	Desinvesteringen onroerende zaken verkocht onder voorwaarden	C	5	\N	t
862	1	BVasOzvAkpDda	0207015.13	Afstotingen	C	5	\N	t
863	1	BVasOzvAkpOmv	0207015.08	Omrekeningsverschillen onroerende zaken verkocht onder voorwaarden	D	5	\N	t
864	1	BVasOzvAkpOve	0207015.09	Overboekingen onroerende zaken verkocht onder voorwaarden	D	5	\N	t
865	1	BVasOzvAkpOvm	0207015.10	Overige mutaties onroerende zaken verkocht onder voorwaarden	D	5	\N	t
866	1	BVasOzvCae	0207020	Cumulatieve afschrijvingen en waardeverminderingen onroerende zaken verkocht onder voorwaarden	C	4	\N	t
867	1	BVasOzvCaeBeg	0207020.01	Beginbalans onroerende zaken verkocht onder voorwaarden	C	5	\N	t
868	1	BVasOzvCaeAfs	0207020.02	Afschrijvingen onroerende zaken verkocht onder voorwaarden	C	5	\N	t
869	1	BVasOzvCaeDca	0207020.03	Desinvestering cumulatieve afschrijvingen en waardeverminderingen onroerende zaken verkocht onder voorwaarden	D	5	\N	t
870	1	BVasOzvCaeWvr	0207020.04	Waardeverminderingen onroerende zaken verkocht onder voorwaarden	C	5	\N	t
871	1	BVasOzvCaeTvw	0207020.05	Terugneming van waardeverminderingen onroerende zaken verkocht onder voorwaarden	D	5	\N	t
872	1	BVasOzvCuh	0207030	Cumulatieve herwaarderingen onroerende zaken verkocht onder voorwaarden	D	4	\N	t
873	1	BVasOzvCuhBeg	0207030.01	Beginbalans onroerende zaken verkocht onder voorwaarden	D	5	\N	t
874	1	BVasOzvCuhRaw	0207030.02	Resultaat als gevolg van aanpassingen van de reële waarde 	D	5	\N	t
875	1	BVasOzvCuhHer	0207030.03	Herwaarderingen onroerende zaken verkocht onder voorwaarden	D	5	\N	t
876	1	BVasOzvCuhDeh	0207030.04	Desinvestering herwaarderingen	C	5	\N	t
877	1	BVasOzvCuhHch	0207030.05	Herclassificatie herwaarderingen	D	5	\N	t
878	1	BVasOzvCuhEfs	0207030.06	Effecten stelselwijziging	D	5	\N	t
879	1	BFva	03	Financiële vaste activa	D	2	\N	t
880	1	BFvaDig	0301000	Deelnemingen in groepsmaatschappijen	D	3	\N	t
881	1	BFvaDigNev	0301010	Verkrijgingsprijs deelnemingen in groepsmaatschappijen	D	4	\N	t
882	1	BFvaDigNevBeg	0301010.01	Beginbalans (overname eindsaldo vorig jaar) deelnemingen in groepsmaatschappijen	D	5	\N	t
883	1	BFvaDigNevInv	0301010.02	Investeringen deelnemingen in groepsmaatschappijen	D	5	\N	t
884	1	BFvaDigNevAdo	0301010.03	Bij overname verkregen activa deelnemingen in groepsmaatschappijen	D	5	\N	t
885	1	BFvaDigNevDes	0301010.04	Desinvesteringen deelnemingen in groepsmaatschappijen	C	5	\N	t
886	1	BFvaDigNevDda	0301010.05	Afstotingen deelnemingen in groepsmaatschappijen	C	5	\N	t
887	1	BFvaDigNevOmv	0301010.09	Omrekeningsverschillen deelnemingen in groepsmaatschappijen	D	5	\N	t
888	1	BFvaDigNevOvm	0301010.10	Overige mutaties deelnemingen in groepsmaatschappijen	D	5	\N	t
889	1	BFvaDigCae	0301020	Cumulatieve afschrijvingen en waardeverminderingen deelnemingen in groepsmaatschappijen	C	4	\N	t
890	1	BFvaDigCaeBeg	0301020.01	Beginbalans (overname eindsaldo vorig jaar) deelnemingen in groepsmaatschappijen	C	5	\N	t
891	1	BFvaDigCaeAfs	0301020.02	Afschrijvingen deelnemingen in groepsmaatschappijen	C	5	\N	t
892	1	BFvaDigCaeDca	0301020.03	Afschrijving op desinvesteringen deelnemingen in groepsmaatschappijen	D	5	\N	t
893	1	BFvaDigCaeWvr	0301020.04	Bijzondere waardeverminderingen deelnemingen in groepsmaatschappijen	C	5	\N	t
894	1	BFvaDigCaeTvw	0301020.05	Terugneming van bijzondere waardeverminderingen deelnemingen in groepsmaatschappijen	D	5	\N	t
895	1	BFvaDigCuh	0301030	Cumulatieve herwaarderingen deelnemingen in groepsmaatschappijen	D	4	\N	t
896	1	BFvaDigCuhBeg	0301030.01	Beginbalans (overname eindsaldo vorig jaar) deelnemingen in groepsmaatschappijen	D	5	\N	t
897	1	BFvaDigCuhHer	0301030.02	Herwaarderingen deelnemingen in groepsmaatschappijen	D	5	\N	t
898	1	BFvaDigCuhAir	0301030.05	Aandeel in resultaat deelnemingen deelnemingen in groepsmaatschappijen	D	5	\N	t
899	1	BFvaDigCuhDvd	0301030.06	Dividend van deelnemingen deelnemingen in groepsmaatschappijen	D	5	\N	t
900	1	BFvaDigCuhAfh	0301030.07	Afschrijving herwaardering	C	5	\N	t
901	1	BFvaDigCuhOvm	0301030.09	Overige mutaties waardeveranderingen	D	5	\N	t
902	1	BFvaDigCuhDeh	0301030.08	Desinvestering herwaardering	D	5	\N	t
903	1	BFvaDio	0302000	Deelnemingen in overige verbonden maatschappijen	D	3	\N	t
904	1	BFvaDioNev	0302020	Verkrijgingsprijs deelnemingen in overige verbonden maatschappijen	D	4	\N	t
905	1	BFvaDioNevBeg	0302020.01	Beginbalans (overname eindsaldo vorig jaar) deelnemingen in overige verbonden maatschappijen	D	5	\N	t
906	1	BFvaDioNevInv	0302020.02	Investeringen deelnemingen in overige verbonden maatschappijen	D	5	\N	t
907	1	BFvaDioNevAdo	0302020.03	Bij overname verkregen activa deelnemingen in overige verbonden maatschappijen	D	5	\N	t
908	1	BFvaDioNevDes	0302020.04	Desinvesteringen deelnemingen in overige verbonden maatschappijen	C	5	\N	t
909	1	BFvaDioNevDda	0302020.05	Afstotingen deelnemingen in overige verbonden maatschappijen	C	5	\N	t
1173	1	BFvaOvrLvlBeh	0309024.13	Overige mutaties vorderingen op lid 3	D	5	\N	t
910	1	BFvaDioNevOmv	0302020.09	Omrekeningsverschillen deelnemingen in overige verbonden maatschappijen	D	5	\N	t
911	1	BFvaDioNevOvm	0302020.10	Overige mutaties deelnemingen in overige verbonden maatschappijen	D	5	\N	t
912	1	BFvaDioCae	0302030	Cumulatieve afschrijvingen en waardeverminderingen deelnemingen in overige verbonden maatschappijen	C	4	\N	t
913	1	BFvaDioCaeBeg	0302030.01	Beginbalans (overname eindsaldo vorig jaar) deelnemingen in overige verbonden maatschappijen	C	5	\N	t
914	1	BFvaDioCaeAfs	0302030.02	Afschrijvingen deelnemingen in overige verbonden maatschappijen	C	5	\N	t
915	1	BFvaDioCaeDca	0302030.03	Afschrijving op desinvesteringen deelnemingen in overige verbonden maatschappijen	D	5	\N	t
916	1	BFvaDioCaeWvr	0302030.04	Bijzondere waardeverminderingen deelnemingen in overige verbonden maatschappijen	C	5	\N	t
917	1	BFvaDioCaeTvw	0302030.05	Terugneming van bijzondere waardeverminderingen deelnemingen in overige verbonden maatschappijen	D	5	\N	t
918	1	BFvaDioCuh	0302040	Cumulatieve herwaarderingen deelnemingen in overige verbonden maatschappijen	D	4	\N	t
919	1	BFvaDioCuhBeg	0302040.01	Beginbalans (overname eindsaldo vorig jaar) deelnemingen in overige verbonden maatschappijen	D	5	\N	t
920	1	BFvaDioCuhHer	0302040.02	Herwaarderingen deelnemingen in overige verbonden maatschappijen	D	5	\N	t
921	1	BFvaDioCuhAir	0302040.05	Aandeel in resultaat deelnemingen deelnemingen in overige verbonden maatschappijen	D	5	\N	t
922	1	BFvaDioCuhDvd	0302040.06	Dividend van deelnemingen deelnemingen in overige verbonden maatschappijen	D	5	\N	t
923	1	BFvaVog	0305000	Vorderingen op groepsmaatschappijen	D	3	\N	t
924	1	BFvaVogVgl	0305010	Verkrijgingsprijs vorderingen op groepsmaatschappijen	D	4	\N	t
925	1	BFvaVogVglBeg	0305010.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op groepsmaatschappijen	D	5	\N	t
926	1	BFvaVogVglVer	0305010.02	Investeringen vorderingen op groepsmaatschappijen	D	5	\N	t
927	1	BFvaVogVglSto	0305010.14	Stortingen / ontvangen 	D	5	\N	t
928	1	BFvaVogVglBta	0305010.15	Betalingen / aflossingen	C	5	\N	t
929	1	BFvaVogVglAfl	0305010.03	Aflossingen vorderingen op groepsmaatschappijen (langlopend)	C	5	\N	t
930	1	BFvaVogVglRen	0305010.13	Rente vorderingen op groepsmaatschappijen (langlopend)	D	5	\N	t
931	1	BFvaVogVglAdo	0305010.04	Bij overname verkregen activa vorderingen op groepsmaatschappijen	D	5	\N	t
932	1	BFvaVogVglDes	0305010.11	Desinvesteringen vorderingen op groepsmaatschappijen	C	5	\N	t
933	1	BFvaVogVglDda	0305010.12	Afstotingen vorderingen op groepsmaatschappijen	C	5	\N	t
934	1	BFvaVogVglOmv	0305010.08	Omrekeningsverschillen vorderingen op groepsmaatschappijen	D	5	\N	t
935	1	BFvaVogVglOvm	0305010.10	Overige mutaties vorderingen op groepsmaatschappijen	D	5	\N	t
936	1	BFvaVogCae	305020	Cumulatieve afschrijvingen en waardeverminderingen vorderingen op groepsmaatschappijen	C	4	\N	t
937	1	BFvaVogCaeBeg	0305020.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op groepsmaatschappijen	C	5	\N	t
938	1	BFvaVogCaeKod	0305020.02	Kortlopend deel vorderingen op groepsmaatschappijen (langlopend)	C	5	\N	t
939	1	BFvaVogCaeAfs	0305020.03	Afschrijvingen vorderingen op groepsmaatschappijen	C	5	\N	t
940	1	BFvaVogCaeDca	0305020.04	Afschrijving op desinvesteringen vorderingen op groepsmaatschappijen	D	5	\N	t
941	1	BFvaVogCaeWvr	0305020.05	Bijzondere waardeverminderingen vorderingen op groepsmaatschappijen	C	5	\N	t
942	1	BFvaVogCaeTvw	0305020.06	Terugneming van bijzondere waardeverminderingen vorderingen op groepsmaatschappijen	D	5	\N	t
943	1	BFvaVogCuh	305030	Cumulatieve herwaarderingen vorderingen op groepsmaatschappijen	D	4	\N	t
944	1	BFvaVogCuhBeg	0305030.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op groepsmaatschappijen	D	5	\N	t
945	1	BFvaVogCuhHer	0305030.02	Herwaarderingen vorderingen op groepsmaatschappijen	D	5	\N	t
946	1	BFvaVogCuhAir	0305030.05	Aandeel in resultaat deelnemingen vorderingen op groepsmaatschappijen	D	5	\N	t
947	1	BFvaVogCuhDvd	0305030.06	Dividend van deelnemingen vorderingen op groepsmaatschappijen	D	5	\N	t
948	1	BFvaVogCuhAfh	0305030.07	Afschrijving herwaardering vorderingen op groepsmaatschappijen	C	5	\N	t
949	1	BFvaVogCuhOvm	0305030.09	Overige mutaties waardeveranderingen vorderingen op groepsmaatschappijen	D	5	\N	t
950	1	BFvaVogCuhDeh	0305030.08	Desinvestering herwaardering vorderingen op groepsmaatschappijen	D	5	\N	t
951	1	BFvaVov	0307000	Vorderingen op overige verbonden maatschappijen	D	3	\N	t
952	1	BFvaVovVol	0307010	Verkrijgingsprijs vorderingen op overige verbonden maatschappijen	D	4	\N	t
953	1	BFvaVovVolBeg	0307010.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op overige verbonden maatschappijen	D	5	\N	t
954	1	BFvaVovVolVer	0307010.02	Investeringen vorderingen op overige verbonden maatschappijen	D	5	\N	t
955	1	BFvaVovVolSto	0307010.14	Stortingen / ontvangen op overige verbonden maatschappijen 	D	5	\N	t
956	1	BFvaVovVolBta	0307010.15	Betalingen / aflossingen op overige verbonden maatschappijen	C	5	\N	t
957	1	BFvaVovVolAfl	0307010.03	Aflossingen vorderingen op overige verbonden maatschappijen (langlopend)	D	5	\N	t
958	1	BFvaVovVolAdo	0307010.04	Bij overname verkregen activa vorderingen op overige verbonden maatschappijen	D	5	\N	t
959	1	BFvaVovVolDes	0307010.11	Desinvesteringen vorderingen op overige verbonden maatschappijen	C	5	\N	t
960	1	BFvaVovVolDda	0307010.12	Afstotingen vorderingen op overige verbonden maatschappijen	C	5	\N	t
961	1	BFvaVovVolOmv	0307010.08	Omrekeningsverschillen vorderingen op overige verbonden maatschappijen	D	5	\N	t
962	1	BFvaVovVolOvm	0307010.10	Overige mutaties vorderingen op overige verbonden maatschappijen	D	5	\N	t
963	1	BFvaVovCae	307020	Cumulatieve afschrijvingen en waardeverminderingen vorderingen op overige verbonden maatschappijen	C	4	\N	t
1174	1	BFvaOvrLvlBei	0309024.14	Overige mutaties vorderingen op lid 4	D	5	\N	t
964	1	BFvaVovCaeBeg	0307020.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op overige verbonden maatschappijen	C	5	\N	t
965	1	BFvaVovCaeKod	0307020.02	Kortlopend deel vorderingen op overige verbonden maatschappijen (langlopend)	C	5	\N	t
966	1	BFvaVovCaeAfs	0307020.03	Afschrijvingen vorderingen op overige verbonden maatschappijen	C	5	\N	t
967	1	BFvaVovCaeDca	0307020.04	Afschrijving op desinvesteringen vorderingen op overige verbonden maatschappijen	D	5	\N	t
968	1	BFvaVovCaeWvr	0307020.05	Bijzondere waardeverminderingen vorderingen op overige verbonden maatschappijen	C	5	\N	t
969	1	BFvaVovCaeTvw	0307020.06	Terugneming van bijzondere waardeverminderingen vorderingen op overige verbonden maatschappijen	D	5	\N	t
970	1	BFvaVovCuh	307030	Cumulatieve herwaarderingen vorderingen op overige verbonden maatschappijen	D	4	\N	t
971	1	BFvaVovCuhBeg	0307030.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op overige verbonden maatschappijen	D	5	\N	t
972	1	BFvaVovCuhHer	0307030.02	Herwaarderingen vorderingen op overige verbonden maatschappijen	D	5	\N	t
973	1	BFvaVovCuhAir	0307030.05	Aandeel in resultaat deelnemingen vorderingen op overige verbonden maatschappijen	D	5	\N	t
974	1	BFvaVovCuhDvd	0307030.06	Dividend van deelnemingen vorderingen op overige verbonden maatschappijen	D	5	\N	t
975	1	BFvaAnd	0303000	Overige deelnemingen	D	3	\N	t
976	1	BFvaAndKpr	0303010	Verkrijgingsprijs overige deelnemingen	D	4	\N	t
977	1	BFvaAndKprBeg	0303010.01	Beginbalans (overname eindsaldo vorig jaar) overige deelnemingen	D	5	\N	t
978	1	BFvaAndKprInv	0303010.02	Investeringen overige deelnemingen	D	5	\N	t
979	1	BFvaAndKprAdo	0303010.03	Bij overname verkregen activa overige deelnemingen	D	5	\N	t
980	1	BFvaAndKprAfl	0303010.06	Aflossingen andere deelnemingen	C	5	\N	t
981	1	BFvaAndKprRen	0303010.09	Rente andere deelnemingen	D	5	\N	t
982	1	BFvaAndKprDes	0303010.04	Desinvesteringen overige deelnemingen	C	5	\N	t
983	1	BFvaAndKprDda	0303010.05	Afstotingen overige deelnemingen	C	5	\N	t
984	1	BFvaAndKprOmv	0303010.07	Omrekeningsverschillen overige deelnemingen	D	5	\N	t
985	1	BFvaAndKprOvm	0303010.08	Overige mutaties overige deelnemingen	D	5	\N	t
986	1	BFvaAndCae	0303020	Cumulatieve afschrijvingen en waardeverminderingen overige deelnemingen	C	4	\N	t
987	1	BFvaAndCaeBeg	0303020.01	Beginbalans (overname eindsaldo vorig jaar) overige deelnemingen	C	5	\N	t
988	1	BFvaAndCaeAfs	0303020.02	Afschrijvingen overige deelnemingen	C	5	\N	t
989	1	BFvaAndCaeDca	0303020.03	Afschrijving op desinvesteringen overige deelnemingen	D	5	\N	t
990	1	BFvaAndCaeWvr	0303020.04	Bijzondere waardeverminderingen overige deelnemingen	C	5	\N	t
991	1	BFvaAndCaeTvw	0303020.05	Terugneming van bijzondere waardeverminderingen overige deelnemingen	D	5	\N	t
992	1	BFvaAndCuh	0303030	Cumulatieve herwaarderingen overige deelnemingen	D	4	\N	t
993	1	BFvaAndCuhBeg	0303030.01	Beginbalans (overname eindsaldo vorig jaar) overige deelnemingen	D	5	\N	t
994	1	BFvaAndCuhHer	0303030.02	Herwaarderingen andere deelnemingen	D	5	\N	t
995	1	BFvaAndCuhAir	0303030.05	Aandeel in resultaat deelnemingen overige deelnemingen	D	5	\N	t
996	1	BFvaAndCuhDvd	0303030.06	Dividend van deelnemingen overige deelnemingen	D	5	\N	t
997	1	BFvaAndCuhAfh	0303030.07	Afschrijving herwaardering overige deelnemingen	C	5	\N	t
998	1	BFvaAndCuhOvm	0303030.09	Overige mutaties waardeveranderingen overige deelnemingen	D	5	\N	t
999	1	BFvaAndCuhDeh	0303030.08	Desinvestering herwaardering overige deelnemingen	D	5	\N	t
1000	1	BFvaVop	0306000	Vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	3	\N	t
1001	1	BFvaVopVpl	0306010	Verkrijgingsprijs vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	4	\N	t
1002	1	BFvaVopVplBeg	0306010.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1003	1	BFvaVopVplVer	0306010.02	Investeringen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1004	1	BFvaVopVplSto	0306010.14	Stortingen / ontvangen  vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1005	1	BFvaVopVplBta	0306010.15	Betalingen / aflossingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	C	5	\N	t
1006	1	BFvaVopVplAfl	0306010.03	Aflossingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen (langlopend)	C	5	\N	t
1007	1	BFvaVopVplRen	0306010.13	Rente vorderingen op participnaten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1008	1	BFvaVopVplAdo	0306010.04	Bij overname verkregen activa vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1009	1	BFvaVopVplDes	0306010.11	Desinvesteringen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	C	5	\N	t
1010	1	BFvaVopVplDda	0306010.12	Afstotingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	C	5	\N	t
1011	1	BFvaVopVplOmv	0306010.08	Omrekeningsverschillen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1012	1	BFvaVopVplOvm	0306010.10	Overige mutaties vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1013	1	BFvaVopCae	306020	Cumulatieve afschrijvingen en waardeverminderingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	C	4	\N	t
1014	1	BFvaVopCaeBeg	0306020.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	C	5	\N	t
1015	1	BFvaVopCaeKod	0306010.09	Kortlopend deel vorderingen op participanten en op maatschappijen waarin wordt deelgenomen (langlopend)	C	5	\N	t
1016	1	BFvaVopCaeAfs	0306020.03	Afschrijvingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	C	5	\N	t
1175	1	BFvaOvrLvlBej	0309024.15	Overige mutaties vorderingen op lid 5	D	5	\N	t
1017	1	BFvaVopCaeDca	0306020.04	Afschrijving op desinvesteringen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1018	1	BFvaVopCaeWvr	0306010.05	Bijzondere waardeverminderingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	C	5	\N	t
1019	1	BFvaVopCaeTvw	0306010.06	Terugneming van bijzondere waardeverminderingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1020	1	BFvaVopCuh	306030	Cumulatieve herwaarderingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	4	\N	t
1021	1	BFvaVopCuhBeg	0306030.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1022	1	BFvaVopCuhHer	0306030.02	Herwaarderingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1023	1	BFvaVopCuhAir	0306030.05	Aandeel in resultaat deelnemingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1024	1	BFvaVopCuhDvd	0306030.06	Dividend van deelnemingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1025	1	BFvaVopCuhAfh	0306030.07	Afschrijving herwaardering vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	C	5	\N	t
1026	1	BFvaVopCuhOvm	0306030.09	Overige mutaties waardeveranderingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1027	1	BFvaVopCuhDeh	0306030.08	Desinvestering herwaardering vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	D	5	\N	t
1028	1	BFvaOve	0304000	Overige effecten (langlopend)	D	3	\N	t
1029	1	BFvaOveWaa	0304010	Verkrijgingsprijs overige effecten (langlopend)	D	4	\N	t
1030	1	BFvaOveWaaBeg	0304010.01	Beginbalans (overname eindsaldo vorig jaar) overige effecten (langlopend)	D	5	\N	t
1031	1	BFvaOveWaaInv	0304010.02	Investeringen overige effecten (langlopend)	D	5	\N	t
1032	1	BFvaOveWaaAdo	0304010.08	Bij overname verkregen activa overige effecten (langlopend)	D	5	\N	t
1033	1	BFvaOveWaaVrk	0304010.04	Desinvesteringen overige effecten (langlopend)	C	5	\N	t
1034	1	BFvaOveWaaWst	0304010.05	Waardestijgingen overige effecten (langlopend)	D	5	\N	t
1035	1	BFvaOveWaaDda	0304010.09	Afstotingen overige effecten (langlopend)	C	5	\N	t
1036	1	BFvaOveWaaOmv	0304010.06	Omrekeningsverschillen overige effecten (langlopend)	D	5	\N	t
1037	1	BFvaOveWaaOvm	0304010.07	Overige mutaties overige effecten (langlopend)	D	5	\N	t
1038	1	BFvaOveCuw	0304020	Cumulatieve afschrijvingen en waardeverminderingen overige effecten (langlopend)	C	4	\N	t
1039	1	BFvaOveCuwBeg	0304020.01	Beginbalans (overname eindsaldo vorig jaar) overige effecten (langlopend)	C	5	\N	t
1040	1	BFvaOveCuwAfs	0304020.04	Afschrijvingen overige effecten (langlopend)	C	5	\N	t
1041	1	BFvaOveCuwDca	0304020.05	Afschrijving op desinvesteringen overige effecten (langlopend)	D	5	\N	t
1042	1	BFvaOveCuwWvr	0304020.02	Bijzondere waardeverminderingen overige effecten (langlopend)	C	5	\N	t
1043	1	BFvaOveCuwTvw	0304020.03	Terugneming van bijzondere waardeverminderingen overige effecten (langlopend)	D	5	\N	t
1044	1	BFvaOveCuh	0304030	Cumulatieve herwaarderingen overige effecten (langlopend)	D	4	\N	t
1045	1	BFvaOveCuhBeg	0304030.01	Beginbalans (overname eindsaldo vorig jaar) overige effecten (langlopend)	D	5	\N	t
1046	1	BFvaOveCuhHer	0304030.02	Herwaarderingen overige effecten (langlopend)	D	5	\N	t
1047	1	BFvaOveCuhDen	0304030.07	Desinvestering herwaardering overige effecten (langlopend)	C	5	\N	t
1048	1	BFvaOveCuhOvm	0304030.08	Overige mutaties waardeveranderingen overige effecten (langlopend)	D	5	\N	t
1049	1	BFvaOveCuhAir	0304030.05	Aandeel in resultaat deelnemingen overige effecten (langlopend)	D	5	\N	t
1050	1	BFvaOveCuhDvd	0304030.06	Dividend van deelnemingen overige effecten (langlopend)	D	5	\N	t
1051	1	BFvaOvr	0309000	Overige vorderingen (langlopend)	D	3	\N	t
1052	1	BFvaOvrVob	309020	Hoofdsom leningen, voorschotten en garanties ten behoeve van bestuurders (langlopend)	D	4	\N	t
1053	1	BFvaOvrVobBe1	0309020.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op bestuurders 1 (langlopend)	D	5	\N	t
1054	1	BFvaOvrVobBe2	0309020.02	Beginbalans (overname eindsaldo vorig jaar) vorderingen op bestuurders 2 (langlopend)	D	5	\N	t
1055	1	BFvaOvrVobBe3	0309020.03	Beginbalans (overname eindsaldo vorig jaar) vorderingen op bestuurders 3 (langlopend)	D	5	\N	t
1056	1	BFvaOvrVobBe4	0309020.04	Beginbalans (overname eindsaldo vorig jaar) vorderingen op bestuurders 4 (langlopend)	D	5	\N	t
1057	1	BFvaOvrVobBe5	0309020.05	Beginbalans (overname eindsaldo vorig jaar) vorderingen op bestuurders 5 (langlopend)	D	5	\N	t
1058	1	BFvaOvrVobBea	0309020.06	Toename leningen, voorschotten en garanties van bestuurders 1 (langlopend)	D	5	\N	t
1059	1	BFvaOvrVobBeb	0309020.07	Toename leningen, voorschotten en garanties van bestuurders 2 (langlopend)	D	5	\N	t
1060	1	BFvaOvrVobBec	0309020.08	Toename leningen, voorschotten en garanties van bestuurders 3 (langlopend)	D	5	\N	t
1061	1	BFvaOvrVobBed	0309020.09	Toename leningen, voorschotten en garanties van bestuurders 4 (langlopend)	D	5	\N	t
1062	1	BFvaOvrVobBee	0309020.10	Toename leningen, voorschotten en garanties van bestuurders 5 (langlopend)	D	5	\N	t
1063	1	BFvaOvrVobBef	0309020.11	Overige mutaties leningen, voorschotten en garanties van bestuurders 1 (langlopend)	D	5	\N	t
1064	1	BFvaOvrVobBeg	0309020.12	Overige mutaties leningen, voorschotten en garanties van bestuurders 2 (langlopend)	D	5	\N	t
1065	1	BFvaOvrVobBeh	0309020.13	Overige mutaties leningen, voorschotten en garanties van bestuurders 3 (langlopend)	D	5	\N	t
1066	1	BFvaOvrVobBei	0309020.14	Overige mutaties leningen, voorschotten en garanties van bestuurders 4 (langlopend)	D	5	\N	t
1067	1	BFvaOvrVobBej	0309020.15	Overige mutaties leningen, voorschotten en garanties van bestuurders 5 (langlopend)	D	5	\N	t
1118	1	BFvaOvrVocBeg	0309022.12	Overige mutaties leningen, voorschotten en garanties commissaris 2	D	5	\N	t
1068	1	BFvaOvrVoa	309120	Cumulatieve aflossingen en waardeverminderingen leningen, voorschotten en garanties bestuurders (langlopend)	C	4	\N	t
1069	1	BFvaOvrVoaBe1	0309120.01	Beginbalans cumulatieve aflossing vorderingen op bestuurders 1 (langlopend)	C	5	\N	t
1070	1	BFvaOvrVoaBe2	0309120.02	Beginbalans cumulatieve aflossing vorderingen op bestuurders 2 (langlopend)	C	5	\N	t
1071	1	BFvaOvrVoaBe3	0309120.03	Beginbalans cumulatieve aflossing vorderingen op bestuurders 3 (langlopend)	C	5	\N	t
1072	1	BFvaOvrVoaBe4	0309120.04	Beginbalans cumulatieve aflossing vorderingen op bestuurders 4 (langlopend)	C	5	\N	t
1073	1	BFvaOvrVoaBe5	0309120.05	Beginbalans cumulatieve aflossing vorderingen op bestuurders 5 (langlopend)	C	5	\N	t
1074	1	BFvaOvrVoaBea	0309120.06	Aflossing / afname leningen, voorschotten en garanties bestuurders 1 (langlopend)	C	5	\N	t
1075	1	BFvaOvrVoaBeb	0309120.07	Aflossing / afname leningen, voorschotten en garanties bestuurders 2 (langlopend)	C	5	\N	t
1076	1	BFvaOvrVoaBec	0309120.08	Aflossing / afname leningen, voorschotten en garanties bestuurders 3 (langlopend)	C	5	\N	t
1077	1	BFvaOvrVoaBed	0309120.09	Aflossing / afname leningen, voorschotten en garanties bestuurders 4 (langlopend)	C	5	\N	t
1078	1	BFvaOvrVoaBee	0309120.10	Aflossing / afname leningen, voorschotten en garanties bestuurders 5 (langlopend)	C	5	\N	t
1079	1	BFvaOvrVgb	309021	Hoofdsom leningen, voorschotten en garanties ten behoeve van gewezen bestuurders (langlopend)	D	4	\N	t
1080	1	BFvaOvrVgbBe1	0309021.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen bestuurders 1 (langlopend)	D	5	\N	t
1081	1	BFvaOvrVgbBe2	0309021.02	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen bestuurders 2 (langlopend)	D	5	\N	t
1082	1	BFvaOvrVgbBe3	0309021.03	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen bestuurders 3 (langlopend)	D	5	\N	t
1083	1	BFvaOvrVgbBe4	0309021.04	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen bestuurders 4 (langlopend)	D	5	\N	t
1084	1	BFvaOvrVgbBe5	0309021.05	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen bestuurders 5 (langlopend)	D	5	\N	t
1085	1	BFvaOvrVgbBea	0309021.06	Toename leningen, voorschotten en garanties van gewezen bestuurders 1	D	5	\N	t
1086	1	BFvaOvrVgbBeb	0309021.07	Toename leningen, voorschotten en garanties van gewezen bestuurders 2	D	5	\N	t
1087	1	BFvaOvrVgbBec	0309021.08	Toename leningen, voorschotten en garanties van gewezen bestuurders 3	D	5	\N	t
1088	1	BFvaOvrVgbBed	0309021.09	Toename leningen, voorschotten en garanties van gewezen bestuurders 4	D	5	\N	t
1089	1	BFvaOvrVgbBee	0309021.10	Toename leningen, voorschotten en garanties van gewezen bestuurders 5	D	5	\N	t
1090	1	BFvaOvrVgbBef	0309021.11	Overige mutaties leningen, voorschotten en garanties van gewezen bestuurders 1	D	5	\N	t
1091	1	BFvaOvrVgbBeg	0309021.12	Overige mutaties leningen, voorschotten en garanties van gewezen bestuurders 2	D	5	\N	t
1092	1	BFvaOvrVgbBeh	0309021.13	Overige mutaties leningen, voorschotten en garanties van gewezen bestuurders 3	D	5	\N	t
1093	1	BFvaOvrVgbBei	0309021.14	Overige mutaties leningen, voorschotten en garanties van gewezen bestuurders 4	D	5	\N	t
1094	1	BFvaOvrVgbBej	0309021.15	Overige mutaties leningen, voorschotten en garanties van gewezen bestuurders 5	D	5	\N	t
1095	1	BFvaOvrVga	309121	Cumulatieve aflossingen en waardeverminderingen leningen, voorschotten en garanties gewezen bestuurders (langlopend)	C	4	\N	t
1096	1	BFvaOvrVgaBe1	0309121.01	Beginbalans cumulatieve aflossing vorderingen op gewezen bestuurders 1	C	5	\N	t
1097	1	BFvaOvrVgaBe2	0309121.02	Beginbalans cumulatieve aflossing vorderingen op gewezen bestuurders 2	C	5	\N	t
1098	1	BFvaOvrVgaBe3	0309121.03	Beginbalans cumulatieve aflossing vorderingen op gewezen bestuurders 3	C	5	\N	t
1099	1	BFvaOvrVgaBe4	0309121.04	Beginbalans cumulatieve aflossing vorderingen op gewezen bestuurders 4	C	5	\N	t
1100	1	BFvaOvrVgaBe5	0309121.05	Beginbalans cumulatieve aflossing vorderingen op gewezen bestuurders 5	C	5	\N	t
1101	1	BFvaOvrVgaBea	0309121.06	Aflossing / afname leningen, voorschotten en garanties gewezen bestuurders 1	C	5	\N	t
1102	1	BFvaOvrVgaBeb	0309121.07	Aflossing / afname leningen, voorschotten en garanties gewezen bestuurders 2	C	5	\N	t
1103	1	BFvaOvrVgaBec	0309121.08	Aflossing / afname leningen, voorschotten en garanties gewezen bestuurders 3	C	5	\N	t
1104	1	BFvaOvrVgaBed	0309121.09	Aflossing / afname leningen, voorschotten en garanties gewezen bestuurders 4	C	5	\N	t
1105	1	BFvaOvrVgaBee	0309121.10	Aflossing / afname leningen, voorschotten en garanties gewezen bestuurders 5	C	5	\N	t
1106	1	BFvaOvrVoc	309022	Hoofdsom leningen, voorschotten en garanties ten behoeve van commissarissen (langlopend)	D	4	\N	t
1107	1	BFvaOvrVocCo1	0309022.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op commissaris 1 (langlopend)	D	5	\N	t
1108	1	BFvaOvrVocCo2	0309022.02	Beginbalans (overname eindsaldo vorig jaar) vorderingen op commissaris 2 (langlopend)	D	5	\N	t
1109	1	BFvaOvrVocCo3	0309022.03	Beginbalans (overname eindsaldo vorig jaar) vorderingen op commissaris 3 (langlopend)	D	5	\N	t
1110	1	BFvaOvrVocCo4	0309022.04	Beginbalans (overname eindsaldo vorig jaar) vorderingen op commissaris 4 (langlopend)	D	5	\N	t
1111	1	BFvaOvrVocCo5	0309022.05	Beginbalans (overname eindsaldo vorig jaar) vorderingen op commissaris 5 (langlopend)	D	5	\N	t
1112	1	BFvaOvrVocBea	0309022.06	Toename leningen, voorschotten en garanties commissaris 1	D	5	\N	t
1113	1	BFvaOvrVocBeb	0309022.07	Toename leningen, voorschotten en garanties commissaris 2	D	5	\N	t
1114	1	BFvaOvrVocBec	0309022.08	Toename leningen, voorschotten en garanties commissaris 3	D	5	\N	t
1115	1	BFvaOvrVocBed	0309022.09	Toename leningen, voorschotten en garanties commissaris 4	D	5	\N	t
1116	1	BFvaOvrVocBee	0309022.10	Toename leningen, voorschotten en garanties commissaris 5	D	5	\N	t
1117	1	BFvaOvrVocBef	0309022.11	Overige mutaties leningen, voorschotten en garanties commissaris 1	D	5	\N	t
1119	1	BFvaOvrVocBeh	0309022.13	Overige mutaties leningen, voorschotten en garanties commissaris 3	D	5	\N	t
1120	1	BFvaOvrVocBei	0309022.14	Overige mutaties leningen, voorschotten en garanties commissaris 4	D	5	\N	t
1121	1	BFvaOvrVocBej	0309022.15	Overige mutaties leningen, voorschotten en garanties commissaris 5	D	5	\N	t
1122	1	BFvaOvrVca	309122	Cumulatieve aflossingen en waardeverminderingen leningen, voorschotten en garanties commissarissen (langlopend)	C	4	\N	t
1123	1	BFvaOvrVcaBe1	0309122.01	Beginbalans cumulatieve aflossing vorderingen op commissaris 1	C	5	\N	t
1124	1	BFvaOvrVcaBe2	0309122.02	Beginbalans cumulatieve aflossing vorderingen op commissaris 2	C	5	\N	t
1125	1	BFvaOvrVcaBe3	0309122.03	Beginbalans cumulatieve aflossing vorderingen op commissaris 3	C	5	\N	t
1126	1	BFvaOvrVcaBe4	0309122.04	Beginbalans cumulatieve aflossing vorderingen op commissaris 4	C	5	\N	t
1127	1	BFvaOvrVcaBe5	0309122.05	Beginbalans cumulatieve aflossing vorderingen op commissaris 5	C	5	\N	t
1128	1	BFvaOvrVcaBea	0309122.06	Aflossing / afname leningen, voorschotten en garanties commissaris 1	C	5	\N	t
1129	1	BFvaOvrVcaBeb	0309122.07	Aflossing / afname leningen, voorschotten en garanties commissaris 2	C	5	\N	t
1130	1	BFvaOvrVcaBec	0309122.08	Aflossing / afname leningen, voorschotten en garanties commissaris 3	C	5	\N	t
1131	1	BFvaOvrVcaBed	0309122.09	Aflossing / afname leningen, voorschotten en garanties commissaris 4	C	5	\N	t
1132	1	BFvaOvrVcaBee	0309122.10	Aflossing / afname leningen, voorschotten en garanties commissaris 5	C	5	\N	t
1133	1	BFvaOvrVgc	309023	Hoofdsom leningen, voorschotten en garanties ten behoeve van gewezen commissarissen (langlopend)	D	4	\N	t
1134	1	BFvaOvrVgcCo1	0309023.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen commissaris 1 (langlopend)	D	5	\N	t
1135	1	BFvaOvrVgcCo2	0309023.02	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen commissaris 2 (langlopend)	D	5	\N	t
1136	1	BFvaOvrVgcCo3	0309023.03	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen commissaris 3 (langlopend)	D	5	\N	t
1137	1	BFvaOvrVgcCo4	0309023.04	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen commissaris 4 (langlopend)	D	5	\N	t
1138	1	BFvaOvrVgcCo5	0309023.05	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen commissaris 5 (langlopend)	D	5	\N	t
1139	1	BFvaOvrVgcBea	0309023.06	Toename leningen, voorschotten en garanties gewezen commissaris 1	D	5	\N	t
1140	1	BFvaOvrVgcBeb	0309023.07	Toename leningen, voorschotten en garanties gewezen commissaris 2	D	5	\N	t
1141	1	BFvaOvrVgcBec	0309023.08	Toename leningen, voorschotten en garanties gewezen commissaris 3	D	5	\N	t
1142	1	BFvaOvrVgcBed	0309023.09	Toename leningen, voorschotten en garanties gewezen commissaris 4	D	5	\N	t
1143	1	BFvaOvrVgcBee	0309023.10	Toename leningen, voorschotten en garanties gewezen commissaris 5	D	5	\N	t
1144	1	BFvaOvrVgcBef	0309023.11	Overige mutaties leningen, voorschotten en garanties gewezen commissaris 1	D	5	\N	t
1145	1	BFvaOvrVgcBeg	0309023.12	Overige mutaties leningen, voorschotten en garanties gewezen commissaris 2	D	5	\N	t
1146	1	BFvaOvrVgcBeh	0309023.13	Overige mutaties leningen, voorschotten en garanties gewezen commissaris 3	D	5	\N	t
1147	1	BFvaOvrVgcBei	0309023.14	Overige mutaties leningen, voorschotten en garanties gewezen commissaris 4	D	5	\N	t
1148	1	BFvaOvrVgcBej	0309023.15	Overige mutaties leningen, voorschotten en garanties gewezen commissaris 5	D	5	\N	t
1149	1	BFvaOvrVaw	309123	Cumulatieve aflossingen en waardeverminderingen leningen, voorschotten en garanties gewezen commissarissen (langlopend)	C	4	\N	t
1150	1	BFvaOvrVawBe1	0309123.01	Beginbalans cumulatieve aflossing vorderingen op gewezen commissaris 1	C	5	\N	t
1151	1	BFvaOvrVawBe2	0309123.02	Beginbalans cumulatieve aflossing vorderingen op gewezen commissaris 2	C	5	\N	t
1152	1	BFvaOvrVawBe3	0309123.03	Beginbalans cumulatieve aflossing vorderingen op gewezen commissaris 3	C	5	\N	t
1153	1	BFvaOvrVawBe4	0309123.04	Beginbalans cumulatieve aflossing vorderingen op gewezen commissaris 4	C	5	\N	t
1154	1	BFvaOvrVawBe5	0309123.05	Beginbalans cumulatieve aflossing vorderingen op gewezen commissaris 5	C	5	\N	t
1155	1	BFvaOvrVawBea	0309123.06	Aflossing / afname leningen, voorschotten en garanties gewezen commissaris 1	C	5	\N	t
1156	1	BFvaOvrVawBeb	0309123.07	Aflossing / afname leningen, voorschotten en garanties gewezen commissaris 2	C	5	\N	t
1157	1	BFvaOvrVawBec	0309123.08	Aflossing / afname leningen, voorschotten en garanties gewezen commissaris 3	C	5	\N	t
1158	1	BFvaOvrVawBed	0309123.09	Aflossing / afname leningen, voorschotten en garanties gewezen commissaris 4	C	5	\N	t
1159	1	BFvaOvrVawBee	0309123.10	Aflossing / afname leningen, voorschotten en garanties gewezen commissaris 5	C	5	\N	t
1160	1	BFvaOvrLvl	309024	Hoofdsom vorderingen uit hoofde van leningen en voorschotten aan leden (langlopend)	D	4	\N	t
1161	1	BFvaOvrLvlLi1	0309024.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op lid 1 (langlopend)	D	5	\N	t
1162	1	BFvaOvrLvlLi2	0309024.02	Beginbalans (overname eindsaldo vorig jaar) vorderingen op lid 2 (langlopend)	D	5	\N	t
1163	1	BFvaOvrLvlLi3	0309024.03	Beginbalans (overname eindsaldo vorig jaar) vorderingen op lid 3 (langlopend)	D	5	\N	t
1164	1	BFvaOvrLvlLi4	0309024.04	Beginbalans (overname eindsaldo vorig jaar) vorderingen op lid 4 (langlopend)	D	5	\N	t
1165	1	BFvaOvrLvlLi5	0309024.05	Beginbalans (overname eindsaldo vorig jaar) vorderingen op lid 5 (langlopend)	D	5	\N	t
1166	1	BFvaOvrLvlBea	0309024.06	Toename vorderingen op lid 1	D	5	\N	t
1167	1	BFvaOvrLvlBeb	0309024.07	Toename vorderingen op lid 2	D	5	\N	t
1168	1	BFvaOvrLvlBec	0309024.08	Toename vorderingen op lid 3	D	5	\N	t
1169	1	BFvaOvrLvlBed	0309024.09	Toename vorderingen op lid 4	D	5	\N	t
1170	1	BFvaOvrLvlBee	0309024.10	Toename vorderingen op lid 5	D	5	\N	t
1171	1	BFvaOvrLvlBef	0309024.11	Overige mutaties vorderingen op lid 1	D	5	\N	t
1176	1	BFvaOvrLvc	309124	Cumulatieve aflossingen en waardeverminderingen leningen en voorschotten aan leden (Langlopend)	C	4	\N	t
1177	1	BFvaOvrLvcBe1	0309124.01	Beginbalans cumulatieve aflossing vorderingen op lid 1	C	5	\N	t
1178	1	BFvaOvrLvcBe2	0309124.02	Beginbalans cumulatieve aflossing vorderingen op lid 2	C	5	\N	t
1179	1	BFvaOvrLvcBe3	0309124.03	Beginbalans cumulatieve aflossing vorderingen op lid 3	C	5	\N	t
1180	1	BFvaOvrLvcBe4	0309124.04	Beginbalans cumulatieve aflossing vorderingen op lid 4	C	5	\N	t
1181	1	BFvaOvrLvcBe5	0309124.05	Beginbalans cumulatieve aflossing vorderingen op lid 5	C	5	\N	t
1182	1	BFvaOvrLvcBea	0309124.06	Aflossing / afname leningen en voorschotten lid 1	C	5	\N	t
1183	1	BFvaOvrLvcBeb	0309124.07	Aflossing / afname leningen en voorschotten lid 2	C	5	\N	t
1184	1	BFvaOvrLvcBec	0309124.08	Aflossing / afname leningen en voorschotten lid 3	C	5	\N	t
1185	1	BFvaOvrLvcBed	0309124.09	Aflossing / afname leningen en voorschotten lid 4	C	5	\N	t
1186	1	BFvaOvrLvcBee	0309124.10	Aflossing / afname leningen en voorschotten lid 5	C	5	\N	t
1187	1	BFvaOvrHva	309025	Hoofdsom vorderingen uit hoofde van leningen en voorschotten houders van aandelen op naam (langlopend)	D	4	\N	t
1188	1	BFvaOvrHvaAh1	0309025.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op aandeelhouder 1 (langlopend)	D	5	\N	t
1189	1	BFvaOvrHvaAh2	0309025.02	Beginbalans (overname eindsaldo vorig jaar) vorderingen op aandeelhouder 2 (langlopend)	D	5	\N	t
1190	1	BFvaOvrHvaAh3	0309025.03	Beginbalans (overname eindsaldo vorig jaar) vorderingen op aandeelhouder 3 (langlopend)	D	5	\N	t
1191	1	BFvaOvrHvaAh4	0309025.04	Beginbalans (overname eindsaldo vorig jaar) vorderingen op aandeelhouder 4 (langlopend)	D	5	\N	t
1192	1	BFvaOvrHvaAh5	0309025.05	Beginbalans (overname eindsaldo vorig jaar) vorderingen op aandeelhouder 5 (langlopend)	D	5	\N	t
1193	1	BFvaOvrHvaBea	0309025.06	Toename vorderingen op aandeelhouder 1	D	5	\N	t
1194	1	BFvaOvrHvaBeb	0309025.07	Toename vorderingen op aandeelhouder 2	D	5	\N	t
1195	1	BFvaOvrHvaBec	0309025.08	Toename vorderingen op aandeelhouder 3	D	5	\N	t
1196	1	BFvaOvrHvaBed	0309025.09	Toename vorderingen op aandeelhouder 4	D	5	\N	t
1197	1	BFvaOvrHvaBee	0309025.10	Toename vorderingen op aandeelhouder 5	D	5	\N	t
1198	1	BFvaOvrHvaBef	0309025.11	Overige mutaties vorderingen op aandeelhouder 1	D	5	\N	t
1199	1	BFvaOvrHvaBeg	0309025.12	Overige mutaties vorderingen op aandeelhouder 2	D	5	\N	t
1200	1	BFvaOvrHvaBeh	0309025.13	Overige mutaties vorderingen op aandeelhouder 3	D	5	\N	t
1201	1	BFvaOvrHvaBei	0309025.14	Overige mutaties vorderingen op aandeelhouder 4	D	5	\N	t
1202	1	BFvaOvrHvaBej	0309025.15	Overige mutaties vorderingen op aandeelhouder 5	D	5	\N	t
1203	1	BFvaOvrHvc	309125	Cumulatieve aflossingen en waardeverminderingen leningen en voorschotten houders van aandelen op naam (langlopend)	C	4	\N	t
1204	1	BFvaOvrHvcBe1	0309125.01	Beginbalans cumulatieve aflossing vorderingen op aandeelhouder 1	C	5	\N	t
1205	1	BFvaOvrHvcBe2	0309125.02	Beginbalans cumulatieve aflossing vorderingen op aandeelhouder 2	C	5	\N	t
1206	1	BFvaOvrHvcBe3	0309125.03	Beginbalans cumulatieve aflossing vorderingen op aandeelhouder 3	C	5	\N	t
1207	1	BFvaOvrHvcBe4	0309125.04	Beginbalans cumulatieve aflossing vorderingen op aandeelhouder 4	C	5	\N	t
1208	1	BFvaOvrHvcBe5	0309125.05	Beginbalans cumulatieve aflossing vorderingen op aandeelhouder 5	C	5	\N	t
1209	1	BFvaOvrHvcBea	0309125.06	Aflossing / afname vorderingen op aandeelhouder 1	C	5	\N	t
1210	1	BFvaOvrHvcBeb	0309125.07	Aflossing / afname vorderingen op aandeelhouder 2	C	5	\N	t
1211	1	BFvaOvrHvcBec	0309125.08	Aflossing / afname vorderingen op aandeelhouder 3	C	5	\N	t
1212	1	BFvaOvrHvcBed	0309125.09	Aflossing / afname vorderingen op aandeelhouder 4	C	5	\N	t
1213	1	BFvaOvrHvcBee	0309125.10	Aflossing / afname vorderingen op aandeelhouder 5	C	5	\N	t
1214	1	BFvaOvrTsl	309009	Hoofdsom te vorderen subsidies (langlopend)	D	4	\N	t
1215	1	BFvaOvrTslTs1	0309009.01	Beginbalans (overname eindsaldo vorig jaar) te vorderen subsidie 1 (langlopend)	D	5	\N	t
1216	1	BFvaOvrTslTs2	0309009.02	Beginbalans (overname eindsaldo vorig jaar) te vorderen subsidie 2 (langlopend)	D	5	\N	t
1217	1	BFvaOvrTslTs3	0309009.03	Beginbalans (overname eindsaldo vorig jaar) te vorderen subsidie 3 (langlopend)	D	5	\N	t
1218	1	BFvaOvrTslBea	0309009.04	Toename te vorderen subsidie 1	D	5	\N	t
1219	1	BFvaOvrTslBeb	0309009.05	Toename te vorderen subsidie 2	D	5	\N	t
1220	1	BFvaOvrTslBec	0309009.06	Toename te vorderen subsidie 3	D	5	\N	t
1221	1	BFvaOvrTslBef	0309009.07	Overige mutaties te vorderen subsidie 1	D	5	\N	t
1222	1	BFvaOvrTslBeg	0309009.08	Overige mutaties te vorderen subsidie 2	D	5	\N	t
1223	1	BFvaOvrTslBeh	0309009.09	Overige mutaties te vorderen subsidie 3	D	5	\N	t
1224	1	BFvaOvrTsc	309019	Cumulatieve aflossingen en waardeverminderingen te vorderen subsidies (langlopend)	C	4	\N	t
1225	1	BFvaOvrTscBe1	0309019.01	Beginbalans cumulatieve aflossing te vorderen subsidies 1	C	5	\N	t
1226	1	BFvaOvrTscBe2	0309019.02	Beginbalans cumulatieve aflossing te vorderen subsidies 2	C	5	\N	t
1227	1	BFvaOvrTscBe3	0309019.03	Beginbalans cumulatieve aflossing te vorderen subsidies 3	C	5	\N	t
1228	1	BFvaOvrTscBea	0309019.04	Aflossing / afname te vorderen subsidies 1	C	5	\N	t
1229	1	BFvaOvrTscBeb	0309019.05	Aflossing / afname te vorderen subsidies 2	C	5	\N	t
1230	1	BFvaOvrTscBec	0309019.06	Aflossing / afname te vorderen subsidies 3	C	5	\N	t
1231	1	BFvaOvrWaa	309050	Hoofdsom waarborgsommen (langlopend)	D	4	\N	t
1232	1	BFvaOvrWaaWb1	0309050.01	Beginbalans (overname eindsaldo vorig jaar) waarborgsom 1 (langlopend)	D	5	\N	t
1233	1	BFvaOvrWaaWb2	0309050.02	Beginbalans (overname eindsaldo vorig jaar) waarborgsom 2 (langlopend)	D	5	\N	t
1234	1	BFvaOvrWaaWb3	0309050.03	Beginbalans (overname eindsaldo vorig jaar) waarborgsom 3 (langlopend)	D	5	\N	t
1235	1	BFvaOvrWaaBea	0309050.04	Toename waarborgsom 1	D	5	\N	t
1236	1	BFvaOvrWaaBeb	0309050.05	Toename waarborgsom 2	D	5	\N	t
1237	1	BFvaOvrWaaBec	0309050.06	Toename waarborgsom 3	D	5	\N	t
1238	1	BFvaOvrWaaBef	0309050.07	Overige mutaties waarborgsom 1	D	5	\N	t
1239	1	BFvaOvrWaaBeg	0309050.08	Overige mutaties waarborgsom 2	D	5	\N	t
1240	1	BFvaOvrWaaBeh	0309050.09	Overige mutaties waarborgsom 3	D	5	\N	t
1241	1	BFvaOvrWac	309150	Cumulatieve aflossingen en waardeverminderingen waarborgsommen (langlopend)	C	4	\N	t
1242	1	BFvaOvrWacBe1	0309150.01	Beginbalans cumulatieve aflossing waarborgsom 1	C	5	\N	t
1243	1	BFvaOvrWacBe2	0309150.02	Beginbalans cumulatieve aflossing waarborgsom 2	C	5	\N	t
1244	1	BFvaOvrWacBe3	0309150.03	Beginbalans cumulatieve aflossing waarborgsom 3	C	5	\N	t
1245	1	BFvaOvrWacBea	0309150.04	Aflossing / afname waarborgsom 1	C	5	\N	t
1246	1	BFvaOvrWacBeb	0309150.05	Aflossing / afname waarborgsom 2	C	5	\N	t
1247	1	BFvaOvrWacBec	0309150.06	Aflossing / afname waarborgsom 3	C	5	\N	t
1248	1	BFvaOvrLed	309039	Hoofdsom ledenrekeningen (langlopend)	D	4	\N	t
1249	1	BFvaOvrLedLe1	0309039.01	Beginbalans (overname eindsaldo vorig jaar) ledenrekeningen 1 (langlopend)	D	5	\N	t
1250	1	BFvaOvrLedLe2	0309039.02	Beginbalans (overname eindsaldo vorig jaar) ledenrekeningen 2 (langlopend)	D	5	\N	t
1251	1	BFvaOvrLedLe3	0309039.03	Beginbalans (overname eindsaldo vorig jaar) ledenrekeningen 3 (langlopend)	D	5	\N	t
1252	1	BFvaOvrLedBea	0309039.04	Toename ledenrekening 1	D	5	\N	t
1253	1	BFvaOvrLedBeb	0309039.05	Toename ledenrekening 2	D	5	\N	t
1254	1	BFvaOvrLedBec	0309039.06	Toename ledenrekening 3	D	5	\N	t
1255	1	BFvaOvrLedBef	0309039.07	Overige mutaties ledenrekening 1	D	5	\N	t
1256	1	BFvaOvrLedBeg	0309039.08	Overige mutaties ledenrekening 2	D	5	\N	t
1257	1	BFvaOvrLedBeh	0309039.09	Overige mutaties ledenrekening 3	D	5	\N	t
1258	1	BFvaOvrLec	309139	Cumulatieve aflossingen en waardeverminderingen ledenrekeningen (langlopend)	C	4	\N	t
1259	1	BFvaOvrLecBe1	0309139.01	Beginbalans cumulatieve aflossing ledenrekening 1	C	5	\N	t
1260	1	BFvaOvrLecBe2	0309139.02	Beginbalans cumulatieve aflossing ledenrekening 2	C	5	\N	t
1261	1	BFvaOvrLecBe3	0309139.03	Beginbalans cumulatieve aflossing ledenrekening 3	C	5	\N	t
1262	1	BFvaOvrLecBea	0309139.04	Aflossing / afname ledenrekening 1	C	5	\N	t
1263	1	BFvaOvrLecBeb	0309139.05	Aflossing / afname ledenrekening 2	C	5	\N	t
1264	1	BFvaOvrLecBec	0309139.06	Aflossing / afname ledenrekening 3	C	5	\N	t
1265	1	BFvaOvrOvl	309029	Hoofdsom overige financiële vaste activa (langlopend)	D	4	\N	t
1266	1	BFvaOvrOvlOv1	0309029.01	Beginbalans (overname eindsaldo vorig jaar) overige financiële vaste activa 1 (langlopend)	D	5	\N	t
1267	1	BFvaOvrOvlOv2	0309029.02	Beginbalans (overname eindsaldo vorig jaar) overige financiële vaste activa 2 (langlopend)	D	5	\N	t
1268	1	BFvaOvrOvlOv3	0309029.03	Beginbalans (overname eindsaldo vorig jaar) overige financiële vaste activa 3 (langlopend)	D	5	\N	t
1269	1	BFvaOvrOvlBea	0309029.04	Toename overige financiële vaste activa 1	D	5	\N	t
1270	1	BFvaOvrOvlBeb	0309029.05	Toename overige financiële vaste activa 2	D	5	\N	t
1271	1	BFvaOvrOvlBec	0309029.06	Toename overige financiële vaste activa 3	D	5	\N	t
1272	1	BFvaOvrOvlBef	0309029.07	Overige mutaties overige financiële vaste activa 1	D	5	\N	t
1273	1	BFvaOvrOvlBeg	0309029.08	Overige mutaties overige financiële vaste activa 2	D	5	\N	t
1274	1	BFvaOvrOvlBeh	0309029.09	Overige mutaties overige financiële vaste activa 3	D	5	\N	t
1275	1	BFvaOvrOvlBei	0309029.10	Omrekeningsverschillen overige financiële vaste activa 1	D	5	\N	t
1276	1	BFvaOvrOvlBej	0309029.11	Omrekeningsverschillen overige financiële vaste activa 2	D	5	\N	t
1277	1	BFvaOvrOvlBek	0309029.12	Omrekeningsverschillen overige financiële vaste activa 3	D	5	\N	t
1278	1	BFvaOvrOvc	309129	Cumulatieve aflossingen en waardeverminderingen overige financiële vaste activa (langlopend)	C	4	\N	t
1279	1	BFvaOvrOvcBe1	0309129.01	Beginbalans (overname eindsaldo vorig jaar) cumulatieve aflossing overige financiële vaste activa 1 (langlopend)	C	5	\N	t
1280	1	BFvaOvrOvcBe2	0309129.02	Beginbalans (overname eindsaldo vorig jaar) cumulatieve aflossing overige financiële vaste activa 2 (langlopend)	C	5	\N	t
1281	1	BFvaOvrOvcBe3	0309129.03	Beginbalans (overname eindsaldo vorig jaar) cumulatieve aflossing overige financiële vaste activa 3 (langlopend)	C	5	\N	t
1282	1	BFvaOvrOvcBea	0309129.04	Aflossing / afname overige financiële vaste activa 1	C	5	\N	t
1283	1	BFvaOvrOvcBeb	0309129.05	Aflossing / afname overige financiële vaste activa 2	C	5	\N	t
1284	1	BFvaOvrOvcBec	0309129.06	Aflossing / afname overige financiële vaste activa 3	C	5	\N	t
1285	1	BFvaOvrOvcBed	0309129.07	Bijzondere waardeverminderingen overige financiële vaste activa 1	C	5	\N	t
1286	1	BFvaOvrOvcBee	0309129.08	Bijzondere waardeverminderingen overige financiële vaste activa 2	C	5	\N	t
1287	1	BFvaOvrOvcBef	0309129.09	Bijzondere waardeverminderingen overige financiële vaste activa 3	C	5	\N	t
1288	1	BFvaOvrOvcBeg	0309129.10	Terugneming van bijzondere waardeverminderingen overige financiële vaste activa 1	D	5	\N	t
1289	1	BFvaOvrOvcBeh	0309129.11	Terugneming van bijzondere waardeverminderingen overige financiële vaste activa 2	D	5	\N	t
1290	1	BFvaOvrOvcBei	0309129.12	Terugneming van bijzondere waardeverminderingen overige financiële vaste activa 3	D	5	\N	t
1291	1	BFvaOvrOvcBej	0309129.13	Overige mutaties waardeveranderingen overige financiële vaste activa 1	C	5	\N	t
1292	1	BFvaOvrOvcBek	0309129.14	Overige mutaties waardeveranderingen overige financiële vaste activa 2	C	5	\N	t
1293	1	BFvaOvrOvcBel	0309129.15	Overige mutaties waardeveranderingen overige financiële vaste activa 3	C	5	\N	t
1294	1	BFvaOvrSid	309028	Storting ivm derivaten	D	4	\N	t
1295	1	BFvaOvrSidBeg	0309028.01	Saldo per begin boekjaar	D	5	\N	t
1296	1	BFvaOvrSidStr	0309028.02	Stortingen	D	5	\N	t
1297	1	BFvaOvrSidOnt	0309028.03	Ontvangsten	C	5	\N	t
1298	1	BFvaOvrSidWvr	0309028.04	Bijzondere waardeverminderingen	C	5	\N	t
1299	1	BFvaOvrSidTvw	0309028.05	Terugneming van bijzondere waardeverminderingen	D	5	\N	t
1300	1	BFvaOvrAga	309027	Agio afkoop leningen/derivaten	D	4	\N	t
1301	1	BFvaOvrAgaBeg	0309027.01	Saldo per begin boekjaar	D	5	\N	t
1302	1	BFvaOvrAgaVlr	0309027.02	Vrijval ten laste van het resultaat	C	5	\N	t
1303	1	BFvaOvrAgaGab	0309027.03	Geactiveerde afrekening break	D	5	\N	t
1304	1	BFvaOvrAgaWvr	0309027.04	Bijzondere waardeverminderingen	C	5	\N	t
1305	1	BFvaOvrAgaTvw	0309027.05	Terugneming van bijzondere waardeverminderingen	D	5	\N	t
1306	1	BFvaLbv	0308000	Latente belastingvorderingen	D	3	\N	t
1307	1	BFvaLbvBll	308010	Compensabele verliezen	D	4	\N	t
1308	1	BFvaLbvBllBeg	0308010.01	Saldo per begin boekjaar	D	5	\N	t
1309	1	BFvaLbvBllToe	0308010.02	Toename	D	5	\N	t
1310	1	BFvaLbvBllAfn	0308010.03	Afname	C	5	\N	t
1311	1	BFvaLbvVtv	308020	Verrekenbare tijdelijke verschillen	D	4	\N	t
1312	1	BFvaLbvVtvBeg	0308020.01	Saldo per begin boekjaar	D	5	\N	t
1313	1	BFvaLbvVtvToe	0308020.02	Toename	D	5	\N	t
1314	1	BFvaLbvVtvAfn	0308020.03	Afname	C	5	\N	t
1315	1	BFvaLbvVtg	308030	Verrekenbare tijdelijke verschillen in verband met investeringen in groepsmaatschappijen enz.	D	4	\N	t
1316	1	BFvaLbvVtgBeg	0308030.01	Saldo per begin boekjaar	D	5	\N	t
1317	1	BFvaLbvVtgToe	0308030.02	Toename	D	5	\N	t
1318	1	BFvaLbvVtgAfn	0308030.03	Afname	C	5	\N	t
1319	1	BFvaSub	310000	Te vorderen BWS-subsidies	D	3	\N	t
1320	1	BFvaSubSub	310010	Hoofdsom te vorderen BWS-subsidies (langlopend)	D	4	\N	t
1321	1	BFvaSubSubTs1	0310010.01	Beginbalans (overname eindsaldo vorig jaar) te vorderen BWS-subsidie 1 (langlopend)	D	5	\N	t
1322	1	BFvaSubSubTs2	0310010.02	Beginbalans (overname eindsaldo vorig jaar) te vorderen BWS-subsidie 2 (langlopend)	D	5	\N	t
1323	1	BFvaSubSubTs3	0310010.03	Beginbalans (overname eindsaldo vorig jaar) te vorderen BWS-subsidie 3 (langlopend)	D	5	\N	t
1324	1	BFvaSubSubTs4	0310010.04	Beginbalans (overname eindsaldo vorig jaar) te vorderen BWS-subsidie 4 (langlopend)	D	5	\N	t
1325	1	BFvaSubSubTs5	0310010.05	Beginbalans (overname eindsaldo vorig jaar) te vorderen BWS-subsidie 5 (langlopend)	D	5	\N	t
1326	1	BFvaSubSubBea	0310010.06	Toename  te vorderen BWS-subsidie 1	D	5	\N	t
1327	1	BFvaSubSubBeb	0310010.07	Toename  te vorderen BWS-subsidie 2	D	5	\N	t
1328	1	BFvaSubSubBec	0310010.08	Toename  te vorderen BWS-subsidie 3	D	5	\N	t
1329	1	BFvaSubSubBed	0310010.09	Toename  te vorderen BWS-subsidie 4	D	5	\N	t
1330	1	BFvaSubSubBee	0310010.10	Toename  te vorderen BWS-subsidie 5	D	5	\N	t
1331	1	BFvaSubSubBef	0310010.11	Overige mutaties  te vorderen BWS-subsidie 1	D	5	\N	t
1332	1	BFvaSubSubBeg	0310010.12	Overige mutaties  te vorderen BWS-subsidie 2	D	5	\N	t
1333	1	BFvaSubSubBeh	0310010.13	Overige mutaties  te vorderen BWS-subsidie 3	D	5	\N	t
1334	1	BFvaSubSubBei	0310010.14	Overige mutaties  te vorderen BWS-subsidie 4	D	5	\N	t
1335	1	BFvaSubSubBej	0310010.15	Overige mutaties  te vorderen BWS-subsidie 5	D	5	\N	t
1336	1	BFvaSubSuc	310020	Cumulatieve aflossingen en waardeverminderingen te vorderen BWS-subsidies (langlopend)	C	4	\N	t
1337	1	BFvaSubSucBe1	0310020.01	Beginbalans cumulatieve aflossing te vorderen BWS-subsidie 1	C	5	\N	t
1338	1	BFvaSubSucBe2	0310020.02	Beginbalans cumulatieve aflossing te vorderen BWS-subsidie 2	C	5	\N	t
1339	1	BFvaSubSucBe3	0310020.03	Beginbalans cumulatieve aflossing te vorderen BWS-subsidie 3	C	5	\N	t
1340	1	BFvaSubSucBe4	0310020.04	Beginbalans cumulatieve aflossing te vorderen BWS-subsidie 4	C	5	\N	t
1341	1	BFvaSubSucBe5	0310020.05	Beginbalans cumulatieve aflossing te vorderen BWS-subsidie 5	C	5	\N	t
1342	1	BFvaSubSucBea	0310020.06	Aflossing / afname te vorderen BWS-subsidie 1	C	5	\N	t
1343	1	BFvaSubSucBeb	0310020.07	Aflossing / afname te vorderen BWS-subsidie 2	C	5	\N	t
1344	1	BFvaSubSucBec	0310020.08	Aflossing / afname te vorderen BWS-subsidie 3	C	5	\N	t
1345	1	BFvaSubSucBed	0310020.09	Aflossing / afname te vorderen BWS-subsidie 4	C	5	\N	t
1346	1	BFvaSubSucBee	0310020.10	Aflossing / afname te vorderen BWS-subsidie 5	C	5	\N	t
1347	1	BFvaLen	320000	Leningen u/g (langlopend)	D	3	\N	t
1348	1	BFvaLenLen	320010	Leningen u/g (langlopend)	D	4	\N	t
1349	1	BFvaLenLenLn1	0320010.01	Beginbalans lening u/g 1 (langlopend)	D	5	\N	t
1350	1	BFvaLenLenAv1	0320010.02	Aflossingsverplichting (overboeking naar kortlopend) lening u/g 1	C	5	\N	t
1351	1	BFvaLenLenAf1	0320010.03	Aflossing / afname in boekjaar lening u/g 1	C	5	\N	t
1352	1	BFvaLenLenUg1	0320010.04	Toename / uitgegeven in boekjaar lening u/g 1	D	5	\N	t
1353	1	BFvaLenLenOm1	0320010.06	Omrekeningsverschillen in boekjaar lening u/g 1	D	5	\N	t
1354	1	BFvaLenLenOv1	0320010.05	Overige mutaties lening u/g 1	D	5	\N	t
1355	1	BFvaLenLenWv1	0320010.07	Bijzondere waardeverminderingen lening u/g 1	C	5	\N	t
1356	1	BFvaLenLenTv1	0320010.08	Terugneming van bijzondere waardeverminderingen lening u/g 1	D	5	\N	t
1357	1	BFvaLenLenOw1	0320010.09	Overige mutaties waardeveranderingen lening u/g 1	D	5	\N	t
1358	1	BFvaLenLenLn2	0320010.11	Beginbalans lening u/g 2 (langlopend)	D	5	\N	t
1359	1	BFvaLenLenAv2	0320010.12	Aflossingsverplichting (overboeking naar kortlopend) lening u/g 2	C	5	\N	t
1360	1	BFvaLenLenAf2	0320010.13	Aflossing / afname in boekjaar lening u/g 2	C	5	\N	t
1361	1	BFvaLenLenUg2	0320010.14	Toename / uitgegeven in boekjaar lening u/g 2	D	5	\N	t
1362	1	BFvaLenLenOm2	0320010.16	Omrekeningsverschillen in boekjaar lening u/g 2	D	5	\N	t
1363	1	BFvaLenLenOv2	0320010.15	Overige mutaties lening u/g 2	D	5	\N	t
1364	1	BFvaLenLenWv2	0320010.17	Bijzondere waardeverminderingen lening u/g 2	C	5	\N	t
1365	1	BFvaLenLenTv2	0320010.18	Terugneming van bijzondere waardeverminderingen lening u/g 2	D	5	\N	t
1366	1	BFvaLenLenOw2	0320010.19	Overige mutaties waardeveranderingen lening u/g 2	D	5	\N	t
1367	1	BFvaLenLenLn3	0320010.21	Beginbalans lening u/g 3 (langlopend)	D	5	\N	t
1368	1	BFvaLenLenAv3	0320010.22	Aflossingsverplichting (overboeking naar kortlopend) lening u/g 3	C	5	\N	t
1369	1	BFvaLenLenAf3	0320010.23	Aflossing / afname in boekjaar lening u/g 3	C	5	\N	t
1370	1	BFvaLenLenUg3	0320010.24	Toename / uitgegeven in boekjaar lening u/g 3	D	5	\N	t
1371	1	BFvaLenLenOm3	0320010.26	Omrekeningsverschillen in boekjaar lening u/g 3	D	5	\N	t
1372	1	BFvaLenLenOv3	0320010.25	Overige mutaties lening u/g 3	D	5	\N	t
1373	1	BFvaLenLenWv3	0320010.27	Bijzondere waardeverminderingen lening u/g 3	C	5	\N	t
1374	1	BFvaLenLenTv3	0320010.28	Terugneming van bijzondere waardeverminderingen lening u/g 3	D	5	\N	t
1375	1	BFvaLenLenOw3	0320010.29	Overige mutaties waardeveranderingen lening u/g 3	D	5	\N	t
1376	1	BFvaLenLenLn4	0320010.31	Beginbalans lening u/g 4 (langlopend)	D	5	\N	t
1377	1	BFvaLenLenAv4	0320010.32	Aflossingsverplichting (overboeking naar kortlopend) lening u/g 4	C	5	\N	t
1378	1	BFvaLenLenAf4	0320010.33	Aflossing / afname in boekjaar lening u/g 4	C	5	\N	t
1379	1	BFvaLenLenUg4	0320010.34	Toename / uitgegeven in boekjaar lening u/g 4	D	5	\N	t
1380	1	BFvaLenLenOm4	0320010.36	Omrekeningsverschillen in boekjaar lening u/g 4	D	5	\N	t
1381	1	BFvaLenLenOv4	0320010.35	Overige mutaties lening u/g 4	D	5	\N	t
1382	1	BFvaLenLenWv4	0320010.37	Bijzondere waardeverminderingen lening u/g 4	C	5	\N	t
1383	1	BFvaLenLenTv4	0320010.38	Terugneming van bijzondere waardeverminderingen lening u/g 4	D	5	\N	t
1384	1	BFvaLenLenOw4	0320010.39	Overige mutaties waardeveranderingen lening u/g 4	D	5	\N	t
1385	1	BFvaLenLenLn5	0320010.41	Beginbalans lening u/g 5 (langlopend)	D	5	\N	t
1386	1	BFvaLenLenAv5	0320010.42	Aflossingsverplichting (overboeking naar kortlopend) lening u/g 5	C	5	\N	t
1387	1	BFvaLenLenAf5	0320010.43	Aflossing / afname in boekjaar lening u/g 5	C	5	\N	t
1388	1	BFvaLenLenUg5	0320010.44	Toename / uitgegeven in boekjaar lening u/g 5	D	5	\N	t
1389	1	BFvaLenLenOm5	0320010.46	Omrekeningsverschillen in boekjaar lening u/g 5	D	5	\N	t
1390	1	BFvaLenLenOv5	0320010.45	Overige mutaties lening u/g 5	D	5	\N	t
1391	1	BFvaLenLenWv5	0320010.47	Bijzondere waardeverminderingen lening u/g 5	C	5	\N	t
1392	1	BFvaLenLenTv5	0320010.48	Terugneming van bijzondere waardeverminderingen lening u/g 5	D	5	\N	t
1393	1	BFvaLenLenOw5	0320010.49	Overige mutaties waardeveranderingen lening u/g 5	D	5	\N	t
1394	1	BFvaIlg	330000	Interne Lening	D	3	\N	t
1395	1	BFvaIlgIlg	330010	Hoofdsom interne lening	D	4	\N	t
1396	1	BFvaIlgIlgBeg	0330010.01	Beginbalans (overname eindsaldo vorig jaar) hoofdsom interne lening	D	5	\N	t
1397	1	BFvaIlgIlgInv	0330010.02	Toename hoofdsom interne lening	D	5	\N	t
1398	1	BFvaIlgIlgOvm	0330010.03	Overige mutaties hoofdsom interne lening	D	5	\N	t
1399	1	BFvaIlgAvp	330030	Aflossingsverplichting interne lening	C	4	\N	t
1400	1	BFvaIlgAil	330020	Cumulatieve aflossing interne lening	C	4	\N	t
1401	1	BFvaIlgAilBeg	0330020.01	Beginbalans (overname eindsaldo vorig jaar) interne Lening	C	5	\N	t
1402	1	BFvaIlgAilAfl	0330020.02	Aflossing / afname in boekjaar interne Lening	C	5	\N	t
1403	1	BFvaNvm	340000	Netto vermogenswaarde niet-Daeb	D	3	\N	t
1404	1	BFvaNvmNvm	340010	Verkrijgingsprijs netto vermogenswaarde niet-Daeb	D	4	\N	t
1405	1	BFvaNvmNvmBeg	0340010.01	Beginbalans (overname eindsaldo vorig jaar) netto vermogenswaarde niet-Daeb	D	5	\N	t
1406	1	BFvaNvmNvmInv	0340010.02	Investeringen netto vermogenswaarde niet-Daeb	D	5	\N	t
1407	1	BFvaNvmNvmAdo	0340010.03	Bij overname verkregen activa netto vermogenswaarde niet-Daeb	D	5	\N	t
1408	1	BFvaNvmNvmDes	0340010.04	Desinvesteringen netto vermogenswaarde niet-Daeb	C	5	\N	t
1409	1	BFvaNvmNvmDda	0340010.05	Afstotingen netto vermogenswaarde niet-Daeb	C	5	\N	t
1410	1	BFvaNvmNvmOmv	0340010.09	Omrekeningsverschillen netto vermogenswaarde niet-Daeb	D	5	\N	t
1411	1	BFvaNvmNvmOvm	0340010.10	Overige mutaties netto vermogenswaarde niet-Daeb	D	5	\N	t
1412	1	BFvaNvmCae	340020	Cumulatieve afschrijvingen en waardeverminderingen netto vermogenswaarde niet-Daeb	C	4	\N	t
1413	1	BFvaNvmCaeBeg	0340020.01	Beginbalans (overname eindsaldo vorig jaar) netto vermogenswaarde niet-Daeb	C	5	\N	t
1414	1	BFvaNvmCaeAfs	0340020.02	Afschrijvingen netto vermogenswaarde niet-Daeb	C	5	\N	t
1415	1	BFvaNvmCaeDca	0340020.03	Afschrijving op desinvesteringen netto vermogenswaarde niet-Daeb	D	5	\N	t
1416	1	BFvaNvmCaeWvr	0340020.04	Bijzondere waardeverminderingen netto vermogenswaarde niet-Daeb	C	5	\N	t
1417	1	BFvaNvmCaeTvw	0340020.05	Terugneming van bijzondere waardeverminderingen netto vermogenswaarde niet-Daeb	D	5	\N	t
1418	1	BFvaNvmCuh	340030	Cumulatieve herwaarderingen netto vermogenswaarde niet-Daeb	D	4	\N	t
1419	1	BFvaNvmCuhBeg	0340030.01	Beginbalans (overname eindsaldo vorig jaar) netto vermogenswaarde niet-Daeb	D	5	\N	t
1420	1	BFvaNvmCuhHer	0340030.02	Herwaarderingen netto vermogenswaarde niet-Daeb	D	5	\N	t
1421	1	BFvaNvmCuhAir	0340030.05	Aandeel in resultaat deelnemingen netto vermogenswaarde niet-Daeb	D	5	\N	t
1422	1	BFvaNvmCuhDvd	0340030.06	Dividend van deelnemingen netto vermogenswaarde niet-Daeb	D	5	\N	t
1423	1	BFvaNvmCuhAfh	0340030.07	Afschrijving herwaardering niet-Daeb	C	5	\N	t
1424	1	BFvaNvmCuhOvm	0340030.09	Overige mutaties waardeverandering niet-Daeb	D	5	\N	t
1425	1	BFvaNvmCuhDeh	0340030.08	Desinvestering herwaardering niet-Daeb	D	5	\N	t
1426	1	BVrd	30	Voorraden	D	2	\N	t
1427	1	BVrdGeh	3002000	Voorraad grond- en hulpstoffen	D	3	\N	t
1428	1	BVrdGehVoo	3002010	Voorraad grond- en hulpstoffen, bruto voorraad grond- en hulpstoffen	D	4	\N	t
1429	1	BVrdGehTus	3002015	Tussenrekening voorraden	D	4	\N	t
1430	1	BVrdGehVic	3002020	Voorraad grond- en hulpstoffen, voorziening incourante grond- en hulpstoffen voorraad grond- en hulpstoffen	C	4	\N	t
1431	1	BVrdGehHvv	3002030	Voorraad grond- en hulpstoffen, herwaardering voorraden grond- en hulpstoffen voorraad grond- en hulpstoffen	D	4	\N	t
1432	1	BVrdGehHvi	3002040	Herclassificatie van en naar vastgoedbelegging in ontwikkeling bestemd voor eigen exploitatie	D	4	\N	t
1433	1	BVrdHal	3102000	Halffabrikaten	D	3	\N	t
1434	1	BVrdHalVoo	3102010	Halffabrikaten, bruto halffabrikaten	D	4	\N	t
1435	1	BVrdHalVic	3102020	Halffabrikaten, voorziening incourante halffabrikaten halffabrikaten	C	4	\N	t
1436	1	BVrdHalHvv	3102030	Halffabrikaten, herwaardering voorraden halffabrikaten halffabrikaten	D	4	\N	t
1437	1	BVrdOwe	3101000	Onderhanden werk	D	3	\N	t
1438	1	BVrdOweVoo	3101010	Onderhanden werk, bruto onderhanden werk	D	4	\N	t
1439	1	BVrdOweGet	3101020	Gefactureerde termijnen onderhanden werk onderhanden werk	C	4	\N	t
1440	1	BVrdOweVzv	3101030	Voorziening verliezen onderhanden werk onderhanden werk	C	4	\N	t
1441	1	BVrdGep	3103000	Gereed product	D	3	\N	t
1442	1	BVrdGepVoo	3103010	Gereed product, bruto gereed product	D	4	\N	t
1443	1	BVrdGepVic	3103020	Gereed product, voorziening incourante gereed product gereed product	C	4	\N	t
1444	1	BVrdGepHvv	3103030	Gereed product, herwaardering voorraden gereed product gereed product	D	4	\N	t
1445	1	BVrdHan	3001000	Handelsgoederen	D	3	\N	t
1446	1	BVrdHanVoo	3001010	Handelsgoederen, bruto handelsgoederen	D	4	\N	t
1447	1	BVrdHanMgr	3001011	Handelsgoederen, marge-voorraden	D	4	\N	t
1448	1	BVrdHanTus	3001015	Tussenrekening voorraden	D	4	\N	t
1449	1	BVrdHanVic	3001020	Handelsgoederen, voorziening incourante handelsgoederen handelsgoederen	C	4	\N	t
1450	1	BVrdHanHvv	3001030	Handelsgoederen, herwaardering voorraden handelsgoederen handelsgoederen	D	4	\N	t
1451	1	BVrdVrv	3004000	Vooruitbetalingen op voorraden	D	3	\N	t
1452	1	BVrdVrvVoo	3004010	Voorraad vooruitbetaald op voorraden, bruto vooruitbetalingen op voorraden	D	4	\N	t
1453	1	BVrdVrvVic	3004020	Voorraad vooruitbetaald op voorraden, voorziening incourante vooruitbetaald op voorraden vooruitbetalingen op voorraden	C	4	\N	t
1454	1	BVrdVrvHvv	3004030	Voorraad vooruitbetaald op voorraden, herwaardering voorraden vooruitbetaald op voorraden vooruitbetalingen op voorraden	D	4	\N	t
1455	1	BVrdEmb	3003000	Emballage	D	3	\N	t
1456	1	BVrdEmbVoo	3003010	Voorraad emballage, bruto emballage	D	4	\N	t
1457	1	BVrdEmbAfn	3003015	Uitgegeven emballage onder afnemers emballage	D	4	\N	t
1458	1	BVrdEmbVic	3003020	Emballage, voorziening incourante emballage emballage	C	4	\N	t
1459	1	BVrdEmbHvv	3003030	Emballage, herwaardering voorraden emballage emballage	D	4	\N	t
1460	1	BVrdVas	3104000	Vastgoed bestemd voor de verkoop	D	3	\N	t
1461	1	BVrdVasVbv	3104020	Vastgoed bestemd voor de verkoop vastgoed	D	4	\N	t
1462	1	BVrdVasVic	3104030	Afwaardering vastgoed bestemd voor de verkoop	C	4	\N	t
1463	1	BVrdVasHvv	3104040	Vastgoed, herwaardering van voorraden vastgoed vastgoed	D	4	\N	t
1464	1	BVrdVio	3104100	Vastgoed in ontwikkeling bestemd voor de verkoop	D	3	\N	t
1465	1	BVrdVioVoo	3104110	Vastgoed in ontwikkeling bestemd voor de verkoop vastgoed	D	4	\N	t
1466	1	BVrdVioVic	3104120	Afwaardering vastgoed in ontwikkeling bestemd voor de verkoop	C	4	\N	t
1467	1	BVrdNig	3105000	Niet gebruiksvee	D	3	\N	t
1468	1	BVrdNigVoo	3105010	Voorraad niet gebruiksvee	D	4	\N	t
1469	1	BVrdNigVic	3105020	Voorziening incourant niet gebruiksvee	C	4	\N	t
1470	1	BVrdNigHvv	3105030	Herwaardering van voorraden niet gebruiksvee	D	4	\N	t
1471	1	BVrdVoo	3106000	Overige voorraden	D	3	\N	t
1472	1	BVrdVooVoo	3106010	Overige voorraden	D	4	\N	t
1473	1	BVrdVooVic	3106020	Afwaardering overige voorraden	C	4	\N	t
1474	1	BPro	35	Onderhanden projecten (activa)	D	2	\N	t
1475	1	BProOnp	3501000	Onderhanden projecten in opdracht van derden	D	3	\N	t
1476	1	BProOnpGkn	3501010	Geactiveerde uitgaven voor nog niet verrichte prestaties van onderhanden projecten	D	4	\N	t
1477	1	BProOnpGknBeg	3501010.01	Beginbalans geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1478	1	BProOnpGknGeh	3501010.02	Grond- en hulpstoffen geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1479	1	BProOnpGknArk	3501010.03	Arbeidskosten geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1480	1	BProOnpGknOnd	3501010.04	Onderaanneming geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1481	1	BProOnpGknCon	3501010.05	Constructiematerialen geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1482	1	BProOnpGknGet	3501010.06	Grond en terreinen geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1483	1	BProOnpGknAie	3501010.07	Afschrijving installaties en uitrusting geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1484	1	BProOnpGknHvi	3501010.08	Huur van installaties en uitrusting geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1485	1	BProOnpGknTvi	3501010.09	Transport van installaties en uitrusting geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1486	1	BProOnpGknOet	3501010.10	Ontwerp en technische assistentie geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1487	1	BProOnpGknHeg	3501010.11	Herstellings- en garantiewerken geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1488	1	BProOnpGknCvd	3501010.12	Claims van derden geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1489	1	BProOnpGknVez	3501010.13	Verzekeringskosten geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1490	1	BProOnpGknRst	3501010.14	Rentekosten schulden tijdens vervaardiging geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1491	1	BProOnpGknOvh	3501010.15	Overheadkosten geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1492	1	BProOnpGknAko	3501010.16	Algemene kosten (opslag) geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1493	1	BProOnpGknWin	3501010.17	Winstopslag geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1494	1	BProOnpGknLbe	3501010.18	Incidentele baten en lasten geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1495	1	BProOnpGknLdb	3501010.19	Interne doorbelastingen binnen fiscale eenheid geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	C	5	\N	t
1496	1	BProOnpGknOpw	3501010.20	Opgeleverde werken geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	C	5	\N	t
1497	1	BProOnpGknOvm	3501010.21	Overige mutaties geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1498	1	BProOnpKvp	3501015	Geactiveerde kosten voor het verkrijgen van een project	D	4	\N	t
1499	1	BProOnpOpo	3501040	Cumulatieve projectopbrengsten van onderhanden projecten	C	4	\N	t
1500	1	BProOnpOpv	3501050	Onderhanden projecten in opdracht van derden, voorschotten onderhanden projecten in opdracht van derden	C	4	\N	t
1501	1	BProOnpGet	3501020	In rekening gebrachte termijnen	C	4	\N	t
1502	1	BProOnpGetBeg	3501020.01	Beginbalans gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	C	5	\N	t
1503	1	BProOnpGetBma	3501020.02	Belast met algemeen tarief gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	C	5	\N	t
1504	1	BProOnpGetBmv	3501020.03	Belast met verlaagd tarief gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	C	5	\N	t
1505	1	BProOnpGetBmo	3501020.04	Belast met overige tarieven gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	C	5	\N	t
1506	1	BProOnpGetBmn	3501020.05	Belast met nultarief of niet belast gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	C	5	\N	t
1507	1	BProOnpGetNbw	3501020.06	Niet belast wegens heffing verlegd gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	C	5	\N	t
1508	1	BProOnpGetLii	3501020.07	Installatie in landen binnen EU gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	C	5	\N	t
1509	1	BProOnpGetLiu	3501020.08	Installatie in landen buiten EU gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	C	5	\N	t
1510	1	BProOnpGetLdb	3501020.09	Interne doorbelastingen binnen fiscale eenheid gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1511	1	BProOnpGetOpw	3501020.10	Opgeleverde werken gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1512	1	BProOnpGetOvm	3501020.11	Overige mutaties gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	C	5	\N	t
1513	1	BProOnpOpi	3501060	Inhoudingen van opdrachtgevers op gedeclareerde termijnen van onderhanden projecten	D	4	\N	t
1514	1	BProOnpVzv	3501030	Voorziening verliezen onderhanden projecten in opdracht van derden	C	4	\N	t
1515	1	BProOnpVzvBeg	3501030.01	Beginbalans voorziening verliezen onderhanden projecten onderhanden projecten in opdracht van derden	C	5	\N	t
1516	1	BProOnpVzvToe	3501030.02	Toename voorziening verliezen onderhanden projecten onderhanden projecten in opdracht van derden	C	5	\N	t
1517	1	BProOnpVzvOnt	3501030.03	Onttrekking voorziening verliezen onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1518	1	BProOnpVzvVri	3501030.04	Vrijval voorziening verliezen onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1519	1	BProOnpVzvLdb	3501030.05	Interne doorbelastingen binnen fiscale eenheid voorziening verliezen onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1520	1	BProOnpVzvOpw	3501030.06	Opgeleverde werken voorziening verliezen onderhanden projecten onderhanden projecten in opdracht van derden	D	5	\N	t
1521	1	BProOnpVzvOvm	3501030.07	Overige mutaties voorziening verliezen onderhanden projecten onderhanden projecten in opdracht van derden	C	5	\N	t
1522	1	BProOnpWin	3501070	Winstopslag onderhanden projecten	C	4	\N	t
1523	1	BVor	11	Vorderingen	D	2	\N	t
1524	1	BVorDeb	1101000	Vorderingen op handelsdebiteuren	D	3	\N	t
1525	1	BVorDebHad	1101010	Handelsdebiteuren nominaal	D	4	\N	t
1526	1	BVorDebHdi	1101020	Handelsdebiteuren intercompany	D	4	\N	t
1527	1	BVorDebVdd	1101030	Voorziening voor oninbaarheid op vorderingen op handelsdebiteuren 	C	4	\N	t
1528	1	BVorDebHdb	1101040	Huurdebiteuren	D	4	\N	t
1529	1	BVorDebTus	1101050	Tussenrekening ontvangsten debiteuren (ontvangsten onderweg)	D	4	\N	t
1530	1	BVorDebVhd	1101060	Voorziening voor oninbaarheid op vorderingen op huurdebiteuren	C	4	\N	t
1531	1	BVorVog	1103099	Vorderingen op groepsmaatschappijen (kortlopend)	D	3	\N	t
1532	1	BVorVogVr1	1103100	Rekening-courant groepsmaatschappij 1	D	4	\N	t
1533	1	BVorVogVr1Rec	1103100.01	Rekening courant vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1534	1	BVorVogVr1Cwv	1103100.02	Cumulatieve waardeverminderingen	C	5	\N	t
1535	1	BVorVogVr1Doo	1103100.03	Doorbelastingen	D	5	\N	t
1536	1	BVorVogVr1Tvd	1103100.04	Te vorderen dividend vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1537	1	BVorVogVr1Wve	1103100.05	Waardeveranderingen	C	5	\N	t
1538	1	BVorVogVr1Ovm	1103100.06	Overige vorderingen vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1539	1	BVorVogVr2	1103101	Rekening-courant groepsmaatschappij 2	D	4	\N	t
1540	1	BVorVogVr2Rec	1103101.01	Rekening courant vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1541	1	BVorVogVr2Cwv	1103101.02	Cumulatieve waardeverminderingen	C	5	\N	t
1542	1	BVorVogVr2Doo	1103101.03	Doorbelastingen	D	5	\N	t
1543	1	BVorVogVr2Tvd	1103101.04	Te vorderen dividend vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1544	1	BVorVogVr2Wve	1103101.05	Waardeveranderingen	C	5	\N	t
1545	1	BVorVogVr2Ovm	1103101.06	Overige vorderingen vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1546	1	BVorVogVr3	1103102	Rekening-courant groepsmaatschappij 3	D	4	\N	t
1547	1	BVorVogVr3Rec	1103102.01	Rekening courant vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1548	1	BVorVogVr3Cwv	1103102.02	Cumulatieve waardeverminderingen	C	5	\N	t
1549	1	BVorVogVr3Doo	1103102.03	Doorbelastingen	D	5	\N	t
1550	1	BVorVogVr3Tvd	1103102.04	Te vorderen dividend vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1551	1	BVorVogVr3Wve	1103102.05	Waardeveranderingen	C	5	\N	t
1552	1	BVorVogVr3Ovm	1103102.06	Overige vorderingen vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1553	1	BVorVogVr4	1103103	Rekening-courant groepsmaatschappij 4	D	4	\N	t
1554	1	BVorVogVr4Rec	1103103.01	Rekening courant vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1555	1	BVorVogVr4Cwv	1103103.02	Cumulatieve waardeverminderingen	C	5	\N	t
1556	1	BVorVogVr4Doo	1103103.03	Doorbelastingen	D	5	\N	t
1557	1	BVorVogVr4Tvd	1103103.04	Te vorderen dividend vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1558	1	BVorVogVr4Wve	1103103.05	Waardeveranderingen	C	5	\N	t
1559	1	BVorVogVr4Ovm	1103103.06	Overige vorderingen vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1560	1	BVorVogVr5	1103104	Rekening-courant groepsmaatschappij 5	D	4	\N	t
1561	1	BVorVogVr5Rec	1103104.01	Rekening courant vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1562	1	BVorVogVr5Cwv	1103104.02	Cumulatieve waardeverminderingen	C	5	\N	t
1563	1	BVorVogVr5Doo	1103104.03	Doorbelastingen	D	5	\N	t
1564	1	BVorVogVr5Tvd	1103104.04	Te vorderen dividend vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1565	1	BVorVogVr5Wve	1103104.05	Waardeveranderingen	C	5	\N	t
1566	1	BVorVogVr5Ovm	1103104.06	Overige vorderingen vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1567	1	BVorVogVg1	1103105	Vordering / lening groepsmaatschappij 1	D	4	\N	t
1568	1	BVorVogVg1Hoo	1103105.01	Saldo hoofdsom lening u/g vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1569	1	BVorVogVg1Afl	1103105.02	Aflossing leningen u/g vorderingen op groepsmaatschappijen (kortlopend)	C	5	\N	t
1570	1	BVorVogVg1Tvr	1103105.03	Te vorderen rente leningen u/g vorderingen op groepsmaatschappijen (kortlopend)	D	5	\N	t
1571	1	BVorVogDae	1103106	Rekening-courant DAEB	D	4	\N	t
1572	1	BVorVogDaeRec	1103106.01	Rekening courant	D	5	\N	t
1573	1	BVorVogDaeCwv	1103106.02	Cumulatieve waardeverminderingen	C	5	\N	t
1574	1	BVorVogDaeDoo	1103106.03	Doorbelastingen	D	5	\N	t
1575	1	BVorVogDaeTvd	1103106.04	Te vorderen dividend	D	5	\N	t
1576	1	BVorVogDaeWve	1103106.05	Waardeveranderingen	C	5	\N	t
1577	1	BVorVogDaeOvm	1103106.06	Overige mutaties	D	5	\N	t
1578	1	BVorVogNda	1103107	Rekening-courant Niet-DAEB	D	4	\N	t
1579	1	BVorVogNdaRec	1103107.01	Rekening courant	D	5	\N	t
1580	1	BVorVogNdaCwv	1103107.02	Cumulatieve waardeverminderingen	C	5	\N	t
1581	1	BVorVogNdaDoo	1103107.03	Doorbelastingen	D	5	\N	t
1582	1	BVorVogNdaTvd	1103107.04	Te vorderen dividend	D	5	\N	t
1583	1	BVorVogNdaWve	1103107.05	Waardeveranderingen	C	5	\N	t
1584	1	BVorVogNdaOvm	1103107.06	Overige mutaties	D	5	\N	t
1585	1	BVorVov	1103109	Vorderingen op overige verbonden maatschappijen (kortlopend)	D	3	\N	t
1586	1	BVorVovVr1	1103110	Rekening-courant overige verbonden maatschappij 1	D	4	\N	t
1587	1	BVorVovVr1Rec	1103110.01	Rekening courant overige verbonden maatschappij 1 (kortlopend)	D	5	\N	t
1588	1	BVorVovVr1Cwv	1103110.02	Cumulatieve waardeverminderingen vordering overige verbonden maatschappij 1 (kortlopend)	C	5	\N	t
1589	1	BVorVovVr1Doo	1103110.03	Doorbelastingen vordering overige verbonden maatschappij 1 (kortlopend)	D	5	\N	t
1590	1	BVorVovVr1Tvd	1103110.04	Te vorderen dividend vordering overige verbonden maatschappij 1 (kortlopend)	D	5	\N	t
1591	1	BVorVovVr1Wve	1103110.05	Waardeveranderingen vordering overige verbonden maatschappij 1 (kortlopend)	C	5	\N	t
1592	1	BVorVovVr1Ovm	1103110.06	Overige mutaties vordering overige verbonden maatschappij 1 (kortlopend)	D	5	\N	t
1593	1	BVorVovVr2	1103111	Rekening-courant overige verbonden maatschappij 2	D	4	\N	t
1594	1	BVorVovVr2Rec	1103111.01	Rekening courant vordering overige verbonden maatschappij 2 (kortlopend)	D	5	\N	t
1595	1	BVorVovVr2Cwv	1103111.02	Cumulatieve waardeverminderingen vordering overige verbonden maatschappij 2 (kortlopend)	C	5	\N	t
1596	1	BVorVovVr2Doo	1103111.03	Doorbelastingen vordering overige verbonden maatschappij 2 (kortlopend)	D	5	\N	t
1597	1	BVorVovVr2Tvd	1103111.04	Te vorderen dividend vordering overige verbonden maatschappij 2 (kortlopend)	D	5	\N	t
1598	1	BVorVovVr2Wve	1103111.05	Waardeveranderingen vordering overige verbonden maatschappij 2 (kortlopend)	C	5	\N	t
1599	1	BVorVovVr2Ovm	1103111.06	Overige vorderingen vordering overige verbonden maatschappij 2 (kortlopend)	D	5	\N	t
1600	1	BVorVovVr3	1103112	Rekening-courant overige verbonden maatschappij 3	D	4	\N	t
1601	1	BVorVovVr3Rec	1103112.01	Rekening courant vordering overige verbonden maatschappij 3 (kortlopend)	D	5	\N	t
1602	1	BVorVovVr3Cwv	1103112.02	Cumulatieve waardeverminderingen vordering overige verbonden maatschappij 3 (kortlopend)	C	5	\N	t
1603	1	BVorVovVr3Doo	1103112.03	Doorbelastingen vordering overige verbonden maatschappij 3 (kortlopend)	D	5	\N	t
1604	1	BVorVovVr3Tvd	1103112.04	Te vorderen dividend vordering overige verbonden maatschappij 3 (kortlopend)	D	5	\N	t
1605	1	BVorVovVr3Wve	1103112.05	Waardeveranderingen vordering overige verbonden maatschappij 3 (kortlopend)	C	5	\N	t
1606	1	BVorVovVr3Ovm	1103112.06	Overige vorderingen vordering overige verbonden maatschappij 3 (kortlopend)	D	5	\N	t
1607	1	BVorVovVr4	1103113	Rekening-courant overige verbonden maatschappij 4	D	4	\N	t
1608	1	BVorVovVr4Rec	1103113.01	Rekening courant vordering overige verbonden maatschappij 4 (kortlopend)	D	5	\N	t
1609	1	BVorVovVr4Cwv	1103113.02	Cumulatieve waardeverminderingen vordering overige verbonden maatschappij 4 (kortlopend)	C	5	\N	t
1610	1	BVorVovVr4Doo	1103113.03	Doorbelastingen vordering overige verbonden maatschappij 4 (kortlopend)	D	5	\N	t
1611	1	BVorVovVr4Tvd	1103113.04	Te vorderen dividend vordering overige verbonden maatschappij 4 (kortlopend)	D	5	\N	t
1612	1	BVorVovVr4Wve	1103113.05	Waardeveranderingen vordering overige verbonden maatschappij 4 (kortlopend)	C	5	\N	t
1613	1	BVorVovVr4Ovm	1103113.06	Overige vorderingen vordering overige verbonden maatschappij 4 (kortlopend)	D	5	\N	t
1614	1	BVorVovVr5	1103114	Rekening-courant overige verbonden maatschappij 5	D	4	\N	t
1615	1	BVorVovVr5Rec	1103114.01	Rekening courant vordering overige verbonden maatschappij 5 (kortlopend)	D	5	\N	t
1616	1	BVorVovVr5Cwv	1103114.02	Cumulatieve waardeverminderingen vordering overige verbonden maatschappij 5 (kortlopend)	C	5	\N	t
1617	1	BVorVovVr5Doo	1103114.03	Doorbelastingen vordering overige verbonden maatschappij 5 (kortlopend)	D	5	\N	t
1618	1	BVorVovVr5Tvd	1103114.04	Te vorderen dividend vordering overige verbonden maatschappij 5 (kortlopend)	D	5	\N	t
1619	1	BVorVovVr5Wve	1103114.05	Waardeveranderingen vordering overige verbonden maatschappij 5 (kortlopend)	C	5	\N	t
1620	1	BVorVovVr5Ovm	1103114.06	Overige vorderingen vordering overige verbonden maatschappij 5 (kortlopend)	D	5	\N	t
1621	1	BVorVovVo1	1103115	Vordering / lening overige verbonden maatschappij 1	D	4	\N	t
1622	1	BVorVovVo1Hoo	1103115.01	Saldo hoofdsom lening u/g overige verbonden maatschappij 1	D	5	\N	t
1623	1	BVorVovVo1Afl	1103115.02	Aflossing leningen u/g overige verbonden maatschappij 1	C	5	\N	t
1624	1	BVorVovVo1Tvr	1103115.03	Te vorderen rente leningen u/g overige verbonden maatschappij 1	D	5	\N	t
1625	1	BVorVop	1103119	Vorderingen op participanten en op maatschappijen waarin wordt deelgenomen (kortlopend)	D	3	\N	t
1626	1	BVorVopVr1	1103120	Rekening-courant participant en op maatschappij waarin wordt deelgenomen 1 (kortlopend)	D	4	\N	t
1627	1	BVorVopVr1Rec	1103120.01	Rekening courant vordering op participanten en op maatschappijen waarin wordt deelgenomen 1 (kortlopend)	D	5	\N	t
1628	1	BVorVopVr1Cwv	1103120.02	Cumulatieve waardeverminderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 1 (kortlopend)	C	5	\N	t
1629	1	BVorVopVr1Doo	1103120.03	Doorbelastingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 1 (kortlopend)	D	5	\N	t
1630	1	BVorVopVr1Tvd	1103120.04	Te vorderen dividend vordering op participanten en op maatschappijen waarin wordt deelgenomen 1 (kortlopend)	D	5	\N	t
1631	1	BVorVopVr1Wve	1103120.05	Waardeveranderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 1 (kortlopend)	C	5	\N	t
1632	1	BVorVopVr1Ovm	1103120.06	Overige vorderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 1 (kortlopend)	D	5	\N	t
1633	1	BVorVopVr2	1103121	Rekening-courant participant en op maatschappij waarin wordt deelgenomen 2 (kortlopend)	D	4	\N	t
1634	1	BVorVopVr2Rec	1103121.01	Rekening courant vordering op participanten en op maatschappijen waarin wordt deelgenomen 2 (kortlopend)	D	5	\N	t
1635	1	BVorVopVr2Cwv	1103121.02	Cumulatieve waardeverminderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 2 (kortlopend)	C	5	\N	t
1636	1	BVorVopVr2Doo	1103121.03	Doorbelastingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 2 (kortlopend)	D	5	\N	t
1637	1	BVorVopVr2Tvd	1103121.04	Te vorderen dividend vordering op participanten en op maatschappijen waarin wordt deelgenomen 2 (kortlopend)	D	5	\N	t
1638	1	BVorVopVr2Wve	1103121.05	Waardeveranderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 2 (kortlopend)	C	5	\N	t
1639	1	BVorVopVr2Ovm	1103121.06	Overige vorderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 2 (kortlopend)	D	5	\N	t
1640	1	BVorVopVr3	1103122	Rekening-courant participant en op maatschappij waarin wordt deelgenomen 3 (kortlopend)	D	4	\N	t
1641	1	BVorVopVr3Rec	1103122.01	Rekening courant vordering op participanten en op maatschappijen waarin wordt deelgenomen 3 (kortlopend)	D	5	\N	t
1694	1	BVorVpkTto	1103150	Terug te ontvangen pensioenpremies vorderingen uit hoofde van pensioenen	D	4	\N	t
1642	1	BVorVopVr3Cwv	1103122.02	Cumulatieve waardeverminderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 3 (kortlopend)	C	5	\N	t
1643	1	BVorVopVr3Doo	1103122.03	Doorbelastingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 3 (kortlopend)	D	5	\N	t
1644	1	BVorVopVr3Tvd	1103122.04	Te vorderen dividend vordering op participanten en op maatschappijen waarin wordt deelgenomen 3 (kortlopend)	D	5	\N	t
1645	1	BVorVopVr3Wve	1103122.05	Waardeveranderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 3 (kortlopend)	C	5	\N	t
1646	1	BVorVopVr3Ovm	1103122.06	Overige vorderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 3 (kortlopend)	D	5	\N	t
1647	1	BVorVopVr4	1103123	Rekening-courant participant en op maatschappij waarin wordt deelgenomen 4 (kortlopend)	D	4	\N	t
1648	1	BVorVopVr4Rec	1103123.01	Rekening courant vordering op participanten en op maatschappijen waarin wordt deelgenomen 4 (kortlopend)	D	5	\N	t
1649	1	BVorVopVr4Cwv	1103123.02	Cumulatieve waardeverminderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 4 (kortlopend)	C	5	\N	t
1650	1	BVorVopVr4Doo	1103123.03	Doorbelastingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 4 (kortlopend)	D	5	\N	t
1651	1	BVorVopVr4Tvd	1103123.04	Te vorderen dividend vordering op participanten en op maatschappijen waarin wordt deelgenomen 4 (kortlopend)	D	5	\N	t
1652	1	BVorVopVr4Wve	1103123.05	Waardeveranderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 4 (kortlopend)	C	5	\N	t
1653	1	BVorVopVr4Ovm	1103123.06	Overige vorderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 4 (kortlopend)	D	5	\N	t
1654	1	BVorVopVr5	1103124	Rekening-courant participant en op maatschappij waarin wordt deelgenomen 5 (kortlopend)	D	4	\N	t
1655	1	BVorVopVr5Rec	1103124.01	Rekening courant vordering op participanten en op maatschappijen waarin wordt deelgenomen 5 (kortlopend)	D	5	\N	t
1656	1	BVorVopVr5Cwv	1103124.02	Cumulatieve waardeverminderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 5 (kortlopend)	C	5	\N	t
1657	1	BVorVopVr5Doo	1103124.03	Doorbelastingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 5 (kortlopend)	D	5	\N	t
1658	1	BVorVopVr5Tvd	1103124.04	Te vorderen dividend vordering op participanten en op maatschappijen waarin wordt deelgenomen 5 (kortlopend)	D	5	\N	t
1659	1	BVorVopVr5Wve	1103124.05	Waardeveranderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 5 (kortlopend)	C	5	\N	t
1660	1	BVorVopVr5Ovm	1103124.06	Overige vorderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 5 (kortlopend)	D	5	\N	t
1661	1	BVorVopVo1	1103125	Vordering / lening participant en op maatschappij waarin wordt deelgenomen 1	D	4	\N	t
1662	1	BVorVopVo1Hoo	1103125.01	Saldo hoofdsom lening u/g participant en op maatschappij waarin wordt deelgenomen 1	D	5	\N	t
1663	1	BVorVopVo1Afl	1103125.02	Aflossing leningen u/g participant en op maatschappij waarin wordt deelgenomen 1	C	5	\N	t
1664	1	BVorVopVo1Tvr	1103125.03	Te vorderen rente leningen u/g participant en op maatschappij waarin wordt deelgenomen 1	D	5	\N	t
1665	1	BVorVlc	1103300	Vorderingen op leden van de coöperatie	D	3	\N	t
1666	1	BVorVlcLi1	1103310	Vorderingen op lid A van de coöperatie	D	4	\N	t
1667	1	BVorVlcLi2	1103320	Vorderingen op lid B van de coöperatie	D	4	\N	t
1668	1	BVorVlcLi3	1103330	Vorderingen op lid C van de coöperatie	D	4	\N	t
1669	1	BVorVlcLi4	1103340	Vorderingen op lid D van de coöperatie	D	4	\N	t
1670	1	BVorVlcLi5	1103350	Vorderingen op lid E van de coöperatie	D	4	\N	t
1671	1	BVorVao	1103129	Van aandeelhouders opgevraagde stortingen	D	3	\N	t
1672	1	BVorVaoNtv	1103130	Nog te verrichten stortingen op aandelen van aandeelhouders opgevraagde stortingen	D	4	\N	t
1673	1	BVorVaoVuh	1103135	Vorderingen uit hoofde van leningen en voorschotten aan leden of houders van aandelen op naam (kortlopend) van aandeelhouders opgevraagde stortingen	D	4	\N	t
1674	1	BVorVbk	1103159	Vorderingen uit hoofde van belastingen	D	3	\N	t
1675	1	BVorVbkVbk	1103160	Vorderingen uit hoofde van belastingen	D	4	\N	t
1676	1	BVorVbkTvo	1102010	Terug te vorderen Omzetbelasting vorderingen uit hoofde van belastingen	D	4	\N	t
1677	1	BVorVbkTvoToi	1102010.01	Terug te ontvangen binnenlandse omzetbelasting vorderingen uit hoofde van belastingen	D	5	\N	t
1678	1	BVorVbkTvoTou	1102010.02	Terug te ontvangen buitenlandse omzetbelasting vorderingen uit hoofde van belastingen	D	5	\N	t
1679	1	BVorVbkEob	1102015	Terug te vorderen EU omzetbelasting	D	4	\N	t
1680	1	BVorVbkTvl	1102020	Terug te vorderen Loonheffing vorderingen uit hoofde van belastingen	D	4	\N	t
1681	1	BVorVbkTvv	1102030	Terug te vorderen Vennootschapsbelasting vorderingen uit hoofde van belastingen	D	4	\N	t
1682	1	BVorVbkTtv	1102040	Terug te vorderen Dividendbelasting vorderingen uit hoofde van belastingen	D	4	\N	t
1683	1	BVorVbkInd	1102050	Ingehouden dividendbelasting	D	4	\N	t
1684	1	BVorVbkTtb	1102060	Terug te vorderen overige belastingen vorderingen uit hoofde van belastingen	D	4	\N	t
1685	1	BVorLbv	1103169	Latente belastingvorderingen (kortlopend)	D	3	\N	t
1686	1	BVorLbvBlk	1103170	Latente belastingvorderingen (kortlopend)	D	4	\N	t
1687	1	BVorLbvCba	1103171	Te verrekenen met verliezen uit het verleden latente belastingvorderingen (kortlopend)	D	4	\N	t
1688	1	BVorLbvCfo	1103172	Te verrekenen met toekomstige verliezen latente belastingvorderingen (kortlopend)	D	4	\N	t
1689	1	BVorTsk	1103039	Te vorderen subsidies	D	3	\N	t
1690	1	BVorTskTos	1103040	Te vorderen overheidssubsidies te vorderen subsidies	D	4	\N	t
1691	1	BVorTskTls	1103050	Te vorderen loonsubsidie te vorderen subsidies	D	4	\N	t
1692	1	BVorTskTvs	1103060	Te vorderen overige subsidies te vorderen subsidies	D	4	\N	t
1693	1	BVorVpk	1103149	Vorderingen uit hoofde van pensioenen	D	3	\N	t
1695	1	BVorVpkTop	1103155	Te ontvangen pensioenuitkeringen vorderingen uit hoofde van pensioenen	D	4	\N	t
1696	1	BVorOvr	1103000	Overige vorderingen	D	3	\N	t
1697	1	BVorOvrLvb	1103005	Leningen, voorschotten en garanties ten behoeve van bestuurders en gewezen bestuurders overige vorderingen (kortlopend)	D	4	\N	t
1698	1	BVorOvrLvc	1103006	Leningen, voorschotten en garanties ten behoeve van commissarissen en gewezen commissarissen overige vorderingen (kortlopend)	D	4	\N	t
1699	1	BVorOvrLek	1103180	Ledenrekeningen overige vorderingen	D	4	\N	t
1700	1	BVorOvrRcb	1103140	Rekening-courant bestuurders overige vorderingen (kortlopend)	D	4	\N	t
1701	1	BVorOvrRcbRb1	1103140.01	Rekening-courant bestuurder 1	D	5	\N	t
1702	1	BVorOvrRcbRb2	1103140.02	Rekening-courant bestuurder 2	D	5	\N	t
1703	1	BVorOvrRcbRb3	1103140.03	Rekening-courant bestuurder 3	D	5	\N	t
1704	1	BVorOvrRcbRb4	1103140.04	Rekening-courant bestuurder 4	D	5	\N	t
1705	1	BVorOvrRcbRb5	1103140.05	Rekening-courant bestuurder 5	D	5	\N	t
1706	1	BVorOvrRcc	1103141	Rekening-courant commissarissen overige vorderingen (kortlopend)	D	4	\N	t
1707	1	BVorOvrRccRc1	1103141.01	Rekening-courant commissaris 1	D	5	\N	t
1708	1	BVorOvrRccRc2	1103141.02	Rekening-courant commissaris 2	D	5	\N	t
1709	1	BVorOvrRccRc3	1103141.03	Rekening-courant commissaris 3	D	5	\N	t
1710	1	BVorOvrRccRc4	1103141.04	Rekening-courant commissaris 4	D	5	\N	t
1711	1	BVorOvrRccRc5	1103141.05	Rekening-courant commissaris 5	D	5	\N	t
1712	1	BVorOvrRco	1103142	Rekening-courant overigen (kortlopend)	D	4	\N	t
1713	1	BVorOvrRcoRo1	1103142.01	Rekening-courant overige 1	D	5	\N	t
1714	1	BVorOvrRcoRo2	1103142.02	Rekening-courant overige 2	D	5	\N	t
1715	1	BVorOvrRcoRo3	1103142.03	Rekening-courant overige 3	D	5	\N	t
1716	1	BVorOvrRcoRo4	1103142.04	Rekening-courant overige 4	D	5	\N	t
1717	1	BVorOvrRcoRo5	1103142.05	Rekening-courant overige 5	D	5	\N	t
1718	1	BVorOvrRca	1103143	Rekening-courant aandeelhouders (kortlopend)	D	4	\N	t
1719	1	BVorOvrRcaRa1	1103143.01	Rekening-courant aandeelhouder 1	D	5	\N	t
1720	1	BVorOvrRcaRa2	1103143.02	Rekening-courant aandeelhouder 2	D	5	\N	t
1721	1	BVorOvrRcaRa3	1103143.03	Rekening-courant aandeelhouder 3	D	5	\N	t
1722	1	BVorOvrRcaRa4	1103143.04	Rekening-courant aandeelhouder 4	D	5	\N	t
1723	1	BVorOvrRcaRa5	1103143.05	Rekening-courant aandeelhouder 5	D	5	\N	t
1724	1	BVorOvrWbs	1103010	Waarborgsommen overige vorderingen	D	4	\N	t
1725	1	BVorOvrVrb	1103090	Vooruitbetalingen	D	4	\N	t
1726	1	BVorOvrTvr	1103070	Te vorderen rente lening	D	4	\N	t
1727	1	BVorOvrTvo	1103080	Te vorderen overige rente	D	4	\N	t
1728	1	BVorOvrOvk	1103190	Overige vorderingen overige vorderingen	D	4	\N	t
1729	1	BVorOvrLen	1103200	Leningen u/g (kortlopend)	D	4	\N	t
1730	1	BVorOvrLenLn1	1103200.01	Lening u/g 1 (kortlopend)	D	5	\N	t
1731	1	BVorOvrLenLn2	1103200.02	Lening u/g 2 (kortlopend)	D	5	\N	t
1732	1	BVorOvrLenLn3	1103200.03	Lening u/g 3 (kortlopend)	D	5	\N	t
1733	1	BVorOvrLenLn4	1103200.04	Lening u/g 4 (kortlopend)	D	5	\N	t
1734	1	BVorOvrLenLn5	1103200.05	Lening u/g 5 (kortlopend)	D	5	\N	t
1735	1	BVorOvrIln	1103390	Interne lening (kortlopend)	D	4	\N	t
1736	1	BVorOvrMcd	1103400	Margin-call deposito	D	4	\N	t
1737	1	BVorOvrOvd	1104115	Overige vorderingen daeb	D	4	\N	t
1738	1	BVorOvrOvn	1104125	Overige vorderingen niet-daeb	D	4	\N	t
1739	1	BVorOvrNvd	1103500	Nog te ontvangen vouchers van derden	D	4	\N	t
1740	1	BVorOva	1104000	Overlopende activa	D	3	\N	t
1741	1	BVorOvaVof	1104010	Vooruitbetaalde facturen overlopende activa	D	4	\N	t
1742	1	BVorOvaVbs	1104020	Vooruitverzonden op bestellingen overlopende activa	D	4	\N	t
1743	1	BVorOvaNtf	1104030	Nog te factureren of nog te verzenden facturen overlopende activa	D	4	\N	t
1744	1	BVorOvaNoo	1104070	Nog te ontvangen / vooruitbetaalde omzetbonificaties overlopende activa	D	4	\N	t
1745	1	BVorOvaNtp	1104080	Nog te ontvangen / vooruitbetaalde provisies overlopende activa	D	4	\N	t
1746	1	BVorOvaNth	1104090	Nog te ontvangen / vooruitbetaalde huren overlopende activa	D	4	\N	t
1747	1	BVorOvaNov	1104100	Nog te ontvangen / vooruitbetaalde vergoedingen overlopende activa	D	4	\N	t
1748	1	BVorOvaNob	1104110	Nog te ontvangen / vooruitbetaalde bijdragen overlopende activa	D	4	\N	t
1749	1	BVorOvaVop	1104120	Vooruitbetaalde personeelskosten overlopende activa	D	4	\N	t
1750	1	BVorOvaVoh	1104130	Vooruitbetaalde huisvestingskosten overlopende activa	D	4	\N	t
1751	1	BVorOvaVem	1104140	Vooruitbetaalde exploitatie- en machinekosten overlopende activa	D	4	\N	t
1752	1	BVorOvaVov	1104150	Vooruitbetaalde verkoopkosten overlopende activa	D	4	\N	t
1753	1	BVorOvaVak	1104160	Vooruitbetaalde autokosten overlopende activa	D	4	\N	t
1754	1	BVorOvaVtr	1104170	Vooruitbetaalde transportkosten overlopende activa	D	4	\N	t
1755	1	BVorOvaVok	1104180	Vooruitbetaalde kantoorkosten overlopende activa	D	4	\N	t
1756	1	BVorOvaVoo	1104190	Vooruitbetaalde organisatiekosten overlopende activa	D	4	\N	t
1757	1	BVorOvaVas	1104200	Vooruitbetaalde assurantiekosten overlopende activa	D	4	\N	t
1758	1	BVorOvaVae	1104210	Vooruitbetaalde accountants- en advieskosten overlopende activa	D	4	\N	t
1759	1	BVorOvaVoa	1104220	Vooruitbetaalde administratiekosten overlopende activa	D	4	\N	t
1760	1	BVorOvaVkf	1104230	Vooruitbetaalde kosten fondsenwerving overlopende activa	D	4	\N	t
1761	1	BVorOvaVan	1104240	Vooruitbetaalde andere kosten overlopende activa	D	4	\N	t
1762	1	BVorOvaTor	1104040	Te ontvangen rente overlopende activa	D	4	\N	t
1763	1	BVorOvaVbr	1104050	Vooruitbetaalde rente overlopende activa	D	4	\N	t
1764	1	BVorOvaOoa	1104060	Overige overlopende activa overlopende activa	D	4	\N	t
1765	1	BVorOvaErf	1104075	Nog te ontvangen / vooruitbetaalde erfpacht overlopende activa	D	4	\N	t
1766	1	BVorOvaNos	1104085	Nog te ontvangen / vooruitbetaalde servicekosten overlopende activa	D	4	\N	t
1767	1	BVorOvaNtr	1104095	Nog toe rekenen rente swaps overlopende activa	D	4	\N	t
1768	1	BVorOvaPen	1104250	Pensioenvordering onder overlopende activa	D	4	\N	t
1769	1	BVorTus	1105000	Tussenrekeningen	D	3	\N	t
1770	1	BVorTusTbt	1105100	Tussenrekeningen betalingen	D	4	\N	t
1771	1	BVorTusTbtTca	1105110	Tussenrekening contante aanbetalingen tussenrekeningen betalingen	D	5	\N	t
1772	1	BVorTusTbtTcb	1105120	Tussenrekening creditcardbetalingen tussenrekeningen betalingen	D	5	\N	t
1773	1	BVorTusTsa	1105200	Tussenrekeningen salarissen	D	4	\N	t
1774	1	BVorTusTsaTbn	1105210	Tussenrekening brutoloon tussenrekeningen salarissen	D	5	\N	t
1775	1	BVorTusTsaTgb	1105220	Tussenrekening brutoinhouding tussenrekeningen salarissen	D	5	\N	t
1776	1	BVorTusTsaTnl	1105230	Tussenrekening nettoloon tussenrekeningen salarissen	D	5	\N	t
1777	1	BVorTusTsaTni	1105240	Tussenrekening nettoinhoudingen tussenrekeningen salarissen	D	5	\N	t
1778	1	BVorTusTin	1105300	Tussenrekeningen inkopen	D	4	\N	t
1779	1	BVorTusTinTog	1105310	Tussenrekening nog te ontvangen goederen tussenrekeningen inkopen	D	5	\N	t
1780	1	BVorTusTinTof	1105320	Tussenrekening nog te ontvangen facturen tussenrekeningen inkopen	D	5	\N	t
1781	1	BVorTusTinTiv	1105330	Tussenrekening inkoopverschillen tussenrekeningen inkopen	D	5	\N	t
1782	1	BVorTusTpj	1105400	Tussenrekeningen projecten	D	4	\N	t
1783	1	BVorTusTpjTpk	1105410	Tussenrekening projectkosten tussenrekeningen projecten	D	5	\N	t
1784	1	BVorTusTpjTpo	1105420	Tussenrekening projectopbrengsten tussenrekeningen projecten	D	5	\N	t
1785	1	BVorTusTpjTpv	1105430	Tussenrekening projectverschillen tussenrekeningen projecten	D	5	\N	t
1786	1	BVorTusTpr	1105500	Tussenrekeningen productie	D	4	\N	t
1787	1	BVorTusTprTmv	1105510	Tussenrekening materiaalverbruik tussenrekeningen productie	D	5	\N	t
1788	1	BVorTusTprTmu	1105520	Tussenrekening manuren tussenrekeningen productie	D	5	\N	t
1789	1	BVorTusTprTau	1105530	Tussenrekening machineuren tussenrekeningen productie	D	5	\N	t
1790	1	BVorTusTprTbu	1105540	Tussenrekening te dekken budget tussenrekeningen productie	D	5	\N	t
1791	1	BVorTusTprTbg	1105550	Tussenrekening budget tussenrekeningen productie	D	5	\N	t
1792	1	BVorTusTdv	1105600	Tussenrekeningen dienstverlening	D	4	\N	t
1793	1	BVorTusTdvTcp	1105610	Tussenrekening capaciteit tussenrekeningen dienstverlening	D	5	\N	t
1794	1	BVorTusTdvTma	1105620	Tussenrekening materialen tussenrekeningen dienstverlening	D	5	\N	t
1795	1	BVorTusTdvTuu	1105630	Tussenrekening uren tussenrekeningen dienstverlening	D	5	\N	t
1796	1	BVorTusTdvInv	1105640	Inkomende verschotten tussenrekeningen dienstverlening	D	5	\N	t
1797	1	BVorTusTdvVso	1105650	Voorschotten onbelast tussenrekeningen dienstverlening	D	5	\N	t
1798	1	BVorTusTdvVsb	1105660	Voorschotten belast tussenrekeningen dienstverlening	D	5	\N	t
1799	1	BVorTusTdvDvo	1105670	Doorberekende voorschotten onbelast tussenrekeningen dienstverlening	D	5	\N	t
1800	1	BVorTusTdvDvb	1105680	Doorberekende voorschotten belast tussenrekeningen dienstverlening	D	5	\N	t
1801	1	BVorTusTvr	1105700	Tussenrekening voorraden	D	4	\N	t
1802	1	BVorTusTvrTvn	1105710	Tussenrekening voorraadverschillen tussenrekening voorraden	D	5	\N	t
1803	1	BVorTusTvk	1105800	Tussenrekeningen verkopen	D	4	\N	t
1804	1	BVorTusTvkTnf	1105810	Tussenrekening nog te factureren tussenrekeningen verkopen	D	5	\N	t
1805	1	BVorTusTvkTng	1105820	Tussenrekening nog te verzenden goederen tussenrekeningen verkopen	D	5	\N	t
1806	1	BVorTusTvkTve	1105830	Tussenrekening verkoopverschillen tussenrekeningen verkopen	D	5	\N	t
1807	1	BVorTusTon	1105900	Tussenrekeningen ontvangsten	D	4	\N	t
1808	1	BVorTusTonTco	1105910	Tussenrekening contante ontvangsten tussenrekeningen ontvangsten	D	5	\N	t
1809	1	BVorTusTonTcv	1105920	Tussenrekening creditcardverkopen tussenrekeningen ontvangsten	D	5	\N	t
1810	1	BVorTusTov	1106000	Tussenrekeningen overig	D	4	\N	t
1811	1	BVorTusTovTbb	1106010	Tussenrekening beginbalans tussenrekeningen overig	D	5	\N	t
1812	1	BVorTusTovTvp	1106020	Tussenrekening vraagposten tussenrekeningen overig	D	5	\N	t
1813	1	BVorTusTovTov	1106030	Tussenrekening overige tussenrekeningen overig	D	5	\N	t
1814	1	BVorTusLen	1107000	Tussenrekeningen leningen	D	4	\N	t
1815	1	BVorTusLenLog	1107010	Tussenrekening leningen OG	D	5	\N	t
1816	1	BVorTusLenLug	1107020	Tussenrekening leningen UG	D	5	\N	t
1817	1	BVorTusLenKog	1107030	Tussenrekening kasgeld OG	D	5	\N	t
1818	1	BVorTusLenKug	1107040	Tussenrekening kasgeld UG	D	5	\N	t
1819	1	BVorTusLenSde	1107050	Tussenrekening spaardeposito	D	5	\N	t
1820	1	BVorTusLenDer	1107060	Tussenrekening derivaten	D	5	\N	t
1821	1	BVorTusLenCfv	1107070	Tussenrekening leningen CFV	D	5	\N	t
1822	1	BVorOvh	1104105	Overheid	D	3	\N	t
1823	1	BVorOvhVor	1104205	Overheid	D	4	\N	t
1824	1	BEff	04	Effecten (kortlopend)	D	2	\N	t
1825	1	BEffAan	0401000	Aandelen	D	3	\N	t
1826	1	BEffAanAbe	0401010	Aandelen beursgenoteerde effecten	D	4	\N	t
1827	1	BEffAanAbeBeg	0401010.01	Beginbalans aandelen beursgenoteerd	D	5	\N	t
1828	1	BEffAanAbeAan	0401010.02	Aankoop beursgenoteerde effecten	D	5	\N	t
1829	1	BEffAanAbeVrk	0401010.04	Verkoop beursgenoteerde effecten	C	5	\N	t
1830	1	BEffAanAbeWvr	0401010.06	Waardeverminderingen beursgenoteerde effecten	C	5	\N	t
1831	1	BEffAanAbeAsm	0401010.05	Afstempeling beursgenoteerde effecten	C	5	\N	t
1832	1	BEffAanAbeOvm	0401010.07	Overige mutaties beursgenoteerde effecten	D	5	\N	t
1833	1	BEffAanAnb	0401020	Aandelen niet-beursgenoteerde effecten	D	4	\N	t
1834	1	BEffAanAnbBeg	0401020.01	Beginbalans aandelen niet beursgenoteerd	D	5	\N	t
1835	1	BEffAanAnbAan	0401020.02	Aankoop niet-beursgenoteerde effecten	D	5	\N	t
1836	1	BEffAanAnbVrk	0401020.04	Verkoop niet-beursgenoteerde effecten	C	5	\N	t
1837	1	BEffAanAnbWvr	0401020.07	Waardeverminderingen niet-beursgenoteerde effecten	C	5	\N	t
1838	1	BEffAanAnbAsm	0401020.05	Afstempeling niet-beursgenoteerde effecten	C	5	\N	t
1839	1	BEffAanAnbOvm	0401020.06	Overige mutaties niet-beursgenoteerde effecten	D	5	\N	t
1840	1	BEffObl	0402000	Obligaties	D	3	\N	t
1841	1	BEffOblObb	0402010	Obligaties beursgenoteerde effecten	D	4	\N	t
1842	1	BEffOblObbBeg	0402010.01	Beginbalans obligaties beursgenoteerd	D	5	\N	t
1843	1	BEffOblObbAan	0402010.02	Aankoop obligaties beursgenoteerd effecten	D	5	\N	t
1844	1	BEffOblObbVrk	0402010.03	Verkoop obligaties beursgenoteerd effecten	C	5	\N	t
1845	1	BEffOblObbWvr	0402010.05	Waardeverminderingen obligaties beursgenoteerd	C	5	\N	t
1846	1	BEffOblObbUil	0402010.04	Uitloting obligaties beursgenoteerd effecten	C	5	\N	t
1847	1	BEffOblObbAsm	0402010.07	Afstempeling obligaties beursgenoteerd effecten	C	5	\N	t
1848	1	BEffOblObbOvm	0402010.06	Overige mutaties obligaties beursgenoteerd effecten	D	5	\N	t
1849	1	BEffOblOnb	0402020	Obligaties niet-beursgenoteerde effecten	D	4	\N	t
1850	1	BEffOblOnbBeg	0402020.01	Beginbalans obligaties niet beursgenoteerd	D	5	\N	t
1851	1	BEffOblOnbAan	0402020.02	Aankoop obligaties niet-beursgenoteerde effecten	D	5	\N	t
1852	1	BEffOblOnbVrk	0402020.03	Verkoop obligaties niet-beursgenoteerde effecten	C	5	\N	t
1853	1	BEffOblOnbWvr	0402020.05	Waardeverminderingen obligaties niet-beursgenoteerde effecten	C	5	\N	t
1854	1	BEffOblOnbUil	0402020.04	Uitloting obligaties niet-beursgenoteerde effecten	C	5	\N	t
1855	1	BEffOblOnbOvm	0402020.06	Overige mutaties obligaties niet-beursgenoteerde effecten	D	5	\N	t
1856	1	BEffOve	403000	Overige effecten	D	3	\N	t
1857	1	BEffOveOeb	0403010	Overige effecten beursgenoteerde effecten	D	4	\N	t
1858	1	BEffOveOebBeg	0403010.01	Beginbalans overige effecten beursgenoteerd	D	5	\N	t
1859	1	BEffOveOebAan	0403010.02	Aankoop overige effecten beursgenoteerde effecten	D	5	\N	t
1860	1	BEffOveOebVrk	0403010.03	Verkoop overige effecten beursgenoteerde effecten	C	5	\N	t
1861	1	BEffOveOebWvr	0403010.04	Waardeverminderingen overige effecten beursgenoteerde effecten	C	5	\N	t
1862	1	BEffOveOebOvm	0403010.05	Overige mutaties overige effecten beursgenoteerde effecten	D	5	\N	t
1863	1	BEffOveOen	403020	Overige effecten niet-beursgenoteerde effecten	D	4	\N	t
1864	1	BEffOveOenBeg	0403020.01	Beginbalans overige effecten niet beursgenoteerd	D	5	\N	t
1865	1	BEffOveOenAan	0403020.02	Aankoop overige effecten niet-beursgenoteerde effecten	D	5	\N	t
1866	1	BEffOveOenVrk	0403020.03	Verkoop overige effecten niet-beursgenoteerde effecten	C	5	\N	t
1867	1	BEffOveOenWvr	0403020.04	Waardeverminderingen overige effecten niet-beursgenoteerde effecten	C	5	\N	t
1868	1	BEffOveOenOvm	0403020.05	Overige mutaties overige effecten niet-beursgenoteerde effecten	D	5	\N	t
1869	1	BEffOpt	404000	Optierechten	D	3	\N	t
1870	1	BEffOptOpb	404010	Optierechten beursgenoteerde effecten	D	4	\N	t
1871	1	BEffOptOpbAan	0404010.02	Aankoop optierechten beursgenoteerde effecten	D	5	\N	t
1872	1	BEffOptOpbVrk	0404010.03	Verkoop optierechten beursgenoteerde effecten	C	5	\N	t
1873	1	BEffOptOpbWvr	0404010.04	Waardeverminderingen optierechten beursgenoteerde effecten	C	5	\N	t
1874	1	BEffOptOpbOvm	0404010.05	Overige mutaties optierechten beursgenoteerde effecten	D	5	\N	t
1875	1	BEffOptOpn	404020	Optierechten niet-beursgenoteerde effecten	D	4	\N	t
1876	1	BEffOptOpnAan	0404020.02	Aankoop optierechten niet-beursgenoteerde effecten	D	5	\N	t
1877	1	BEffOptOpnVrk	0404020.03	Verkoop optierechten niet-beursgenoteerde effecten	C	5	\N	t
1878	1	BEffOptOpnWvr	0404020.04	Waardeverminderingen optierechten niet-beursgenoteerde effecten	C	5	\N	t
1879	1	BEffOptOpnOvm	0404020.05	Overige mutaties optierechten niet-beursgenoteerde effecten	D	5	\N	t
1880	1	BEffOpv	405000	Optieverplichtingen	D	3	\N	t
1881	1	BEffOpvOpb	405010	Optieverplichtingen beursgenoteerde effecten	D	4	\N	t
1882	1	BEffOpvOpbAan	0405010.02	Aankoop optieverplichtingen beursgenoteerde optieverplichtingen	D	5	\N	t
1883	1	BEffOpvOpbVrk	0405010.03	Verkoop optieverplichtingen beursgenoteerde optieverplichtingen	C	5	\N	t
1884	1	BEffOpvOpbWvr	0405010.04	Waardeverminderingen optieverplichtingen beursgenoteerde optieverplichtingen	C	5	\N	t
1885	1	BEffOpvOpbOvm	0405010.05	Overige mutaties optieverplichtingen beursgenoteerde optieverplichtingen	D	5	\N	t
1886	1	BEffOpvOpn	405020	Optieverplichtingen niet-beursgenoteerde effecten	D	4	\N	t
1887	1	BEffOpvOpnAan	0405020.02	Aankoop optieverplichtingen niet-beursgenoteerde optieverplichtingen	D	5	\N	t
1888	1	BEffOpvOpnVrk	0405020.03	Verkoop optieverplichtingen niet-beursgenoteerde optieverplichtingen	C	5	\N	t
1889	1	BEffOpvOpnWvr	0405020.04	Waardeverminderingen optieverplichtingen niet-beursgenoteerde optieverplichtingen	C	5	\N	t
2169	1	BEivBer	505019	Bestemmingsreserves	C	3	\N	t
1890	1	BEffOpvOpnOvm	0405020.05	Overige mutaties optieverplichtingen niet-beursgenoteerde optieverplichtingen	D	5	\N	t
1891	1	BEffDer	406000	Derivaten	D	3	\N	t
1892	1	BEffDerDer	406010	Derivaten	D	4	\N	t
1893	1	BEffDerDerPmd	0406010.01	Positieve marktwaarde derivaten	D	5	\N	t
1894	1	BEffDerDerPed	0465010.02	Positieve marktwaarde embedded derivaten	D	5	\N	t
1895	1	BLim	10	Liquide middelen	D	2	\N	t
1896	1	BLimKas	1001000	Kasmiddelen	D	3	\N	t
1897	1	BLimKasKas	1001010	Kas kasmiddelen	D	4	\N	t
1898	1	BLimKasKlk	1001020	Kleine kas kasmiddelen	D	4	\N	t
1899	1	BLimBan	1002000	Tegoeden bij banken	D	3	\N	t
1900	1	BLimBanRba	1002010	Rekening-courant bank tegoeden op bankgirorekeningen	D	4	\N	t
1901	1	BLimBanRbaBg1	1002010.01	Rekening-courant bank groep 1	D	5	\N	t
1902	1	BLimBanRbaBg2	1002010.02	Rekening-courant bank groep 2	D	5	\N	t
1903	1	BLimBanRbaBg3	1002010.03	Rekening-courant bank groep 3	D	5	\N	t
1904	1	BLimBanRbaBg4	1002010.04	Rekening-courant bank groep 4	D	5	\N	t
1905	1	BLimBanRbaBg5	1002010.05	Rekening-courant bank groep 5	D	5	\N	t
1906	1	BLimBanRbaBg6	1002010.06	Rekening-courant bank groep 6	D	5	\N	t
1907	1	BLimBanRbaBg7	1002010.07	Rekening-courant bank groep 7	D	5	\N	t
1908	1	BLimBanRbaBg8	1002010.08	Rekening-courant bank groep 8	D	5	\N	t
1909	1	BLimBanRbaBg9	1002010.09	Rekening-courant bank groep 9	D	5	\N	t
1910	1	BLimBanRbaBg10	1002010.10	Rekening-courant bank groep 10	D	5	\N	t
1911	1	BLimBanRbb	1002011	Rekening-courant bank - Naam A - tegoeden op bankgirorekeningen	D	4	\N	t
1912	1	BLimBanRbc	1002012	Rekening-courant bank - Naam B - tegoeden op bankgirorekeningen	D	4	\N	t
1913	1	BLimBanRbd	1002013	Rekening-courant bank - Naam C - tegoeden op bankgirorekeningen	D	4	\N	t
1914	1	BLimBanRbe	1002014	Rekening-courant bank - Naam D - tegoeden op bankgirorekeningen	D	4	\N	t
1915	1	BLimBanRbf	1002015	Rekening-courant bank - Naam E - tegoeden op bankgirorekeningen	D	4	\N	t
1916	1	BLimBanDrk	1002020	Depotrekening tegoeden op bankgirorekeningen	D	4	\N	t
1917	1	BLimBanDep	1002030	Depositorekening tegoeden op bankgirorekeningen	D	4	\N	t
1918	1	BLimBanBel	1002040	Beleggingsrekening tegoeden op bankgirorekeningen	D	4	\N	t
1919	1	BLimBanGrb	1002060	G-rekening tegoeden op bankgirorekeningen	D	4	\N	t
1920	1	BLimBanInb	1002050	Internetrekening tegoeden op bankgirorekeningen	D	4	\N	t
1921	1	BLimBanSpa	1002070	(Bedrijfs)spaarrekening	D	4	\N	t
1922	1	BLimKru	1003000	Kruisposten	D	3	\N	t
1923	1	BLimKruSto	1003010	Stortingen onderweg kruisposten	D	4	\N	t
1924	1	BLimKruKlu	1003015	Tussenrekening kluis	D	4	\N	t
1925	1	BLimKruPib	1003020	PIN betalingen kruisposten	D	4	\N	t
1926	1	BLimKruCra	1003030	Creditcard afrekening kruisposten	D	4	\N	t
1927	1	BLimKruWec	1003040	Wissels en cheques kruisposten	D	4	\N	t
1928	1	BEiv	05	Groepsvermogen - Eigen vermogen - Kapitaal	C	2	\N	t
1929	1	BEivGok	0501000	Aandelenkapitaal	C	3	\N	t
1930	1	BEivGokGea	0501010	Normale aandelen aandelenkapitaal	C	4	\N	t
1931	1	BEivGokGeaBeg	0501010.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
1932	1	BEivGokGeaUit	0501010.02	Uitgifte van aandelen 	C	5	\N	t
1933	1	BEivGokGeaVrk	0501010.06	Verkoop van eigen aandelen 	C	5	\N	t
1934	1	BEivGokGeaInk	0501010.07	Inkoop van eigen aandelen 	D	5	\N	t
1935	1	BEivGokGeaInt	0501010.10	Intrekking van aandelen 	D	5	\N	t
1936	1	BEivGokGeaDiv	0501010.14	Dividenduitkeringen 	C	5	\N	t
1937	1	BEivGokGeaIdi	0501010.28	Interim-dividenduitkeringen	C	5	\N	t
1938	1	BEivGokGeaEmk	0501010.16	Emissiekosten	D	5	\N	t
1939	1	BEivGokGeaOve	0501010.15	Overboekingen 	C	5	\N	t
1940	1	BEivGokGeaOvm	0501010.13	Overige mutaties 	C	5	\N	t
1941	1	BEivGokPra	0501040	Preferente aandelen 	C	4	\N	t
1942	1	BEivGokPraBeg	0501040.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
1943	1	BEivGokPraUit	0501040.02	Uitgifte van aandelen 	C	5	\N	t
1944	1	BEivGokPraVrk	0501040.06	Verkoop van eigen aandelen 	C	5	\N	t
1945	1	BEivGokPraInk	0501040.07	Inkoop van eigen aandelen 	D	5	\N	t
1946	1	BEivGokPraInt	0501040.08	Intrekking van aandelen 	D	5	\N	t
1947	1	BEivGokPraDiv	0501040.14	Dividenduitkeringen 	C	5	\N	t
1948	1	BEivGokPraIdi	0501040.28	Interim-dividenduitkeringen	C	5	\N	t
1949	1	BEivGokPraEmk	0501040.16	Emissiekosten	D	5	\N	t
1950	1	BEivGokPraOve	0501040.15	Overboekingen 	C	5	\N	t
1951	1	BEivGokPraOvm	0501040.11	Overige mutaties preferente aandelen	C	5	\N	t
1952	1	BEivGokPri	501050	Prioriteitsaandelen 	C	4	\N	t
1953	1	BEivGokPriBeg	0501050.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
1954	1	BEivGokPriUit	0501050.02	Uitgifte van aandelen 	C	5	\N	t
1955	1	BEivGokPriVrk	0501050.06	Verkoop van eigen aandelen 	C	5	\N	t
1956	1	BEivGokPriInk	0501050.07	Inkoop van eigen aandelen 	D	5	\N	t
1957	1	BEivGokPriInt	0501050.08	Intrekking van aandelen 	D	5	\N	t
1958	1	BEivGokPriDiv	0501050.14	Dividenduitkeringen 	C	5	\N	t
1959	1	BEivGokPriIdi	0501050.28	Interim-dividenduitkeringen	C	5	\N	t
1960	1	BEivGokPriEmk	0501050.16	Emissiekosten	D	5	\N	t
1961	1	BEivGokPriOve	0501050.15	Overboekingen 	C	5	\N	t
1962	1	BEivGokPriOvm	0501050.11	Overige mutaties 	C	5	\N	t
1963	1	BEivGokCva	501070	Certificaten van aandelen 	C	4	\N	t
1964	1	BEivGokCvaBeg	0501070.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
1965	1	BEivGokCvaUit	0501070.02	Uitgifte van aandelen 	C	5	\N	t
1966	1	BEivGokCvaVrk	0501070.06	Verkoop van eigen aandelen 	C	5	\N	t
1967	1	BEivGokCvaInk	0501070.07	Inkoop van eigen aandelen 	D	5	\N	t
1968	1	BEivGokCvaInt	0501070.08	Intrekking van aandelen 	D	5	\N	t
1969	1	BEivGokCvaDiv	0501070.14	Dividenduitkeringen 	C	5	\N	t
1970	1	BEivGokCvaIdi	0501070.28	Interim-dividenduitkeringen	C	5	\N	t
1971	1	BEivGokCvaEmk	0501070.16	Emissiekosten	D	5	\N	t
1972	1	BEivGokCvaOve	0501070.15	Overboekingen 	C	5	\N	t
1973	1	BEivGokCvaOvm	0501070.11	Overige mutaties 	C	5	\N	t
1974	1	BEivGokZea	0501030	Stemrechtloze aandelen 	C	4	\N	t
1975	1	BEivGokZeaBeg	0501030.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
1976	1	BEivGokZeaUit	0501030.02	Uitgifte van aandelen 	C	5	\N	t
1977	1	BEivGokZeaVrk	0501030.06	Verkoop van eigen aandelen 	C	5	\N	t
1978	1	BEivGokZeaInk	0501030.07	Inkoop van eigen aandelen 	D	5	\N	t
1979	1	BEivGokZeaInt	0501030.08	Intrekking van aandelen 	D	5	\N	t
1980	1	BEivGokZeaDiv	0501030.14	Dividenduitkeringen 	C	5	\N	t
1981	1	BEivGokZeaIdi	0501030.28	Interim-dividenduitkeringen	C	5	\N	t
1982	1	BEivGokZeaEmk	0501030.16	Emissiekosten	D	5	\N	t
1983	1	BEivGokZeaOve	0501030.15	Overboekingen 	C	5	\N	t
1984	1	BEivGokZeaOvm	0501030.11	Overige mutaties 	C	5	\N	t
1985	1	BEivGokWia	0501020	Winstrechtloze aandelen 	C	4	\N	t
1986	1	BEivGokWiaBeg	0501020.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
1987	1	BEivGokWiaUit	0501020.02	Uitgifte van aandelen 	C	5	\N	t
1988	1	BEivGokWiaVrk	0501020.06	Verkoop van eigen aandelen 	C	5	\N	t
1989	1	BEivGokWiaInk	0501020.07	Inkoop van eigen aandelen 	D	5	\N	t
1990	1	BEivGokWiaInt	0501020.08	Intrekking van aandelen 	D	5	\N	t
1991	1	BEivGokWiaDiv	0501020.14	Dividenduitkeringen 	C	5	\N	t
1992	1	BEivGokWiaIdi	0501020.28	Interim-dividenduitkeringen	C	5	\N	t
1993	1	BEivGokWiaEmk	0501020.16	Emissiekosten	D	5	\N	t
1994	1	BEivGokWiaOve	0501020.15	Overboekingen 	C	5	\N	t
1995	1	BEivGokWiaOvm	0501020.11	Overige mutaties 	C	5	\N	t
1996	1	BEivGokEia	501080	Eigen aandelen 	C	4	\N	t
1997	1	BEivGokEiaBeg	0501080.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
1998	1	BEivGokEiaUit	0501080.02	Uitgifte van aandelen 	C	5	\N	t
1999	1	BEivGokEiaVrk	0501080.06	Verkoop van eigen aandelen 	C	5	\N	t
2000	1	BEivGokEiaInk	0501080.07	Inkoop van eigen aandelen 	D	5	\N	t
2001	1	BEivGokEiaInt	0501080.08	Intrekking van aandelen 	D	5	\N	t
2002	1	BEivGokEiaDiv	0501080.14	Dividenduitkeringen 	C	5	\N	t
2003	1	BEivGokEiaIdi	0501080.28	Interim-dividenduitkeringen	C	5	\N	t
2004	1	BEivGokEiaEmk	0501080.16	Emissiekosten	D	5	\N	t
2005	1	BEivGokEiaOve	0501080.15	Overboekingen 	C	5	\N	t
2006	1	BEivGokEiaOvm	0501080.11	Overige mutaties 	C	5	\N	t
2007	1	BEivSev	509049	Kapitaal	C	3	\N	t
2008	1	BEivSevSti	509050	Stichtingskapitaal eigen vermogen	C	4	\N	t
2009	1	BEivSevStiBeg	0509050.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen	C	5	\N	t
2010	1	BEivSevStiKap	0509050.02	Kapitaalmutaties eigen vermogen	C	5	\N	t
2011	1	BEivSevStiKac	0509050.03	Kapitaalcorrecties eigen vermogen	D	5	\N	t
2012	1	BEivSevStiOvm	0509050.04	Overige mutaties eigen vermogen	C	5	\N	t
2013	1	BEivSevVnk	0509060	Verenigingskapitaal eigen vermogen	C	4	\N	t
2014	1	BEivSevVnkBeg	0509060.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen	C	5	\N	t
2015	1	BEivSevVnkKap	0509060.02	Kapitaalmutaties eigen vermogen	C	5	\N	t
2016	1	BEivSevVnkKac	0509060.03	Kapitaalcorrecties eigen vermogen	D	5	\N	t
2017	1	BEivSevVnkOvm	0509060.04	Overige mutaties eigen vermogen	C	5	\N	t
2018	1	BEivSevCoo	509065	Kapitaal participatie coöperatie eigen vermogen	C	4	\N	t
2019	1	BEivSevCooBeg	0509065.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen participatie	C	5	\N	t
2020	1	BEivSevCooKap	0509065.02	Kapitaalmutaties eigen vermogen participatie	C	5	\N	t
2021	1	BEivSevCooKac	0509065.03	Kapitaalcorrecties eigen vermogen participatie	D	5	\N	t
2022	1	BEivSevCooOvm	0509065.04	Overige mutaties eigen vermogen participatie	C	5	\N	t
2023	1	BEivCok	509069	Commanditair kapitaal	C	3	\N	t
2024	1	BEivCokCok	0509070	Commanditair kapitaal eigen vermogen	C	4	\N	t
2025	1	BEivCokCokBeg	0509070.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen	C	5	\N	t
2026	1	BEivCokCokKap	0509070.02	Kapitaalmutaties eigen vermogen	C	5	\N	t
2027	1	BEivCokCokKac	0509070.03	Kapitaalcorrecties eigen vermogen	D	5	\N	t
2028	1	BEivCokCokOvm	0509070.04	Overige mutaties eigen vermogen	C	5	\N	t
2029	1	BEivAgi	0502000	Agio	C	3	\N	t
2030	1	BEivAgiAgi	0502010	Agioreserve agio	C	4	\N	t
2031	1	BEivAgiAgiBeg	0502010.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2032	1	BEivAgiAgiSta	0502010.06	Stortingen door aandeelhouders 	C	5	\N	t
2033	1	BEivAgiAgiAvv	0502010.07	Aanzuivering van verliezen 	C	5	\N	t
2034	1	BEivAgiAgiVve	0502010.08	Verkoop van eigen aandelen 	C	5	\N	t
2035	1	BEivAgiAgiIve	0502010.09	Inkoop van eigen aandelen 	D	5	\N	t
2036	1	BEivAgiAgiIva	0502010.10	Intrekking van aandelen 	D	5	\N	t
2037	1	BEivAgiAgiOve	0502010.11	Overboekingen 	C	5	\N	t
2038	1	BEivAgiAgiRfh	0502010.12	Rechtstreekse mutatie als gevolg van foutherstel 	C	5	\N	t
2039	1	BEivAgiAgiRov	0502010.13	Rechtstreekse mutatie als gevolg van overnames 	C	5	\N	t
2040	1	BEivAgiAgiRaf	0502010.14	Rechtstreekse mutatie als gevolg van afstotingen 	D	5	\N	t
2041	1	BEivAgiAgiOvm	0502010.15	Overige mutaties 	C	5	\N	t
2042	1	BEivHer	0503000	Herwaarderingsreserves	C	3	\N	t
2043	1	BEivHerHew	0503010	Herwaardering herwaarderingsreserves	C	4	\N	t
2044	1	BEivHerHewBeg	0503010.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2045	1	BEivHerHewOhe	0503010.16	Herwaarderingsreserve ongegerealiseerde herwaardering	C	5	\N	t
2046	1	BEivHerHewSte	0503010.03	Stelselwijziging (correctie beginbalans)	C	5	\N	t
2047	1	BEivHerHewBvs	0503010.10	Belastingeffect van stelselwijzigingen (correctie beginbalans)	C	5	\N	t
2048	1	BEivHerHewGhw	0503010.07	Gerealiseerde herwaarderingen via winst- en verliesrekening 	D	5	\N	t
2049	1	BEivHerHewGhr	0503010.04	Gerealiseerde herwaarderingen via overige reserves 	D	5	\N	t
2050	1	BEivHerHewGha	0503010.05	Gerealiseerde herwaarderingen via afgedekte activa of passiva 	D	5	\N	t
2051	1	BEivHerHewBrh	0503010.06	Belastingeffecten op gerealiseerde herwaarderingen 	D	5	\N	t
2052	1	BEivHerHewGvw	0503010.11	Gevormde herwaarderingen via winst- en verliesrekening 	C	5	\N	t
2053	1	BEivHerHewGvr	0503010.08	Gevormde herwaarderingen via overige reserves 	C	5	\N	t
2054	1	BEivHerHewGva	0503010.09	Gevormde herwaarderingen via afgedekt activa of passiva 	C	5	\N	t
2055	1	BEivHerHewBvh	0503010.12	Belastingeffecten op gevormde herwaarderingen 	D	5	\N	t
2056	1	BEivHerHewOve	0503010.15	Overboekingen 	C	5	\N	t
2057	1	BEivHerHewHer	0503010.02	Herwaarderingen 	C	5	\N	t
2058	1	BEivHerHewVrh	0503010.13	Vrijval herwaardering herwaarderingsreserve	D	5	\N	t
2059	1	BEivHerHewOvm	0503010.14	Overige mutaties 	C	5	\N	t
2060	1	BEivWer	0504000	Wettelijke reserves	C	3	\N	t
2061	1	BEivWerNba	0504010	Negatieve bijschrijvingsreserve als gevolg van de omrekening van het aandelenkapitaal van een naamloze vennootschap naar de euro wettelijke reserves	C	4	\N	t
2062	1	BEivWerNbaBeg	0504010.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2063	1	BEivWerNbaOve	0504010.05	Overboekingen 	C	5	\N	t
2064	1	BEivWerNbaOvm	0504010.04	Overige mutaties 	C	5	\N	t
2065	1	BEivWerRla	0504020	Niet-uitkeerbare reserve als gevolg van de omrekening van het aandelenkapitaal van een naamloze vennootschap naar de euro	C	4	\N	t
2066	1	BEivWerRlaBeg	0504020.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2068	1	BEivWerRlaOvm	0504020.04	Overige mutaties 	C	5	\N	t
2069	1	BEivWerRvi	0504030	Wettelijke reserve voor inbreng in natura 	C	4	\N	t
2070	1	BEivWerRviBeg	0504030.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2071	1	BEivWerRviSta	0504030.06	Stortingen door aandeelhouders 	C	5	\N	t
2072	1	BEivWerRviAvv	0504030.07	Aanzuivering van verliezen 	C	5	\N	t
2073	1	BEivWerRviOve	0504030.11	Overboekingen 	C	5	\N	t
2074	1	BEivWerRviOvm	0504030.04	Overige mutaties 	C	5	\N	t
2075	1	BEivWerRvl	0504040	Wettelijke reserve voor financiering van transacties in eigen aandelen 	C	4	\N	t
2076	1	BEivWerRvlBeg	0504040.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2077	1	BEivWerRvlUva	0504040.05	Uitgifte van aandelen 	C	5	\N	t
2078	1	BEivWerRvlSta	0504040.06	Stortingen door aandeelhouders 	C	5	\N	t
2079	1	BEivWerRvlAvv	0504040.07	Aanzuivering van verliezen 	C	5	\N	t
2080	1	BEivWerRvlVve	0504040.08	Verkoop van eigen aandelen 	C	5	\N	t
2081	1	BEivWerRvlIve	0504040.09	Inkoop van eigen aandelen 	D	5	\N	t
2082	1	BEivWerRvlIva	0504040.10	Intrekking van aandelen 	D	5	\N	t
2083	1	BEivWerRvlDiv	0504040.23	Dividenduitkeringen 	D	5	\N	t
2084	1	BEivWerRvlIdi	0504040.28	Interim-dividenduitkeringen	D	5	\N	t
2085	1	BEivWerRvlOve	0504040.11	Overboekingen 	C	5	\N	t
2086	1	BEivWerRvlUia	0504040.22	Uitgeoefende aandelen(optie)regelingen 	C	5	\N	t
2087	1	BEivWerRvlOvm	0504040.04	Overige mutaties 	C	5	\N	t
2088	1	BEivWerRvg	0504050	Wettelijke reserve voor geactiveerde kosten van oprichting en uitgifte van aandelen 	C	4	\N	t
2089	1	BEivWerRvgBeg	0504050.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2090	1	BEivWerRvgUva	0504050.05	Uitgifte van aandelen 	C	5	\N	t
2091	1	BEivWerRvgSta	0504050.06	Stortingen door aandeelhouders 	C	5	\N	t
2092	1	BEivWerRvgAvv	0504050.07	Aanzuivering van verliezen 	C	5	\N	t
2093	1	BEivWerRvgVve	0504050.08	Verkoop van eigen aandelen 	C	5	\N	t
2094	1	BEivWerRvgIve	0504050.09	Inkoop van eigen aandelen 	D	5	\N	t
2095	1	BEivWerRvgIva	0504050.10	Intrekking van aandelen 	D	5	\N	t
2096	1	BEivWerRvgOve	0504050.11	Overboekingen 	C	5	\N	t
2097	1	BEivWerRvgHer	0504050.12	Herwaarderingen 	C	5	\N	t
2098	1	BEivWerRvgRsw	0504050.13	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	C	5	\N	t
2099	1	BEivWerRvgRfh	0504050.14	Rechtstreekse mutatie als gevolg van foutherstel 	C	5	\N	t
2100	1	BEivWerRvgRom	0504050.15	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	C	5	\N	t
2101	1	BEivWerRvgRbw	0504050.16	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	D	5	\N	t
2102	1	BEivWerRvgRtw	0504050.17	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	C	5	\N	t
2103	1	BEivWerRvgRov	0504050.18	Rechtstreekse mutatie als gevolg van overnames 	C	5	\N	t
2104	1	BEivWerRvgRaf	0504050.19	Rechtstreekse mutatie als gevolg van afstotingen 	D	5	\N	t
2105	1	BEivWerRvgRfi	0504050.20	Rechtstreekse mutatie als gevolg van financiële instrumenten 	C	5	\N	t
2106	1	BEivWerRvgVar	0504050.21	Verleende aandelen(optie) regelingen 	C	5	\N	t
2107	1	BEivWerRvgUia	0504050.22	Uitgeoefende aandelen(optie)regelingen 	C	5	\N	t
2108	1	BEivWerRvgOvm	0504050.04	Overige mutaties reserve voor geactiveerde kosten van oprichting en uitgifte van aandelen	C	5	\N	t
2109	1	BEivWerRgk	0504060	Wettelijke reserve voor geactiveerde kosten van ontwikkeling 	C	4	\N	t
2110	1	BEivWerRgkBeg	0504060.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2111	1	BEivWerRgkOve	0504060.11	Overboekingen 	C	5	\N	t
2112	1	BEivWerRgkHer	0504060.12	Herwaarderingen 	C	5	\N	t
2113	1	BEivWerRgkRsw	0504060.13	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	C	5	\N	t
2114	1	BEivWerRgkRfh	0504060.14	Rechtstreekse mutatie als gevolg van foutherstel 	C	5	\N	t
2115	1	BEivWerRgkRom	0504060.15	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	C	5	\N	t
2116	1	BEivWerRgkRbw	0504060.16	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	D	5	\N	t
2117	1	BEivWerRgkRtw	0504060.17	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	C	5	\N	t
2118	1	BEivWerRgkRov	0504060.18	Rechtstreekse mutatie als gevolg van overnames 	C	5	\N	t
2119	1	BEivWerRgkRaf	0504060.19	Rechtstreekse mutatie als gevolg van afstotingen 	D	5	\N	t
2120	1	BEivWerRgkRfi	0504060.20	Rechtstreekse mutatie als gevolg van financiële instrumenten 	C	5	\N	t
2121	1	BEivWerRgkOvm	0504060.04	Overige mutaties reserve voor geactiveerde kosten van onderzoek en ontwikkeling	C	5	\N	t
2122	1	BEivWerRed	0504070	Wettelijke reserve deelnemingen	C	4	\N	t
2123	1	BEivWerRedBeg	0504070.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2124	1	BEivWerRedDot	0504070.02	Dotatie reserve deelnemingen	C	5	\N	t
2125	1	BEivWerRedOnt	0504070.03	Onttrekking reserve deelnemingen	D	5	\N	t
2126	1	BEivWerRedDiv	0504070.23	Dividenduitkeringen 	D	5	\N	t
2127	1	BEivWerRedIdi	0504070.28	Interim-dividenduitkeringen	D	5	\N	t
2128	1	BEivWerRedOve	0504070.11	Overboekingen 	C	5	\N	t
2129	1	BEivWerRedHer	0504070.12	Herwaarderingen 	C	5	\N	t
2130	1	BEivWerRedRsw	0504070.13	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	C	5	\N	t
2131	1	BEivWerRedRfh	0504070.14	Rechtstreekse mutatie als gevolg van foutherstel 	C	5	\N	t
2132	1	BEivWerRedRom	0504070.15	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	C	5	\N	t
2133	1	BEivWerRedRbw	0504070.16	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	D	5	\N	t
2134	1	BEivWerRedRtw	0504070.17	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	C	5	\N	t
2135	1	BEivWerRedRov	0504070.18	Rechtstreekse mutatie als gevolg van overnames 	C	5	\N	t
2136	1	BEivWerRedRaf	0504070.19	Rechtstreekse mutatie als gevolg van afstotingen 	D	5	\N	t
2137	1	BEivWerRedRfi	0504070.20	Rechtstreekse mutatie als gevolg van financiële instrumenten 	C	5	\N	t
2138	1	BEivWerRedOvm	0504070.04	Overige mutaties reserve deelnemingen	C	5	\N	t
2139	1	BEivWerRvo	0504080	Wettelijke reserve omrekeningsverschillen voor omrekening van het geïnvesteerde vermogen en het resultaat van deelnemingen	C	4	\N	t
2140	1	BEivWerRvoBeg	0504080.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2141	1	BEivWerRvoDot	0504080.02	Dotatie reserve voor omrekeningsverschillen	C	5	\N	t
2142	1	BEivWerRvoOnt	0504080.03	Onttrekking reserve voor omrekeningsverschillen	D	5	\N	t
2143	1	BEivWerRvoRom	0504080.15	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	C	5	\N	t
2144	1	BEivWerRvoOvm	0504080.04	Overige mutaties 	C	5	\N	t
2145	1	BEivWerKoe	504090	Reserve omrekeningsverschillen	C	4	\N	t
2146	1	BEivWerKoeBeg	0504090.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2147	1	BEivWerKoeHer	0504090.12	Herwaarderingen 	C	5	\N	t
2148	1	BEivWerKoeRsw	0504090.13	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	C	5	\N	t
2149	1	BEivWerKoeRfh	0504090.14	Rechtstreekse mutatie als gevolg van foutherstel 	C	5	\N	t
2150	1	BEivWerKoeRom	0504090.15	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	C	5	\N	t
2151	1	BEivWerKoeRbw	0504090.16	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	D	5	\N	t
2152	1	BEivWerKoeRtw	0504090.17	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	C	5	\N	t
2153	1	BEivWerKoeOvm	0504090.04	Overige mutaties 	C	5	\N	t
2154	1	BEivStr	0505000	Statutaire reserves	C	3	\N	t
2155	1	BEivStrStr	0505030	Statutaire reserve statutaire reserves	C	4	\N	t
2156	1	BEivStrStrBeg	0505030.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2157	1	BEivStrStrAvv	0505030.05	Aanzuivering van verliezen 	C	5	\N	t
2158	1	BEivStrStrDiv	0505030.06	Dividenduitkeringen 	D	5	\N	t
2159	1	BEivStrStrIdi	0505030.28	Interim-dividenduitkeringen	D	5	\N	t
2160	1	BEivStrStrOve	0505030.07	Overboekingen 	C	5	\N	t
2161	1	BEivStrStrAvh	0505030.08	Allocatie van het resultaat 	C	5	\N	t
2162	1	BEivStrStrRfh	0505030.09	Rechtstreekse mutatie als gevolg van foutherstel 	C	5	\N	t
2163	1	BEivStrStrOvm	0505030.04	Overige mutaties statutaire reserve	C	5	\N	t
2164	1	BEivBef	507000	Bestemmingsfondsen	C	3	\N	t
2165	1	BEivBefBef	507020	Bestemmingsfondsen bestemmingsfondsen	C	4	\N	t
2166	1	BEivBefBefBeg	0507020.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2167	1	BEivBefBefDot	0507020.02	Toevoegingen aan het bestemmingsfonds 	C	5	\N	t
2168	1	BEivBefBefOnt	0507020.03	Onttrekkingen aan het bestemmingsfonds 	D	5	\N	t
2170	1	BEivBerBer	0505020	Bestemmingsreserve bestemmingsreserves	C	4	\N	t
2171	1	BEivBerBerBeg	0505020.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2172	1	BEivBerBerTad	0505020.02	Toevoegingen aan de bestemmingsreserve 	C	5	\N	t
2173	1	BEivBerBerOad	0505020.03	Onttrekkingen aan de bestemmingsreserve 	D	5	\N	t
2174	1	BEivFij	507100	Financiële instrumenten op basis van juridische vorm geclassificeerd als eigen vermogen	C	3	\N	t
2175	1	BEivFijFij	507110	Financiële instrumenten op basis van juridische vorm geclassificeerd als eigen vermogen	C	4	\N	t
2176	1	BEivFijFijBeg	0507110.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2177	1	BEivFijFijOve	0507110.07	Overboekingen 	C	5	\N	t
2178	1	BEivFijFijOvm	0507110.04	Overige mutaties statutaire reserve	C	5	\N	t
2179	1	BEivOvr	506000	Overige reserves	C	3	\N	t
2180	1	BEivOvrAlr	506001	Algemene reserve 	C	4	\N	t
2181	1	BEivOvrAlrBeg	0506001.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2182	1	BEivOvrAlrSlw	0506001.26	Stelselwijziging (correctie beginbalans)	C	5	\N	t
2183	1	BEivOvrAlrUva	0506001.05	Uitgifte van aandelen 	C	5	\N	t
2184	1	BEivOvrAlrSta	0506001.06	Stortingen door aandeelhouders 	C	5	\N	t
2185	1	BEivOvrAlrAvv	0506001.07	Aanzuivering van verliezen 	C	5	\N	t
2186	1	BEivOvrAlrVve	0506001.08	Verkoop van eigen aandelen 	C	5	\N	t
2187	1	BEivOvrAlrIve	0506001.09	Inkoop van eigen aandelen 	D	5	\N	t
2188	1	BEivOvrAlrIva	0506001.10	Intrekking van aandelen 	D	5	\N	t
2189	1	BEivOvrAlrDiv	0506001.25	Dividenduitkeringen 	D	5	\N	t
2190	1	BEivOvrAlrIdi	0506001.28	Interim-dividenduitkeringen 	D	5	\N	t
2191	1	BEivOvrAlrEmk	0506001.27	Emissiekosten	D	5	\N	t
2192	1	BEivOvrAlrOve	0506001.11	Overboekingen 	C	5	\N	t
2193	1	BEivOvrAlrAvh	0506001.03	Allocatie van het resultaat 	C	5	\N	t
2194	1	BEivOvrAlrHer	0506001.12	Herwaarderingen 	C	5	\N	t
2195	1	BEivOvrAlrRsw	0506001.13	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	C	5	\N	t
2196	1	BEivOvrAlrRtw	0506001.14	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	C	5	\N	t
2197	1	BEivOvrAlrRfh	0506001.15	Rechtstreekse mutatie als gevolg van foutherstel 	C	5	\N	t
2198	1	BEivOvrAlrRom	0506001.16	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	C	5	\N	t
2199	1	BEivOvrAlrRbw	0506001.17	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	D	5	\N	t
2200	1	BEivOvrAlrRgo	0506001.18	Rechtstreekse mutatie als gevolg van goodwill 	C	5	\N	t
2201	1	BEivOvrAlrRov	0506001.19	Rechtstreekse mutatie als gevolg van overnames 	C	5	\N	t
2202	1	BEivOvrAlrRaf	0506001.20	Rechtstreekse mutatie als gevolg van afstotingen 	D	5	\N	t
2203	1	BEivOvrAlrRfi	0506001.21	Rechtstreekse mutatie als gevolg van financiële instrumenten 	C	5	\N	t
2204	1	BEivOvrAlrVar	0506001.22	Verleende aandelen(optie) regelingen 	C	5	\N	t
2205	1	BEivOvrAlrUia	0506001.23	Uitgeoefende aandelen(optie)regelingen 	C	5	\N	t
2206	1	BEivOvrAlrOvm	0506001.24	Overige mutaties 	C	5	\N	t
2207	1	BEivOvrOrs	506005	Overige reserves 	C	4	\N	t
2208	1	BEivOvrOrsBeg	0506005.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2209	1	BEivOvrOrsSlw	0506005.26	Stelselwijziging (correctie beginbalans)	C	5	\N	t
2210	1	BEivOvrOrsUva	0506005.05	Uitgifte van aandelen 	C	5	\N	t
2211	1	BEivOvrOrsSta	0506005.06	Stortingen door aandeelhouders 	C	5	\N	t
2212	1	BEivOvrOrsAvv	0506005.07	Aanzuivering van verliezen 	C	5	\N	t
2213	1	BEivOvrOrsVve	0506005.08	Verkoop van eigen aandelen 	C	5	\N	t
2214	1	BEivOvrOrsIve	0506005.09	Inkoop van eigen aandelen 	D	5	\N	t
2215	1	BEivOvrOrsIva	0506005.10	Intrekking van aandelen 	D	5	\N	t
2216	1	BEivOvrOrsDiv	0506005.25	Dividenduitkeringen 	D	5	\N	t
2217	1	BEivOvrOrsIdi	0506005.28	Interim-dividenduitkeringen 	D	5	\N	t
2218	1	BEivOvrOrsEmk	0506005.27	Emissiekosten	D	5	\N	t
2219	1	BEivOvrOrsOve	0506005.11	Overboekingen 	C	5	\N	t
2220	1	BEivOvrOrsAvh	0506005.03	Allocatie van het resultaat 	C	5	\N	t
2221	1	BEivOvrOrsHer	0506005.12	Herwaarderingen 	C	5	\N	t
2222	1	BEivOvrOrsRsw	0506005.13	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	C	5	\N	t
2223	1	BEivOvrOrsRtw	0506005.14	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	C	5	\N	t
2224	1	BEivOvrOrsRfh	0506005.15	Rechtstreekse mutatie als gevolg van foutherstel 	D	5	\N	t
2225	1	BEivOvrOrsRom	0506005.16	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	C	5	\N	t
2226	1	BEivOvrOrsRbw	0506005.17	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	D	5	\N	t
2227	1	BEivOvrOrsRgo	0506005.18	Rechtstreekse mutatie als gevolg van goodwill 	C	5	\N	t
2228	1	BEivOvrOrsRov	0506005.19	Rechtstreekse mutatie als gevolg van overnames 	C	5	\N	t
2229	1	BEivOvrOrsRaf	0506005.20	Rechtstreekse mutatie als gevolg van afstotingen 	D	5	\N	t
2230	1	BEivOvrOrsRfi	0506005.21	Rechtstreekse mutatie als gevolg van financiële instrumenten 	C	5	\N	t
2231	1	BEivOvrOrsVar	0506005.22	Verleende aandelen(optie) regelingen 	C	5	\N	t
2232	1	BEivOvrOrsUia	0506005.23	Uitgeoefende aandelen(optie)regelingen 	C	5	\N	t
2233	1	BEivOvrOrsOvm	0506005.24	Overige mutaties 	C	5	\N	t
2234	1	BEivOvrCor	506006	Continuïteitsreserve	C	4	\N	t
2235	1	BEivOvrCorBeg	0506006.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2236	1	BEivOvrCorToe	0506006.02	Toevoegingen aan reserves en fondsen	C	5	\N	t
2237	1	BEivOvrCorOnt	0506006.03	Onttrekkingen uit reserves en fondsen	D	5	\N	t
2238	1	BEivOvrCorVrv	0506006.04	Vrijval van reserves en fondsen	D	5	\N	t
2239	1	BEivOvrCorOve	0506006.05	Overboekingen van reserves en fondsen	C	5	\N	t
2240	1	BEivOvrCorHer	0506006.06	Herwaarderingen 	C	5	\N	t
2241	1	BEivOvrCorRsw	0506006.07	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	C	5	\N	t
2242	1	BEivOvrCorRtw	0506006.08	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	C	5	\N	t
2243	1	BEivOvrCorRfh	0506006.09	Rechtstreekse mutatie als gevolg van foutherstel 	C	5	\N	t
2244	1	BEivOvrCorRom	0506006.10	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	C	5	\N	t
2245	1	BEivOvrCorRbw	0506006.11	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	D	5	\N	t
2246	1	BEivOvrCorRfi	0506006.12	Rechtstreekse mutatie als gevolg van financiële instrumenten 	C	5	\N	t
2247	1	BEivOvrCorOvm	0506006.13	Overige mutaties 	C	5	\N	t
2248	1	BEivOre	506009	Onverdeelde winst	C	3	\N	t
2249	1	BEivOreOvw	0506010	Niet verdeelde winst onverdeelde winst	C	4	\N	t
2250	1	BEivOreOvwBeg	0506010.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2251	1	BEivOreOvwSlw	0506010.26	Stelselwijziging (correctie beginbalans)	C	5	\N	t
2252	1	BEivOreOvwDiv	0506010.02	Dividenduitkeringen 	D	5	\N	t
2253	1	BEivOreOvwIdi	0506010.28	Interim-dividenduitkeringen	D	5	\N	t
2254	1	BEivOreOvwOve	0506010.03	Overboekingen 	C	5	\N	t
2255	1	BEivOreOvwAll	0506010.04	Allocatie van het resultaat 	C	5	\N	t
2256	1	BEivOreOvwHer	0506010.25	Herwaarderingen 	C	5	\N	t
2257	1	BEivOreOvwRms	0506010.05	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	C	5	\N	t
2258	1	BEivOreOvwRmt	0506010.09	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	C	5	\N	t
2259	1	BEivOreOvwRmf	0506010.06	Rechtstreekse mutatie als gevolg van foutherstel 	D	5	\N	t
2260	1	BEivOreOvwRmv	0506010.07	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	C	5	\N	t
2261	1	BEivOreOvwRmw	0506010.08	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	D	5	\N	t
2262	1	BEivOreOvwRmg	0506010.10	Rechtstreekse mutatie als gevolg van goodwill 	C	5	\N	t
2263	1	BEivOreOvwRmo	0506010.11	Rechtstreekse mutatie als gevolg van overnames 	C	5	\N	t
2264	1	BEivOreOvwRma	0506010.12	Rechtstreekse mutatie als gevolg van afstotingen 	D	5	\N	t
2265	1	BEivOreOvwRmd	0506010.13	Rechtstreekse mutatie als gevolg van financiële instrumenten 	C	5	\N	t
2266	1	BEivOreOvwOvm	0506010.14	Overige mutaties 	C	5	\N	t
2267	1	BEivOreRvh	0506020	Resultaat van het boekjaar 	C	4	\N	t
2268	1	BEivOreRvhBeg	0506020.01	Beginbalans resultaat van het boekjaar	C	5	\N	t
2269	1	BEivOreRvhDiv	0506020.02	Dividenduitkeringen 	D	5	\N	t
2270	1	BEivOreRvhIdi	0506020.28	Interim-dividenduitkeringen	D	5	\N	t
2271	1	BEivOreRvhOve	0506020.03	Overboekingen 	C	5	\N	t
2272	1	BEivOreRvhAll	0506020.04	Allocatie van het resultaat 	C	5	\N	t
2273	1	BEivOreRvhHer	0506020.25	Herwaarderingen 	C	5	\N	t
2274	1	BEivOreRvhRms	0506020.05	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	C	5	\N	t
2275	1	BEivOreRvhRmt	0506020.09	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	C	5	\N	t
2276	1	BEivOreRvhRmf	0506020.06	Rechtstreekse mutatie als gevolg van foutherstel 	D	5	\N	t
2277	1	BEivOreRvhRmv	0506020.07	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	C	5	\N	t
2278	1	BEivOreRvhRmw	0506020.08	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	D	5	\N	t
2279	1	BEivOreRvhRmg	0506020.10	Rechtstreekse mutatie als gevolg van goodwill 	C	5	\N	t
2280	1	BEivOreRvhRmo	0506020.11	Rechtstreekse mutatie als gevolg van overnames 	C	5	\N	t
2281	1	BEivOreRvhRma	0506020.12	Rechtstreekse mutatie als gevolg van afstotingen 	D	5	\N	t
2282	1	BEivOreRvhRmd	0506020.13	Rechtstreekse mutatie als gevolg van financiële instrumenten 	C	5	\N	t
2283	1	BEivOreRvhOvm	0506020.14	Overige mutaties 	C	5	\N	t
2284	1	BEivOreVde	506030	Voorgestelde bedrag aan dividenduitkeringen aan houders van eigenvermogensinstrumenten (geclassificeerd als eigen vermogen)	C	4	\N	t
2285	1	BEivOreVdeBeg	0506030.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2286	1	BEivOreVdeDiv	0506030.02	Dividenduitkeringen 	D	5	\N	t
2287	1	BEivOreVdeIdi	0506030.28	Interim-dividenduitkeringen	D	5	\N	t
2288	1	BEivOreVdeOve	0506030.03	Overboekingen 	C	5	\N	t
2289	1	BEivOreVdeAll	0506030.04	Allocatie van het resultaat 	C	5	\N	t
2290	1	BEivOreVdeOvm	0506030.14	Overige mutaties 	C	5	\N	t
2291	1	BEivOreUpd	506040	Uit te keren preferent dividend die in mindering wordt gebracht op het resultaat na belastingen	C	4	\N	t
2292	1	BEivOreUpdBeg	0506040.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2293	1	BEivOreUpdDiv	0506040.02	Dividenduitkeringen 	D	5	\N	t
2294	1	BEivOreUpdIdi	0506040.28	Interim-dividenduitkeringen	D	5	\N	t
2295	1	BEivOreUpdOve	0506040.03	Overboekingen 	C	5	\N	t
2296	1	BEivOreUpdAll	0506040.04	Allocatie van het resultaat 	C	5	\N	t
2297	1	BEivOreUpdOvm	0506040.14	Overige mutaties 	C	5	\N	t
2298	1	BEivKap	509000	Eigen vermogen onderneming natuurlijke personen	C	3	\N	t
2299	1	BEivKapOnd	0509010	Ondernemingsvermogen exclusief fiscale reserves fiscaal eigen vermogen onderneming natuurlijke personen	C	4	\N	t
2300	1	BEivKapOndBeg	0509010.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	C	5	\N	t
3178	1	BSchCreKcr	1203040	Kostencrediteuren	C	4	\N	t
2301	1	BEivKapOndRgv	0509020.02	Rente geïnvesteerd vermogen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2302	1	BEivKapOndArb	0509020.03	Arbeidsvergoeding  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2303	1	BEivKapOndVbv	0509020.04	Vergoeding buitenvennootschappelijk vermogen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2304	1	BEivKapOndAow	0509020.05	Aandeel in de overwinst eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2305	1	BEivKapOndOvm	0509020.06	Overige mutaties eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2306	1	BEivKapPrs	0509030	Privé-stortingen	C	4	\N	t
2307	1	BEivKapPrsPsk	0509030.02	Privé-storting kapitaal  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2308	1	BEivKapPrsOns	0509030.03	Ontvangen schenkingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2309	1	BEivKapPrsOlp	0509030.04	Ontvangen loon, uitkeringen of pensioenen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2310	1	BEivKapPrsOte	0509030.05	Ontvangen toeslagen en toelagen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2311	1	BEivKapPrsOnk	0509030.06	Ontvangen kostenvergoedingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2312	1	BEivKapPrsOpp	0509030.07	Opname privé-financieringen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2313	1	BEivKapPrsOsp	0509030.08	Opname privé-spaargelden  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2314	1	BEivKapPrsVep	0509030.09	Verkoop privé-bezittingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2315	1	BEivKapPrsPzl	0509030.10	Privé-betaalde zakelijke lasten  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2316	1	BEivKapPrsOps	0509030.11	Overige privé-stortingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2317	1	BEivKapPro	0509040	Privé-opnamen	D	4	\N	t
2318	1	BEivKapProPok	0509040.02	Privé-opname kapitaal eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2319	1	BEivKapProPmv	0509040.03	Privé-gebruik materiële vaste activa eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2320	1	BEivKapProPrg	0509040.04	Privé-verbruik goederen eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2321	1	BEivKapProPiz	0509040.05	Privé-aandeel in zakelijke lasten eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2322	1	BEivKapProPpr	0509040.06	Privé-premies eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2323	1	BEivKapProPri	0509040.07	Privé-belastingen eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2324	1	BEivKapProPer	0509040.08	Privé-aflossingen en rente eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2325	1	BEivKapProPrk	0509040.09	Privé-aftrekbare kosten eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2326	1	BEivKapProFor	0509040.10	Dotatie Fiscale Oudedags Reserve eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2327	1	BEivKapProOvp	0509040.11	Overige privé-opnamen eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2328	1	BEivKapPoc	509041	Privé-onttrekking contanten 	D	4	\N	t
2329	1	BEivKapPng	509042	Privé-onttrekking in natura en goederen	D	4	\N	t
2330	1	BEivKapPbe	509043	Privé-belastingen	D	4	\N	t
2331	1	BEivKapPpr	509044	Privé-premies 	D	4	\N	t
2332	1	BEivKa2	509100	Eigen vermogen firmant 2	C	3	\N	t
2333	1	BEivKa2Ond	509110	Ondernemingsvermogen exclusief fiscale reserves fiscaal eigen vermogen onderneming natuurlijke personen	C	4	\N	t
2334	1	BEivKa2OndBeg	0509110.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2335	1	BEivKa2OndRgv	0509120.02	Rente geïnvesteerd vermogen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2336	1	BEivKa2OndArb	0509120.03	Arbeidsvergoeding  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2337	1	BEivKa2OndVbv	0509120.04	Vergoeding buitenvennootschappelijk vermogen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2338	1	BEivKa2OndAow	0509120.05	Aandeel in de overwinst  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2339	1	BEivKa2OndOvm	0509120.06	Overige mutaties eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2340	1	BEivKa2Prs	509130	Privé-stortingen firmant 2	C	4	\N	t
2341	1	BEivKa2PrsPsk	0509130.02	Privé-storting kapitaal  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2342	1	BEivKa2PrsOns	0509130.03	Ontvangen schenkingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2343	1	BEivKa2PrsOlp	0509130.04	Ontvangen loon, uitkeringen of pensioenen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2344	1	BEivKa2PrsOte	0509130.05	Ontvangen toeslagen en toelagen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2345	1	BEivKa2PrsOnk	0509130.06	Ontvangen kostenvergoedingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2346	1	BEivKa2PrsOpp	0509130.07	Opname privé-financieringen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2347	1	BEivKa2PrsOsp	0509130.08	Opname privé-spaargelden  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2348	1	BEivKa2PrsVep	0509130.09	Verkoop privé-bezittingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2349	1	BEivKa2PrsPzl	0509130.10	Privé-betaalde zakelijke lasten  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2350	1	BEivKa2PrsOps	0509130.11	Overige privé-stortingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2351	1	BEivKa2Pro	509140	Privé-opnamen firmant 2	D	4	\N	t
2352	1	BEivKa2ProPok	0509140.02	Privé-opname kapitaal  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2353	1	BEivKa2ProPmv	0509140.03	Privé-gebruik materiële vaste activa  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2354	1	BEivKa2ProPrg	0509140.04	Privé-verbruik goederen  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2355	1	BEivKa2ProPiz	0509140.05	Privé-aandeel in zakelijke lasten  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2356	1	BEivKa2ProPpr	0509140.06	Privé-premies  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2357	1	BEivKa2ProPri	0509140.07	Privé-belastingen  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2358	1	BEivKa2ProPer	0509140.08	Privé-aflossingen en rente  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2359	1	BEivKa2ProPrk	0509140.09	Privé-aftrekbare kosten  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2360	1	BEivKa2ProFor	0509140.10	Dotatie Fiscale Oudedags Reserve  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2361	1	BEivKa2ProOvp	0509140.11	Overige privé-opnamen  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2362	1	BEivKa2Poc	509150	Privé-onttrekking contanten firmant 2 	D	4	\N	t
2363	1	BEivKa2Png	509160	Privé-onttrekking in natura en goederen firmant 2	D	4	\N	t
2364	1	BEivKa2Pbe	509170	Privé-belastingen firmant 2	D	4	\N	t
2365	1	BEivKa2Ppr	509180	Privé-premies firmant 2 	D	4	\N	t
2366	1	BEivKa3	509200	Eigen vermogen firmant 3	C	3	\N	t
2367	1	BEivKa3Ond	509210	Ondernemingsvermogen exclusief fiscale reserves fiscaal eigen vermogen onderneming natuurlijke personen	C	4	\N	t
2368	1	BEivKa3OndBeg	0509210.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2369	1	BEivKa3OndRgv	0509220.02	Rente geïnvesteerd vermogen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2370	1	BEivKa3OndArb	0509220.03	Arbeidsvergoeding  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2371	1	BEivKa3OndVbv	0509220.04	Vergoeding buitenvennootschappelijk vermogen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2372	1	BEivKa3OndAow	0509220.05	Aandeel in de overwinst  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2373	1	BEivKa3OndOvm	0509220.06	Overige mutaties eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2374	1	BEivKa3Prs	509230	Privé-stortingen firmant 3	C	4	\N	t
2375	1	BEivKa3PrsPsk	0509230.02	Privé-storting kapitaal  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2376	1	BEivKa3PrsOns	0509230.03	Ontvangen schenkingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2377	1	BEivKa3PrsOlp	0509230.04	Ontvangen loon, uitkeringen of pensioenen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2378	1	BEivKa3PrsOte	0509230.05	Ontvangen toeslagen en toelagen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2379	1	BEivKa3PrsOnk	0509230.06	Ontvangen kostenvergoedingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2380	1	BEivKa3PrsOpp	0509230.07	Opname privé-financieringen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2381	1	BEivKa3PrsOsp	0509230.08	Opname privé-spaargelden  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2382	1	BEivKa3PrsVep	0509230.09	Verkoop privé-bezittingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2383	1	BEivKa3PrsPzl	0509230.10	Privé-betaalde zakelijke lasten  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2384	1	BEivKa3PrsOps	0509230.11	Overige privé-stortingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2385	1	BEivKa3Pro	509240	Privé-opnamen firmant 3	D	4	\N	t
2386	1	BEivKa3ProPok	0509240.02	Privé-opname kapitaal  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2387	1	BEivKa3ProPmv	0509240.03	Privé-gebruik materiële vaste activa  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2388	1	BEivKa3ProPrg	0509240.04	Privé-verbruik goederen  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2389	1	BEivKa3ProPiz	0509240.05	Privé-aandeel in zakelijke lasten  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2390	1	BEivKa3ProPpr	0509240.06	Privé-premies  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2391	1	BEivKa3ProPri	0509240.07	Privé-belastingen  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2392	1	BEivKa3ProPer	0509240.08	Privé-aflossingen en rente  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2393	1	BEivKa3ProPrk	0509240.09	Privé-aftrekbare kosten  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2394	1	BEivKa3ProFor	0509240.10	Dotatie Fiscale Oudedags Reserve  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2395	1	BEivKa3ProOvp	0509240.11	Overige privé-opnamen  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2396	1	BEivKa3Poc	509250	Privé-onttrekking contanten firmant 3 	D	4	\N	t
2397	1	BEivKa3Png	509260	Privé-onttrekking in natura en goederen firmant 3	D	4	\N	t
2398	1	BEivKa3Pbe	509270	Privé-belastingen firmant 3	D	4	\N	t
2399	1	BEivKa3Ppr	509280	Privé-premies firmant 3 	D	4	\N	t
2400	1	BEivKa4	509300	Eigen vermogen firmant 4	C	3	\N	t
2401	1	BEivKa4Ond	509310	Ondernemingsvermogen exclusief fiscale reserves fiscaal eigen vermogen onderneming natuurlijke personen	C	4	\N	t
2402	1	BEivKa4OndBeg	0509310.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2403	1	BEivKa4OndRgv	0509320.02	Rente geïnvesteerd vermogen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2404	1	BEivKa4OndArb	0509320.03	Arbeidsvergoeding  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2405	1	BEivKa4OndVbv	0509320.04	Vergoeding buitenvennootschappelijk vermogen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2406	1	BEivKa4OndAow	0509320.05	Aandeel in de overwinst  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2407	1	BEivKa4OndOvm	0509320.06	Overige mutaties eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2408	1	BEivKa4Prs	509330	Privé-stortingen firmant 4	C	4	\N	t
2409	1	BEivKa4PrsPsk	0509330.02	Privé-storting kapitaal  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2410	1	BEivKa4PrsOns	0509330.03	Ontvangen schenkingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2411	1	BEivKa4PrsOlp	0509330.04	Ontvangen loon, uitkeringen of pensioenen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2412	1	BEivKa4PrsOte	0509330.05	Ontvangen toeslagen en toelagen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2413	1	BEivKa4PrsOnk	0509330.06	Ontvangen kostenvergoedingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2414	1	BEivKa4PrsOpp	0509330.07	Opname privé-financieringen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2415	1	BEivKa4PrsOsp	0509330.08	Opname privé-spaargelden  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2416	1	BEivKa4PrsVep	0509330.09	Verkoop privé-bezittingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2417	1	BEivKa4PrsPzl	0509330.10	Privé-betaalde zakelijke lasten  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2418	1	BEivKa4PrsOps	0509330.11	Overige privé-stortingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2419	1	BEivKa4Pro	509340	Privé-opnamen firmant 4	D	4	\N	t
2420	1	BEivKa4ProPok	0509340.02	Privé-opname kapitaal  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2421	1	BEivKa4ProPmv	0509340.03	Privé-gebruik materiële vaste activa  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2422	1	BEivKa4ProPrg	0509340.04	Privé-verbruik goederen  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2423	1	BEivKa4ProPiz	0509340.05	Privé-aandeel in zakelijke lasten  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2424	1	BEivKa4ProPpr	0509340.06	Privé-premies  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2425	1	BEivKa4ProPri	0509340.07	Privé-belastingen  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2426	1	BEivKa4ProPer	0509340.08	Privé-aflossingen en rente  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2427	1	BEivKa4ProPrk	0509340.09	Privé-aftrekbare kosten  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2428	1	BEivKa4ProFor	0509340.10	Dotatie Fiscale Oudedags Reserve  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2429	1	BEivKa4ProOvp	0509340.11	Overige privé-opnamen  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2430	1	BEivKa4Poc	509350	Privé-onttrekking contanten firmant 4	D	4	\N	t
2431	1	BEivKa4Png	509360	Privé-onttrekking in natura en goederen firmant 4	D	4	\N	t
2432	1	BEivKa4Pbe	509370	Privé-belastingen firmant 4	D	4	\N	t
2433	1	BEivKa4Ppr	509380	Privé-premies firmant 4	D	4	\N	t
2434	1	BEivKa5	509400	Eigen vermogen firmant 5	C	3	\N	t
2435	1	BEivKa5Ond	509410	Ondernemingsvermogen exclusief fiscale reserves fiscaal eigen vermogen onderneming natuurlijke personen	C	4	\N	t
2436	1	BEivKa5OndBeg	0509410.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2437	1	BEivKa5OndRgv	0509420.02	Rente geïnvesteerd vermogen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2438	1	BEivKa5OndArb	0509420.03	Arbeidsvergoeding  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2439	1	BEivKa5OndVbv	0509420.04	Vergoeding buitenvennootschappelijk vermogen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2440	1	BEivKa5OndAow	0509420.05	Aandeel in de overwinst  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2441	1	BEivKa5OndOvm	0509420.06	Overige mutaties eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2442	1	BEivKa5Prs	509430	Privé-stortingen firmant 5	C	4	\N	t
2443	1	BEivKa5PrsPsk	0509430.02	Privé-storting kapitaal  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2444	1	BEivKa5PrsOns	0509430.03	Ontvangen schenkingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2445	1	BEivKa5PrsOlp	0509430.04	Ontvangen loon, uitkeringen of pensioenen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2446	1	BEivKa5PrsOte	0509430.05	Ontvangen toeslagen en toelagen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2447	1	BEivKa5PrsOnk	0509430.06	Ontvangen kostenvergoedingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2448	1	BEivKa5PrsOpp	0509430.07	Opname privé-financieringen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2449	1	BEivKa5PrsOsp	0509430.08	Opname privé-spaargelden  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2450	1	BEivKa5PrsVep	0509430.09	Verkoop privé-bezittingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2451	1	BEivKa5PrsPzl	0509430.10	Privé-betaalde zakelijke lasten  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2452	1	BEivKa5PrsOps	0509430.11	Overige privé-stortingen  eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2453	1	BEivKa5Pro	509440	Privé-opnamen firmant 5	D	4	\N	t
2454	1	BEivKa5ProPok	0509440.02	Privé-opname kapitaal  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2455	1	BEivKa5ProPmv	0509440.03	Privé-gebruik materiële vaste activa  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2456	1	BEivKa5ProPrg	0509440.04	Privé-verbruik goederen  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2457	1	BEivKa5ProPiz	0509440.05	Privé-aandeel in zakelijke lasten  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2458	1	BEivKa5ProPpr	0509440.06	Privé-premies  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2459	1	BEivKa5ProPri	0509440.07	Privé-belastingen  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2460	1	BEivKa5ProPer	0509440.08	Privé-aflossingen en rente  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2461	1	BEivKa5ProPrk	0509440.09	Privé-aftrekbare kosten  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2462	1	BEivKa5ProFor	0509440.10	Dotatie Fiscale Oudedags Reserve  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
3686	1	WRevOolOolRih	8016100.11	Rioolheffing	D	5	\N	t
2463	1	BEivKa5ProOvp	0509440.11	Overige privé-opnamen  eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2464	1	BEivKa5Poc	509450	Privé-onttrekking contanten firmant 5	D	4	\N	t
2465	1	BEivKa5Png	509460	Privé-onttrekking in natura en goederen firmant 5	D	4	\N	t
2466	1	BEivKa5Pbe	509470	Privé-belastingen firmant 5	D	4	\N	t
2467	1	BEivKa5Ppr	509480	Privé-premies firmant 5	D	4	\N	t
2468	1	BEivOkc	509079	Overige kapitaalcomponenten	C	3	\N	t
2469	1	BEivOkcInk	0509080	Informeel kapitaal (alleen in BD-VPB)	C	4	\N	t
2470	1	BEivOkcInkBeg	0509080.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2471	1	BEivOkcInkKap	0509080.02	Kapitaalmutaties eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2472	1	BEivOkcInkKac	0509080.03	Kapitaalcorrecties eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2473	1	BEivOkcInkOvm	0509080.04	Overige mutaties eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2474	1	BEivOkcKeg	0510050	Kosten egalisatiereserve fiscaal (alleen in BD-VPB)	C	4	\N	t
2475	1	BEivOkcKegBeg	0510050.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2476	1	BEivOkcKegDot	0510050.02	Dotatie eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2477	1	BEivOkcKegAtg	0510050.03	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2478	1	BEivOkcKegKtl	0510050.04	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2479	1	BEivOkcKegOve	0510050.05	Overboekingen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2480	1	BEivOkcKegVal	0510050.06	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2481	1	BEivOkcKegOvm	0510050.07	Overige mutaties eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2482	1	BEivFir	0510000	Fiscale reserves	C	3	\N	t
2483	1	BEivFirHer	510020	Herinvesteringsreserve fiscaal eigen vermogen	C	4	\N	t
2484	1	BEivFirHerBeg	0510020.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen	C	5	\N	t
2485	1	BEivFirHerDot	0510020.02	Dotatie eigen vermogen	C	5	\N	t
2486	1	BEivFirHerAaw	0510020.03	Afname ten gunste van het resultaat eigen vermogen	D	5	\N	t
2487	1	BEivFirHerKtl	0510020.07	Kosten ten laste van reserve eigen vermogen	D	5	\N	t
2488	1	BEivFirHerOve	0510020.04	Overboekingen eigen vermogen	C	5	\N	t
2489	1	BEivFirHerVal	0510020.05	Valutaomrekeningsverschillen eigen vermogen	C	5	\N	t
2490	1	BEivFirHerOvm	0510020.06	Overige mutaties eigen vermogen	C	5	\N	t
2491	1	BEivFirFor	0510010	Fiscale oudedagsreserve eigen vermogen onderneming natuurlijke personen	C	4	\N	t
2492	1	BEivFirForBeg	0510010.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2493	1	BEivFirForFor	0510010.02	Dotatie eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2494	1	BEivFirForAtg	0510010.08	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2495	1	BEivFirForKtl	0510010.07	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2496	1	BEivFirForOve	0510010.03	Overboekingen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2497	1	BEivFirForVal	0510010.09	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2498	1	BEivFirForOvm	0510010.04	Overige mutaties eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2499	1	BEivFirOpw	0510030	Opwaarderingsreserve eigen vermogen onderneming natuurlijke personen	C	4	\N	t
2500	1	BEivFirOpwBeg	0510030.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2501	1	BEivFirOpwDot	0510030.02	Dotatie eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2502	1	BEivFirOpwAtg	0510030.08	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2503	1	BEivFirOpwAaw	0510030.03	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2504	1	BEivFirOpwOve	0510030.04	Overboekingen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2505	1	BEivFirOpwVal	0510030.05	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2506	1	BEivFirOpwOvm	0510030.06	Overige mutaties eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2507	1	BEivFirRae	0510040	Reserve assurantie eigen risico eigen vermogen onderneming natuurlijke personen	C	4	\N	t
2508	1	BEivFirRaeBeg	0510040.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2509	1	BEivFirRaeDot	0510040.02	Dotatie eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2510	1	BEivFirRaeAtg	0510040.03	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2511	1	BEivFirRaeKtl	0510040.04	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2512	1	BEivFirRaeOve	0510040.05	Overboekingen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2513	1	BEivFirRaeVal	0510040.06	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2514	1	BEivFirRaeOvm	0510040.07	Overige mutaties eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2515	1	BEivFirExp	0510060	Exportreserve eigen vermogen onderneming natuurlijke personen	C	4	\N	t
2516	1	BEivFirExpBeg	0510060.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2517	1	BEivFirExpDot	0510060.02	Dotatie eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2518	1	BEivFirExpAtg	0510060.03	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	D	5	\N	t
4018	1	WKprTvlKbaCom	7203300.06	Communicatiekosten	D	5	\N	t
2519	1	BEivFirExpKtl	0510060.04	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2520	1	BEivFirExpOve	0510060.05	Overboekingen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2521	1	BEivFirExpVal	0510060.06	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2522	1	BEivFirExpOvm	0510060.07	Overige mutaties eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2523	1	BEivFirRis	0510070	Risicoreserve eigen vermogen onderneming natuurlijke personen	C	4	\N	t
2524	1	BEivFirRisBeg	0510070.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2525	1	BEivFirRisDot	0510070.02	Dotatie eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2526	1	BEivFirRisAtg	0510070.03	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2527	1	BEivFirRisKtl	0510070.04	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2528	1	BEivFirRisOve	0510070.05	Overboekingen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2529	1	BEivFirRisVal	0510070.06	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2530	1	BEivFirRisOvm	0510070.07	Overige mutaties eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2531	1	BEivFirTer	0510080	Terugkeerreserve eigen vermogen onderneming natuurlijke personen	C	4	\N	t
2532	1	BEivFirTerBeg	0510080.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2533	1	BEivFirTerDot	0510080.02	Dotatie eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2534	1	BEivFirTerAaw	0510080.03	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2535	1	BEivFirTerVri	0510080.04	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2536	1	BEivFirTerOve	0510080.05	Overboekingen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2537	1	BEivFirTerVal	0510080.06	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2538	1	BEivFirTerOvm	0510080.07	Overige mutaties eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2539	1	BEivFirOfr	0510090	Overige fiscale reserves eigen vermogen onderneming natuurlijke personen	C	4	\N	t
2540	1	BEivFirOfrBeg	0510090.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2541	1	BEivFirOfrDot	0510090.02	Dotatie eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2542	1	BEivFirOfrAaw	0510090.03	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2543	1	BEivFirOfrVri	0510090.04	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	D	5	\N	t
2544	1	BEivFirOfrOve	0510090.05	Overboekingen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2545	1	BEivFirOfrVal	0510090.06	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2546	1	BEivFirOfrOvm	0510090.07	Overige mutaties eigen vermogen onderneming natuurlijke personen	C	5	\N	t
2547	1	BEivAvd	0508000	Aandeel van derden	C	3	\N	t
2548	1	BEivAvdAvd	0508010	Aandeel van derden aandeel van derden	C	4	\N	t
2549	1	BEga	06	Egalisatierekening	C	2	\N	t
2550	1	BEgaEga	601000	Egalisatierekening	C	3	\N	t
2551	1	BEgaEgaEga	601010	Egalisatierekening	C	4	\N	t
2552	1	BEgaEgaEgaBeg	0601010.01	Beginbalans egalisatierekening	C	5	\N	t
2553	1	BEgaEgaEgaDot	0601010.02	Dotatie egalisatierekening	C	5	\N	t
2554	1	BEgaEgaEgaOnt	0601010.03	Onttrekking egalisatierekening	D	5	\N	t
2555	1	BEgaEgaEgaOvm	0601010.04	Overige mutaties egalisatierekening	C	5	\N	t
2556	1	BVrz	07	Voorzieningen	C	2	\N	t
2557	1	BVrzVvp	0701000	Voorziening voor pensioenen	C	3	\N	t
2558	1	BVrzVvpVpd	0701010	Voorziening voor pensioenen directie in eigen beheer voorziening voor pensioenen	C	4	\N	t
2559	1	BVrzVvpVpdBeg	0701010.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2560	1	BVrzVvpVpdToe	0701010.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2561	1	BVrzVvpVpdOnt	0701010.03	Gebruik van voorzieningen 	D	5	\N	t
2562	1	BVrzVvpVpdVri	0701010.04	Vrijval van voorziening 	D	5	\N	t
2563	1	BVrzVvpVpdOmv	0701010.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2564	1	BVrzVvpVpdOev	0701010.06	Oprenting van voorzieningen 	C	5	\N	t
2565	1	BVrzVvpBac	0701020	Backserviceverplichting 	C	4	\N	t
2566	1	BVrzVvpBacBeg	0701020.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2567	1	BVrzVvpBacToe	0701020.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2568	1	BVrzVvpBacOnt	0701020.03	Gebruik van voorzieningen 	D	5	\N	t
2569	1	BVrzVvpBacVri	0701020.04	Vrijval van voorziening 	D	5	\N	t
2570	1	BVrzVvpBacOmv	0701020.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2571	1	BVrzVvpBacOev	0701020.06	Oprenting van voorzieningen 	C	5	\N	t
2572	1	BVrzVvb	0702000	Voorziening voor belastingen	C	3	\N	t
2573	1	BVrzVvbVlb	0702010	Voorziening voor latente belastingverplichtingen voorziening voor belastingen	C	4	\N	t
2574	1	BVrzVvbVlbBeg	0702010.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2575	1	BVrzVvbVlbToe	0702010.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2576	1	BVrzVvbVlbOnt	0702010.03	Gebruik van voorzieningen 	D	5	\N	t
2577	1	BVrzVvbVlbVri	0702010.04	Vrijval van voorziening 	D	5	\N	t
2578	1	BVrzVvbVlbOmv	0702010.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2579	1	BVrzVvbVlbOev	0702010.06	Oprenting van voorzieningen 	C	5	\N	t
2580	1	BVrzVvbVlbOvm	0702010.07	Overige mutaties voorziening latente belastingverplichtingen	C	5	\N	t
2581	1	BVrzVvbVvb	702020	Voorziening voor belastingen voorziening voor belastingen	C	4	\N	t
2582	1	BVrzVvbVvbBeg	0702020.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2583	1	BVrzVvbVvbToe	0702020.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2584	1	BVrzVvbVvbOnt	0702020.03	Gebruik van voorzieningen 	D	5	\N	t
2585	1	BVrzVvbVvbVri	0702020.04	Vrijval van voorziening 	D	5	\N	t
2586	1	BVrzVvbVvbOmv	0702020.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2587	1	BVrzVvbVvbOev	0702020.06	Oprenting van voorzieningen 	C	5	\N	t
2588	1	BVrzOvz	0704000	Overige voorzieningen	C	3	\N	t
2589	1	BVrzOvzVhe	0704020	Voorziening voor herstelkosten overige voorzieningen	C	4	\N	t
2590	1	BVrzOvzVheBeg	0704020.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2591	1	BVrzOvzVheToe	0704020.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2592	1	BVrzOvzVheOnt	0704020.03	Gebruik van voorzieningen 	D	5	\N	t
2593	1	BVrzOvzVheVri	0704020.04	Vrijval van voorziening 	D	5	\N	t
2594	1	BVrzOvzVheOmv	0704020.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2595	1	BVrzOvzVheOev	0704020.06	Oprenting van voorzieningen 	C	5	\N	t
2596	1	BVrzOvzVvo	0704030	Voorziening voor opruiming van aanwezige milieuvervuiling 	C	4	\N	t
2597	1	BVrzOvzVvoBeg	0704030.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2598	1	BVrzOvzVvoToe	0704030.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2599	1	BVrzOvzVvoOnt	0704030.03	Gebruik van voorzieningen 	D	5	\N	t
2600	1	BVrzOvzVvoVri	0704030.04	Vrijval van voorziening 	D	5	\N	t
2601	1	BVrzOvzVvoOmv	0704030.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2602	1	BVrzOvzVvoOev	0704030.06	Oprenting van voorzieningen 	C	5	\N	t
2603	1	BVrzOvzVuc	0704040	Voorziening uit hoofde van claims, geschillen en rechtsgedingen 	C	4	\N	t
2604	1	BVrzOvzVucBeg	0704040.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2605	1	BVrzOvzVucToe	0704040.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2606	1	BVrzOvzVucOnt	0704040.03	Gebruik van voorzieningen 	D	5	\N	t
2607	1	BVrzOvzVucVri	0704040.04	Vrijval van voorziening 	D	5	\N	t
2608	1	BVrzOvzVucOmv	0704040.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2609	1	BVrzOvzVucOev	0704040.06	Oprenting van voorzieningen 	C	5	\N	t
2610	1	BVrzOvzVvg	0703010	Voorziening voor groot onderhoud 	C	4	\N	t
2611	1	BVrzOvzVvgBeg	0703010.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2612	1	BVrzOvzVvgToe	0703010.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2613	1	BVrzOvzVvgOnt	0703010.03	Gebruik van voorzieningen 	D	5	\N	t
2614	1	BVrzOvzVvgVri	0703010.04	Vrijval van voorziening 	D	5	\N	t
2615	1	BVrzOvzVvgOmv	0703010.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2616	1	BVrzOvzVvgOev	0703010.06	Oprenting van voorzieningen 	C	5	\N	t
2617	1	BVrzOvzVwp	0704050	Voorziening voor verwijderingsverplichtingen 	C	4	\N	t
2618	1	BVrzOvzVwpBeg	0704050.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2619	1	BVrzOvzVwpToe	0704050.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2620	1	BVrzOvzVwpOnt	0704050.03	Gebruik van voorzieningen 	D	5	\N	t
2621	1	BVrzOvzVwpVri	0704050.04	Vrijval van voorziening 	D	5	\N	t
2622	1	BVrzOvzVwpOmv	0704050.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2623	1	BVrzOvzVwpOev	0704050.06	Oprenting van voorzieningen 	C	5	\N	t
2624	1	BVrzOvzVlc	0704060	Voorziening voor verlieslatende contracten 	C	4	\N	t
2625	1	BVrzOvzVlcBeg	0704060.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2626	1	BVrzOvzVlcToe	0704060.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2627	1	BVrzOvzVlcOnt	0704060.03	Gebruik van voorzieningen 	D	5	\N	t
2628	1	BVrzOvzVlcVri	0704060.04	Vrijval van voorziening 	D	5	\N	t
2629	1	BVrzOvzVlcOmv	0704060.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2630	1	BVrzOvzVlcOev	0704060.06	Oprenting van voorzieningen 	C	5	\N	t
2631	1	BVrzOvzVir	0704070	Voorziening in verband met reorganisaties 	C	4	\N	t
2632	1	BVrzOvzVirBeg	0704070.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2633	1	BVrzOvzVirToe	0704070.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2634	1	BVrzOvzVirOnt	0704070.03	Gebruik van voorzieningen 	D	5	\N	t
2635	1	BVrzOvzVirVri	0704070.04	Vrijval van voorziening 	D	5	\N	t
2636	1	BVrzOvzVirOmv	0704070.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2637	1	BVrzOvzVirOev	0704070.06	Oprenting van voorzieningen 	C	5	\N	t
2638	1	BVrzOvzVid	0704080	Voorziening in verband met deelnemingen 	C	4	\N	t
2639	1	BVrzOvzVidBeg	0704080.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2640	1	BVrzOvzVidToe	0704080.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2641	1	BVrzOvzVidOnt	0704080.03	Gebruik van voorzieningen 	D	5	\N	t
2642	1	BVrzOvzVidVri	0704080.04	Vrijval van voorziening 	D	5	\N	t
2643	1	BVrzOvzVidOmv	0704080.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2644	1	BVrzOvzVidOev	0704080.06	Oprenting van voorzieningen 	C	5	\N	t
2645	1	BVrzOvzVidOvm	0704080.07	Overige mutatie voorziening deelneming	C	5	\N	t
2646	1	BVrzOvzGar	0704010	Garantievoorziening 	C	4	\N	t
2647	1	BVrzOvzGarBeg	0704010.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2648	1	BVrzOvzGarToe	0704010.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2649	1	BVrzOvzGarOnt	0704010.03	Gebruik van voorzieningen 	D	5	\N	t
2650	1	BVrzOvzGarVri	0704010.04	Vrijval van voorziening 	D	5	\N	t
2651	1	BVrzOvzGarOmv	0704010.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2652	1	BVrzOvzGarOev	0704010.06	Oprenting van voorzieningen 	C	5	\N	t
2653	1	BVrzOvzJub	0704090	Jubileumvoorziening 	C	4	\N	t
2654	1	BVrzOvzJubBeg	0704090.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2655	1	BVrzOvzJubToe	0704090.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2656	1	BVrzOvzJubOnt	0704090.03	Gebruik van voorzieningen 	D	5	\N	t
2657	1	BVrzOvzJubVri	0704090.04	Vrijval van voorziening 	D	5	\N	t
2658	1	BVrzOvzJubOmv	0704090.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2659	1	BVrzOvzJubOev	0704090.06	Oprenting van voorzieningen 	C	5	\N	t
2660	1	BVrzOvzArb	704100	Voorziening voor verzekering van arbeidsongeschiktheidsrisico's 	C	4	\N	t
2661	1	BVrzOvzArbBeg	0704100.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2662	1	BVrzOvzArbToe	0704100.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2663	1	BVrzOvzArbOnt	0704100.03	Gebruik van voorzieningen 	D	5	\N	t
2664	1	BVrzOvzArbVri	0704100.04	Vrijval van voorziening 	D	5	\N	t
2665	1	BVrzOvzArbOmv	0704100.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2666	1	BVrzOvzArbOev	0704100.06	Oprenting van voorzieningen 	C	5	\N	t
2667	1	BVrzOvzOvz	0704120	Overige voorzieningen 	C	4	\N	t
2668	1	BVrzOvzOvzBeg	0704120.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2669	1	BVrzOvzOvzToe	0704120.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2670	1	BVrzOvzOvzOnt	0704120.03	Gebruik van voorzieningen 	D	5	\N	t
2671	1	BVrzOvzOvzVri	0704120.04	Vrijval van voorziening 	D	5	\N	t
2672	1	BVrzOvzOvzOmv	0704120.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2673	1	BVrzOvzOvzOev	0704120.06	Oprenting van voorzieningen 	C	5	\N	t
2674	1	BVrzOvzOvzOvm	0704120.07	Overige mutaties 	C	5	\N	t
2675	1	BVrzOvzOio	704140	Voorziening onroerende zaken in ontwikkeling	C	4	\N	t
2676	1	BVrzOvzOioBeg	0704140.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2677	1	BVrzOvzOioToe	0704140.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2678	1	BVrzOvzOioOnt	0704140.03	Onttrekking van voorzieningen	D	5	\N	t
2679	1	BVrzOvzOioVri	0704140.04	Vrijval van voorziening 	D	5	\N	t
2680	1	BVrzOvzOioOmv	0704140.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2681	1	BVrzOvzOioOev	0704140.06	Oprenting van voorzieningen 	C	5	\N	t
2682	1	BVrzOvzOioOvm	0704140.07	Overige mutaties 	C	5	\N	t
2683	1	BVrzOvzOiv	704150	Voorziening onroerende zaken in ontwikkeling voor verkoop	C	4	\N	t
2684	1	BVrzOvzOivBeg	0704150.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2685	1	BVrzOvzOivToe	0704150.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2686	1	BVrzOvzOivOnt	0704150.03	Onttrekking van voorzieningen	D	5	\N	t
2687	1	BVrzOvzOivVri	0704150.04	Vrijval van voorziening 	D	5	\N	t
2688	1	BVrzOvzOivOmv	0704150.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2689	1	BVrzOvzOivOev	0704150.06	Oprenting van voorzieningen 	C	5	\N	t
2690	1	BVrzOvzOivOvm	0704150.07	Overige mutaties 	C	5	\N	t
2691	1	BVrzOvzLob	704160	Loopbaan begeleiding voorziening	C	4	\N	t
2692	1	BVrzOvzLobBeg	0704160.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2693	1	BVrzOvzLobToe	0704160.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2694	1	BVrzOvzLobOnt	0704160.03	Onttrekking van voorzieningen	D	5	\N	t
2695	1	BVrzOvzLobVri	0704160.04	Vrijval van voorziening 	D	5	\N	t
2696	1	BVrzOvzLobOmv	0704160.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2697	1	BVrzOvzLobOev	0704160.06	Oprenting van voorzieningen 	C	5	\N	t
2698	1	BVrzOvzZoa	704170	Voorziening voor verzekering van ziekte of arbeidsongeschiktheid	C	4	\N	t
2699	1	BVrzOvzZoaBeg	0704170.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2700	1	BVrzOvzZoaToe	0704170.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2701	1	BVrzOvzZoaOnt	0704170.03	Gebruik van voorzieningen 	D	5	\N	t
2702	1	BVrzOvzZoaVri	0704170.04	Vrijval van voorziening 	D	5	\N	t
2703	1	BVrzOvzZoaOmv	0704170.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2704	1	BVrzOvzZoaOev	0704170.06	Oprenting van voorzieningen 	C	5	\N	t
2705	1	BVrzOvzUhp	704180	Voorziening uit hoofde van personeelsbeloningen	C	4	\N	t
2706	1	BVrzOvzUhpBeg	0704180.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2707	1	BVrzOvzUhpToe	0704180.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2708	1	BVrzOvzUhpOnt	0704180.03	Gebruik van voorzieningen 	D	5	\N	t
2709	1	BVrzOvzUhpVri	0704180.04	Vrijval van voorziening 	D	5	\N	t
2710	1	BVrzOvzUhpOmv	0704180.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2711	1	BVrzOvzUhpOev	0704180.06	Oprenting van voorzieningen 	C	5	\N	t
2712	1	BVrzOvzAgb	704190	Voorziening uit hoofde van op aandelen gebaseerde betalingen	C	4	\N	t
2713	1	BVrzOvzAgbBeg	0704190.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2714	1	BVrzOvzAgbToe	0704190.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2715	1	BVrzOvzAgbOnt	0704190.03	Gebruik van voorzieningen 	D	5	\N	t
2716	1	BVrzOvzAgbVri	0704190.04	Vrijval van voorziening 	D	5	\N	t
2717	1	BVrzOvzAgbOmv	0704190.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2718	1	BVrzOvzAgbOev	0704190.06	Oprenting van voorzieningen 	C	5	\N	t
2719	1	BVrzOvzVza	704191	Voorziening voor verplichtingen uit hoofde van ziekte of arbeidsongeschiktheid	C	4	\N	t
2720	1	BVrzOvzVzaBeg	0704191.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2721	1	BVrzOvzVzaToe	0704191.02	Toevoegingen aan voorzieningen 	C	5	\N	t
2722	1	BVrzOvzVzaOnt	0704191.03	Gebruik van voorzieningen 	D	5	\N	t
2723	1	BVrzOvzVzaVri	0704191.04	Vrijval van voorziening 	D	5	\N	t
2724	1	BVrzOvzVzaOmv	0704191.05	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2725	1	BVrzOvzVzaOev	0704191.06	Oprenting van voorzieningen 	C	5	\N	t
2726	1	BVrzOih	704174	Voorziening voor onrendabele investeringen en herstructureringen	C	3	\N	t
2727	1	BVrzOihOrb	704176	Toekomstige investeringen in bestaande projecten	C	4	\N	t
2728	1	BVrzOihOrbBeg	0704176.01	Beginbalans (overname eindsaldo vorig jaar)	C	5	\N	t
2729	1	BVrzOihOrbTre	0704176.02	Toevoegingen aan voorzieningen ten laste van het resultaat	C	5	\N	t
2730	1	BVrzOihOrbOnt	0704176.04	Onttrekking van voorzieningen	D	5	\N	t
2731	1	BVrzOihOrbVri	0704176.05	Vrijval van voorziening	D	5	\N	t
2732	1	BVrzOihOrbOev	0704176.07	Oprenting van voorzieningen	C	5	\N	t
2733	1	BVrzOihOrt	704175	Toekomstige investeringen in nieuwbouwprojecten	C	4	\N	t
2734	1	BVrzOihOrtBeg	0704175.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
2735	1	BVrzOihOrtTre	0704175.02	Toevoegingen aan voorzieningen ten laste van het resultaat	C	5	\N	t
2736	1	BVrzOihOrtTev	0704175.03	Toevoegingen aan voorzieningen ten laste van het eigen vermogen	C	5	\N	t
2737	1	BVrzOihOrtOnt	0704175.04	Onttrekking van voorzieningen	D	5	\N	t
2738	1	BVrzOihOrtVri	0704175.05	Vrijval van voorziening 	D	5	\N	t
2739	1	BVrzOihOrtOmv	0704175.06	Omrekeningsverschillen over voorzieningen 	C	5	\N	t
2740	1	BVrzOihOrtOev	0704175.07	Oprenting van voorzieningen 	C	5	\N	t
2741	1	BLas	08	Langlopende schulden	C	2	\N	t
2742	1	BLasAcl	0801000	Achtergestelde schulden (langlopend)	C	3	\N	t
2743	1	BLasAclAll	0801010	Hoofdsom achtergestelde schulden (langlopend)	C	4	\N	t
2744	1	BLasAclAllBeg	0801010.01	Beginbalans (overname eindsaldo vorig jaar) achtergestelde schulden	C	5	\N	t
2745	1	BLasAclAllToe	0801010.03	Aanvullend opgenomen achtergestelde schulden	C	5	\N	t
2746	1	BLasAclAllOvs	0801010.10	Bij overname verkregen schulden achtergestelde schulden	C	5	\N	t
2747	1	BLasAclAllAvs	0801010.11	Bij afstoting vervreemde schulden achtergestelde schulden	D	5	\N	t
2748	1	BLasAclAllBir	0801010.08	Bijschrijving rente achtergestelde schulden	C	5	\N	t
2749	1	BLasAclAllOmv	0801010.06	Omrekeningsverschillen achtergestelde schulden	C	5	\N	t
2750	1	BLasAclAllOvm	0801010.07	Overige mutaties achtergestelde schulden	C	5	\N	t
2751	1	BLasAclAllOwv	0801010.12	Overige waardeveranderingen achtergestelde schulden	C	5	\N	t
2752	1	BLasAclCla	801020	Cumulatieve aflossingen achtergestelde schulden (langlopend)	D	4	\N	t
2753	1	BLasAclClaBeg	0801020.01	Aflossingen beginbalans (overname eindsaldo vorig jaar) achtergestelde schulden	D	5	\N	t
2754	1	BLasAclClaAfl	0801020.02	Aflossingen in boekjaar achtergestelde schulden	D	5	\N	t
2755	1	BLasAclClaAvp	0801020.05	Aflossingsverplichting (overboeking naar kortlopend) achtergestelde schulden	D	5	\N	t
2756	1	BLasCol	0802000	Converteerbare leningen (langlopend)	C	3	\N	t
2757	1	BLasColCll	802010	Hoofdsom converteerbare leningen (langlopend)	C	4	\N	t
2758	1	BLasColCllBeg	0802010.01	Beginbalans (overname eindsaldo vorig jaar) converteerbare leningen	C	5	\N	t
2759	1	BLasColCllToe	0802010.03	Aanvullend opgenomen converteerbare leningen	C	5	\N	t
2760	1	BLasColCllOvs	0802010.10	Bij overname verkregen schulden	C	5	\N	t
2761	1	BLasColCllAvs	0802010.11	Bij afstoting vervreemde schulden	D	5	\N	t
2762	1	BLasColCllBir	0802010.08	Bijschrijving rente converteerbare leningen	C	5	\N	t
2763	1	BLasColCllOmv	0802010.06	Omrekeningsverschillen converteerbare leningen	C	5	\N	t
2764	1	BLasColCllOvm	0802010.07	Overige mutaties converteerbare leningen	C	5	\N	t
2765	1	BLasColCllOwv	0802010.12	Overige waardeveranderingen	C	5	\N	t
2766	1	BLasColCla	802020	Cumulatieve aflossingen converteerbare leningen (langlopend)	D	4	\N	t
2767	1	BLasColClaBeg	0802020.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	D	5	\N	t
2768	1	BLasColClaAfl	0802020.02	Aflossingen in boekjaar converteerbare leningen (langlopend)	D	5	\N	t
2769	1	BLasColClaAvp	0802020.05	Aflossingsverplichting (overboeking naar kortlopend) converteerbare leningen (langlopend)	D	5	\N	t
2770	1	BLasAoe	0803000	Obligatieleningen, pandbrieven en andere leningen (langlopend)	C	3	\N	t
2771	1	BLasAoeAol	0803010	Hoofdsom andere obligaties en onderhandse leningen (langlopend)	C	4	\N	t
2772	1	BLasAoeAolBeg	0803010.01	Beginbalans (overname eindsaldo vorig jaar) andere obligaties en onderhandse leningen	C	5	\N	t
2773	1	BLasAoeAolToe	0803010.03	Aanvullend opgenomen andere obligaties en onderhandse leningen	C	5	\N	t
2774	1	BLasAoeAolOvs	0803010.10	Bij overname verkregen schulden	C	5	\N	t
2775	1	BLasAoeAolAvs	0803010.11	Bij afstoting vervreemde schulden	D	5	\N	t
2776	1	BLasAoeAolBir	0803010.08	Bijschrijving rente / oprenting andere obligaties en onderhandse leningen	C	5	\N	t
2777	1	BLasAoeAolOmv	0803010.06	Omrekeningsverschillen andere obligaties en onderhandse leningen	C	5	\N	t
2778	1	BLasAoeAolOvm	0803010.07	Overige mutaties andere obligaties en onderhandse leningen	C	5	\N	t
2779	1	BLasAoeAolOwv	0803010.12	Overige waardeveranderingen	C	5	\N	t
2780	1	BLasAoeCla	803020	Cumulatieve aflossingen andere obligaties en onderhandse leningen (langlopend)	D	4	\N	t
2781	1	BLasAoeClaBeg	0803020.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	D	5	\N	t
2782	1	BLasAoeClaAfl	0803020.02	Aflossingen in boekjaar andere obligaties en onderhandse leningen (langlopend)	D	5	\N	t
4160	1	WPerLesGraJuk	4001090.02	Jubileumuitkering	D	5	\N	t
2783	1	BLasAoeClaAvp	0803020.05	Aflossingsverplichting (overboeking naar kortlopend) andere obligaties en onderhandse leningen (langlopend)	D	5	\N	t
2784	1	BLasFlv	0804000	Financiële lease verplichtingen (langlopend)	C	3	\N	t
2785	1	BLasFlvFlv	804010	Hoofdsom financiële lease verplichtingen (langlopend)	C	4	\N	t
2786	1	BLasFlvFlvBeg	0804010.01	Beginbalans (overname eindsaldo vorig jaar) financiële lease verplichtingen	C	5	\N	t
2787	1	BLasFlvFlvToe	0804010.03	Aanvullend opgenomen financiële lease verplichtingen	C	5	\N	t
2788	1	BLasFlvFlvOvs	0804010.10	Bij overname verkregen schulden financiële lease verplichtingen	C	5	\N	t
2789	1	BLasFlvFlvAvs	0804010.11	Bij afstoting vervreemde schulden financiële lease verplichtingen	D	5	\N	t
2790	1	BLasFlvFlvBir	0804010.08	Bijschrijving rente / oprenting financiële lease verplichtingen	C	5	\N	t
2791	1	BLasFlvFlvOmv	0804010.06	Omrekeningsverschillen financiële lease verplichtingen	C	5	\N	t
2792	1	BLasFlvFlvOvm	0804010.07	Overige mutaties financiële lease verplichtingen	C	5	\N	t
2793	1	BLasFlvFlvOwv	0804010.12	Overige waardeveranderingen financiële lease verplichtingen	C	5	\N	t
2794	1	BLasFlvCla	804020	Cumulatieve aflossingen financiële lease verplichtingen (langlopend)	D	4	\N	t
2795	1	BLasFlvClaBeg	0804020.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	D	5	\N	t
2796	1	BLasFlvClaAfl	0804020.02	Aflossingen in boekjaar financiële lease verplichtingen (langlopend)	D	5	\N	t
2797	1	BLasFlvClaAvp	0804020.05	Aflossingsverplichting (overboeking naar kortlopend) financiële lease verplichtingen (langlopend)	D	5	\N	t
2798	1	BLasSak	0805000	Schulden aan banken (langlopend)	C	3	\N	t
2799	1	BLasSakHvl	0805010	Hoofdsom hypotheken van kredietinstellingen (langlopend)	C	4	\N	t
2800	1	BLasSakHvlBeg	0805010.01	Beginbalans hypotheken van kredietinstellingen (langlopend)	C	5	\N	t
2801	1	BLasSakHvlToe	0805010.03	Toename hypotheken van kredietinstellingen (langlopend)	C	5	\N	t
2802	1	BLasSakHvlOvs	0805010.10	Bij overname verkregen schulden hypotheken van kredietinstellingen (langlopend)	C	5	\N	t
2803	1	BLasSakHvlAvs	0805010.11	Bij afstoting vervreemde schulden hypotheken van kredietinstellingen (langlopend)	D	5	\N	t
2804	1	BLasSakHvlBir	0805010.08	Bijschrijving rente / oprenting hypotheken van kredietinstellingen (langlopend)	C	5	\N	t
2805	1	BLasSakHvlOmv	0805010.06	Omrekeningsverschillen hypotheken van kredietinstellingen (langlopend)	C	5	\N	t
2806	1	BLasSakHvlOvm	0805010.07	Overige mutaties hypotheken van kredietinstellingen (langlopend)	C	5	\N	t
2807	1	BLasSakHvlOwv	0805010.12	Overige waardeveranderingen hypotheken van kredietinstellingen (langlopend)	C	5	\N	t
2808	1	BLasSakCla	805015	Cumulatieve aflossingen hypotheken van kredietinstellingen (langlopend)	D	4	\N	t
2809	1	BLasSakClaBeg	0805015.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	D	5	\N	t
2810	1	BLasSakClaAfl	0805015.04	Aflossingen in boekjaar hypotheken van kredietinstellingen (langlopend)	D	5	\N	t
2811	1	BLasSakClaAvp	0805015.05	Aflossingsverplichting (overboeking naar kortlopend) hypotheken van kredietinstellingen (langlopend)	D	5	\N	t
2812	1	BLasSakFvl	0805020	Hoofdsom financieringen van kredietinstellingen (langlopend)	C	4	\N	t
2813	1	BLasSakFvlBeg	0805020.01	Beginbalans financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2814	1	BLasSakFvlToe	0805020.03	Toename financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2815	1	BLasSakFvlOvs	0805020.10	Bij overname verkregen schulden financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2816	1	BLasSakFvlAvs	0805020.11	Bij afstoting vervreemde schulden financieringen van kredietinstellingen (langlopend)	D	5	\N	t
2817	1	BLasSakFvlBir	0805020.08	Bijschrijving rente / oprenting financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2818	1	BLasSakFvlOmv	0805020.06	Omrekeningsverschillen financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2819	1	BLasSakFvlOvm	0805020.07	Overige mutaties financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2820	1	BLasSakFvlOwv	0805020.12	Overige waardeveranderingen hypotheken van kredietinstellingen (langlopend)	C	5	\N	t
2821	1	BLasSakFca	805025	Cumulatieve aflossingen financieringen van kredietinstellingen (langlopend)	D	4	\N	t
2822	1	BLasSakFcaBeg	0805025.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	D	5	\N	t
2823	1	BLasSakFcaAfl	0805025.04	Aflossingen in boekjaar financieringen van kredietinstellingen (langlopend)	D	5	\N	t
2824	1	BLasSakFcaAvp	0805025.05	Aflossingsverplichting (overboeking naar kortlopend) financieringen van kredietinstellingen (langlopend)	D	5	\N	t
2825	1	BLasSakLvl	805030	Hoofdsom leningen van kredietinstellingen (langlopend)	C	4	\N	t
2826	1	BLasSakLvlBeg	0805030.01	Beginbalans leningen van kredietinstellingen (langlopend)	C	5	\N	t
2827	1	BLasSakLvlToe	0805030.03	Toename leningen van kredietinstellingen (langlopend)	C	5	\N	t
2828	1	BLasSakLvlOvs	0805030.10	Bij overname verkregen schulden financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2829	1	BLasSakLvlAvs	0805030.11	Bij afstoting vervreemde schulden financieringen van kredietinstellingen (langlopend)	D	5	\N	t
2830	1	BLasSakLvlBir	0805030.08	Bijschrijving rente / oprenting financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2831	1	BLasSakLvlOmv	0805030.06	Omrekeningsverschillen leningen van kredietinstellingen (langlopend)	C	5	\N	t
2832	1	BLasSakLvlOvm	0805030.07	Overige mutaties leningen van kredietinstellingen (langlopend)	C	5	\N	t
2833	1	BLasSakLvlOwv	0805030.12	Overige waardeveranderingen hypotheken van kredietinstellingen (langlopend)	C	5	\N	t
2834	1	BLasSakLvlMvl	0805030.13	Marktwaardecorrectie van de vastrentende lening 	C	5	\N	t
2835	1	BLasSakLca	805035	Cumulatieve aflossingen leningen van kredietinstellingen (langlopend)	D	4	\N	t
2836	1	BLasSakLcaBeg	0805035.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	D	5	\N	t
2837	1	BLasSakLcaAfl	0805035.04	Aflossingen in boekjaar leningen van kredietinstellingen (langlopend)	D	5	\N	t
2838	1	BLasSakLcaAvp	0805035.05	Aflossingsverplichting (overboeking naar kortlopend) leningen van kredietinstellingen (langlopend)	D	5	\N	t
2839	1	BLasSakLcaMvl	0805035.06	Aflossingsverplichting marktwaardecorrectie vastrentende lening (langlopend)	D	5	\N	t
2840	1	BLasSakOvl	805040	Hoofdsom overige schulden aan kredietinstellingen (langlopend)	C	4	\N	t
2841	1	BLasSakOvlBeg	0805040.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan kredietinstellingen	C	5	\N	t
2842	1	BLasSakOvlToe	0805040.03	Aanvullend opgenomen schulden aan kredietinstellingen	C	5	\N	t
2843	1	BLasSakOvlOvs	0805040.10	Bij overname verkregen schulden financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2844	1	BLasSakOvlAvs	0805040.11	Bij afstoting vervreemde schulden financieringen van kredietinstellingen (langlopend)	D	5	\N	t
2845	1	BLasSakOvlBir	0805040.08	Bijschrijving rente / oprenting financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2846	1	BLasSakOvlOmv	0805040.06	Omrekeningsverschillen leningen van kredietinstellingen (langlopend)	C	5	\N	t
2847	1	BLasSakOvlOvm	0805040.07	Overige mutaties leningen van kredietinstellingen (langlopend)	C	5	\N	t
2848	1	BLasSakOvlOwv	0805040.12	Overige waardeveranderingen hypotheken van kredietinstellingen (langlopend)	C	5	\N	t
2849	1	BLasSakOca	805045	Cumulatieve aflossingen overige schulden aan kredietinstellingen (langlopend)	D	4	\N	t
2850	1	BLasSakOcaBeg	0805045.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	D	5	\N	t
2851	1	BLasSakOcaAfl	0805045.04	Aflossingen in boekjaar overige schulden van kredietinstellingen (langlopend)	D	5	\N	t
2852	1	BLasSakOcaAvp	0805045.05	Aflossingsverplichting (overboeking naar kortlopend) overige schulden aan kredietinstellingen (langlopend)	D	5	\N	t
2853	1	BLasSakWsl	805050	Hoofdsom schulden van kredietinstellingen geborgd door WSW (langlopend)	C	4	\N	t
2854	1	BLasSakWslBeg	0805050.01	Beginbalans (overname eindsaldo vorig jaar) schulden van kredietinstellingen geborgd door WSW 	C	5	\N	t
2855	1	BLasSakWslToe	0805050.03	Toename leningen van kredietinstellingen (langlopend)	C	5	\N	t
2856	1	BLasSakWslOvs	0805050.10	Bij overname verkregen schulden financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2857	1	BLasSakWslAvs	0805050.11	Bij afstoting vervreemde schulden financieringen van kredietinstellingen (langlopend)	D	5	\N	t
2858	1	BLasSakWslBir	0805050.08	Bijschrijving rente / oprenting financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2859	1	BLasSakWslOmv	0805050.06	Omrekeningsverschillen leningen van kredietinstellingen (langlopend)	C	5	\N	t
2860	1	BLasSakWslOvm	0805050.07	Overige mutaties leningen van kredietinstellingen (langlopend)	C	5	\N	t
2861	1	BLasSakWslOwv	0805050.12	Overige waardeveranderingen schulden van kredietinstellingen (langlopend)	C	5	\N	t
2862	1	BLasSakWslMvl	0805050.13	Marktwaardecorrectie van de vastrentende lening 	C	5	\N	t
2863	1	BLasSakWsa	805055	Cumulatieve aflossingen schulden van kredietinstellingen geborgd door WSW (langlopend)	D	4	\N	t
2864	1	BLasSakWsaBeg	0805055.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	D	5	\N	t
2865	1	BLasSakWsaAfl	0805055.04	Aflossingen in boekjaar leningen van kredietinstellingen geborgd door WSW (langlopend)	D	5	\N	t
2866	1	BLasSakWsaAvp	0805055.05	Aflossingsverplichting (overboeking naar kortlopend) schulden van kredietinstellingen geborgd door WSW (langlopend)	D	5	\N	t
2867	1	BLasSakWsaMvl	0805055.06	Aflossingsverplichting marktwaardecorrectie vastrentende lening  geborgd door WSW (langlopend)	D	5	\N	t
2868	1	BLasSakGol	805060	Hoofdsom schulden van kredietinstellingen gegarandeerd door overheden (langlopend)	C	4	\N	t
2869	1	BLasSakGolBeg	0805060.01	Beginbalans (overname eindsaldo vorig jaar) schulden van kredietinstellingen gegarandeerd door overheden	C	5	\N	t
2870	1	BLasSakGolToe	0805060.03	Toename leningen van kredietinstellingen (langlopend)	C	5	\N	t
2871	1	BLasSakGolOvs	0805060.10	Bij overname verkregen schulden financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2872	1	BLasSakGolAvs	0805060.11	Bij afstoting vervreemde schulden financieringen van kredietinstellingen (langlopend)	D	5	\N	t
2873	1	BLasSakGolBir	0805060.08	Bijschrijving rente / oprenting financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2874	1	BLasSakGolOmv	0805060.06	Omrekeningsverschillen leningen van kredietinstellingen (langlopend)	C	5	\N	t
2875	1	BLasSakGolOvm	0805060.07	Overige mutaties leningen van kredietinstellingen (langlopend)	C	5	\N	t
2876	1	BLasSakGolOwv	0805060.12	Overige waardeveranderingen schulden van kredietinstellingen (langlopend)	C	5	\N	t
2877	1	BLasSakGolMvl	0805060.13	Marktwaardecorrectie van de vastrentende lening 	C	5	\N	t
2878	1	BLasSakGoa	805065	Cumulatieve aflossingen leningen van kredietinstellingen gegarandeerd door overheden (langlopend)	D	4	\N	t
2879	1	BLasSakGoaBeg	0805065.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	D	5	\N	t
2880	1	BLasSakGoaAfl	0805065.04	Aflossingen in boekjaar leningen van kredietinstellingen  gegarandeerd door overheden (langlopend)	D	5	\N	t
2881	1	BLasSakGoaAvp	0805065.05	Aflossingsverplichting (overboeking naar kortlopend) schulden van kredietinstellingen gegarandeerd door overheden (langlopend)	D	5	\N	t
2882	1	BLasSakGoaMvl	0805065.06	Aflossingsverplichting marktwaardecorrectie vastrentende lening (langlopend)	D	5	\N	t
2883	1	BLasSakObl	805070	Hoofdsom obligolening van kredietinstellingen geborgd door WSW (langlopend)	C	4	\N	t
2884	1	BLasSakOblBeg	0805070.01	Beginbalans (overname eindsaldo vorig jaar) schulden van kredietinstellingen geborgd door WSW 	C	5	\N	t
2885	1	BLasSakOblToe	0805070.03	Toename leningen van kredietinstellingen (langlopend)	C	5	\N	t
2886	1	BLasSakOblOvs	0805070.10	Bij overname verkregen schulden financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2887	1	BLasSakOblAvs	0805070.11	Bij afstoting vervreemde schulden financieringen van kredietinstellingen (langlopend)	D	5	\N	t
2888	1	BLasSakOblBir	0805070.08	Bijschrijving rente / oprenting financieringen van kredietinstellingen (langlopend)	C	5	\N	t
2889	1	BLasSakOblOmv	0805070.06	Omrekeningsverschillen leningen van kredietinstellingen (langlopend)	C	5	\N	t
2890	1	BLasSakOblOvm	0805070.07	Overige mutaties leningen van kredietinstellingen (langlopend)	C	5	\N	t
2891	1	BLasSakOblOwv	0805070.12	Overige waardeveranderingen schulden van kredietinstellingen (langlopend)	C	5	\N	t
2892	1	BLasSakOblMvl	0805070.13	Marktwaardecorrectie van de vastrentende lening 	C	5	\N	t
2893	1	BLasSakOba	805075	Cumulatieve aflossingen obligolening van kredietinstellingen geborgd door WSW (langlopend)	D	4	\N	t
2894	1	BLasSakObaBeg	0805075.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	D	5	\N	t
2895	1	BLasSakObaAfl	0805075.04	Aflossingen in boekjaar leningen van kredietinstellingen geborgd door WSW (langlopend)	D	5	\N	t
2896	1	BLasSakObaAvp	0805075.05	Aflossingsverplichting (overboeking naar kortlopend) schulden van kredietinstellingen geborgd door WSW (langlopend)	D	5	\N	t
2897	1	BLasSakObaMvl	0805075.06	Aflossingsverplichting marktwaardecorrectie vastrentende lening  geborgd door WSW (langlopend)	D	5	\N	t
2898	1	BLasVob	806059	Ontvangen vooruitbetalingen op bestellingen (langlopend)	C	3	\N	t
2899	1	BLasVobVob	806060	Hoofdsom ontvangen vooruitbetalingen op bestellingen (langlopend)	C	4	\N	t
2900	1	BLasVobVobBeg	0806060.01	Beginbalans (overname eindsaldo vorig jaar) ontvangen vooruitbetalingen op bestellingen	C	5	\N	t
2901	1	BLasVobVobToe	0806060.02	Toename ontvangen vooruitbetalingen op bestellingen (langlopend)	C	5	\N	t
2902	1	BLasVobVobSto	0806060.05	Stortingen / ontvangsten	C	5	\N	t
2903	1	BLasVobVobBet	0806060.06	Betalingen	D	5	\N	t
2904	1	BLasVobVobBir	0806060.03	Bijschrijving rente / oprenting ontvangen vooruitbetalingen op bestellingen (langlopend)	C	5	\N	t
2905	1	BLasVobVobOwv	0806060.04	Overige waardeveranderingen ontvangen vooruitbetalingen op bestellingen (langlopend)	C	5	\N	t
2906	1	BLasVobVoc	806061	Cumulatieve aflossingen ontvangen vooruitbetalingen op bestellingen (langlopend)	D	4	\N	t
2907	1	BLasVobVocBeg	0806061.01	Beginbalans (overname eindsaldo vorig jaar) cumulatieve aflossingen vooruitbetalingen op bestellingen	D	5	\N	t
2908	1	BLasVobVocAfl	0806061.02	Afname in boekjaar vooruitbetalingen op bestellingen (langlopend)	D	5	\N	t
2909	1	BLasVobVocAvp	0806061.03	Afname (overboeking naar kortlopend) vooruitbetalingen op bestellingen	D	5	\N	t
2910	1	BLasSal	806069	Schulden aan leveranciers en handelskredieten (langlopend)	C	3	\N	t
2911	1	BLasSalSal	0806070	Hoofdsom schulden aan leveranciers en handelskredieten (langlopend)	C	4	\N	t
2912	1	BLasSalSalBeg	0806070.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan leveranciers en handelskredieten	C	5	\N	t
2913	1	BLasSalSalToe	0806070.02	Toename schulden aan leveranciers en handelskredieten (langlopend)	C	5	\N	t
2914	1	BLasSalSalBir	0806070.03	Bijschrijving rente / oprenting schulden aan leveranciers en handelskredieten (langlopend)	C	5	\N	t
2915	1	BLasSalSalOwv	0806070.04	Overige waardeveranderingen schulden aan leveranciers en handelskredieten (langlopend)	C	5	\N	t
2916	1	BLasSalSac	806071	Cumulatieve aflossingen schulden aan leveranciers en handelskredieten (langlopend)	D	4	\N	t
2917	1	BLasSalSacBeg	0806071.01	Aflossingen beginbalans (overname eindsaldo vorig jaar) schulden aan leveranciers en handelskredieten	D	5	\N	t
2918	1	BLasSalSacAfl	0806071.02	Afname in boekjaar schulden aan leveranciers en handelskredieten (langlopend)	D	5	\N	t
2919	1	BLasSalSacAvp	0806071.03	Afname (overboeking naar kortlopend) schulden aan leveranciers en handelskredieten	D	5	\N	t
2920	1	BLasTbw	806079	Te betalen wissels en cheques (langlopend)	C	3	\N	t
2921	1	BLasTbwTbw	0806080	Hoofdsom te betalen wissels en cheques (langlopend)	C	4	\N	t
2922	1	BLasTbwTbwBeg	0806080.01	Beginbalans (overname eindsaldo vorig jaar) te betalen wissels en cheques	C	5	\N	t
2923	1	BLasTbwTbwToe	0806080.02	Toename te betalen wissels en cheques (langlopend)	C	5	\N	t
2924	1	BLasTbwTbwSto	0806080.05	Stortingen / ontvangsten	C	5	\N	t
2925	1	BLasTbwTbwBet	0806080.06	Betalingen	D	5	\N	t
2926	1	BLasTbwTbwBir	0806080.03	Bijschrijving rente / oprenting te betalen wissels en cheques (langlopend)	C	5	\N	t
2927	1	BLasTbwTbwOwv	0806080.04	Overige waardeveranderingen te betalen wissels en cheques (langlopend)	C	5	\N	t
2928	1	BLasTbwTbc	806081	Cumulatieve aflossingen te betalen wissels en cheques (langlopend)	D	4	\N	t
2929	1	BLasTbwTbcBeg	0806081.01	Aflossingen beginbalans (overname eindsaldo vorig jaar) te betalen wissels en cheques	D	5	\N	t
2930	1	BLasTbwTbcAfl	0806081.02	Afname in boekjaar te betalen wissels en cheques (langlopend)	D	5	\N	t
2931	1	BLasTbwTbcAvp	0806081.03	Afname (overboeking naar kortlopend) te betalen wissels en cheques (langlopend)	D	5	\N	t
2932	1	BLasSag	806009	Schulden aan groepsmaatschappijen (langlopend)	C	3	\N	t
2933	1	BLasSagHoo	0806010	Hoofdsom schulden aan groepsmaatschappijen (langlopend)	C	4	\N	t
2934	1	BLasSagHooBeg	0806010.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan groepsmaatschappijen	C	5	\N	t
2935	1	BLasSagHooAao	0806010.03	Aanvullend opgenomen schulden aan groepsmaatschappijen	C	5	\N	t
2936	1	BLasSagHooSto	0806010.09	Stortingen / ontvangsten	C	5	\N	t
2937	1	BLasSagHooBet	0806010.10	Betalingen	D	5	\N	t
2938	1	BLasSagHooBir	0806010.08	Bijschrijving rente schulden aan groepsmaatschappijen	C	5	\N	t
2939	1	BLasSagHooOmr	0806010.06	Omrekeningsverschillen schulden aan groepsmaatschappijen	C	5	\N	t
2940	1	BLasSagHooOvm	0806010.07	Overige mutaties schulden aan groepsmaatschappijen	C	5	\N	t
2941	1	BLasSagAfl	806015	Aflossingen schulden aan groepsmaatschappijen (langlopend)	D	4	\N	t
2942	1	BLasSagAflBeg	0806015.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan groepsmaatschappijen	D	5	\N	t
2943	1	BLasSagAflAfl	0806015.02	Aflossingen schulden aan groepsmaatschappijen (langlopend)	D	5	\N	t
2944	1	BLasSagAflAvp	0806015.03	Aflossingsverplichting (overboeking naar kortlopend) schulden aan groepsmaatschappijen	D	5	\N	t
2945	1	BLasSagAflTer	0806015.04	Terugboekingen schulden aan groepsmaatschappijen	D	5	\N	t
2946	1	BLasSao	806019	Schulden aan overige verbonden maatschappijen (langlopend)	C	3	\N	t
2947	1	BLasSaoHoo	0806020	Hoofdsom schulden aan overige verbonden maatschappijen (langlopend)	C	4	\N	t
2948	1	BLasSaoHooBeg	0806020.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan overige verbonden maatschappijen	C	5	\N	t
2949	1	BLasSaoHooAao	0806020.03	Aanvullend opgenomen schulden aan overige verbonden maatschappijen	C	5	\N	t
2950	1	BLasSaoHooSto	0806020.09	Stortingen / ontvangsten	C	5	\N	t
2951	1	BLasSaoHooBet	0806020.10	Betalingen	D	5	\N	t
2952	1	BLasSaoHooBir	0806020.08	Bijschrijving rente schulden aan overige verbonden maatschappijen	C	5	\N	t
2953	1	BLasSaoHooOmr	0806020.06	Omrekeningsverschillen schulden aan overige verbonden maatschappijen	C	5	\N	t
2954	1	BLasSaoHooOvm	0806020.07	Overige mutaties schulden aan overige verbonden maatschappijen	D	5	\N	t
2955	1	BLasSaoAfl	806025	Aflossingen schulden aan overige verbonden maatschappijen (langlopend)	D	4	\N	t
2956	1	BLasSaoAflBeg	0806025.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan overige verbonden maatschappijen	D	5	\N	t
2957	1	BLasSaoAflAfl	0806020.04	Aflossingen schulden aan overige verbonden maatschappijen (langlopend)	C	5	\N	t
2958	1	BLasSaoAflAvp	0806025.03	Aflossingsverplichting (overboeking naar kortlopend) schulden aan overige verbonden maatschappijen	D	5	\N	t
2959	1	BLasSaoAflTer	0806025.04	Terugboekingen schulden aan overige verbonden maatschappijen	D	5	\N	t
2960	1	BLasSap	806029	Schulden aan participanten en aan maatschappijen waarin wordt deelgenomen (langlopend)	C	3	\N	t
2961	1	BLasSapHoo	0806030	Hoofdsom schulden aan participanten en aan maatschappijen waarin wordt deelgenomen (langlopend)	C	4	\N	t
2962	1	BLasSapHooBeg	0806030.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
2963	1	BLasSapHooAao	0806030.03	Aanvullend opgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
2964	1	BLasSapHooSto	0806030.09	Stortingen / ontvangsten	C	5	\N	t
2965	1	BLasSapHooBet	0806030.10	Betalingen	D	5	\N	t
2966	1	BLasSapHooBir	0806030.08	Bijschrijving rente schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
2967	1	BLasSapHooOmr	0806030.06	Omrekeningsverschillen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
2968	1	BLasSapHooOvm	0806030.07	Overige mutaties schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
2969	1	BLasSapAfl	806035	Aflossingen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen (langlopend)	D	4	\N	t
2970	1	BLasSapAflBeg	0806035.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	D	5	\N	t
2971	1	BLasSapAflAfl	0806030.04	Aflossingen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen (langlopend)	D	5	\N	t
2972	1	BLasSapAflAvp	0806035.03	Aflossingsverplichting (overboeking naar kortlopend) schulden aan participanten en aan maatschappijen waarin wordt deelgenomen (langlopend)	D	5	\N	t
2973	1	BLasSapAflTer	0806035.04	Terugboekingen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	D	5	\N	t
2974	1	BLasBep	806039	Belastingen en premies sociale verzekeringen (langlopend)	C	3	\N	t
2975	1	BLasBepBep	806040	Hoofdsom belastingen en premies sociale verzekeringen (langlopend)	C	4	\N	t
2976	1	BLasBepBepBeg	0806040.01	Beginbalans (overname eindsaldo vorig jaar) belastingen en premies sociale verzekeringen	C	5	\N	t
2977	1	BLasBepBepToe	0806040.02	Toename belastingen en premies sociale verzekeringen (langlopend)	C	5	\N	t
2978	1	BLasBepBepBir	0806040.03	Bijschrijving rente / oprenting belastingen en premies sociale verzekeringen (langlopend)	C	5	\N	t
2979	1	BLasBepBepOwv	0806040.04	Overige waardeveranderingen belastingen en premies sociale verzekeringen (langlopend)	C	5	\N	t
2980	1	BLasBepBec	806041	Cumulatieve aflossingen belastingen en premies sociale verzekeringen (langlopend)	D	4	\N	t
2981	1	BLasBepBecBeg	0806041.01	Aflossingen beginbalans (overname eindsaldo vorig jaar) belastingen en premies sociale verzekeringen	D	5	\N	t
2982	1	BLasBepBecAfl	0806041.02	Afname in boekjaar belastingen en premies sociale verzekeringen (langlopend)	D	5	\N	t
2983	1	BLasBepBecAvp	0806041.03	Afname (overboeking naar kortlopend) belastingen en premies sociale verzekeringen (langlopend)	D	5	\N	t
2984	1	BLasSuh	806044	Schulden uit hoofde van belastingen (langlopend)	C	3	\N	t
2985	1	BLasSuhSuh	806045	Hoofdsom schulden uit hoofde van belastingen (langlopend)	C	4	\N	t
2986	1	BLasSuhSuhBeg	0806045.01	Beginbalans (overname eindsaldo vorig jaar) schulden uit hoofde van belastingen	C	5	\N	t
2987	1	BLasSuhSuhToe	0806045.02	Toename schulden uit hoofde van belastingen (langlopend)	C	5	\N	t
2988	1	BLasSuhSuhBir	0806045.03	Bijschrijving rente / oprenting schulden uit hoofde van belastingen (langlopend)	C	5	\N	t
2989	1	BLasSuhSuhOwv	0806045.04	Overige waardeveranderingen schulden uit hoofde van belastingen (langlopend)	C	5	\N	t
2990	1	BLasSuhSuc	806046	Cumulatieve aflossingen schulden uit hoofde van belastingen (langlopend)	D	4	\N	t
2991	1	BLasSuhSucBeg	0806046.01	Beginbalans (overname eindsaldo vorig jaar) cumulatieve aflossing schulden uit hoofde van belastingen	D	5	\N	t
2992	1	BLasSuhSucAfl	0806046.02	Afname in boekjaar schulden uit hoofde van belastingen (langlopend)	D	5	\N	t
2993	1	BLasSuhSucAvp	0806046.03	Afname (overboeking naar kortlopend) schulden uit hoofde van belastingen (langlopend)	D	5	\N	t
2994	1	BLasStz	806049	Schulden ter zake van pensioenen (langlopend)	C	3	\N	t
2995	1	BLasStzStz	0806050	Hoofdsom schulden ter zake van pensioenen (langlopend)	C	4	\N	t
2996	1	BLasStzStzBeg	0806050.01	Beginbalans (overname eindsaldo vorig jaar) schulden ter zake van pensioenen (langlopend)	C	5	\N	t
2997	1	BLasStzStzToe	0806050.02	Toename schulden ter zake van pensioenen (langlopend)	C	5	\N	t
2998	1	BLasStzStzBir	0806050.03	Bijschrijving rente / oprenting schulden ter zake van pensioenen (langlopend)	C	5	\N	t
2999	1	BLasStzStzOwv	0806050.04	Overige waardeveranderingen schulden ter zake van pensioenen (langlopend)	C	5	\N	t
3000	1	BLasStzStc	806051	Cumulatieve aflossingen schulden ter zake van pensioenen (langlopend)	D	4	\N	t
3001	1	BLasStzStcBeg	0806051.01	Beginbalans (overname eindsaldo vorig jaar) cumulatieve aflossingen schulden pensioenen (langlopend)	D	5	\N	t
3002	1	BLasStzStcAfl	0806051.02	Afname in boekjaar schulden ter zake van pensioenen (langlopend)	D	5	\N	t
3003	1	BLasStzStcAvp	0806051.03	Afname (overboeking naar kortlopend) schulden ter zake van pensioenen (langlopend)	D	5	\N	t
3004	1	BLasNeg	0705000	Negatieve goodwill	C	3	\N	t
3005	1	BLasNegBrw	0705010	Bruto waarde 	C	4	\N	t
3006	1	BLasNegBrwBeg	0705010.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
3007	1	BLasNegBrwAao	0705010.02	Aanvullend opgenomen 	D	5	\N	t
3008	1	BLasNegBrwAag	0705010.03	Aanpassing als gevolg van later geïdentificeerde activa en passiva en veranderingen in de waarde ervan 	C	5	\N	t
3009	1	BLasNegBrwAga	0705010.04	Afboeking als gevolg van afstotingen 	C	5	\N	t
3010	1	BLasNegBrwOvm	0705010.08	Overige mutaties bruto waarde negatieve goodwill	C	5	\N	t
3011	1	BLasNegCbd	705015	Cumulatief bedrag die ten gunste van de winst- en verliesrekening is gebracht 	C	4	\N	t
3012	1	BLasNegCbdBeg	0705015.01	Beginbalans (overname eindsaldo vorig jaar) 	C	5	\N	t
3013	1	BLasNegCbdTgv	0705015.02	Ten gunste van winst- en verliesrekening gebracht 	C	5	\N	t
3014	1	BLasNegCbdVtg	0705015.03	Vrijval ten gunste van winst- en verliesrekening, geen betrekking op toekomstige resultaten 	C	5	\N	t
3015	1	BLasOdv	806148	Oudedagsverplichting	C	3	\N	t
3016	1	BLasOdvOdv	806149	Oudedagsverplichting	C	4	\N	t
3017	1	BLasOdvOdvBeg	0806149.01	Beginbalans (overname eindsaldo vorig jaar) oudedagsverplichting	C	5	\N	t
3018	1	BLasOdvOdvToe	0806149.03	Aanvullend opgenomen / nieuwe opbouw oudedagsverplichtingoudedagsverplichting	C	5	\N	t
3019	1	BLasOdvOdvSto	0806149.09	Stortingen / ontvangsten	C	5	\N	t
3020	1	BLasOdvOdvBet	0806149.10	Betalingen	D	5	\N	t
3021	1	BLasOdvOdvAvs	0806149.11	Uitbetaald / bij afstoting vervreemde schulden oudedagsverplichting	D	5	\N	t
3022	1	BLasOdvOdvBir	0806149.08	Bijschrijving rente / oprenting oudedagsverplichting	C	5	\N	t
3023	1	BLasOdvOdvAvp	0806149.12	Aflossingsverplichting (overboeking naar kortlopend) oudedagsverplichting	D	5	\N	t
3024	1	BLasOdvOdvOvm	0806149.07	Overige mutaties oudedagsverplichting	C	5	\N	t
3025	1	BLasPar	807000	Participaties (geclassificeerd als vreemd vermogen) (langlopend)	C	3	\N	t
3026	1	BLasParPar	807010	Hoofdsom participaties (langlopend)	C	4	\N	t
3027	1	BLasParParBeg	0807010.01	Beginbalans (overname eindsaldo vorig jaar) participaties	C	5	\N	t
3028	1	BLasParParToe	0807010.03	Aanvullend opgenomen participaties	C	5	\N	t
3029	1	BLasParParSto	0807010.13	Stortingen / ontvangsten	C	5	\N	t
3030	1	BLasParParBet	0807010.14	Betalingen	D	5	\N	t
3031	1	BLasParParOvs	0807010.10	Bij overname verkregen schulden participaties	C	5	\N	t
3032	1	BLasParParAvs	0807010.11	Bij afstoting vervreemde schulden participaties	D	5	\N	t
3033	1	BLasParParBir	0807010.08	Bijschrijving rente participaties	C	5	\N	t
3034	1	BLasParParOmv	0807010.06	Omrekeningsverschillen participaties	C	5	\N	t
3035	1	BLasParParOvm	0807010.07	Overige mutaties participaties	C	5	\N	t
3036	1	BLasParParOwv	0807010.12	Overige waardeveranderingen participaties	C	5	\N	t
3037	1	BLasParCla	807020	Cumulatieve aflossingen participaties (langlopend)	D	4	\N	t
3038	1	BLasParClaBeg	0807020.01	Aflossingen beginbalans (overname eindsaldo vorig jaar) participaties	D	5	\N	t
3039	1	BLasParClaAfl	0807020.02	Aflossingen in boekjaar participaties (langlopend)	D	5	\N	t
3040	1	BLasParClaAvp	0807020.05	Aflossingsverplichting (overboeking naar kortlopend) participaties (langlopend)	D	5	\N	t
3041	1	BLasSoh	806119	Schulden aan overheid (langlopend)	C	3	\N	t
3042	1	BLasSohSoh	0806120	Hoofdsom schulden aan overheid (langlopend)	C	4	\N	t
3043	1	BLasSohSohBeg	0806120.01	Beginbalans (overname eindsaldo vorig jaar) schulden van overheid	C	5	\N	t
3044	1	BLasSohSohToe	0806120.02	Toename leningen schulden van overheid (langlopend)	C	5	\N	t
3045	1	BLasSohSohOvs	0806120.03	Bij overname verkregen schulden aan overheid (langlopend)	C	5	\N	t
3046	1	BLasSohSohAvs	0806120.04	Bij afstoting vervreemde schulden van overheid (langlopend)	D	5	\N	t
3047	1	BLasSohSohSto	0806120.09	Stortingen / ontvangsten	C	5	\N	t
3048	1	BLasSohSohBet	0806120.10	Betalingen	D	5	\N	t
3049	1	BLasSohSohBir	0806120.05	Bijschrijving rente / oprenting schulden van overheid (langlopend)	C	5	\N	t
3050	1	BLasSohSohOmv	0806120.06	Omrekeningsverschillen schulden van overheid (langlopend)	C	5	\N	t
3051	1	BLasSohSohOvm	0806120.07	Overige mutaties schulden van overheid (langlopend)	C	5	\N	t
3052	1	BLasSohSohOwv	0806120.08	Overige waardeveranderingen schulden van overheid (langlopend)	C	5	\N	t
3053	1	BLasSohAso	806125	Cumulatieve aflossingen schulden aan overheid (langlopend)	D	4	\N	t
3054	1	BLasSohAsoBeg	0806125.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	D	5	\N	t
3055	1	BLasSohAsoAfl	0806125.02	Aflossingen in boekjaar leningen van overheid (langlopend)	D	5	\N	t
3056	1	BLasSohAsoAvp	0806125.03	Aflossingsverplichting (overboeking naar kortlopend) schulden van overheid (langlopend)	D	5	\N	t
3057	1	BLasSohWsw	806150	Hoofdsom schulden aan overheid geborgd door WSW (langlopend)	C	4	\N	t
3058	1	BLasSohWswBeg	0806150.01	Beginbalans (overname eindsaldo vorig jaar) schulden van overheid geborgd door WSW 	C	5	\N	t
3059	1	BLasSohWswToe	0806150.02	Toename leningen van overheid (langlopend)	C	5	\N	t
3060	1	BLasSohWswOvs	0806150.03	Bij overname verkregen leningen van overheid (langlopend)	C	5	\N	t
3061	1	BLasSohWswAvs	0806150.04	Bij afstoting vervreemde leningen van overheid (langlopend)	D	5	\N	t
3062	1	BLasSohWswSto	0806150.09	Stortingen / ontvangsten	C	5	\N	t
3063	1	BLasSohWswBet	0806150.10	Betalingen	D	5	\N	t
3064	1	BLasSohWswBir	0806150.05	Bijschrijving rente / oprenting leningen van overheid (langlopend)	C	5	\N	t
3065	1	BLasSohWswOmv	0806150.06	Omrekeningsverschillen leningen van overheid (langlopend)	C	5	\N	t
3066	1	BLasSohWswOvm	0806150.07	Overige mutaties leningen van overheid (langlopend)	C	5	\N	t
3067	1	BLasSohWswOwv	0806150.08	Overige waardeveranderingen leningen van overheid (langlopend)	C	5	\N	t
3068	1	BLasSohAws	806155	Cumulatieve aflossingen schulden aan overheid geborgd door WSW (langlopend)	D	4	\N	t
3069	1	BLasSohAwsBeg	0806155.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	D	5	\N	t
3070	1	BLasSohAwsAfl	0806155.02	Aflossingen in boekjaar leningen van overheid geborgd door WSW (langlopend)	D	5	\N	t
3071	1	BLasSohAwsAvp	0806155.03	Aflossingsverplichting (overboeking naar kortlopend) leningen van overheid geborgd door WSW (langlopend)	D	5	\N	t
3072	1	BLasSohGos	806160	Hoofdsom schulden aan overheid gegarandeerd door overheid (langlopend)	C	4	\N	t
3073	1	BLasSohGosBeg	0806160.01	Beginbalans (overname eindsaldo vorig jaar) schulden van overheid gegarandeerd door overheden	C	5	\N	t
3074	1	BLasSohGosToe	0806160.02	Toename leningen van overheid (langlopend)	C	5	\N	t
3075	1	BLasSohGosOvs	0806160.03	Bij overname verkregen schulden van overheid (langlopend)	C	5	\N	t
3076	1	BLasSohGosAvs	0806160.04	Bij afstoting vervreemde schulden van overheid (langlopend)	D	5	\N	t
3077	1	BLasSohGosBir	0806160.05	Bijschrijving rente / oprenting financieringen van overheid (langlopend)	C	5	\N	t
3078	1	BLasSohGosOmv	0806160.06	Omrekeningsverschillen leningen van overheid (langlopend)	C	5	\N	t
3079	1	BLasSohGosOvm	0806160.07	Overige mutaties leningen van overheid (langlopend)	C	5	\N	t
3080	1	BLasSohGosOwv	0806160.08	Overige waardeveranderingen leningen van overheid (langlopend)	C	5	\N	t
3081	1	BLasSohGoa	806165	Cumulatieve aflossingen schulden aan overheid gegarandeerd door overheid (langlopend)	D	4	\N	t
3082	1	BLasSohGoaBeg	0806165.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	D	5	\N	t
3083	1	BLasSohGoaAfl	0806165.02	Aflossingen in boekjaar leningen gegarandeerd door overheid (langlopend)	D	5	\N	t
3084	1	BLasSohGoaAvp	0806165.03	Aflossingsverplichting (overboeking naar kortlopend) gegarandeerd door overheid (langlopend)	D	5	\N	t
3085	1	BLasVhz	806109	Verplichtingen uit hoofde van onroerende zaken verkocht onder voorwaarden (langlopend)	C	3	\N	t
3086	1	BLasVhzVhz	0806110	Verplichtingen uit hoofde van onroerende zaken verkocht onder voorwaarden (langlopend)	C	4	\N	t
3087	1	BLasVhzVhzBeg	0806110.01	Beginbalans (overname eindsaldo vorig jaar) verplichtingen uit hoofde van onroerende zaken verkocht ondervoorwaarden (langlopend)	C	5	\N	t
3088	1	BLasVhzVhzAan	0806110.02	Aankoop verplichtingen uit hoofde van onroerende zaken verkocht onder voorwaarden (langlopend)	C	5	\N	t
3089	1	BLasVhzVhzVer	0806110.03	Verkoop verplichtingen uit hoofde van onroerende zaken verkocht onder voorwaarden (langlopend)	D	5	\N	t
3090	1	BLasVhzVhzWaa	0806110.04	Waardestijging verplichtingen uit hoofde van onroerende zaken verkocht onder voorwaarden (langlopend)	C	5	\N	t
3091	1	BLasVhzVhzAfw	0806110.05	Afwaardering verplichtingen uit hoofde van onroerende zaken verekocht onder voorwaarden	D	5	\N	t
3092	1	BLasVhzVhzOve	0806110.06	Overige mutaties verplichtingen uit hoofde van onroerende zaken verkocht onder voorwaarden (langlopend)	C	5	\N	t
3093	1	BLasOls	806129	Overige schulden (Langlopend)	C	3	\N	t
3094	1	BLasOlsOsl	0806130	Hoofdsom overige schulden (langlopend)	C	4	\N	t
3095	1	BLasOlsOslBeg	0806130.01	Beginbalans (overname eindsaldo vorig jaar) schulden 	C	5	\N	t
3096	1	BLasOlsOslToe	0806130.03	Aanvullend opgenomen overige schulden	C	5	\N	t
3097	1	BLasOlsOslSto	0806130.09	Stortingen / ontvangsten	C	5	\N	t
3098	1	BLasOlsOslBet	0806130.10	Betalingen	D	5	\N	t
3099	1	BLasOlsOslOvm	0806130.06	Overige mutaties overige schulden (langlopend)	C	5	\N	t
3100	1	BLasOlsAfl	806135	Cumulatieve aflossingen overige schulden (langlopend)	D	4	\N	t
3101	1	BLasOlsAflBeg	0806135.01	Beginbalans (overname eindsaldo vorig jaar) schulden 	D	5	\N	t
3102	1	BLasOlsAflAfl	0806135.04	Aflossingen overige schulden (langlopend)	D	5	\N	t
3103	1	BLasOlsAflAvp	0806135.05	Aflossingsverplichting (overboeking naar kortlopend) overige schulden	D	5	\N	t
3104	1	BLasOlsIlg	806133	Hoodsom intern lening (Langlopend)	C	4	\N	t
3105	1	BLasOlsIlgBeg	0806133.01	Beginbalans (overname eindsaldo vorig jaar) intern lening	C	5	\N	t
3106	1	BLasOlsIlgToe	0806133.03	Aanvullend opgenomen intern lening	C	5	\N	t
3107	1	BLasOlsIlgSto	0806133.09	Stortingen / ontvangsten	C	5	\N	t
3108	1	BLasOlsIlgBet	0806133.10	Betalingen	D	5	\N	t
3109	1	BLasOlsIlgOvm	0806133.06	Overige mutaties intern lening (langlopend)	C	5	\N	t
3110	1	BLasOlsIla	806134	Aflossingen intern lening (Langlopend)	D	4	\N	t
3111	1	BLasOlsIlaBeg	0806134.01	Beginbalans (overname eindsaldo vorig jaar) intern lening	D	5	\N	t
3112	1	BLasOlsIlaAfl	0806134.04	Aflossingen intern lening (Langlopend)	D	5	\N	t
3113	1	BLasOlsIlaAvp	0806134.05	Aflossingsverplichting (overboeking naar kortlopend)  intern lening	D	5	\N	t
3114	1	BLasOlsWbs	806137	Hoofdsom waarborgsommen (Langlopend)	C	4	\N	t
3115	1	BLasOlsWbsBeg	0806137.01	Beginbalans (overname eindsaldo vorig jaar) waarborgsommen	C	5	\N	t
3116	1	BLasOlsWbsToe	0806137.03	Aanvullend opgenomen waarborgsommen	C	5	\N	t
3117	1	BLasOlsWbsOvm	0806137.06	Overige mutaties waarborgsommen (langlopend)	C	5	\N	t
3118	1	BLasOlsWba	806138	Aflossingen waarborgsommen (langlopend)	D	4	\N	t
3119	1	BLasOlsWbaBeg	0806138.01	Beginbalans (overname eindsaldo vorig jaar) aflossingen waarborgsommen	D	5	\N	t
3120	1	BLasOlsWbaAfl	0806138.04	Aflossingen waarborgsommen (langlopend)	D	5	\N	t
3121	1	BLasOlsWbaAvp	0806138.05	Aflossingsverplichting (overboeking naar kortlopend) waarborgsommen	D	5	\N	t
3122	1	BLasOlsDer	806140	Hoofdsom derivaten (Langlopend)	C	4	\N	t
3123	1	BLasOlsDerBeg	0806140.01	Beginbalans (overname eindsaldo vorig jaar) derivaten	C	5	\N	t
3124	1	BLasOlsDerToe	0806140.03	Aanvullend opgenomen derivaten	C	5	\N	t
3125	1	BLasOlsDerOvm	0806140.06	Overige mutaties derivaten (langlopend)	C	5	\N	t
3126	1	BLasOlsDea	806141	Aflossingen derivaten (Langlopend)	D	4	\N	t
3127	1	BLasOlsDeaBeg	0806141.01	Beginbalans (overname eindsaldo vorig jaar) derivaten	D	5	\N	t
3128	1	BLasOlsDeaAfl	0806141.04	Aflossingen derivaten (langlopend)	D	5	\N	t
3129	1	BLasOlsDeaAvp	0806141.05	Aflossingsverplichting (overboeking naar kortlopend) derivaten	D	5	\N	t
3130	1	BLasOvp	806170	Overlopende passiva (Langlopend)	C	3	\N	t
3131	1	BLasOvpOvp	806171	Hoofdsom overlopende passiva (langlopend)	C	4	\N	t
3132	1	BLasOvpOvpBeg	0806171.01	Beginbalans (overname eindsaldo vorig jaar) overlopende passiva	C	5	\N	t
3133	1	BLasOvpOvpToe	0806171.03	Aanvullend opgenomen overlopende passiva	C	5	\N	t
3134	1	BLasOvpOvpSto	0806171.09	Stortingen / ontvangsten	C	5	\N	t
3135	1	BLasOvpOvpBet	0806171.10	Betalingen	D	5	\N	t
3136	1	BLasOvpOvpOvm	0806171.06	Overige mutaties overlopende passiva (langlopend)	C	5	\N	t
3137	1	BLasOvpOva	806172	Aflossingen overlopende passiva (langlopend)	D	4	\N	t
3138	1	BLasOvpOvaBeg	0806172.01	Beginbalans (overname eindsaldo vorig jaar) cumulatieve aflossing overlopende passiva	D	5	\N	t
3139	1	BLasOvpOvaAfl	0806172.04	Aflossingen overlopende passiva (langlopend)	D	5	\N	t
3140	1	BLasOvpOvaAvp	0806172.05	Aflossingsverplichting (overboeking naar kortlopend) overlopende passiva	D	5	\N	t
3141	1	BSch	12	Kortlopende schulden	C	2	\N	t
3142	1	BSchKol	1201000	Kortlopende leningen-schulden-verplichtingen	C	3	\N	t
3143	1	BSchKolAlk	1201010	Achtergestelde schulden	C	4	\N	t
3144	1	BSchKolClk	1201020	Converteerbare leningen	C	4	\N	t
3145	1	BSchKolAok	1201030	Obligatieleningen, pandbrieven en andere leningen	C	4	\N	t
3146	1	BSchKolAov	1201040	Aangegane verplichtingen overig	C	4	\N	t
3147	1	BSchKolDer	1201050	Derivaten	C	4	\N	t
3148	1	BSchKolDerNmd	1201050.01	Negatieve marktwaarde derivaten	C	5	\N	t
3149	1	BSchKolDerNed	1201050.02	Negatieve marktwaarde embedded derivaten	C	5	\N	t
3150	1	BSchSoh	1211000	Schulden aan overheid (kortlopend)	C	3	\N	t
3151	1	BSchSohSoh	1211100	Schulden aan overheid (kortlopend)	C	4	\N	t
3152	1	BSchOdv	1211200	Kortlopende schulden inzake oudedagsverplichting	C	3	\N	t
3153	1	BSchOdvKlo	1211210	Kortlopende schulden inzake oudedagsverplichting	C	4	\N	t
3154	1	BSchSak	1209029	Schulden aan banken	C	3	\N	t
3155	1	BSchSakRba	1209030	Rekening-courant bij kredietinstellingen schulden aan kredietinstellingen	C	4	\N	t
3156	1	BSchSakRbaBg1	1209030.01	Rekening-courant bank groep 1	C	5	\N	t
3157	1	BSchSakRbaBg2	1209030.02	Rekening-courant bank groep 2	C	5	\N	t
3158	1	BSchSakRbaBg3	1209030.03	Rekening-courant bank groep 3	C	5	\N	t
3159	1	BSchSakRbaBg4	1209030.04	Rekening-courant bank groep 4	C	5	\N	t
3160	1	BSchSakRbaBg5	1209030.05	Rekening-courant bank groep 5	C	5	\N	t
3161	1	BSchSakRbaBg6	1209030.06	Rekening-courant bank groep 6	C	5	\N	t
3162	1	BSchSakRbaBg7	1209030.07	Rekening-courant bank groep 7	C	5	\N	t
3163	1	BSchSakRbaBg8	1209030.08	Rekening-courant bank groep 8	C	5	\N	t
3164	1	BSchSakRbaBg9	1209030.09	Rekening-courant bank groep 9	C	5	\N	t
3165	1	BSchSakRbaBg10	1209030.10	Rekening-courant bank groep 10	C	5	\N	t
3166	1	BSchSakRbb	1209031	Rekening-courant bij kredietinstellingen - Naam A - schulden aan kredietinstellingen	C	4	\N	t
3167	1	BSchSakRbc	1209032	Rekening-courant bij kredietinstellingen - Naam B - schulden aan kredietinstellingen	C	4	\N	t
3168	1	BSchSakRbd	1209033	Rekening-courant bij kredietinstellingen - Naam C - schulden aan kredietinstellingen	C	4	\N	t
3169	1	BSchSakRbe	1209034	Rekening-courant bij kredietinstellingen - Naam D - schulden aan kredietinstellingen	C	4	\N	t
3170	1	BSchSakRbf	1209035	Rekening-courant bij kredietinstellingen - Naam E - schulden aan kredietinstellingen	C	4	\N	t
3171	1	BSchVob	1209040	Ontvangen vooruitbetalingen op bestellingen	C	3	\N	t
3172	1	BSchVobVgf	1209041	Vooruitgezonden facturen ontvangen vooruitbetalingen op bestellingen	C	4	\N	t
3173	1	BSchVobVob	1209042	Ontvangen vooruitbetalingen op bestellingen ontvangen vooruitbetalingen op bestellingen	C	4	\N	t
3174	1	BSchCre	1203000	Schulden aan leveranciers en handelskredieten	C	3	\N	t
3175	1	BSchCreHac	1203010	Handelscrediteuren nominaal schulden aan leveranciers en handelskredieten	C	4	\N	t
3176	1	BSchCreHci	1203020	Handelscrediteuren intercompany	C	4	\N	t
3177	1	BSchCreVbk	1203030	Ontvangen vooruitbetalingen op bestellingen	C	4	\N	t
3179	1	BSchCreTus	1203050	Tussenrekening betalingen crediteuren (betalingen onderweg)	C	4	\N	t
3180	1	BSchCreTtf	1203060	Tussenrekening te fiatteren facturen	C	4	\N	t
3181	1	BSchTbw	1209079	Te betalen wissels en cheques	C	3	\N	t
3182	1	BSchTbwAvp	1209081	Aflossingsverplichtingen te betalen wissels en cheques	C	4	\N	t
3183	1	BSchTbwTbr	1209082	Te betalen rente te betalen wissels en cheques	C	4	\N	t
3184	1	BSchTbwOvs	1209080	Overige schulden te betalen wissels en cheques	C	4	\N	t
3185	1	BSchSag	1208100	Schulden aan groepsmaatschappijen	C	3	\N	t
3186	1	BSchSagSg1	1208110	Schuld aan groepsmaatschappij 1	C	4	\N	t
3187	1	BSchSagSg1Klg	1208110.01	Kortlopend deel van langlopende schulden aan groepsmaatschappijen schulden aan groepsmaatschappijen	C	5	\N	t
3188	1	BSchSagSg1Tbr	1208110.02	Te betalen rente schulden aan groepsmaatschappijen	C	5	\N	t
3189	1	BSchSagSg1Rbg	1208110.03	Rekening-courant bij groepsmaatschappijen schulden aan groepsmaatschappijen	C	5	\N	t
3190	1	BSchSagSg2	1208120	Schuld aan groepsmaatschappij 2	C	4	\N	t
3191	1	BSchSagSg2Klg	1208120.01	Kortlopend deel van langlopende schulden aan groepsmaatschappijen schulden aan groepsmaatschappijen	C	5	\N	t
3192	1	BSchSagSg2Tbr	1208120.02	Te betalen rente schulden aan groepsmaatschappijen	C	5	\N	t
3193	1	BSchSagSg2Rbg	1208120.03	Rekening-courant bij groepsmaatschappijen schulden aan groepsmaatschappijen	C	5	\N	t
3194	1	BSchSagSg3	1208130	Schuld aan groepsmaatschappij 3	C	4	\N	t
3195	1	BSchSagSg3Klg	1208130.01	Kortlopend deel van langlopende schulden aan groepsmaatschappijen schulden aan groepsmaatschappijen	C	5	\N	t
3196	1	BSchSagSg3Tbr	1208130.02	Te betalen rente schulden aan groepsmaatschappijen	C	5	\N	t
3197	1	BSchSagSg3Rbg	1208130.03	Rekening-courant bij groepsmaatschappijen schulden aan groepsmaatschappijen	C	5	\N	t
3198	1	BSchSagSg4	1208140	Schuld aan groepsmaatschappij 4	C	4	\N	t
3199	1	BSchSagSg4Klg	1208140.01	Kortlopend deel van langlopende schulden aan groepsmaatschappijen schulden aan groepsmaatschappijen	C	5	\N	t
3200	1	BSchSagSg4Tbr	1208140.02	Te betalen rente schulden aan groepsmaatschappijen	C	5	\N	t
3201	1	BSchSagSg4Rbg	1208140.03	Rekening-courant bij groepsmaatschappijen schulden aan groepsmaatschappijen	C	5	\N	t
3202	1	BSchSagSg5	1208150	Schuld aan groepsmaatschappij 5	C	4	\N	t
3203	1	BSchSagSg5Klg	1208150.01	Kortlopend deel van langlopende schulden aan groepsmaatschappijen schulden aan groepsmaatschappijen	C	5	\N	t
3204	1	BSchSagSg5Tbr	1208150.02	Te betalen rente schulden aan groepsmaatschappijen	C	5	\N	t
3205	1	BSchSagSg5Rbg	1208150.03	Rekening-courant bij groepsmaatschappijen schulden aan groepsmaatschappijen	C	5	\N	t
3206	1	BSchSagDae	1208160	Schuld aan DAEB	C	4	\N	t
3207	1	BSchSagDaeKlg	1208160.01	Kortlopend deel van langlopende schulden aan DAEB	C	5	\N	t
3208	1	BSchSagDaeTbr	1208160.02	Te betalen rente	C	5	\N	t
3209	1	BSchSagDaeRbg	1208160.03	Rekening-courant bij DAEB	C	5	\N	t
3210	1	BSchSagNda	1208170	Schuld aan Niet-DAEB	C	4	\N	t
3211	1	BSchSagNdaKlg	1208170.01	Kortlopend deel van langlopende schulden aan Niet-DAEB	C	5	\N	t
3212	1	BSchSagNdaTbr	1208170.02	Te betalen rente	C	5	\N	t
3213	1	BSchSagNdaRbg	1208170.03	Rekening-courant bij Niet-DAEB	C	5	\N	t
3214	1	BSchSao	1208200	Schulden aan overige verbonden maatschappijen	C	3	\N	t
3215	1	BSchSaoSo1	1208210	Schuld aan overige verbonden maatschappij 1	C	4	\N	t
3216	1	BSchSaoSo1Klo	1208210.01	Kortlopend deel van langlopende schulden aan overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	C	5	\N	t
3217	1	BSchSaoSo1Tbr	1208210.02	Te betalen rente schulden aan overige verbonden maatschappijen	C	5	\N	t
3218	1	BSchSaoSo1Rbo	1208210.03	Rekening-courant bij overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	C	5	\N	t
3219	1	BSchSaoSo2	1208220	Schuld aan overige verbonden maatschappij 2	C	4	\N	t
3220	1	BSchSaoSo2Klo	1208220.01	Kortlopend deel van langlopende schulden aan overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	C	5	\N	t
3221	1	BSchSaoSo2Tbr	1208220.02	Te betalen rente schulden aan overige verbonden maatschappijen	C	5	\N	t
3222	1	BSchSaoSo2Rbo	1208220.03	Rekening-courant bij overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	C	5	\N	t
3223	1	BSchSaoSo3	1208230	Schuld aan overige verbonden maatschappij 3	C	4	\N	t
3224	1	BSchSaoSo3Klo	1208230.01	Kortlopend deel van langlopende schulden aan overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	C	5	\N	t
3225	1	BSchSaoSo3Tbr	1208230.02	Te betalen rente schulden aan overige verbonden maatschappijen	C	5	\N	t
3226	1	BSchSaoSo3Rbo	1208230.03	Rekening-courant bij overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	C	5	\N	t
3227	1	BSchSaoSo4	1208240	Schuld aan overige verbonden maatschappij 4	C	4	\N	t
3228	1	BSchSaoSo4Klo	1208240.01	Kortlopend deel van langlopende schulden aan overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	C	5	\N	t
3229	1	BSchSaoSo4Tbr	1208240.02	Te betalen rente schulden aan overige verbonden maatschappijen	C	5	\N	t
3230	1	BSchSaoSo4Rbo	1208240.03	Rekening-courant bij overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	C	5	\N	t
3231	1	BSchSaoSo5	1208250	Schuld aan overige verbonden maatschappij 5	C	4	\N	t
3232	1	BSchSaoSo5Klo	1208250.01	Kortlopend deel van langlopende schulden aan overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	C	5	\N	t
3233	1	BSchSaoSo5Tbr	1208250.02	Te betalen rente schulden aan overige verbonden maatschappijen	C	5	\N	t
3234	1	BSchSaoSo5Rbo	1208250.03	Rekening-courant bij overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	C	5	\N	t
3235	1	BSchSap	1208300	Schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	3	\N	t
3236	1	BSchSapSp1	1208310	Schulden aan participant en aan maatschappij waarin wordt deelgenomen 1	C	4	\N	t
3237	1	BSchSapSp1Klp	1208310.01	Kortlopend deel van langlopende schulden aan participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3238	1	BSchSapSp1Tbr	1208310.02	Te betalen rente schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3239	1	BSchSapSp1Rbp	1208310.03	Rekening-courant bij participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3240	1	BSchSapSp2	1208320	Schulden aan participant en aan maatschappij waarin wordt deelgenomen 2	C	4	\N	t
3241	1	BSchSapSp2Klp	1208320.01	Kortlopend deel van langlopende schulden aan participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3242	1	BSchSapSp2Tbr	1208320.02	Te betalen rente schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3243	1	BSchSapSp2Rbp	1208320.03	Rekening-courant bij participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3244	1	BSchSapSp3	1208330	Schulden aan participant en aan maatschappij waarin wordt deelgenomen 3	C	4	\N	t
3245	1	BSchSapSp3Klp	1208330.01	Kortlopend deel van langlopende schulden aan participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3246	1	BSchSapSp3Tbr	1208330.02	Te betalen rente schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3247	1	BSchSapSp3Rbp	1208330.03	Rekening-courant bij participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3248	1	BSchSapSp4	1208340	Schulden aan participant en aan maatschappij waarin wordt deelgenomen 4	C	4	\N	t
3249	1	BSchSapSp4Klp	1208340.01	Kortlopend deel van langlopende schulden aan participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3250	1	BSchSapSp4Tbr	1208340.02	Te betalen rente schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3251	1	BSchSapSp4Rbp	1208340.03	Rekening-courant bij participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3252	1	BSchSapSp5	1208350	Schulden aan participant en aan maatschappij waarin wordt deelgenomen 5	C	4	\N	t
3253	1	BSchSapSp5Klp	1208350.01	Kortlopend deel van langlopende schulden aan participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3254	1	BSchSapSp5Tbr	1208350.02	Te betalen rente schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3255	1	BSchSapSp5Rbp	1208350.03	Rekening-courant bij participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	C	5	\N	t
3256	1	BSchShb	1208400	Schulden uit hoofde van belasting naar de winst	C	3	\N	t
3257	1	BSchShbShb	1208410	Schulden uit hoofde van belasting naar de winst	C	4	\N	t
3258	1	BSchFlk	1208500	Kortlopende financiële lease verplichtingen	C	3	\N	t
3259	1	BSchFlkFlk	1208510	Financiële lease verplichtingen	C	4	\N	t
3260	1	BSchBep	1205009	Belastingen en premies sociale verzekeringen	C	3	\N	t
3261	1	BSchBepBtw	1205010	Te betalen Omzetbelasting	C	4	\N	t
3262	1	BSchBepBtwBeg	1205010.01	Beginbalans af te dragen omzetbelasting	C	5	\N	t
3263	1	BSchBepBtwOla	1205010.02	Omzetbelasting leveringen/diensten algemeen tarief 	C	5	\N	t
3264	1	BSchBepBtwOlv	1205010.03	Omzetbelasting leveringen/diensten verlaagd tarief 	C	5	\N	t
3265	1	BSchBepBtwOlt	1205010.16	Omzetbelasting leveringen/diensten verlaagd tarief 9%	C	5	\N	t
3266	1	BSchBepBtwOlo	1205010.04	Omzetbelasting leveringen/diensten overige tarieven 	C	5	\N	t
3267	1	BSchBepBtwOop	1205010.05	Omzetbelasting over privégebruik 	C	5	\N	t
3268	1	BSchBepBtwOlw	1205010.06	Omzetbelasting leveringen/diensten waarbij heffing is verlegd 	C	5	\N	t
3269	1	BSchBepBtwOlb	1205010.07	Omzetbelasting leveringen/diensten uit landen buiten de EU 	C	5	\N	t
3270	1	BSchBepBtwOlu	1205010.08	Omzetbelasting leveringen/diensten uit landen binnen EU 	C	5	\N	t
3271	1	BSchBepBtwVoo	1205010.09	Voorbelasting 	D	5	\N	t
3272	1	BSchBepBtwVvd	1205010.10	Vermindering volgens de kleineondernemersregeling 	D	5	\N	t
3273	1	BSchBepBtwSva	1205010.11	Schatting vorige aangifte(n) 	C	5	\N	t
3274	1	BSchBepBtwSda	1205010.12	Schatting deze aangifte 	C	5	\N	t
3275	1	BSchBepBtwAfo	1205010.13	Afgedragen omzetbelasting 	D	5	\N	t
3276	1	BSchBepBtwNah	1205010.14	Naheffingsaanslagen omzetbelasting	C	5	\N	t
3277	1	BSchBepBtwOvm	1205010.15	Overige mutaties omzetbelasting	C	5	\N	t
3278	1	BSchBepBla	1205020	1a Omzetbelasting leveringen/diensten algemeen tarief	C	4	\N	t
3279	1	BSchBepBlv	1205021	1b Omzetbelasting leveringen/diensten verlaagd tarief	C	4	\N	t
3280	1	BSchBepBlo	1205022	1c Omzetbelasting leveringen/diensten overige tarieven	C	4	\N	t
3281	1	BSchBepBop	1205023	1d Omzetbelasting over privegebruik	C	4	\N	t
3282	1	BSchBepBlw	1205024	2a Omzetbelasting leveringen/diensten waarbij heffing is verlegd	C	4	\N	t
3283	1	BSchBepBlb	1205025	4a Omzetbelasting leveringen/diensten uit landen buiten de EU	C	4	\N	t
3284	1	BSchBepBlu	1205026	4b Omzetbelasting leveringen/diensten uit landen binnen EU	C	4	\N	t
3285	1	BSchBepBoo	1205027	5b Voorbelasting 	D	4	\N	t
3286	1	BSchBepEob	1205030	Te betalen EU omzetbelasting	C	4	\N	t
3287	1	BSchBepBaf	1205040	Omzetbelasting afdracht	D	4	\N	t
3288	1	BSchBepLhe	1206010	Te betalen Loonheffing belastingen en premies sociale verzekeringen	C	4	\N	t
3289	1	BSchBepLheBeg	1206010.01	Beginbalans af te dragen loonheffing 	C	5	\N	t
3290	1	BSchBepLheAal	1206010.02	Aangifte loonheffing 	C	5	\N	t
3291	1	BSchBepLheAlh	1206010.03	Afgedragen Loonheffing 	D	5	\N	t
3292	1	BSchBepLheNah	1206010.04	Naheffingsaanslagen loonheffing	C	5	\N	t
3293	1	BSchBepLheOvm	1206010.05	Overige mutaties loonheffing	C	5	\N	t
3294	1	BSchBepVpb	1207010	Te betalen vennootschapsbelasting	C	4	\N	t
3295	1	BSchBepVpbBeg	1207010.01	Beginbalans af te dragen vennootschapsbelasting	C	5	\N	t
3296	1	BSchBepVpbAav	1207010.02	Aangifte vennootschapsbelasting 	C	5	\N	t
3297	1	BSchBepVpbAgv	1207010.03	Voorlopige aanslag vennootschapsbelasting huidig boekjaar	C	5	\N	t
3298	1	BSchBepVpbVav	1207010.08	Voorlopige aanslag vennootschapsbelasting voorgaande boekjaren	C	5	\N	t
3299	1	BSchBepVpbTvv	1207010.04	Te verrekenen vennootschapsbelasting 	D	5	\N	t
3300	1	BSchBepVpbAfv	1207010.05	Afgedragen vennootschapsbelasting 	D	5	\N	t
3301	1	BSchBepVpbNah	1207010.06	Naheffingsaanslagen vennootschapsbelasting	C	5	\N	t
3302	1	BSchBepVpbOvm	1207010.07	Overige mutaties vennootschapsbelasting	C	5	\N	t
3303	1	BSchBepOvb	1208000	Overige belastingen	C	4	\N	t
3304	1	BSchBepOvbBib	1208010	Binnenlandse belastingen	C	5	\N	t
3305	1	BSchBepOvbBut	1208020	Buitenlandse belastingen	C	5	\N	t
3306	1	BSchBepOvbPrb	1208030	Provinciale belastingen	C	5	\N	t
3307	1	BSchBepOvbGbe	1208040	Gemeentelijke belastingen	C	5	\N	t
3308	1	BSchBepOvbBgd	1208050	Belastingen op verkochte goederen en diensten uitgezonderd BTW	C	5	\N	t
3309	1	BSchBepOvbTdb	1208070	Te betalen Dividendbelasting belastingen en premies sociale verzekeringen	C	5	\N	t
3310	1	BSchBepOvbOvb	1208060	Te betalen overige belastingen belastingen en premies sociale verzekeringen	C	5	\N	t
3311	1	BSchBepTdb	1208900	Te betalen Dividendbelasting	C	4	\N	t
3312	1	BSchStz	1204089	Schulden ter zake van pensioenen	C	3	\N	t
3313	1	BSchStzPen	1204090	Te betalen pensioenuitkeringen schulden ter zake van pensioenen	C	4	\N	t
3314	1	BSchAos	1201059	Aflossingsverplichtingen van langlopende leningen	C	3	\N	t
3315	1	BSchAosHvk	1201060	Hypotheken van kredietinstellingen (kortlopend)	C	4	\N	t
3316	1	BSchAosLvk	1201080	Leningen van kredietinstellingen (kortlopend)	C	4	\N	t
3317	1	BSchAosFvk	1201070	Financieringen van kredietinstellingen (kortlopend)	C	4	\N	t
3318	1	BSchAosAos	1201090	Aflossingsverplichtingen overige schulden	C	4	\N	t
3319	1	BSchAosMvl	1201100	Marktwaardecorrectie van de vastrentende lening (kortlopend)	C	4	\N	t
3320	1	BSchOpp	1209119	Onderhanden projecten (passiva) overige schulden	C	3	\N	t
3321	1	BSchOppOpp	1209120	Onderhanden projecten (passiva) overige schulden	C	4	\N	t
3322	1	BSchOppOppGkn	1209120.01	Geactiveerde uitgaven voor nog niet verrichte prestaties van onderhanden projecten	D	5	\N	t
3323	1	BSchOppOppKvp	1209120.08	Geactiveerde kosten voor het verkrijgen van een project	D	5	\N	t
3324	1	BSchOppOppOpo	1209120.02	Cumulatieve projectopbrengsten van onderhanden projecten	D	5	\N	t
3325	1	BSchOppOppOpv	1209120.03	Onderhanden projecten in opdracht van derden, voorschotten	D	5	\N	t
3326	1	BSchOppOppGet	1209120.04	In rekening gebrachte termijnen	C	5	\N	t
3327	1	BSchOppOppOpi	1209120.05	Inhoudingen van opdrachtgevers op gedeclareerde termijnen van onderhanden projecten	D	5	\N	t
3328	1	BSchOppOppVzv	1209120.06	Voorziening verliezen	D	5	\N	t
3329	1	BSchOppOppWin	1209120.07	Winstopslag onderhanden projecten	D	5	\N	t
3330	1	BSchSal	1204000	Salarisverwerking	C	3	\N	t
3331	1	BSchSalNet	1204010	Netto lonen overige schulden	C	4	\N	t
3332	1	BSchSalVpe	1204020	Voorschotten personeel	C	4	\N	t
3333	1	BSchSalTan	1204030	Tantièmes overige schulden	C	4	\N	t
3334	1	BSchSalTvg	1204040	Te betalen vakantiegeld overige schulden	C	4	\N	t
3335	1	BSchSalTbv	1204050	Reservering vakantiedagen overige schulden	C	4	\N	t
3336	1	BSchSalVab	1204060	Vakantiebonnen	C	4	\N	t
3337	1	BSchSalBls	1204070	Bruto lonen en salarissen	C	4	\N	t
3338	1	BSchSalOrn	1204075	Overige reserveringen overige schulden	C	4	\N	t
3339	1	BSchSalPsv	1204080	Premies sociale verzekeringen overige schulden	C	4	\N	t
3340	1	BSchSalPer	1204100	Personeelsfonds / personeelsvereniging	C	4	\N	t
3341	1	BSchSalOna	1204110	Overige netto-afdrachten	C	4	\N	t
3342	1	BSchSalGra	1204120	Gratificaties	C	4	\N	t
3343	1	BSchSalOsf	1204130	Te betalen overige sociale fondsen	C	4	\N	t
3344	1	BSchSalReu	1204140	Reservering eindejaarsuitkering	C	4	\N	t
3345	1	BSchOvs	1209000	Overige schulden	C	3	\N	t
3346	1	BSchOvsRcb	1209020	Rekening-courant bestuurders (Kortlopend)	C	4	\N	t
3347	1	BSchOvsRcbRb1	1209020.01	Rekening-courant bestuurder 1	C	5	\N	t
3348	1	BSchOvsRcbRb2	1209020.02	Rekening-courant bestuurder 2	C	5	\N	t
3349	1	BSchOvsRcbRb3	1209020.03	Rekening-courant bestuurder 3	C	5	\N	t
3350	1	BSchOvsRcbRb4	1209020.04	Rekening-courant bestuurder 4	C	5	\N	t
3351	1	BSchOvsRcbRb5	1209020.05	Rekening-courant bestuurder 5	C	5	\N	t
3352	1	BSchOvsRcc	1209025	Rekening-courant commissarissen (Kortlopend)	C	4	\N	t
3353	1	BSchOvsRccRc1	1209025.01	Rekening-courant commissaris 1	C	5	\N	t
3354	1	BSchOvsRccRc2	1209025.02	Rekening-courant commissaris 2	C	5	\N	t
3355	1	BSchOvsRccRc3	1209025.03	Rekening-courant commissaris 3	C	5	\N	t
3356	1	BSchOvsRccRc4	1209025.04	Rekening-courant commissaris 4	C	5	\N	t
3357	1	BSchOvsRccRc5	1209025.05	Rekening-courant commissaris 5	C	5	\N	t
3358	1	BSchOvsRco	1209045	Rekening-courant overigen (Kortlopend)	C	4	\N	t
3359	1	BSchOvsRcoRo1	1209045.01	Rekening-courant overige 1	C	5	\N	t
3360	1	BSchOvsRcoRo2	1209045.02	Rekening-courant overige 2	C	5	\N	t
3361	1	BSchOvsRcoRo3	1209045.03	Rekening-courant overige 3	C	5	\N	t
3362	1	BSchOvsRcoRo4	1209045.04	Rekening-courant overige 4	C	5	\N	t
3363	1	BSchOvsRcoRo5	1209045.05	Rekening-courant overige 5	C	5	\N	t
3364	1	BSchOvsSaa	1209010	Schulden aan aandeelhouders	C	4	\N	t
3365	1	BSchOvsSaaRa1	1209010.01	Rekening-courant aandeelhouder 1	C	5	\N	t
3366	1	BSchOvsSaaRa2	1209010.02	Rekening-courant aandeelhouder 2	C	5	\N	t
3367	1	BSchOvsSaaRa3	1209010.03	Rekening-courant aandeelhouder 3	C	5	\N	t
3368	1	BSchOvsSaaRa4	1209010.04	Rekening-courant aandeelhouder 4	C	5	\N	t
3369	1	BSchOvsSaaRa5	1209010.05	Rekening-courant aandeelhouder 5	C	5	\N	t
3370	1	BSchOvsOvi	1209065	Overige verplichtingen inzake personeel overige schulden	C	4	\N	t
3371	1	BSchOvsTbd	1209070	Te betalen dividenduitkeringen overige schulden	C	4	\N	t
3372	1	BSchOvsGif	1209090	Giftenverplichtingen	C	4	\N	t
3373	1	BSchOvsSuv	1209100	Terugbetaling subsidies overige schulden	C	4	\N	t
3374	1	BSchOvsStp	1209110	Te betalen pensioenpremies schulden ter zake van pensioenen	C	4	\N	t
3375	1	BSchOvsVvv	1209130	Verplichtingen uit hoofde van onroerende zaken verkocht onder voorwaarden	C	4	\N	t
3376	1	BSchOvsVpo	1209140	Verplichtingen aan overheid	C	4	\N	t
3377	1	BSchOvsOvs	1209150	Overige schulden overige schulden	C	4	\N	t
3378	1	BSchOvsWaa	1209135	Waarborgsommen overige schulden	C	4	\N	t
3379	1	BSchOvsLed	1209145	Ledenrekeningen overige schulden	C	4	\N	t
3380	1	BSchOvsLoy	1209155	Loyalty / membersaldo	C	4	\N	t
3381	1	BSchOvsSta	1209160	Statiegeld uitstaand overige schulden	C	4	\N	t
3382	1	BSchOvsVou	1209170	Vouchers uitstaand	C	4	\N	t
3383	1	BSchOvsVvd	1209175	Verkochte vouchers van derden	C	4	\N	t
3384	1	BSchOvsZua	1290180	Zegels uitstaand onder afnemers	C	4	\N	t
3385	1	BSchOpa	1210000	Overlopende passiva	C	3	\N	t
3386	1	BSchOpaNto	1210010	Nog te ontvangen facturen overlopende passiva	C	4	\N	t
3387	1	BSchOpaNtb	1210020	Nog te betalen andere kosten overlopende passiva	C	4	\N	t
3388	1	BSchOpaTbr	1210030	Te betalen rente overlopende passiva	C	4	\N	t
3389	1	BSchOpaVor	1210040	Vooruitontvangen rente overlopende passiva	C	4	\N	t
3390	1	BSchOpaOop	1210050	Overige overlopende passiva overlopende passiva	C	4	\N	t
3391	1	BSchOpaNbs	1210055	Nog te betalen / vooruitontvangen servicekosten	C	4	\N	t
3392	1	BSchOpaNom	1210060	Nog te betalen  / vooruitontvangen omzetbonificaties overlopende passiva	C	4	\N	t
3393	1	BSchOpaNpr	1210070	Nog te betalen  / vooruitontvangen provisies overlopende passiva	C	4	\N	t
3394	1	BSchOpaNbh	1210080	Nog te betalen  / vooruitontvangen huren overlopende passiva	C	4	\N	t
3395	1	BSchOpaNve	1210090	Nog te betalen  / vooruitontvangen vergoedingen overlopende passiva	C	4	\N	t
3396	1	BSchOpaNbi	1210100	Nog te betalen  / vooruitontvangen bijdragen overlopende passiva	C	4	\N	t
3397	1	BSchOpaNpe	1210110	Nog te betalen personeelskosten overlopende passiva	C	4	\N	t
3398	1	BSchOpaNhv	1210120	Nog te betalen huisvestingskosten overlopende passiva	C	4	\N	t
3399	1	BSchOpaNee	1210130	Nog te betalen exploitatie- en machinekosten overlopende passiva	C	4	\N	t
3400	1	BSchOpaNvk	1210140	Nog te betalen verkoopkosten overlopende passiva	C	4	\N	t
3401	1	BSchOpaNak	1210150	Nog te betalen autokosten overlopende passiva	C	4	\N	t
3402	1	BSchOpaNtk	1210160	Nog te betalen transportkosten overlopende passiva	C	4	\N	t
3403	1	BSchOpaNkk	1210170	Nog te betalen kantoorkosten overlopende passiva	C	4	\N	t
3404	1	BSchOpaNok	1210180	Nog te betalen organisatiekosten overlopende passiva	C	4	\N	t
3405	1	BSchOpaNas	1210190	Nog te betalen assurantiekosten overlopende passiva	C	4	\N	t
3406	1	BSchOpaNaa	1210200	Nog te betalen accountants- en advieskosten overlopende passiva	C	4	\N	t
3407	1	BSchOpaNad	1210210	Nog te betalen administratiekosten overlopende passiva	C	4	\N	t
3408	1	BSchOpaNkf	1210220	Nog te betalen kosten fondsenwerving overlopende passiva	C	4	\N	t
3409	1	BSchOpaErf	1210230	Nog te betalen  / vooruitontvangen erfpacht	C	4	\N	t
3410	1	BSchOpaHur	1210240	Vooruitontvangen huren	C	4	\N	t
3411	1	BSchOpaVhr	1210250	Voorstanden huren	C	4	\N	t
3412	1	BSchOpaKsv	1210256	Kosten S&V verrekenbaar	C	4	\N	t
3413	1	BSchOpaNao	1210257	Opbrengsten S&V verrekenbaar	C	4	\N	t
3414	1	BSchOpaVgo	1210260	Vooruitgefactureerde omzet	C	4	\N	t
3415	1	BSchOpaPen	1210270	Schulden pensioen onder overlopende passiva	C	4	\N	t
3416	1	BSchTus	1220000	Tussenrekeningen	C	3	\N	t
3417	1	BSchTusTbt	1220500	Tussenrekeningen betalingen	C	4	\N	t
3418	1	BSchTusTbtTca	1220010	Tussenrekening contante aanbetalingen tussenrekeningen betalingen	C	5	\N	t
3419	1	BSchTusTbtTcb	1220030	Tussenrekening creditcardbetalingen tussenrekeningen betalingen	C	5	\N	t
3420	1	BSchTusTsa	1221000	Tussenrekeningen salarissen	C	4	\N	t
3421	1	BSchTusTsaTbn	1221010	Tussenrekening brutoloon tussenrekeningen salarissen	C	5	\N	t
3422	1	BSchTusTsaTgb	1221020	Tussenrekening brutoinhouding tussenrekeningen salarissen	C	5	\N	t
3423	1	BSchTusTsaTnl	1221030	Tussenrekening nettoloon tussenrekeningen salarissen	C	5	\N	t
3424	1	BSchTusTsaTni	1221040	Tussenrekening nettoinhoudingen tussenrekeningen salarissen	C	5	\N	t
3425	1	BSchTusTin	1222000	Tussenrekeningen inkopen	C	4	\N	t
3426	1	BSchTusTinTog	1222010	Tussenrekening nog te ontvangen goederen tussenrekeningen inkopen	C	5	\N	t
3427	1	BSchTusTinTof	1222020	Tussenrekening nog te ontvangen facturen tussenrekeningen inkopen	C	5	\N	t
3428	1	BSchTusTinTiv	1222030	Tussenrekening inkoopverschillen tussenrekeningen inkopen	C	5	\N	t
3429	1	BSchTusTpj	1223000	Tussenrekeningen projecten	C	4	\N	t
3430	1	BSchTusTpjTpk	1223010	Tussenrekening projectkosten tussenrekeningen projecten	C	5	\N	t
3431	1	BSchTusTpjTpo	1223020	Tussenrekening projectopbrengsten tussenrekeningen projecten	C	5	\N	t
3432	1	BSchTusTpjTpv	1223030	Tussenrekening projectverschillen tussenrekeningen projecten	C	5	\N	t
3433	1	BSchTusTpr	1224000	Tussenrekeningen productie	C	4	\N	t
3434	1	BSchTusTprTmv	1224010	Tussenrekening materiaalverbruik tussenrekeningen productie	C	5	\N	t
3435	1	BSchTusTprTmu	1224020	Tussenrekening manuren tussenrekeningen productie	C	5	\N	t
3436	1	BSchTusTprTau	1224030	Tussenrekening machineuren tussenrekeningen productie	C	5	\N	t
3437	1	BSchTusTprTbu	1224040	Tussenrekening te dekken budget tussenrekeningen productie	C	5	\N	t
3438	1	BSchTusTprTbg	1224050	Tussenrekening budget tussenrekeningen productie	C	5	\N	t
3439	1	BSchTusTdv	1225000	Tussenrekeningen dienstverlening	C	4	\N	t
3440	1	BSchTusTdvTcp	1225010	Tussenrekening capaciteit tussenrekeningen dienstverlening	C	5	\N	t
3441	1	BSchTusTdvTma	1225020	Tussenrekening materialen tussenrekeningen dienstverlening	C	5	\N	t
3442	1	BSchTusTdvTuu	1225030	Tussenrekening uren tussenrekeningen dienstverlening	C	5	\N	t
3443	1	BSchTusTdvInv	1225040	Inkomende verschotten tussenrekeningen dienstverlening	C	5	\N	t
3444	1	BSchTusTdvVso	1225050	Voorschotten onbelast tussenrekeningen dienstverlening	C	5	\N	t
3445	1	BSchTusTdvVsb	1225060	Voorschotten belast tussenrekeningen dienstverlening	C	5	\N	t
3446	1	BSchTusTdvDvo	1225070	Doorberekende voorschotten onbelast tussenrekeningen dienstverlening	C	5	\N	t
3447	1	BSchTusTdvDvb	1225080	Doorberekende voorschotten belast tussenrekeningen dienstverlening	C	5	\N	t
3448	1	BSchTusTvr	1226000	Tussenrekening voorraden	C	4	\N	t
3449	1	BSchTusTvrTvn	1226010	Tussenrekening voorraadverschillen tussenrekening voorraden	C	5	\N	t
3450	1	BSchTusTvk	1227000	Tussenrekeningen verkopen	C	4	\N	t
3451	1	BSchTusTvkTnf	1227010	Tussenrekening nog te factureren tussenrekeningen verkopen	C	5	\N	t
3452	1	BSchTusTvkTng	1227020	Tussenrekening nog te verzenden goederen tussenrekeningen verkopen	C	5	\N	t
3453	1	BSchTusTvkTve	1227030	Tussenrekening verkoopverschillen tussenrekeningen verkopen	C	5	\N	t
3454	1	BSchTusTon	1228000	Tussenrekeningen ontvangsten	C	4	\N	t
3455	1	BSchTusTonTco	1228010	Tussenrekening contante ontvangsten tussenrekeningen ontvangsten	C	5	\N	t
3456	1	BSchTusTonTcv	1228030	Tussenrekening creditcardverkopen tussenrekeningen ontvangsten	C	5	\N	t
3457	1	BSchTusTov	1229000	Tussenrekeningen overig	C	4	\N	t
3458	1	BSchTusTovTbb	1229010	Tussenrekening beginbalans tussenrekeningen overig	C	5	\N	t
3459	1	BSchTusTovTvp	1229020	Tussenrekening vraagposten tussenrekeningen overig	C	5	\N	t
3460	1	BSchTusTovTov	1229030	Tussenrekening overige tussenrekeningen overig	C	5	\N	t
3461	1	BSchTusLen	1228500	Tussenrekeningen leningen	C	4	\N	t
3462	1	BSchTusLenLog	1228510	Tussenrekening leningen OG	C	5	\N	t
3463	1	BSchTusLenLug	1228520	Tussenrekening leningen UG	C	5	\N	t
3464	1	BSchTusLenKog	1228530	Tussenrekening kasgeld OG	C	5	\N	t
3465	1	BSchTusLenKug	1228540	Tussenrekening kasgeld UG	C	5	\N	t
3466	1	BSchTusLenSde	1228550	Tussenrekening spaardeposito	C	5	\N	t
3467	1	BSchTusLenDer	1228560	Tussenrekening derivaten	C	5	\N	t
3468	1	BSchTusLenCfv	1228570	Tussenrekening leningen CFV	C	5	\N	t
3469	1	BSchDha	1230000	Uit te keren dividend aan houders van aandelen	C	3	\N	t
3470	1	BSchDhaDha	1231000	Uit te keren dividend aan houders van aandelen	C	4	\N	t
3471	1	BSchDhaVde	1232000	Voorgestelde bedrag aan dividenduitkeringen aan houders van eigenvermogensinstrumenten	C	4	\N	t
3472	1	BSchDhp	1240000	Uit te keren dividend aan houders van preferente aandelen	C	3	\N	t
3473	1	BSchDhpDhp	1241000	Uit te keren dividend aan houders van preferente aandelen	C	4	\N	t
3474	1	BSchSdn	1250000	Schulden aan daeb-niet daeb	C	3	\N	t
3475	1	BSchSdnDae	1251000	Schulden aan daeb tak	C	4	\N	t
3476	1	BSchSdnNda	1251010	Schulden aan niet-daeb tak	C	4	\N	t
3477	1	BSchSlc	1260000	Schulden aan leden van de coöperatie	C	3	\N	t
3478	1	BSchSlcLi1	1260100	Schuld aan lid A van de coöperatie	C	4	\N	t
3479	1	BSchSlcLi2	1260200	Schuld aan lid B van de coöperatie	C	4	\N	t
3480	1	BSchSlcLi3	1260300	Schuld aan lid C van de coöperatie	C	4	\N	t
3481	1	BSchSlcLi4	1260400	Schuld aan lid D van de coöperatie	C	4	\N	t
3482	1	BSchSlcLi5	1260500	Schuld aan lid E van de coöperatie	C	4	\N	t
3483	1	W	\N	WINST- EN VERLIESREKENING	\N	1	\N	t
3484	1	WOmz	80	Netto-omzet	C	2	\N	t
3485	1	WOmzNop	8001000	Netto-omzet uit leveringen geproduceerde goederen opbrengsten uit de verkoop van goederen	C	3	\N	t
3486	1	WOmzNopOlh	8001010	1a. Netto-omzet uit leveringen geproduceerde goederen belast met hoog tarief	C	4	\N	t
3487	1	WOmzNopOlv	8001020	1b. Netto-omzet uit leveringen geproduceerde goederen belast met laag tarief	C	4	\N	t
3488	1	WOmzNopOlo	8001030	1c. Netto-omzet uit leveringen geproduceerde goederen belast met overige tarieven, behalve 0%	C	4	\N	t
3489	1	WOmzNopOpg	8001040	1d. Netto-omzet uit privégebruik geproduceerde goederen	C	4	\N	t
3490	1	WOmzNopOlg	8001050	1e. Netto-omzet uit geproduceerde goederen belast met 0% of niet bij u belast	C	4	\N	t
3491	1	WOmzNopOll	8001060	2a. Netto-omzet uit leveringen geproduceerde goederen waarbij de omzetbelasting naar u  is verlegd	C	4	\N	t
3492	1	WOmzNopOln	8001070	3a. Netto-omzet uit leveringen geproduceerde goederen naar landen buiten EU (uitvoer)	C	4	\N	t
3493	1	WOmzNopOli	8001080	3b. Netto-omzet uit leveringen geproduceerde goederen naar landen binnen EU	C	4	\N	t
3494	1	WOmzNopOla	8001090	3c. Netto-omzet uit leveringen geproduceerde goederen via installatie/afstandsverkopen binnen de EU	C	4	\N	t
3495	1	WOmzNopOlu	8001100	4a. Netto-omzet uit belaste leveringen van geproduceerde goederen uit landen buiten de EU	C	4	\N	t
3496	1	WOmzNopOle	8001110	4b. Netto-omzet uit belaste leveringen van geproduceerde goederen uit landen binnen de EU	C	4	\N	t
3497	1	WOmzNopNon	8001120	Netto-omzet uit leveringen geproduceerde goederen waarvan overboeking naar andere rubriek opbrengsten uit de verkoop van goederen	C	4	\N	t
3498	1	WOmzNopNod	8001150	Netto-omzet van onbelaste leveringen geproduceerde goederen	C	4	\N	t
3499	1	WOmzNoh	8002000	Netto-omzet uit verkoop van handelsgoederen opbrengsten uit de verkoop van goederen	C	3	\N	t
3500	1	WOmzNohOlh	8002010	1a. Netto-omzet uit verkoop van handelsgoederen belast met hoog tarief	C	4	\N	t
3501	1	WOmzNohOlv	8002020	1b. Netto-omzet uit verkoop van handelsgoederen belast met laag tarief	C	4	\N	t
3502	1	WOmzNohOlo	8002030	1c. Netto-omzet uit verkoop van handelsgoederen belast met overige tarieven, behalve 0%	C	4	\N	t
3503	1	WOmzNohMai	8002035	Margeinkopen 	D	4	\N	t
3504	1	WOmzNohOmr	8002040	Margeverkopen 	C	4	\N	t
3505	1	WOmzNohOpg	8002050	1d. Netto-omzet uit privégebruik handelsgoederen	C	4	\N	t
3506	1	WOmzNohOlg	8002060	1e. Netto-omzet uit leveringen handelsgoederen belast met 0% of niet bij u belast	C	4	\N	t
3507	1	WOmzNohOll	8002070	2a. Netto-omzet uit leveringen handelsgoederen waarbij de omzetbelasting naar u is verlegd	C	4	\N	t
3508	1	WOmzNohOln	8002080	3a. Netto-omzet uit leveringen handelsgoederen naar landen buiten de EU (uitvoer)	C	4	\N	t
3509	1	WOmzNohOli	8002090	3b. Netto-omzet uit leveringen handelsgoederen naar landen binnen de EU	C	4	\N	t
3510	1	WOmzNohOla	8002100	3c. Netto-omzet uit leveringen handelsgoederen via installatie/afstandsverkopen binnen de EU	C	4	\N	t
3511	1	WOmzNohOlu	8002110	4a. Netto-omzet uit belaste leveringen van handelsgoederen uit landen buiten de EU	C	4	\N	t
3512	1	WOmzNohOle	8002120	4b. Netto-omzet uit belaste leveringen van handelsgoederen uit landen binnen de EU	C	4	\N	t
3513	1	WOmzNohNon	8002130	Netto-omzet uit leveringen handelsgoederen waarvan overboeking naar andere rubriek 	C	4	\N	t
3514	1	WOmzNohNod	8002150	Netto-omzet van onbelaste verkoop van handelsgoederen	C	4	\N	t
3515	1	WOmzNod	8003000	Opbrengsten uit het verlenen van diensten	C	3	\N	t
3516	1	WOmzNodOdh	8003010	1a. Netto-omzet uit verleende diensten belast met hoog tarief	C	4	\N	t
3517	1	WOmzNodOdl	8003020	1b. Netto-omzet uit verleende diensten belast met laag tarief	C	4	\N	t
3518	1	WOmzNodOdo	8003030	1c.  Netto-omzet uit verleende diensten belast met overige tarieven, behalve 0%	C	4	\N	t
3519	1	WOmzNodOpd	8003040	1d  Netto-omzet uit privégebruik verleende diensten	C	4	\N	t
3520	1	WOmzNodOdg	8003050	1e. Netto-omzet uit verleende diensten belast met 0% of niet bij u belast	C	4	\N	t
3521	1	WOmzNodOdv	8003060	2a. Netto-omzet uit verleende diensten waarbij de omzetbelasting naar u is verlegd	C	4	\N	t
3522	1	WOmzNodOdb	8003070	3a. Netto-omzet uit verleende diensten naar landen buiten de EU (uitvoer)	C	4	\N	t
3523	1	WOmzNodOdi	8003080	3b. Netto-omzet uit verleende diensten naar landen binnen de EU	C	4	\N	t
3524	1	WOmzNodOda	8003090	3c. Netto-omzet uit verleende diensten via installatie/afstandsverkopen binnen de EU	C	4	\N	t
3525	1	WOmzNodOdu	8003100	4a. Netto-omzet uit belaste leveringen van diensten uit landen buiten de EU	C	4	\N	t
3526	1	WOmzNodOde	8003110	4b. Netto-omzet uit belaste leveringen van diensten uit landen binnen de EU	C	4	\N	t
3527	1	WOmzNodNon	8003120	Netto-omzet uit verleende diensten waarvan overboeking naar andere rubriek opbrengsten uit het verlenen van diensten	C	4	\N	t
3528	1	WOmzNodNod	8003150	Netto-omzet van onbelaste diensten	C	4	\N	t
3529	1	WOmzAol	8007000	Toegerekende opbrengsten	C	3	\N	t
3530	1	WOmzAolPom	8007010	Productieomzet toegerekende opbrengsten	C	4	\N	t
3531	1	WOmzAolVpa	8007020	Verpakkingsvergoeding toegerekende opbrengsten	C	4	\N	t
3532	1	WOmzAolGms	8007030	GMO subsidie toegerekende opbrengsten	C	4	\N	t
3533	1	WOmzAolVee	8007040	Verkoop elektra toegerekende opbrengsten	C	4	\N	t
3534	1	WOmzAolVwd	8007045	Vergoeding werk aan derden	C	4	\N	t
3535	1	WOmzAolOno	8007050	Overige niet toegerekende opbrengsten toegerekende opbrengsten	C	4	\N	t
3536	1	WOmzAov	8008000	Agrarische bedrijfsopbrengsten veeteelt	C	3	\N	t
3537	1	WOmzAovVmu	8008005	Voorraadmutatie toegerekende opbrengsten	C	4	\N	t
3538	1	WOmzAovOzv	8008010	Omzet vee toegerekende opbrengsten	C	4	\N	t
3539	1	WOmzAovOea	8008015	Omzet en Aanwas vee toegerekende opbrengsten	C	4	\N	t
3540	1	WOmzAovBts	8008020	Bedrijfstoeslag toegerekende opbrengsten	C	4	\N	t
3541	1	WOmzAovMel	8008030	Melkgeld	C	4	\N	t
3542	1	WOmzAovEie	8008040	Eiergeld	C	4	\N	t
3543	1	WOmzNoo	8004000	Overige netto-omzet	C	3	\N	t
3544	1	WOmzNooNdl	8004010	Overige netto-omzet waarvan licenties overige netto-omzet	C	4	\N	t
3545	1	WOmzNooNdy	8004020	Opbrengsten uit royalty's overige netto-omzet	C	4	\N	t
3546	1	WOmzNooNdd	8004030	Opbrengsten uit dividenden overige netto-omzet	C	4	\N	t
3547	1	WOmzNooOur	8004060	Opbrengsten uit rente overige netto-omzet	C	4	\N	t
3548	1	WOmzNooOnw	8004070	Overige netto-omzet waarvan niet elders genoemd overige netto-omzet	C	4	\N	t
3549	1	WOmzNooNdo	8004040	Opbrengsten uit overige bronnen overige netto-omzet	C	4	\N	t
3550	1	WOmzNooNon	8004050	Overige netto-omzet waarvan overboeking naar andere rubriek overige netto-omzet	C	4	\N	t
3551	1	WOmzNooNtf	8004080	Omzet (nog te factureren)	C	4	\N	t
3552	1	WOmzNooOvd	8004090	Opbrengsten verkoop vouchers van derden	C	4	\N	t
3553	1	WOmzNooOvv	8004100	Opbrengsten vervallen vouchers	C	4	\N	t
3554	1	WOmzOit	8005000	Netto-omzet intercompany transacties	C	3	\N	t
3555	1	WOmzOitOit	8005010	Omzet intercompany transacties	C	4	\N	t
3556	1	WOmzOitOvg	8005020	Omzet verkopen aan groepsmaatschappijen netto-omzet intercompany transacties	C	4	\N	t
3557	1	WOmzOitOvm	8005030	Omzet verkopen aan overige verbonden maatschappijen netto-omzet intercompany transacties	C	4	\N	t
3558	1	WOmzOitOvd	8005040	Omzet verkopen aan andere deelnemingen netto-omzet intercompany transacties	C	4	\N	t
3559	1	WOmzKeb	8006000	Kortingen en bonussen en provisies	D	3	\N	t
3560	1	WOmzKebVek	8006010	Verleende kortingen	D	4	\N	t
3561	1	WOmzKebVekVkp	8006010.01	Verleende kortingen op geproduceerde goederen verleende kortingen	D	5	\N	t
3562	1	WOmzKebVekVkh	8006010.02	Verleende kortingen op handelsgoederen verleende kortingen	D	5	\N	t
3563	1	WOmzKebVekVkd	8006010.03	Verleende kortingen op diensten verleende kortingen	D	5	\N	t
3564	1	WOmzKebVekOkr	8006010.04	Overige verleende kortingen verleende kortingen	D	5	\N	t
3565	1	WOmzKebOmz	8006020	Omzetbonificaties	D	4	\N	t
3566	1	WOmzKebOmzOog	8006020.01	Omzetbonificaties op geproduceerde goederen omzetbonificaties	D	5	\N	t
3567	1	WOmzKebOmzOoh	8006020.02	Omzetbonificaties op handelsgoederen omzetbonificaties	D	5	\N	t
3568	1	WOmzKebOmzOod	8006020.03	Omzetbonificaties op diensten omzetbonificaties	D	5	\N	t
3569	1	WOmzKebOmzOov	8006020.04	Omzetbonificaties overige omzetbonificaties	D	5	\N	t
3570	1	WOmzKebPrv	8006030	Provisies	D	4	\N	t
3571	1	WOmzKebPrvPvh	8006030.01	Provisies op verkopen handel provisies	D	5	\N	t
3572	1	WOmzKebPrvPvp	8006030.02	Provisies op verkopen productie provisies	D	5	\N	t
3573	1	WOmzKebPrvPvd	8006030.03	Provisies op verkopen dienstverlening provisies	D	5	\N	t
3574	1	WOmzKebPrvOvp	8006030.04	Overige provisies provisies	D	5	\N	t
3575	1	WOmzGrp	8009000	Netto-omzet groepen	C	3	\N	t
3576	1	WOmzGrpGr1	8009100	Netto-omzet groep 1	C	4	\N	t
3577	1	WOmzGrpGr1Pra	8009100.01	Netto-omzet groep 1 product A	C	5	\N	t
3578	1	WOmzGrpGr1Prb	8009100.02	Netto-omzet groep 1 product B	C	5	\N	t
3579	1	WOmzGrpGr1Prc	8009100.03	Netto-omzet groep 1 product C	C	5	\N	t
3580	1	WOmzGrpGr1Prd	8009100.04	Netto-omzet groep 1 product D	C	5	\N	t
3581	1	WOmzGrpGr1Pre	8009100.05	Netto-omzet groep 1 product E	C	5	\N	t
3582	1	WOmzGrpGr2	8009200	Netto-omzet groep 2	C	4	\N	t
3583	1	WOmzGrpGr2Pra	8009200.01	Netto-omzet groep 2 product A	C	5	\N	t
3584	1	WOmzGrpGr2Prb	8009200.02	Netto-omzet groep 2 product B	C	5	\N	t
3585	1	WOmzGrpGr2Prc	8009200.03	Netto-omzet groep 2 product C	C	5	\N	t
3586	1	WOmzGrpGr2Prd	8009200.04	Netto-omzet groep 2 product D	C	5	\N	t
3587	1	WOmzGrpGr2Pre	8009200.05	Netto-omzet groep 2 product E	C	5	\N	t
3588	1	WOmzGrpGr3	8009300	Netto-omzet groep 3	C	4	\N	t
3589	1	WOmzGrpGr3Pra	8009300.01	Netto-omzet groep 3 product A	C	5	\N	t
3590	1	WOmzGrpGr3Prb	8009300.02	Netto-omzet groep 3 product B	C	5	\N	t
3591	1	WOmzGrpGr3Prc	8009300.03	Netto-omzet groep 3 product C	C	5	\N	t
3592	1	WOmzGrpGr3Prd	8009300.04	Netto-omzet groep 3 product D	C	5	\N	t
3593	1	WOmzGrpGr3Pre	8009300.05	Netto-omzet groep 3 product E	C	5	\N	t
3594	1	WOmzGrpGr4	8009400	Netto-omzet groep 4	C	4	\N	t
3595	1	WOmzGrpGr4Pra	8009400.01	Netto-omzet groep 4 product A	C	5	\N	t
3596	1	WOmzGrpGr4Prb	8009400.02	Netto-omzet groep 4 product B	C	5	\N	t
3597	1	WOmzGrpGr4Prc	8009400.03	Netto-omzet groep 4 product C	C	5	\N	t
3598	1	WOmzGrpGr4Prd	8009400.04	Netto-omzet groep 4 product D	C	5	\N	t
3599	1	WOmzGrpGr4Pre	8009400.05	Netto-omzet groep 4 product E	C	5	\N	t
3600	1	WOmzGrpGr5	8009500	Netto-omzet groep 5	C	4	\N	t
3601	1	WOmzGrpGr5Pra	8009500.01	Netto-omzet groep 5 product A	C	5	\N	t
3602	1	WOmzGrpGr5Prb	8009500.02	Netto-omzet groep 5 product B	C	5	\N	t
3603	1	WOmzGrpGr5Prc	8009500.03	Netto-omzet groep 5 product C	C	5	\N	t
3604	1	WOmzGrpGr5Prd	8009500.04	Netto-omzet groep 5 product D	C	5	\N	t
3605	1	WOmzGrpGr5Pre	8009500.05	Netto-omzet groep 5 product E	C	5	\N	t
3606	1	WRev	80.1	Netto resultaat exploitatie van vastgoedportefeuille	C	2	\N	t
3607	1	WRevHuo	8010000	Huuropbrengsten	C	3	\N	t
3608	1	WRevHuoHuo	8010100	Huuropbrengsten	C	4	\N	t
3609	1	WRevHuoHuoHur	8010100.01	Huren	C	5	\N	t
3610	1	WRevHuoHuoLee	8010100.02	Frictieleegstand	C	5	\N	t
3611	1	WRevHuoHuoAfb	8010100.03	Afboekingen	C	5	\N	t
3612	1	WRevHuoHuoMvh	8010100.04	Mutatie voorziening huurdebiteuren	C	5	\N	t
3613	1	WRevHuoHuoLpr	8010100.05	Leegstand projecten	C	5	\N	t
3614	1	WRevHuoHuoLvk	8010100.06	Leegstand verkoop	C	5	\N	t
3615	1	WRevHuoHuoHko	8010100.07	Huurkortingen	C	5	\N	t
3616	1	WRevOsc	8011000	Opbrengsten servicecontracten	C	3	\N	t
3617	1	WRevOscOsc	8011100	Opbrengsten servicecontracten	C	4	\N	t
3618	1	WRevOscOscOzd	8011100.01	Overige zaken, leveringen en diensten	C	5	\N	t
3619	1	WRevOscOscVgd	8011100.02	Vergoedingsderving (verrekenbaar)	C	5	\N	t
3620	1	WRevOscOscTvh	8011100.03	Te verrekenen met huurders	C	5	\N	t
3621	1	WRevOscOscZsv	8011100.04	Overige zaken, service en verbruik  (niet verrekenbaar)	C	5	\N	t
3622	1	WRevOscOscZnd	8011100.05	Vergoedingsderving (niet verrekenbaar)	C	5	\N	t
3623	1	WRevOscOscOsc	8011100.06	Opbrengsten serviceabonnement onderhoud	C	5	\N	t
3624	1	WRevLsc	8012000	Lasten servicecontracten	D	3	\N	t
3625	1	WRevLscLsc	8012100	Lasten servicecontracten	D	4	\N	t
3626	1	WRevLscLscSal	8012100.10	Toegerekende kosten salarissen	D	5	\N	t
3627	1	WRevLscLscSoc	8012100.11	Toegerekende kosten sociale lasten	D	5	\N	t
3628	1	WRevLscLscPen	8012100.12	Toegerekende kosten pensioenlasten	D	5	\N	t
3629	1	WRevLscLscAfs	8012100.13	Toegerekende kosten afschrijvingen	D	5	\N	t
3630	1	WRevLscLscObl	8012100.14	Toegerekende kosten overige bedrijfslasten	D	5	\N	t
3631	1	WRevLscLscOpl	8012100.15	Toegerekende kosten overige personeelslasten	D	5	\N	t
3632	1	WRevLscLscLld	8012100.01	Lasten leveringen en diensten	D	5	\N	t
3633	1	WRevLscLscLwl	8012100.02	Lasten warmtelevering	D	5	\N	t
3634	1	WRevLscLscLoz	8012100.03	Lasten overige zaken (niet verrekenbaar)	D	5	\N	t
3635	1	WRevLscLscAsc	8012100.04	Afgerekende service en stookkosten	D	5	\N	t
3636	1	WRevLscLscLos	8012100.05	Lasten overige servicekosten	D	5	\N	t
3637	1	WRevLscLscKso	8012100.16	Directe kosten serviceaboonement onderhoud	D	5	\N	t
3638	1	WRevOhb	8013000	Overheidsbijdragen	C	3	\N	t
3639	1	WRevOhbOhb	8013100	Overheidsbijdragen	C	4	\N	t
3640	1	WRevLvb	8014000	Lasten verhuur en beheeractiviteiten	D	3	\N	t
3641	1	WRevLvbLvb	8014100	Lasten verhuur en beheeractiviteiten	D	4	\N	t
3642	1	WRevLvbLvbSal	8014100.01	Toegerekende kosten salarissen lasten lasten verhuur en beheeractiviteiten	D	5	\N	t
3643	1	WRevLvbLvbSoc	8014100.02	Toegerekende kosten sociale lasten lasten verhuur en beheeractiviteiten	D	5	\N	t
3644	1	WRevLvbLvbPen	8014100.03	Toegerekende kosten pensioenlasten lasten verhuur en beheeractiviteiten	D	5	\N	t
3645	1	WRevLvbLvbAfs	8014100.04	Toegerekende kosten afschrijvingen lasten verhuur en beheeractiviteiten	D	5	\N	t
3646	1	WRevLvbLvbObl	8014100.05	Toegerekende kosten overige bedrijfslasten lasten verhuur en beheeractiviteiten	D	5	\N	t
3647	1	WRevLvbLvbOpl	8014100.06	Toegerekende kosten overige personeelslasten	D	5	\N	t
3648	1	WRevLvbLvbAhc	8014100.07	Administratiekosten huurcontract	D	5	\N	t
3649	1	WRevLvbLvbAsk	8014100.08	Administratiekosten servicekosten	D	5	\N	t
3650	1	WRevLvbLvbOve	8014100.09	Lasten Verhuur en Beheeractiviteiten overig	D	5	\N	t
3651	1	WRevLoa	8015000	Lasten onderhoudsactiviteiten	D	3	\N	t
3652	1	WRevLoaLoa	8015100	Lasten onderhoudsactiviteiten	D	4	\N	t
3653	1	WRevLoaLoaCal	8015100.01	Calamiteiten	D	5	\N	t
3654	1	WRevLoaLoaPmo	8015100.02	Planmatig onderhoud	D	5	\N	t
3655	1	WRevLoaLoaOvu	8015100.03	Mutatieonderhoud verhuur (technisch noodzakelijk)	D	5	\N	t
3656	1	WRevLoaLoaOve	8015100.04	Mutatieonderhoud verhuur (extra)	D	5	\N	t
3657	1	WRevLoaLoaOvt	8015100.05	Mutatieonderhoud verkoop (technisch noodzakelijk)	D	5	\N	t
3658	1	WRevLoaLoaRpo	8015100.06	Reparatieonderhoud	D	5	\N	t
3659	1	WRevLoaLoaAro	8015100.07	Afkoop reparatieonderhoud	D	5	\N	t
3660	1	WRevLoaLoaCto	8015100.08	Contractonderhoud	D	5	\N	t
3661	1	WRevLoaLoaObv	8015100.09	Onderhoudsbijdrage VVE's	D	5	\N	t
3662	1	WRevLoaLoaVio	8015100.10	Vandalisme/inbraak onderhoud	D	5	\N	t
3663	1	WRevLoaLoaOvr	8015100.11	Opstalverzekering eigen risico	D	5	\N	t
3664	1	WRevLoaLoaRen	8015100.12	Renovatie	D	5	\N	t
3665	1	WRevLoaLoaOoh	8015100.13	Overig onderhoud	D	5	\N	t
3666	1	WRevLoaLoaSal	8015100.14	Toegerekende kosten salarissen lasten lasten onderhoud	D	5	\N	t
3667	1	WRevLoaLoaSoc	8015100.15	Toegerekende kosten sociale lasten lasten onderhoud	D	5	\N	t
3668	1	WRevLoaLoaPen	8015100.16	Toegerekende kosten pensioenlasten lasten onderhoud	D	5	\N	t
3669	1	WRevLoaLoaOpk	8015100.29	Toerekening organisatiekosten overige personeelslasten	D	5	\N	t
3670	1	WRevLoaLoaAfs	8015100.17	Toegerekende kosten afschrijvingen lasten onderhoud	D	5	\N	t
3671	1	WRevLoaLoaObk	8015100.18	Toegerekende kosten overige bedrijfslasten lasten onderhoud	D	5	\N	t
3672	1	WRevLoaLoaPop	8015100.19	Planmatig onderhoud overboeking naar projecten	D	5	\N	t
3673	1	WRevLoaLoaDui	8015100.20	Dekking uren indirect	D	5	\N	t
3674	1	WRevLoaLoaDue	8015100.21	Dekking uren eigen dienst	D	5	\N	t
3675	1	WRevLoaLoaDup	8015100.22	Dekking uren planmatig en contractonderhoud	D	5	\N	t
3676	1	WRevLoaLoaDum	8015100.23	Dekking magazijnkosten	D	5	\N	t
3677	1	WRevLoaLoaDua	8015100.24	Dekking afval	D	5	\N	t
3678	1	WRevLoaLoaDuk	8015100.25	Dekking klein materiaal	D	5	\N	t
3679	1	WRevLoaLoaPvm	8015100.26	Voorraadprijsverschillen materiaal	D	5	\N	t
3680	1	WRevLoaLoaKso	8015100.27	Kosten serviceabonnement onderhoud	D	5	\N	t
3681	1	WRevLoaLoaOso	8015100.28	Opbrengsten serviceabonnement onderhoud	C	5	\N	t
3682	1	WRevOol	8016000	Overige directe operationele lasten explotatie bezit	D	3	\N	t
3683	1	WRevOolOol	8016100	Overige directe operationele lasten explotatie bezit	D	4	\N	t
3684	1	WRevOolOolBel	8016100.01	Onroerende zaakbelasting	D	5	\N	t
3685	1	WRevOolOolWsb	8016100.10	Waterschapsbelasting	D	5	\N	t
3687	1	WRevOolOolObh	8016100.12	Overige belastingen en heffingen	D	5	\N	t
3688	1	WRevOolOolVez	8016100.02	Verzekeringen	D	5	\N	t
3689	1	WRevOolOolVhf	8016100.03	Verhuurdersheffing	D	5	\N	t
3690	1	WRevOolOolShf	8016100.04	Saneringsheffing	D	5	\N	t
3691	1	WRevOolOolBhf	8016100.05	Bijdrageheffing Autoriteit woningcorporaties	D	5	\N	t
3692	1	WRevOolOolCon	8016100.06	Contributies	D	5	\N	t
3693	1	WRevOolOolBiv	8016100.07	Aandeel in vereniging van eigenaren	D	5	\N	t
3694	1	WRevOolOolErp	8016100.08	Erfpacht	D	5	\N	t
3695	1	WRevOolOolOdl	8016100.09	Diverse directe exploitatielasten	D	5	\N	t
3696	1	WRvi	80.2	Netto resultaat verkocht vastgoed in ontwikkeling	C	2	\N	t
3697	1	WRviOvo	8020000	Omzet verkocht vastgoed in ontwikkeling	C	3	\N	t
3698	1	WRviOvoOvo	8020100	Omzet verkocht vastgoed in ontwikkeling	C	4	\N	t
3699	1	WRviUvv	8021000	Uitgaven verkocht vastgoed in ontwikkeling	D	3	\N	t
3700	1	WRviUvvUvv	8021100	Uitgaven verkocht vastgoed in ontwikkeling	D	4	\N	t
3701	1	WRviUvvUvvKuw	8021100.01	Kosten uitbesteed werk verkocht vastgoed in ontwikkeling	D	5	\N	t
3702	1	WRviTok	8022000	Toegerekende organisatiekosten verkocht vastgoed in ontwikkeling	D	3	\N	t
3703	1	WRviTokTok	8022100	Toegerekende organisatiekosten verkocht vastgoed in ontwikkeling	D	4	\N	t
3704	1	WRviTokTokSal	8022100.01	Toegerekende organisatiekosten salarissen verkocht vastgoed in ontwikkeling	D	5	\N	t
3705	1	WRviTokTokSoc	8022100.02	Toegerekende organisatiekosten sociale lasten verkocht vastgoed in ontwikkeling	D	5	\N	t
3706	1	WRviTokTokPen	8022100.03	Toegerekende organisatiekosten pensioenlasten verkocht vastgoed in ontwikkeling	D	5	\N	t
3707	1	WRviTokTokAfs	8022100.04	Toegerekende organisatiekosten afschrijvingen verkocht vastgoed in ontwikkeling	D	5	\N	t
3708	1	WRviTokTokObl	8022100.05	Toegerekende organisatiekosten overige bedrijfslasten verkocht vastgoed in ontwikkeling	D	5	\N	t
3709	1	WRviTokTokGpr	8022100.06	          Geactiveerde productie Vastgoed in ontwikkeling	D	5	\N	t
3710	1	WRviTokTokOpl	8022100.07	Toegerekende organisatiekosten overige personeelslasten	D	5	\N	t
3711	1	WRviTfk	8023000	Toegerekende financieringskosten	D	3	\N	t
3712	1	WRviTfkTfk	8023100	Toegerekende financieringskosten	D	4	\N	t
3713	1	WRgr	80.3	Netto gerealiseerd resultaat verkoop vastgoedportefeuille	C	2	\N	t
3714	1	WRgrOvp	8030000	Verkoopopbrengst vastgoedportefeuille	C	3	\N	t
3715	1	WRgrOvpOvp	8030100	Verkoopopbrengst vastgoedportefeuille	C	4	\N	t
3716	1	WRgrTok	8031000	Toegerekende organisatiekosten verkoop vastgoedportefeuille	D	3	\N	t
3717	1	WRgrTokTok	8031100	Toegerekende organisatiekosten verkoop vastgoedportefeuille	D	4	\N	t
3718	1	WRgrTokTokSal	8031100.01	Toegerekende organisatiekosten salarissen resultaat verkoop vastgoedportefeuille	D	5	\N	t
3719	1	WRgrTokTokSoc	8031100.02	Toegerekende organisatiekosten sociale lasten resultaat verkoop vastgoedportefeuille	D	5	\N	t
3720	1	WRgrTokTokPen	8031100.03	Toegerekende organisatiekosten pensioenlasten resultaat verkoop vastgoedportefeuille	D	5	\N	t
3721	1	WRgrTokTokAfs	8031100.04	Toegerekende organisatiekosten afschrijvingen resultaat verkoop vastgoedportefeuille	D	5	\N	t
3722	1	WRgrTokTokObl	8031100.05	Toegerekende organisatiekosten overige bedrijfslasten resultaat verkoop vastgoedportefeuille	D	5	\N	t
3723	1	WRgrTokTokOpl	8031100.06	Toegerekende organisatiekosten overige personeelslasten	D	5	\N	t
3724	1	WRgrRvb	8032000	Boekwaarde verkochte vastgoedportefeuille	D	3	\N	t
3725	1	WRgrRvbLsc	8032100	Boekwaarde verkochte vastgoedportefeuille	D	4	\N	t
3726	1	WRgrDkv	8033000	Directe kosten inzake verkoop vastgoedportefeuille	D	3	\N	t
3727	1	WRgrDkvVkk	8033100	Verkoopkosten	D	4	\N	t
3728	1	WRgrDkvVbm	8033200	Verkoopbevorderende maatregelen	D	4	\N	t
3729	1	WRgrDkvMaf	8033300	Meerwaarde afdracht	D	4	\N	t
3730	1	WWvv	80.4	Waardeveranderingen vastgoedportefeuille	C	2	\N	t
3731	1	WWvvOwv	8040000	Overige waardeveranderingen van vastgoedportefeuille	C	3	\N	t
3732	1	WWvvOwvOwv	8040100	Overige waardeveranderingen van vastgoedportefeuille	C	4	\N	t
3733	1	WWvvOwvOwvKgp	8040100.01	Kosten afboeking gestaakte projecten	D	5	\N	t
3734	1	WWvvOwvOwvOvp	8040100.02	Overige projectkosten	D	5	\N	t
3735	1	WWvvOwvOwvDvn	8040100.03	Dotatie voorziening nieuwbouw	D	5	\N	t
3736	1	WWvvOwvOwvVvn	8040100.04	Vrijval voorziening nieuwbouw	C	5	\N	t
3737	1	WWvvOwvOwvDvr	8040100.05	Dotatie voorziening renovatie	D	5	\N	t
3738	1	WWvvOwvOwvVvr	8040100.06	Vrijval voorziening renovatie	C	5	\N	t
3739	1	WWvvOwvOwvDvg	8040100.07	Dotatie voorziening grondposities	D	5	\N	t
3740	1	WWvvOwvOwvVvg	8040100.08	Vrijval voorziening grondposities	C	5	\N	t
3741	1	WWvvOwvTok	8040200	Toegerekende organisatiekosten vastgoed in ontwikkeling t.b.v. verhuur	D	4	\N	t
3742	1	WWvvOwvTokSal	8040200.01	Toegerekende organisatiekosten salarissen vastgoed in ontwikkeling tbv verhuur	D	5	\N	t
3743	1	WWvvOwvTokSoc	8040200.02	Toegerekende organisatiekosten sociale lasten vastgoed in ontwikkeling tbv verhuur	D	5	\N	t
3744	1	WWvvOwvTokPen	8040200.03	Toegerekende organisatiekosten pensioenlasten vastgoed in ontwikkeling tbv verhuur	D	5	\N	t
3745	1	WWvvOwvTokAfs	8040200.04	Toegerekende organisatiekosten afschrijvingen vastgoed in ontwikkeling tbv verhuur	D	5	\N	t
3746	1	WWvvOwvTokObl	8040200.05	Toegerekende organisatiekosten overige bedrijfslasten vastgoed in ontwikkeling tbv verhuur	D	5	\N	t
3747	1	WWvvOwvTokOpl	8040200.07	Toegerekende organisatiekosten overige personeelslasten vastgoed in ontwikkeling tbv verhuur	D	5	\N	t
3748	1	WWvvOwvTokGap	8040200.08	Toegerekende organisatiekosten geactiveerde productie vastgoedinvesteringen	C	5	\N	t
3749	1	WWvvNwp	8041000	Niet-gerealiseerde waardeveranderingen van vastgoedportefeuille	C	3	\N	t
3750	1	WWvvNwpNwp	8041100	Niet-gerealiseerde waardeveranderingen van vastgoedportefeuille	C	4	\N	t
3751	1	WWvvNwpNwpDie	8041100.01	Niet-gerealiseerde waardeveranderingen DAEB	C	5	\N	t
3752	1	WWvvNwpNwpNde	8041100.02	Niet-gerealiseerde waardeveranderingen Niet-DAEB	C	5	\N	t
3753	1	WWvvNwv	8042000	Niet-gerealiseerde waardeveranderingen van vastgoedportefeuille verkocht onder voorwaarden	C	3	\N	t
3754	1	WWvvNwvNwv	8042100	Niet-gerealiseerde waardeveranderingen van vastgoedportefeuille verkocht onder voorwaarden	C	4	\N	t
3755	1	WWvvNwb	8043000	Niet-gerealiseerde waardeveranderingen van vastgoedportefeuille bestemd voor verkoop	C	3	\N	t
3756	1	WWvvNwbNwb	8043100	Niet-gerealiseerde waardeveranderingen van vastgoedportefeuille bestemd voor verkoop	C	4	\N	t
3757	1	WNoa	80.5	Netto resultaat overige activiteiten	C	2	\N	t
3758	1	WNoaOoa	8050000	Opbrengsten overige activiteiten	C	3	\N	t
3759	1	WNoaOoaOoa	8050100	Opbrengsten overige activiteiten	C	4	\N	t
3760	1	WNoaOoaOoaAop	8050100.01	Antenne opstelling	C	5	\N	t
3761	1	WNoaOoaOoaVve	8050100.02	VVE	C	5	\N	t
3762	1	WNoaOoaOoaZpn	8050100.03	Zonnepanelen	C	5	\N	t
3763	1	WNoaOoaOoaWpp	8050100.04	Warmtepompen	C	5	\N	t
3764	1	WNoaOoaOoaVbw	8050100.05	Vastrecht bronwarmte	C	5	\N	t
3765	1	WNoaOoaOoaWaw	8050100.06	Opbrengsten warmtewet	C	5	\N	t
3766	1	WNoaOoaOoaDer	8050100.07	Derving opbrengsten overige activiteiten	C	5	\N	t
3767	1	WNoaOoaOoaOvr	8050100.08	Overige opbrengsten	C	5	\N	t
3768	1	WNoaKoa	8051000	Kosten overige activiteiten	D	3	\N	t
3769	1	WNoaKoaKoa	8051100	Kosten overige activiteiten	D	4	\N	t
3770	1	WNoaKoaKoaSal	8051100.01	Aan overige activiteiten toegerekende salarissen	D	5	\N	t
3771	1	WNoaKoaKoaSoc	8051100.02	Aan overige activiteiten toegerekende sociale lasten	D	5	\N	t
3772	1	WNoaKoaKoaPen	8051100.03	Aan overige activiteiten toegerekende pensioenlasten	D	5	\N	t
3773	1	WNoaKoaKoaAfs	8051100.04	Aan overige activiteiten toegerekende afschrijvingen	D	5	\N	t
3774	1	WNoaKoaKoaObl	8051100.05	Aan overige activiteiten toegerekende overige bedrijfslasten	D	5	\N	t
3775	1	WNoaKoaKoaKuw	8051100.06	Kosten uitbesteed werk overige activiteiten	D	5	\N	t
3776	1	WNoaKoaKoaOpl	8051100.07	Aan overige activiteiten toegerekende overige personeelslasten	D	5	\N	t
3777	1	WNoaKoaKoaGpe	8051100.08	Geactiveerde productie voor het eigen bedrijf	D	5	\N	t
3778	1	WOok	44	Overige organisatiekosten	D	2	\N	t
3779	1	WOokOok	4400000	Overige organisatiekosten	D	3	\N	t
3780	1	WOokOokSal	4400140	Aan overige organisatiekosten toegerekende salarissen	D	4	\N	t
3781	1	WOokOokSoc	4400150	Aan overige organisatiekosten toegerekende sociale lasten	D	4	\N	t
3782	1	WOokOokPen	4400160	Aan overige organisatiekosten toegerekende pensioenlasten	D	4	\N	t
3783	1	WOokOokAfs	4400170	Aan overige organisatiekosten toegerekende afschrijvingen	D	4	\N	t
3784	1	WOokOokObl	4400180	Aan overige organisatiekosten toegerekende overige bedrijfslasten	D	4	\N	t
3785	1	WOokOokOpl	4400190	Aan overige organisatiekosten toegerekende overige personeelskosten	D	4	\N	t
3786	1	WOokOokOkn	4400100	Overige organisatiekosten	D	4	\N	t
3787	1	WOokOokDok	4400101	Doorberekende organisatiekosten	C	4	\N	t
3788	1	WOokOokShf	4400110	Saneringsheffing	D	4	\N	t
3789	1	WOokOokBhf	4400120	Bijdrageheffing Autoriteit woningcorporaties	D	4	\N	t
3790	1	WOokOokOhf	4400130	Obligoheffing WSW	D	4	\N	t
3791	1	WOokOokOsh	4400200	Overige sectorspecifieke heffingen	D	4	\N	t
3792	1	WKol	80.6	Kosten omtrent leefbaarheid	D	2	\N	t
3793	1	WKolKol	8060000	Kosten omtrent leefbaarheid	D	3	\N	t
3794	1	WKolKolLee	8060100	Kosten omtrent leefbaarheid	D	4	\N	t
3795	1	WKolKolLeeMpo	8060100.01	Aanpak multiproblematiek en overlast	D	5	\N	t
3796	1	WKolKolLeeKli	8060100.02	Kleinschalige leefbaarheidsinitiatieven	D	5	\N	t
3797	1	WKolKolLeeInb	8060100.03	Interventies buitenruimte	D	5	\N	t
3798	1	WKolKolLeeKwp	8060100.04	Kleinschalige wijkpanden	D	5	\N	t
3799	1	WKolKolLeeWbe	8060100.05	Wijkbeheer/schoon, heel, veilig	D	5	\N	t
3800	1	WKolKolLeeOnt	8060100.15	Ontmoeting	D	5	\N	t
3801	1	WKolKolLeeSal	8060100.06	Aan leefbaarheid toegerekende salarissen	D	5	\N	t
3802	1	WKolKolLeeSoc	8060100.07	Aan leefbaarheid toegerekende sociale lasten	D	5	\N	t
3803	1	WKolKolLeePen	8060100.08	Aan leefbaarheid toegerekende pensioenlasten	D	5	\N	t
3804	1	WKolKolLeeAfs	8060100.09	Aan leefbaarheid toegerekende afschrijvingen	D	5	\N	t
3805	1	WKolKolLeeObl	8060100.11	Aan leefbaarheid toegerekende overige bedrijfslasten	D	5	\N	t
3806	1	WKolKolLeeOpl	8060100.12	Aan leefbaarheid toegerekende overige personeelslasten	D	5	\N	t
3807	1	WKolKolLeeDul	8060100.13	Dekking uitgaven leefbaarheid	D	5	\N	t
3808	1	WVkf	80.8	Verkoopkosten	D	2	\N	t
3809	1	WVkfVkf	8080000	Verkoopkosten	D	3	\N	t
3810	1	WVkfVkfVkf	8080100	Verkoopkosten	D	4	\N	t
3811	1	WAkf	80.9	Algemene beheerskosten	D	2	\N	t
3812	1	WAkfAkf	8090000	Algemene beheerskosten	D	3	\N	t
3813	1	WAkfAkfAkf	8090100	Algemene beheerskosten	D	4	\N	t
3814	1	WWiv	81	Wijziging voorraden	C	2	\N	t
3815	1	WWivWgp	8101000	Wijziging in voorraden grond- en hulpstoffen, gereed product en handelsgoederen	C	3	\N	t
3816	1	WWivWgpWgh	8101030	Wijziging in voorraden grond- en hulpstoffen / halffabrikaten)	C	4	\N	t
3817	1	WWivWgpWgp	8101010	Wijziging in voorraden gereed product	C	4	\N	t
3818	1	WWivWgpWhg	8101020	Wijziging in voorraden handelsgoederen	C	4	\N	t
3819	1	WWivWow	8102000	Wijziging in voorraden onderhanden werk	C	3	\N	t
3820	1	WWivWowWow	8102010	Wijziging in vooraden onderhanden werk	C	4	\N	t
3821	1	WWivWop	8103000	Wijziging in onderhanden projecten in opdracht van derden	C	3	\N	t
3822	1	WWivWopWop	8103010	Wijziging in onderhanden projecten	C	4	\N	t
3823	1	WWivGpv	8104000	Geactiveerde productie voor het eigen bedrijf	C	3	\N	t
3824	1	WWivGpvGpe	8104010	Geactiveerde productie voor het eigen bedrijf	C	4	\N	t
3825	1	WWivGpvPge	8104020	Privé gebruik eigen bedrijf	C	4	\N	t
3826	1	WWivWav	8110000	Wijziging agrarische voorraden	C	3	\N	t
3827	1	WWivWavAaf	8110010	Aanwas fruitopstanden	C	4	\N	t
3828	1	WWivWavAav	8110020	Aanwas vee	C	4	\N	t
3829	1	WWivWavOvv	8110030	Overige voorraadmutaties	C	4	\N	t
3830	1	WWivWva	8120000	Waardeveranderingen van agrarische voorraden	D	3	\N	t
3831	1	WWivWvaWva	8120010	Waardeveranderingen van agrarische voorraden	D	4	\N	t
3832	1	WWivMrv	8130000	Marge-voorraden	D	3	\N	t
3833	1	WWivMrvMrv	8130010	Marge-voorraden	D	4	\N	t
3834	1	WKpr	70	Kostprijs van de omzet	D	2	\N	t
3835	1	WKprKvg	7001000	Kosten van grond- en hulpstoffen / halffabrikaten	D	3	\N	t
3836	1	WKprKvgKvg	7001010	Kosten van grond- en hulpstoffen, ingekocht in Nederland kosten van grond- en hulpstoffen	D	4	\N	t
3837	1	WKprKvgKgi	7001020	Kosten van grond- en hulpstoffen, ingekocht in het buitenland kosten van grond- en hulpstoffen	D	4	\N	t
3838	1	WKprKvgVrv	7001030	Voorraadverschillen grond- en hulpstoffen	D	4	\N	t
3839	1	WKprKvgPrv	7001040	Prijsverschillen inkoop grond- en hulpstoffen	D	4	\N	t
3840	1	WKprKvgKhn	7001050	Kosten van halffabrikaten, ingekocht in Nederland van halffabrikaten	D	4	\N	t
3841	1	WKprKvgKhb	7001060	Kosten van halffabrikaten, ingekocht in het buitenland van halffabrikaten	D	4	\N	t
3842	1	WKprKvgVvh	7001070	Voorraadverschillen halffabrikaten	D	4	\N	t
3843	1	WKprKvgPvh	7001080	Prijsverschillen halffabrikaten	D	4	\N	t
3844	1	WKprKvgDfw	7001099	Doorberekend / Overboeking ivm functionele indeling kosten van grond- en hulpstoffen / halffabrikaten	C	4	\N	t
3845	1	WKprKvp	7002000	Kosten van personeel	D	3	\N	t
3846	1	WKprKvpKvp	7002010	Kosten van personeel kosten van personeel	D	4	\N	t
3847	1	WKprKvpDfw	7002099	Doorberekend / Overboeking ivm functionele indeling kosten van personeel	C	4	\N	t
3848	1	WKprKuw	7003000	Kosten uitbesteed werk en andere externe kosten	D	3	\N	t
3849	1	WKprKuwKuw	7003010	Kosten van uitbesteed werk	D	4	\N	t
3850	1	WKprKuwAek	7003020	Andere externe kosten 	D	4	\N	t
3851	1	WKprKuwDfw	7003099	Doorberekend / Overboeking ivm functionele indeling kosten uitbesteed werk en andere externe kosten	C	4	\N	t
3852	1	WKprAkl	4301000	Toegerekende kosten	D	3	\N	t
3853	1	WKprAklTee	4301009	Teeltkosten toegerekende kosten	D	4	\N	t
3854	1	WKprAklZpe	4301010	Zaai, plant en pootgoedkosten toegerekende kosten	D	4	\N	t
3855	1	WKprAklSmk	4301020	Substraatmateriaalkosten toegerekende kosten	D	4	\N	t
3856	1	WKprAklBdm	4301030	Bemestingskosten dierlijke mest toegerekende kosten	D	4	\N	t
3857	1	WKprAklBek	4301040	Bemestingskosten kunstmest toegerekende kosten	D	4	\N	t
3858	1	WKprAklGew	4301050	Gewasbeschermingskosten toegerekende kosten	D	4	\N	t
3859	1	WKprAklGvk	4301060	Gewassenverzekeringskosten toegerekende kosten	D	4	\N	t
3860	1	WKprAklAft	4301070	Afvoerkosten teeltafval toegerekende kosten	D	4	\N	t
3861	1	WKprAklCoe	4301080	CO2-, OCAP- en waterkosten toegerekende kosten	D	4	\N	t
3862	1	WKprAklPeg	4301085	Potten en grondkosten toegerekende kosten	D	4	\N	t
3863	1	WKprAklOte	4301090	Overige teeltkosten toegerekende kosten	D	4	\N	t
3864	1	WKprAklGko	4301100	Gaskosten toegerekende kosten	D	4	\N	t
3865	1	WKprAklEkn	4301110	Elektrakosten toegerekende kosten	D	4	\N	t
3866	1	WKprAklWkn	4301115	Water kosten toegerekende kosten	D	4	\N	t
3867	1	WKprAklOwk	4301120	Onderhoudskosten WKK toegerekende kosten	D	4	\N	t
3868	1	WKprAklLew	4301130	Leasekosten WKK toegerekende kosten	D	4	\N	t
3869	1	WKprAklVkn	4301140	Veilingkosten toegerekende kosten	D	4	\N	t
3870	1	WKprAklAve	4301150	Afzet-, verpakking- en fustkosten toegerekende kosten	D	4	\N	t
3871	1	WKprAklPah	4301155	Pacht/huur toegerekende kosten	D	4	\N	t
3872	1	WKprAklTra	4301160	Transportkosten toegerekende kosten	D	4	\N	t
3873	1	WKprAklCtk	4301190	Contractteeltkosten toegerekende kosten	D	4	\N	t
3874	1	WKprAklVwa	4301200	Vergoeding werk aan derden toegerekende kosten	D	4	\N	t
3875	1	WKprAklPbk	4301210	Productbewerkingskosten toegerekende kosten	D	4	\N	t
3876	1	WKprAklAaf	4301230	Aanwas fruitopstanden toegerekende kosten	D	4	\N	t
3877	1	WKprAklSod	4301220	Sorteerkosten derden toegerekende kosten	D	4	\N	t
3878	1	WKprAklCkn	4301170	Compostkosten toegerekende kosten	D	4	\N	t
3879	1	WKprAklAfc	4301180	Afvoerkosten champost toegerekende kosten	D	4	\N	t
3880	1	WKprIna	7101000	Inkoopwaarde agrarisch	D	3	\N	t
3881	1	WKprInaLpk	7101010	Inkoopkosten planten opkweek inkoopwaarde agrarisch	D	4	\N	t
3882	1	WKprInaLph	7101020	Inkoopkosten planten handel inkoopwaarde agrarisch	D	4	\N	t
3883	1	WKprInaLpo	7101030	Inkoopkosten potten inkoopwaarde agrarisch	D	4	\N	t
3884	1	WKprInaLpt	7101040	Inkoopkosten potgrond inkoopwaarde agrarisch	D	4	\N	t
3885	1	WKprInaLbh	7101050	Inkoopkosten bloembollen handel inkoopwaarde agrarisch	D	4	\N	t
3886	1	WKprAkv	4302000	Agrarische bedrijfskosten veeteelt	D	3	\N	t
3887	1	WKprAkvVks	4302010	Voerkosten agrarische bedrijfskosten veeteelt	D	4	\N	t
3888	1	WKprAkvGez	4302020	Gezondheidszorgkosten agrarische bedrijfskosten veeteelt	D	4	\N	t
3889	1	WKprAkvKie	4302030	K.I./Fokkerijkosten agrarische bedrijfskosten veeteelt	D	4	\N	t
3890	1	WKprAkvTee	4302040	Teeltkosten agrarische bedrijfskosten veeteelt	D	4	\N	t
3891	1	WKprAkvSkn	4302050	Strooiselkosten agrarische bedrijfskosten veeteelt	D	4	\N	t
3892	1	WKprAkvEne	4302060	Energiekosten agrarische bedrijfskosten veeteelt	D	4	\N	t
3893	1	WKprAkvOve	4302070	Overige veekosten agrarische bedrijfskosten veeteelt	D	4	\N	t
3894	1	WKprAkvMes	4302080	Mestafzetkosten agrarische bedrijfskosten veeteelt	D	4	\N	t
3895	1	WKprAkvLep	4302090	Leasekosten productierechten agrarische bedrijfskosten veeteelt	D	4	\N	t
3896	1	WKprAkvEie	4302150	Eiergeld agrarische bedrijfskosten veeteelt	D	4	\N	t
3897	1	WKprAkvKvk	4302100	Krachtvoerkosten agrarische bedrijfskosten veeteelt	D	4	\N	t
3898	1	WKprAkvRuw	4302110	Ruwvoerkosten agrarische bedrijfskosten veeteelt	D	4	\N	t
3899	1	WKprAkvBik	4302130	Bijproducten kosten agrarische bedrijfskosten veeteelt	D	4	\N	t
3900	1	WKprAkvVgd	4302120	Voergeld agrarische bedrijfskosten veeteelt	D	4	\N	t
3901	1	WKprAkvAvb	4302190	Aankopen vee agrarische bedrijfskosten veeteelt	D	4	\N	t
3902	1	WKprAkvAam	4302160	Aankopen melkkoeien agrarische bedrijfskosten veeteelt	D	4	\N	t
3903	1	WKprAkvAjo	4302170	Aankopen jongvee ouder dan 1 jaar agrarische bedrijfskosten veeteelt	D	4	\N	t
3904	1	WKprAkvMel	4302180	Melkgeld agrarische bedrijfskosten veeteelt	D	4	\N	t
3905	1	WKprAkvLve	4302140	Inzet- vang- en laadkosten agrarische bedrijfskosten veeteelt	D	4	\N	t
3906	1	WKprKra	7004000	Kosten van rente, afschrijvingen en overig	D	3	\N	t
3907	1	WKprKraKra	7004010	Kosten van rente kosten van rente en afschrijvingen	D	4	\N	t
3908	1	WKprKraKva	7004020	Kosten van afschrijvingen kosten van rente en afschrijvingen	D	4	\N	t
3909	1	WKprKraOik	7004030	Opslag indirecte kosten	D	4	\N	t
3910	1	WKprKraOdk	7004040	Overige directe kosten	D	4	\N	t
3911	1	WKprKraDfw	7004099	Doorberekend / Overboeking ivm functionele indeling kosten van rente en afschrijvingen	C	4	\N	t
3912	1	WKprInh	7005000	Inkoopwaarde handelsgoederen	D	3	\N	t
3913	1	WKprInhInh	7005010	Inkoopwaarde handelsgoederen	D	4	\N	t
3914	1	WKprInhVrv	7005020	Voorraadverschillen handelsgoederen	D	4	\N	t
3915	1	WKprInhPrv	7005030	Prijsverschillen inkoop handelsgoederen	D	4	\N	t
3916	1	WKprInhMai	7005040	Margeinkopen 	D	4	\N	t
3917	1	WKprInhDfw	7005099	Doorberekend / Overboeking ivm functionele indeling inkoopwaarde handelsgoederen	C	4	\N	t
3918	1	WKprInp	7006000	Inkoopwaarde productiegoederen	D	3	\N	t
3919	1	WKprInpInp	7006010	Kostprijswaarde productiegoederen	D	4	\N	t
3920	1	WKprInpVrv	7006020	Voorraadverschillen productiegoederen	D	4	\N	t
3921	1	WKprInpPrv	7006030	Prijsverschillen productiegoederen	D	4	\N	t
3922	1	WKprInpDfw	7006099	Doorberekend / Overboeking ivm functionele indeling inkoopwaarde productiegoederen	C	4	\N	t
3923	1	WKprLeb	7007000	Inkoopkortingen en bonussen	C	3	\N	t
3924	1	WKprLebLeb	7007010	Inkoopkortingen en bonussen inkoopwaarde handels- en productiegoederen	C	4	\N	t
3925	1	WKprLebInp	7007020	Inkoopprovisie	C	4	\N	t
3926	1	WKprLebDfw	7007099	Doorberekend / Overboeking ivm functionele indeling inkoopkortingen en bonussen	D	4	\N	t
3927	1	WKprBtk	7008000	Betalingskortingen	D	3	\N	t
3928	1	WKprBtkBed	7008010	Betalingskorting debiteuren	D	4	\N	t
3929	1	WKprBtkBec	7008020	Betalingskortingen op inkopen inkoopwaarde handels- en productiegoederen	C	4	\N	t
3930	1	WKprBtkDfw	7008099	Doorberekend / Overboeking ivm functionele indeling betalingskortingen	C	4	\N	t
3931	1	WKprKit	7009000	Kostprijs intercompany transacties	D	3	\N	t
3932	1	WKprKitKit	7009010	Kostprijs intercompany transacties inkoopwaarde handels- en productiegoederen	D	4	\N	t
3933	1	WKprKitDfw	7009099	Doorberekend / Overboeking ivm functionele indeling intercompany transacties	C	4	\N	t
3934	1	WKprMuo	7010000	Mutatie omzetvorderingen	D	3	\N	t
3935	1	WKprMuoMuo	7010010	Mutatie omzetvorderingen inkoopwaarde handels- en productiegoederen	D	4	\N	t
3936	1	WKprMuoDfw	7010099	Doorberekend / Overboeking ivm functionele indeling mutatie omzetvorderingen	C	4	\N	t
3937	1	WKprVom	7011000	Voorraadmutatie	D	3	\N	t
3938	1	WKprVomVom	7011010	Voorraadmutatie inkoopwaarde handels- en productiegoederen	D	4	\N	t
3939	1	WKprVomDfw	7011099	Doorberekend / Overboeking ivm functionele indeling voorraadmutatie	C	4	\N	t
3940	1	WKprPrg	7012000	Privé-gebruik goederen	C	3	\N	t
3941	1	WKprPrgPrg	7012010	Privé-gebruik goederen inkoopwaarde handels- en productiegoederen	C	4	\N	t
3942	1	WKprPrgDfw	7012099	Doorberekend / Overboeking ivm functionele indeling privé-gebruik goederen	C	4	\N	t
3943	1	WKprPrd	7013000	Privé-gebruik diensten	C	3	\N	t
3944	1	WKprPrdPrd	7013010	Privé-gebruik diensten inkoopwaarde handels- en productiegoederen	C	4	\N	t
3945	1	WKprPrdDfw	7013099	Doorberekend / Overboeking ivm functionele indeling privé-gebruik diensten	C	4	\N	t
3946	1	WKprGrp	7200000	Kostprijs - inkoopwaarde groepen	D	3	\N	t
3947	1	WKprGrpGr1	7200100	Kostprijs - inkoopwaarde groep 1	D	4	\N	t
3948	1	WKprGrpGr1Pra	7200100.01	Kostprijs - inkoopwaarde groep 1 product A	D	5	\N	t
3949	1	WKprGrpGr1Prb	7200100.02	Kostprijs - inkoopwaarde groep 1 product B	D	5	\N	t
3950	1	WKprGrpGr1Prc	7200100.03	Kostprijs - inkoopwaarde groep 1 product C	D	5	\N	t
3951	1	WKprGrpGr1Prd	7200100.04	Kostprijs - inkoopwaarde groep 1 product D	D	5	\N	t
3952	1	WKprGrpGr1Pre	7200100.05	Kostprijs - inkoopwaarde groep 1 product E	D	5	\N	t
3953	1	WKprGrpGr2	7200200	Kostprijs - inkoopwaarde groep 2	D	4	\N	t
3954	1	WKprGrpGr2Pra	7200200.01	Kostprijs - inkoopwaarde groep 2 product A	D	5	\N	t
3955	1	WKprGrpGr2Prb	7200200.02	Kostprijs - inkoopwaarde groep 2 product B	D	5	\N	t
3956	1	WKprGrpGr2Prc	7200200.03	Kostprijs - inkoopwaarde groep 2 product C	D	5	\N	t
3957	1	WKprGrpGr2Prd	7200200.04	Kostprijs - inkoopwaarde groep 2 product D	D	5	\N	t
3958	1	WKprGrpGr2Pre	7200200.05	Kostprijs - inkoopwaarde groep 2 product E	D	5	\N	t
3959	1	WKprGrpGr3	7200300	Kostprijs - inkoopwaarde groep 3	D	4	\N	t
3960	1	WKprGrpGr3Pra	7200300.01	Kostprijs - inkoopwaarde groep 3 product A	D	5	\N	t
3961	1	WKprGrpGr3Prb	7200300.02	Kostprijs - inkoopwaarde groep 3 product B	D	5	\N	t
3962	1	WKprGrpGr3Prc	7200300.03	Kostprijs - inkoopwaarde groep 3 product C	D	5	\N	t
3963	1	WKprGrpGr3Prd	7200300.04	Kostprijs - inkoopwaarde groep 3 product D	D	5	\N	t
3964	1	WKprGrpGr3Pre	7200300.05	Kostprijs - inkoopwaarde groep 3 product E	D	5	\N	t
3965	1	WKprGrpGr4	7200400	Kostprijs - inkoopwaarde groep 4	D	4	\N	t
3966	1	WKprGrpGr4Pra	7200400.01	Kostprijs - inkoopwaarde groep 4 product A	D	5	\N	t
3967	1	WKprGrpGr4Prb	7200400.02	Kostprijs - inkoopwaarde groep 4 product B	D	5	\N	t
3968	1	WKprGrpGr4Prc	7200400.03	Kostprijs - inkoopwaarde groep 4 product C	D	5	\N	t
3969	1	WKprGrpGr4Prd	7200400.04	Kostprijs - inkoopwaarde groep 4 product D	D	5	\N	t
3970	1	WKprGrpGr4Pre	7200400.05	Kostprijs - inkoopwaarde groep 4 product E	D	5	\N	t
3971	1	WKprGrpGr5	7200500	Kostprijs - inkoopwaarde groep 5	D	4	\N	t
3972	1	WKprGrpGr5Pra	7200500.01	Kostprijs - inkoopwaarde groep 5 product A	D	5	\N	t
3973	1	WKprGrpGr5Prb	7200500.02	Kostprijs - inkoopwaarde groep 5 product B	D	5	\N	t
3974	1	WKprGrpGr5Prc	7200500.03	Kostprijs - inkoopwaarde groep 5 product C	D	5	\N	t
3975	1	WKprGrpGr5Prd	7200500.04	Kostprijs - inkoopwaarde groep 5 product D	D	5	\N	t
3976	1	WKprGrpGr5Pre	7200500.05	Kostprijs - inkoopwaarde groep 5 product E	D	5	\N	t
3977	1	WKprGrpDfw	7200999	Doorberekend / Overboeking ivm functionele indeling kostprijs - inkoopwaarde groepen	C	4	\N	t
3978	1	WKprOni	7201000	Kostprijs van de omzet niet ingekocht bij leden (Coöperatie)	D	3	\N	t
3979	1	WKprOniOn1	7201010	Kostprijs van de omzet niet ingekocht bij leden (Coöperatie)	D	4	\N	t
3980	1	WKprOniOn1Pra	7201010.01	Kostprijs van de omzet niet ingekocht bij leden product A	D	5	\N	t
3981	1	WKprOniOn1Prb	7201010.02	Kostprijs van de omzet niet ingekocht bij leden product B	D	5	\N	t
3982	1	WKprOniOn1Prc	7201010.03	Kostprijs van de omzet niet ingekocht bij leden product C	D	5	\N	t
3983	1	WKprOniOn1Prd	7201010.04	Kostprijs van de omzet niet ingekocht bij leden product D	D	5	\N	t
3984	1	WKprOniOn1Pre	7201010.05	Kostprijs van de omzet niet ingekocht bij leden product E	D	5	\N	t
3985	1	WKprTvl	7202000	Totaal van lasten	D	3	\N	t
3986	1	WKprTvlIgp	7202100	Inkoopwaarde van geleverde producten	D	4	\N	t
3987	1	WKprTvlIgpIgp	7202110	Inkoopwaarde van geleverde producten	D	5	\N	t
3988	1	WKprTvlVsg	7202200	Verstrekte subsidies of giften	D	4	\N	t
3989	1	WKprTvlVsgVsg	7202210	Verstrekte subsidies of giften	D	5	\N	t
3990	1	WKprTvlLbd	7203100	Lasten besteed aan doelstellingen	D	4	\N	t
3991	1	WKprTvlLbdLbd	7203100.01	Lasten besteed aan doelstellingen - overige	D	5	\N	t
3992	1	WKprTvlLbdLsb	7203100.02	Lasten van subsidies en bijdragen	D	5	\N	t
3993	1	WKprTvlLbdAvo	7203100.03	Afdrachten aan verbonden (internationale) organisaties	D	5	\N	t
3994	1	WKprTvlLbdLav	7203100.04	Lasten van aankopen en verwervingen	D	5	\N	t
3995	1	WKprTvlLbdKuw	7203100.05	Kosten van uitbesteed werk	D	5	\N	t
3996	1	WKprTvlLbdCom	7203100.06	Communicatiekosten	D	5	\N	t
3997	1	WKprTvlLbdPer	7203100.07	Lasten uit hoofde van personeelsbeloningen	D	5	\N	t
3998	1	WKprTvlLbdHui	7203100.08	Huisvestingskosten	D	5	\N	t
3999	1	WKprTvlLbdKan	7203100.09	Kantoor- en algemene kosten	D	5	\N	t
4000	1	WKprTvlLbdAfs	7203100.10	Afschrijvingen	D	5	\N	t
4001	1	WKprTvlWko	7203200	Wervingskosten	D	4	\N	t
4002	1	WKprTvlWkoWko	7203200.01	Wervingskosten - overige	D	5	\N	t
4003	1	WKprTvlWkoLsb	7203200.02	Lasten van subsidies en bijdragen	D	5	\N	t
4004	1	WKprTvlWkoAvo	7203200.03	Afdrachten aan verbonden (internationale) organisaties	D	5	\N	t
4005	1	WKprTvlWkoLav	7203200.04	Lasten van aankopen en verwervingen	D	5	\N	t
4006	1	WKprTvlWkoKuw	7203200.05	Kosten van uitbesteed werk	D	5	\N	t
4007	1	WKprTvlWkoCom	7203200.06	Communicatiekosten	D	5	\N	t
4008	1	WKprTvlWkoPer	7203200.07	Lasten uit hoofde van personeelsbeloningen	D	5	\N	t
4009	1	WKprTvlWkoHui	7203200.08	Huisvestingskosten	D	5	\N	t
4010	1	WKprTvlWkoKan	7203200.09	Kantoor- en algemene kosten	D	5	\N	t
4011	1	WKprTvlWkoAfs	7203200.10	Afschrijvingen	D	5	\N	t
4012	1	WKprTvlKba	7203300	Kosten van beheer en administratie	D	4	\N	t
4013	1	WKprTvlKbaKba	7203300.01	Kosten van beheer en administratie - overige	D	5	\N	t
4014	1	WKprTvlKbaLsb	7203300.02	Lasten van subsidies en bijdragen	D	5	\N	t
4015	1	WKprTvlKbaAvo	7203300.03	Afdrachten aan verbonden (internationale) organisaties	D	5	\N	t
4016	1	WKprTvlKbaLav	7203300.04	Lasten van aankopen en verwervingen	D	5	\N	t
4017	1	WKprTvlKbaKuw	7203300.05	Kosten van uitbesteed werk	D	5	\N	t
4019	1	WKprTvlKbaPer	7203300.07	Lasten uit hoofde van personeelsbeloningen	D	5	\N	t
4020	1	WKprTvlKbaHui	7203300.08	Huisvestingskosten	D	5	\N	t
4021	1	WKprTvlKbaKan	7203300.09	Kantoor- en algemene kosten	D	5	\N	t
4022	1	WKprTvlKbaAfs	7203300.10	Afschrijvingen	D	5	\N	t
4023	1	WKprTvlAla	7204000	Andere lasten	D	4	\N	t
4024	1	WKprTvlAlaAla	7204010	Andere lasten	D	5	\N	t
4025	1	WKprEmb	7205000	Emballage	D	3	\N	t
4026	1	WKprEmbKst	7205100	Kosten afgekeurde emballage	D	4	\N	t
4027	1	WKprEmbRes	7205200	Resultaat niet retour gekomen emballage	D	4	\N	t
4028	1	WKprKvm	7206000	Kosten van materieel	D	3	\N	t
4029	1	WKprKvmKvm	7206100	Kosten van materieel	D	4	\N	t
4030	1	WOvb	82	Overige bedrijfsopbrengsten	C	2	\N	t
4031	1	WOvbLpd	8215000	Baten als tegenprestatie voor de levering van producten en/of diensten	C	3	\N	t
4032	1	WOvbLpdLpd	8215010	Baten als tegenprestatie voor de levering van producten en/of diensten	C	4	\N	t
4033	1	WOvbLpdLpdDnb	8215010.01	Deelnemersbijdragen	C	5	\N	t
4034	1	WOvbLpdLpdAbg	8215010.02	Abonnementsgelden	C	5	\N	t
4035	1	WOvbLpdLpdHuo	8215010.03	Huuropbrengsten	C	5	\N	t
4036	1	WOvbLpdLpdRec	8215010.04	Recettes	C	5	\N	t
4037	1	WOvbOrs	8207000	Subsidiebaten	C	3	\N	t
4038	1	WOvbOrsOel	8207010	Overheidssubsidies exclusief loonkostensubsidies subsidiebaten	C	4	\N	t
4039	1	WOvbOrsOre	8207015	Ontvangen restituties en subsidies subsidiebaten	C	4	\N	t
4040	1	WOvbOrsOreOsa	8207020	Ontvangen loonsubsidies subsidiebaten	C	5	\N	t
4041	1	WOvbOrsOreOar	8207030	Ontvangen afdrachtrestituties subsidiebaten	C	5	\N	t
4042	1	WOvbOrsOreEeo	8207040	Export- en overige restituties en subsidies ingevolge EU-regelingen subsidiebaten	C	5	\N	t
4043	1	WOvbOrsOsu	8207050	Overige ontvangen subsidies subsidiebaten	C	4	\N	t
4044	1	WOvbOrsOsuSro	8207050.01	Subsidiebaten van rijksoverheden subsidiebaten	C	5	\N	t
4045	1	WOvbOrsOsuSov	8207050.02	Subsidiebaten van overheden subsidiebaten	C	5	\N	t
4046	1	WOvbOrsOsuSoo	8207050.03	Subsidiebaten van overige overheden subsidiebaten	C	5	\N	t
4047	1	WOvbOrsOsuSeu	8207050.04	Subsidiebaten van de Europese Unie subsidiebaten	C	5	\N	t
4048	1	WOvbOrsOsuSbd	8207050.05	Subsidiebaten van bedrijven subsidiebaten	C	5	\N	t
4049	1	WOvbOrsOsuSpo	8207050.06	Subsidiebaten van private organisaties subsidiebaten	C	5	\N	t
4050	1	WOvbOrsOsuSop	8207050.07	Subsidiebaten van overige private organisaties subsidiebaten	C	5	\N	t
4051	1	WOvbSpd	8216000	Sponsorbijdragen	C	3	\N	t
4052	1	WOvbSpdSpd	8216010	Sponsorbijdragen	C	4	\N	t
4053	1	WOvbBue	8203000	Baten en giften uit fondsenwerving	C	3	\N	t
4054	1	WOvbBueCol	8203010	Collecten	C	4	\N	t
4055	1	WOvbBueDeg	8203020	Donaties en giften	C	4	\N	t
4056	1	WOvbBueCtb	8203030	Contributies	C	4	\N	t
4057	1	WOvbBueSpo	8203040	Sponsoring	C	4	\N	t
4058	1	WOvbBueNal	8203050	Nalatenschappen	C	4	\N	t
4059	1	WOvbBueEle	8203060	Eigen loterijen en prijsvragen	C	4	\N	t
4060	1	WOvbBueVeg	8203070	Verkoop goederen	C	4	\N	t
4061	1	WOvbBueObu	8203080	Overige baten uit fondsenwerving	C	4	\N	t
4062	1	WOvbBug	8204000	Baten uit gezamenlijke acties	C	3	\N	t
4063	1	WOvbBugCol	8204010	Collecten	C	4	\N	t
4064	1	WOvbBugDeg	8204020	Donaties en giften	C	4	\N	t
4065	1	WOvbBugCtb	8204030	Contributies	C	4	\N	t
4066	1	WOvbBugSpo	8204040	Sponsoring	C	4	\N	t
4067	1	WOvbBugNal	8204050	Nalatenschappen	C	4	\N	t
4068	1	WOvbBugEle	8204060	Eigen loterijen en prijsvragen	C	4	\N	t
4069	1	WOvbBugVeg	8204070	Verkoop goederen	C	4	\N	t
4070	1	WOvbBugObu	8204080	Overige baten uit fondsenwerving	C	4	\N	t
4071	1	WOvbBua	8205000	Baten uit acties van derden	C	3	\N	t
4072	1	WOvbBuaCol	8205010	Collecten	C	4	\N	t
4073	1	WOvbBuaDeg	8205020	Donaties en giften	C	4	\N	t
4074	1	WOvbBuaCtb	8205030	Contributies	C	4	\N	t
4075	1	WOvbBuaSpo	8205040	Sponsoring	C	4	\N	t
4076	1	WOvbBuaNal	8205050	Nalatenschappen	C	4	\N	t
4077	1	WOvbBuaEle	8205060	Eigen loterijen en prijsvragen	C	4	\N	t
4078	1	WOvbBuaVeg	8205070	Verkoop goederen	C	4	\N	t
4079	1	WOvbBuaObu	8205080	Overige baten uit fondsenwerving	C	4	\N	t
4080	1	WOvbHuo	8208000	Huurontvangsten	C	3	\N	t
4081	1	WOvbHuoHuo	8208010	Huurontvangsten baten uit overige activiteiten	C	4	\N	t
4082	1	WOvbOps	8209000	Opbrengsten servicecontracten	C	3	\N	t
4083	1	WOvbOpsOps	8209010	Opbrengsten servicecontracten baten uit overige activiteiten	C	4	\N	t
4084	1	WOvbCcl	8211000	College-, cursus-, les- en examengelden	C	3	\N	t
4085	1	WOvbCclCcl	8211010	College-, cursus-, les- en examengelden baten uit overige activiteiten	C	4	\N	t
4086	1	WOvbNvv	8210000	Netto verkoopresultaat vastgoedportefeuille	C	3	\N	t
4087	1	WOvbNvvNvv	8210010	Netto verkoopresultaat vastgoedportefeuille baten uit overige activiteiten	C	4	\N	t
4088	1	WOvbBwi	8212000	Baten werk in opdracht van derden	C	3	\N	t
4089	1	WOvbBwiBwi	8212010	Baten werk in opdracht van derden baten uit overige activiteiten	C	4	\N	t
4090	1	WOvbOnm	8201000	Ontvangen managementvergoeding	C	3	\N	t
4091	1	WOvbOnmOnm	8201010	Ontvangen managementvergoeding baten uit overige activiteiten	C	4	\N	t
4092	1	WOvbOdp	8202000	Ontvangen doorbelasting personeelskosten	C	3	\N	t
4161	1	WPerLesLin	4001100	Lonen in natura lonen en salarissen	D	4	\N	t
4093	1	WOvbOdpOdp	8202010	Ontvangen doorbelasting personeelskosten baten uit overige activiteiten	C	4	\N	t
4094	1	WOvbOvo	8213000	Overige opbrengsten	C	3	\N	t
4095	1	WOvbOvoOvo	8213010	Overige opbrengsten niet elders genoemd baten uit overige activiteiten	C	4	\N	t
4096	1	WOvbVez	8206000	Verzekeringsuitkeringen	C	3	\N	t
4097	1	WOvbVezUib	8206010	Uitkering bedrijfsschadeverzekering verzekeringsuitkeringen	C	4	\N	t
4098	1	WOvbVezOvu	8206020	Overige verzekeringsuitkeringen verzekeringsuitkeringen	C	4	\N	t
4099	1	WOvbSgb	8214000	Som van de (geworven) baten	C	3	\N	t
4100	1	WOvbSgbBvd	8214100	Bijdragen van donateurs	C	4	\N	t
4101	1	WOvbSgbBvdBvd	8214110	Bijdragen van donateurs	C	5	\N	t
4102	1	WOvbSgbBvl	8214200	Bijdragen van leden	C	4	\N	t
4103	1	WOvbSgbBvlBvl	8214210	Bijdragen van leden	C	5	\N	t
4104	1	WOvbSgbBvp	8214300	Baten van particulieren	C	4	\N	t
4105	1	WOvbSgbBvpBvp	8214310	Collecten	C	5	\N	t
4106	1	WOvbSgbBvpNal	8214320	Nalatenschappen	C	5	\N	t
4107	1	WOvbSgbBvpCtb	8214330	Contributies	C	5	\N	t
4108	1	WOvbSgbBvpDeg	8214340	Donaties en giften	C	5	\N	t
4109	1	WOvbSgbBvpEle	8214350	Eigen loterijen en prijsvragen	C	5	\N	t
4110	1	WOvbSgbBvpObu	8214380	Overige baten uit fondsenwerving	C	5	\N	t
4111	1	WOvbSgbBvb	8214400	Baten van bedrijfsleven	C	4	\N	t
4112	1	WOvbSgbBvbBvb	8214410	Baten van bedrijfsleven	C	5	\N	t
4113	1	WOvbSgbBlo	8214500	Baten van loterijorganisaties	C	4	\N	t
4114	1	WOvbSgbBloBlo	8214510	Baten van loterijorganisaties	C	5	\N	t
4115	1	WOvbSgbBso	8214600	Baten van subsidies van overheden	C	4	\N	t
4116	1	WOvbSgbBsoBso	8214610	Baten van subsidies van overheden	C	5	\N	t
4117	1	WOvbSgbBvo	8214700	Baten van verbonden organisaties zonder winststreven	C	4	\N	t
4118	1	WOvbSgbBvoBvo	8214710	Baten van verbonden organisaties zonder winststreven	C	5	\N	t
4119	1	WOvbSgbBvoBio	8214720	Baten van verbonden (internationale) organisaties	C	5	\N	t
4120	1	WOvbSgbBao	8214800	Baten van andere organisaties zonder winststreven	C	4	\N	t
4121	1	WOvbSgbBaoBao	8214810	Baten van andere organisaties zonder winststreven	C	5	\N	t
4122	1	WOvbSgbAnb	8214900	Andere baten	C	4	\N	t
4123	1	WOvbSgbAnbAnb	8214910	Andere baten	C	5	\N	t
4124	1	WOvbEsu	8218900	Exploitatiesubsidies	C	3	\N	t
4125	1	WOvbEsuEsu	8218910	Exploitatiesubsidies	C	4	\N	t
4126	1	WOvbDob	8219000	Doorberekening overige bedrijfsopbrengsten	C	3	\N	t
4127	1	WOvbDobEvp	8219000.01	Doorberekening overige bedrijfsopbrengsten netto resultaat exploitatie vastgoedportefeuille	C	4	\N	t
4128	1	WOvbDobVvo	8219000.02	Doorberekening overige bedrijfsopbrengsten netto resultaat verkocht vastgoed in ontwikkeling	C	4	\N	t
4129	1	WOvbDobGrv	8219000.03	Doorberekening overige bedrijfsopbrengsten netto gerealiseerd resultaat verkoop vastgoedportefeuille	C	4	\N	t
4130	1	WOvbDobWvp	8219000.04	Doorberekening overige bedrijfsopbrengsten waardeveranderingen vastgoedportefeuille	C	4	\N	t
4131	1	WOvbDobOac	8219000.05	Doorberekening overige bedrijfsopbrengsten netto resultaat overige activiteiten	C	4	\N	t
4132	1	WOvbDobLbh	8219000.06	Doorberekening overige bedrijfsopbrengsten kosten leefbaarheid	C	4	\N	t
4133	1	WPer	40	Lasten uit hoofde van personeelsbeloningen	D	2	\N	t
4134	1	WPerLes	4001000	Lonen en salarissen	D	3	\N	t
4135	1	WPerLesSld	4001010	Bezoldiging van bestuurders en gewezen bestuurders lonen en salarissen	D	4	\N	t
4136	1	WPerLesSldPbb	4001010.01	Periodiek betaalde beloning van een bestuurder lonen en salarissen	D	5	\N	t
4137	1	WPerLesSldBtb	4001010.02	Beloningen betaalbaar op termijn van een bestuurder lonen en salarissen	D	5	\N	t
4138	1	WPerLesSldUbb	4001010.03	Uitkeringen bij beëindiging van het dienstverband van een bestuurder lonen en salarissen	D	5	\N	t
4139	1	WPerLesSldWbb	4001010.04	Winstdelingen en bonusbetalingen van een bestuurder lonen en salarissen	D	5	\N	t
4140	1	WPerLesBvc	4001020	Bezoldiging van commissarissen en gewezen commissarissen lonen en salarissen	D	4	\N	t
4141	1	WPerLesBvcPbc	4001020.01	Periodiek betaalde beloning van een commissaris lonen en salarissen	D	5	\N	t
4142	1	WPerLesBvcBtc	4001020.02	Beloningen betaalbaar op termijn van een commissaris lonen en salarissen	C	5	\N	t
4143	1	WPerLesBvcUbc	4001020.03	Uitkeringen bij beëindiging van het dienstverband van een commissaris lonen en salarissen	D	5	\N	t
4144	1	WPerLesBvcWbc	4001020.04	Winstdelingen en bonusbetalingen van een commissaris lonen en salarissen	D	5	\N	t
4145	1	WPerLesBvcKit	4001020.05	Kosten intern toezicht	D	5	\N	t
4146	1	WPerLesTep	4001030	Tantièmes en provisie lonen en salarissen	D	4	\N	t
4147	1	WPerLesLon	4001040	Lonen en salarissen	D	4	\N	t
4148	1	WPerLesLonLon	4001040.01	Lonen en salarissen	D	5	\N	t
4149	1	WPerLesLonVvg	4001040.02	Lonen vervanging	D	5	\N	t
4150	1	WPerLesLonCor	4001040.03	Lonen salariscorrectie	D	5	\N	t
4151	1	WPerLesOwe	4001050	Overwerk lonen en salarissen	D	4	\N	t
4152	1	WPerLesOnr	4001060	Onregelmatigheidstoeslag lonen en salarissen	D	4	\N	t
4153	1	WPerLesVag	4001070	Vakantiebijslag lonen en salarissen	D	4	\N	t
4154	1	WPerLesVagVag	4001070.01	Vakantiebijslag lonen en salarissen	D	5	\N	t
4155	1	WPerLesVagVld	4001070.02	Vakantiebijslag uitbetaling verlofdagen	D	5	\N	t
4156	1	WPerLesVagVlu	4001070.03	Vakantiebijslag restant verlofuren	D	5	\N	t
4157	1	WPerLesVad	4001080	Vakantiedagen lonen en salarissen	D	4	\N	t
4158	1	WPerLesGra	4001090	Gratificaties lonen en salarissen	D	4	\N	t
4159	1	WPerLesGraGra	4001090.01	Gratificaties lonen en salarissen	D	5	\N	t
4162	1	WPerLesTls	4001110	Spaarloon lonen en salarissen	D	4	\N	t
4163	1	WPerLesOnu	4001140	Ontslaguitkeringen lonen en salarissen	D	4	\N	t
4164	1	WPerLesLiv	4001150	Op aandelen gebaseerde betalingen opgenomen onder lonen en salarissen	D	4	\N	t
4165	1	WPerLesLoo	4001120	Loonkostenreductie lonen en salarissen	C	4	\N	t
4166	1	WPerLesOvt	4001130	Overige toeslagen lonen en salarissen	D	4	\N	t
4167	1	WPerLesOlr	4001160	Overige lonen en salarissen lonen en salarissen	D	4	\N	t
4168	1	WPerLesOlrOlr	4001160.01	Overige lonen en salarissen lonen en salarissen	D	5	\N	t
4169	1	WPerLesOlrWpt	4001160.02	Overige lonen en salarissen wachtgeld/piket	D	5	\N	t
4170	1	WPerLesOlrSvg	4001160.03	Overige lonen en salarissen stagevergoeding	D	5	\N	t
4171	1	WPerLesOlrRvc	4001160.04	Overige lonen en salarissen kosten RVC niet salaris	D	5	\N	t
4172	1	WPerLesOlrNtb	4001160.05	Overige lonen en salarissen nb/bt	D	5	\N	t
4173	1	WPerLesLks	4001170	Loonkostensubsidie (LIV) lonen en salarissen	C	4	\N	t
4174	1	WPerLesOls	4001180	Overige loon(kosten)subsidies	C	4	\N	t
4175	1	WPerLesEuk	4001190	Eindejaarsuitkering	D	4	\N	t
4176	1	WPerLesDle	4001990	Doorberekende Lonen en salarissen lonen en salarissen	C	4	\N	t
4177	1	WPerLesDfw	4001999	Doorberekend / Overboeking ivm functionele indeling lonen en salarissen	C	4	\N	t
4178	1	WPerSol	4002000	Sociale lasten	D	3	\N	t
4179	1	WPerSolPsv	4002010	Premies sociale verzekeringen sociale lasten	D	4	\N	t
4180	1	WPerSolBiz	4002020	Bijdrage ziektekostenverzekering sociale lasten	D	4	\N	t
4181	1	WPerSolOpr	4002030	Overige premies sociale lasten	D	4	\N	t
4182	1	WPerSolOsf	4002040	Overige sociale fondsen sociale lasten	D	4	\N	t
4183	1	WPerSolOss	4002050	Overige sociale lasten sociale lasten	D	4	\N	t
4184	1	WPerSolOssOss	4002050.01	Overige sociale lasten sociale lasten	D	5	\N	t
4185	1	WPerSolOssLeh	4002050.02	Overige sociale lasten loonheffing eindheffing	D	5	\N	t
4186	1	WPerSolOssPkg	4002050.03	Overige sociale lasten premiekortingen	D	5	\N	t
4187	1	WPerSolOssRvl	4002050.04	Overige sociale lasten restant verlofuren - verlofdagen	D	5	\N	t
4188	1	WPerSolOssRvg	4002050.05	Overige sociale lasten restant vakantiegeld	D	5	\N	t
4189	1	WPerSolOssRvd	4002050.06	Overige sociale lasten restant vakantiedagen	D	5	\N	t
4190	1	WPerSolOssErd	4002060	Eigen risicodragerschap	D	5	\N	t
4191	1	WPerSolDsl	4002990	Doorberekende sociale lasten sociale lasten	C	4	\N	t
4192	1	WPerSolDfw	4002999	Doorberekend / Overboeking ivm functionele indeling sociale lasten	C	4	\N	t
4193	1	WPerPen	4003000	Pensioenlasten	D	3	\N	t
4194	1	WPerPenPen	4003010	Pensioenpremies pensioenlasten	D	4	\N	t
4195	1	WPerPenPenPen	4003010.01	Pensioenpremies	D	5	\N	t
4196	1	WPerPenPenPpe	4003010.02	Pensioenpremies PP	D	5	\N	t
4197	1	WPerPenPenOvp	4003010.03	Pensioenpremies OVP	D	5	\N	t
4198	1	WPerPenAap	4003015	Aanvullende pensioenlasten pensioenlasten	D	4	\N	t
4199	1	WPerPenAapAap	4003015.01	Aanvullende pensioenlasten	D	5	\N	t
4200	1	WPerPenAapWex	4003015.02	Aanvullende pensioenlasten WIA excedent	D	5	\N	t
4201	1	WPerPenAapWpp	4003015.03	Aanvullende pensioenlasten WIA PP	D	5	\N	t
4202	1	WPerPenDpe	4003020	Dotatie pensioenvoorziening directie	D	4	\N	t
4203	1	WPerPenVpv	4003030	Vrijval pensioenvoorziening directie	C	4	\N	t
4204	1	WPerPenDvb	4003040	Dotatie voorziening backserviceverplichting directie	D	4	\N	t
4205	1	WPerPenVvb	4003050	Vrijval voorziening backserviceverplichting directie	C	4	\N	t
4206	1	WPerPenDvl	4003060	Dotatie voorziening lijfrenteverplichtingen	D	4	\N	t
4207	1	WPerPenVvl	4003070	Vrijval voorziening lijfrenteverplichtingen	C	4	\N	t
4208	1	WPerPenOpe	4003080	Overige pensioenlasten	D	4	\N	t
4209	1	WPerPenOpeOpe	4003080.01	Overige pensioenlasten	D	5	\N	t
4210	1	WPerPenOpeFlw	4003080.02	Overige pensioenlasten FLOW	D	5	\N	t
4211	1	WPerPenDon	4003990	Doorberekende pensioenlasten	C	4	\N	t
4212	1	WPerPenDfw	4003995	Doorberekend / Overboeking ivm functionele indeling pensioenlasten	C	4	\N	t
4213	1	WPerOlu	4004008	Overige lasten uit hoofde van personeelsbeloningen	D	3	\N	t
4214	1	WPerOluOlp	4004009	Overige lasten met betrekking tot personeelsbeloningen overige lasten uit hoofde van personeelsbeloningen	D	4	\N	t
4215	1	WPerOluDfw	4004099	Doorberekend / Overboeking ivm functionele indeling overige lasten personeel	C	4	\N	t
4216	1	WAfs	41	Afschrijvingen op immateriële en materiële vaste activa	D	2	\N	t
4217	1	WAfsAiv	4101000	Afschrijvingen op immateriële vaste activa	D	3	\N	t
4218	1	WAfsAivOek	4101010	Afschrijvingen kosten van oprichting en van uitgifte van aandelen afschrijvingen op immateriële vaste activa	D	4	\N	t
4219	1	WAfsAivKoe	4101020	Afschrijvingen kosten van ontwikkeling afschrijvingen op immateriële vaste activa	D	4	\N	t
4220	1	WAfsAivCev	4101030	Afschrijvingen concessies, vergunningen en intellectuele eigendom afschrijvingen op immateriële vaste activa	D	4	\N	t
4221	1	WAfsAivGoo	4101070	Afschrijvingen goodwill - fiscaal aftrekbaar - afschrijvingen op immateriële vaste activa	D	4	\N	t
4222	1	WAfsAivGon	4101075	Afschrijvingen goodwill - fiscaal niet aftrekbaar - afschrijvingen op immateriële vaste activa	D	4	\N	t
4223	1	WAfsAivViv	4101090	Afschrijvingen vooruitbetalingen op immateriële vaste activa afschrijvingen op immateriële vaste activa	D	4	\N	t
4224	1	WAfsAivOiv	4101100	Afschrijvingen overige immateriële vaste activa afschrijvingen op immateriële vaste activa	D	4	\N	t
4225	1	WAfsAivBou	4101200	Afschrijvingen bouwclaims	D	4	\N	t
4226	1	WAfsAivDfw	4101299	Doorberekend / Overboeking ivm functionele indeling afschrijvingen op immateriële vaste activa	C	4	\N	t
4227	1	WAfsAmv	4102000	Afschrijvingen op materiële vaste activa	D	3	\N	t
4228	1	WAfsAmvAft	4102005	Afschrijvingen Terreinen 	D	4	\N	t
4229	1	WAfsAmvBeg	4102010	Afschrijvingen Bedrijfsgebouwen 	D	4	\N	t
4230	1	WAfsAmvHuu	4102040	Afschrijvingen Huurdersinvesteringen 	D	4	\N	t
4231	1	WAfsAmvVeb	4102020	Afschrijvingen Verbouwingen 	D	4	\N	t
4232	1	WAfsAmvMei	4102050	Afschrijvingen Machines en installaties 	D	4	\N	t
4233	1	WAfsAmvObe	4102080	Afschrijvingen Andere vaste bedrijfsmiddelen 	D	4	\N	t
4234	1	WAfsAmvSev	4102060	Afschrijvingen Vliegtuigen 	D	4	\N	t
4235	1	WAfsAmvAfs	4102065	Afschrijvingen Schepen 	D	4	\N	t
4236	1	WAfsAmvTev	4102070	Afschrijvingen Automobielen en overige transportmiddelen 	D	4	\N	t
4237	1	WAfsAmvBei	4102090	Afschrijvingen Inventaris 	D	4	\N	t
4238	1	WAfsAmvAmp	4102095	Afschrijvingen Meerjaren plantopstanden 	D	4	\N	t
4239	1	WAfsAmvAfg	4102096	Afschrijvingen Gebruiksvee 	D	4	\N	t
4240	1	WAfsAmvVbi	4102100	Afschrijvingen Vaste bedrijfsmiddelen in uitvoering 	D	4	\N	t
4241	1	WAfsAmvAvm	4102105	Afschrijvingen Vooruitbetalingen op materiële vaste activa 	D	4	\N	t
4242	1	WAfsAmvBgm	4102110	Afschrijvingen Niet aan de bedrijfsuitoefening dienstbare materiële vaste activa 	D	4	\N	t
4243	1	WAfsAmvOrz	4102120	Afschrijvingen Onroerende en roerende zaken ten dienste van de exploitatie	D	4	\N	t
4244	1	WAfsAmvDfw	4102199	Doorberekend / Overboeking ivm functionele indeling afschrijvingen op materiële vaste activa	C	4	\N	t
4245	1	WAfsAfv	4103008	Afschrijvingen vastgoed	D	3	\N	t
4246	1	WAfsAfvAvo	4103009	Afschrijvingen vastgoedbeleggingen in ontwikkeling afschrijvingen vastgoed	D	4	\N	t
4247	1	WAfsAfvAve	4103010	Afschrijvingen vastgoedbeleggingen in exploitatie afschrijvingen vastgoed	D	4	\N	t
4248	1	WAfsAfvDfw	4103099	Doorberekend / Overboeking ivm functionele indeling afschrijvingen vastgoed	C	4	\N	t
4249	1	WAfsRvi	4105000	Winsten of verliezen die ontstaan als gevolg van de buitengebruikstelling of afstoting van een immaterieel vast actief	C	3	\N	t
4250	1	WAfsRviOek	4105010	Boekresultaat kosten van oprichting en van uitgifte van aandelen boekresultaat op immateriële vaste activa	C	4	\N	t
4251	1	WAfsRviKoe	4105020	Boekresultaat kosten van ontwikkeling boekresultaat op immateriële vaste activa	C	4	\N	t
4252	1	WAfsRviCev	4105030	Boekresultaat concessies, vergunningen en intellectuele eigendom boekresultaat op immateriële vaste activa	C	4	\N	t
4253	1	WAfsRviGoo	4105070	Boekresultaat goodwill boekresultaat op immateriële vaste activa	C	4	\N	t
4254	1	WAfsRviViv	4105090	Boekresultaat vooruitbetalingen op immateriële vaste activa boekresultaat op immateriële vaste activa	C	4	\N	t
4255	1	WAfsRviOiv	4105100	Boekresultaat overige immateriële vaste activa boekresultaat op immateriële vaste activa	C	4	\N	t
4256	1	WAfsRviBou	4105200	Boekresultaat bouwclaims boekresultaat op immateriële vaste activa	C	4	\N	t
4257	1	WAfsRviDfw	4105299	Doorberekend / Overboeking ivm functionele indeling boekresultaat immateriële vaste activa	C	4	\N	t
4258	1	WAfsRvm	4106000	Winsten of verliezen die ontstaan als gevolg van de buitengebruikstelling of afstoting van een materieel vast actief	C	3	\N	t
4259	1	WAfsRvmBrt	4106005	Boekresultaat Terreinen boekresultaat op materiële vaste activa	C	4	\N	t
4260	1	WAfsRvmBeg	4106010	Boekresultaat Bedrijfsgebouwen boekresultaat op materiële vaste activa	C	4	\N	t
4261	1	WAfsRvmHuu	4106040	Boekresultaat Huurdersinvesteringen boekresultaat op materiële vaste activa	C	4	\N	t
4262	1	WAfsRvmVeb	4106020	Boekresultaat Verbouwingen boekresultaat op materiële vaste activa	C	4	\N	t
4263	1	WAfsRvmMei	4106050	Boekresultaat Machines en installaties boekresultaat op materiële vaste activa	C	4	\N	t
4264	1	WAfsRvmObe	4106080	Boekresultaat Andere vaste bedrijfsmiddelen boekresultaat op materiële vaste activa	C	4	\N	t
4265	1	WAfsRvmSev	4106060	Boekresultaat Vliegtuigen boekresultaat op materiële vaste activa	C	4	\N	t
4266	1	WAfsRvmSch	4106065	Boekresultaat Schepen boekresultaat op materiële vaste activa	C	4	\N	t
4267	1	WAfsRvmTev	4106070	Boekresultaat Automobielen en overige transportmiddelen boekresultaat op materiële vaste activa	C	4	\N	t
4268	1	WAfsRvmBei	4106090	Boekresultaat Inventaris boekresultaat op materiële vaste activa	C	4	\N	t
4269	1	WAfsRvmBmp	4106095	Boekresultaat Meerjaren plantopstanden boekresultaat op materiële vaste activa	C	4	\N	t
4270	1	WAfsRvmBgv	4106096	Boekresultaat Gebruiksvee boekresultaat op materiële vaste activa	C	4	\N	t
4271	1	WAfsRvmVbi	4106100	Boekresultaat Vaste bedrijfsmiddelen in uitvoering boekresultaat op materiële vaste activa	C	4	\N	t
4272	1	WAfsRvmBvm	4106105	Boekresultaat Vooruitbetalingen op materiële vaste activa boekresultaat op materiële vaste activa	C	4	\N	t
4273	1	WAfsRvmBgm	4106110	Boekresultaat Niet aan de bedrijfsuitoefening dienstbare materiële vaste activa boekresultaat op materiële vaste activa	C	4	\N	t
4274	1	WAfsRvmOrz	4106120	Boekresultaat Onroerende en roerende zaken ten dienste van de exploitatie	C	4	\N	t
4275	1	WAfsRvmDfw	4106199	Doorberekend / Overboeking ivm functionele indeling boekresultaat materiële vaste activa	C	4	\N	t
4276	1	WAfsBov	4107000	Boekresultaat vastgoed	C	3	\N	t
4277	1	WAfsBovBvo	4107010	Boekresultaat vastgoedbeleggingen in ontwikkeling boekresultaat vastgoed	C	4	\N	t
4278	1	WAfsBovBve	4107020	Boekresultaat vastgoedbeleggingen in exploitatie boekresultaat vastgoed	C	4	\N	t
4279	1	WAfsBovDfw	4107099	Doorberekend / Overboeking ivm functionele indeling boekresultaat vastgoed	C	4	\N	t
4280	1	WAfsDae	4199000	Doorberekende afschrijvingen en waardeveranderingen	C	3	\N	t
4281	1	WAfsDaeDaf	4199010	Doorberekende afschrijvingen doorberekende afschrijvingen en waardeveranderingen	C	4	\N	t
4282	1	WAfsDaeDafDai	4199010.01	Doorberekende afschrijvingen immateriële vaste activa doorberekende afschrijvingen en waardeveranderingen	C	5	\N	t
4283	1	WAfsDaeDafDam	4199010.02	Doorberekende afschrijvingen materiële vaste activa doorberekende afschrijvingen en waardeveranderingen	C	5	\N	t
4284	1	WAfsDaeDow	4199020	Doorberekende waardeveranderingen doorberekende afschrijvingen en waardeveranderingen	C	4	\N	t
4285	1	WAfsDaeDowDwi	4199020.01	Doorberekende waardeveranderingen immateriële vaste activa doorberekende afschrijvingen en waardeveranderingen	C	5	\N	t
4286	1	WAfsDaeDowDwm	4199020.02	Doorberekende waardeveranderingen materiële vaste activa doorberekende afschrijvingen en waardeveranderingen	C	5	\N	t
4287	1	WAfsDaeDve	4199030	Doorberekende verkoopresultaten doorberekende afschrijvingen en waardeveranderingen	C	4	\N	t
4288	1	WAfsDaeDveDvi	4199030.01	Doorberekende verkoopresultaten immateriële vaste activa doorberekende afschrijvingen en waardeveranderingen	C	5	\N	t
4289	1	WAfsDaeDveDvm	4199030.02	Doorberekende verkoopresultaten materiële vaste activa doorberekende afschrijvingen en waardeveranderingen	C	5	\N	t
4290	1	WAfsDaeDfw	4199099	Doorberekend / Overboeking ivm functionele indeling afschrijvingen en waardeveranderingen	C	4	\N	t
4291	1	WWvi	41.01	Waardeveranderingen van immateriële en materiële vaste activa en vastgoedbeleggingen	D	2	\N	t
4292	1	WWviWvi	4103000	Waardeveranderingen van immateriële vaste activa	D	3	\N	t
4293	1	WWviWviBwi	4103200	Bijzondere waardeverminderingen van immateriële vaste activa waardeveranderingen van immateriële vaste activa	D	4	\N	t
4294	1	WWviWviTbi	4103210	Terugneming van bijzondere waardeverminderingen van immateriële vaste activa waardeveranderingen van immateriële vaste activa	C	4	\N	t
4295	1	WWviWviDfw	4103299	Doorberekend / Overboeking ivm functionele indeling waardeveranderingen immateriële vaste activa	C	4	\N	t
4296	1	WWviWvm	4104000	Waardeveranderingen van materiële vaste activa	D	3	\N	t
4297	1	WWviWvmBwm	4104200	Bijzondere waardeverminderingen van materiële vaste activa waardeveranderingen van materiële vaste activa	D	4	\N	t
4298	1	WWviWvmTbm	4104210	Terugneming van bijzondere waardeverminderingen van materiële vaste activa waardeveranderingen van materiële vaste activa	C	4	\N	t
4299	1	WWviWvmDfw	4104299	Doorberekend / Overboeking ivm functionele indeling waardeveranderingen materiële vaste activa	C	4	\N	t
4300	1	WWviWvb	4105500	Wijziging in de reële waarde van vastgoedbeleggingen	D	3	\N	t
4301	1	WWviWvbBwv	4105505	Bijzondere waardeverminderingen van vastgoedbeleggingen waardeveranderingen van vastgoedbeleggingen	D	4	\N	t
4302	1	WWviWvbBwvVie	4105505.01	Bijzondere waardeverminderingen van vastgoedbeleggingen in exploitatie	D	5	\N	t
4303	1	WWviWvbBwvVio	4105505.02	Bijzondere waardeverminderingen van vastgoedbeleggingen in ontwikkeling	D	5	\N	t
4304	1	WWviWvbTbw	4105515	Terugneming van bijzondere waardeverminderingen van vastgoedbeleggingen waardeveranderingen van vastgoedbeleggingen	C	4	\N	t
4305	1	WWviWvbTbwVie	4105515.01	Bijzondere waardeverminderingen van vastgoedbeleggingen in exploitatie	C	5	\N	t
4306	1	WWviWvbTbwVio	4105515.02	Bijzondere waardeverminderingen van vastgoedbeleggingen in ontwikkeling	C	5	\N	t
4307	1	WWviWvbDfw	4105599	Doorberekend / Overboeking ivm functionele indeling wijziging in de reële waarde van vastgoedbeleggingen	C	4	\N	t
4308	1	WWviWvbDfwVie	4105599.01	Doorberekend / Overboeking ivm functionele indeling wijziging in de reële waarde van vastgoedbeleggingen in exploitatie	C	5	\N	t
4309	1	WWviWvbDfwVio	4105599.02	Doorberekend / Overboeking ivm functionele indeling wijziging in de reële waarde van vastgoedbeleggingen in ontwikkeling	C	5	\N	t
4310	1	WBwv	41.02	Overige waardeveranderingen	D	2	\N	t
4311	1	WBwvObw	4106009	Bijzondere waardeverminderingen van vlottende activa	D	3	\N	t
4312	1	WBwvObwBwv	4106014	Bijzondere waardeverminderingen van vlottende activa	D	4	\N	t
4313	1	WBwvObwBwvBwk	4106015	Bijzondere waardevermindering vorderingen (korte termijn) overige bijzondere waardeverminderingen	D	5	\N	t
4314	1	WBwvObwBwvBwe	4106025	Bijzondere waardevermindering effecten (korte termijn) overige bijzondere waardeverminderingen	D	5	\N	t
4315	1	WBwvObwBwvBwo	4106030	Bijzondere waardevermindering overige vlottende activa overige bijzondere waardeverminderingen	D	5	\N	t
4316	1	WBwvObwBwvLim	4106045	Liquide middelen	D	5	\N	t
4317	1	WBwvObwDfw	4106099	Doorberekend / Overboeking ivm functionele indeling wijziging in de reële waarde van vastgoedbeleggingen	C	4	\N	t
4318	1	WBwvGwb	4106200	Gerealiseerde waardeveranderingen van beleggingen	C	3	\N	t
4319	1	WBwvGwbGwb	4106210	Gerealiseerde waardeveranderingen van beleggingen	C	4	\N	t
4320	1	WBwvGwbGwbGwg	4106210.01	Gerealiseerde waardeveranderingen van beleggingen in groepsmaatschappijen	C	5	\N	t
4321	1	WBwvGwbGwbGwd	4106210.02	Gerealiseerde waardeveranderingen van beleggingen in andere deelnemingen	C	5	\N	t
4322	1	WBwvGwbGwbGwt	4106210.03	Gerealiseerde waardeveranderingen van beleggingen in terreinen en gebouwen	C	5	\N	t
4323	1	WBwvGwbGwbGwa	4106210.04	Gerealiseerde waardeveranderingen van beleggingen in andere beleggingen	C	5	\N	t
4324	1	WBwvGwbDfw	4106299	Doorberekend / Overboeking ivm functionele indeling gerealiseerde waardeveranderingen van beleggingen	C	4	\N	t
4325	1	WBwvNwb	4106300	Niet-gerealiseerde waardeveranderingen van beleggingen	C	3	\N	t
4326	1	WBwvNwbNwb	4106310	Niet-gerealiseerde waardeveranderingen van beleggingen	C	4	\N	t
4327	1	WBwvNwbNwbGwg	4106310.01	Niet-gerealiseerde waardeveranderingen van beleggingen in groepsmaatschappijen	C	5	\N	t
4328	1	WBwvNwbNwbGwd	4106310.02	Niet-gerealiseerde waardeveranderingen van beleggingen in andere deelnemingen	C	5	\N	t
4329	1	WBwvNwbNwbGwt	4106310.03	Niet-gerealiseerde waardeveranderingen van beleggingen in terreinen en gebouwen	C	5	\N	t
4330	1	WBwvNwbNwbGwa	4106310.04	Niet-gerealiseerde waardeveranderingen van beleggingen in andere beleggingen	C	5	\N	t
4478	1	WBedOvpMaf	4012030	Management fee overige personeelskosten	D	4	\N	t
4331	1	WBwvNwbDfw	4106399	Doorberekend / Overboeking ivm functionele indeling niet-gerealiseerde waardeveranderingen van beleggingen	C	4	\N	t
4332	1	WBed	42	Overige bedrijfskosten	D	2	\N	t
4333	1	WBedBno	4216000	Baten uit niet-ondernemingsactiviteiten	C	3	\N	t
4334	1	WBedBnoBno	4216010	Baten uit niet-ondernemingsactiviteiten	C	4	\N	t
4335	1	WBedLno	4216100	Lasten uit niet-ondernemingsactiviteiten	D	3	\N	t
4336	1	WBedLnoLno	4216110	Lasten uit niet-ondernemingsactiviteiten	D	4	\N	t
4337	1	WBedWkr	4003999	Werkkostenregeling - detail	D	3	\N	t
4338	1	WBedWkrWkf	4004000	Werkkosten vrije ruimte overige personeelsgerelateerde kosten	D	4	\N	t
4339	1	WBedWkrWkfVtw	4004010	Verteer werknemers (buiten werkplek, extern) overige personeelsgerelateerde kosten	D	5	\N	t
4340	1	WBedWkrWkfMow	4004020	Maaltijden op de werkplek overige personeelsgerelateerde kosten	D	5	\N	t
4341	1	WBedWkrWkfVcn	4004030	Vaste vergoeding voor consumpties (niet-ambulante werknemer) overige personeelsgerelateerde kosten	D	5	\N	t
4342	1	WBedWkrWkfRvn	4004040	Rentevoordeel personeelslening (niet eigen woning of (elektrische) fiets/elektrische scooter) overige personeelsgerelateerde kosten	D	5	\N	t
4343	1	WBedWkrWkfHei	4004050	Huisvesting en inwoning (incl energie,water, bewassing) niet ter vervulling dienstbetrekking overige personeelsgerelateerde kosten	D	5	\N	t
4344	1	WBedWkrWkfVmn	4004060	Vergoeding/verstrekking mobiele telefoon incl. abonnement (indien niet noodzakelijk) overige personeelsgerelateerde kosten	D	5	\N	t
4345	1	WBedWkrWkfVtb	4004070	Vergoeding telefoonabonnementen/internetabonnementen bij werknemer thuis (indien niet noodzakelijk) overige personeelsgerelateerde kosten	D	5	\N	t
4346	1	WBedWkrWkfVvt	4004080	Vergoeding/verstrekking van tablet (indien niet noodzakelijk) overige personeelsgerelateerde kosten	D	5	\N	t
4347	1	WBedWkrWkfVlp	4004090	Vergoeding/verstrekking van laptop (indien niet noodzakelijk) overige personeelsgerelateerde kosten	D	5	\N	t
4348	1	WBedWkrWkfVdt	4004100	Vergoeding/verstrekking van desktop (indien niet noodzakelijk) overige personeelsgerelateerde kosten	D	5	\N	t
4349	1	WBedWkrWkfVcp	4004110	Vergoeding/verstrekking computerprogrammatuur (indien niet noodzakelijk) overige personeelsgerelateerde kosten	D	5	\N	t
4350	1	WBedWkrWkfIwt	4004120	Inrichting werkplek thuis (exclusief arbovoorzieningen) overige personeelsgerelateerde kosten	D	5	\N	t
4351	1	WBedWkrWkfVrh	4004130	Vergoeding reiskosten voorzover boven € 0,19 per kilometer overige personeelsgerelateerde kosten	D	5	\N	t
4352	1	WBedWkrWkfVpb	4004140	Vergoeding van kosten van persoonlijke beschermingsmiddelen aan werknemer overige personeelsgerelateerde kosten	D	5	\N	t
4353	1	WBedWkrWkfVww	4004150	Vergoeding van kosten van werkkleding die nagenoeg uitsluitend geschikt is om in te werken overige personeelsgerelateerde kosten	D	5	\N	t
4354	1	WBedWkrWkfVka	4004160	Vergoeding van kosten van kleding die achterblijft op de werkplek overige personeelsgerelateerde kosten	D	5	\N	t
4355	1	WBedWkrWkfVog	4004170	Verstrekking/vergoeding van overige kleding overige personeelsgerelateerde kosten	D	5	\N	t
4356	1	WBedWkrWkfEho	4004180	Eerste huisvestingskosten (tot 18% van het loon) overige personeelsgerelateerde kosten	D	5	\N	t
4357	1	WBedWkrWkfZve	4004190	Zakelijke verhuiskosten exclusief kosten overbrenging boedel (boven gerichte vrijstelling) overige personeelsgerelateerde kosten	D	5	\N	t
4358	1	WBedWkrWkfPfe	4004200	Personeelsfeesten (buiten de werkplek) overige personeelsgerelateerde kosten	D	5	\N	t
4359	1	WBedWkrWkfKrs	4004210	Kerstpakket aan personeel en postactieven overige personeelsgerelateerde kosten	D	5	\N	t
4360	1	WBedWkrWkfGmi	4004220	Geschenken met in hoofzaak ideële waarde bij feestdagen en jubilea overige personeelsgerelateerde kosten	D	5	\N	t
4361	1	WBedWkrWkfAgn	4004230	Andere geschenken in natura overige personeelsgerelateerde kosten	D	5	\N	t
4362	1	WBedWkrWkfAgg	4004240	Andere geschenken in de vorm van een geldsom overige personeelsgerelateerde kosten	D	5	\N	t
4363	1	WBedWkrWkfFie	4004250	Fietsvergoeding overige personeelsgerelateerde kosten	D	5	\N	t
4364	1	WBedWkrWkfBbd	4004260	Bedrijfsfitness buiten de werkplek overige personeelsgerelateerde kosten	D	5	\N	t
4365	1	WBedWkrWkfKpu	4004270	Producten uit eigen bedrijf en kortingen voor zover niet vrijgesteld overige personeelsgerelateerde kosten	D	5	\N	t
4366	1	WBedWkrWkfWep	4004280	Werkgeversbijdrage personeelsvereniging overige personeelsgerelateerde kosten	D	5	\N	t
4367	1	WBedWkrWkfVbp	4004290	Vergoeding werknemersbijdrage personeelsvereniging overige personeelsgerelateerde kosten	D	5	\N	t
4368	1	WBedWkrWkfVev	4004300	Vergoeding vakbondscontributie overige personeelsgerelateerde kosten	D	5	\N	t
4369	1	WBedWkrWkfPrz	4004310	Personeelsreizen overige personeelsgerelateerde kosten	D	5	\N	t
4370	1	WBedWkrWkfPwn	4004320	Parkeren bij werk (niet zijnde auto van de zaak) (geen eigen parkeerterrein, parkeervergunning) overige personeelsgerelateerde kosten	D	5	\N	t
4371	1	WBedWkrWkfPvn	4004330	Parkeer-, veer- en tolgelden (niet zijnde auto van de zaak) overige personeelsgerelateerde kosten	D	5	\N	t
4372	1	WBedWkrWkfPev	4004340	Persoonlijke verzorging overige personeelsgerelateerde kosten	D	5	\N	t
4373	1	WBedWkrWkfRaw	4004350	Representatievergoeding/relatiegeschenken aan werknemers overige personeelsgerelateerde kosten	D	5	\N	t
4374	1	WBedWkrWkfEbd	4004360	Eigen bijdrage werknemers voor kinderopvang op werkplek (dagopvang) overige personeelsgerelateerde kosten	C	5	\N	t
4375	1	WBedWkrWkfEbb	4004370	Eigen bijdrage werknemers voor kinderopvang op werkplek (bso) overige personeelsgerelateerde kosten	C	5	\N	t
4376	1	WBedWkrWkfKbd	4004380	Kinderopvang buiten de werkplek (factuurwaarde incl. btw of WEV) overige personeelsgerelateerde kosten	D	5	\N	t
4377	1	WBedWkrWkfEbw	4004390	Eigen bijdrage werknemers voor kinderopvang buiten de werkplek overige personeelsgerelateerde kosten	C	5	\N	t
4378	1	WBedWkrWkfDkd	4004400	Door inhoudingsplichte verrichte kinderopvang op werkplek (dagopvang) overige personeelsgerelateerde kosten	D	5	\N	t
4667	1	WBedKanPor	4206020	Porti kantoorkosten	D	4	\N	t
4379	1	WBedWkrWkfDkb	4004410	Door inhoudingsplichte verrichte kinderopvang op werkplek (bso) overige personeelsgerelateerde kosten	D	5	\N	t
4380	1	WBedWkrWkfOwr	4004420	Overige werkkosten vrije ruimte overige personeelsgerelateerde kosten	D	5	\N	t
4381	1	WBedWkrWkfDfw	4004499	Doorberekend / Overboeking ivm functionele indeling werkkosten vrije ruimte	C	5	\N	t
4382	1	WBedWkrWkn	4005000	Werkkosten met nihilwaardering overige personeelsgerelateerde kosten	D	4	\N	t
4383	1	WBedWkrWknVwo	4005010	Verteer werknemers op werkplek (geen maaltijden) overige personeelsgerelateerde kosten	D	5	\N	t
4384	1	WBedWkrWknHit	4005020	Huisvesting en inwoning (incl energie,water, bewassing) ter vervulling dienstbetrekking overige personeelsgerelateerde kosten	D	5	\N	t
4385	1	WBedWkrWknRve	4005030	Rentevoordeel personeelslening eigen woning en (elektrische) fiets of elektrische scooter overige personeelsgerelateerde kosten	D	5	\N	t
4386	1	WBedWkrWknTbs	4005040	Ter beschikking stellen desktop computer op werkplek overige personeelsgerelateerde kosten	D	5	\N	t
4387	1	WBedWkrWknLwe	4005050	Inrichting werkplek (niet thuis) overige personeelsgerelateerde kosten	D	5	\N	t
4388	1	WBedWkrWknLwa	4005060	Inrichting werkplek arbo-voorzieningen (thuis) overige personeelsgerelateerde kosten	D	5	\N	t
4389	1	WBedWkrWknPwp	4005070	Parkeren werkplek (niet zijnde auto van de zaak)(op parkeerterrein van werkgever) overige personeelsgerelateerde kosten	D	5	\N	t
4390	1	WBedWkrWknTbg	4005080	Ter beschikking gestelde openbaarvervoerkaart/voordeelurenkaart (mede zakelijk gebruikt) overige personeelsgerelateerde kosten	D	5	\N	t
4391	1	WBedWkrWknVbm	4005090	Verstrekking van persoonlijke beschermingsmiddelen (veiligheidsbril, werkschoenen) door werkgever overige personeelsgerelateerde kosten	D	5	\N	t
4392	1	WBedWkrWknVwk	4005100	Verstrekking van werkkleding die nagenoeg uitsluitend geschikt is om in te werken door werkgever overige personeelsgerelateerde kosten	D	5	\N	t
4393	1	WBedWkrWknVvk	4005110	Verstrekking van kleding die achterblijft op de werkplek overige personeelsgerelateerde kosten	D	5	\N	t
4394	1	WBedWkrWknVkl	4005120	Verstrekking van kleding met bedrijfslogo van tenminste 70 cm² overige personeelsgerelateerde kosten	D	5	\N	t
4395	1	WBedWkrWknArv	4005130	Arbovoorzieningen overige personeelsgerelateerde kosten	D	5	\N	t
4396	1	WBedWkrWknPfw	4005140	Personeelsfeesten (op de werkplek) overige personeelsgerelateerde kosten	D	5	\N	t
4397	1	WBedWkrWknBod	4005150	Bedrijfsfitness op de werkplek overige personeelsgerelateerde kosten	D	5	\N	t
4398	1	WBedWkrWknOwn	4005160	Overige werkkosten nihilwaardering overige personeelsgerelateerde kosten	D	5	\N	t
4399	1	WBedWkrWknDfw	4005199	Doorberekend / Overboeking ivm functionele indeling werkkosten met nihilwaardering	C	5	\N	t
4400	1	WBedWkrWkg	4006000	Werkkosten gericht vrijgesteld overige personeelsgerelateerde kosten	D	4	\N	t
4401	1	WBedWkrWkgVro	4006010	Vergoeding reiskosten (tot € 0,19) per kilometer overige personeelsgerelateerde kosten	D	5	\N	t
4402	1	WBedWkrWkgCem	4006020	Consumpties en maaltijden dienstreis overige personeelsgerelateerde kosten	D	5	\N	t
4403	1	WBedWkrWkgMbo	4006030	Maaltijden bij overwerk/werk op koopavonden overige personeelsgerelateerde kosten	D	5	\N	t
4404	1	WBedWkrWkgVca	4006040	Vaste vergoeding voor consumpties (ambulante werknemer) overige personeelsgerelateerde kosten	D	5	\N	t
4405	1	WBedWkrWkgOsc	4006050	Opleidingen, studies, cursussen, congressen, seminars, symposia, excursies, studiereizen overige personeelsgerelateerde kosten	D	5	\N	t
4406	1	WBedWkrWkgVak	4006060	Werkkosten gericht vrijgesteld, waarvan vakliteratuur overige personeelsgerelateerde kosten	D	5	\N	t
4407	1	WBedWkrWkgIwr	4006070	Inschrijving wettelijk en door beroepsgroep opgelegde registers overige personeelsgerelateerde kosten	D	5	\N	t
4408	1	WBedWkrWkgDuh	4006080	Dubbele huisvestingskosten overige personeelsgerelateerde kosten	D	5	\N	t
4409	1	WBedWkrWkgEkl	4006090	Extra kosten levensonderhoud overige personeelsgerelateerde kosten	D	5	\N	t
4410	1	WBedWkrWkgKap	4006100	Kosten aanvragen/omzetten papieren (verblijfsvergunningen, visa, rijbewijzen) overige personeelsgerelateerde kosten	D	5	\N	t
4411	1	WBedWkrWkgKmk	4006110	Kosten medische keuringen, vaccinaties overige personeelsgerelateerde kosten	D	5	\N	t
4412	1	WBedWkrWkgRnl	4006120	Reiskosten naar land herkomst (familiebezoek, gezinshereniging) overige personeelsgerelateerde kosten	D	5	\N	t
4413	1	WBedWkrWkgCtw	4006130	Cursuskosten taal werkland (werknemer + gezin) overige personeelsgerelateerde kosten	D	5	\N	t
4414	1	WBedWkrWkgEhb	4006140	Eerste huisvestingskosten (boven 18% van het loon) overige personeelsgerelateerde kosten	D	5	\N	t
4415	1	WBedWkrWkgEtk	4006150	Extra (niet-zakelijke) telefoonkosten (gesprek) met land van herkomst overige personeelsgerelateerde kosten	D	5	\N	t
4416	1	WBedWkrWkgOkb	4006160	Opslagkosten boedel overige personeelsgerelateerde kosten	D	5	\N	t
4417	1	WBedWkrWkgKkw	4006170	Kosten kennismakingsreis werkland overige personeelsgerelateerde kosten	D	5	\N	t
4418	1	WBedWkrWkgK3r	4006180	Kosten 30% regeling overige personeelsgerelateerde kosten	D	5	\N	t
4419	1	WBedWkrWkgZvk	4006190	Zakelijke verhuiskosten: kosten overbrenging boedel overige personeelsgerelateerde kosten	D	5	\N	t
4420	1	WBedWkrWkgZvo	4006200	Zakelijke verhuiskosten exclusief kosten overbrenging boedel overige personeelsgerelateerde kosten	D	5	\N	t
4421	1	WBedWkrWkgOut	4006210	Outplacementkosten overige personeelsgerelateerde kosten	D	5	\N	t
4422	1	WBedWkrWkgHow	4006220	(Hotel)overnachtingen in verband met werk overige personeelsgerelateerde kosten	D	5	\N	t
4423	1	WBedWkrWkgVpr	4006230	Verstrekte producten en kortingen op producten uit eigen bedrijf (voor zover vrijgesteld) overige personeelsgerelateerde kosten	D	5	\N	t
4424	1	WBedWkrWkgOwv	4006240	Overige werkkosten gericht vrijgesteld overige personeelsgerelateerde kosten	D	5	\N	t
4425	1	WBedWkrWkgArv	4006250	Arbovoorzieningen overige personeelsgerelateerde kosten	D	5	\N	t
4426	1	WBedWkrWkgTwv	4006260	Thuiswerkvergoeding overige personeelsgerelateerde kosten	D	5	\N	t
4427	1	WBedWkrWkgDfw	4006299	Doorberekend / Overboeking ivm functionele indeling werkkosten gericht vrijgesteld	C	5	\N	t
4428	1	WBedWkrWkc	4007000	Werkkosten noodzakelijkheidscriterium overige personeelsgerelateerde kosten	D	4	\N	t
4429	1	WBedWkrWkcVmt	4007010	Vergoeding/verstrekking mobiele telefoon incl. abonnement (mits noodzakelijk) overige personeelsgerelateerde kosten	D	5	\N	t
4430	1	WBedWkrWkcVtn	4007020	Vergoeding/verstrekking van tablet (mits noodzakelijk) overige personeelsgerelateerde kosten	D	5	\N	t
4431	1	WBedWkrWkcVln	4007030	Vergoeding/verstrekking van laptop (mits noodzakelijk) overige personeelsgerelateerde kosten	D	5	\N	t
4432	1	WBedWkrWkcVdn	4007040	Vergoeding/verstrekking van desktop (mits noodzakelijk) overige personeelsgerelateerde kosten	D	5	\N	t
4433	1	WBedWkrWkcVcm	4007050	Vergoeding/verstrekking computerprogrammatuur (mits noodzakelijk) overige personeelsgerelateerde kosten	D	5	\N	t
4434	1	WBedWkrWkcOwm	4007060	Overige werkkosten noodzakelijkheidscriterium overige personeelsgerelateerde kosten	D	5	\N	t
4435	1	WBedWkrWkcDfw	4007099	Doorberekend / Overboeking ivm functionele indeling werkkosten noodzakelijkscriterium	C	5	\N	t
4436	1	WBedWkrWki	4008000	Werkkosten intermediair overige personeelsgerelateerde kosten	D	4	\N	t
4437	1	WBedWkrWkiMmz	4008010	Maaltijden met zakelijke relaties overige personeelsgerelateerde kosten	D	5	\N	t
4438	1	WBedWkrWkiPva	4008020	Parkeer-, veer- en tolgelden (auto van de zaak) overige personeelsgerelateerde kosten	D	5	\N	t
4439	1	WBedWkrWkiPwa	4008030	Parkeren bij werk (auto van de zaak) (geen eigen parkeerterrein, parkeervergunning) overige personeelsgerelateerde kosten	D	5	\N	t
4440	1	WBedWkrWkiOwi	4008040	Overige werkkosten intermediair overige personeelsgerelateerde kosten	D	5	\N	t
4441	1	WBedWkrWkiDfw	4008099	Doorberekend / Overboeking ivm functionele indeling werkkosten intermediair	C	5	\N	t
4442	1	WBedWkrWkb	4009000	Werkkosten belast loon overige personeelsgerelateerde kosten	D	4	\N	t
4443	1	WBedWkrWkbPga	4009010	Werkkosten belast loon t.a.v. privé-gebruik auto's overige personeelsgerelateerde kosten	D	5	\N	t
4444	1	WBedWkrWkbGed	4009020	Genot dienstwoning overige personeelsgerelateerde kosten	D	5	\N	t
4445	1	WBedWkrWkbGbu	4009030	Geldboetes buitenlandse autoriteiten overige personeelsgerelateerde kosten	D	5	\N	t
4446	1	WBedWkrWkbGbi	4009040	Geldboetes binnenlandse autoriteiten overige personeelsgerelateerde kosten	D	5	\N	t
4447	1	WBedWkrWkbVzm	4009050	Vergoedingen en verstrekkingen ter zake van misdrijven overige personeelsgerelateerde kosten	D	5	\N	t
4448	1	WBedWkrWkbVwm	4009060	Vergoedingen en verstrekkingen ter zake van wapens en munitie overige personeelsgerelateerde kosten	D	5	\N	t
4449	1	WBedWkrWkbVdr	4009070	Vergoedingen en verstrekkingen ter zake van agressieve dieren overige personeelsgerelateerde kosten	D	5	\N	t
4450	1	WBedWkrWkbOwb	4009080	Overige werkkosten belast loon overige personeelsgerelateerde kosten	D	5	\N	t
4451	1	WBedWkrWkbBas	4009090	Bestuurdersaansprakelijkheid	D	5	\N	t
4452	1	WBedWkrWkbDfw	4009099	Doorberekend / Overboeking ivm functionele indeling werkkosten belast loon	C	5	\N	t
4453	1	WBedWkrWkv	4010000	Werkkosten geen of vrijgesteld loon overige personeelsgerelateerde kosten	D	4	\N	t
4454	1	WBedWkrWkvFrb	4010010	Fruitmand, rouwkrans, bloemetje overige personeelsgerelateerde kosten	D	5	\N	t
4455	1	WBedWkrWkvKgs	4010020	Kleine geschenken (geen geld of waardebon) maximaal € 25 overige personeelsgerelateerde kosten	D	5	\N	t
4456	1	WBedWkrWkvEub	4010030	Eenmalige uitkering/verstrekking bij 25/40-jarig diensttijdjubileum werknemer (voorzover = kleiner dan 1 x maandloon) overige personeelsgerelateerde kosten	D	5	\N	t
4457	1	WBedWkrWkvWpv	4010040	Werkgeversbijdrage personeelsvereniging (als werknemers geen aanspraak hebben op uitkeringen uit de pv) overige personeelsgerelateerde kosten	D	5	\N	t
4458	1	WBedWkrWkvUtv	4010050	Uitkering/verstrekking tot vergoeding door werknemer ivm met werk gelden schade/verlies persoonlijke zaken overige personeelsgerelateerde kosten	D	5	\N	t
4459	1	WBedWkrWkvEuo	4010060	Eenmalige uitkering/verstrekking bij overlijden werknemer, zijn partner of kinderen (voorzover kleiner dan 3 x maandloon) overige personeelsgerelateerde kosten	D	5	\N	t
4460	1	WBedWkrWkvUue	4010070	Uitkering/verstrekking uit een personeelsfonds overige personeelsgerelateerde kosten	D	5	\N	t
4461	1	WBedWkrWkvMpi	4010080	Meewerkvergoeding partner inhoudingsplichtige (indien lager dan € 5.000) overige personeelsgerelateerde kosten	D	5	\N	t
4462	1	WBedWkrWkvOwg	4010090	Overige werkkosten geen of vrijgesteld loon overige personeelsgerelateerde kosten	D	5	\N	t
4463	1	WBedWkrWkvDfw	4010099	Doorberekend / Overboeking ivm functionele indeling werkkosten geen of vrijgesteld	C	5	\N	t
4464	1	WBedWkrWko	4011000	Werkkosten overig overige personeelsgerelateerde kosten	D	4	\N	t
4465	1	WBedWkrWkoWee	4011010	Werkkosten eindheffing overige personeelsgerelateerde kosten	D	5	\N	t
4466	1	WBedWkrWkoCib	4011020	Correctie inzake BTW overige personeelsgerelateerde kosten	C	5	\N	t
4467	1	WBedWkrWkoObw	4011030	Overboeking werkkosten overige personeelsgerelateerde kosten	C	5	\N	t
4468	1	WBedWkrWkoDwk	4011990	Doorberekende werkkosten overige personeelsgerelateerde kosten	C	5	\N	t
4469	1	WBedWkrWkoDfw	4011999	Doorberekend / Overboeking ivm functionele indeling werkkosten overig	C	5	\N	t
4470	1	WBedOvp	4012000	Overige personeelsgerelateerde kosten	D	3	\N	t
4471	1	WBedOvpUik	4012010	Uitzendkrachten overige personeelskosten	D	4	\N	t
4472	1	WBedOvpUikUik	4012010.01	Uitzendkrachten overige personeelskosten	D	5	\N	t
4473	1	WBedOvpUikFor	4012010.02	Uitzendkrachten  formatief	D	5	\N	t
4474	1	WBedOvpUikPrj	4012010.03	Uitzendkrachten projectmatig	D	5	\N	t
4475	1	WBedOvpUikBfo	4012010.04	Uitzendkrachten boven formatief	D	5	\N	t
4476	1	WBedOvpUikPro	4012010.05	Uitzendkrachten programma's	D	5	\N	t
4477	1	WBedOvpUit	4012020	Uitzendbedrijven overige personeelskosten	D	4	\N	t
4479	1	WBedOvpZzp	4012040	Ingehuurde ZZP-ers overige personeelskosten	D	4	\N	t
4480	1	WBedOvpPay	4012050	Ingehuurde payrollers overige personeelskosten	D	4	\N	t
4481	1	WBedOvpOip	4012060	Overig ingeleend personeel overige personeelskosten	D	4	\N	t
4482	1	WBedOvpWer	4012070	Wervingskosten overige personeelskosten	D	4	\N	t
4483	1	WBedOvpWkv	4012071	Werkkleding	D	4	\N	t
4484	1	WBedOvpWpt	4012072	Werkplek thuis	D	4	\N	t
4485	1	WBedOvpThv	4012073	Thuiswerkvergoeding	D	4	\N	t
4486	1	WBedOvpMlv	4012074	Maaltijden en consumpties personeel	D	4	\N	t
4487	1	WBedOvpPug	4012075	Personeeluitjes en -geschenken	D	4	\N	t
4488	1	WBedOvpWbp	4012076	Werkgeversbijdrage personeelsvereniging, -fonds	D	4	\N	t
4489	1	WBedOvpOvb	4012077	(Overige) Vergoedingen personeel	D	4	\N	t
4490	1	WBedOvpRkv	4012078	Reiskostenvergoeding	D	4	\N	t
4491	1	WBedOvpAbd	4012080	Arbodienst overige personeelskosten	D	4	\N	t
4492	1	WBedOvpDdd	4012090	Diensten door derden overige personeelskosten	D	4	\N	t
4493	1	WBedOvpZie	4012100	Ziekengeldverzekering overige personeelskosten	D	4	\N	t
4494	1	WBedOvpOzi	4012110	Ontvangen ziekengelden overige personeelskosten	C	4	\N	t
4495	1	WBedOvpDvr	4012120	Dotatie voorziening in verband met reorganisaties overige personeelskosten	D	4	\N	t
4496	1	WBedOvpVvr	4012130	Vrijval voorziening in verband met reorganisaties overige personeelskosten	C	4	\N	t
4497	1	WBedOvpDoa	4012140	Dotatie arbeidsongeschiktheidsvoorziening overige personeelskosten	D	4	\N	t
4498	1	WBedOvpDva	4012141	Dotatie voorziening voor verzekering van ziekte of arbeidsongeschiktheid	D	4	\N	t
4499	1	WBedOvpDvz	4012142	Dotatie voorziening voor verplichtingen uit hoofde van ziekte of arbeidsongeschiktheid	D	4	\N	t
4500	1	WBedOvpDoj	4012150	Dotatie jubileumvoorziening overige personeelskosten	D	4	\N	t
4501	1	WBedOvpVva	4012160	Vrijval arbeidsongeschiktheidsvoorziening overige personeelskosten	C	4	\N	t
4502	1	WBedOvpVvv	4012161	Vrijval voorziening voor verzekering van ziekte of arbeidsongeschiktheid	C	4	\N	t
4503	1	WBedOvpVvz	4012162	Vrijval voorziening voor verplichtingen uit hoofde van ziekte of arbeidsongeschiktheid	C	4	\N	t
4504	1	WBedOvpVrj	4012170	Vrijval jubileumvoorziening overige personeelskosten	C	4	\N	t
4505	1	WBedOvpObp	4012180	Overige belastingen inzake personeel overige personeelskosten	D	4	\N	t
4506	1	WBedOvpOvp	4012190	Overige personeelskosten niet elders genoemd overige personeelskosten	D	4	\N	t
4507	1	WBedOvpDop	4012990	Doorberekende overige personeelskosten overige personeelskosten	C	4	\N	t
4508	1	WBedOvpLbo	4012200	Loopbaanontwikkeling	D	4	\N	t
4509	1	WBedOvpOpk	4012205	Opleidingskosten	D	4	\N	t
4510	1	WBedOvpDlb	4012210	Dotatie loopbaan begeleiding voorziening	D	4	\N	t
4511	1	WBedOvpVlb	4012220	Vrijval loopbaan begeleiding voorziening	C	4	\N	t
4512	1	WBedOvpDvp	4012300	Dotatie voorziening uit hoofde van personeelsbeloningen	D	4	\N	t
4513	1	WBedOvpVvp	4012310	Vrijval voorziening uit hoofde van personeelsbeloningen	C	4	\N	t
4514	1	WBedOvpDab	4012400	Dotatie voorziening uit hoofde van op aandelen gebaseerde betalingen	D	4	\N	t
4515	1	WBedOvpVab	4012410	Vrijval voorziening uit hoofde van op aandelen gebaseerde betalingen	C	4	\N	t
4516	1	WBedOvpDfw	4012999	Doorberekend / Overboeking ivm functionele indeling overige  personeelsgerelateerde kosten	C	4	\N	t
4517	1	WBedHui	4201000	Huisvestingskosten	D	3	\N	t
4518	1	WBedHuiErf	4201010	Erfpacht huisvestingskosten	D	4	\N	t
4519	1	WBedHuiLee	4201020	Leefbaarheid huisvestingskosten	D	4	\N	t
4520	1	WBedHuiLas	4201030	Lasten servicecontracten huisvestingskosten	D	4	\N	t
4521	1	WBedHuiBeh	4201040	Betaalde huur huisvestingskosten	D	4	\N	t
4522	1	WBedHuiOhu	4201050	Ontvangen huursuppletie huisvestingskosten	C	4	\N	t
4523	1	WBedHuiHuw	4201060	Huurwaarde woongedeelte huisvestingskosten	C	4	\N	t
4524	1	WBedHuiOnt	4201070	Onderhoud terreinen huisvestingskosten	D	4	\N	t
4525	1	WBedHuiOng	4201080	Onderhoud gebouwen huisvestingskosten	D	4	\N	t
4526	1	WBedHuiSch	4201090	Schoonmaakkosten huisvestingskosten	D	4	\N	t
4527	1	WBedHuiSer	4201100	Servicekosten huisvestingskosten	D	4	\N	t
4528	1	WBedHuiBev	4201101	Beveiligingskosten	D	4	\N	t
4529	1	WBedHuiGwe	4201105	Gas,water en elektra (algemeen)	D	4	\N	t
4530	1	WBedHuiGweGas	4201110	Gas huisvestingskosten	D	5	\N	t
4531	1	WBedHuiGweElk	4201120	Elektra huisvestingskosten	D	5	\N	t
4532	1	WBedHuiGweWat	4201130	Water huisvestingskosten	D	5	\N	t
4533	1	WBedHuiGweNed	4201140	Netdiensten huisvestingskosten	D	5	\N	t
4534	1	WBedHuiGas	4201141	Energiekosten gas	D	4	\N	t
4535	1	WBedHuiWat	4201142	Energiekosten water	D	4	\N	t
4536	1	WBedHuiElk	4201143	Energiekosten elektra	D	4	\N	t
4537	1	WBedHuiTrg	4201144	Teruglevering elektra	C	4	\N	t
4538	1	WBedHuiPre	4201150	Privé-gebruik energie huisvestingskosten	C	4	\N	t
4539	1	WBedHuiAoz	4201160	Assurantiepremies onroerende zaak huisvestingskosten	D	4	\N	t
4540	1	WBedHuiOnz	4201170	Onroerende zaakbelasting huisvestingskosten	D	4	\N	t
4541	1	WBedHuiMez	4201180	Milieuheffingen en zuiveringsleges huisvestingskosten	D	4	\N	t
4542	1	WBedHuiObh	4201190	Overige belastingen inzake huisvesting huisvestingskosten	D	4	\N	t
4543	1	WBedHuiOvh	4201200	Overige vaste huisvestingslasten huisvestingskosten	D	4	\N	t
4544	1	WBedHuiDrg	4201210	Dotatie reserve assurantie eigen risico gebouwen huisvestingskosten	D	4	\N	t
4668	1	WBedKanTef	4206030	Telefoonkosten kantoorkosten	D	4	\N	t
4545	1	WBedHuiVrg	4201220	Vrijval reserve assurantie eigen risico gebouwen huisvestingskosten	C	4	\N	t
4546	1	WBedHuiDvg	4201230	Dotatie voorziening groot onderhoud gebouwen huisvestingskosten	D	4	\N	t
4547	1	WBedHuiVgb	4201240	Vrijval voorziening groot onderhoud gebouwen huisvestingskosten	C	4	\N	t
4548	1	WBedHuiDkg	4201250	Dotatie kostenegalisatiereserve groot onderhoud gebouwen huisvestingskosten	D	4	\N	t
4549	1	WBedHuiVkg	4201260	Vrijval kostenegalisatiereserve groot onderhoud gebouwen huisvestingskosten	C	4	\N	t
4550	1	WBedHuiOhv	4201270	Overige huisvestingskosten huisvestingskosten	D	4	\N	t
4551	1	WBedHuiOhvOhv	4201270.01	Overige huisvestingskosten	D	5	\N	t
4552	1	WBedHuiOhvGbw	4201270.02	Overige huisvestingskosten glasbewassing	D	5	\N	t
4553	1	WBedHuiOhvSav	4201270.03	Overige huisvestingskosten sanitaire voorzieningen	D	5	\N	t
4554	1	WBedHuiOhvOgb	4201270.04	Overige huisvestingskosten ongedierte bestrijding	D	5	\N	t
4555	1	WBedHuiOhvRvb	4201270.05	Overige huisvestingskosten reinigen vloer en buiten	D	5	\N	t
4556	1	WBedHuiOhvBev	4201270.06	Overige huisvestingskosten beveiliging	D	5	\N	t
4557	1	WBedHuiOhvKap	4201270.07	Overige huisvestingskosten kleine aanpassingen	D	5	\N	t
4558	1	WBedHuiOhvBlm	4201270.08	Overige huisvestingskosten bloemen	D	5	\N	t
4559	1	WBedHuiOhvIhh	4201270.09	Overige huisvestigingskosten interne huur huismeesterruimte	D	5	\N	t
4560	1	WBedHuiOhvEhr	4201270.10	Overige huisvestingskosten elektra huismeesterruimte	D	5	\N	t
4561	1	WBedHuiDoh	4201990	Doorberekende huisvestingskosten huisvestingskosten	C	4	\N	t
4562	1	WBedHuiDfw	4201999	Doorberekend / Overboeking ivm functionele indeling huisvestingskosten	C	4	\N	t
4563	1	WBedEem	4202000	Exploitatie- en machinekosten	D	3	\N	t
4564	1	WBedEemRoi	4202010	Reparatie en onderhoud inventaris exploitatie- en machinekosten	D	4	\N	t
4565	1	WBedEemOls	4202020	Operational leasing inventaris exploitatie- en machinekosten	D	4	\N	t
4566	1	WBedEemHui	4202030	Huur inventaris exploitatie- en machinekosten	D	4	\N	t
4567	1	WBedEemKai	4202040	Kleine aanschaffingen inventaris exploitatie- en machinekosten	D	4	\N	t
4568	1	WBedEemGsk	4202050	Gereedschapskosten exploitatie- en machinekosten	D	4	\N	t
4569	1	WBedEemDvi	4202060	Dotatie voorziening groot onderhoud inventaris exploitatie- en machinekosten	D	4	\N	t
4570	1	WBedEemVoi	4202070	Vrijval voorziening groot onderhoud inventaris exploitatie- en machinekosten	C	4	\N	t
4571	1	WBedEemDki	4202080	Dotatie kostenegalisatiereserve groot onderhoud inventaris exploitatie- en machinekosten	D	4	\N	t
4572	1	WBedEemVki	4202090	Vrijval kostenegalisatiereserve groot onderhoud inventaris exploitatie- en machinekosten	C	4	\N	t
4573	1	WBedEemOki	4202100	Overige kosten inventaris exploitatie- en machinekosten	D	4	\N	t
4574	1	WBedEemRom	4202110	Reparatie en onderhoud machines exploitatie- en machinekosten	D	4	\N	t
4575	1	WBedEemOlm	4202120	Operational leasing machines exploitatie- en machinekosten	D	4	\N	t
4576	1	WBedEemHum	4202130	Huur machines exploitatie- en machinekosten	D	4	\N	t
4577	1	WBedEemOme	4202140	Onderhoud machines exploitatie- en machinekosten	D	4	\N	t
4578	1	WBedEemBrm	4202150	Brandstof machines exploitatie- en machinekosten	D	4	\N	t
4579	1	WBedEemKam	4202160	Kleine aanschaffingen machines exploitatie- en machinekosten	D	4	\N	t
4580	1	WBedEemDvm	4202170	Dotatie voorziening groot onderhoud machines exploitatie- en machinekosten	D	4	\N	t
4581	1	WBedEemVgo	4202180	Vrijval voorziening groot onderhoud machines exploitatie- en machinekosten	C	4	\N	t
4582	1	WBedEemDkm	4202190	Dotatie kostenegalisatiereserve groot onderhoud machines exploitatie- en machinekosten	D	4	\N	t
4583	1	WBedEemVkm	4202200	Vrijval kostenegalisatiereserve groot onderhoud machines exploitatie- en machinekosten	C	4	\N	t
4584	1	WBedEemObm	4202210	Overige belastingen inzake exploitatie en machines exploitatie- en machinekosten	D	4	\N	t
4585	1	WBedEemOkm	4202220	Overige kosten machines exploitatie- en machinekosten	D	4	\N	t
4586	1	WBedEemWdi	4202225	Werk door derden, waarvan industriële loondiensten 	D	4	\N	t
4587	1	WBedEemWdd	4202230	Werk door derden, overig 	D	4	\N	t
4588	1	WBedEemDrm	4202240	Dotatie reserve assurantie eigen risico machines 	D	4	\N	t
4589	1	WBedEemVrm	4202250	Vrijval reserve assurantie eigen risico machines 	C	4	\N	t
4590	1	WBedEemAme	4202260	Assurantiepremie machines en inventaris 	D	4	\N	t
4591	1	WBedEemVpm	4202270	Verpakkingsmaterialen 	D	4	\N	t
4592	1	WBedEemOee	4202280	Overige exploitatie- en machinekosten 	D	4	\N	t
4593	1	WBedEemDem	4202990	Doorberekende exploitatie- en machinekosten 	C	4	\N	t
4594	1	WBedEemDfw	4202999	Doorberekend / Overboeking ivm functionele indeling exploitatie- en machinekosten	C	4	\N	t
4595	1	WBedVkk	4203000	Verkoop gerelateerde kosten	D	3	\N	t
4596	1	WBedVkkRea	4203010	Reclame- en advertentiekosten verkoop gerelateerde kosten	D	4	\N	t
4597	1	WBedVkkKos	4203020	Kosten sponsoring verkoop gerelateerde kosten	D	4	\N	t
4598	1	WBedVkkBeu	4203030	Beurskosten verkoop gerelateerde kosten	D	4	\N	t
4599	1	WBedVkkRel	4203040	Relatiegeschenken verkoop gerelateerde kosten	D	4	\N	t
4600	1	WBedVkkKer	4203050	Kerstpakketten relaties verkoop gerelateerde kosten	D	4	\N	t
4601	1	WBedVkkRep	4203060	Representatiekosten verkoop gerelateerde kosten	D	4	\N	t
4602	1	WBedVkkRev	4203070	Reis- en verblijfkosten verkoop gerelateerde kosten	D	4	\N	t
4603	1	WBedVkkEta	4203080	Etalagekosten verkoop gerelateerde kosten	D	4	\N	t
4604	1	WBedVkkVrk	4203090	Vrachtkosten verkoop gerelateerde kosten	D	4	\N	t
4605	1	WBedVkkInc	4203100	Incassokosten a.g.v. verkoopactiviteiten verkoop gerelateerde kosten	D	4	\N	t
4606	1	WBedVkkKmz	4203110	Kilometervergoeding zakelijke reizen verkoop gerelateerde kosten	D	4	\N	t
4607	1	WBedVkkKmw	4203120	Kilometervergoeding woon-werkverkeer verkoop gerelateerde kosten	D	4	\N	t
4608	1	WBedVkkVkp	4203130	Verkoopprovisie verkoop gerelateerde kosten	D	4	\N	t
4609	1	WBedVkkCom	4203140	Commissies verkoop gerelateerde kosten	D	4	\N	t
4610	1	WBedVkkFra	4203150	Franchisekosten verkoop gerelateerde kosten	D	4	\N	t
4611	1	WBedVkkDvd	4203160	Dotatie voorziening dubieuze debiteuren verkoop gerelateerde kosten	D	4	\N	t
4612	1	WBedVkkAdd	4203170	Afboeking dubieuze debiteuren verkoop gerelateerde kosten	D	4	\N	t
4613	1	WBedVkkDog	4203180	Dotatie garantievoorziening verkoop gerelateerde kosten	D	4	\N	t
4614	1	WBedVkkVgv	4203190	Vrijval garantievoorziening verkoop gerelateerde kosten	C	4	\N	t
4615	1	WBedVkkWeb	4203200	Websitekosten verkoop gerelateerde kosten	D	4	\N	t
4616	1	WBedVkkObs	4203210	Overige belastingen inzake verkoopactiviteiten verkoop gerelateerde kosten	D	4	\N	t
4617	1	WBedVkkOvr	4203220	Overige verkoopkosten verkoop gerelateerde kosten	D	4	\N	t
4618	1	WBedVkkDbv	4203990	Doorberekende verkoopkosten verkoop gerelateerde kosten	C	4	\N	t
4619	1	WBedVkkDfw	4203999	Doorberekend / Overboeking ivm functionele indeling verkoopkosten	C	4	\N	t
4620	1	WBedAut	4204000	Autokosten en andere vervoermiddelen	D	3	\N	t
4621	1	WBedAutBra	4204010	Brandstofkosten auto's autokosten en andere vervoermiddelen	D	4	\N	t
4622	1	WBedAutRoa	4204020	Reparatie en onderhoud auto's autokosten en andere vervoermiddelen	D	4	\N	t
4623	1	WBedAutAsa	4204030	Assurantiepremie auto's autokosten en andere vervoermiddelen	D	4	\N	t
4624	1	WBedAutMot	4204040	Motorrijtuigenbelasting auto's autokosten en andere vervoermiddelen	D	4	\N	t
4625	1	WBedAutOpa	4204050	Operational leasing auto's autokosten en andere vervoermiddelen	D	4	\N	t
4626	1	WBedAutBwl	4204060	Bijdrage werknemers leaseregeling autokosten en andere vervoermiddelen	C	4	\N	t
4627	1	WBedAutPga	4204070	Privé-gebruik auto's autokosten en andere vervoermiddelen	C	4	\N	t
4628	1	WBedAutBop	4204080	BTW op privé-gebruik auto's autokosten en andere vervoermiddelen	D	4	\N	t
4629	1	WBedAutHua	4204090	Huur auto's autokosten en andere vervoermiddelen	D	4	\N	t
4630	1	WBedAutKil	4204100	Kilometervergoeding autokosten en andere vervoermiddelen	D	4	\N	t
4631	1	WBedAutBeb	4204110	Boetes en bekeuringen autokosten en andere vervoermiddelen	D	4	\N	t
4632	1	WBedAutObv	4204120	Overige belastingen inzake auto's autokosten en andere vervoermiddelen	D	4	\N	t
4633	1	WBedAutDrv	4204130	Dotatie reserve assurantie eigen risico auto's autokosten	D	4	\N	t
4634	1	WBedAutVrv	4204140	Vrijval reserve assurantie eigen risico auto's autokosten	C	4	\N	t
4635	1	WBedAutDkv	4204150	Dotatie kostenegalisatiereserve groot onderhoud auto's autokosten en andere vervoermiddelen	D	4	\N	t
4636	1	WBedAutVkv	4204160	Vrijval kostenegalisatiereserve groot onderhoud auto's autokosten en andere vervoermiddelen	C	4	\N	t
4637	1	WBedAutDvv	4204170	Dotatie voorziening groot onderhoud auto's autokosten en andere vervoermiddelen	D	4	\N	t
4638	1	WBedAutVoa	4204180	Vrijval voorziening groot onderhoud auto's autokosten en andere vervoermiddelen	C	4	\N	t
4639	1	WBedAutPar	4204190	Parkeerkosten auto's autokosten en andere vervoermiddelen	D	4	\N	t
4640	1	WBedAutOak	4204200	Overige autokosten autokosten en andere vervoermiddelen	D	4	\N	t
4641	1	WBedAutDau	4204990	Doorberekende autokosten autokosten en andere vervoermiddelen	C	4	\N	t
4642	1	WBedAutDfw	4204999	Doorberekend / Overboeking ivm functionele indeling autokosten en andere vervoermiddelen	C	4	\N	t
4643	1	WBedTra	4205000	Transportkosten	D	3	\N	t
4644	1	WBedTraBrr	4205010	Brandstofkosten transportmiddelen transportkosten	D	4	\N	t
4645	1	WBedTraRot	4205020	Reparatie en onderhoud transportmiddelen transportkosten	D	4	\N	t
4646	1	WBedTraAst	4205030	Assurantiepremie transportmiddelen transportkosten	D	4	\N	t
4647	1	WBedTraMot	4205040	Motorrijtuigenbelasting transportmiddelen transportkosten	D	4	\N	t
4648	1	WBedTraOpt	4205050	Operational leasing transportmiddelen transportkosten	D	4	\N	t
4649	1	WBedTraPgt	4205060	Privé-gebruik transportmiddelen transportkosten	C	4	\N	t
4650	1	WBedTraBot	4205070	BTW op privé-gebruik transportmiddelen transportkosten	D	4	\N	t
4651	1	WBedTraHut	4205080	Huur transportmiddelen transportkosten	D	4	\N	t
4652	1	WBedTraObt	4205090	Overige belastingen inzake transportmiddelen transportkosten	D	4	\N	t
4653	1	WBedTraDrt	4205100	Dotatie reserve assurantie eigen risico transportmiddelen transportkosten	D	4	\N	t
4654	1	WBedTraVrt	4205110	Vrijval reserve assurantie eigen risico transportmiddelen transportkosten	C	4	\N	t
4655	1	WBedTraDkt	4205120	Dotatie kostenegalisatiereserve groot onderhoud transportmiddelen transportkosten	D	4	\N	t
4656	1	WBedTraVkt	4205130	Vrijval kostenegalisatiereserve groot onderhoud transportmiddelen transportkosten	C	4	\N	t
4657	1	WBedTraDvt	4205140	Dotatie voorziening groot onderhoud transportmiddelen transportkosten	D	4	\N	t
4658	1	WBedTraVot	4205150	Vrijval voorziening groot onderhoud transportmiddelen transportkosten	C	4	\N	t
4659	1	WBedTraPar	4205160	Parkeerkosten transportmiddelen transportkosten	D	4	\N	t
4660	1	WBedTraAki	4205165	Afhandelingskosten import	D	4	\N	t
4661	1	WBedTraOpk	4205166	Opslagkosten	D	4	\N	t
4662	1	WBedTraOtr	4205170	Overige transportkosten transportkosten	D	4	\N	t
4663	1	WBedTraDot	4205990	Doorberekende transportkosten transportkosten	C	4	\N	t
4664	1	WBedTraDfw	4205999	Doorberekend / Overboeking ivm functionele indeling transportkosten	C	4	\N	t
4665	1	WBedKan	4206000	Kantoorkosten	D	3	\N	t
4666	1	WBedKanKan	4206010	Kantoorbenodigdheden kantoorkosten	D	4	\N	t
4669	1	WBedKanPrt	4206040	Privé-gebruik telefoon kantoorkosten	C	4	\N	t
4670	1	WBedKanDru	4206050	Drukwerk kantoorkosten	D	4	\N	t
4671	1	WBedKanKak	4206060	Kleine aanschaffingen kantoorinventaris kantoorkosten	D	4	\N	t
4672	1	WBedKanCea	4206070	Contributies en abonnementen kantoorkosten	D	4	\N	t
4673	1	WBedKanVak	4206080	Vakliteratuur kantoorkosten	D	4	\N	t
4674	1	WBedKanBoe	4206090	Boekhouding kantoorkosten	D	4	\N	t
4675	1	WBedKanInc	4206100	Incassokosten a.g.v. kantooractiviteiten kantoorkosten	D	4	\N	t
4676	1	WBedKanKoa	4206110	Kosten automatisering kantoorkosten	D	4	\N	t
4677	1	WBedKanSof	4206115	Kosten software abonnementen	D	4	\N	t
4678	1	WBedKanAss	4206120	Assurantiepremie kantoorkosten	D	4	\N	t
4679	1	WBedKanOba	4206130	Overige administratieve belastingen kantoorkosten	D	4	\N	t
4680	1	WBedKanRok	4206140	Reparatie en onderhoud kantoorinventaris kantoorkosten	D	4	\N	t
4681	1	WBedKanOka	4206150	Overige kantoorkosten kantoorkosten	D	4	\N	t
4682	1	WBedKanDka	4206990	Doorberekende kantoorkosten kantoorkosten	C	4	\N	t
4683	1	WBedKanCom	4206160	Communicatie	D	4	\N	t
4684	1	WBedKanDfw	4206999	Doorberekend / Overboeking ivm functionele indeling kantoorkosten	C	4	\N	t
4685	1	WBedOrg	4207000	Organisatiekosten	D	3	\N	t
4686	1	WBedOrgHol	4207010	Holdingkosten organisatiekosten	D	4	\N	t
4687	1	WBedOrgKvt	4207015	Kosten van toezicht	D	4	\N	t
4688	1	WBedOrgDmf	4207020	Doorberekende management fee organisatiekosten	C	4	\N	t
4689	1	WBedOrgFra	4207025	Franchisefee organisatiekosten	D	4	\N	t
4690	1	WBedOrgOeo	4207030	Onderzoek en ontwikkeling organisatiekosten	D	4	\N	t
4691	1	WBedOrgLgv	4207040	Leges / vergunningen organisatiekosten	D	4	\N	t
4692	1	WBedOrgOct	4207050	Octrooi en licentiekosten organisatiekosten	D	4	\N	t
4693	1	WBedOrgOok	4207060	Overige organisatiekosten organisatiekosten	D	4	\N	t
4694	1	WBedOrgDoo	4207990	Doorberekende organisatiekosten organisatiekosten	C	4	\N	t
4695	1	WBedOrgWrc	4207995	Bedrijfsrestaurant en verstrekkingen comsumpties werkvloer	D	4	\N	t
4696	1	WBedOrgKgd	4207996	Kosten van giften en donaties	D	4	\N	t
4697	1	WBedOrgDfw	4207999	Doorberekend / Overboeking ivm functionele indeling organisatiekosten	C	4	\N	t
4698	1	WBedAss	4208000	Assurantiekosten	D	3	\N	t
4699	1	WBedAssBea	4208010	Bedrijfsaansprakelijkheidsverzekering assurantiekosten	D	4	\N	t
4700	1	WBedAssOva	4208020	Overige assurantiepremies assurantiekosten	D	4	\N	t
4701	1	WBedAssScb	4208030	Schadevergoedingen betaald assurantiekosten	D	4	\N	t
4702	1	WBedAssSco	4208040	Schadevergoedingen ontvangen assurantiekosten	C	4	\N	t
4703	1	WBedAssDas	4208990	Doorberekende assurantiekosten assurantiekosten	C	4	\N	t
4704	1	WBedAssAvk	4208950	Overige advieskosten	D	4	\N	t
4705	1	WBedAssBhk	4208960	Overige beheerskosten	D	4	\N	t
4706	1	WBedAssDfw	4208999	Doorberekend / Overboeking ivm functionele indeling assurantiekosten	C	4	\N	t
4707	1	WBedAea	4209000	Accountants- en advieskosten	D	3	\N	t
4708	1	WBedAeaAea	4209005	Accountants- en advieskosten	D	4	\N	t
4709	1	WBedAeaAeaAov	4209010	Accountantshonoraria inzake het onderzoek van de jaarrekening accountants- en advieskosten	D	5	\N	t
4710	1	WBedAeaAeaAac	4209020	Accountantshonoraria inzake andere controleopdrachten accountants- en advieskosten	D	5	\N	t
4711	1	WBedAeaAeaAao	4209030	Accountantshonoraria inzake adviesdiensten op fiscaal terrein accountants- en advieskosten	D	5	\N	t
4712	1	WBedAeaAeaAnc	4209040	Accountantshonoraria inzake andere niet-controlediensten accountants- en advieskosten	D	5	\N	t
4713	1	WBedAeaPda	4209050	Privé-gedeelte accountant accountants- en advieskosten	C	4	\N	t
4714	1	WBedAeaNot	4209060	Notariskosten accountants- en advieskosten	D	4	\N	t
4715	1	WBedAeaAej	4209070	Advocaat en juridisch advies accountants- en advieskosten	D	4	\N	t
4716	1	WBedAeaAdv	4209080	Overige advieskosten accountants- en advieskosten	D	4	\N	t
4717	1	WBedAeaDae	4209990	Doorberekende accountants- en advieskosten accountants- en advieskosten	C	4	\N	t
4718	1	WBedAeaDfw	4209999	Doorberekend / Overboeking ivm functionele indeling accountants- en advieskosten	C	4	\N	t
4719	1	WBedAdl	4210000	Administratieve lasten	D	3	\N	t
4720	1	WBedAdlHef	4210010	Heffingen administratieve lasten	D	4	\N	t
4721	1	WBedAdlOvb	4210020	Overige belastingen administratieve lasten	D	4	\N	t
4722	1	WBedAdlKav	4210030	Kasverschillen administratieve lasten	D	4	\N	t
4723	1	WBedAdlBan	4210040	Bankkosten administratieve lasten	D	4	\N	t
4724	1	WBedAdlVal	4210050	Valutaomrekeningsverschillen administratieve lasten	D	4	\N	t
4725	1	WBedAdlBov	4210060	Boekingsverschillen administratieve lasten	D	4	\N	t
4726	1	WBedAdlBet	4210070	Betalingsverschillen administratieve lasten	D	4	\N	t
4727	1	WBedAdlBev	4210080	Boetes en verhogingen belastingen en premies sociale verzekeringen administratieve lasten	D	4	\N	t
4728	1	WBedAdlNao	4210090	Naheffing omzetbelasting administratieve lasten	D	4	\N	t
4729	1	WBedAdlNbo	4210100	Niet-verrekenbare BTW op kosten administratieve lasten	D	4	\N	t
4730	1	WBedAdlBtk	4210110	BTW kleine-ondernemers-regeling administratieve lasten	C	4	\N	t
4731	1	WBedAdlOad	4210120	Overige administratieve lasten administratieve lasten	D	4	\N	t
4732	1	WBedAdlDal	4210990	Doorberekende administratieve lasten administratieve lasten	C	4	\N	t
4733	1	WBedAdlKlv	4210995	Kluisverschillen	D	4	\N	t
4734	1	WBedAdlOpr	4210997	Opbrengst pro rata	C	4	\N	t
4735	1	WBedAdlDfw	4210999	Doorberekend / Overboeking ivm functionele indeling administratieve lasten	C	4	\N	t
4736	1	WBedKof	4211000	Kosten fondsenwerving	D	3	\N	t
4737	1	WBedKofBad	4211010	Bestedingen aan doelstelling kosten fondsenwerving	D	4	\N	t
4738	1	WBedKofKef	4211020	Kosten eigen fondsenwerwing kosten fondsenwerving	D	4	\N	t
4739	1	WBedKofKgf	4211030	Kosten gezamenlijke fondsenwervingsacties kosten fondsenwerving	D	4	\N	t
4740	1	WBedKofKfv	4211040	Kosten fondsenwervingsacties van derden kosten fondsenwerving	D	4	\N	t
4741	1	WBedKofKvs	4211050	Kosten verkrijging subsidies overheden kosten fondsenwerving	D	4	\N	t
4742	1	WBedKofDfw	4211099	Doorberekend / Overboeking ivm functionele indeling kosten fondsenwerving	C	4	\N	t
4743	1	WBedKse	4212000	Kosten stamrecht en lijfrentes	D	3	\N	t
4744	1	WBedKseAbs	4212010	Vrijval stamrecht- en lijfrentevoorzieningen kosten stamrecht en lijfrentes	C	4	\N	t
4745	1	WBedKseLiu	4212020	Lijfrente-uitkeringen	D	4	\N	t
4746	1	WBedKseDfw	4212099	Doorberekend / Overboeking ivm functionele indeling kosten stamrecht en lijfrentes	C	4	\N	t
4747	1	WBedDvr	4213000	Dotaties en vrijval (fiscale) reserves	D	3	\N	t
4748	1	WBedDvrDfr	4213130	Dotatie (fiscale) reserves dotaties en vrijval (fiscale) reserves	D	4	\N	t
4749	1	WBedDvrVfr	4213140	Vrijval (fiscale) reserves dotaties en vrijval (fiscale) reserves	C	4	\N	t
4750	1	WBedDvrDfw	4213199	Doorberekend / Overboeking ivm functionele indeling dotaties en vrijval (fiscale) reserves	C	4	\N	t
4751	1	WBedDvv	4214000	Dotaties en vrijval voorzieningen	D	3	\N	t
4752	1	WBedDvvDvu	4214010	Dotatie voorziening uit hoofde van claims, geschillen en rechtsgedingen	D	4	\N	t
4753	1	WBedDvvDvh	4214020	Dotatie voorziening voor herstelkosten	D	4	\N	t
4754	1	WBedDvvDvo	4214030	Dotatie voorziening voor opruiming van aanwezige milieuvervuiling	D	4	\N	t
4755	1	WBedDvvDvc	4214040	Dotatie voorziening voor verlieslatende contracten	D	4	\N	t
4756	1	WBedDvvDvw	4214050	Dotatie voorziening voor verwijderingsverplichtingen	D	4	\N	t
4757	1	WBedDvvDov	4214060	Dotatie overige voorzieningen	D	4	\N	t
4758	1	WBedDvvVvu	4214070	Vrijval voorziening uit hoofde van claims, geschillen en rechtsgedingen	C	4	\N	t
4759	1	WBedDvvVvh	4214080	Vrijval voorziening voor herstelkosten	C	4	\N	t
4760	1	WBedDvvVvm	4214090	Vrijval voorziening voor opruiming van aanwezige milieuvervuiling	C	4	\N	t
4761	1	WBedDvvVvc	4214100	Vrijval voorziening voor verlieslatende contracten	C	4	\N	t
4762	1	WBedDvvVvw	4214110	Vrijval voorziening voor verwijderingsverplichtingen	C	4	\N	t
4763	1	WBedDvvVov	4214120	Vrijval overige voorzieningen	C	4	\N	t
4764	1	WBedDvvDfw	4214199	Doorberekend / Overboeking ivm functionele indeling dotaties en vrijval voorzieningen	C	4	\N	t
4765	1	WBedAlk	4215000	Andere kosten	D	3	\N	t
4766	1	WBedAlkOal	4215010	Algemene kosten andere kosten	D	4	\N	t
4767	1	WBedAlkKzo	4215015	Kosten zelfstandig ondernemer	D	4	\N	t
4768	1	WBedAlkDak	4215020	Doorberekende kosten andere kosten	C	4	\N	t
4769	1	WBedAlkDfw	4215099	Doorberekend / Overboeking ivm functionele indeling andere kosten	C	4	\N	t
4770	1	WOvt	45	Opbrengst van vorderingen die tot de vaste activa behoren en van effecten	C	2	\N	t
4771	1	WOvtRof	8401000	Opbrengst van vorderingen die tot de vaste activa behoren en van effecten	C	3	\N	t
4772	1	WOvtRofRig	8401010	Rentebaten vorderingen groepsmaatschappijen binnenland opbrengst van vorderingen die tot de vaste activa behoren en van effecten	C	4	\N	t
4773	1	WOvtRofRug	8401020	Rentebaten vorderingen groepsmaatschappijen buitenland opbrengst van vorderingen die tot de vaste activa behoren en van effecten	C	4	\N	t
4774	1	WOvtRofRvp	8401030	Rentebaten vorderingen participanten en overige deelnemingen	C	4	\N	t
4775	1	WOvtRofRvi	8401031	Rentebaten vorderingen overige verbonden maatschappijen binnenland opbrengst van vorderingen die tot de vaste activa behoren en van effecten	C	4	\N	t
4776	1	WOvtRofRvu	8401032	Rentebaten vorderingen overige verbonden maatschappijen buitenland opbrengst van vorderingen die tot de vaste activa behoren en van effecten	C	4	\N	t
4777	1	WOvtRofRid	8401040	Rentebaten vorderingen op deelnemingen binnenland opbrengst van vorderingen die tot de vaste activa behoren en van effecten	C	4	\N	t
4778	1	WOvtRofRud	8401050	Rentebaten vorderingen op deelnemingen buitenland opbrengst van vorderingen die tot de vaste activa behoren en van effecten	C	4	\N	t
4779	1	WOvtRofRva	8401060	Rentebaten vorderingen op aandeelhouders opbrengst van vorderingen die tot de vaste activa behoren en van effecten	C	4	\N	t
4780	1	WOvtRofRvd	8401070	Rentebaten vorderingen op directie opbrengst van vorderingen die tot de vaste activa behoren en van effecten	C	4	\N	t
4781	1	WOvtRofRov	8401080	Rentebaten overige vorderingen opbrengst van vorderingen die tot de vaste activa behoren en van effecten	C	4	\N	t
4782	1	WOvtRofDiv	8401090	Dividend effecten opbrengst van vorderingen die tot de vaste activa behoren en van effecten	C	4	\N	t
4783	1	WOvtRofOoe	8401100	Opbrengst overige effecten opbrengst van vorderingen die tot de vaste activa behoren en van effecten	C	4	\N	t
4784	1	WOvtRofRor	8401110	Rentebaten overige rekeningen-courant	C	4	\N	t
4785	1	WOvtRofLen	8401120	Rentebaten leningen u/g opbrengst van vorderingen die tot de vaste activa behoren en van effecten	C	4	\N	t
4786	1	WVhe	46	Vrijval herwaarderingsreserve	C	2	\N	t
4787	1	WVheVuh	8301000	Vrijval uit herwaarderingsreserve	C	3	\N	t
4788	1	WVheVuhVuh	8301010	Vrijval uit herwaarderingsreserve	C	4	\N	t
4789	1	WVheVei	8302000	Vrijval egalisatierekening IPR	C	3	\N	t
4790	1	WVheVeiVei	8302010	Vrijval egalisatierekening IPR	C	4	\N	t
4791	1	WVheVoe	8303000	Vrijval overige egalisatierekeningen	C	3	\N	t
4792	1	WVheVoeVoe	8303010	Vrijval overige egalisatierekeningen	C	4	\N	t
4793	1	WWfa	47	Waardeveranderingen van financiële vaste activa en van effecten	D	2	\N	t
4794	1	WWfaBwv	8405000	Waardeveranderingen van financiële vaste activa en van effecten	D	3	\N	t
4795	1	WWfaBwvFva	8405004	Bijzondere waardeverminderingen van financiële vaste activa	D	4	\N	t
4796	1	WWfaBwvFvaDgr	8405005	Waardeveranderingen groepsmaatschappijen	D	5	\N	t
4797	1	WWfaBwvFvaDee	8405010	Waardeveranderingen overige deelnemingen	D	5	\N	t
4798	1	WWfaBwvFvaLvo	8405020	Langlopende vorderingen op deelnemingen	D	5	\N	t
4799	1	WWfaBwvFvaRcm	8405030	Rekening-courant met deelnemingen	D	5	\N	t
4800	1	WWfaBwvFvaOvm	8405040	Overige vorderingen	D	5	\N	t
4801	1	WWfaBwvFvaRca	8405060	Rekening-courant aandeelhouder	D	5	\N	t
4802	1	WWfaBwvFvaRcd	8405070	Rekening-courant directie	D	5	\N	t
4803	1	WWfaBwvFvaLen	8405075	Leningen u/g	D	5	\N	t
4804	1	WWfaBwvWse	8405080	Bijzondere waardestijgingen van effecten waardeveranderingen van financiële vaste activa en van effecten	C	4	\N	t
4805	1	WWfaBwvOef	8405050	Bijzondere waardeverminderingen van effecten waardeveranderingen van financiële vaste activa en van effecten	D	4	\N	t
4806	1	WWfaBwvTwf	8405100	Terugneming van bijzondere waardeverminderingen van financiële vaste activa waardeveranderingen van financiële vaste activa en van effecten	C	4	\N	t
4807	1	WWfaBwvTwe	8405110	Terugneming van bijzondere waardeverminderingen van effecten waardeveranderingen van financiële vaste activa en van effecten	C	4	\N	t
4808	1	WWfaBwvOvp	8405120	Verkoopopbrengst vastgoedportefeuille Verkoop Onder Voorwaarden	C	4	\N	t
4809	1	WWfaBwvTok	8405130	Toegerekende organisatiekosten Verkoop Onder Voorwaarden	D	4	\N	t
4810	1	WWfaBwvTokSal	8405130.01	Toegerekende organisatiekosten salarissen resultaat verkoop vastgoedportefeuille aan Verkoop Onder Voorwaarden	D	5	\N	t
4811	1	WWfaBwvTokSoc	8405130.02	Toegerekende organisatiekosten sociale lasten resultaat verkoop vastgoedportefeuille aan Verkoop Onder Voorwaarden	D	5	\N	t
4812	1	WWfaBwvTokPen	8405130.03	Toegerekende organisatiekosten pensioenlasten resultaat verkoop vastgoedportefeuille aan Verkoop Onder Voorwaarden	D	5	\N	t
4813	1	WWfaBwvTokAfs	8405130.04	Toegerekende organisatiekosten afschrijvingen resultaat verkoop vastgoedportefeuille aan Verkoop Onder Voorwaarden	D	5	\N	t
4814	1	WWfaBwvTokObl	8405130.05	Toegerekende organisatiekosten overige bedrijfslasten resultaat verkoop vastgoedportefeuille aan Verkoop Onder Voorwaarden	D	5	\N	t
4815	1	WWfaBwvTokOpl	8405130.06	Toegerekende organisatiekosten overige personeelslasten aan Verkoop Onder Voorwaarden	D	5	\N	t
4816	1	WWfaBwvLsc	8405131	Boekwaarde verkochte vastgoedportefeuille mbt Verkoop Onder Voorwaarden	D	4	\N	t
4817	1	WWfaBwvVvk	8405132	Verkoopkosten (makelaar, notaris e.d.) mbt Verkoop Onder Voorwaarden	D	4	\N	t
4818	1	WWfaBwvVbm	8405133	Verkoopbevorderende maatregelen mbt Verkoop Onder Voorwaarden	D	4	\N	t
4819	1	WFbe	50	Financiële baten en lasten	C	2	\N	t
4820	1	WFbeRlm	8402000	Rentebaten en soortgelijke opbrengsten	C	3	\N	t
4821	1	WFbeRlmRgi	8402030	Rentebaten vorderingen groepsmaatschappijen binnenland	C	4	\N	t
4822	1	WFbeRlmRgu	8402040	Rentebaten vorderingen groepsmaatschappijen buitenland	C	4	\N	t
4823	1	WFbeRlmRmi	8402050	Rentebaten vorderingen overige verbonden maatschappijen binnenland	C	4	\N	t
4824	1	WFbeRlmRmu	8402060	Rentebaten vorderingen overige verbonden maatschappijen buitenland	C	4	\N	t
4825	1	WFbeRlmRdi	8402070	Rentebaten vorderingen deelnemingen binnenland	C	4	\N	t
4826	1	WFbeRlmRdu	8402080	Rentebaten vorderingen deelnemingen buitenland	C	4	\N	t
4827	1	WFbeRlmRlm	8402110	Rente liquide middelen rentebaten en soortgelijke opbrengsten	C	4	\N	t
4828	1	WFbeRlmOdr	8402010	Rentebaten depositorekeningen rentebaten en soortgelijke opbrengsten	C	4	\N	t
4829	1	WFbeRlmObr	8402020	Rentebaten bankrekeningen rentebaten en soortgelijke opbrengsten	C	4	\N	t
4830	1	WFbeRlmRva	8402090	Rentebaten vorderingen op aandeelhouders	C	4	\N	t
4831	1	WFbeRlmRvf	8402095	Rentebaten vorderingen op firmanten	C	4	\N	t
4832	1	WFbeRlmRrb	8402100	Rentebaten rekeningen-courant bestuurders rentebaten en soortgelijke opbrengsten	C	4	\N	t
4833	1	WFbeRlmRrc	8402105	Rentebaten rekeningen-courant commissarissen rentebaten en soortgelijke opbrengsten	C	4	\N	t
4834	1	WFbeRlmRbb	8403010	Rentebaten belastingen rentebaten en soortgelijke opbrengsten	C	4	\N	t
4835	1	WFbeRlmRil	8402120	Rentebaten interne lening	C	4	\N	t
4836	1	WFbeRlmKgd	8402130	Rentebaten kasgeld	C	4	\N	t
4837	1	WFbeRlmCol	8402140	Rente baten collateral	C	4	\N	t
4838	1	WFbeRlmCfv	8402150	Rentebaten CFV	C	4	\N	t
4839	1	WFbeRlmKsw	8403030	Kwijtscheldingswinst	C	4	\N	t
4840	1	WFbeRlmAre	8403020	Overige rentebaten rentebaten en soortgelijke opbrengsten	C	4	\N	t
4841	1	WFbeRlmInc	8402190	Rentebaten incasso	C	4	\N	t
4842	1	WFbeRlmMvl	8402200	Marktwaardecorrectie van de vastrentende lening	C	4	\N	t
4843	1	WFbeRls	8404000	Rentelasten en soortgelijke kosten	D	3	\N	t
4844	1	WFbeRlsRal	8404010	Rentelasten achtergestelde leningen	D	4	\N	t
4845	1	WFbeRlsRcl	8404015	Rentelasten converteerbare leningen	D	4	\N	t
4846	1	WFbeRlsRob	8404020	Rentelasten obligatieleningen	D	4	\N	t
4847	1	WFbeRlsRol	8404030	Rentelasten onderhandse leningen	D	4	\N	t
4848	1	WFbeRlsRhl	8404040	Rentelasten hypethecaire leningen	D	4	\N	t
4849	1	WFbeRlsRle	8404050	Rentelasten overige leningen	D	4	\N	t
4850	1	WFbeRlsRef	8404060	Rentelasten financieringen	D	4	\N	t
4851	1	WFbeRlsRlk	8404065	Rentelasten  kredietinstellingen	D	4	\N	t
4852	1	WFbeRlsRlv	8404070	Rentelasten leaseverplichtingen	D	4	\N	t
4853	1	WFbeRlsRlo	8404075	Rentelasten overheid	D	4	\N	t
4854	1	WFbeRlsRgi	8404080	Rentelasten schulden groepsmaatschappijen binnenland rentelasten en soortgelijke kosten	D	4	\N	t
4855	1	WFbeRlsRgu	8404090	Rentelasten schulden groepsmaatschappijen buitenland rentelasten en soortgelijke kosten	D	4	\N	t
4856	1	WFbeRlsRmi	8404150	Rentelasten schulden overige verbonden maatschappijen binnenland rentelasten en soortgelijke kosten	D	4	\N	t
4857	1	WFbeRlsRmu	8404160	Rentelasten schulden overige verbonden maatschappijen buitenland rentelasten en soortgelijke kosten	D	4	\N	t
4858	1	WFbeRlsRdi	8404110	Rentelasten schulden op deelnemingen binnenland rentelasten en soortgelijke kosten	D	4	\N	t
4859	1	WFbeRlsRdu	8404120	Rentelasten schulden op deelnemingen buitenland rentelasten en soortgelijke kosten	D	4	\N	t
4860	1	WFbeRlsRsa	8404130	Rentelasten schulden aan aandeelhouders rentelasten en soortgelijke kosten	D	4	\N	t
4861	1	WFbeRlsRsf	8404135	Rentelasten schulden aan firmanten	D	4	\N	t
4862	1	WFbeRlsRsd	8404140	Rentelasten schulden aan bestuurders rentelasten en soortgelijke kosten	D	4	\N	t
4863	1	WFbeRlsRsc	8404145	Rentelasten schulden aan commissarissen rentelasten en soortgelijke kosten	D	4	\N	t
4864	1	WFbeRlsRil	8404190	Rentelasten interne lening	D	4	\N	t
4865	1	WFbeRlsRps	8404200	Rente payerswaps	D	4	\N	t
4866	1	WFbeRlsNhr	8404210	Nog toe te rekenen hedgeresultaat renteswaps	D	4	\N	t
4867	1	WFbeOrl	8406000	Overige rentelasten	D	3	\N	t
4868	1	WFbeOrlRpe	8406010	Rentelasten pensioenverplichtingen	D	4	\N	t
4869	1	WFbeOrlRli	8406020	Rentelasten lijfrenteverplichtingen	D	4	\N	t
4870	1	WFbeOrlRlb	8406030	Rentelasten belastingen	D	4	\N	t
4871	1	WFbeOrlRos	8406040	Rentelasten overige schulden rentelasten en soortgelijke kosten	D	4	\N	t
4872	1	WFbeOrlRkb	8406050	Rente en kosten bank	D	4	\N	t
4873	1	WFbeOrlWbs	8406060	Rente waarborgsommen	D	4	\N	t
4874	1	WFbeOrlRld	8406070	Rente disagio	D	4	\N	t
4875	1	WFbeOrlRls	8406080	Rentelasten steun	D	4	\N	t
4876	1	WFbeOrlOrl	8406090	Overige rentelasten rentelasten en soortgelijke kosten	D	4	\N	t
4877	1	WFbeOrlTrv	8406095	Toegevoegde rente aan voorzieningen	D	4	\N	t
4878	1	WFbeOrlWsw	8406100	Borgstellingsvergoeding WSW	D	4	\N	t
4879	1	WFbeOrlObl	8406110	Bereidstellingsprovisie Obligolening WSW	D	4	\N	t
4880	1	WFbeWis	8407000	Wisselkoersverschillen	D	3	\N	t
4881	1	WFbeWisWis	8407010	Valutakoersverschillen rentelasten en soortgelijke kosten	D	4	\N	t
4882	1	WFbeKvb	8408000	Kosten van beleggingen	D	3	\N	t
4883	1	WFbeKvbKvb	8408010	Kosten van beleggingen rentelasten en soortgelijke kosten	D	4	\N	t
4884	1	WFbeKba	8409000	Kosten van beheer en administratie	D	3	\N	t
4885	1	WFbeKbaKba	8409010	Kosten van beheer en administratie rentelasten en soortgelijke kosten	D	4	\N	t
4886	1	WFbeOnn	8497000	Opbrengsten uit niet op netto-vermogenswaarde e.d. gewaardeerde deelnemingen	C	3	\N	t
4887	1	WFbeOnnOnn	8497010	Opbrengsten uit niet op netto-vermogenswaarde e.d. gewaardeerde deelnemingen	C	4	\N	t
4888	1	WFbeWnn	8498000	Waardeveranderingen van niet op netto-vermogenswaarde e.d. gewaardeerde deelnemingen	C	3	\N	t
4889	1	WFbeWnnWnn	8498010	Waardeveranderingen van niet op netto-vermogenswaarde e.d. gewaardeerde deelnemingen	C	4	\N	t
4890	1	WFbeDer	8500000	Derivaten	D	3	\N	t
4891	1	WFbeDerMmd	8500010	Mutatie marktwaarde derivaten	D	4	\N	t
4892	1	WFbeDerMal	8500020	Mutatie amortisatie leningen	D	4	\N	t
4893	1	WFbeDerMme	8500030	Mutatie marktwaarde embedded derivaten	D	4	\N	t
4894	1	WFbeDerMae	8500040	Mutatie amortisatie embedded leningen	D	4	\N	t
4895	1	WFbePol	8510000	Positieve verschil tussen het ontvangen bedrag en de bij het aangaan van de lening als schuld erkende hoofdsom	C	3	\N	t
4896	1	WFbePolPol	8510100	Positieve verschil tussen het ontvangen bedrag en de bij het aangaan van de lening als schuld erkende hoofdsom	C	4	\N	t
4897	1	WFbePhp	8511000	Positieve herwaarderingen van puttable financiële instrumenten	C	3	\N	t
4898	1	WFbePhpPhp	8511100	Positieve herwaarderingen van puttable financiële instrumenten	C	4	\N	t
4899	1	WFbeAad	8512000	(Amortisatie van) agio en disagio	D	3	\N	t
4900	1	WFbeAadAad	8512100	(Amortisatie van) agio en disagio	D	4	\N	t
4901	1	WFbeNol	8513000	Negatieve verschil tussen het ontvangen bedrag en de bij het aangaan van de lening als schuld erkende hoofdsom	D	3	\N	t
4902	1	WFbeNolNol	8513100	Negatieve verschil tussen het ontvangen bedrag en de bij het aangaan van de lening als schuld erkende hoofdsom	D	4	\N	t
4903	1	WFbeDfb	8499000	Doorberekende financiële baten en lasten	C	3	\N	t
4904	1	WFbeDfbDrb	8499010	Doorberekende financiële baten doorberekende financiële baten en lasten	D	4	\N	t
4905	1	WFbeDfbDrl	8499020	Doorberekende financiële lasten doorberekende financiële baten en lasten	C	4	\N	t
4906	1	WFbeDfbDof	8499030	Doorberekende overige financiële baten en lasten	C	4	\N	t
4907	1	WFbeNhp	8514000	Negatieve herwaarderingen van puttable financiële instrumenten	D	3	\N	t
4908	1	WFbeNhpNhp	8514100	Negatieve herwaarderingen van puttable financiële instrumenten	D	4	\N	t
4909	1	WFbeAlp	8515000	Aflossingspremies	D	3	\N	t
4910	1	WFbeAlpAlp	8515100	Aflossingspremies	D	4	\N	t
4911	1	WFbeEmk	8516000	Emissiekosten	D	3	\N	t
4912	1	WFbeEmkEmk	8516100	Emissiekosten	D	4	\N	t
4913	1	WFbeKva	8517000	Kosten bij vervroegde aflossing (eenmalig)	D	3	\N	t
4914	1	WFbeKvaKva	8517100	Kosten bij vervroegde aflossing (eenmalig)	D	4	\N	t
4915	1	WFbeBkf	8518000	Bijkomende kosten ter afsluiting van een financiering	D	3	\N	t
4916	1	WFbeBkfBkf	8518100	Bijkomende kosten ter afsluiting van een financiering	D	4	\N	t
4917	1	WFbeVlr	8519000	Valutaverschillen op leningen voor zover zij als een correctie van de verschuldigde rentekosten kunnen worden aangemerkt	D	3	\N	t
4918	1	WFbeVlrVlr	8519100	Valutaverschillen op leningen voor zover zij als een correctie van de verschuldigde rentekosten kunnen worden aangemerkt	D	4	\N	t
4919	1	WFbeRfl	8520000	Rentekosten begrepen in de leasetermijn in geval van financiële leasing	D	3	\N	t
4920	1	WFbeRflRfl	8520100	Rentekosten begrepen in de leasetermijn in geval van financiële leasing	D	4	\N	t
4921	1	WBel	60	Belastingen	D	2	\N	t
4922	1	WBelBgr	9101000	Belastingen over de winst of het verlies	D	3	\N	t
4923	1	WBelBgrLab	9101005	Latente belastingen belastingen over de winst of het verlies	D	4	\N	t
4924	1	WBelBgrDlb	9101006	Dotatie voorziening voor latente belastingen	D	4	\N	t
4925	1	WBelBgrVlb	9101007	Vrijval voorziening voor latente belastingen	C	4	\N	t
4926	1	WBelBgrBgr	9101010	Belastingen uit huidig boekjaar belastingen over de winst of het verlies	D	4	\N	t
4927	1	WBelBgrBuv	9101020	Belastingen uit voorgaande boekjaren belastingen over de winst of het verlies	D	4	\N	t
4928	1	WBelBgrWlb	9101025	Waardevermindering van latente belastingvorderingen	D	4	\N	t
4929	1	WBelBgrOvb	9101030	Overige belastingen belastingen over de winst of het verlies	D	4	\N	t
4930	1	WRed	84	Aandeel in resultaat van ondernemingen waarin wordt deelgenomen	C	2	\N	t
4931	1	WRedAir	8410000	Aandeel in resultaat van ondernemingen waarin wordt deelgenomen	C	3	\N	t
4932	1	WRedAirAwd	8410010	Resultaat deelnemingen (dividend)	C	4	\N	t
4933	1	WRedAirGrp	8410015	Aandeel in winst (verlies) van deelnemingen in groepsmaatschappijen	C	4	\N	t
4934	1	WRedAirGrpGp1	8410015.01	Resultaat deelneming groepsmaatschappij 1	C	5	\N	t
4935	1	WRedAirGrpGp2	8410015.02	Resultaat deelneming groepsmaatschappij 2	C	5	\N	t
4936	1	WRedAirGrpGp3	8410015.03	Resultaat deelneming groepsmaatschappij 3	C	5	\N	t
4937	1	WRedAirGrpGp4	8410015.04	Resultaat deelneming groepsmaatschappij 4	C	5	\N	t
4938	1	WRedAirGrpGp5	8410015.05	Resultaat deelneming groepsmaatschappij 5	C	5	\N	t
4939	1	WRedAirOvd	8410016	Aandeel in winst (verlies) van overige deelnemingen	C	4	\N	t
4940	1	WRedAirDvn	8410020	Dotatie voorziening in verband met deelnemingen	C	4	\N	t
4941	1	WRedAirVvi	8410030	Vrijval voorziening in verband met deelnemingen	D	4	\N	t
4942	1	WRedAirAwb	8410040	Aandeel in winst (verlies) bestuurders	C	4	\N	t
4943	1	WRedArv	8420000	Aandeel in resultaat van ondernemingen waarin wordt deelgenomen - vrijstelling	C	3	\N	t
4944	1	WRedArvAwd	8420010	Resultaat deelnemingen (dividend) - vrijstelling	C	4	\N	t
4945	1	WRedArvGrp	8420015	Aandeel in winst (verlies) van deelnemingen in groepsmaatschappijen - vrijstelling	C	4	\N	t
4946	1	WRedArvOvd	8420016	Aandeel in winst (verlies) van overige deelnemingen - vrijstelling	C	4	\N	t
4947	1	WRedArvDvn	8420020	Dotatie voorziening in verband met deelnemingen - vrijstelling	C	4	\N	t
4948	1	WRedArvVvi	8420030	Vrijval voorziening in verband met deelnemingen - vrijstelling	D	4	\N	t
4949	1	WRedArvAwb	8420040	Aandeel in winst (verlies) bestuurders - vrijstelling	C	4	\N	t
4950	1	WLbe	88	Ledenbetalingen (inclusief reeds betaalde voorschotten)	C	2	\N	t
4951	1	WLbeLbv	9001100	Ledenbetalingen (inclusief reeds betaalde voorschotten)	C	3	\N	t
4952	1	WLbeLbvLbv	9001110	Ledenbetalingen (inclusief reeds betaalde voorschotten)	C	4	\N	t
4953	1	WAad	89	Aandeel derden	C	2	\N	t
4954	1	WAadRav	9001000	Resultaat aandeel van derden	C	3	\N	t
4955	1	WAadRavRav	9001010	Resultaat aandeel van derden	C	4	\N	t
4956	1	WNer	90	Nettoresultaat	C	2	\N	t
4957	1	WNerNew	9999000	Nettoresultaat na belastingen (B.V.)	C	3	\N	t
4958	1	WNerNewNew	9999010	Netto resultaat na belastingen (B.V.)	C	4	\N	t
4959	1	WNerKap	9999100	Nettoresultaat (EZ-VOF)	C	3	\N	t
4960	1	WNerKapKap	9999110	Netto resultaat (EZ-VOF)	C	4	\N	t
4961	1	WMfo	95	Mutatie fiscale oudedagsreserve	D	2	\N	t
4962	1	WMfoBel	9104000	Mutatie fiscale oudedagsreserve	D	3	\N	t
4963	1	WMfoBelMfo	9104010	Mutatie fiscale oudedagsreserve belastingen over de winst of het verlies	D	4	\N	t
\.


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY public.bookings (id, invoice_id, account_code, created_at, confidence_score) FROM stdin;
\.


--
-- Data for Name: coa; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY public.coa (number, description, parent_code, level) FROM stdin;
0201010.02	Investeringen terreinen	\N	5
0305010.14	Stortingen / ontvangen 	\N	5
0309024.15	Overige mutaties vorderingen op lid 5	\N	5
0309039.04	Toename ledenrekening 1	\N	5
0110010.05	Afstotingen overige immateriële vaste activa	\N	5
0203015.07	Afstotingen verbouwingen	\N	5
0215015.07	Afstotingen inventaris	\N	5
0704050.06	Oprenting van voorzieningen 	\N	5
0807010.13	Stortingen / ontvangsten	\N	5
0806171.09	Stortingen / ontvangsten	\N	5
1228510	Tussenrekening leningen OG	\N	3
8215010.04	Recettes	\N	5
0106020.03	Afschrijving op desinvesteringen concessies, vergunningen en intellectuele eigendom	\N	5
0101010.01	Beginbalans (overname eindsaldo vorig jaar) kosten van oprichting en van uitgifte van aandelen	\N	5
0101010.02	Investeringen kosten van oprichting en van uitgifte van aandelen	\N	5
0101010.03	Bij overname verkregen activa kosten van oprichting en van uitgifte van aandelen	\N	5
0101010.04	Desinvesteringen kosten van oprichting en van uitgifte van aandelen	\N	5
0101010.05	Afstotingen kosten van oprichting en van uitgifte van aandelen	\N	5
0101010.06	Omrekeningsverschillen kosten van oprichting en van uitgifte van aandelen	\N	5
0101010.07	Overige mutaties kosten van oprichting en van uitgifte van aandelen	\N	5
0101015.01	Beginbalans (overname eindsaldo vorig jaar) kosten van oprichting en van uitgifte van aandelen	\N	5
0101015.02	Investeringen kosten van oprichting en van uitgifte van aandelen	\N	5
0101015.03	Bij overname verkregen activa kosten van oprichting en van uitgifte van aandelen	\N	5
0101015.04	Desinvesteringen kosten van oprichting en van uitgifte van aandelen	\N	5
0101015.05	Afstotingen kosten van oprichting en van uitgifte van aandelen	\N	5
0101015.06	Omrekeningsverschillen kosten van oprichting en van uitgifte van aandelen	\N	5
0101015.07	Overige mutaties kosten van oprichting en van uitgifte van aandelen	\N	5
0101020.01	Beginbalans (overname eindsaldo vorig jaar) kosten van oprichting en van uitgifte van aandelen	\N	5
0101020.02	Afschrijvingen kosten van oprichting en van uitgifte van aandelen	\N	5
0101020.03	Afschrijving op desinvesteringen kosten van oprichting en van uitgifte van aandelen	\N	5
0101020.04	Bijzondere waardeverminderingen kosten van oprichting en van uitgifte van aandelen	\N	5
0101020.05	Terugneming van bijzondere waardeverminderingen kosten van oprichting en van uitgifte van aandelen	\N	5
0101030.01	Beginbalans (overname eindsaldo vorig jaar) kosten van oprichting en van uitgifte van aandelen	\N	5
0101030.02	Herwaarderingen kosten van oprichting en van uitgifte van aandelen	\N	5
0101030.03	Afschrijving herwaarderingen kosten van oprichting en van uitgifte van aandelen	\N	5
0101030.04	Desinvestering herwaarderingen kosten van oprichting en van uitgifte van aandelen	\N	5
0102010.01	Beginbalans (overname eindsaldo vorig jaar) kosten van ontwikkeling	\N	5
0102010.02	Investeringen kosten van ontwikkeling	\N	5
0102010.03	Bij overname verkregen activa kosten van ontwikkeling	\N	5
0102010.04	Desinvesteringen kosten van ontwikkeling	\N	5
0102010.05	Afstotingen kosten van ontwikkeling	\N	5
0102010.06	Omrekeningsverschillen kosten van ontwikkeling	\N	5
0102010.07	Overige mutaties kosten van ontwikkeling	\N	5
0102015.01	Beginbalans (overname eindsaldo vorig jaar) kosten van ontwikkeling	\N	5
0102015.02	Investeringen kosten van ontwikkeling	\N	5
0102015.03	Bij overname verkregen activa kosten van ontwikkeling	\N	5
0102015.04	Desinvesteringen kosten van ontwikkeling	\N	5
0102015.05	Afstotingen kosten van ontwikkeling	\N	5
0102015.06	Omrekeningsverschillen kosten van ontwikkeling	\N	5
0102015.07	Overige mutaties kosten van ontwikkeling	\N	5
0102020.01	Beginbalans (overname eindsaldo vorig jaar) kosten van ontwikkeling	\N	5
0102020.02	Afschrijvingen kosten van ontwikkeling	\N	5
0102020.03	Afschrijving op desinvesteringen kosten van ontwikkeling	\N	5
0102020.04	Bijzondere waardeverminderingen kosten van ontwikkeling	\N	5
0102020.05	Terugneming van bijzondere waardeverminderingen kosten van ontwikkeling	\N	5
0102030.01	Beginbalans (overname eindsaldo vorig jaar) kosten van ontwikkeling	\N	5
0102030.02	Herwaarderingen kosten van ontwikkeling	\N	5
0102030.03	Afschrijving herwaarderingen kosten van ontwikkeling	\N	5
0102030.04	Desinvestering herwaarderingen kosten van ontwikkeling	\N	5
0106010.01	Beginbalans (overname eindsaldo vorig jaar) concessies, vergunningen en intellectuele eigendom	\N	5
0106010.02	Investeringen concessies, vergunningen en intellectuele eigendom	\N	5
0106010.03	Bij overname verkregen activa concessies, vergunningen en intellectuele eigendom	\N	5
0106010.04	Desinvesteringen concessies, vergunningen en intellectuele eigendom	\N	5
0106010.05	Afstotingen concessies, vergunningen en intellectuele eigendom	\N	5
0106010.06	Omrekeningsverschillen concessies, vergunningen en intellectuele eigendom	\N	5
0106010.07	Overige mutaties concessies, vergunningen en intellectuele eigendom	\N	5
0106015.01	Beginbalans (overname eindsaldo vorig jaar) concessies, vergunningen en intellectuele eigendom	\N	5
0106015.02	Investeringen concessies, vergunningen en intellectuele eigendom	\N	5
0106015.03	Bij overname verkregen activa concessies, vergunningen en intellectuele eigendom	\N	5
0106015.04	Desinvesteringen concessies, vergunningen en intellectuele eigendom	\N	5
0106015.05	Afstotingen concessies, vergunningen en intellectuele eigendom	\N	5
0106015.06	Omrekeningsverschillen concessies, vergunningen en intellectuele eigendom	\N	5
0106015.07	Overige mutaties concessies, vergunningen en intellectuele eigendom	\N	5
0106020.01	Beginbalans (overname eindsaldo vorig jaar) concessies, vergunningen en intellectuele eigendom	\N	5
0106020.02	Afschrijvingen concessies, vergunningen en intellectuele eigendom	\N	5
0106020.04	Bijzondere waardeverminderingen concessies, vergunningen en intellectuele eigendom	\N	5
0106020.05	Terugneming van bijzondere waardeverminderingen concessies, vergunningen en intellectuele eigendom	\N	5
0106030.01	Beginbalans (overname eindsaldo vorig jaar) concessies, vergunningen en intellectuele eigendom	\N	5
0106030.02	Herwaarderingen concessies, vergunningen en intellectuele eigendom	\N	5
0106030.03	Afschrijving herwaarderingen concessies, vergunningen en intellectuele eigendom	\N	5
0106030.04	Desinvestering herwaarderingen concessies, vergunningen en intellectuele eigendom	\N	5
0107010.01	Beginbalans (overname eindsaldo vorig jaar) goodwill	\N	5
0107010.02	Investeringen goodwill	\N	5
0107010.03	Bij overname verkregen activa goodwill	\N	5
0107010.04	Desinvesteringen goodwill	\N	5
0107010.05	Afstotingen goodwill	\N	5
0107010.06	Omrekeningsverschillen goodwill	\N	5
0107010.07	Overige mutaties goodwill	\N	5
0107015.01	Beginbalans (overname eindsaldo vorig jaar) goodwill	\N	5
0107015.02	Investeringen goodwill	\N	5
0107015.03	Bij overname verkregen activa goodwill	\N	5
0107015.04	Desinvesteringen goodwill	\N	5
0107015.05	Afstotingen goodwill	\N	5
0107015.06	Omrekeningsverschillen goodwill	\N	5
0107015.07	Overige mutaties goodwill	\N	5
0107020.01	Beginbalans (overname eindsaldo vorig jaar) goodwill	\N	5
0107020.02	Afschrijvingen goodwill	\N	5
0107020.03	Afschrijving op desinvesteringen goodwill	\N	5
0107020.04	Bijzondere waardeverminderingen goodwill	\N	5
0107020.05	Terugneming van bijzondere waardeverminderingen goodwill	\N	5
0107020.06	Overige mutaties waardeveranderingen goodwill	\N	5
0107030.01	Beginbalans (overname eindsaldo vorig jaar) goodwill	\N	5
0107030.02	Herwaarderingen goodwill	\N	5
0107030.03	Afschrijving herwaarderingen concessies, goodwill	\N	5
0201030.06	Overige mutaties herwaarderingen terreinen	\N	5
0107030.05	Aanpassingen van de goodwill als gevolg van later geïdentificeerde activa en passiva en veranderingen in de waarde ervan	\N	5
0107030.04	Desinvestering herwaarderingen goodwill	\N	5
0109010.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op immateriële vaste activa	\N	5
0109010.02	Investeringen vooruitbetalingen op immateriële vaste activa	\N	5
0109010.03	Bij overname verkregen activa vooruitbetalingen op immateriële vaste activa	\N	5
0109010.04	Desinvesteringen vooruitbetalingen op immateriële vaste activa	\N	5
0109010.05	Afstotingen vooruitbetalingen op immateriële vaste activa	\N	5
0109010.06	Omrekeningsverschillen vooruitbetalingen op immateriële vaste activa	\N	5
0109010.07	Overige mutaties vooruitbetalingen op immateriële vaste activa	\N	5
0109015.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op immateriële vaste activa	\N	5
0109015.02	Investeringen vooruitbetalingen op immateriële vaste activa	\N	5
0109015.03	Bij overname verkregen activa vooruitbetalingen op immateriële vaste activa	\N	5
0109015.04	Desinvesteringen vooruitbetalingen op immateriële vaste activa	\N	5
0109015.05	Afstotingen vooruitbetalingen op immateriële vaste activa	\N	5
0109015.06	Omrekeningsverschillen vooruitbetalingen op immateriële vaste activa	\N	5
0109015.07	Overige mutaties vooruitbetalingen op immateriële vaste activa	\N	5
0109020.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op immateriële vaste activa	\N	5
0109020.02	Afschrijvingen vooruitbetalingen op immateriële vaste activa	\N	5
0109020.03	Afschrijving op desinvesteringen vooruitbetalingen op immateriële vaste activa	\N	5
0109020.04	Bijzondere waardeverminderingen vooruitbetalingen op immateriële vaste activa	\N	5
0109020.05	Terugneming van bijzondere waardeverminderingen vooruitbetalingen op immateriële vaste activa	\N	5
0109030.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op immateriële vaste activa	\N	5
0109030.02	Herwaarderingen vooruitbetalingen op immateriële vaste activa	\N	5
0109030.03	Afschrijving herwaarderingen vooruitbetalingen op immateriële vaste activa	\N	5
0109030.04	Desinvestering herwaarderingen vooruitbetalingen op immateriële vaste activa	\N	5
0105010.01	Beginbalans bouwclaims	\N	5
0105010.02	Investeringen bouwclaims	\N	5
0105010.03	Aankopen door overnames bouwclaims	\N	5
0105010.04	Desinvesteringen bouwclaims	\N	5
0105010.05	Desinvesteringen door afstotingen bouwclaims	\N	5
0105010.06	Omrekeningsverschillen bouwclaims	\N	5
0105010.07	Overige mutaties bouwclaims	\N	5
0105015.01	Beginbalans bouwclaims	\N	5
0105015.02	Investeringen bouwclaims	\N	5
0105015.03	Aankopen door overnames bouwclaims	\N	5
0105015.04	Desinvesteringen bouwclaims	\N	5
0105015.05	Desinvesteringen door afstotingen bouwclaims	\N	5
0105015.06	Omrekeningsverschillen bouwclaims	\N	5
0105015.07	Overige mutaties bouwclaims	\N	5
0105020.01	Beginbalans bouwclaims	\N	5
0105020.02	Afschrijvingen bouwclaims	\N	5
0105020.03	Desinvestering cumulatieve afschrijvingen en waardeverminderingen bouwclaims	\N	5
0105020.04	Waardeverminderingen bouwclaims	\N	5
0105020.05	Terugneming van waardeverminderingen bouwclaims	\N	5
0105020.06	Overige mutaties waardeveranderingen bouwclaims	\N	5
0105030.01	Beginbalans bouwclaims	\N	5
0105030.02	Herwaarderingen bouwclaims	\N	5
0105030.03	Afschrijving herwaarderingen bouwclaims	\N	5
0105030.04	Desinvestering herwaarderingen bouwclaims	\N	5
0110010.01	Beginbalans (overname eindsaldo vorig jaar) overige immateriële vaste activa	\N	5
0110010.02	Investeringen overige immateriële vaste activa	\N	5
0110010.03	Bij overname verkregen activa overige immateriële vaste activa	\N	5
0110010.04	Desinvesteringen overige immateriële vaste activa	\N	5
0110010.06	Omrekeningsverschillen overige immateriële vaste activa	\N	5
0110010.07	Overige mutaties overige immateriële vaste activa	\N	5
0110015.01	Beginbalans (overname eindsaldo vorig jaar) overige immateriële vaste activa	\N	5
0110015.02	Investeringen overige immateriële vaste activa	\N	5
0110015.03	Bij overname verkregen activa overige immateriële vaste activa	\N	5
0110015.04	Desinvesteringen overige immateriële vaste activa	\N	5
0110015.05	Afstotingen overige immateriële vaste activa	\N	5
0110015.06	Omrekeningsverschillen overige immateriële vaste activa	\N	5
0110015.07	Overige mutaties overige immateriële vaste activa	\N	5
0110020.01	Beginbalans (overname eindsaldo vorig jaar) overige immateriële vaste activa	\N	5
0110020.02	Afschrijvingen overige immateriële vaste activa	\N	5
0110020.03	Afschrijving op desinvesteringen overige immateriële vaste activa	\N	5
0110020.04	Bijzondere waardeverminderingen overige immateriële vaste activa	\N	5
0110020.05	Terugneming van bijzondere waardeverminderingen overige immateriële vaste activa	\N	5
0110020.06	Overige mutaties waardeveranderingen overige immateriële vaste activa	\N	5
0110030.01	Beginbalans (overname eindsaldo vorig jaar) overige immateriële vaste activa	\N	5
0110030.02	Herwaarderingen overige immateriële vaste activa	\N	5
0110030.03	Afschrijving herwaarderingen overige immateriële vaste activa	\N	5
0110030.04	Desinvestering herwaarderingen overige immateriële vaste activa	\N	5
0201010.01	Beginbalans (overname eindsaldo vorig jaar) terreinen	\N	5
0201010.04	Verwervingen via fusies en overnames terreinen	\N	5
0201010.05	Desinvesteringen terreinen	\N	5
0201010.06	Afstotingen terreinen	\N	5
0201010.10	Herclassificatie terreinen	\N	5
0201010.07	Omrekeningsverschillen terreinen	\N	5
0201010.08	Overboekingen terreinen	\N	5
0201010.09	Overige mutaties terreinen	\N	5
0201015.01	Beginbalans (overname eindsaldo vorig jaar) terreinen	\N	5
0201015.02	Investeringen terreinen	\N	5
0201015.04	Verwervingen via fusies en overnames terreinen	\N	5
0201015.05	Desinvesteringen terreinen	\N	5
0201015.06	Afstotingen terreinen	\N	5
0201015.07	Omrekeningsverschillen terreinen	\N	5
0201015.08	Overboekingen terreinen	\N	5
0201015.09	Overige mutaties terreinen	\N	5
0201020.01	Beginbalans (overname eindsaldo vorig jaar) terreinen	\N	5
0201020.02	Afschrijvingen terreinen	\N	5
0201020.03	Afschrijving op desinvesteringen terreinen	\N	5
0201020.04	Bijzondere waardeverminderingen terreinen	\N	5
0201020.05	Terugneming van bijzondere waardeverminderingen terreinen	\N	5
0201020.06	Herclassificatie afschrijvingen terreinen	\N	5
0201020.07	Overige mutaties afschrijvingen terreinen	\N	5
0201030.01	Beginbalans (overname eindsaldo vorig jaar) terreinen	\N	5
0201030.02	Herwaarderingen terreinen	\N	5
0201030.03	Afschrijving herwaarderingen terreinen	\N	5
0201030.04	Desinvestering herwaarderingen terreinen	\N	5
0201030.05	Herclassificatie herwaarderingen terreinen	\N	5
0202010.01	Beginbalans (overname eindsaldo vorig jaar) bedrijfsgebouwen	\N	5
0202010.04	Investeringen bedrijfsgebouwen	\N	5
0202010.05	Verwervingen via fusies en overnames bedrijfsgebouwen	\N	5
0202010.06	Desinvesteringen bedrijfsgebouwen	\N	5
0202010.07	Afstotingen bedrijfsgebouwen	\N	5
0202010.11	Herclassificatie bedrijfsgebouwen	\N	5
0202010.08	Omrekeningsverschillen bedrijfsgebouwen	\N	5
0202010.09	Overboekingen bedrijfsgebouwen	\N	5
0202010.10	Overige mutaties bedrijfsgebouwen	\N	5
0202015.01	Beginbalans (overname eindsaldo vorig jaar) bedrijfsgebouwen	\N	5
0202015.04	Investeringen bedrijfsgebouwen	\N	5
0202015.05	Verwervingen via fusies en overnames bedrijfsgebouwen	\N	5
0202015.06	Desinvesteringen bedrijfsgebouwen	\N	5
0202015.07	Afstotingen bedrijfsgebouwen	\N	5
0202015.08	Omrekeningsverschillen bedrijfsgebouwen	\N	5
0202015.09	Overboekingen bedrijfsgebouwen	\N	5
0202015.10	Overige mutaties bedrijfsgebouwen	\N	5
0202020.01	Beginbalans (overname eindsaldo vorig jaar) bedrijfsgebouwen	\N	5
0202020.02	Afschrijvingen bedrijfsgebouwen	\N	5
0202020.03	Afschrijving op desinvesteringen bedrijfsgebouwen	\N	5
0202020.04	Bijzondere waardeverminderingen bedrijfsgebouwen	\N	5
0202020.05	Terugneming van bijzondere waardeverminderingen bedrijfsgebouwen	\N	5
0202020.06	Herclassificatie afschrijvingen bedrijfsgebouwen	\N	5
0202020.07	Overige mutaties afschrijvingen bedrijfsgebouwen	\N	5
0202030.01	Beginbalans (overname eindsaldo vorig jaar) bedrijfsgebouwen	\N	5
0202030.02	Herwaarderingen bedrijfsgebouwen	\N	5
0202030.03	Afschrijving herwaarderingen bedrijfsgebouwen	\N	5
0202030.04	Desinvestering herwaarderingen bedrijfsgebouwen	\N	5
0202030.05	Herclassificatie herwaarderingen bedrijfsgebouwen	\N	5
0202030.06	Overige mutaties herwaarderingen bedrijfsgebouwen	\N	5
0203010.01	Beginbalans (overname eindsaldo vorig jaar) verbouwingen	\N	5
0203010.02	Investeringen verbouwingen	\N	5
0203010.05	Verwervingen via fusies en overnames verbouwingen	\N	5
0203010.06	Desinvesteringen verbouwingen	\N	5
0203010.07	Afstotingen verbouwingen	\N	5
0203010.11	Herclassificatie verbouwingen	\N	5
0203010.08	Omrekeningsverschillen verbouwingen	\N	5
0203010.09	Overboekingen verbouwingen	\N	5
0203010.10	Overige mutaties verbouwingen	\N	5
0203015.01	Beginbalans (overname eindsaldo vorig jaar) verbouwingen	\N	5
0203015.02	Investeringen verbouwingen	\N	5
0203015.05	Verwervingen via fusies en overnames verbouwingen	\N	5
0203015.06	Desinvesteringen verbouwingen	\N	5
0203015.08	Omrekeningsverschillen verbouwingen	\N	5
0203015.09	Overboekingen verbouwingen	\N	5
0203015.10	Overige mutaties verbouwingen	\N	5
0203020.01	Beginbalans (overname eindsaldo vorig jaar) verbouwingen	\N	5
0203020.02	Afschrijvingen verbouwingen	\N	5
0203020.03	Afschrijving op desinvesteringen verbouwingen	\N	5
0203020.04	Bijzondere waardeverminderingen verbouwingen	\N	5
0203020.05	Terugneming van bijzondere waardeverminderingen verbouwingen	\N	5
0203020.06	Herclassificatie afschrijvingen verbouwingen	\N	5
0203020.07	Overige mutaties afschrijvingen verbouwingen	\N	5
0203030.01	Beginbalans (overname eindsaldo vorig jaar) verbouwingen	\N	5
0203030.02	Herwaarderingen verbouwingen	\N	5
0203030.03	Afschrijving herwaarderingen verbouwingen	\N	5
0203030.04	Desinvestering herwaarderingen verbouwingen	\N	5
0203030.05	Herclassificatie herwaarderingen verbouwingen	\N	5
0203030.06	Overige mutaties herwaarderingen verbouwingen	\N	5
0210010.01	Beginbalans (overname eindsaldo vorig jaar) machines en installaties	\N	5
0210010.02	Investeringen machines en installaties	\N	5
0210010.05	Verwervingen via fusies en overnames machines en installaties	\N	5
0210010.06	Desinvesteringen machines en installaties	\N	5
0210010.07	Afstotingen machines en installaties	\N	5
0210010.11	Herclassificatie machines en installaties	\N	5
0210010.08	Omrekeningsverschillen machines en installaties	\N	5
0210010.09	Overboekingen machines en installaties	\N	5
0210010.10	Overige mutaties machines en installaties	\N	5
0210015.01	Beginbalans (overname eindsaldo vorig jaar) machines en installaties	\N	5
0210015.02	Investeringen machines en installaties	\N	5
0210015.05	Verwervingen via fusies en overnames machines en installaties	\N	5
0210015.06	Desinvesteringen machines en installaties	\N	5
0210015.07	Afstotingen machines en installaties	\N	5
0210015.08	Omrekeningsverschillen machines en installaties	\N	5
0210015.09	Overboekingen machines en installaties	\N	5
0210015.10	Overige mutaties machines en installaties	\N	5
0210020.01	Beginbalans (overname eindsaldo vorig jaar) machines en installaties	\N	5
0210020.02	Afschrijvingen machines en installaties	\N	5
0210020.03	Afschrijving op desinvesteringen machines en installaties	\N	5
0210020.04	Bijzondere waardeverminderingen machines en installaties	\N	5
0210020.05	Terugneming van bijzondere waardeverminderingen machines en installaties	\N	5
0210020.06	Herclassificatie afschrijvingen machines en installaties	\N	5
0210020.07	Overige mutaties afschrijvingen machines en installaties	\N	5
0210030.01	Beginbalans (overname eindsaldo vorig jaar) machines en installaties	\N	5
0210030.02	Herwaarderingen machines en installaties	\N	5
0210030.03	Afschrijving herwaarderingen machines en installaties	\N	5
0210030.04	Desinvestering herwaarderingen machines en installaties	\N	5
0210030.05	Herclassificatie herwaarderingen machines en installaties	\N	5
0210030.06	Overige mutaties herwaarderingen machines en installaties	\N	5
0214010.01	Beginbalans (overname eindsaldo vorig jaar) andere vaste bedrijfsmiddelen	\N	5
0214010.02	Investeringen andere vaste bedrijfsmiddelen	\N	5
0214010.05	Verwervingen via fusies en overnames andere vaste bedrijfsmiddelen	\N	5
0214010.06	Desinvesteringen andere vaste bedrijfsmiddelen	\N	5
0214010.07	Afstotingen andere vaste bedrijfsmiddelen	\N	5
0214010.08	Omrekeningsverschillen andere vaste bedrijfsmiddelen	\N	5
0214010.09	Overboekingen andere vaste bedrijfsmiddelen	\N	5
0214010.10	Overige mutaties andere vaste bedrijfsmiddelen	\N	5
0214015.01	Beginbalans (overname eindsaldo vorig jaar) andere vaste bedrijfsmiddelen	\N	5
0214015.02	Investeringen andere vaste bedrijfsmiddelen	\N	5
0214015.05	Verwervingen via fusies en overnames andere vaste bedrijfsmiddelen	\N	5
0214015.06	Desinvesteringen andere vaste bedrijfsmiddelen	\N	5
0214015.07	Afstotingen andere vaste bedrijfsmiddelen	\N	5
0214015.08	Omrekeningsverschillen andere vaste bedrijfsmiddelen	\N	5
0214015.09	Overboekingen andere vaste bedrijfsmiddelen	\N	5
0214015.10	Overige mutaties andere vaste bedrijfsmiddelen	\N	5
0214020.01	Beginbalans (overname eindsaldo vorig jaar) andere vaste bedrijfsmiddelen	\N	5
0214020.02	Afschrijvingen andere vaste bedrijfsmiddelen	\N	5
0214020.03	Afschrijving op desinvesteringen andere vaste bedrijfsmiddelen	\N	5
0214020.04	Bijzondere waardeverminderingen andere vaste bedrijfsmiddelen	\N	5
0214020.05	Terugneming van bijzondere waardeverminderingen andere vaste bedrijfsmiddelen	\N	5
0214020.06	Overige mutaties afschrijvingen andere vaste bedrijfsmiddelen	\N	5
0214030.01	Beginbalans (overname eindsaldo vorig jaar) andere vaste bedrijfsmiddelen	\N	5
0214030.02	Herwaarderingen andere vaste bedrijfsmiddelen	\N	5
0214030.03	Afschrijving herwaarderingen andere vaste bedrijfsmiddelen	\N	5
0214030.04	Desinvestering herwaarderingen andere vaste bedrijfsmiddelen	\N	5
0214030.05	Overige mutaties herwaarderingen andere vaste bedrijfsmiddelen	\N	5
0215010.01	Beginbalans (overname eindsaldo vorig jaar) inventaris	\N	5
0215010.02	Investeringen inventaris	\N	5
0215010.05	Verwervingen via fusies en overnames inventaris	\N	5
0215010.06	Desinvesteringen inventaris	\N	5
0215010.07	Afstotingen inventaris	\N	5
0215010.08	Omrekeningsverschillen inventaris	\N	5
0215010.09	Overboekingen inventaris	\N	5
0215010.10	Overige mutaties inventaris	\N	5
0215015.01	Beginbalans (overname eindsaldo vorig jaar) inventaris	\N	5
0215015.02	Investeringen inventaris	\N	5
0215015.05	Verwervingen via fusies en overnames inventaris	\N	5
0215015.06	Desinvesteringen inventaris	\N	5
0215015.08	Omrekeningsverschillen inventaris	\N	5
0215015.09	Overboekingen inventaris	\N	5
0215015.10	Overige mutaties inventaris	\N	5
0215020.01	Beginbalans (overname eindsaldo vorig jaar) inventaris	\N	5
0215020.02	Afschrijvingen inventaris	\N	5
0215020.03	Afschrijving op desinvesteringen inventaris	\N	5
0215020.04	Bijzondere waardeverminderingen inventaris	\N	5
0215020.05	Terugneming van bijzondere waardeverminderingen inventaris	\N	5
0215020.06	Overige mutaties afschrijvingen inventaris	\N	5
0215030.01	Beginbalans (overname eindsaldo vorig jaar) inventaris	\N	5
0215030.02	Herwaarderingen inventaris	\N	5
0215030.03	Afschrijving herwaarderingen inventaris	\N	5
0215030.04	Desinvestering herwaarderingen inventaris	\N	5
0215030.05	Overige mutaties herwaarderingen inventaris	\N	5
0213010.01	Beginbalans (overname eindsaldo vorig jaar) automobielen en overige transportmiddelen	\N	5
0213010.02	Investeringen automobielen en overige transportmiddelen	\N	5
0213010.05	Verwervingen via fusies en overnames automobielen en overige transportmiddelen	\N	5
0213010.06	Desinvesteringen automobielen en overige transportmiddelen	\N	5
0213010.07	Afstotingen automobielen en overige transportmiddelen	\N	5
0213010.08	Omrekeningsverschillen automobielen en overige transportmiddelen	\N	5
0213010.09	Overboekingen automobielen en overige transportmiddelen	\N	5
0213010.10	Overige mutaties automobielen en overige transportmiddelen	\N	5
0213015.01	Beginbalans (overname eindsaldo vorig jaar) automobielen en overige transportmiddelen	\N	5
0213015.02	Investeringen automobielen en overige transportmiddelen	\N	5
0213015.05	Verwervingen via fusies en overnames automobielen en overige transportmiddelen	\N	5
0213015.06	Desinvesteringen automobielen en overige transportmiddelen	\N	5
0213015.07	Afstotingen automobielen en overige transportmiddelen	\N	5
0213015.08	Omrekeningsverschillen automobielen en overige transportmiddelen	\N	5
0213015.09	Overboekingen automobielen en overige transportmiddelen	\N	5
0213015.10	Overige mutaties automobielen en overige transportmiddelen	\N	5
0204020.02	Afschrijvingen 	\N	5
0213020.01	Beginbalans (overname eindsaldo vorig jaar) automobielen en overige transportmiddelen	\N	5
0213020.02	Afschrijvingen automobielen en overige transportmiddelen	\N	5
0213020.03	Afschrijving op desinvesteringen automobielen en overige transportmiddelen	\N	5
0213020.04	Bijzondere waardeverminderingen automobielen en overige transportmiddelen	\N	5
0213020.05	Terugneming van bijzondere waardeverminderingen automobielen en overige transportmiddelen	\N	5
0213020.06	Overige mutaties afschrijvingen automobielen en overige transportmiddelen	\N	5
0213030.01	Beginbalans (overname eindsaldo vorig jaar) automobielen en overige transportmiddelen	\N	5
0213030.02	Herwaarderingen automobielen en overige transportmiddelen	\N	5
0213030.03	Afschrijving herwaarderingen automobielen en overige transportmiddelen	\N	5
0213030.04	Desinvestering herwaarderingen automobielen en overige transportmiddelen	\N	5
0213030.05	Overige mutaties herwaarderingen automobielen en overige transportmiddelen	\N	5
0209010.01	Beginbalans (overname eindsaldo vorig jaar) huurdersinvesteringen	\N	5
0209010.02	Investeringen huurdersinvesteringen	\N	5
0209010.05	Verwervingen via fusies en overnames huurdersinvesteringen	\N	5
0209010.06	Desinvesteringen huurdersinvesteringen	\N	5
0209010.07	Afstotingen huurdersinvesteringen	\N	5
0209010.08	Omrekeningsverschillen huurdersinvesteringen	\N	5
0209010.09	Overboekingen huurdersinvesteringen	\N	5
0209010.10	Overige mutaties huurdersinvesteringen	\N	5
0209015.01	Beginbalans (overname eindsaldo vorig jaar) huurdersinvesteringen	\N	5
0209015.02	Investeringen huurdersinvesteringen	\N	5
0209015.05	Verwervingen via fusies en overnames huurdersinvesteringen	\N	5
0209015.06	Desinvesteringen huurdersinvesteringen	\N	5
0209015.07	Afstotingen huurdersinvesteringen	\N	5
0209015.08	Omrekeningsverschillen huurdersinvesteringen	\N	5
0209015.09	Overboekingen huurdersinvesteringen	\N	5
0209015.10	Overige mutaties huurdersinvesteringen	\N	5
0209020.01	Beginbalans (overname eindsaldo vorig jaar) huurdersinvesteringen	\N	5
0209020.02	Afschrijvingen huurdersinvesteringen	\N	5
0209020.03	Afschrijving op desinvesteringen huurdersinvesteringen	\N	5
0209020.04	Bijzondere waardeverminderingen huurdersinvesteringen	\N	5
0209020.05	Terugneming van bijzondere waardeverminderingen huurdersinvesteringen	\N	5
0209020.06	Overige mutaties afschrijvingen huurdersinvesteringen	\N	5
0209030.01	Beginbalans (overname eindsaldo vorig jaar) huurdersinvesteringen	\N	5
0209030.02	Herwaarderingen huurdersinvesteringen	\N	5
0209030.03	Afschrijving herwaarderingen huurdersinvesteringen	\N	5
0209030.04	Desinvestering herwaarderingen huurdersinvesteringen	\N	5
0209030.05	Overige mutaties herwaarderingen huurdersinvesteringen	\N	5
0211010.01	Beginbalans (overname eindsaldo vorig jaar) vliegtuigen	\N	5
0211010.02	Investeringen vliegtuigen	\N	5
0211010.05	Verwervingen via fusies en overnames vliegtuigen	\N	5
0211010.06	Desinvesteringen vliegtuigen	\N	5
0211010.07	Afstotingen vliegtuigen	\N	5
0211010.08	Omrekeningsverschillen vliegtuigen	\N	5
0211010.09	Overboekingen vliegtuigen	\N	5
0211010.10	Overige mutaties vliegtuigen	\N	5
0211015.01	Beginbalans (overname eindsaldo vorig jaar) vliegtuigen	\N	5
0211015.02	Investeringen vliegtuigen	\N	5
0211015.05	Verwervingen via fusies en overnames vliegtuigen	\N	5
0211015.06	Desinvesteringen vliegtuigen	\N	5
0211015.07	Afstotingen vliegtuigen	\N	5
0211015.08	Omrekeningsverschillen vliegtuigen	\N	5
0211015.09	Overboekingen vliegtuigen	\N	5
0211015.10	Overige mutaties vliegtuigen	\N	5
0211020.01	Beginbalans (overname eindsaldo vorig jaar) vliegtuigen	\N	5
0211020.02	Afschrijvingen vliegtuigen	\N	5
0211020.03	Afschrijving op desinvesteringen vliegtuigen	\N	5
0211020.04	Bijzondere waardeverminderingen vliegtuigen	\N	5
0211020.05	Terugneming van bijzondere waardeverminderingen vliegtuigen	\N	5
0211030.01	Beginbalans (overname eindsaldo vorig jaar) vliegtuigen	\N	5
0211030.02	Herwaarderingen vliegtuigen	\N	5
0211030.03	Afschrijving herwaarderingen vliegtuigen	\N	5
0211030.04	Desinvestering herwaarderingen vliegtuigen	\N	5
0212010.01	Beginbalans (overname eindsaldo vorig jaar) schepen	\N	5
0212010.02	Investeringen schepen	\N	5
0212010.05	Verwervingen via fusies en overnames schepen	\N	5
0212010.06	Desinvesteringen schepen	\N	5
0212010.07	Afstotingen schepen	\N	5
0212010.08	Omrekeningsverschillen schepen	\N	5
0212010.09	Overboekingen schepen	\N	5
0212010.10	Overige mutaties schepen	\N	5
0212015.01	Beginbalans (overname eindsaldo vorig jaar) schepen	\N	5
0212015.02	Investeringen schepen	\N	5
0212015.05	Verwervingen via fusies en overnames schepen	\N	5
0212015.06	Desinvesteringen schepen	\N	5
0212015.07	Afstotingen schepen	\N	5
0212015.08	Omrekeningsverschillen schepen	\N	5
0212015.09	Overboekingen schepen	\N	5
0212015.10	Overige mutaties schepen	\N	5
0212020.01	Beginbalans (overname eindsaldo vorig jaar) schepen	\N	5
0212020.02	Afschrijvingen schepen	\N	5
0212020.03	Afschrijving op desinvesteringen schepen	\N	5
0212020.04	Bijzondere waardeverminderingen schepen	\N	5
0212020.05	Terugneming van bijzondere waardeverminderingen schepen	\N	5
0212030.01	Beginbalans (overname eindsaldo vorig jaar) schepen	\N	5
0212030.02	Herwaarderingen schepen	\N	5
0212030.03	Afschrijving herwaarderingen schepen	\N	5
0212030.04	Desinvestering herwaarderingen schepen	\N	5
0221010.01	Beginbalans (overname eindsaldo vorig jaar) meerjaren plantopstand	\N	5
0221010.02	Investeringen meerjaren plantopstand	\N	5
0221010.05	Verwervingen via fusies en overnames meerjaren plantopstand	\N	5
0221010.06	Desinvesteringen meerjaren plantopstand	\N	5
0221010.07	Afstotingen meerjaren plantopstand	\N	5
0221010.08	Omrekeningsverschillen meerjaren plantopstand	\N	5
0221010.09	Overboekingen meerjaren plantopstand	\N	5
0221010.10	Overige mutaties meerjaren plantopstand	\N	5
0221020.01	Beginbalans (overname eindsaldo vorig jaar) meerjaren plantopstand	\N	5
0221020.02	Afschrijvingen meerjaren plantopstand	\N	5
0221020.03	Afschrijving op desinvesteringen meerjaren plantopstand	\N	5
0221020.04	Bijzondere waardeverminderingen meerjaren plantopstand	\N	5
0221020.05	Terugneming van bijzondere waardeverminderingen meerjaren plantopstand	\N	5
0221030.01	Beginbalans (overname eindsaldo vorig jaar) meerjaren plantopstand	\N	5
0221030.02	Herwaarderingen meerjaren plantopstand	\N	5
0221030.03	Afschrijving herwaarderingen meerjaren plantopstand	\N	5
0221030.04	Desinvestering herwaarderingen meerjaren plantopstand	\N	5
0222010.01	Beginbalans (overname eindsaldo vorig jaar) gebruiksvee	\N	5
0222010.02	Investeringen gebruiksvee	\N	5
0222010.05	Verwervingen via fusies en overnames gebruiksvee	\N	5
0222010.06	Desinvesteringen gebruiksvee	\N	5
0222010.07	Afstotingen gebruiksvee	\N	5
0222010.08	Omrekeningsverschillen gebruiksvee	\N	5
0222010.09	Overboekingen gebruiksvee	\N	5
0222010.10	Overige mutaties gebruiksvee	\N	5
0222020.01	Beginbalans (overname eindsaldo vorig jaar) gebruiksvee	\N	5
0222020.02	Afschrijvingen gebruiksvee	\N	5
0222020.03	Afschrijving op desinvesteringen gebruiksvee	\N	5
0222020.04	Bijzondere waardeverminderingen gebruiksvee	\N	5
0222020.05	Terugneming van bijzondere waardeverminderingen gebruiksvee	\N	5
0222030.01	Beginbalans (overname eindsaldo vorig jaar) gebruiksvee	\N	5
0222030.02	Herwaarderingen gebruiksvee	\N	5
0222030.03	Afschrijving herwaarderingen gebruiksvee	\N	5
0222030.04	Desinvestering herwaarderingen gebruiksvee	\N	5
0216010.01	Beginbalans (overname eindsaldo vorig jaar) vaste bedrijfsmiddelen in uitvoering	\N	5
0216010.02	Investeringen vaste bedrijfsmiddelen in uitvoering	\N	5
0216010.05	Verwervingen via fusies en overnames vaste bedrijfsmiddelen in uitvoering	\N	5
0216010.06	Desinvesteringen vaste bedrijfsmiddelen in uitvoering	\N	5
0216010.07	Afstotingen vaste bedrijfsmiddelen in uitvoering	\N	5
0216010.08	Omrekeningsverschillen vaste bedrijfsmiddelen in uitvoering	\N	5
0216010.09	Overboekingen vaste bedrijfsmiddelen in uitvoering	\N	5
0216010.10	Overige mutaties vaste bedrijfsmiddelen in uitvoering	\N	5
0216015.01	Beginbalans (overname eindsaldo vorig jaar) vaste bedrijfsmiddelen in uitvoering	\N	5
0216015.02	Investeringen vaste bedrijfsmiddelen in uitvoering	\N	5
0216015.05	Verwervingen via fusies en overnames vaste bedrijfsmiddelen in uitvoering	\N	5
0216015.06	Desinvesteringen vaste bedrijfsmiddelen in uitvoering	\N	5
0216015.07	Afstotingen vaste bedrijfsmiddelen in uitvoering	\N	5
0216015.08	Omrekeningsverschillen vaste bedrijfsmiddelen in uitvoering	\N	5
0216015.09	Overboekingen vaste bedrijfsmiddelen in uitvoering	\N	5
0216015.10	Overige mutaties vaste bedrijfsmiddelen in uitvoering	\N	5
0216020.01	Beginbalans (overname eindsaldo vorig jaar) vaste bedrijfsmiddelen in uitvoering	\N	5
0216020.02	Afschrijvingen vaste bedrijfsmiddelen in uitvoering	\N	5
0216020.03	Afschrijving op desinvesteringen vaste bedrijfsmiddelen in uitvoering	\N	5
0216020.04	Bijzondere waardeverminderingen vaste bedrijfsmiddelen in uitvoering	\N	5
0216020.05	Terugneming van bijzondere waardeverminderingen vaste bedrijfsmiddelen in uitvoering	\N	5
0216030.01	Beginbalans (overname eindsaldo vorig jaar) vaste bedrijfsmiddelen in uitvoering	\N	5
0216030.02	Herwaarderingen vaste bedrijfsmiddelen in uitvoering	\N	5
0216030.03	Afschrijving herwaarderingen vaste bedrijfsmiddelen in uitvoering	\N	5
0216030.04	Desinvestering herwaarderingen vaste bedrijfsmiddelen in uitvoering	\N	5
0216110.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op materiële vaste activa	\N	5
0216110.02	Investeringen vooruitbetalingen op materiële vaste activa	\N	5
0216110.05	Verwervingen via fusies en overnames vooruitbetalingen op materiële vaste activa	\N	5
0216110.06	Desinvesteringen vooruitbetalingen op materiële vaste activa	\N	5
0216110.07	Afstotingen vooruitbetalingen op materiële vaste activa	\N	5
0216110.08	Omrekeningsverschillen vooruitbetalingen op materiële vaste activa	\N	5
0216110.09	Overboekingen vooruitbetalingen op materiële vaste activa	\N	5
0216110.10	Overige mutaties vooruitbetalingen op materiële vaste activa	\N	5
0216115.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op materiële vaste activa	\N	5
0216115.02	Investeringen vooruitbetalingen op materiële vaste activa	\N	5
0216115.05	Verwervingen via fusies en overnames vooruitbetalingen op materiële vaste activa	\N	5
0216115.06	Desinvesteringen vooruitbetalingen op materiële vaste activa	\N	5
0216115.07	Afstotingen vooruitbetalingen op materiële vaste activa	\N	5
0216115.08	Omrekeningsverschillen vooruitbetalingen op materiële vaste activa	\N	5
0216115.09	Overboekingen vooruitbetalingen op materiële vaste activa	\N	5
0216115.10	Overige mutaties vooruitbetalingen op materiële vaste activa	\N	5
0216120.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op materiële vaste activa	\N	5
0216120.02	Afschrijvingen vooruitbetalingen op materiële vaste activa	\N	5
0216120.03	Afschrijving op desinvesteringen vooruitbetalingen op materiële vaste activa	\N	5
0216120.04	Bijzondere waardeverminderingen vooruitbetalingen op materiële vaste activa	\N	5
0216120.05	Terugneming van bijzondere waardeverminderingen vooruitbetalingen op materiële vaste activa	\N	5
0216130.01	Beginbalans (overname eindsaldo vorig jaar) vooruitbetalingen op materiële vaste activa	\N	5
0216130.02	Herwaarderingen vooruitbetalingen op materiële vaste activa	\N	5
0216130.03	Afschrijving herwaarderingen vooruitbetalingen op materiële vaste activa	\N	5
0216130.04	Desinvestering herwaarderingen vooruitbetalingen op materiële vaste activa	\N	5
0217010.01	Beginbalans (overname eindsaldo vorig jaar) niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217010.02	Investeringen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217010.05	Verwervingen via fusies en overnames niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217010.06	Desinvesteringen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217010.07	Afstotingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217010.08	Omrekeningsverschillen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217010.09	Overboekingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217010.10	Overige mutaties niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217015.01	Beginbalans (overname eindsaldo vorig jaar) niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217015.02	Investeringen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217015.05	Verwervingen via fusies en overnames niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217015.06	Desinvesteringen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217015.07	Afstotingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217015.08	Omrekeningsverschillen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217015.09	Overboekingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217015.10	Overige mutaties niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217020.01	Beginbalans (overname eindsaldo vorig jaar) niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217020.02	Afschrijvingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217020.03	Afschrijving op desinvesteringen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217020.04	Bijzondere waardeverminderingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217020.05	Terugneming van bijzondere waardeverminderingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217030.01	Beginbalans (overname eindsaldo vorig jaar) niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217030.02	Herwaarderingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0217030.03	Afschrijving herwaarderingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0204020.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0217030.04	Desinvestering herwaarderingen niet aan de bedrijfsuitoefening dienstbare materiële vaste activa	\N	5
0218010.01	Beginbalans (overname eindsaldo vorig jaar)  ten dienste van de exploitatie	\N	5
0218010.02	Investeringen  ten dienste van de exploitatie	\N	5
0218010.05	Verwervingen via fusies en overnames  ten dienste van de exploitatie	\N	5
0218010.06	Desinvesteringen  ten dienste van de exploitatie	\N	5
0218010.07	Afstotingen  ten dienste van de exploitatie	\N	5
0218010.11	Herclassificatie  ten dienste van de exploitatie	\N	5
0218010.08	Omrekeningsverschillen  ten dienste van de exploitatie	\N	5
0218010.09	Overboekingen  ten dienste van de exploitatie	\N	5
0218010.10	Overige mutaties  ten dienste van de exploitatie	\N	5
0218015.01	Beginbalans (overname eindsaldo vorig jaar)  ten dienste van de exploitatie	\N	5
0218015.02	Investeringen  ten dienste van de exploitatie	\N	5
0218015.05	Verwervingen via fusies en overnames  ten dienste van de exploitatie	\N	5
0218015.06	Desinvesteringen  ten dienste van de exploitatie	\N	5
0218015.07	Afstotingen  ten dienste van de exploitatie	\N	5
0218015.08	Omrekeningsverschillen  ten dienste van de exploitatie	\N	5
0218015.09	Overboekingen  ten dienste van de exploitatie	\N	5
0218015.10	Overige mutaties  ten dienste van de exploitatie	\N	5
0218020.01	Beginbalans (overname eindsaldo vorig jaar)  ten dienste van de exploitatie	\N	5
0218020.02	Afschrijvingen niet aan de bedrijfsuitoefening  ten dienste van de exploitatie	\N	5
0218020.03	Afschrijving op desinvesteringen  ten dienste van de exploitatie	\N	5
0218020.04	Bijzondere waardeverminderingen  ten dienste van de exploitatie	\N	5
0218020.05	Terugneming van bijzondere waardeverminderingen  ten dienste van de exploitatie	\N	5
0218020.06	Overige mutaties afschrijvingen  ten dienste van de exploitatie	\N	5
0218030.01	Beginbalans (overname eindsaldo vorig jaar)  ten dienste van de exploitatie	\N	5
0218030.02	Herwaarderingen  ten dienste van de exploitatie	\N	5
0218030.03	Afschrijving herwaarderingen  ten dienste van de exploitatie	\N	5
0218030.04	Desinvestering herwaarderingen  ten dienste van de exploitatie	\N	5
0218030.05	Overige mutaties herwaarderingen  ten dienste van de exploitatie	\N	5
0204010.01	Beginbalans (overname eindsaldo vorig jaar) vastgoedbeleggingen in ontwikkeling	\N	5
0204010.02	Initiële verkrijgingen 	\N	5
0204010.03	Investeringen	\N	5
0204010.04	Inbreng vanuit vastgoed in exploitatie	\N	5
0204010.15	Oplevering naar vastgoed in exploitatie	\N	5
0204010.11	Uitgaven na eerste waardering 	\N	5
0204010.05	Investeringen door overnames 	\N	5
0204010.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	\N	5
0204010.06	Desinvesteringen 	\N	5
0204010.13	Afstotingen	\N	5
0204010.08	Omrekeningsverschillen 	\N	5
0204010.09	Overboekingen 	\N	5
0204010.10	Overige mutaties 	\N	5
0204015.01	Beginbalans (overname eindsaldo vorig jaar) vastgoedbeleggingen in ontwikkeling	\N	5
0204015.02	Initiële verkrijgingen 	\N	5
0204015.11	Uitgaven na eerste waardering 	\N	5
0204015.05	Investeringen door overnames 	\N	5
0204015.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	\N	5
0204015.06	Desinvesteringen 	\N	5
0204015.13	Afstotingen	\N	5
0204015.08	Omrekeningsverschillen 	\N	5
0204015.09	Overboekingen 	\N	5
0204015.10	Overige mutaties 	\N	5
0204020.03	Afschrijving op desinvesteringen 	\N	5
0204020.09	Overboeking investeringen naar voorziening (onttrekking)	\N	5
0204020.10	Oplevering naar vastgoed in exploitatie	\N	5
0204020.04	Bijzondere waardeverminderingen 	\N	5
0204020.05	Terugneming van bijzondere waardeverminderingen 	\N	5
0204020.06	Overboeking van waardevermindering	\N	5
0204020.07	Desinvestering van waardevermindering	\N	5
0204020.08	Overige mutaties waardevermindering	\N	5
0204030.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0204030.02	Resultaat als gevolg van aanpassingen van de reële waarde 	\N	5
0204030.03	Herwaarderingen commercieel vastgoed in exploitatie	\N	5
0204030.04	Desinvestering herwaarderingen	\N	5
0204030.05	Effecten stelselwijziging	\N	5
0205010.01	Beginbalans (overname eindsaldo vorig jaar) vastgoedbeleggingen in exploitatie	\N	5
0205010.02	Initiële verkrijgingen 	\N	5
0205010.15	Overboekingen van vastgoed in ontwikkeling	\N	5
0205010.11	Uitgaven na eerste waardering 	\N	5
0205010.05	Investeringen door overnames 	\N	5
0205010.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	\N	5
0205010.16	Overboekingen naar vastgoed in ontwikkeling bestemd voor eigen exploitaties	\N	5
0205010.17	Overboekingen van en naar voorraden en vastgoed voor eigen gebruik	\N	5
0205010.06	Desinvesteringen 	\N	5
0205010.13	Afstotingen	\N	5
0205010.08	Omrekeningsverschillen 	\N	5
0205010.09	Overboekingen 	\N	5
0205010.10	Overige mutaties 	\N	5
0205010.14	Herclassificaties naar vastgoed Niet Daeb	\N	5
0205010.18	Herclassificaties van vastgoed Niet Daeb	\N	5
0205015.01	Beginbalans (overname eindsaldo vorig jaar) vastgoedbeleggingen in exploitatie	\N	5
0205015.02	Initiële verkrijgingen 	\N	5
0205015.11	Uitgaven na eerste waardering 	\N	5
0205015.05	Investeringen door overnames 	\N	5
0205015.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	\N	5
0205015.06	Desinvesteringen 	\N	5
0205015.13	Afstotingen	\N	5
0205015.08	Omrekeningsverschillen 	\N	5
0205015.09	Overboekingen 	\N	5
0205015.10	Overige mutaties 	\N	5
0205015.14	Herclassificaties van en naar vastgoed Niet Daeb	\N	5
0205020.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0205020.02	Afschrijvingen 	\N	5
0205020.03	Afschrijving op desinvesteringen 	\N	5
0205020.04	Bijzondere waardeverminderingen 	\N	5
0205020.05	Terugneming van bijzondere waardeverminderingen 	\N	5
0205020.06	Desinvesteringen bijzondere waardeverminderingen	\N	5
0205020.07	Herclassificatie bijzondere waardevermindering en afschrijving	\N	5
0205030.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0205030.02	Resultaat als gevolg van aanpassingen van de reële waarde 	\N	5
0205030.03	Herwaarderingen sociaal vastgoed in exploitatie	\N	5
0205030.07	Overboekingen van vastgoed ontwikkeling herwaardering	\N	5
0205030.04	Desinvestering herwaarderingen	\N	5
0205030.05	Herclassificatie herwaarderingen	\N	5
0205030.08	Herclassificatie herwaarderingen van en naar vastgoed verkocht onder voorwaarden	\N	5
0205030.09	Overboekingen naar vastgoed in ontwikkeling bestemd voor eigen exploitatie	\N	5
0205030.10	Overboekingen van en naar voorraden en vastgoed voor eigen gebruik	\N	5
0205030.11	Herclassificatie herwaarderingen van vastgoed Niet Daeb	\N	5
0205030.12	Herclassificatie herwaarderingen naar vastgoed Niet Daeb	\N	5
0205030.13	Overige mutaties	\N	5
0205030.06	Effecten stelselwijziging	\N	5
0206010.01	Beginbalans commercieel vastgoed in exploitatie	\N	5
0206010.02	Initiële verkrijgingen 	\N	5
0206010.11	Uitgaven na eerste waardering 	\N	5
0206010.15	Overboekingen van vastgoed ontwikkeling niet-Daeb	\N	5
0206010.05	Aankopen door overnames commercieel vastgoed in exploitatie	\N	5
0206010.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	\N	5
0206010.16	Overboekingen naar vastgoed ontwikkeling bestemd voor eigen exploitatie	\N	5
0206010.17	Overboekingen van en naar voorraden en vastgoed voor eigen gebruik	\N	5
0206010.18	Herclassificaties van vastgoed Daeb	\N	5
0206010.06	Desinvesteringen commercieel vastgoed in exploitatie	\N	5
0206010.13	Afstotingen	\N	5
0206010.08	Omrekeningsverschillen commercieel vastgoed in exploitatie	\N	5
0206010.09	Overboekingen commercieel vastgoed in exploitatie	\N	5
0206010.10	Overige mutaties commercieel vastgoed in exploitatie	\N	5
0206010.14	Herclassificaties naar vastgoed Daeb	\N	5
0206015.01	Beginbalans commercieel vastgoed in exploitatie	\N	5
0206015.02	Initiële verkrijgingen 	\N	5
0206015.11	Uitgaven na eerste waardering 	\N	5
0206015.05	Aankopen door overnames commercieel vastgoed in exploitatie	\N	5
0206015.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	\N	5
0206015.06	Desinvesteringen commercieel vastgoed in exploitatie	\N	5
0206015.13	Afstotingen	\N	5
0206015.08	Omrekeningsverschillen commercieel vastgoed in exploitatie	\N	5
0206015.09	Overboekingen commercieel vastgoed in exploitatie	\N	5
0206015.10	Overige mutaties commercieel vastgoed in exploitatie	\N	5
0206015.14	Herclassificaties van en naar vastgoed Daeb	\N	5
0206020.01	Beginbalans commercieel vastgoed in exploitatie	\N	5
0206020.02	Afschrijvingen commercieel vastgoed in exploitatie	\N	5
0206020.03	Desinvestering cumulatieve afschrijvingen en waardeverminderingen commercieel vastgoed in exploitatie	\N	5
0206020.04	Waardeverminderingen commercieel vastgoed in exploitatie	\N	5
0206020.05	Terugneming van waardeverminderingen commercieel vastgoed in exploitatie	\N	5
0206020.06	Desinvesteringen bijzondere waardeverminderingen	\N	5
0206020.07	Herclassificatie bijzondere waardevermindering en afschrijving	\N	5
0206030.01	Beginbalans commercieel vastgoed in exploitatie	\N	5
0206030.02	Resultaat als gevolg van aanpassingen van de reële waarde 	\N	5
0206030.03	Herwaarderingen commercieel vastgoed in exploitatie	\N	5
0206030.07	Overboekingen van vastgoed ontwikkeling herwaardering	\N	5
0206030.04	Desinvestering herwaarderingen	\N	5
0206030.05	Herclassificatie herwaarderingen	\N	5
0206030.08	Herclassificatie herwaarderingen van en naar vastgoed verkocht onder voorwaarden niet-Daeb	\N	5
0206030.09	Overboekingen naar vastgoed in ontwikkeling bestemd voor eigen exploitatie niet-Daeb	\N	5
0206030.10	Overboekingen van en naar voorraden en vastgoed voor eigen gebruik niet-Daeb	\N	5
0206030.11	Herclassificatie herwaarderingen van vastgoed Daeb	\N	5
0206030.12	Herclassificatie herwaarderingen naar vastgoed Daeb	\N	5
0206030.13	Overige mutaties niet-Daeb	\N	5
0206030.06	Effecten stelselwijziging	\N	5
0207010.01	Beginbalans onroerende zaken verkocht onder voorwaarden	\N	5
0207010.02	Investeringen nieuw aangeschaft onroerende zaken verkocht onder voorwaarden	\N	5
0207010.11	Uitgaven na eerste waardering 	\N	5
0207010.05	Aankopen door overnames onroerende zaken verkocht onder voorwaarden	\N	5
0207010.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	\N	5
0207010.06	Desinvesteringen onroerende zaken verkocht onder voorwaarden	\N	5
0207010.13	Afstotingen	\N	5
0207010.08	Omrekeningsverschillen onroerende zaken verkocht onder voorwaarden	\N	5
0309024.12	Overige mutaties vorderingen op lid 2	\N	5
0207010.09	Overboekingen onroerende zaken verkocht onder voorwaarden	\N	5
0207010.10	Overige mutaties onroerende zaken verkocht onder voorwaarden	\N	5
0207015.01	Beginbalans onroerende zaken verkocht onder voorwaarden	\N	5
0207015.02	Investeringen nieuw aangeschaft onroerende zaken verkocht onder voorwaarden	\N	5
0207015.11	Uitgaven na eerste waardering 	\N	5
0207015.05	Aankopen door overnames onroerende zaken verkocht onder voorwaarden	\N	5
0207015.12	Herclassificaties van en naar vastgoed verkocht onder voorwaarden	\N	5
0207015.06	Desinvesteringen onroerende zaken verkocht onder voorwaarden	\N	5
0207015.13	Afstotingen	\N	5
0207015.08	Omrekeningsverschillen onroerende zaken verkocht onder voorwaarden	\N	5
0207015.09	Overboekingen onroerende zaken verkocht onder voorwaarden	\N	5
0207015.10	Overige mutaties onroerende zaken verkocht onder voorwaarden	\N	5
0207020.01	Beginbalans onroerende zaken verkocht onder voorwaarden	\N	5
0207020.02	Afschrijvingen onroerende zaken verkocht onder voorwaarden	\N	5
0207020.03	Desinvestering cumulatieve afschrijvingen en waardeverminderingen onroerende zaken verkocht onder voorwaarden	\N	5
0207020.04	Waardeverminderingen onroerende zaken verkocht onder voorwaarden	\N	5
0207020.05	Terugneming van waardeverminderingen onroerende zaken verkocht onder voorwaarden	\N	5
0207030.01	Beginbalans onroerende zaken verkocht onder voorwaarden	\N	5
0207030.02	Resultaat als gevolg van aanpassingen van de reële waarde 	\N	5
0207030.03	Herwaarderingen onroerende zaken verkocht onder voorwaarden	\N	5
0207030.04	Desinvestering herwaarderingen	\N	5
0207030.05	Herclassificatie herwaarderingen	\N	5
0207030.06	Effecten stelselwijziging	\N	5
0301010.01	Beginbalans (overname eindsaldo vorig jaar) deelnemingen in groepsmaatschappijen	\N	5
0301010.02	Investeringen deelnemingen in groepsmaatschappijen	\N	5
0301010.03	Bij overname verkregen activa deelnemingen in groepsmaatschappijen	\N	5
0301010.04	Desinvesteringen deelnemingen in groepsmaatschappijen	\N	5
0301010.05	Afstotingen deelnemingen in groepsmaatschappijen	\N	5
0301010.09	Omrekeningsverschillen deelnemingen in groepsmaatschappijen	\N	5
0301010.10	Overige mutaties deelnemingen in groepsmaatschappijen	\N	5
0301020.01	Beginbalans (overname eindsaldo vorig jaar) deelnemingen in groepsmaatschappijen	\N	5
0301020.02	Afschrijvingen deelnemingen in groepsmaatschappijen	\N	5
0301020.03	Afschrijving op desinvesteringen deelnemingen in groepsmaatschappijen	\N	5
0301020.04	Bijzondere waardeverminderingen deelnemingen in groepsmaatschappijen	\N	5
0301020.05	Terugneming van bijzondere waardeverminderingen deelnemingen in groepsmaatschappijen	\N	5
0301030.01	Beginbalans (overname eindsaldo vorig jaar) deelnemingen in groepsmaatschappijen	\N	5
0301030.02	Herwaarderingen deelnemingen in groepsmaatschappijen	\N	5
0301030.05	Aandeel in resultaat deelnemingen deelnemingen in groepsmaatschappijen	\N	5
0301030.06	Dividend van deelnemingen deelnemingen in groepsmaatschappijen	\N	5
0301030.07	Afschrijving herwaardering	\N	5
0301030.09	Overige mutaties waardeveranderingen	\N	5
0301030.08	Desinvestering herwaardering	\N	5
0302020.01	Beginbalans (overname eindsaldo vorig jaar) deelnemingen in overige verbonden maatschappijen	\N	5
0302020.02	Investeringen deelnemingen in overige verbonden maatschappijen	\N	5
0302020.03	Bij overname verkregen activa deelnemingen in overige verbonden maatschappijen	\N	5
0302020.04	Desinvesteringen deelnemingen in overige verbonden maatschappijen	\N	5
0302020.05	Afstotingen deelnemingen in overige verbonden maatschappijen	\N	5
0309024.13	Overige mutaties vorderingen op lid 3	\N	5
0302020.09	Omrekeningsverschillen deelnemingen in overige verbonden maatschappijen	\N	5
0302020.10	Overige mutaties deelnemingen in overige verbonden maatschappijen	\N	5
0302030.01	Beginbalans (overname eindsaldo vorig jaar) deelnemingen in overige verbonden maatschappijen	\N	5
0302030.02	Afschrijvingen deelnemingen in overige verbonden maatschappijen	\N	5
0302030.03	Afschrijving op desinvesteringen deelnemingen in overige verbonden maatschappijen	\N	5
0302030.04	Bijzondere waardeverminderingen deelnemingen in overige verbonden maatschappijen	\N	5
0302030.05	Terugneming van bijzondere waardeverminderingen deelnemingen in overige verbonden maatschappijen	\N	5
0302040.01	Beginbalans (overname eindsaldo vorig jaar) deelnemingen in overige verbonden maatschappijen	\N	5
0302040.02	Herwaarderingen deelnemingen in overige verbonden maatschappijen	\N	5
0302040.05	Aandeel in resultaat deelnemingen deelnemingen in overige verbonden maatschappijen	\N	5
0302040.06	Dividend van deelnemingen deelnemingen in overige verbonden maatschappijen	\N	5
0305010.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op groepsmaatschappijen	\N	5
0305010.02	Investeringen vorderingen op groepsmaatschappijen	\N	5
0305010.15	Betalingen / aflossingen	\N	5
0305010.03	Aflossingen vorderingen op groepsmaatschappijen (langlopend)	\N	5
0305010.13	Rente vorderingen op groepsmaatschappijen (langlopend)	\N	5
0305010.04	Bij overname verkregen activa vorderingen op groepsmaatschappijen	\N	5
0305010.11	Desinvesteringen vorderingen op groepsmaatschappijen	\N	5
0305010.12	Afstotingen vorderingen op groepsmaatschappijen	\N	5
0305010.08	Omrekeningsverschillen vorderingen op groepsmaatschappijen	\N	5
0305010.10	Overige mutaties vorderingen op groepsmaatschappijen	\N	5
0305020.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op groepsmaatschappijen	\N	5
0305020.02	Kortlopend deel vorderingen op groepsmaatschappijen (langlopend)	\N	5
0305020.03	Afschrijvingen vorderingen op groepsmaatschappijen	\N	5
0305020.04	Afschrijving op desinvesteringen vorderingen op groepsmaatschappijen	\N	5
0305020.05	Bijzondere waardeverminderingen vorderingen op groepsmaatschappijen	\N	5
0305020.06	Terugneming van bijzondere waardeverminderingen vorderingen op groepsmaatschappijen	\N	5
0305030.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op groepsmaatschappijen	\N	5
0305030.02	Herwaarderingen vorderingen op groepsmaatschappijen	\N	5
0305030.05	Aandeel in resultaat deelnemingen vorderingen op groepsmaatschappijen	\N	5
0305030.06	Dividend van deelnemingen vorderingen op groepsmaatschappijen	\N	5
0305030.07	Afschrijving herwaardering vorderingen op groepsmaatschappijen	\N	5
0305030.09	Overige mutaties waardeveranderingen vorderingen op groepsmaatschappijen	\N	5
0305030.08	Desinvestering herwaardering vorderingen op groepsmaatschappijen	\N	5
0307010.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op overige verbonden maatschappijen	\N	5
0307010.02	Investeringen vorderingen op overige verbonden maatschappijen	\N	5
0307010.14	Stortingen / ontvangen op overige verbonden maatschappijen 	\N	5
0307010.15	Betalingen / aflossingen op overige verbonden maatschappijen	\N	5
0307010.03	Aflossingen vorderingen op overige verbonden maatschappijen (langlopend)	\N	5
0307010.04	Bij overname verkregen activa vorderingen op overige verbonden maatschappijen	\N	5
0307010.11	Desinvesteringen vorderingen op overige verbonden maatschappijen	\N	5
0307010.12	Afstotingen vorderingen op overige verbonden maatschappijen	\N	5
0307010.08	Omrekeningsverschillen vorderingen op overige verbonden maatschappijen	\N	5
0307010.10	Overige mutaties vorderingen op overige verbonden maatschappijen	\N	5
0309024.14	Overige mutaties vorderingen op lid 4	\N	5
0307020.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op overige verbonden maatschappijen	\N	5
0307020.02	Kortlopend deel vorderingen op overige verbonden maatschappijen (langlopend)	\N	5
0307020.03	Afschrijvingen vorderingen op overige verbonden maatschappijen	\N	5
0307020.04	Afschrijving op desinvesteringen vorderingen op overige verbonden maatschappijen	\N	5
0307020.05	Bijzondere waardeverminderingen vorderingen op overige verbonden maatschappijen	\N	5
0307020.06	Terugneming van bijzondere waardeverminderingen vorderingen op overige verbonden maatschappijen	\N	5
0307030.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op overige verbonden maatschappijen	\N	5
0307030.02	Herwaarderingen vorderingen op overige verbonden maatschappijen	\N	5
0307030.05	Aandeel in resultaat deelnemingen vorderingen op overige verbonden maatschappijen	\N	5
0307030.06	Dividend van deelnemingen vorderingen op overige verbonden maatschappijen	\N	5
0303010.01	Beginbalans (overname eindsaldo vorig jaar) overige deelnemingen	\N	5
0303010.02	Investeringen overige deelnemingen	\N	5
0303010.03	Bij overname verkregen activa overige deelnemingen	\N	5
0303010.06	Aflossingen andere deelnemingen	\N	5
0303010.09	Rente andere deelnemingen	\N	5
0303010.04	Desinvesteringen overige deelnemingen	\N	5
0303010.05	Afstotingen overige deelnemingen	\N	5
0303010.07	Omrekeningsverschillen overige deelnemingen	\N	5
0303010.08	Overige mutaties overige deelnemingen	\N	5
0303020.01	Beginbalans (overname eindsaldo vorig jaar) overige deelnemingen	\N	5
0303020.02	Afschrijvingen overige deelnemingen	\N	5
0303020.03	Afschrijving op desinvesteringen overige deelnemingen	\N	5
0303020.04	Bijzondere waardeverminderingen overige deelnemingen	\N	5
0303020.05	Terugneming van bijzondere waardeverminderingen overige deelnemingen	\N	5
0303030.01	Beginbalans (overname eindsaldo vorig jaar) overige deelnemingen	\N	5
0303030.02	Herwaarderingen andere deelnemingen	\N	5
0303030.05	Aandeel in resultaat deelnemingen overige deelnemingen	\N	5
0303030.06	Dividend van deelnemingen overige deelnemingen	\N	5
0303030.07	Afschrijving herwaardering overige deelnemingen	\N	5
0303030.09	Overige mutaties waardeveranderingen overige deelnemingen	\N	5
0303030.08	Desinvestering herwaardering overige deelnemingen	\N	5
0306010.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306010.02	Investeringen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306010.14	Stortingen / ontvangen  vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306010.15	Betalingen / aflossingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306010.03	Aflossingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen (langlopend)	\N	5
0306010.13	Rente vorderingen op participnaten en op maatschappijen waarin wordt deelgenomen	\N	5
0306010.04	Bij overname verkregen activa vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306010.11	Desinvesteringen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306010.12	Afstotingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306010.08	Omrekeningsverschillen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306010.10	Overige mutaties vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306020.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306010.09	Kortlopend deel vorderingen op participanten en op maatschappijen waarin wordt deelgenomen (langlopend)	\N	5
0306020.03	Afschrijvingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306020.04	Afschrijving op desinvesteringen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306010.05	Bijzondere waardeverminderingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306010.06	Terugneming van bijzondere waardeverminderingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306030.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306030.02	Herwaarderingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306030.05	Aandeel in resultaat deelnemingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306030.06	Dividend van deelnemingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306030.07	Afschrijving herwaardering vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306030.09	Overige mutaties waardeveranderingen vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0306030.08	Desinvestering herwaardering vorderingen op participanten en op maatschappijen waarin wordt deelgenomen	\N	5
0304010.01	Beginbalans (overname eindsaldo vorig jaar) overige effecten (langlopend)	\N	5
0304010.02	Investeringen overige effecten (langlopend)	\N	5
0304010.08	Bij overname verkregen activa overige effecten (langlopend)	\N	5
0304010.04	Desinvesteringen overige effecten (langlopend)	\N	5
0304010.05	Waardestijgingen overige effecten (langlopend)	\N	5
0304010.09	Afstotingen overige effecten (langlopend)	\N	5
0304010.06	Omrekeningsverschillen overige effecten (langlopend)	\N	5
0304010.07	Overige mutaties overige effecten (langlopend)	\N	5
0304020.01	Beginbalans (overname eindsaldo vorig jaar) overige effecten (langlopend)	\N	5
0304020.04	Afschrijvingen overige effecten (langlopend)	\N	5
0304020.05	Afschrijving op desinvesteringen overige effecten (langlopend)	\N	5
0304020.02	Bijzondere waardeverminderingen overige effecten (langlopend)	\N	5
0304020.03	Terugneming van bijzondere waardeverminderingen overige effecten (langlopend)	\N	5
0304030.01	Beginbalans (overname eindsaldo vorig jaar) overige effecten (langlopend)	\N	5
0304030.02	Herwaarderingen overige effecten (langlopend)	\N	5
0304030.07	Desinvestering herwaardering overige effecten (langlopend)	\N	5
0304030.08	Overige mutaties waardeveranderingen overige effecten (langlopend)	\N	5
0304030.05	Aandeel in resultaat deelnemingen overige effecten (langlopend)	\N	5
0304030.06	Dividend van deelnemingen overige effecten (langlopend)	\N	5
0309020.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op bestuurders 1 (langlopend)	\N	5
0309020.02	Beginbalans (overname eindsaldo vorig jaar) vorderingen op bestuurders 2 (langlopend)	\N	5
0309020.03	Beginbalans (overname eindsaldo vorig jaar) vorderingen op bestuurders 3 (langlopend)	\N	5
0309020.04	Beginbalans (overname eindsaldo vorig jaar) vorderingen op bestuurders 4 (langlopend)	\N	5
0309020.05	Beginbalans (overname eindsaldo vorig jaar) vorderingen op bestuurders 5 (langlopend)	\N	5
0309020.06	Toename leningen, voorschotten en garanties van bestuurders 1 (langlopend)	\N	5
0309020.07	Toename leningen, voorschotten en garanties van bestuurders 2 (langlopend)	\N	5
0309020.08	Toename leningen, voorschotten en garanties van bestuurders 3 (langlopend)	\N	5
0309020.09	Toename leningen, voorschotten en garanties van bestuurders 4 (langlopend)	\N	5
0309020.10	Toename leningen, voorschotten en garanties van bestuurders 5 (langlopend)	\N	5
0309020.11	Overige mutaties leningen, voorschotten en garanties van bestuurders 1 (langlopend)	\N	5
0309020.12	Overige mutaties leningen, voorschotten en garanties van bestuurders 2 (langlopend)	\N	5
0309020.13	Overige mutaties leningen, voorschotten en garanties van bestuurders 3 (langlopend)	\N	5
0309020.14	Overige mutaties leningen, voorschotten en garanties van bestuurders 4 (langlopend)	\N	5
0309020.15	Overige mutaties leningen, voorschotten en garanties van bestuurders 5 (langlopend)	\N	5
0309022.12	Overige mutaties leningen, voorschotten en garanties commissaris 2	\N	5
0309120.01	Beginbalans cumulatieve aflossing vorderingen op bestuurders 1 (langlopend)	\N	5
0309120.02	Beginbalans cumulatieve aflossing vorderingen op bestuurders 2 (langlopend)	\N	5
0309120.03	Beginbalans cumulatieve aflossing vorderingen op bestuurders 3 (langlopend)	\N	5
0309120.04	Beginbalans cumulatieve aflossing vorderingen op bestuurders 4 (langlopend)	\N	5
0309120.05	Beginbalans cumulatieve aflossing vorderingen op bestuurders 5 (langlopend)	\N	5
0309120.06	Aflossing / afname leningen, voorschotten en garanties bestuurders 1 (langlopend)	\N	5
0309120.07	Aflossing / afname leningen, voorschotten en garanties bestuurders 2 (langlopend)	\N	5
0309120.08	Aflossing / afname leningen, voorschotten en garanties bestuurders 3 (langlopend)	\N	5
0309120.09	Aflossing / afname leningen, voorschotten en garanties bestuurders 4 (langlopend)	\N	5
0309120.10	Aflossing / afname leningen, voorschotten en garanties bestuurders 5 (langlopend)	\N	5
0309021.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen bestuurders 1 (langlopend)	\N	5
0309021.02	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen bestuurders 2 (langlopend)	\N	5
0309021.03	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen bestuurders 3 (langlopend)	\N	5
0309021.04	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen bestuurders 4 (langlopend)	\N	5
0309021.05	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen bestuurders 5 (langlopend)	\N	5
0309021.06	Toename leningen, voorschotten en garanties van gewezen bestuurders 1	\N	5
0309021.07	Toename leningen, voorschotten en garanties van gewezen bestuurders 2	\N	5
0309021.08	Toename leningen, voorschotten en garanties van gewezen bestuurders 3	\N	5
0309021.09	Toename leningen, voorschotten en garanties van gewezen bestuurders 4	\N	5
0309021.10	Toename leningen, voorschotten en garanties van gewezen bestuurders 5	\N	5
0309021.11	Overige mutaties leningen, voorschotten en garanties van gewezen bestuurders 1	\N	5
0309021.12	Overige mutaties leningen, voorschotten en garanties van gewezen bestuurders 2	\N	5
0309021.13	Overige mutaties leningen, voorschotten en garanties van gewezen bestuurders 3	\N	5
0309021.14	Overige mutaties leningen, voorschotten en garanties van gewezen bestuurders 4	\N	5
0309021.15	Overige mutaties leningen, voorschotten en garanties van gewezen bestuurders 5	\N	5
0309121.01	Beginbalans cumulatieve aflossing vorderingen op gewezen bestuurders 1	\N	5
0309121.02	Beginbalans cumulatieve aflossing vorderingen op gewezen bestuurders 2	\N	5
0309121.03	Beginbalans cumulatieve aflossing vorderingen op gewezen bestuurders 3	\N	5
0309121.04	Beginbalans cumulatieve aflossing vorderingen op gewezen bestuurders 4	\N	5
0309121.05	Beginbalans cumulatieve aflossing vorderingen op gewezen bestuurders 5	\N	5
0309121.06	Aflossing / afname leningen, voorschotten en garanties gewezen bestuurders 1	\N	5
0309121.07	Aflossing / afname leningen, voorschotten en garanties gewezen bestuurders 2	\N	5
0309121.08	Aflossing / afname leningen, voorschotten en garanties gewezen bestuurders 3	\N	5
0309121.09	Aflossing / afname leningen, voorschotten en garanties gewezen bestuurders 4	\N	5
0309121.10	Aflossing / afname leningen, voorschotten en garanties gewezen bestuurders 5	\N	5
0309022.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op commissaris 1 (langlopend)	\N	5
0309022.02	Beginbalans (overname eindsaldo vorig jaar) vorderingen op commissaris 2 (langlopend)	\N	5
0309022.03	Beginbalans (overname eindsaldo vorig jaar) vorderingen op commissaris 3 (langlopend)	\N	5
0309022.04	Beginbalans (overname eindsaldo vorig jaar) vorderingen op commissaris 4 (langlopend)	\N	5
0309022.05	Beginbalans (overname eindsaldo vorig jaar) vorderingen op commissaris 5 (langlopend)	\N	5
0309022.06	Toename leningen, voorschotten en garanties commissaris 1	\N	5
0309022.07	Toename leningen, voorschotten en garanties commissaris 2	\N	5
0309022.08	Toename leningen, voorschotten en garanties commissaris 3	\N	5
0309022.09	Toename leningen, voorschotten en garanties commissaris 4	\N	5
0309022.10	Toename leningen, voorschotten en garanties commissaris 5	\N	5
0309022.11	Overige mutaties leningen, voorschotten en garanties commissaris 1	\N	5
0309022.13	Overige mutaties leningen, voorschotten en garanties commissaris 3	\N	5
0309022.14	Overige mutaties leningen, voorschotten en garanties commissaris 4	\N	5
0309022.15	Overige mutaties leningen, voorschotten en garanties commissaris 5	\N	5
0309122.01	Beginbalans cumulatieve aflossing vorderingen op commissaris 1	\N	5
0309122.02	Beginbalans cumulatieve aflossing vorderingen op commissaris 2	\N	5
0309122.03	Beginbalans cumulatieve aflossing vorderingen op commissaris 3	\N	5
0309122.04	Beginbalans cumulatieve aflossing vorderingen op commissaris 4	\N	5
0309122.05	Beginbalans cumulatieve aflossing vorderingen op commissaris 5	\N	5
0309122.06	Aflossing / afname leningen, voorschotten en garanties commissaris 1	\N	5
0309122.07	Aflossing / afname leningen, voorschotten en garanties commissaris 2	\N	5
0309122.08	Aflossing / afname leningen, voorschotten en garanties commissaris 3	\N	5
0309122.09	Aflossing / afname leningen, voorschotten en garanties commissaris 4	\N	5
0309122.10	Aflossing / afname leningen, voorschotten en garanties commissaris 5	\N	5
0309023.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen commissaris 1 (langlopend)	\N	5
0309023.02	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen commissaris 2 (langlopend)	\N	5
0309023.03	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen commissaris 3 (langlopend)	\N	5
0309023.04	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen commissaris 4 (langlopend)	\N	5
0309023.05	Beginbalans (overname eindsaldo vorig jaar) vorderingen op gewezen commissaris 5 (langlopend)	\N	5
0309023.06	Toename leningen, voorschotten en garanties gewezen commissaris 1	\N	5
0309023.07	Toename leningen, voorschotten en garanties gewezen commissaris 2	\N	5
0309023.08	Toename leningen, voorschotten en garanties gewezen commissaris 3	\N	5
0309023.09	Toename leningen, voorschotten en garanties gewezen commissaris 4	\N	5
0309023.10	Toename leningen, voorschotten en garanties gewezen commissaris 5	\N	5
0309023.11	Overige mutaties leningen, voorschotten en garanties gewezen commissaris 1	\N	5
0309023.12	Overige mutaties leningen, voorschotten en garanties gewezen commissaris 2	\N	5
0309023.13	Overige mutaties leningen, voorschotten en garanties gewezen commissaris 3	\N	5
0309023.14	Overige mutaties leningen, voorschotten en garanties gewezen commissaris 4	\N	5
0309023.15	Overige mutaties leningen, voorschotten en garanties gewezen commissaris 5	\N	5
0309123.01	Beginbalans cumulatieve aflossing vorderingen op gewezen commissaris 1	\N	5
0309123.02	Beginbalans cumulatieve aflossing vorderingen op gewezen commissaris 2	\N	5
0309123.03	Beginbalans cumulatieve aflossing vorderingen op gewezen commissaris 3	\N	5
0309123.04	Beginbalans cumulatieve aflossing vorderingen op gewezen commissaris 4	\N	5
0309123.05	Beginbalans cumulatieve aflossing vorderingen op gewezen commissaris 5	\N	5
0309123.06	Aflossing / afname leningen, voorschotten en garanties gewezen commissaris 1	\N	5
0309123.07	Aflossing / afname leningen, voorschotten en garanties gewezen commissaris 2	\N	5
0309123.08	Aflossing / afname leningen, voorschotten en garanties gewezen commissaris 3	\N	5
0309123.09	Aflossing / afname leningen, voorschotten en garanties gewezen commissaris 4	\N	5
0309123.10	Aflossing / afname leningen, voorschotten en garanties gewezen commissaris 5	\N	5
0309024.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op lid 1 (langlopend)	\N	5
0309024.02	Beginbalans (overname eindsaldo vorig jaar) vorderingen op lid 2 (langlopend)	\N	5
0309024.03	Beginbalans (overname eindsaldo vorig jaar) vorderingen op lid 3 (langlopend)	\N	5
0309024.04	Beginbalans (overname eindsaldo vorig jaar) vorderingen op lid 4 (langlopend)	\N	5
0309024.05	Beginbalans (overname eindsaldo vorig jaar) vorderingen op lid 5 (langlopend)	\N	5
0309024.06	Toename vorderingen op lid 1	\N	5
0309024.07	Toename vorderingen op lid 2	\N	5
0309024.08	Toename vorderingen op lid 3	\N	5
0309024.09	Toename vorderingen op lid 4	\N	5
0309024.10	Toename vorderingen op lid 5	\N	5
0309024.11	Overige mutaties vorderingen op lid 1	\N	5
0309124.01	Beginbalans cumulatieve aflossing vorderingen op lid 1	\N	5
0309124.02	Beginbalans cumulatieve aflossing vorderingen op lid 2	\N	5
0309124.03	Beginbalans cumulatieve aflossing vorderingen op lid 3	\N	5
0309124.04	Beginbalans cumulatieve aflossing vorderingen op lid 4	\N	5
0309124.05	Beginbalans cumulatieve aflossing vorderingen op lid 5	\N	5
0309124.06	Aflossing / afname leningen en voorschotten lid 1	\N	5
0309124.07	Aflossing / afname leningen en voorschotten lid 2	\N	5
0309124.08	Aflossing / afname leningen en voorschotten lid 3	\N	5
0309124.09	Aflossing / afname leningen en voorschotten lid 4	\N	5
0309124.10	Aflossing / afname leningen en voorschotten lid 5	\N	5
0309025.01	Beginbalans (overname eindsaldo vorig jaar) vorderingen op aandeelhouder 1 (langlopend)	\N	5
0309025.02	Beginbalans (overname eindsaldo vorig jaar) vorderingen op aandeelhouder 2 (langlopend)	\N	5
0309025.03	Beginbalans (overname eindsaldo vorig jaar) vorderingen op aandeelhouder 3 (langlopend)	\N	5
0309025.04	Beginbalans (overname eindsaldo vorig jaar) vorderingen op aandeelhouder 4 (langlopend)	\N	5
0309025.05	Beginbalans (overname eindsaldo vorig jaar) vorderingen op aandeelhouder 5 (langlopend)	\N	5
0309025.06	Toename vorderingen op aandeelhouder 1	\N	5
0309025.07	Toename vorderingen op aandeelhouder 2	\N	5
0309025.08	Toename vorderingen op aandeelhouder 3	\N	5
0309025.09	Toename vorderingen op aandeelhouder 4	\N	5
0309025.10	Toename vorderingen op aandeelhouder 5	\N	5
0309025.11	Overige mutaties vorderingen op aandeelhouder 1	\N	5
0309025.12	Overige mutaties vorderingen op aandeelhouder 2	\N	5
0309025.13	Overige mutaties vorderingen op aandeelhouder 3	\N	5
0309025.14	Overige mutaties vorderingen op aandeelhouder 4	\N	5
0309025.15	Overige mutaties vorderingen op aandeelhouder 5	\N	5
0309125.01	Beginbalans cumulatieve aflossing vorderingen op aandeelhouder 1	\N	5
0309125.02	Beginbalans cumulatieve aflossing vorderingen op aandeelhouder 2	\N	5
0309125.03	Beginbalans cumulatieve aflossing vorderingen op aandeelhouder 3	\N	5
0309125.04	Beginbalans cumulatieve aflossing vorderingen op aandeelhouder 4	\N	5
0309125.05	Beginbalans cumulatieve aflossing vorderingen op aandeelhouder 5	\N	5
0309125.06	Aflossing / afname vorderingen op aandeelhouder 1	\N	5
0309125.07	Aflossing / afname vorderingen op aandeelhouder 2	\N	5
0309125.08	Aflossing / afname vorderingen op aandeelhouder 3	\N	5
0309125.09	Aflossing / afname vorderingen op aandeelhouder 4	\N	5
0309125.10	Aflossing / afname vorderingen op aandeelhouder 5	\N	5
0309009.01	Beginbalans (overname eindsaldo vorig jaar) te vorderen subsidie 1 (langlopend)	\N	5
0309009.02	Beginbalans (overname eindsaldo vorig jaar) te vorderen subsidie 2 (langlopend)	\N	5
0309009.03	Beginbalans (overname eindsaldo vorig jaar) te vorderen subsidie 3 (langlopend)	\N	5
0309009.04	Toename te vorderen subsidie 1	\N	5
0309009.05	Toename te vorderen subsidie 2	\N	5
0309009.06	Toename te vorderen subsidie 3	\N	5
0309009.07	Overige mutaties te vorderen subsidie 1	\N	5
0309009.08	Overige mutaties te vorderen subsidie 2	\N	5
0309009.09	Overige mutaties te vorderen subsidie 3	\N	5
0309019.01	Beginbalans cumulatieve aflossing te vorderen subsidies 1	\N	5
0309019.02	Beginbalans cumulatieve aflossing te vorderen subsidies 2	\N	5
0309019.03	Beginbalans cumulatieve aflossing te vorderen subsidies 3	\N	5
0309019.04	Aflossing / afname te vorderen subsidies 1	\N	5
0309019.05	Aflossing / afname te vorderen subsidies 2	\N	5
0309019.06	Aflossing / afname te vorderen subsidies 3	\N	5
0309050.01	Beginbalans (overname eindsaldo vorig jaar) waarborgsom 1 (langlopend)	\N	5
0309050.02	Beginbalans (overname eindsaldo vorig jaar) waarborgsom 2 (langlopend)	\N	5
0309050.03	Beginbalans (overname eindsaldo vorig jaar) waarborgsom 3 (langlopend)	\N	5
0309050.04	Toename waarborgsom 1	\N	5
0309050.05	Toename waarborgsom 2	\N	5
0309050.06	Toename waarborgsom 3	\N	5
0309050.07	Overige mutaties waarborgsom 1	\N	5
0309050.08	Overige mutaties waarborgsom 2	\N	5
0309050.09	Overige mutaties waarborgsom 3	\N	5
0309150.01	Beginbalans cumulatieve aflossing waarborgsom 1	\N	5
0309150.02	Beginbalans cumulatieve aflossing waarborgsom 2	\N	5
0309150.03	Beginbalans cumulatieve aflossing waarborgsom 3	\N	5
0309150.04	Aflossing / afname waarborgsom 1	\N	5
0309150.05	Aflossing / afname waarborgsom 2	\N	5
0309150.06	Aflossing / afname waarborgsom 3	\N	5
0309039.01	Beginbalans (overname eindsaldo vorig jaar) ledenrekeningen 1 (langlopend)	\N	5
0309039.02	Beginbalans (overname eindsaldo vorig jaar) ledenrekeningen 2 (langlopend)	\N	5
0309039.03	Beginbalans (overname eindsaldo vorig jaar) ledenrekeningen 3 (langlopend)	\N	5
0309039.05	Toename ledenrekening 2	\N	5
0309039.06	Toename ledenrekening 3	\N	5
0309039.07	Overige mutaties ledenrekening 1	\N	5
0309039.08	Overige mutaties ledenrekening 2	\N	5
0309039.09	Overige mutaties ledenrekening 3	\N	5
0309139.01	Beginbalans cumulatieve aflossing ledenrekening 1	\N	5
0309139.02	Beginbalans cumulatieve aflossing ledenrekening 2	\N	5
0309139.03	Beginbalans cumulatieve aflossing ledenrekening 3	\N	5
0309139.04	Aflossing / afname ledenrekening 1	\N	5
0309139.05	Aflossing / afname ledenrekening 2	\N	5
0309139.06	Aflossing / afname ledenrekening 3	\N	5
0309029.01	Beginbalans (overname eindsaldo vorig jaar) overige financiële vaste activa 1 (langlopend)	\N	5
0309029.02	Beginbalans (overname eindsaldo vorig jaar) overige financiële vaste activa 2 (langlopend)	\N	5
0309029.03	Beginbalans (overname eindsaldo vorig jaar) overige financiële vaste activa 3 (langlopend)	\N	5
0309029.04	Toename overige financiële vaste activa 1	\N	5
0309029.05	Toename overige financiële vaste activa 2	\N	5
0309029.06	Toename overige financiële vaste activa 3	\N	5
0309029.07	Overige mutaties overige financiële vaste activa 1	\N	5
0309029.08	Overige mutaties overige financiële vaste activa 2	\N	5
0309029.09	Overige mutaties overige financiële vaste activa 3	\N	5
0309029.10	Omrekeningsverschillen overige financiële vaste activa 1	\N	5
0309029.11	Omrekeningsverschillen overige financiële vaste activa 2	\N	5
0309029.12	Omrekeningsverschillen overige financiële vaste activa 3	\N	5
0309129.01	Beginbalans (overname eindsaldo vorig jaar) cumulatieve aflossing overige financiële vaste activa 1 (langlopend)	\N	5
0309129.02	Beginbalans (overname eindsaldo vorig jaar) cumulatieve aflossing overige financiële vaste activa 2 (langlopend)	\N	5
0309129.03	Beginbalans (overname eindsaldo vorig jaar) cumulatieve aflossing overige financiële vaste activa 3 (langlopend)	\N	5
0309129.04	Aflossing / afname overige financiële vaste activa 1	\N	5
0309129.05	Aflossing / afname overige financiële vaste activa 2	\N	5
0309129.06	Aflossing / afname overige financiële vaste activa 3	\N	5
0309129.07	Bijzondere waardeverminderingen overige financiële vaste activa 1	\N	5
0309129.08	Bijzondere waardeverminderingen overige financiële vaste activa 2	\N	5
0309129.09	Bijzondere waardeverminderingen overige financiële vaste activa 3	\N	5
0309129.10	Terugneming van bijzondere waardeverminderingen overige financiële vaste activa 1	\N	5
0309129.11	Terugneming van bijzondere waardeverminderingen overige financiële vaste activa 2	\N	5
0309129.12	Terugneming van bijzondere waardeverminderingen overige financiële vaste activa 3	\N	5
0309129.13	Overige mutaties waardeveranderingen overige financiële vaste activa 1	\N	5
0309129.14	Overige mutaties waardeveranderingen overige financiële vaste activa 2	\N	5
0309129.15	Overige mutaties waardeveranderingen overige financiële vaste activa 3	\N	5
0309028.01	Saldo per begin boekjaar	\N	5
0309028.02	Stortingen	\N	5
0309028.03	Ontvangsten	\N	5
0309028.04	Bijzondere waardeverminderingen	\N	5
0309028.05	Terugneming van bijzondere waardeverminderingen	\N	5
0309027.01	Saldo per begin boekjaar	\N	5
0309027.02	Vrijval ten laste van het resultaat	\N	5
0309027.03	Geactiveerde afrekening break	\N	5
0309027.04	Bijzondere waardeverminderingen	\N	5
0309027.05	Terugneming van bijzondere waardeverminderingen	\N	5
0308010.01	Saldo per begin boekjaar	\N	5
0308010.02	Toename	\N	5
0308010.03	Afname	\N	5
0308020.01	Saldo per begin boekjaar	\N	5
0308020.02	Toename	\N	5
0308020.03	Afname	\N	5
0308030.01	Saldo per begin boekjaar	\N	5
0308030.02	Toename	\N	5
0308030.03	Afname	\N	5
0310010.01	Beginbalans (overname eindsaldo vorig jaar) te vorderen BWS-subsidie 1 (langlopend)	\N	5
0310010.02	Beginbalans (overname eindsaldo vorig jaar) te vorderen BWS-subsidie 2 (langlopend)	\N	5
0310010.03	Beginbalans (overname eindsaldo vorig jaar) te vorderen BWS-subsidie 3 (langlopend)	\N	5
0310010.04	Beginbalans (overname eindsaldo vorig jaar) te vorderen BWS-subsidie 4 (langlopend)	\N	5
0310010.05	Beginbalans (overname eindsaldo vorig jaar) te vorderen BWS-subsidie 5 (langlopend)	\N	5
0310010.06	Toename  te vorderen BWS-subsidie 1	\N	5
0310010.07	Toename  te vorderen BWS-subsidie 2	\N	5
0310010.08	Toename  te vorderen BWS-subsidie 3	\N	5
0310010.09	Toename  te vorderen BWS-subsidie 4	\N	5
0310010.10	Toename  te vorderen BWS-subsidie 5	\N	5
0310010.11	Overige mutaties  te vorderen BWS-subsidie 1	\N	5
0310010.12	Overige mutaties  te vorderen BWS-subsidie 2	\N	5
0310010.13	Overige mutaties  te vorderen BWS-subsidie 3	\N	5
0310010.14	Overige mutaties  te vorderen BWS-subsidie 4	\N	5
0310010.15	Overige mutaties  te vorderen BWS-subsidie 5	\N	5
0310020.01	Beginbalans cumulatieve aflossing te vorderen BWS-subsidie 1	\N	5
0310020.02	Beginbalans cumulatieve aflossing te vorderen BWS-subsidie 2	\N	5
0310020.03	Beginbalans cumulatieve aflossing te vorderen BWS-subsidie 3	\N	5
0310020.04	Beginbalans cumulatieve aflossing te vorderen BWS-subsidie 4	\N	5
0310020.05	Beginbalans cumulatieve aflossing te vorderen BWS-subsidie 5	\N	5
0310020.06	Aflossing / afname te vorderen BWS-subsidie 1	\N	5
0310020.07	Aflossing / afname te vorderen BWS-subsidie 2	\N	5
0310020.08	Aflossing / afname te vorderen BWS-subsidie 3	\N	5
0310020.09	Aflossing / afname te vorderen BWS-subsidie 4	\N	5
0310020.10	Aflossing / afname te vorderen BWS-subsidie 5	\N	5
0320010.01	Beginbalans lening u/g 1 (langlopend)	\N	5
0320010.02	Aflossingsverplichting (overboeking naar kortlopend) lening u/g 1	\N	5
0320010.03	Aflossing / afname in boekjaar lening u/g 1	\N	5
0320010.04	Toename / uitgegeven in boekjaar lening u/g 1	\N	5
0320010.06	Omrekeningsverschillen in boekjaar lening u/g 1	\N	5
0320010.05	Overige mutaties lening u/g 1	\N	5
0320010.07	Bijzondere waardeverminderingen lening u/g 1	\N	5
0320010.08	Terugneming van bijzondere waardeverminderingen lening u/g 1	\N	5
0320010.09	Overige mutaties waardeveranderingen lening u/g 1	\N	5
0320010.11	Beginbalans lening u/g 2 (langlopend)	\N	5
0320010.12	Aflossingsverplichting (overboeking naar kortlopend) lening u/g 2	\N	5
0320010.13	Aflossing / afname in boekjaar lening u/g 2	\N	5
0320010.14	Toename / uitgegeven in boekjaar lening u/g 2	\N	5
0320010.16	Omrekeningsverschillen in boekjaar lening u/g 2	\N	5
0320010.15	Overige mutaties lening u/g 2	\N	5
0320010.17	Bijzondere waardeverminderingen lening u/g 2	\N	5
0320010.18	Terugneming van bijzondere waardeverminderingen lening u/g 2	\N	5
0320010.19	Overige mutaties waardeveranderingen lening u/g 2	\N	5
0320010.21	Beginbalans lening u/g 3 (langlopend)	\N	5
0320010.22	Aflossingsverplichting (overboeking naar kortlopend) lening u/g 3	\N	5
0320010.23	Aflossing / afname in boekjaar lening u/g 3	\N	5
0320010.24	Toename / uitgegeven in boekjaar lening u/g 3	\N	5
0320010.26	Omrekeningsverschillen in boekjaar lening u/g 3	\N	5
0320010.25	Overige mutaties lening u/g 3	\N	5
0320010.27	Bijzondere waardeverminderingen lening u/g 3	\N	5
0320010.28	Terugneming van bijzondere waardeverminderingen lening u/g 3	\N	5
0320010.29	Overige mutaties waardeveranderingen lening u/g 3	\N	5
0320010.31	Beginbalans lening u/g 4 (langlopend)	\N	5
0320010.32	Aflossingsverplichting (overboeking naar kortlopend) lening u/g 4	\N	5
0320010.33	Aflossing / afname in boekjaar lening u/g 4	\N	5
0320010.34	Toename / uitgegeven in boekjaar lening u/g 4	\N	5
0320010.36	Omrekeningsverschillen in boekjaar lening u/g 4	\N	5
0320010.35	Overige mutaties lening u/g 4	\N	5
0320010.37	Bijzondere waardeverminderingen lening u/g 4	\N	5
0320010.38	Terugneming van bijzondere waardeverminderingen lening u/g 4	\N	5
0320010.39	Overige mutaties waardeveranderingen lening u/g 4	\N	5
0320010.41	Beginbalans lening u/g 5 (langlopend)	\N	5
0320010.42	Aflossingsverplichting (overboeking naar kortlopend) lening u/g 5	\N	5
0320010.43	Aflossing / afname in boekjaar lening u/g 5	\N	5
0320010.44	Toename / uitgegeven in boekjaar lening u/g 5	\N	5
0320010.46	Omrekeningsverschillen in boekjaar lening u/g 5	\N	5
0320010.45	Overige mutaties lening u/g 5	\N	5
0320010.47	Bijzondere waardeverminderingen lening u/g 5	\N	5
0320010.48	Terugneming van bijzondere waardeverminderingen lening u/g 5	\N	5
0320010.49	Overige mutaties waardeveranderingen lening u/g 5	\N	5
0330010.01	Beginbalans (overname eindsaldo vorig jaar) hoofdsom interne lening	\N	5
0330010.02	Toename hoofdsom interne lening	\N	5
0330010.03	Overige mutaties hoofdsom interne lening	\N	5
0330020.01	Beginbalans (overname eindsaldo vorig jaar) interne Lening	\N	5
0330020.02	Aflossing / afname in boekjaar interne Lening	\N	5
0340010.01	Beginbalans (overname eindsaldo vorig jaar) netto vermogenswaarde niet-Daeb	\N	5
0340010.02	Investeringen netto vermogenswaarde niet-Daeb	\N	5
0340010.03	Bij overname verkregen activa netto vermogenswaarde niet-Daeb	\N	5
0340010.04	Desinvesteringen netto vermogenswaarde niet-Daeb	\N	5
0340010.05	Afstotingen netto vermogenswaarde niet-Daeb	\N	5
0340010.09	Omrekeningsverschillen netto vermogenswaarde niet-Daeb	\N	5
0340010.10	Overige mutaties netto vermogenswaarde niet-Daeb	\N	5
0340020.01	Beginbalans (overname eindsaldo vorig jaar) netto vermogenswaarde niet-Daeb	\N	5
0340020.02	Afschrijvingen netto vermogenswaarde niet-Daeb	\N	5
0340020.03	Afschrijving op desinvesteringen netto vermogenswaarde niet-Daeb	\N	5
0340020.04	Bijzondere waardeverminderingen netto vermogenswaarde niet-Daeb	\N	5
0340020.05	Terugneming van bijzondere waardeverminderingen netto vermogenswaarde niet-Daeb	\N	5
0340030.01	Beginbalans (overname eindsaldo vorig jaar) netto vermogenswaarde niet-Daeb	\N	5
0340030.02	Herwaarderingen netto vermogenswaarde niet-Daeb	\N	5
0340030.05	Aandeel in resultaat deelnemingen netto vermogenswaarde niet-Daeb	\N	5
0340030.06	Dividend van deelnemingen netto vermogenswaarde niet-Daeb	\N	5
0340030.07	Afschrijving herwaardering niet-Daeb	\N	5
0340030.09	Overige mutaties waardeverandering niet-Daeb	\N	5
0340030.08	Desinvestering herwaardering niet-Daeb	\N	5
3501010.01	Beginbalans geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.02	Grond- en hulpstoffen geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.03	Arbeidskosten geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.04	Onderaanneming geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.05	Constructiematerialen geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.06	Grond en terreinen geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.07	Afschrijving installaties en uitrusting geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.08	Huur van installaties en uitrusting geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.09	Transport van installaties en uitrusting geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.10	Ontwerp en technische assistentie geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.11	Herstellings- en garantiewerken geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.12	Claims van derden geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.13	Verzekeringskosten geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.14	Rentekosten schulden tijdens vervaardiging geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.15	Overheadkosten geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.16	Algemene kosten (opslag) geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.17	Winstopslag geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.18	Incidentele baten en lasten geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.19	Interne doorbelastingen binnen fiscale eenheid geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.20	Opgeleverde werken geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501010.21	Overige mutaties geactiveerde kosten onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501020.01	Beginbalans gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501020.02	Belast met algemeen tarief gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501020.03	Belast met verlaagd tarief gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501020.04	Belast met overige tarieven gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501020.05	Belast met nultarief of niet belast gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501020.06	Niet belast wegens heffing verlegd gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501020.07	Installatie in landen binnen EU gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501020.08	Installatie in landen buiten EU gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501020.09	Interne doorbelastingen binnen fiscale eenheid gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501020.10	Opgeleverde werken gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501020.11	Overige mutaties gefactureerde termijnen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501030.01	Beginbalans voorziening verliezen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501030.02	Toename voorziening verliezen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501030.03	Onttrekking voorziening verliezen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501030.04	Vrijval voorziening verliezen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501030.05	Interne doorbelastingen binnen fiscale eenheid voorziening verliezen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501030.06	Opgeleverde werken voorziening verliezen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
3501030.07	Overige mutaties voorziening verliezen onderhanden projecten onderhanden projecten in opdracht van derden	\N	5
1103100.01	Rekening courant vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103100.02	Cumulatieve waardeverminderingen	\N	5
1103100.03	Doorbelastingen	\N	5
1103100.04	Te vorderen dividend vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103100.05	Waardeveranderingen	\N	5
1103100.06	Overige vorderingen vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103101.01	Rekening courant vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103101.02	Cumulatieve waardeverminderingen	\N	5
1103101.03	Doorbelastingen	\N	5
1103101.04	Te vorderen dividend vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103101.05	Waardeveranderingen	\N	5
1103101.06	Overige vorderingen vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103102.01	Rekening courant vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103102.02	Cumulatieve waardeverminderingen	\N	5
1103102.03	Doorbelastingen	\N	5
1103102.04	Te vorderen dividend vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103102.05	Waardeveranderingen	\N	5
1103102.06	Overige vorderingen vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103103.01	Rekening courant vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103103.02	Cumulatieve waardeverminderingen	\N	5
1103103.03	Doorbelastingen	\N	5
1103103.04	Te vorderen dividend vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103103.05	Waardeveranderingen	\N	5
1103103.06	Overige vorderingen vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103104.01	Rekening courant vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103104.02	Cumulatieve waardeverminderingen	\N	5
1103104.03	Doorbelastingen	\N	5
1103104.04	Te vorderen dividend vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103104.05	Waardeveranderingen	\N	5
1103104.06	Overige vorderingen vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103105.01	Saldo hoofdsom lening u/g vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103105.02	Aflossing leningen u/g vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103105.03	Te vorderen rente leningen u/g vorderingen op groepsmaatschappijen (kortlopend)	\N	5
1103106.01	Rekening courant	\N	5
1103106.02	Cumulatieve waardeverminderingen	\N	5
1103106.03	Doorbelastingen	\N	5
1103106.04	Te vorderen dividend	\N	5
1103106.05	Waardeveranderingen	\N	5
1103106.06	Overige mutaties	\N	5
1103107.01	Rekening courant	\N	5
1103107.02	Cumulatieve waardeverminderingen	\N	5
1103107.03	Doorbelastingen	\N	5
1103107.04	Te vorderen dividend	\N	5
1103107.05	Waardeveranderingen	\N	5
1103107.06	Overige mutaties	\N	5
1103110.01	Rekening courant overige verbonden maatschappij 1 (kortlopend)	\N	5
1103110.02	Cumulatieve waardeverminderingen vordering overige verbonden maatschappij 1 (kortlopend)	\N	5
1103110.03	Doorbelastingen vordering overige verbonden maatschappij 1 (kortlopend)	\N	5
1103110.04	Te vorderen dividend vordering overige verbonden maatschappij 1 (kortlopend)	\N	5
1103110.05	Waardeveranderingen vordering overige verbonden maatschappij 1 (kortlopend)	\N	5
1103110.06	Overige mutaties vordering overige verbonden maatschappij 1 (kortlopend)	\N	5
1103111.01	Rekening courant vordering overige verbonden maatschappij 2 (kortlopend)	\N	5
1103111.02	Cumulatieve waardeverminderingen vordering overige verbonden maatschappij 2 (kortlopend)	\N	5
1103111.03	Doorbelastingen vordering overige verbonden maatschappij 2 (kortlopend)	\N	5
1103111.04	Te vorderen dividend vordering overige verbonden maatschappij 2 (kortlopend)	\N	5
1103111.05	Waardeveranderingen vordering overige verbonden maatschappij 2 (kortlopend)	\N	5
1103111.06	Overige vorderingen vordering overige verbonden maatschappij 2 (kortlopend)	\N	5
1103112.01	Rekening courant vordering overige verbonden maatschappij 3 (kortlopend)	\N	5
1103112.02	Cumulatieve waardeverminderingen vordering overige verbonden maatschappij 3 (kortlopend)	\N	5
1103112.03	Doorbelastingen vordering overige verbonden maatschappij 3 (kortlopend)	\N	5
1103112.04	Te vorderen dividend vordering overige verbonden maatschappij 3 (kortlopend)	\N	5
1103112.05	Waardeveranderingen vordering overige verbonden maatschappij 3 (kortlopend)	\N	5
1103112.06	Overige vorderingen vordering overige verbonden maatschappij 3 (kortlopend)	\N	5
1103113.01	Rekening courant vordering overige verbonden maatschappij 4 (kortlopend)	\N	5
1103113.02	Cumulatieve waardeverminderingen vordering overige verbonden maatschappij 4 (kortlopend)	\N	5
1103113.03	Doorbelastingen vordering overige verbonden maatschappij 4 (kortlopend)	\N	5
1103113.04	Te vorderen dividend vordering overige verbonden maatschappij 4 (kortlopend)	\N	5
1103113.05	Waardeveranderingen vordering overige verbonden maatschappij 4 (kortlopend)	\N	5
1103113.06	Overige vorderingen vordering overige verbonden maatschappij 4 (kortlopend)	\N	5
1103200.05	Lening u/g 5 (kortlopend)	\N	5
1103114.01	Rekening courant vordering overige verbonden maatschappij 5 (kortlopend)	\N	5
1103114.02	Cumulatieve waardeverminderingen vordering overige verbonden maatschappij 5 (kortlopend)	\N	5
1103114.03	Doorbelastingen vordering overige verbonden maatschappij 5 (kortlopend)	\N	5
1103114.04	Te vorderen dividend vordering overige verbonden maatschappij 5 (kortlopend)	\N	5
1103114.05	Waardeveranderingen vordering overige verbonden maatschappij 5 (kortlopend)	\N	5
1103114.06	Overige vorderingen vordering overige verbonden maatschappij 5 (kortlopend)	\N	5
1103115.01	Saldo hoofdsom lening u/g overige verbonden maatschappij 1	\N	5
1103115.02	Aflossing leningen u/g overige verbonden maatschappij 1	\N	5
1103115.03	Te vorderen rente leningen u/g overige verbonden maatschappij 1	\N	5
1103120.01	Rekening courant vordering op participanten en op maatschappijen waarin wordt deelgenomen 1 (kortlopend)	\N	5
1103120.02	Cumulatieve waardeverminderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 1 (kortlopend)	\N	5
1103120.03	Doorbelastingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 1 (kortlopend)	\N	5
1103120.04	Te vorderen dividend vordering op participanten en op maatschappijen waarin wordt deelgenomen 1 (kortlopend)	\N	5
1103120.05	Waardeveranderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 1 (kortlopend)	\N	5
1103120.06	Overige vorderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 1 (kortlopend)	\N	5
1103121.01	Rekening courant vordering op participanten en op maatschappijen waarin wordt deelgenomen 2 (kortlopend)	\N	5
1103121.02	Cumulatieve waardeverminderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 2 (kortlopend)	\N	5
1103121.03	Doorbelastingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 2 (kortlopend)	\N	5
1103121.04	Te vorderen dividend vordering op participanten en op maatschappijen waarin wordt deelgenomen 2 (kortlopend)	\N	5
1103121.05	Waardeveranderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 2 (kortlopend)	\N	5
1103121.06	Overige vorderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 2 (kortlopend)	\N	5
1103122.01	Rekening courant vordering op participanten en op maatschappijen waarin wordt deelgenomen 3 (kortlopend)	\N	5
1103122.02	Cumulatieve waardeverminderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 3 (kortlopend)	\N	5
1103122.03	Doorbelastingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 3 (kortlopend)	\N	5
1103122.04	Te vorderen dividend vordering op participanten en op maatschappijen waarin wordt deelgenomen 3 (kortlopend)	\N	5
1103122.05	Waardeveranderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 3 (kortlopend)	\N	5
1103122.06	Overige vorderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 3 (kortlopend)	\N	5
1103123.01	Rekening courant vordering op participanten en op maatschappijen waarin wordt deelgenomen 4 (kortlopend)	\N	5
1103123.02	Cumulatieve waardeverminderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 4 (kortlopend)	\N	5
1103123.03	Doorbelastingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 4 (kortlopend)	\N	5
1103123.04	Te vorderen dividend vordering op participanten en op maatschappijen waarin wordt deelgenomen 4 (kortlopend)	\N	5
1103123.05	Waardeveranderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 4 (kortlopend)	\N	5
1103123.06	Overige vorderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 4 (kortlopend)	\N	5
1103124.01	Rekening courant vordering op participanten en op maatschappijen waarin wordt deelgenomen 5 (kortlopend)	\N	5
1103124.02	Cumulatieve waardeverminderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 5 (kortlopend)	\N	5
1103124.03	Doorbelastingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 5 (kortlopend)	\N	5
1103124.04	Te vorderen dividend vordering op participanten en op maatschappijen waarin wordt deelgenomen 5 (kortlopend)	\N	5
1103124.05	Waardeveranderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 5 (kortlopend)	\N	5
1103124.06	Overige vorderingen vordering op participanten en op maatschappijen waarin wordt deelgenomen 5 (kortlopend)	\N	5
1103125.01	Saldo hoofdsom lening u/g participant en op maatschappij waarin wordt deelgenomen 1	\N	5
1103125.02	Aflossing leningen u/g participant en op maatschappij waarin wordt deelgenomen 1	\N	5
1103125.03	Te vorderen rente leningen u/g participant en op maatschappij waarin wordt deelgenomen 1	\N	5
1102010.01	Terug te ontvangen binnenlandse omzetbelasting vorderingen uit hoofde van belastingen	\N	5
1102010.02	Terug te ontvangen buitenlandse omzetbelasting vorderingen uit hoofde van belastingen	\N	5
1103140.01	Rekening-courant bestuurder 1	\N	5
1103140.02	Rekening-courant bestuurder 2	\N	5
1103140.03	Rekening-courant bestuurder 3	\N	5
1103140.04	Rekening-courant bestuurder 4	\N	5
1103140.05	Rekening-courant bestuurder 5	\N	5
1103141.01	Rekening-courant commissaris 1	\N	5
1103141.02	Rekening-courant commissaris 2	\N	5
1103141.03	Rekening-courant commissaris 3	\N	5
1103141.04	Rekening-courant commissaris 4	\N	5
1103141.05	Rekening-courant commissaris 5	\N	5
1103142.01	Rekening-courant overige 1	\N	5
1103142.02	Rekening-courant overige 2	\N	5
1103142.03	Rekening-courant overige 3	\N	5
1103142.04	Rekening-courant overige 4	\N	5
1103142.05	Rekening-courant overige 5	\N	5
1103143.01	Rekening-courant aandeelhouder 1	\N	5
1103143.02	Rekening-courant aandeelhouder 2	\N	5
1103143.03	Rekening-courant aandeelhouder 3	\N	5
1103143.04	Rekening-courant aandeelhouder 4	\N	5
1103143.05	Rekening-courant aandeelhouder 5	\N	5
1103200.01	Lening u/g 1 (kortlopend)	\N	5
1103200.02	Lening u/g 2 (kortlopend)	\N	5
1103200.03	Lening u/g 3 (kortlopend)	\N	5
1103200.04	Lening u/g 4 (kortlopend)	\N	5
1105110	Tussenrekening contante aanbetalingen tussenrekeningen betalingen	\N	3
1105120	Tussenrekening creditcardbetalingen tussenrekeningen betalingen	\N	3
1105210	Tussenrekening brutoloon tussenrekeningen salarissen	\N	3
1105220	Tussenrekening brutoinhouding tussenrekeningen salarissen	\N	3
1105230	Tussenrekening nettoloon tussenrekeningen salarissen	\N	3
1105240	Tussenrekening nettoinhoudingen tussenrekeningen salarissen	\N	3
1105310	Tussenrekening nog te ontvangen goederen tussenrekeningen inkopen	\N	3
1105320	Tussenrekening nog te ontvangen facturen tussenrekeningen inkopen	\N	3
1105330	Tussenrekening inkoopverschillen tussenrekeningen inkopen	\N	3
1105410	Tussenrekening projectkosten tussenrekeningen projecten	\N	3
1105420	Tussenrekening projectopbrengsten tussenrekeningen projecten	\N	3
1105430	Tussenrekening projectverschillen tussenrekeningen projecten	\N	3
1105510	Tussenrekening materiaalverbruik tussenrekeningen productie	\N	3
1105520	Tussenrekening manuren tussenrekeningen productie	\N	3
1105530	Tussenrekening machineuren tussenrekeningen productie	\N	3
1105540	Tussenrekening te dekken budget tussenrekeningen productie	\N	3
1105550	Tussenrekening budget tussenrekeningen productie	\N	3
1105610	Tussenrekening capaciteit tussenrekeningen dienstverlening	\N	3
1105620	Tussenrekening materialen tussenrekeningen dienstverlening	\N	3
1105630	Tussenrekening uren tussenrekeningen dienstverlening	\N	3
1105640	Inkomende verschotten tussenrekeningen dienstverlening	\N	3
1105650	Voorschotten onbelast tussenrekeningen dienstverlening	\N	3
1105660	Voorschotten belast tussenrekeningen dienstverlening	\N	3
1105670	Doorberekende voorschotten onbelast tussenrekeningen dienstverlening	\N	3
1105680	Doorberekende voorschotten belast tussenrekeningen dienstverlening	\N	3
1105710	Tussenrekening voorraadverschillen tussenrekening voorraden	\N	3
1105810	Tussenrekening nog te factureren tussenrekeningen verkopen	\N	3
1105820	Tussenrekening nog te verzenden goederen tussenrekeningen verkopen	\N	3
1105830	Tussenrekening verkoopverschillen tussenrekeningen verkopen	\N	3
1105910	Tussenrekening contante ontvangsten tussenrekeningen ontvangsten	\N	3
1105920	Tussenrekening creditcardverkopen tussenrekeningen ontvangsten	\N	3
1106010	Tussenrekening beginbalans tussenrekeningen overig	\N	3
1106020	Tussenrekening vraagposten tussenrekeningen overig	\N	3
1106030	Tussenrekening overige tussenrekeningen overig	\N	3
1107010	Tussenrekening leningen OG	\N	3
1107020	Tussenrekening leningen UG	\N	3
1107030	Tussenrekening kasgeld OG	\N	3
1107040	Tussenrekening kasgeld UG	\N	3
1107050	Tussenrekening spaardeposito	\N	3
1107060	Tussenrekening derivaten	\N	3
1107070	Tussenrekening leningen CFV	\N	3
0401010.01	Beginbalans aandelen beursgenoteerd	\N	5
0401010.02	Aankoop beursgenoteerde effecten	\N	5
0401010.04	Verkoop beursgenoteerde effecten	\N	5
0401010.06	Waardeverminderingen beursgenoteerde effecten	\N	5
0401010.05	Afstempeling beursgenoteerde effecten	\N	5
0401010.07	Overige mutaties beursgenoteerde effecten	\N	5
0401020.01	Beginbalans aandelen niet beursgenoteerd	\N	5
0401020.02	Aankoop niet-beursgenoteerde effecten	\N	5
0401020.04	Verkoop niet-beursgenoteerde effecten	\N	5
0401020.07	Waardeverminderingen niet-beursgenoteerde effecten	\N	5
0401020.05	Afstempeling niet-beursgenoteerde effecten	\N	5
0401020.06	Overige mutaties niet-beursgenoteerde effecten	\N	5
0402010.01	Beginbalans obligaties beursgenoteerd	\N	5
0402010.02	Aankoop obligaties beursgenoteerd effecten	\N	5
0402010.03	Verkoop obligaties beursgenoteerd effecten	\N	5
0402010.05	Waardeverminderingen obligaties beursgenoteerd	\N	5
0402010.04	Uitloting obligaties beursgenoteerd effecten	\N	5
0402010.07	Afstempeling obligaties beursgenoteerd effecten	\N	5
0402010.06	Overige mutaties obligaties beursgenoteerd effecten	\N	5
0402020.01	Beginbalans obligaties niet beursgenoteerd	\N	5
0402020.02	Aankoop obligaties niet-beursgenoteerde effecten	\N	5
0402020.03	Verkoop obligaties niet-beursgenoteerde effecten	\N	5
0402020.05	Waardeverminderingen obligaties niet-beursgenoteerde effecten	\N	5
0402020.04	Uitloting obligaties niet-beursgenoteerde effecten	\N	5
0402020.06	Overige mutaties obligaties niet-beursgenoteerde effecten	\N	5
0403010.01	Beginbalans overige effecten beursgenoteerd	\N	5
0403010.02	Aankoop overige effecten beursgenoteerde effecten	\N	5
0403010.03	Verkoop overige effecten beursgenoteerde effecten	\N	5
0403010.04	Waardeverminderingen overige effecten beursgenoteerde effecten	\N	5
0403010.05	Overige mutaties overige effecten beursgenoteerde effecten	\N	5
0403020.01	Beginbalans overige effecten niet beursgenoteerd	\N	5
0403020.02	Aankoop overige effecten niet-beursgenoteerde effecten	\N	5
0403020.03	Verkoop overige effecten niet-beursgenoteerde effecten	\N	5
0403020.04	Waardeverminderingen overige effecten niet-beursgenoteerde effecten	\N	5
0403020.05	Overige mutaties overige effecten niet-beursgenoteerde effecten	\N	5
0404010.02	Aankoop optierechten beursgenoteerde effecten	\N	5
0404010.03	Verkoop optierechten beursgenoteerde effecten	\N	5
0404010.04	Waardeverminderingen optierechten beursgenoteerde effecten	\N	5
0404010.05	Overige mutaties optierechten beursgenoteerde effecten	\N	5
0404020.02	Aankoop optierechten niet-beursgenoteerde effecten	\N	5
0404020.03	Verkoop optierechten niet-beursgenoteerde effecten	\N	5
0404020.04	Waardeverminderingen optierechten niet-beursgenoteerde effecten	\N	5
0404020.05	Overige mutaties optierechten niet-beursgenoteerde effecten	\N	5
0405010.02	Aankoop optieverplichtingen beursgenoteerde optieverplichtingen	\N	5
0405010.03	Verkoop optieverplichtingen beursgenoteerde optieverplichtingen	\N	5
0405010.04	Waardeverminderingen optieverplichtingen beursgenoteerde optieverplichtingen	\N	5
0405010.05	Overige mutaties optieverplichtingen beursgenoteerde optieverplichtingen	\N	5
0405020.02	Aankoop optieverplichtingen niet-beursgenoteerde optieverplichtingen	\N	5
0405020.03	Verkoop optieverplichtingen niet-beursgenoteerde optieverplichtingen	\N	5
0405020.04	Waardeverminderingen optieverplichtingen niet-beursgenoteerde optieverplichtingen	\N	5
0405020.05	Overige mutaties optieverplichtingen niet-beursgenoteerde optieverplichtingen	\N	5
0406010.01	Positieve marktwaarde derivaten	\N	5
0465010.02	Positieve marktwaarde embedded derivaten	\N	5
1002010.01	Rekening-courant bank groep 1	\N	5
1002010.02	Rekening-courant bank groep 2	\N	5
1002010.03	Rekening-courant bank groep 3	\N	5
1002010.04	Rekening-courant bank groep 4	\N	5
1002010.05	Rekening-courant bank groep 5	\N	5
1002010.06	Rekening-courant bank groep 6	\N	5
1002010.07	Rekening-courant bank groep 7	\N	5
1002010.08	Rekening-courant bank groep 8	\N	5
1002010.09	Rekening-courant bank groep 9	\N	5
1002010.10	Rekening-courant bank groep 10	\N	5
0501010.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0501010.02	Uitgifte van aandelen 	\N	5
0501010.06	Verkoop van eigen aandelen 	\N	5
0501010.07	Inkoop van eigen aandelen 	\N	5
0501010.10	Intrekking van aandelen 	\N	5
0501010.14	Dividenduitkeringen 	\N	5
0501010.28	Interim-dividenduitkeringen	\N	5
0501010.16	Emissiekosten	\N	5
0501010.15	Overboekingen 	\N	5
0501010.13	Overige mutaties 	\N	5
0501040.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0501040.02	Uitgifte van aandelen 	\N	5
0501040.06	Verkoop van eigen aandelen 	\N	5
0501040.07	Inkoop van eigen aandelen 	\N	5
0501040.08	Intrekking van aandelen 	\N	5
0501040.14	Dividenduitkeringen 	\N	5
0501040.28	Interim-dividenduitkeringen	\N	5
0501040.16	Emissiekosten	\N	5
0501040.15	Overboekingen 	\N	5
0501040.11	Overige mutaties preferente aandelen	\N	5
0501050.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0501050.02	Uitgifte van aandelen 	\N	5
0501050.06	Verkoop van eigen aandelen 	\N	5
0501050.07	Inkoop van eigen aandelen 	\N	5
0501050.08	Intrekking van aandelen 	\N	5
0501050.14	Dividenduitkeringen 	\N	5
0501050.28	Interim-dividenduitkeringen	\N	5
0501050.16	Emissiekosten	\N	5
0501050.15	Overboekingen 	\N	5
0501050.11	Overige mutaties 	\N	5
0501070.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0501070.02	Uitgifte van aandelen 	\N	5
0501070.06	Verkoop van eigen aandelen 	\N	5
0501070.07	Inkoop van eigen aandelen 	\N	5
0501070.08	Intrekking van aandelen 	\N	5
0501070.14	Dividenduitkeringen 	\N	5
0501070.28	Interim-dividenduitkeringen	\N	5
0501070.16	Emissiekosten	\N	5
0501070.15	Overboekingen 	\N	5
0501070.11	Overige mutaties 	\N	5
0501030.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0501030.02	Uitgifte van aandelen 	\N	5
0501030.06	Verkoop van eigen aandelen 	\N	5
0501030.07	Inkoop van eigen aandelen 	\N	5
0501030.08	Intrekking van aandelen 	\N	5
0501030.14	Dividenduitkeringen 	\N	5
0501030.28	Interim-dividenduitkeringen	\N	5
0501030.16	Emissiekosten	\N	5
0501030.15	Overboekingen 	\N	5
0501030.11	Overige mutaties 	\N	5
0501020.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0501020.02	Uitgifte van aandelen 	\N	5
0501020.06	Verkoop van eigen aandelen 	\N	5
0501020.07	Inkoop van eigen aandelen 	\N	5
0501020.08	Intrekking van aandelen 	\N	5
0501020.14	Dividenduitkeringen 	\N	5
0501020.28	Interim-dividenduitkeringen	\N	5
0501020.16	Emissiekosten	\N	5
0501020.15	Overboekingen 	\N	5
0501020.11	Overige mutaties 	\N	5
0501080.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0501080.02	Uitgifte van aandelen 	\N	5
0501080.06	Verkoop van eigen aandelen 	\N	5
0501080.07	Inkoop van eigen aandelen 	\N	5
0501080.08	Intrekking van aandelen 	\N	5
0501080.14	Dividenduitkeringen 	\N	5
0501080.28	Interim-dividenduitkeringen	\N	5
0501080.16	Emissiekosten	\N	5
0501080.15	Overboekingen 	\N	5
0501080.11	Overige mutaties 	\N	5
0509050.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen	\N	5
0509050.02	Kapitaalmutaties eigen vermogen	\N	5
0509050.03	Kapitaalcorrecties eigen vermogen	\N	5
0509050.04	Overige mutaties eigen vermogen	\N	5
0509060.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen	\N	5
0509060.02	Kapitaalmutaties eigen vermogen	\N	5
0509060.03	Kapitaalcorrecties eigen vermogen	\N	5
0509060.04	Overige mutaties eigen vermogen	\N	5
0509065.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen participatie	\N	5
0509065.02	Kapitaalmutaties eigen vermogen participatie	\N	5
0509065.03	Kapitaalcorrecties eigen vermogen participatie	\N	5
0509065.04	Overige mutaties eigen vermogen participatie	\N	5
0509070.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen	\N	5
0509070.02	Kapitaalmutaties eigen vermogen	\N	5
0509070.03	Kapitaalcorrecties eigen vermogen	\N	5
0509070.04	Overige mutaties eigen vermogen	\N	5
0502010.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0502010.06	Stortingen door aandeelhouders 	\N	5
0502010.07	Aanzuivering van verliezen 	\N	5
0502010.08	Verkoop van eigen aandelen 	\N	5
0502010.09	Inkoop van eigen aandelen 	\N	5
0502010.10	Intrekking van aandelen 	\N	5
0502010.11	Overboekingen 	\N	5
0502010.12	Rechtstreekse mutatie als gevolg van foutherstel 	\N	5
0502010.13	Rechtstreekse mutatie als gevolg van overnames 	\N	5
0502010.14	Rechtstreekse mutatie als gevolg van afstotingen 	\N	5
0502010.15	Overige mutaties 	\N	5
0503010.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0503010.16	Herwaarderingsreserve ongegerealiseerde herwaardering	\N	5
0503010.03	Stelselwijziging (correctie beginbalans)	\N	5
0503010.10	Belastingeffect van stelselwijzigingen (correctie beginbalans)	\N	5
0503010.07	Gerealiseerde herwaarderingen via winst- en verliesrekening 	\N	5
0503010.04	Gerealiseerde herwaarderingen via overige reserves 	\N	5
0503010.05	Gerealiseerde herwaarderingen via afgedekte activa of passiva 	\N	5
0503010.06	Belastingeffecten op gerealiseerde herwaarderingen 	\N	5
0503010.11	Gevormde herwaarderingen via winst- en verliesrekening 	\N	5
0503010.08	Gevormde herwaarderingen via overige reserves 	\N	5
0503010.09	Gevormde herwaarderingen via afgedekt activa of passiva 	\N	5
0503010.12	Belastingeffecten op gevormde herwaarderingen 	\N	5
0503010.15	Overboekingen 	\N	5
0503010.02	Herwaarderingen 	\N	5
0503010.13	Vrijval herwaardering herwaarderingsreserve	\N	5
0503010.14	Overige mutaties 	\N	5
0504010.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0504010.05	Overboekingen 	\N	5
0504010.04	Overige mutaties 	\N	5
0504020.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0504020.04	Overige mutaties 	\N	5
0504030.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0504030.06	Stortingen door aandeelhouders 	\N	5
0504030.07	Aanzuivering van verliezen 	\N	5
0504030.11	Overboekingen 	\N	5
0504030.04	Overige mutaties 	\N	5
0504040.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0504040.05	Uitgifte van aandelen 	\N	5
0504040.06	Stortingen door aandeelhouders 	\N	5
0504040.07	Aanzuivering van verliezen 	\N	5
0504040.08	Verkoop van eigen aandelen 	\N	5
0504040.09	Inkoop van eigen aandelen 	\N	5
0504040.10	Intrekking van aandelen 	\N	5
0504040.23	Dividenduitkeringen 	\N	5
0504040.28	Interim-dividenduitkeringen	\N	5
0504040.11	Overboekingen 	\N	5
0504040.22	Uitgeoefende aandelen(optie)regelingen 	\N	5
0504040.04	Overige mutaties 	\N	5
0504050.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0504050.05	Uitgifte van aandelen 	\N	5
0504050.06	Stortingen door aandeelhouders 	\N	5
0504050.07	Aanzuivering van verliezen 	\N	5
0504050.08	Verkoop van eigen aandelen 	\N	5
0504050.09	Inkoop van eigen aandelen 	\N	5
0504050.10	Intrekking van aandelen 	\N	5
0504050.11	Overboekingen 	\N	5
0504050.12	Herwaarderingen 	\N	5
0504050.13	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	\N	5
0504050.14	Rechtstreekse mutatie als gevolg van foutherstel 	\N	5
0504050.15	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	\N	5
0504050.16	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	\N	5
0504050.17	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	\N	5
0504050.18	Rechtstreekse mutatie als gevolg van overnames 	\N	5
0504050.19	Rechtstreekse mutatie als gevolg van afstotingen 	\N	5
0504050.20	Rechtstreekse mutatie als gevolg van financiële instrumenten 	\N	5
0504050.21	Verleende aandelen(optie) regelingen 	\N	5
0504050.22	Uitgeoefende aandelen(optie)regelingen 	\N	5
0504050.04	Overige mutaties reserve voor geactiveerde kosten van oprichting en uitgifte van aandelen	\N	5
0504060.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0504060.11	Overboekingen 	\N	5
0504060.12	Herwaarderingen 	\N	5
0504060.13	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	\N	5
0504060.14	Rechtstreekse mutatie als gevolg van foutherstel 	\N	5
0504060.15	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	\N	5
0504060.16	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	\N	5
0504060.17	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	\N	5
0504060.18	Rechtstreekse mutatie als gevolg van overnames 	\N	5
0504060.19	Rechtstreekse mutatie als gevolg van afstotingen 	\N	5
0504060.20	Rechtstreekse mutatie als gevolg van financiële instrumenten 	\N	5
0504060.04	Overige mutaties reserve voor geactiveerde kosten van onderzoek en ontwikkeling	\N	5
0504070.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0504070.02	Dotatie reserve deelnemingen	\N	5
0504070.03	Onttrekking reserve deelnemingen	\N	5
0504070.23	Dividenduitkeringen 	\N	5
0504070.28	Interim-dividenduitkeringen	\N	5
0504070.11	Overboekingen 	\N	5
0504070.12	Herwaarderingen 	\N	5
0504070.13	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	\N	5
0504070.14	Rechtstreekse mutatie als gevolg van foutherstel 	\N	5
0504070.15	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	\N	5
0504070.16	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	\N	5
0504070.17	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	\N	5
0504070.18	Rechtstreekse mutatie als gevolg van overnames 	\N	5
0504070.19	Rechtstreekse mutatie als gevolg van afstotingen 	\N	5
0504070.20	Rechtstreekse mutatie als gevolg van financiële instrumenten 	\N	5
0504070.04	Overige mutaties reserve deelnemingen	\N	5
0504080.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0504080.02	Dotatie reserve voor omrekeningsverschillen	\N	5
0504080.03	Onttrekking reserve voor omrekeningsverschillen	\N	5
0504080.15	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	\N	5
0504080.04	Overige mutaties 	\N	5
0504090.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0504090.12	Herwaarderingen 	\N	5
0504090.13	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	\N	5
0504090.14	Rechtstreekse mutatie als gevolg van foutherstel 	\N	5
0504090.15	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	\N	5
0504090.16	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	\N	5
0504090.17	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	\N	5
0504090.04	Overige mutaties 	\N	5
0505030.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0505030.05	Aanzuivering van verliezen 	\N	5
0505030.06	Dividenduitkeringen 	\N	5
0505030.28	Interim-dividenduitkeringen	\N	5
0505030.07	Overboekingen 	\N	5
0505030.08	Allocatie van het resultaat 	\N	5
0505030.09	Rechtstreekse mutatie als gevolg van foutherstel 	\N	5
0505030.04	Overige mutaties statutaire reserve	\N	5
0507020.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0507020.02	Toevoegingen aan het bestemmingsfonds 	\N	5
0507020.03	Onttrekkingen aan het bestemmingsfonds 	\N	5
0505020.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0505020.02	Toevoegingen aan de bestemmingsreserve 	\N	5
0505020.03	Onttrekkingen aan de bestemmingsreserve 	\N	5
0507110.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0507110.07	Overboekingen 	\N	5
0507110.04	Overige mutaties statutaire reserve	\N	5
0506001.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0506001.26	Stelselwijziging (correctie beginbalans)	\N	5
0506001.05	Uitgifte van aandelen 	\N	5
0506001.06	Stortingen door aandeelhouders 	\N	5
0506001.07	Aanzuivering van verliezen 	\N	5
0506001.08	Verkoop van eigen aandelen 	\N	5
0506001.09	Inkoop van eigen aandelen 	\N	5
0506001.10	Intrekking van aandelen 	\N	5
0506001.25	Dividenduitkeringen 	\N	5
0506001.28	Interim-dividenduitkeringen 	\N	5
0506001.27	Emissiekosten	\N	5
0506001.11	Overboekingen 	\N	5
0506001.03	Allocatie van het resultaat 	\N	5
0506001.12	Herwaarderingen 	\N	5
0506001.13	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	\N	5
0506001.14	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	\N	5
0506001.15	Rechtstreekse mutatie als gevolg van foutherstel 	\N	5
0506001.16	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	\N	5
0506001.17	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	\N	5
0506001.18	Rechtstreekse mutatie als gevolg van goodwill 	\N	5
0506001.19	Rechtstreekse mutatie als gevolg van overnames 	\N	5
0506001.20	Rechtstreekse mutatie als gevolg van afstotingen 	\N	5
0506001.21	Rechtstreekse mutatie als gevolg van financiële instrumenten 	\N	5
0506001.22	Verleende aandelen(optie) regelingen 	\N	5
0506001.23	Uitgeoefende aandelen(optie)regelingen 	\N	5
0506001.24	Overige mutaties 	\N	5
0506005.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0506005.26	Stelselwijziging (correctie beginbalans)	\N	5
0506005.05	Uitgifte van aandelen 	\N	5
0506005.06	Stortingen door aandeelhouders 	\N	5
0506005.07	Aanzuivering van verliezen 	\N	5
0506005.08	Verkoop van eigen aandelen 	\N	5
0506005.09	Inkoop van eigen aandelen 	\N	5
0506005.10	Intrekking van aandelen 	\N	5
0506005.25	Dividenduitkeringen 	\N	5
0506005.28	Interim-dividenduitkeringen 	\N	5
0506005.27	Emissiekosten	\N	5
0506005.11	Overboekingen 	\N	5
0506005.03	Allocatie van het resultaat 	\N	5
0506005.12	Herwaarderingen 	\N	5
0506005.13	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	\N	5
0506005.14	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	\N	5
0506005.15	Rechtstreekse mutatie als gevolg van foutherstel 	\N	5
0506005.16	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	\N	5
0506005.17	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	\N	5
0506005.18	Rechtstreekse mutatie als gevolg van goodwill 	\N	5
0506005.19	Rechtstreekse mutatie als gevolg van overnames 	\N	5
0506005.20	Rechtstreekse mutatie als gevolg van afstotingen 	\N	5
0506005.21	Rechtstreekse mutatie als gevolg van financiële instrumenten 	\N	5
0506005.22	Verleende aandelen(optie) regelingen 	\N	5
0506005.23	Uitgeoefende aandelen(optie)regelingen 	\N	5
0506005.24	Overige mutaties 	\N	5
0506006.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0506006.02	Toevoegingen aan reserves en fondsen	\N	5
0506006.03	Onttrekkingen uit reserves en fondsen	\N	5
0506006.04	Vrijval van reserves en fondsen	\N	5
0506006.05	Overboekingen van reserves en fondsen	\N	5
0506006.06	Herwaarderingen 	\N	5
0506006.07	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	\N	5
0506006.08	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	\N	5
0506006.09	Rechtstreekse mutatie als gevolg van foutherstel 	\N	5
0506006.10	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	\N	5
0506006.11	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	\N	5
0506006.12	Rechtstreekse mutatie als gevolg van financiële instrumenten 	\N	5
0506006.13	Overige mutaties 	\N	5
0506010.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0506010.26	Stelselwijziging (correctie beginbalans)	\N	5
0506010.02	Dividenduitkeringen 	\N	5
0506010.28	Interim-dividenduitkeringen	\N	5
0506010.03	Overboekingen 	\N	5
0506010.04	Allocatie van het resultaat 	\N	5
0506010.25	Herwaarderingen 	\N	5
0506010.05	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	\N	5
0506010.09	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	\N	5
0506010.06	Rechtstreekse mutatie als gevolg van foutherstel 	\N	5
0506010.07	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	\N	5
0506010.08	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	\N	5
0506010.10	Rechtstreekse mutatie als gevolg van goodwill 	\N	5
0506010.11	Rechtstreekse mutatie als gevolg van overnames 	\N	5
0506010.12	Rechtstreekse mutatie als gevolg van afstotingen 	\N	5
0506010.13	Rechtstreekse mutatie als gevolg van financiële instrumenten 	\N	5
0506010.14	Overige mutaties 	\N	5
0506020.01	Beginbalans resultaat van het boekjaar	\N	5
0506020.02	Dividenduitkeringen 	\N	5
0506020.28	Interim-dividenduitkeringen	\N	5
0506020.03	Overboekingen 	\N	5
0506020.04	Allocatie van het resultaat 	\N	5
0506020.25	Herwaarderingen 	\N	5
0506020.05	Rechtstreekse mutatie als gevolg van stelselwijzigingen 	\N	5
0506020.09	Rechtstreekse mutatie als gevolg van terugneming van bijzondere waardeverminderingen 	\N	5
0506020.06	Rechtstreekse mutatie als gevolg van foutherstel 	\N	5
0506020.07	Rechtstreekse mutatie als gevolg van omrekeningsverschillen 	\N	5
0506020.08	Rechtstreekse mutatie als gevolg van bijzondere waardeverminderingen 	\N	5
0506020.10	Rechtstreekse mutatie als gevolg van goodwill 	\N	5
0506020.11	Rechtstreekse mutatie als gevolg van overnames 	\N	5
0506020.12	Rechtstreekse mutatie als gevolg van afstotingen 	\N	5
0506020.13	Rechtstreekse mutatie als gevolg van financiële instrumenten 	\N	5
0506020.14	Overige mutaties 	\N	5
0506030.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0506030.02	Dividenduitkeringen 	\N	5
0506030.28	Interim-dividenduitkeringen	\N	5
0506030.03	Overboekingen 	\N	5
0506030.04	Allocatie van het resultaat 	\N	5
0506030.14	Overige mutaties 	\N	5
0506040.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0506040.02	Dividenduitkeringen 	\N	5
0506040.28	Interim-dividenduitkeringen	\N	5
0506040.03	Overboekingen 	\N	5
0506040.04	Allocatie van het resultaat 	\N	5
0506040.14	Overige mutaties 	\N	5
0509010.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	\N	5
0509020.02	Rente geïnvesteerd vermogen eigen vermogen onderneming natuurlijke personen	\N	5
0509020.03	Arbeidsvergoeding  eigen vermogen onderneming natuurlijke personen	\N	5
0509020.04	Vergoeding buitenvennootschappelijk vermogen eigen vermogen onderneming natuurlijke personen	\N	5
0509020.05	Aandeel in de overwinst eigen vermogen onderneming natuurlijke personen	\N	5
0509020.06	Overige mutaties eigen vermogen onderneming natuurlijke personen	\N	5
0509030.02	Privé-storting kapitaal  eigen vermogen onderneming natuurlijke personen	\N	5
0509030.03	Ontvangen schenkingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509030.04	Ontvangen loon, uitkeringen of pensioenen  eigen vermogen onderneming natuurlijke personen	\N	5
0509030.05	Ontvangen toeslagen en toelagen  eigen vermogen onderneming natuurlijke personen	\N	5
0509030.06	Ontvangen kostenvergoedingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509030.07	Opname privé-financieringen  eigen vermogen onderneming natuurlijke personen	\N	5
0509030.08	Opname privé-spaargelden  eigen vermogen onderneming natuurlijke personen	\N	5
0509030.09	Verkoop privé-bezittingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509030.10	Privé-betaalde zakelijke lasten  eigen vermogen onderneming natuurlijke personen	\N	5
0509030.11	Overige privé-stortingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509040.02	Privé-opname kapitaal eigen vermogen onderneming natuurlijke personen	\N	5
0509040.03	Privé-gebruik materiële vaste activa eigen vermogen onderneming natuurlijke personen	\N	5
0509040.04	Privé-verbruik goederen eigen vermogen onderneming natuurlijke personen	\N	5
0509040.05	Privé-aandeel in zakelijke lasten eigen vermogen onderneming natuurlijke personen	\N	5
0509040.06	Privé-premies eigen vermogen onderneming natuurlijke personen	\N	5
0509040.07	Privé-belastingen eigen vermogen onderneming natuurlijke personen	\N	5
0509040.08	Privé-aflossingen en rente eigen vermogen onderneming natuurlijke personen	\N	5
0509040.09	Privé-aftrekbare kosten eigen vermogen onderneming natuurlijke personen	\N	5
0509040.10	Dotatie Fiscale Oudedags Reserve eigen vermogen onderneming natuurlijke personen	\N	5
0509040.11	Overige privé-opnamen eigen vermogen onderneming natuurlijke personen	\N	5
0509110.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	\N	5
0509120.02	Rente geïnvesteerd vermogen  eigen vermogen onderneming natuurlijke personen	\N	5
0509120.03	Arbeidsvergoeding  eigen vermogen onderneming natuurlijke personen	\N	5
0509120.04	Vergoeding buitenvennootschappelijk vermogen  eigen vermogen onderneming natuurlijke personen	\N	5
0509120.05	Aandeel in de overwinst  eigen vermogen onderneming natuurlijke personen	\N	5
0509120.06	Overige mutaties eigen vermogen onderneming natuurlijke personen	\N	5
0509130.02	Privé-storting kapitaal  eigen vermogen onderneming natuurlijke personen	\N	5
0509130.03	Ontvangen schenkingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509130.04	Ontvangen loon, uitkeringen of pensioenen  eigen vermogen onderneming natuurlijke personen	\N	5
0509130.05	Ontvangen toeslagen en toelagen  eigen vermogen onderneming natuurlijke personen	\N	5
0509130.06	Ontvangen kostenvergoedingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509130.07	Opname privé-financieringen  eigen vermogen onderneming natuurlijke personen	\N	5
0509130.08	Opname privé-spaargelden  eigen vermogen onderneming natuurlijke personen	\N	5
0509130.09	Verkoop privé-bezittingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509130.10	Privé-betaalde zakelijke lasten  eigen vermogen onderneming natuurlijke personen	\N	5
0509130.11	Overige privé-stortingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509140.02	Privé-opname kapitaal  eigen vermogen onderneming natuurlijke personen	\N	5
0509140.03	Privé-gebruik materiële vaste activa  eigen vermogen onderneming natuurlijke personen	\N	5
0509140.04	Privé-verbruik goederen  eigen vermogen onderneming natuurlijke personen	\N	5
0509140.05	Privé-aandeel in zakelijke lasten  eigen vermogen onderneming natuurlijke personen	\N	5
0509140.06	Privé-premies  eigen vermogen onderneming natuurlijke personen	\N	5
0509140.07	Privé-belastingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509140.08	Privé-aflossingen en rente  eigen vermogen onderneming natuurlijke personen	\N	5
0509140.09	Privé-aftrekbare kosten  eigen vermogen onderneming natuurlijke personen	\N	5
0509140.10	Dotatie Fiscale Oudedags Reserve  eigen vermogen onderneming natuurlijke personen	\N	5
0509140.11	Overige privé-opnamen  eigen vermogen onderneming natuurlijke personen	\N	5
0509210.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	\N	5
0509220.02	Rente geïnvesteerd vermogen  eigen vermogen onderneming natuurlijke personen	\N	5
0509220.03	Arbeidsvergoeding  eigen vermogen onderneming natuurlijke personen	\N	5
0509220.04	Vergoeding buitenvennootschappelijk vermogen  eigen vermogen onderneming natuurlijke personen	\N	5
0509220.05	Aandeel in de overwinst  eigen vermogen onderneming natuurlijke personen	\N	5
0509220.06	Overige mutaties eigen vermogen onderneming natuurlijke personen	\N	5
0509230.02	Privé-storting kapitaal  eigen vermogen onderneming natuurlijke personen	\N	5
0509230.03	Ontvangen schenkingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509230.04	Ontvangen loon, uitkeringen of pensioenen  eigen vermogen onderneming natuurlijke personen	\N	5
0509230.05	Ontvangen toeslagen en toelagen  eigen vermogen onderneming natuurlijke personen	\N	5
0509230.06	Ontvangen kostenvergoedingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509230.07	Opname privé-financieringen  eigen vermogen onderneming natuurlijke personen	\N	5
0509230.08	Opname privé-spaargelden  eigen vermogen onderneming natuurlijke personen	\N	5
0509230.09	Verkoop privé-bezittingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509230.10	Privé-betaalde zakelijke lasten  eigen vermogen onderneming natuurlijke personen	\N	5
0509230.11	Overige privé-stortingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509240.02	Privé-opname kapitaal  eigen vermogen onderneming natuurlijke personen	\N	5
0509240.03	Privé-gebruik materiële vaste activa  eigen vermogen onderneming natuurlijke personen	\N	5
0509240.04	Privé-verbruik goederen  eigen vermogen onderneming natuurlijke personen	\N	5
0509240.05	Privé-aandeel in zakelijke lasten  eigen vermogen onderneming natuurlijke personen	\N	5
0509240.06	Privé-premies  eigen vermogen onderneming natuurlijke personen	\N	5
0509240.07	Privé-belastingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509240.08	Privé-aflossingen en rente  eigen vermogen onderneming natuurlijke personen	\N	5
0509240.09	Privé-aftrekbare kosten  eigen vermogen onderneming natuurlijke personen	\N	5
0509240.10	Dotatie Fiscale Oudedags Reserve  eigen vermogen onderneming natuurlijke personen	\N	5
0509240.11	Overige privé-opnamen  eigen vermogen onderneming natuurlijke personen	\N	5
0509310.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	\N	5
0509320.02	Rente geïnvesteerd vermogen  eigen vermogen onderneming natuurlijke personen	\N	5
0509320.03	Arbeidsvergoeding  eigen vermogen onderneming natuurlijke personen	\N	5
0509320.04	Vergoeding buitenvennootschappelijk vermogen  eigen vermogen onderneming natuurlijke personen	\N	5
0509320.05	Aandeel in de overwinst  eigen vermogen onderneming natuurlijke personen	\N	5
0509320.06	Overige mutaties eigen vermogen onderneming natuurlijke personen	\N	5
0509330.02	Privé-storting kapitaal  eigen vermogen onderneming natuurlijke personen	\N	5
0509330.03	Ontvangen schenkingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509330.04	Ontvangen loon, uitkeringen of pensioenen  eigen vermogen onderneming natuurlijke personen	\N	5
0509330.05	Ontvangen toeslagen en toelagen  eigen vermogen onderneming natuurlijke personen	\N	5
0509330.06	Ontvangen kostenvergoedingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509330.07	Opname privé-financieringen  eigen vermogen onderneming natuurlijke personen	\N	5
0509330.08	Opname privé-spaargelden  eigen vermogen onderneming natuurlijke personen	\N	5
0509330.09	Verkoop privé-bezittingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509330.10	Privé-betaalde zakelijke lasten  eigen vermogen onderneming natuurlijke personen	\N	5
0509330.11	Overige privé-stortingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509340.02	Privé-opname kapitaal  eigen vermogen onderneming natuurlijke personen	\N	5
0510040.02	Dotatie eigen vermogen onderneming natuurlijke personen	\N	5
0509340.03	Privé-gebruik materiële vaste activa  eigen vermogen onderneming natuurlijke personen	\N	5
0509340.04	Privé-verbruik goederen  eigen vermogen onderneming natuurlijke personen	\N	5
0509340.05	Privé-aandeel in zakelijke lasten  eigen vermogen onderneming natuurlijke personen	\N	5
0509340.06	Privé-premies  eigen vermogen onderneming natuurlijke personen	\N	5
0509340.07	Privé-belastingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509340.08	Privé-aflossingen en rente  eigen vermogen onderneming natuurlijke personen	\N	5
0509340.09	Privé-aftrekbare kosten  eigen vermogen onderneming natuurlijke personen	\N	5
0509340.10	Dotatie Fiscale Oudedags Reserve  eigen vermogen onderneming natuurlijke personen	\N	5
0509340.11	Overige privé-opnamen  eigen vermogen onderneming natuurlijke personen	\N	5
0509410.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	\N	5
0509420.02	Rente geïnvesteerd vermogen  eigen vermogen onderneming natuurlijke personen	\N	5
0509420.03	Arbeidsvergoeding  eigen vermogen onderneming natuurlijke personen	\N	5
0509420.04	Vergoeding buitenvennootschappelijk vermogen  eigen vermogen onderneming natuurlijke personen	\N	5
0509420.05	Aandeel in de overwinst  eigen vermogen onderneming natuurlijke personen	\N	5
0509420.06	Overige mutaties eigen vermogen onderneming natuurlijke personen	\N	5
0509430.02	Privé-storting kapitaal  eigen vermogen onderneming natuurlijke personen	\N	5
0509430.03	Ontvangen schenkingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509430.04	Ontvangen loon, uitkeringen of pensioenen  eigen vermogen onderneming natuurlijke personen	\N	5
0509430.05	Ontvangen toeslagen en toelagen  eigen vermogen onderneming natuurlijke personen	\N	5
0509430.06	Ontvangen kostenvergoedingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509430.07	Opname privé-financieringen  eigen vermogen onderneming natuurlijke personen	\N	5
0509430.08	Opname privé-spaargelden  eigen vermogen onderneming natuurlijke personen	\N	5
0509430.09	Verkoop privé-bezittingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509430.10	Privé-betaalde zakelijke lasten  eigen vermogen onderneming natuurlijke personen	\N	5
0509430.11	Overige privé-stortingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509440.02	Privé-opname kapitaal  eigen vermogen onderneming natuurlijke personen	\N	5
0509440.03	Privé-gebruik materiële vaste activa  eigen vermogen onderneming natuurlijke personen	\N	5
0509440.04	Privé-verbruik goederen  eigen vermogen onderneming natuurlijke personen	\N	5
0509440.05	Privé-aandeel in zakelijke lasten  eigen vermogen onderneming natuurlijke personen	\N	5
0509440.06	Privé-premies  eigen vermogen onderneming natuurlijke personen	\N	5
0509440.07	Privé-belastingen  eigen vermogen onderneming natuurlijke personen	\N	5
0509440.08	Privé-aflossingen en rente  eigen vermogen onderneming natuurlijke personen	\N	5
0509440.09	Privé-aftrekbare kosten  eigen vermogen onderneming natuurlijke personen	\N	5
0509440.10	Dotatie Fiscale Oudedags Reserve  eigen vermogen onderneming natuurlijke personen	\N	5
8016100.11	Rioolheffing	\N	5
0509440.11	Overige privé-opnamen  eigen vermogen onderneming natuurlijke personen	\N	5
0509080.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	\N	5
0509080.02	Kapitaalmutaties eigen vermogen onderneming natuurlijke personen	\N	5
0509080.03	Kapitaalcorrecties eigen vermogen onderneming natuurlijke personen	\N	5
0509080.04	Overige mutaties eigen vermogen onderneming natuurlijke personen	\N	5
0510050.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	\N	5
0510050.02	Dotatie eigen vermogen onderneming natuurlijke personen	\N	5
0510050.03	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	\N	5
0510050.04	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	\N	5
0510050.05	Overboekingen eigen vermogen onderneming natuurlijke personen	\N	5
0510050.06	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	\N	5
0510050.07	Overige mutaties eigen vermogen onderneming natuurlijke personen	\N	5
0510020.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen	\N	5
0510020.02	Dotatie eigen vermogen	\N	5
0510020.03	Afname ten gunste van het resultaat eigen vermogen	\N	5
0510020.07	Kosten ten laste van reserve eigen vermogen	\N	5
0510020.04	Overboekingen eigen vermogen	\N	5
0510020.05	Valutaomrekeningsverschillen eigen vermogen	\N	5
0510020.06	Overige mutaties eigen vermogen	\N	5
0510010.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	\N	5
0510010.02	Dotatie eigen vermogen onderneming natuurlijke personen	\N	5
0510010.08	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	\N	5
0510010.07	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	\N	5
0510010.03	Overboekingen eigen vermogen onderneming natuurlijke personen	\N	5
0510010.09	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	\N	5
0510010.04	Overige mutaties eigen vermogen onderneming natuurlijke personen	\N	5
0510030.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	\N	5
0510030.02	Dotatie eigen vermogen onderneming natuurlijke personen	\N	5
0510030.08	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	\N	5
0510030.03	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	\N	5
0510030.04	Overboekingen eigen vermogen onderneming natuurlijke personen	\N	5
0510030.05	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	\N	5
0510030.06	Overige mutaties eigen vermogen onderneming natuurlijke personen	\N	5
0510040.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	\N	5
0510040.03	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	\N	5
0510040.04	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	\N	5
0510040.05	Overboekingen eigen vermogen onderneming natuurlijke personen	\N	5
0510040.06	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	\N	5
0510040.07	Overige mutaties eigen vermogen onderneming natuurlijke personen	\N	5
0510060.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	\N	5
0510060.02	Dotatie eigen vermogen onderneming natuurlijke personen	\N	5
0510060.03	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	\N	5
7203300.06	Communicatiekosten	\N	5
0510060.04	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	\N	5
0510060.05	Overboekingen eigen vermogen onderneming natuurlijke personen	\N	5
0510060.06	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	\N	5
0510060.07	Overige mutaties eigen vermogen onderneming natuurlijke personen	\N	5
0510070.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	\N	5
0510070.02	Dotatie eigen vermogen onderneming natuurlijke personen	\N	5
0510070.03	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	\N	5
0510070.04	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	\N	5
0510070.05	Overboekingen eigen vermogen onderneming natuurlijke personen	\N	5
0510070.06	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	\N	5
0510070.07	Overige mutaties eigen vermogen onderneming natuurlijke personen	\N	5
0510080.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	\N	5
0510080.02	Dotatie eigen vermogen onderneming natuurlijke personen	\N	5
0510080.03	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	\N	5
0510080.04	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	\N	5
0510080.05	Overboekingen eigen vermogen onderneming natuurlijke personen	\N	5
0510080.06	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	\N	5
0510080.07	Overige mutaties eigen vermogen onderneming natuurlijke personen	\N	5
0510090.01	Beginbalans (overname eindsaldo vorig jaar) eigen vermogen onderneming natuurlijke personen	\N	5
0510090.02	Dotatie eigen vermogen onderneming natuurlijke personen	\N	5
0510090.03	Afname ten gunste van het resultaat eigen vermogen onderneming natuurlijke personen	\N	5
0510090.04	Kosten ten laste van reserve eigen vermogen onderneming natuurlijke personen	\N	5
0510090.05	Overboekingen eigen vermogen onderneming natuurlijke personen	\N	5
0510090.06	Valutaomrekeningsverschillen eigen vermogen onderneming natuurlijke personen	\N	5
0510090.07	Overige mutaties eigen vermogen onderneming natuurlijke personen	\N	5
0601010.01	Beginbalans egalisatierekening	\N	5
0601010.02	Dotatie egalisatierekening	\N	5
0601010.03	Onttrekking egalisatierekening	\N	5
0601010.04	Overige mutaties egalisatierekening	\N	5
0701010.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0701010.02	Toevoegingen aan voorzieningen 	\N	5
0701010.03	Gebruik van voorzieningen 	\N	5
0701010.04	Vrijval van voorziening 	\N	5
0701010.05	Omrekeningsverschillen over voorzieningen 	\N	5
0701010.06	Oprenting van voorzieningen 	\N	5
0701020.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0701020.02	Toevoegingen aan voorzieningen 	\N	5
0701020.03	Gebruik van voorzieningen 	\N	5
0701020.04	Vrijval van voorziening 	\N	5
0701020.05	Omrekeningsverschillen over voorzieningen 	\N	5
0701020.06	Oprenting van voorzieningen 	\N	5
0702010.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0702010.02	Toevoegingen aan voorzieningen 	\N	5
0702010.03	Gebruik van voorzieningen 	\N	5
0702010.04	Vrijval van voorziening 	\N	5
0702010.05	Omrekeningsverschillen over voorzieningen 	\N	5
0702010.06	Oprenting van voorzieningen 	\N	5
0702010.07	Overige mutaties voorziening latente belastingverplichtingen	\N	5
0702020.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0702020.02	Toevoegingen aan voorzieningen 	\N	5
0702020.03	Gebruik van voorzieningen 	\N	5
0702020.04	Vrijval van voorziening 	\N	5
0702020.05	Omrekeningsverschillen over voorzieningen 	\N	5
0702020.06	Oprenting van voorzieningen 	\N	5
0704020.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704020.02	Toevoegingen aan voorzieningen 	\N	5
0704020.03	Gebruik van voorzieningen 	\N	5
0704020.04	Vrijval van voorziening 	\N	5
0704020.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704020.06	Oprenting van voorzieningen 	\N	5
0704030.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704030.02	Toevoegingen aan voorzieningen 	\N	5
0704030.03	Gebruik van voorzieningen 	\N	5
0704030.04	Vrijval van voorziening 	\N	5
0704030.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704030.06	Oprenting van voorzieningen 	\N	5
0704040.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704040.02	Toevoegingen aan voorzieningen 	\N	5
0704040.03	Gebruik van voorzieningen 	\N	5
0704040.04	Vrijval van voorziening 	\N	5
0704040.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704040.06	Oprenting van voorzieningen 	\N	5
0703010.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0703010.02	Toevoegingen aan voorzieningen 	\N	5
0703010.03	Gebruik van voorzieningen 	\N	5
0703010.04	Vrijval van voorziening 	\N	5
0703010.05	Omrekeningsverschillen over voorzieningen 	\N	5
0703010.06	Oprenting van voorzieningen 	\N	5
0704050.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704050.02	Toevoegingen aan voorzieningen 	\N	5
0704050.03	Gebruik van voorzieningen 	\N	5
0704050.04	Vrijval van voorziening 	\N	5
0704050.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704060.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704060.02	Toevoegingen aan voorzieningen 	\N	5
0704060.03	Gebruik van voorzieningen 	\N	5
0704060.04	Vrijval van voorziening 	\N	5
0704060.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704060.06	Oprenting van voorzieningen 	\N	5
0704070.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704070.02	Toevoegingen aan voorzieningen 	\N	5
0704070.03	Gebruik van voorzieningen 	\N	5
0704070.04	Vrijval van voorziening 	\N	5
0704070.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704070.06	Oprenting van voorzieningen 	\N	5
0704080.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704080.02	Toevoegingen aan voorzieningen 	\N	5
0704080.03	Gebruik van voorzieningen 	\N	5
0704080.04	Vrijval van voorziening 	\N	5
0704080.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704080.06	Oprenting van voorzieningen 	\N	5
0704080.07	Overige mutatie voorziening deelneming	\N	5
0704010.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704010.02	Toevoegingen aan voorzieningen 	\N	5
0704010.03	Gebruik van voorzieningen 	\N	5
0704010.04	Vrijval van voorziening 	\N	5
0704010.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704010.06	Oprenting van voorzieningen 	\N	5
0704090.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704090.02	Toevoegingen aan voorzieningen 	\N	5
0704090.03	Gebruik van voorzieningen 	\N	5
0704090.04	Vrijval van voorziening 	\N	5
0704090.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704090.06	Oprenting van voorzieningen 	\N	5
0704100.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704100.02	Toevoegingen aan voorzieningen 	\N	5
0704100.03	Gebruik van voorzieningen 	\N	5
0704100.04	Vrijval van voorziening 	\N	5
0704100.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704100.06	Oprenting van voorzieningen 	\N	5
0704120.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704120.02	Toevoegingen aan voorzieningen 	\N	5
0704120.03	Gebruik van voorzieningen 	\N	5
0704120.04	Vrijval van voorziening 	\N	5
0704120.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704120.06	Oprenting van voorzieningen 	\N	5
0704120.07	Overige mutaties 	\N	5
0704140.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704140.02	Toevoegingen aan voorzieningen 	\N	5
0704140.03	Onttrekking van voorzieningen	\N	5
0704140.04	Vrijval van voorziening 	\N	5
0704140.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704140.06	Oprenting van voorzieningen 	\N	5
0704140.07	Overige mutaties 	\N	5
0704150.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704150.02	Toevoegingen aan voorzieningen 	\N	5
0704150.03	Onttrekking van voorzieningen	\N	5
0704150.04	Vrijval van voorziening 	\N	5
0704150.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704150.06	Oprenting van voorzieningen 	\N	5
0704150.07	Overige mutaties 	\N	5
0704160.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704160.02	Toevoegingen aan voorzieningen 	\N	5
0704160.03	Onttrekking van voorzieningen	\N	5
0704160.04	Vrijval van voorziening 	\N	5
0704160.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704160.06	Oprenting van voorzieningen 	\N	5
0704170.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704170.02	Toevoegingen aan voorzieningen 	\N	5
0704170.03	Gebruik van voorzieningen 	\N	5
0704170.04	Vrijval van voorziening 	\N	5
0704170.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704170.06	Oprenting van voorzieningen 	\N	5
0704180.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704180.02	Toevoegingen aan voorzieningen 	\N	5
0704180.03	Gebruik van voorzieningen 	\N	5
0704180.04	Vrijval van voorziening 	\N	5
0704180.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704180.06	Oprenting van voorzieningen 	\N	5
0704190.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704190.02	Toevoegingen aan voorzieningen 	\N	5
0704190.03	Gebruik van voorzieningen 	\N	5
0704190.04	Vrijval van voorziening 	\N	5
0704190.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704190.06	Oprenting van voorzieningen 	\N	5
0704191.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704191.02	Toevoegingen aan voorzieningen 	\N	5
0704191.03	Gebruik van voorzieningen 	\N	5
0704191.04	Vrijval van voorziening 	\N	5
0704191.05	Omrekeningsverschillen over voorzieningen 	\N	5
0704191.06	Oprenting van voorzieningen 	\N	5
0704176.01	Beginbalans (overname eindsaldo vorig jaar)	\N	5
0704176.02	Toevoegingen aan voorzieningen ten laste van het resultaat	\N	5
0704176.04	Onttrekking van voorzieningen	\N	5
0704176.05	Vrijval van voorziening	\N	5
0704176.07	Oprenting van voorzieningen	\N	5
0704175.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0704175.02	Toevoegingen aan voorzieningen ten laste van het resultaat	\N	5
0704175.03	Toevoegingen aan voorzieningen ten laste van het eigen vermogen	\N	5
0704175.04	Onttrekking van voorzieningen	\N	5
0704175.05	Vrijval van voorziening 	\N	5
0704175.06	Omrekeningsverschillen over voorzieningen 	\N	5
0704175.07	Oprenting van voorzieningen 	\N	5
0801010.01	Beginbalans (overname eindsaldo vorig jaar) achtergestelde schulden	\N	5
0801010.03	Aanvullend opgenomen achtergestelde schulden	\N	5
0801010.10	Bij overname verkregen schulden achtergestelde schulden	\N	5
0801010.11	Bij afstoting vervreemde schulden achtergestelde schulden	\N	5
0801010.08	Bijschrijving rente achtergestelde schulden	\N	5
0801010.06	Omrekeningsverschillen achtergestelde schulden	\N	5
0801010.07	Overige mutaties achtergestelde schulden	\N	5
0801010.12	Overige waardeveranderingen achtergestelde schulden	\N	5
0801020.01	Aflossingen beginbalans (overname eindsaldo vorig jaar) achtergestelde schulden	\N	5
0801020.02	Aflossingen in boekjaar achtergestelde schulden	\N	5
0801020.05	Aflossingsverplichting (overboeking naar kortlopend) achtergestelde schulden	\N	5
0802010.01	Beginbalans (overname eindsaldo vorig jaar) converteerbare leningen	\N	5
0802010.03	Aanvullend opgenomen converteerbare leningen	\N	5
0802010.10	Bij overname verkregen schulden	\N	5
0802010.11	Bij afstoting vervreemde schulden	\N	5
0802010.08	Bijschrijving rente converteerbare leningen	\N	5
0802010.06	Omrekeningsverschillen converteerbare leningen	\N	5
0802010.07	Overige mutaties converteerbare leningen	\N	5
0802010.12	Overige waardeveranderingen	\N	5
0802020.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	\N	5
0802020.02	Aflossingen in boekjaar converteerbare leningen (langlopend)	\N	5
0802020.05	Aflossingsverplichting (overboeking naar kortlopend) converteerbare leningen (langlopend)	\N	5
0803010.01	Beginbalans (overname eindsaldo vorig jaar) andere obligaties en onderhandse leningen	\N	5
0803010.03	Aanvullend opgenomen andere obligaties en onderhandse leningen	\N	5
0803010.10	Bij overname verkregen schulden	\N	5
0803010.11	Bij afstoting vervreemde schulden	\N	5
0803010.08	Bijschrijving rente / oprenting andere obligaties en onderhandse leningen	\N	5
0803010.06	Omrekeningsverschillen andere obligaties en onderhandse leningen	\N	5
0803010.07	Overige mutaties andere obligaties en onderhandse leningen	\N	5
0803010.12	Overige waardeveranderingen	\N	5
0803020.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	\N	5
0803020.02	Aflossingen in boekjaar andere obligaties en onderhandse leningen (langlopend)	\N	5
4001090.02	Jubileumuitkering	\N	5
0803020.05	Aflossingsverplichting (overboeking naar kortlopend) andere obligaties en onderhandse leningen (langlopend)	\N	5
0804010.01	Beginbalans (overname eindsaldo vorig jaar) financiële lease verplichtingen	\N	5
0804010.03	Aanvullend opgenomen financiële lease verplichtingen	\N	5
0804010.10	Bij overname verkregen schulden financiële lease verplichtingen	\N	5
0804010.11	Bij afstoting vervreemde schulden financiële lease verplichtingen	\N	5
0804010.08	Bijschrijving rente / oprenting financiële lease verplichtingen	\N	5
0804010.06	Omrekeningsverschillen financiële lease verplichtingen	\N	5
0804010.07	Overige mutaties financiële lease verplichtingen	\N	5
0804010.12	Overige waardeveranderingen financiële lease verplichtingen	\N	5
0804020.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	\N	5
0804020.02	Aflossingen in boekjaar financiële lease verplichtingen (langlopend)	\N	5
0804020.05	Aflossingsverplichting (overboeking naar kortlopend) financiële lease verplichtingen (langlopend)	\N	5
0805010.01	Beginbalans hypotheken van kredietinstellingen (langlopend)	\N	5
0805010.03	Toename hypotheken van kredietinstellingen (langlopend)	\N	5
0805010.10	Bij overname verkregen schulden hypotheken van kredietinstellingen (langlopend)	\N	5
0805010.11	Bij afstoting vervreemde schulden hypotheken van kredietinstellingen (langlopend)	\N	5
0805010.08	Bijschrijving rente / oprenting hypotheken van kredietinstellingen (langlopend)	\N	5
0805010.06	Omrekeningsverschillen hypotheken van kredietinstellingen (langlopend)	\N	5
0805010.07	Overige mutaties hypotheken van kredietinstellingen (langlopend)	\N	5
0805010.12	Overige waardeveranderingen hypotheken van kredietinstellingen (langlopend)	\N	5
0805015.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	\N	5
0805015.04	Aflossingen in boekjaar hypotheken van kredietinstellingen (langlopend)	\N	5
0805015.05	Aflossingsverplichting (overboeking naar kortlopend) hypotheken van kredietinstellingen (langlopend)	\N	5
0805020.01	Beginbalans financieringen van kredietinstellingen (langlopend)	\N	5
0805020.03	Toename financieringen van kredietinstellingen (langlopend)	\N	5
0805020.10	Bij overname verkregen schulden financieringen van kredietinstellingen (langlopend)	\N	5
0805020.11	Bij afstoting vervreemde schulden financieringen van kredietinstellingen (langlopend)	\N	5
0805020.08	Bijschrijving rente / oprenting financieringen van kredietinstellingen (langlopend)	\N	5
0805020.06	Omrekeningsverschillen financieringen van kredietinstellingen (langlopend)	\N	5
0805020.07	Overige mutaties financieringen van kredietinstellingen (langlopend)	\N	5
0805020.12	Overige waardeveranderingen hypotheken van kredietinstellingen (langlopend)	\N	5
0805025.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	\N	5
0805025.04	Aflossingen in boekjaar financieringen van kredietinstellingen (langlopend)	\N	5
0805025.05	Aflossingsverplichting (overboeking naar kortlopend) financieringen van kredietinstellingen (langlopend)	\N	5
0805030.01	Beginbalans leningen van kredietinstellingen (langlopend)	\N	5
0805030.03	Toename leningen van kredietinstellingen (langlopend)	\N	5
1209045.01	Rekening-courant overige 1	\N	5
0805030.10	Bij overname verkregen schulden financieringen van kredietinstellingen (langlopend)	\N	5
0805030.11	Bij afstoting vervreemde schulden financieringen van kredietinstellingen (langlopend)	\N	5
0805030.08	Bijschrijving rente / oprenting financieringen van kredietinstellingen (langlopend)	\N	5
0805030.06	Omrekeningsverschillen leningen van kredietinstellingen (langlopend)	\N	5
0805030.07	Overige mutaties leningen van kredietinstellingen (langlopend)	\N	5
0805030.12	Overige waardeveranderingen hypotheken van kredietinstellingen (langlopend)	\N	5
0805030.13	Marktwaardecorrectie van de vastrentende lening 	\N	5
0805035.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	\N	5
0805035.04	Aflossingen in boekjaar leningen van kredietinstellingen (langlopend)	\N	5
0805035.05	Aflossingsverplichting (overboeking naar kortlopend) leningen van kredietinstellingen (langlopend)	\N	5
0805035.06	Aflossingsverplichting marktwaardecorrectie vastrentende lening (langlopend)	\N	5
0805040.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan kredietinstellingen	\N	5
0805040.03	Aanvullend opgenomen schulden aan kredietinstellingen	\N	5
0805040.10	Bij overname verkregen schulden financieringen van kredietinstellingen (langlopend)	\N	5
0805040.11	Bij afstoting vervreemde schulden financieringen van kredietinstellingen (langlopend)	\N	5
0805040.08	Bijschrijving rente / oprenting financieringen van kredietinstellingen (langlopend)	\N	5
0805040.06	Omrekeningsverschillen leningen van kredietinstellingen (langlopend)	\N	5
0805040.07	Overige mutaties leningen van kredietinstellingen (langlopend)	\N	5
0805040.12	Overige waardeveranderingen hypotheken van kredietinstellingen (langlopend)	\N	5
0805045.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	\N	5
0805045.04	Aflossingen in boekjaar overige schulden van kredietinstellingen (langlopend)	\N	5
0805045.05	Aflossingsverplichting (overboeking naar kortlopend) overige schulden aan kredietinstellingen (langlopend)	\N	5
0805050.01	Beginbalans (overname eindsaldo vorig jaar) schulden van kredietinstellingen geborgd door WSW 	\N	5
0805050.03	Toename leningen van kredietinstellingen (langlopend)	\N	5
0805050.10	Bij overname verkregen schulden financieringen van kredietinstellingen (langlopend)	\N	5
0805050.11	Bij afstoting vervreemde schulden financieringen van kredietinstellingen (langlopend)	\N	5
0805050.08	Bijschrijving rente / oprenting financieringen van kredietinstellingen (langlopend)	\N	5
0805050.06	Omrekeningsverschillen leningen van kredietinstellingen (langlopend)	\N	5
0805050.07	Overige mutaties leningen van kredietinstellingen (langlopend)	\N	5
0805050.12	Overige waardeveranderingen schulden van kredietinstellingen (langlopend)	\N	5
0805050.13	Marktwaardecorrectie van de vastrentende lening 	\N	5
0805055.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	\N	5
0805055.04	Aflossingen in boekjaar leningen van kredietinstellingen geborgd door WSW (langlopend)	\N	5
0805055.05	Aflossingsverplichting (overboeking naar kortlopend) schulden van kredietinstellingen geborgd door WSW (langlopend)	\N	5
0805055.06	Aflossingsverplichting marktwaardecorrectie vastrentende lening  geborgd door WSW (langlopend)	\N	5
0805060.01	Beginbalans (overname eindsaldo vorig jaar) schulden van kredietinstellingen gegarandeerd door overheden	\N	5
0805060.03	Toename leningen van kredietinstellingen (langlopend)	\N	5
0805060.10	Bij overname verkregen schulden financieringen van kredietinstellingen (langlopend)	\N	5
0805060.11	Bij afstoting vervreemde schulden financieringen van kredietinstellingen (langlopend)	\N	5
0805060.08	Bijschrijving rente / oprenting financieringen van kredietinstellingen (langlopend)	\N	5
0805060.06	Omrekeningsverschillen leningen van kredietinstellingen (langlopend)	\N	5
0805060.07	Overige mutaties leningen van kredietinstellingen (langlopend)	\N	5
0805060.12	Overige waardeveranderingen schulden van kredietinstellingen (langlopend)	\N	5
0805060.13	Marktwaardecorrectie van de vastrentende lening 	\N	5
0805065.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	\N	5
0805065.04	Aflossingen in boekjaar leningen van kredietinstellingen  gegarandeerd door overheden (langlopend)	\N	5
0805065.05	Aflossingsverplichting (overboeking naar kortlopend) schulden van kredietinstellingen gegarandeerd door overheden (langlopend)	\N	5
0805065.06	Aflossingsverplichting marktwaardecorrectie vastrentende lening (langlopend)	\N	5
0805070.01	Beginbalans (overname eindsaldo vorig jaar) schulden van kredietinstellingen geborgd door WSW 	\N	5
0805070.03	Toename leningen van kredietinstellingen (langlopend)	\N	5
0805070.10	Bij overname verkregen schulden financieringen van kredietinstellingen (langlopend)	\N	5
0805070.11	Bij afstoting vervreemde schulden financieringen van kredietinstellingen (langlopend)	\N	5
0805070.08	Bijschrijving rente / oprenting financieringen van kredietinstellingen (langlopend)	\N	5
0805070.06	Omrekeningsverschillen leningen van kredietinstellingen (langlopend)	\N	5
0805070.07	Overige mutaties leningen van kredietinstellingen (langlopend)	\N	5
0805070.12	Overige waardeveranderingen schulden van kredietinstellingen (langlopend)	\N	5
0805070.13	Marktwaardecorrectie van de vastrentende lening 	\N	5
0805075.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	\N	5
0805075.04	Aflossingen in boekjaar leningen van kredietinstellingen geborgd door WSW (langlopend)	\N	5
0805075.05	Aflossingsverplichting (overboeking naar kortlopend) schulden van kredietinstellingen geborgd door WSW (langlopend)	\N	5
0805075.06	Aflossingsverplichting marktwaardecorrectie vastrentende lening  geborgd door WSW (langlopend)	\N	5
0806060.01	Beginbalans (overname eindsaldo vorig jaar) ontvangen vooruitbetalingen op bestellingen	\N	5
0806060.02	Toename ontvangen vooruitbetalingen op bestellingen (langlopend)	\N	5
0806060.05	Stortingen / ontvangsten	\N	5
0806060.06	Betalingen	\N	5
0806060.03	Bijschrijving rente / oprenting ontvangen vooruitbetalingen op bestellingen (langlopend)	\N	5
0806060.04	Overige waardeveranderingen ontvangen vooruitbetalingen op bestellingen (langlopend)	\N	5
0806061.01	Beginbalans (overname eindsaldo vorig jaar) cumulatieve aflossingen vooruitbetalingen op bestellingen	\N	5
0806061.02	Afname in boekjaar vooruitbetalingen op bestellingen (langlopend)	\N	5
0806061.03	Afname (overboeking naar kortlopend) vooruitbetalingen op bestellingen	\N	5
0806070.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan leveranciers en handelskredieten	\N	5
0806070.02	Toename schulden aan leveranciers en handelskredieten (langlopend)	\N	5
0806070.03	Bijschrijving rente / oprenting schulden aan leveranciers en handelskredieten (langlopend)	\N	5
0806070.04	Overige waardeveranderingen schulden aan leveranciers en handelskredieten (langlopend)	\N	5
0806071.01	Aflossingen beginbalans (overname eindsaldo vorig jaar) schulden aan leveranciers en handelskredieten	\N	5
0806071.02	Afname in boekjaar schulden aan leveranciers en handelskredieten (langlopend)	\N	5
0806071.03	Afname (overboeking naar kortlopend) schulden aan leveranciers en handelskredieten	\N	5
0806080.01	Beginbalans (overname eindsaldo vorig jaar) te betalen wissels en cheques	\N	5
0806080.02	Toename te betalen wissels en cheques (langlopend)	\N	5
0806080.05	Stortingen / ontvangsten	\N	5
0806080.06	Betalingen	\N	5
0806080.03	Bijschrijving rente / oprenting te betalen wissels en cheques (langlopend)	\N	5
0806080.04	Overige waardeveranderingen te betalen wissels en cheques (langlopend)	\N	5
0806081.01	Aflossingen beginbalans (overname eindsaldo vorig jaar) te betalen wissels en cheques	\N	5
0806081.02	Afname in boekjaar te betalen wissels en cheques (langlopend)	\N	5
0806081.03	Afname (overboeking naar kortlopend) te betalen wissels en cheques (langlopend)	\N	5
0806010.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan groepsmaatschappijen	\N	5
0806010.03	Aanvullend opgenomen schulden aan groepsmaatschappijen	\N	5
0806010.09	Stortingen / ontvangsten	\N	5
0806010.10	Betalingen	\N	5
0806010.08	Bijschrijving rente schulden aan groepsmaatschappijen	\N	5
0806010.06	Omrekeningsverschillen schulden aan groepsmaatschappijen	\N	5
0806010.07	Overige mutaties schulden aan groepsmaatschappijen	\N	5
0806015.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan groepsmaatschappijen	\N	5
0806015.02	Aflossingen schulden aan groepsmaatschappijen (langlopend)	\N	5
0806015.03	Aflossingsverplichting (overboeking naar kortlopend) schulden aan groepsmaatschappijen	\N	5
0806015.04	Terugboekingen schulden aan groepsmaatschappijen	\N	5
0806020.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan overige verbonden maatschappijen	\N	5
0806020.03	Aanvullend opgenomen schulden aan overige verbonden maatschappijen	\N	5
0806020.09	Stortingen / ontvangsten	\N	5
0806020.10	Betalingen	\N	5
0806020.08	Bijschrijving rente schulden aan overige verbonden maatschappijen	\N	5
0806020.06	Omrekeningsverschillen schulden aan overige verbonden maatschappijen	\N	5
0806020.07	Overige mutaties schulden aan overige verbonden maatschappijen	\N	5
0806025.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan overige verbonden maatschappijen	\N	5
0806020.04	Aflossingen schulden aan overige verbonden maatschappijen (langlopend)	\N	5
0806025.03	Aflossingsverplichting (overboeking naar kortlopend) schulden aan overige verbonden maatschappijen	\N	5
0806025.04	Terugboekingen schulden aan overige verbonden maatschappijen	\N	5
0806030.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
0806030.03	Aanvullend opgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
0806030.09	Stortingen / ontvangsten	\N	5
0806030.10	Betalingen	\N	5
0806030.08	Bijschrijving rente schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
0806030.06	Omrekeningsverschillen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
0806030.07	Overige mutaties schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
0806035.01	Beginbalans (overname eindsaldo vorig jaar) schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
0806030.04	Aflossingen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen (langlopend)	\N	5
0806035.03	Aflossingsverplichting (overboeking naar kortlopend) schulden aan participanten en aan maatschappijen waarin wordt deelgenomen (langlopend)	\N	5
0806035.04	Terugboekingen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
0806040.01	Beginbalans (overname eindsaldo vorig jaar) belastingen en premies sociale verzekeringen	\N	5
0806040.02	Toename belastingen en premies sociale verzekeringen (langlopend)	\N	5
0806040.03	Bijschrijving rente / oprenting belastingen en premies sociale verzekeringen (langlopend)	\N	5
0806040.04	Overige waardeveranderingen belastingen en premies sociale verzekeringen (langlopend)	\N	5
0806041.01	Aflossingen beginbalans (overname eindsaldo vorig jaar) belastingen en premies sociale verzekeringen	\N	5
0806041.02	Afname in boekjaar belastingen en premies sociale verzekeringen (langlopend)	\N	5
0806041.03	Afname (overboeking naar kortlopend) belastingen en premies sociale verzekeringen (langlopend)	\N	5
0806045.01	Beginbalans (overname eindsaldo vorig jaar) schulden uit hoofde van belastingen	\N	5
0806045.02	Toename schulden uit hoofde van belastingen (langlopend)	\N	5
0806045.03	Bijschrijving rente / oprenting schulden uit hoofde van belastingen (langlopend)	\N	5
0806045.04	Overige waardeveranderingen schulden uit hoofde van belastingen (langlopend)	\N	5
0806046.01	Beginbalans (overname eindsaldo vorig jaar) cumulatieve aflossing schulden uit hoofde van belastingen	\N	5
0806046.02	Afname in boekjaar schulden uit hoofde van belastingen (langlopend)	\N	5
0806046.03	Afname (overboeking naar kortlopend) schulden uit hoofde van belastingen (langlopend)	\N	5
0806050.01	Beginbalans (overname eindsaldo vorig jaar) schulden ter zake van pensioenen (langlopend)	\N	5
0806050.02	Toename schulden ter zake van pensioenen (langlopend)	\N	5
0806050.03	Bijschrijving rente / oprenting schulden ter zake van pensioenen (langlopend)	\N	5
0806050.04	Overige waardeveranderingen schulden ter zake van pensioenen (langlopend)	\N	5
0806051.01	Beginbalans (overname eindsaldo vorig jaar) cumulatieve aflossingen schulden pensioenen (langlopend)	\N	5
0806051.02	Afname in boekjaar schulden ter zake van pensioenen (langlopend)	\N	5
0806051.03	Afname (overboeking naar kortlopend) schulden ter zake van pensioenen (langlopend)	\N	5
0705010.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0705010.02	Aanvullend opgenomen 	\N	5
0705010.03	Aanpassing als gevolg van later geïdentificeerde activa en passiva en veranderingen in de waarde ervan 	\N	5
0705010.04	Afboeking als gevolg van afstotingen 	\N	5
0705010.08	Overige mutaties bruto waarde negatieve goodwill	\N	5
0705015.01	Beginbalans (overname eindsaldo vorig jaar) 	\N	5
0705015.02	Ten gunste van winst- en verliesrekening gebracht 	\N	5
0705015.03	Vrijval ten gunste van winst- en verliesrekening, geen betrekking op toekomstige resultaten 	\N	5
0806149.01	Beginbalans (overname eindsaldo vorig jaar) oudedagsverplichting	\N	5
0806149.03	Aanvullend opgenomen / nieuwe opbouw oudedagsverplichtingoudedagsverplichting	\N	5
0806149.09	Stortingen / ontvangsten	\N	5
0806149.10	Betalingen	\N	5
0806149.11	Uitbetaald / bij afstoting vervreemde schulden oudedagsverplichting	\N	5
0806149.08	Bijschrijving rente / oprenting oudedagsverplichting	\N	5
0806149.12	Aflossingsverplichting (overboeking naar kortlopend) oudedagsverplichting	\N	5
0806149.07	Overige mutaties oudedagsverplichting	\N	5
0807010.01	Beginbalans (overname eindsaldo vorig jaar) participaties	\N	5
0807010.03	Aanvullend opgenomen participaties	\N	5
0807010.14	Betalingen	\N	5
0807010.10	Bij overname verkregen schulden participaties	\N	5
0807010.11	Bij afstoting vervreemde schulden participaties	\N	5
0807010.08	Bijschrijving rente participaties	\N	5
0807010.06	Omrekeningsverschillen participaties	\N	5
0807010.07	Overige mutaties participaties	\N	5
0807010.12	Overige waardeveranderingen participaties	\N	5
0807020.01	Aflossingen beginbalans (overname eindsaldo vorig jaar) participaties	\N	5
0807020.02	Aflossingen in boekjaar participaties (langlopend)	\N	5
0807020.05	Aflossingsverplichting (overboeking naar kortlopend) participaties (langlopend)	\N	5
0806120.01	Beginbalans (overname eindsaldo vorig jaar) schulden van overheid	\N	5
0806120.02	Toename leningen schulden van overheid (langlopend)	\N	5
0806120.03	Bij overname verkregen schulden aan overheid (langlopend)	\N	5
0806120.04	Bij afstoting vervreemde schulden van overheid (langlopend)	\N	5
0806120.09	Stortingen / ontvangsten	\N	5
0806120.10	Betalingen	\N	5
0806120.05	Bijschrijving rente / oprenting schulden van overheid (langlopend)	\N	5
0806120.06	Omrekeningsverschillen schulden van overheid (langlopend)	\N	5
0806120.07	Overige mutaties schulden van overheid (langlopend)	\N	5
0806120.08	Overige waardeveranderingen schulden van overheid (langlopend)	\N	5
0806125.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	\N	5
0806125.02	Aflossingen in boekjaar leningen van overheid (langlopend)	\N	5
0806125.03	Aflossingsverplichting (overboeking naar kortlopend) schulden van overheid (langlopend)	\N	5
0806150.01	Beginbalans (overname eindsaldo vorig jaar) schulden van overheid geborgd door WSW 	\N	5
0806150.02	Toename leningen van overheid (langlopend)	\N	5
0806150.03	Bij overname verkregen leningen van overheid (langlopend)	\N	5
0806150.04	Bij afstoting vervreemde leningen van overheid (langlopend)	\N	5
0806150.09	Stortingen / ontvangsten	\N	5
0806150.10	Betalingen	\N	5
0806150.05	Bijschrijving rente / oprenting leningen van overheid (langlopend)	\N	5
0806150.06	Omrekeningsverschillen leningen van overheid (langlopend)	\N	5
0806150.07	Overige mutaties leningen van overheid (langlopend)	\N	5
0806150.08	Overige waardeveranderingen leningen van overheid (langlopend)	\N	5
0806155.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	\N	5
0806155.02	Aflossingen in boekjaar leningen van overheid geborgd door WSW (langlopend)	\N	5
0806155.03	Aflossingsverplichting (overboeking naar kortlopend) leningen van overheid geborgd door WSW (langlopend)	\N	5
0806160.01	Beginbalans (overname eindsaldo vorig jaar) schulden van overheid gegarandeerd door overheden	\N	5
0806160.02	Toename leningen van overheid (langlopend)	\N	5
0806160.03	Bij overname verkregen schulden van overheid (langlopend)	\N	5
0806160.04	Bij afstoting vervreemde schulden van overheid (langlopend)	\N	5
0806160.05	Bijschrijving rente / oprenting financieringen van overheid (langlopend)	\N	5
0806160.06	Omrekeningsverschillen leningen van overheid (langlopend)	\N	5
0806160.07	Overige mutaties leningen van overheid (langlopend)	\N	5
0806160.08	Overige waardeveranderingen leningen van overheid (langlopend)	\N	5
0806165.01	Aflossingen beginbalans (overname eindsaldo vorig jaar)	\N	5
0806165.02	Aflossingen in boekjaar leningen gegarandeerd door overheid (langlopend)	\N	5
0806165.03	Aflossingsverplichting (overboeking naar kortlopend) gegarandeerd door overheid (langlopend)	\N	5
0806110.01	Beginbalans (overname eindsaldo vorig jaar) verplichtingen uit hoofde van onroerende zaken verkocht ondervoorwaarden (langlopend)	\N	5
0806110.02	Aankoop verplichtingen uit hoofde van onroerende zaken verkocht onder voorwaarden (langlopend)	\N	5
0806110.03	Verkoop verplichtingen uit hoofde van onroerende zaken verkocht onder voorwaarden (langlopend)	\N	5
0806110.04	Waardestijging verplichtingen uit hoofde van onroerende zaken verkocht onder voorwaarden (langlopend)	\N	5
0806110.05	Afwaardering verplichtingen uit hoofde van onroerende zaken verekocht onder voorwaarden	\N	5
1208240.02	Te betalen rente schulden aan overige verbonden maatschappijen	\N	5
0806110.06	Overige mutaties verplichtingen uit hoofde van onroerende zaken verkocht onder voorwaarden (langlopend)	\N	5
0806130.01	Beginbalans (overname eindsaldo vorig jaar) schulden 	\N	5
0806130.03	Aanvullend opgenomen overige schulden	\N	5
0806130.09	Stortingen / ontvangsten	\N	5
0806130.10	Betalingen	\N	5
0806130.06	Overige mutaties overige schulden (langlopend)	\N	5
0806135.01	Beginbalans (overname eindsaldo vorig jaar) schulden 	\N	5
0806135.04	Aflossingen overige schulden (langlopend)	\N	5
0806135.05	Aflossingsverplichting (overboeking naar kortlopend) overige schulden	\N	5
0806133.01	Beginbalans (overname eindsaldo vorig jaar) intern lening	\N	5
0806133.03	Aanvullend opgenomen intern lening	\N	5
0806133.09	Stortingen / ontvangsten	\N	5
0806133.10	Betalingen	\N	5
0806133.06	Overige mutaties intern lening (langlopend)	\N	5
0806134.01	Beginbalans (overname eindsaldo vorig jaar) intern lening	\N	5
0806134.04	Aflossingen intern lening (Langlopend)	\N	5
0806134.05	Aflossingsverplichting (overboeking naar kortlopend)  intern lening	\N	5
0806137.01	Beginbalans (overname eindsaldo vorig jaar) waarborgsommen	\N	5
0806137.03	Aanvullend opgenomen waarborgsommen	\N	5
0806137.06	Overige mutaties waarborgsommen (langlopend)	\N	5
0806138.01	Beginbalans (overname eindsaldo vorig jaar) aflossingen waarborgsommen	\N	5
0806138.04	Aflossingen waarborgsommen (langlopend)	\N	5
0806138.05	Aflossingsverplichting (overboeking naar kortlopend) waarborgsommen	\N	5
0806140.01	Beginbalans (overname eindsaldo vorig jaar) derivaten	\N	5
0806140.03	Aanvullend opgenomen derivaten	\N	5
0806140.06	Overige mutaties derivaten (langlopend)	\N	5
0806141.01	Beginbalans (overname eindsaldo vorig jaar) derivaten	\N	5
0806141.04	Aflossingen derivaten (langlopend)	\N	5
0806141.05	Aflossingsverplichting (overboeking naar kortlopend) derivaten	\N	5
0806171.01	Beginbalans (overname eindsaldo vorig jaar) overlopende passiva	\N	5
0806171.03	Aanvullend opgenomen overlopende passiva	\N	5
0806171.10	Betalingen	\N	5
0806171.06	Overige mutaties overlopende passiva (langlopend)	\N	5
0806172.01	Beginbalans (overname eindsaldo vorig jaar) cumulatieve aflossing overlopende passiva	\N	5
0806172.04	Aflossingen overlopende passiva (langlopend)	\N	5
0806172.05	Aflossingsverplichting (overboeking naar kortlopend) overlopende passiva	\N	5
1201050.01	Negatieve marktwaarde derivaten	\N	5
1201050.02	Negatieve marktwaarde embedded derivaten	\N	5
1209030.01	Rekening-courant bank groep 1	\N	5
1209030.02	Rekening-courant bank groep 2	\N	5
1209030.03	Rekening-courant bank groep 3	\N	5
1209030.04	Rekening-courant bank groep 4	\N	5
1209030.05	Rekening-courant bank groep 5	\N	5
1209030.06	Rekening-courant bank groep 6	\N	5
1209030.07	Rekening-courant bank groep 7	\N	5
1209030.08	Rekening-courant bank groep 8	\N	5
1209030.09	Rekening-courant bank groep 9	\N	5
1209030.10	Rekening-courant bank groep 10	\N	5
1208110.01	Kortlopend deel van langlopende schulden aan groepsmaatschappijen schulden aan groepsmaatschappijen	\N	5
1208110.02	Te betalen rente schulden aan groepsmaatschappijen	\N	5
1208110.03	Rekening-courant bij groepsmaatschappijen schulden aan groepsmaatschappijen	\N	5
1208120.01	Kortlopend deel van langlopende schulden aan groepsmaatschappijen schulden aan groepsmaatschappijen	\N	5
1208120.02	Te betalen rente schulden aan groepsmaatschappijen	\N	5
1208120.03	Rekening-courant bij groepsmaatschappijen schulden aan groepsmaatschappijen	\N	5
1208130.01	Kortlopend deel van langlopende schulden aan groepsmaatschappijen schulden aan groepsmaatschappijen	\N	5
1208130.02	Te betalen rente schulden aan groepsmaatschappijen	\N	5
1208130.03	Rekening-courant bij groepsmaatschappijen schulden aan groepsmaatschappijen	\N	5
1208140.01	Kortlopend deel van langlopende schulden aan groepsmaatschappijen schulden aan groepsmaatschappijen	\N	5
1208140.02	Te betalen rente schulden aan groepsmaatschappijen	\N	5
1208140.03	Rekening-courant bij groepsmaatschappijen schulden aan groepsmaatschappijen	\N	5
1208150.01	Kortlopend deel van langlopende schulden aan groepsmaatschappijen schulden aan groepsmaatschappijen	\N	5
1208150.02	Te betalen rente schulden aan groepsmaatschappijen	\N	5
1208150.03	Rekening-courant bij groepsmaatschappijen schulden aan groepsmaatschappijen	\N	5
1208160.01	Kortlopend deel van langlopende schulden aan DAEB	\N	5
1208160.02	Te betalen rente	\N	5
1208160.03	Rekening-courant bij DAEB	\N	5
1208170.01	Kortlopend deel van langlopende schulden aan Niet-DAEB	\N	5
1208170.02	Te betalen rente	\N	5
1208170.03	Rekening-courant bij Niet-DAEB	\N	5
1208210.01	Kortlopend deel van langlopende schulden aan overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	\N	5
1208210.02	Te betalen rente schulden aan overige verbonden maatschappijen	\N	5
1208210.03	Rekening-courant bij overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	\N	5
1208220.01	Kortlopend deel van langlopende schulden aan overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	\N	5
1208220.02	Te betalen rente schulden aan overige verbonden maatschappijen	\N	5
1208220.03	Rekening-courant bij overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	\N	5
1208230.01	Kortlopend deel van langlopende schulden aan overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	\N	5
1208230.02	Te betalen rente schulden aan overige verbonden maatschappijen	\N	5
1208230.03	Rekening-courant bij overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	\N	5
1208240.01	Kortlopend deel van langlopende schulden aan overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	\N	5
1208240.03	Rekening-courant bij overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	\N	5
1208250.01	Kortlopend deel van langlopende schulden aan overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	\N	5
1208250.02	Te betalen rente schulden aan overige verbonden maatschappijen	\N	5
1208250.03	Rekening-courant bij overige verbonden maatschappijen schulden aan overige verbonden maatschappijen	\N	5
1208310.01	Kortlopend deel van langlopende schulden aan participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1208310.02	Te betalen rente schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1208310.03	Rekening-courant bij participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1208320.01	Kortlopend deel van langlopende schulden aan participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1208320.02	Te betalen rente schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1208320.03	Rekening-courant bij participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1208330.01	Kortlopend deel van langlopende schulden aan participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1208330.02	Te betalen rente schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1208330.03	Rekening-courant bij participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1208340.01	Kortlopend deel van langlopende schulden aan participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1208340.02	Te betalen rente schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1208340.03	Rekening-courant bij participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1208350.01	Kortlopend deel van langlopende schulden aan participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1208350.02	Te betalen rente schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1208350.03	Rekening-courant bij participanten en maatschappijen waarin wordt deelgenomen schulden aan participanten en aan maatschappijen waarin wordt deelgenomen	\N	5
1205010.01	Beginbalans af te dragen omzetbelasting	\N	5
1205010.02	Omzetbelasting leveringen/diensten algemeen tarief 	\N	5
1205010.03	Omzetbelasting leveringen/diensten verlaagd tarief 	\N	5
1205010.16	Omzetbelasting leveringen/diensten verlaagd tarief 9%	\N	5
1205010.04	Omzetbelasting leveringen/diensten overige tarieven 	\N	5
1205010.05	Omzetbelasting over privégebruik 	\N	5
1205010.06	Omzetbelasting leveringen/diensten waarbij heffing is verlegd 	\N	5
1205010.07	Omzetbelasting leveringen/diensten uit landen buiten de EU 	\N	5
1205010.08	Omzetbelasting leveringen/diensten uit landen binnen EU 	\N	5
1205010.09	Voorbelasting 	\N	5
1205010.10	Vermindering volgens de kleineondernemersregeling 	\N	5
1205010.11	Schatting vorige aangifte(n) 	\N	5
1205010.12	Schatting deze aangifte 	\N	5
1205010.13	Afgedragen omzetbelasting 	\N	5
1205010.14	Naheffingsaanslagen omzetbelasting	\N	5
1205010.15	Overige mutaties omzetbelasting	\N	5
1206010.01	Beginbalans af te dragen loonheffing 	\N	5
1206010.02	Aangifte loonheffing 	\N	5
1206010.03	Afgedragen Loonheffing 	\N	5
1206010.04	Naheffingsaanslagen loonheffing	\N	5
1206010.05	Overige mutaties loonheffing	\N	5
1207010.01	Beginbalans af te dragen vennootschapsbelasting	\N	5
1207010.02	Aangifte vennootschapsbelasting 	\N	5
1207010.03	Voorlopige aanslag vennootschapsbelasting huidig boekjaar	\N	5
1207010.08	Voorlopige aanslag vennootschapsbelasting voorgaande boekjaren	\N	5
1207010.04	Te verrekenen vennootschapsbelasting 	\N	5
1207010.05	Afgedragen vennootschapsbelasting 	\N	5
1207010.06	Naheffingsaanslagen vennootschapsbelasting	\N	5
1207010.07	Overige mutaties vennootschapsbelasting	\N	5
1208010	Binnenlandse belastingen	\N	3
1208020	Buitenlandse belastingen	\N	3
1208030	Provinciale belastingen	\N	3
1208040	Gemeentelijke belastingen	\N	3
1208050	Belastingen op verkochte goederen en diensten uitgezonderd BTW	\N	3
1208070	Te betalen Dividendbelasting belastingen en premies sociale verzekeringen	\N	3
1208060	Te betalen overige belastingen belastingen en premies sociale verzekeringen	\N	3
1209120.01	Geactiveerde uitgaven voor nog niet verrichte prestaties van onderhanden projecten	\N	5
1209120.08	Geactiveerde kosten voor het verkrijgen van een project	\N	5
1209120.02	Cumulatieve projectopbrengsten van onderhanden projecten	\N	5
1209120.03	Onderhanden projecten in opdracht van derden, voorschotten	\N	5
1209120.04	In rekening gebrachte termijnen	\N	5
1209120.05	Inhoudingen van opdrachtgevers op gedeclareerde termijnen van onderhanden projecten	\N	5
1209120.06	Voorziening verliezen	\N	5
1209120.07	Winstopslag onderhanden projecten	\N	5
1209020.01	Rekening-courant bestuurder 1	\N	5
1209020.02	Rekening-courant bestuurder 2	\N	5
1209020.03	Rekening-courant bestuurder 3	\N	5
1209020.04	Rekening-courant bestuurder 4	\N	5
1209020.05	Rekening-courant bestuurder 5	\N	5
1209025.01	Rekening-courant commissaris 1	\N	5
1209025.02	Rekening-courant commissaris 2	\N	5
1209025.03	Rekening-courant commissaris 3	\N	5
1209025.04	Rekening-courant commissaris 4	\N	5
1209025.05	Rekening-courant commissaris 5	\N	5
1209045.02	Rekening-courant overige 2	\N	5
1209045.03	Rekening-courant overige 3	\N	5
1209045.04	Rekening-courant overige 4	\N	5
1209045.05	Rekening-courant overige 5	\N	5
1209010.01	Rekening-courant aandeelhouder 1	\N	5
1209010.02	Rekening-courant aandeelhouder 2	\N	5
1209010.03	Rekening-courant aandeelhouder 3	\N	5
1209010.04	Rekening-courant aandeelhouder 4	\N	5
1209010.05	Rekening-courant aandeelhouder 5	\N	5
1220010	Tussenrekening contante aanbetalingen tussenrekeningen betalingen	\N	3
1220030	Tussenrekening creditcardbetalingen tussenrekeningen betalingen	\N	3
1221010	Tussenrekening brutoloon tussenrekeningen salarissen	\N	3
1221020	Tussenrekening brutoinhouding tussenrekeningen salarissen	\N	3
1221030	Tussenrekening nettoloon tussenrekeningen salarissen	\N	3
1221040	Tussenrekening nettoinhoudingen tussenrekeningen salarissen	\N	3
1222010	Tussenrekening nog te ontvangen goederen tussenrekeningen inkopen	\N	3
1222020	Tussenrekening nog te ontvangen facturen tussenrekeningen inkopen	\N	3
1222030	Tussenrekening inkoopverschillen tussenrekeningen inkopen	\N	3
1223010	Tussenrekening projectkosten tussenrekeningen projecten	\N	3
1223020	Tussenrekening projectopbrengsten tussenrekeningen projecten	\N	3
1223030	Tussenrekening projectverschillen tussenrekeningen projecten	\N	3
1224010	Tussenrekening materiaalverbruik tussenrekeningen productie	\N	3
1224020	Tussenrekening manuren tussenrekeningen productie	\N	3
1224030	Tussenrekening machineuren tussenrekeningen productie	\N	3
1224040	Tussenrekening te dekken budget tussenrekeningen productie	\N	3
1224050	Tussenrekening budget tussenrekeningen productie	\N	3
1225010	Tussenrekening capaciteit tussenrekeningen dienstverlening	\N	3
1225020	Tussenrekening materialen tussenrekeningen dienstverlening	\N	3
1225030	Tussenrekening uren tussenrekeningen dienstverlening	\N	3
1225040	Inkomende verschotten tussenrekeningen dienstverlening	\N	3
1225050	Voorschotten onbelast tussenrekeningen dienstverlening	\N	3
1225060	Voorschotten belast tussenrekeningen dienstverlening	\N	3
1225070	Doorberekende voorschotten onbelast tussenrekeningen dienstverlening	\N	3
1225080	Doorberekende voorschotten belast tussenrekeningen dienstverlening	\N	3
1226010	Tussenrekening voorraadverschillen tussenrekening voorraden	\N	3
1227010	Tussenrekening nog te factureren tussenrekeningen verkopen	\N	3
1227020	Tussenrekening nog te verzenden goederen tussenrekeningen verkopen	\N	3
1227030	Tussenrekening verkoopverschillen tussenrekeningen verkopen	\N	3
1228010	Tussenrekening contante ontvangsten tussenrekeningen ontvangsten	\N	3
1228030	Tussenrekening creditcardverkopen tussenrekeningen ontvangsten	\N	3
1229010	Tussenrekening beginbalans tussenrekeningen overig	\N	3
1229020	Tussenrekening vraagposten tussenrekeningen overig	\N	3
1229030	Tussenrekening overige tussenrekeningen overig	\N	3
1228520	Tussenrekening leningen UG	\N	3
1228530	Tussenrekening kasgeld OG	\N	3
1228540	Tussenrekening kasgeld UG	\N	3
1228550	Tussenrekening spaardeposito	\N	3
1228560	Tussenrekening derivaten	\N	3
1228570	Tussenrekening leningen CFV	\N	3
8006010.01	Verleende kortingen op geproduceerde goederen verleende kortingen	\N	5
8006010.02	Verleende kortingen op handelsgoederen verleende kortingen	\N	5
8006010.03	Verleende kortingen op diensten verleende kortingen	\N	5
8006010.04	Overige verleende kortingen verleende kortingen	\N	5
8006020.01	Omzetbonificaties op geproduceerde goederen omzetbonificaties	\N	5
8006020.02	Omzetbonificaties op handelsgoederen omzetbonificaties	\N	5
8006020.03	Omzetbonificaties op diensten omzetbonificaties	\N	5
8006020.04	Omzetbonificaties overige omzetbonificaties	\N	5
8006030.01	Provisies op verkopen handel provisies	\N	5
8006030.02	Provisies op verkopen productie provisies	\N	5
8006030.03	Provisies op verkopen dienstverlening provisies	\N	5
8006030.04	Overige provisies provisies	\N	5
8009100.01	Netto-omzet groep 1 product A	\N	5
8009100.02	Netto-omzet groep 1 product B	\N	5
8009100.03	Netto-omzet groep 1 product C	\N	5
8009100.04	Netto-omzet groep 1 product D	\N	5
8009100.05	Netto-omzet groep 1 product E	\N	5
8009200.01	Netto-omzet groep 2 product A	\N	5
8009200.02	Netto-omzet groep 2 product B	\N	5
8009200.03	Netto-omzet groep 2 product C	\N	5
8009200.04	Netto-omzet groep 2 product D	\N	5
8009200.05	Netto-omzet groep 2 product E	\N	5
8009300.01	Netto-omzet groep 3 product A	\N	5
8009300.02	Netto-omzet groep 3 product B	\N	5
8009300.03	Netto-omzet groep 3 product C	\N	5
8009300.04	Netto-omzet groep 3 product D	\N	5
8009300.05	Netto-omzet groep 3 product E	\N	5
8009400.01	Netto-omzet groep 4 product A	\N	5
8009400.02	Netto-omzet groep 4 product B	\N	5
8009400.03	Netto-omzet groep 4 product C	\N	5
8009400.04	Netto-omzet groep 4 product D	\N	5
8009400.05	Netto-omzet groep 4 product E	\N	5
8009500.01	Netto-omzet groep 5 product A	\N	5
8009500.02	Netto-omzet groep 5 product B	\N	5
8009500.03	Netto-omzet groep 5 product C	\N	5
8009500.04	Netto-omzet groep 5 product D	\N	5
8009500.05	Netto-omzet groep 5 product E	\N	5
8010100.01	Huren	\N	5
8010100.02	Frictieleegstand	\N	5
8010100.03	Afboekingen	\N	5
8010100.04	Mutatie voorziening huurdebiteuren	\N	5
8010100.05	Leegstand projecten	\N	5
8010100.06	Leegstand verkoop	\N	5
8010100.07	Huurkortingen	\N	5
8011100.01	Overige zaken, leveringen en diensten	\N	5
8011100.02	Vergoedingsderving (verrekenbaar)	\N	5
8011100.03	Te verrekenen met huurders	\N	5
8011100.04	Overige zaken, service en verbruik  (niet verrekenbaar)	\N	5
8011100.05	Vergoedingsderving (niet verrekenbaar)	\N	5
8011100.06	Opbrengsten serviceabonnement onderhoud	\N	5
8012100.10	Toegerekende kosten salarissen	\N	5
8012100.11	Toegerekende kosten sociale lasten	\N	5
8012100.12	Toegerekende kosten pensioenlasten	\N	5
8012100.13	Toegerekende kosten afschrijvingen	\N	5
8012100.14	Toegerekende kosten overige bedrijfslasten	\N	5
8012100.15	Toegerekende kosten overige personeelslasten	\N	5
8012100.01	Lasten leveringen en diensten	\N	5
8012100.02	Lasten warmtelevering	\N	5
8012100.03	Lasten overige zaken (niet verrekenbaar)	\N	5
8012100.04	Afgerekende service en stookkosten	\N	5
8012100.05	Lasten overige servicekosten	\N	5
8012100.16	Directe kosten serviceaboonement onderhoud	\N	5
8014100.01	Toegerekende kosten salarissen lasten lasten verhuur en beheeractiviteiten	\N	5
8014100.02	Toegerekende kosten sociale lasten lasten verhuur en beheeractiviteiten	\N	5
8014100.03	Toegerekende kosten pensioenlasten lasten verhuur en beheeractiviteiten	\N	5
8014100.04	Toegerekende kosten afschrijvingen lasten verhuur en beheeractiviteiten	\N	5
8014100.05	Toegerekende kosten overige bedrijfslasten lasten verhuur en beheeractiviteiten	\N	5
8014100.06	Toegerekende kosten overige personeelslasten	\N	5
8014100.07	Administratiekosten huurcontract	\N	5
8014100.08	Administratiekosten servicekosten	\N	5
8014100.09	Lasten Verhuur en Beheeractiviteiten overig	\N	5
8015100.01	Calamiteiten	\N	5
8015100.02	Planmatig onderhoud	\N	5
8015100.03	Mutatieonderhoud verhuur (technisch noodzakelijk)	\N	5
8015100.04	Mutatieonderhoud verhuur (extra)	\N	5
8015100.05	Mutatieonderhoud verkoop (technisch noodzakelijk)	\N	5
8015100.06	Reparatieonderhoud	\N	5
8015100.07	Afkoop reparatieonderhoud	\N	5
8015100.08	Contractonderhoud	\N	5
8015100.09	Onderhoudsbijdrage VVE's	\N	5
8015100.10	Vandalisme/inbraak onderhoud	\N	5
8015100.11	Opstalverzekering eigen risico	\N	5
8015100.12	Renovatie	\N	5
8015100.13	Overig onderhoud	\N	5
8015100.14	Toegerekende kosten salarissen lasten lasten onderhoud	\N	5
8015100.15	Toegerekende kosten sociale lasten lasten onderhoud	\N	5
8015100.16	Toegerekende kosten pensioenlasten lasten onderhoud	\N	5
8015100.29	Toerekening organisatiekosten overige personeelslasten	\N	5
8015100.17	Toegerekende kosten afschrijvingen lasten onderhoud	\N	5
8015100.18	Toegerekende kosten overige bedrijfslasten lasten onderhoud	\N	5
8015100.19	Planmatig onderhoud overboeking naar projecten	\N	5
8015100.20	Dekking uren indirect	\N	5
8015100.21	Dekking uren eigen dienst	\N	5
8015100.22	Dekking uren planmatig en contractonderhoud	\N	5
8015100.23	Dekking magazijnkosten	\N	5
8015100.24	Dekking afval	\N	5
8015100.25	Dekking klein materiaal	\N	5
8015100.26	Voorraadprijsverschillen materiaal	\N	5
8015100.27	Kosten serviceabonnement onderhoud	\N	5
8015100.28	Opbrengsten serviceabonnement onderhoud	\N	5
8016100.01	Onroerende zaakbelasting	\N	5
8016100.10	Waterschapsbelasting	\N	5
8016100.12	Overige belastingen en heffingen	\N	5
8016100.02	Verzekeringen	\N	5
8016100.03	Verhuurdersheffing	\N	5
8016100.04	Saneringsheffing	\N	5
8016100.05	Bijdrageheffing Autoriteit woningcorporaties	\N	5
8016100.06	Contributies	\N	5
8016100.07	Aandeel in vereniging van eigenaren	\N	5
8016100.08	Erfpacht	\N	5
8016100.09	Diverse directe exploitatielasten	\N	5
8021100.01	Kosten uitbesteed werk verkocht vastgoed in ontwikkeling	\N	5
8022100.01	Toegerekende organisatiekosten salarissen verkocht vastgoed in ontwikkeling	\N	5
8022100.02	Toegerekende organisatiekosten sociale lasten verkocht vastgoed in ontwikkeling	\N	5
8022100.03	Toegerekende organisatiekosten pensioenlasten verkocht vastgoed in ontwikkeling	\N	5
8022100.04	Toegerekende organisatiekosten afschrijvingen verkocht vastgoed in ontwikkeling	\N	5
8022100.05	Toegerekende organisatiekosten overige bedrijfslasten verkocht vastgoed in ontwikkeling	\N	5
8022100.06	          Geactiveerde productie Vastgoed in ontwikkeling	\N	5
8022100.07	Toegerekende organisatiekosten overige personeelslasten	\N	5
8031100.01	Toegerekende organisatiekosten salarissen resultaat verkoop vastgoedportefeuille	\N	5
8031100.02	Toegerekende organisatiekosten sociale lasten resultaat verkoop vastgoedportefeuille	\N	5
8031100.03	Toegerekende organisatiekosten pensioenlasten resultaat verkoop vastgoedportefeuille	\N	5
8031100.04	Toegerekende organisatiekosten afschrijvingen resultaat verkoop vastgoedportefeuille	\N	5
8031100.05	Toegerekende organisatiekosten overige bedrijfslasten resultaat verkoop vastgoedportefeuille	\N	5
8031100.06	Toegerekende organisatiekosten overige personeelslasten	\N	5
8040100.01	Kosten afboeking gestaakte projecten	\N	5
8040100.02	Overige projectkosten	\N	5
8040100.03	Dotatie voorziening nieuwbouw	\N	5
8040100.04	Vrijval voorziening nieuwbouw	\N	5
8040100.05	Dotatie voorziening renovatie	\N	5
8040100.06	Vrijval voorziening renovatie	\N	5
8040100.07	Dotatie voorziening grondposities	\N	5
8040100.08	Vrijval voorziening grondposities	\N	5
8040200.01	Toegerekende organisatiekosten salarissen vastgoed in ontwikkeling tbv verhuur	\N	5
8040200.02	Toegerekende organisatiekosten sociale lasten vastgoed in ontwikkeling tbv verhuur	\N	5
7203300.04	Lasten van aankopen en verwervingen	\N	5
8040200.03	Toegerekende organisatiekosten pensioenlasten vastgoed in ontwikkeling tbv verhuur	\N	5
8040200.04	Toegerekende organisatiekosten afschrijvingen vastgoed in ontwikkeling tbv verhuur	\N	5
8040200.05	Toegerekende organisatiekosten overige bedrijfslasten vastgoed in ontwikkeling tbv verhuur	\N	5
8040200.07	Toegerekende organisatiekosten overige personeelslasten vastgoed in ontwikkeling tbv verhuur	\N	5
8040200.08	Toegerekende organisatiekosten geactiveerde productie vastgoedinvesteringen	\N	5
8041100.01	Niet-gerealiseerde waardeveranderingen DAEB	\N	5
8041100.02	Niet-gerealiseerde waardeveranderingen Niet-DAEB	\N	5
8050100.01	Antenne opstelling	\N	5
8050100.02	VVE	\N	5
8050100.03	Zonnepanelen	\N	5
8050100.04	Warmtepompen	\N	5
8050100.05	Vastrecht bronwarmte	\N	5
8050100.06	Opbrengsten warmtewet	\N	5
8050100.07	Derving opbrengsten overige activiteiten	\N	5
8050100.08	Overige opbrengsten	\N	5
8051100.01	Aan overige activiteiten toegerekende salarissen	\N	5
8051100.02	Aan overige activiteiten toegerekende sociale lasten	\N	5
8051100.03	Aan overige activiteiten toegerekende pensioenlasten	\N	5
8051100.04	Aan overige activiteiten toegerekende afschrijvingen	\N	5
8051100.05	Aan overige activiteiten toegerekende overige bedrijfslasten	\N	5
8051100.06	Kosten uitbesteed werk overige activiteiten	\N	5
8051100.07	Aan overige activiteiten toegerekende overige personeelslasten	\N	5
8051100.08	Geactiveerde productie voor het eigen bedrijf	\N	5
8060100.01	Aanpak multiproblematiek en overlast	\N	5
8060100.02	Kleinschalige leefbaarheidsinitiatieven	\N	5
8060100.03	Interventies buitenruimte	\N	5
8060100.04	Kleinschalige wijkpanden	\N	5
8060100.05	Wijkbeheer/schoon, heel, veilig	\N	5
8060100.15	Ontmoeting	\N	5
8060100.06	Aan leefbaarheid toegerekende salarissen	\N	5
8060100.07	Aan leefbaarheid toegerekende sociale lasten	\N	5
8060100.08	Aan leefbaarheid toegerekende pensioenlasten	\N	5
8060100.09	Aan leefbaarheid toegerekende afschrijvingen	\N	5
8060100.11	Aan leefbaarheid toegerekende overige bedrijfslasten	\N	5
8060100.12	Aan leefbaarheid toegerekende overige personeelslasten	\N	5
8060100.13	Dekking uitgaven leefbaarheid	\N	5
7200100.01	Kostprijs - inkoopwaarde groep 1 product A	\N	5
7200100.02	Kostprijs - inkoopwaarde groep 1 product B	\N	5
7200100.03	Kostprijs - inkoopwaarde groep 1 product C	\N	5
7200100.04	Kostprijs - inkoopwaarde groep 1 product D	\N	5
7200100.05	Kostprijs - inkoopwaarde groep 1 product E	\N	5
7200200.01	Kostprijs - inkoopwaarde groep 2 product A	\N	5
7200200.02	Kostprijs - inkoopwaarde groep 2 product B	\N	5
7200200.03	Kostprijs - inkoopwaarde groep 2 product C	\N	5
7200200.04	Kostprijs - inkoopwaarde groep 2 product D	\N	5
7200200.05	Kostprijs - inkoopwaarde groep 2 product E	\N	5
7200300.01	Kostprijs - inkoopwaarde groep 3 product A	\N	5
7200300.02	Kostprijs - inkoopwaarde groep 3 product B	\N	5
7200300.03	Kostprijs - inkoopwaarde groep 3 product C	\N	5
7200300.04	Kostprijs - inkoopwaarde groep 3 product D	\N	5
7200300.05	Kostprijs - inkoopwaarde groep 3 product E	\N	5
7200400.01	Kostprijs - inkoopwaarde groep 4 product A	\N	5
7200400.02	Kostprijs - inkoopwaarde groep 4 product B	\N	5
7200400.03	Kostprijs - inkoopwaarde groep 4 product C	\N	5
7200400.04	Kostprijs - inkoopwaarde groep 4 product D	\N	5
7200400.05	Kostprijs - inkoopwaarde groep 4 product E	\N	5
7200500.01	Kostprijs - inkoopwaarde groep 5 product A	\N	5
7200500.02	Kostprijs - inkoopwaarde groep 5 product B	\N	5
7200500.03	Kostprijs - inkoopwaarde groep 5 product C	\N	5
7200500.04	Kostprijs - inkoopwaarde groep 5 product D	\N	5
7200500.05	Kostprijs - inkoopwaarde groep 5 product E	\N	5
7201010.01	Kostprijs van de omzet niet ingekocht bij leden product A	\N	5
7201010.02	Kostprijs van de omzet niet ingekocht bij leden product B	\N	5
7201010.03	Kostprijs van de omzet niet ingekocht bij leden product C	\N	5
7201010.04	Kostprijs van de omzet niet ingekocht bij leden product D	\N	5
7201010.05	Kostprijs van de omzet niet ingekocht bij leden product E	\N	5
7202110	Inkoopwaarde van geleverde producten	\N	3
7202210	Verstrekte subsidies of giften	\N	3
7203100.01	Lasten besteed aan doelstellingen - overige	\N	5
7203100.02	Lasten van subsidies en bijdragen	\N	5
7203100.03	Afdrachten aan verbonden (internationale) organisaties	\N	5
7203100.04	Lasten van aankopen en verwervingen	\N	5
7203100.05	Kosten van uitbesteed werk	\N	5
7203100.06	Communicatiekosten	\N	5
7203100.07	Lasten uit hoofde van personeelsbeloningen	\N	5
7203100.08	Huisvestingskosten	\N	5
7203100.09	Kantoor- en algemene kosten	\N	5
7203100.10	Afschrijvingen	\N	5
7203200.01	Wervingskosten - overige	\N	5
7203200.02	Lasten van subsidies en bijdragen	\N	5
7203200.03	Afdrachten aan verbonden (internationale) organisaties	\N	5
7203200.04	Lasten van aankopen en verwervingen	\N	5
7203200.05	Kosten van uitbesteed werk	\N	5
7203200.06	Communicatiekosten	\N	5
7203200.07	Lasten uit hoofde van personeelsbeloningen	\N	5
7203200.08	Huisvestingskosten	\N	5
7203200.09	Kantoor- en algemene kosten	\N	5
7203200.10	Afschrijvingen	\N	5
7203300.01	Kosten van beheer en administratie - overige	\N	5
7203300.02	Lasten van subsidies en bijdragen	\N	5
7203300.03	Afdrachten aan verbonden (internationale) organisaties	\N	5
7203300.05	Kosten van uitbesteed werk	\N	5
7203300.07	Lasten uit hoofde van personeelsbeloningen	\N	5
7203300.08	Huisvestingskosten	\N	5
7203300.09	Kantoor- en algemene kosten	\N	5
7203300.10	Afschrijvingen	\N	5
7204010	Andere lasten	\N	3
8215010.01	Deelnemersbijdragen	\N	5
8215010.02	Abonnementsgelden	\N	5
8215010.03	Huuropbrengsten	\N	5
8207020	Ontvangen loonsubsidies subsidiebaten	\N	3
8207030	Ontvangen afdrachtrestituties subsidiebaten	\N	3
8207040	Export- en overige restituties en subsidies ingevolge EU-regelingen subsidiebaten	\N	3
8207050.01	Subsidiebaten van rijksoverheden subsidiebaten	\N	5
8207050.02	Subsidiebaten van overheden subsidiebaten	\N	5
8207050.03	Subsidiebaten van overige overheden subsidiebaten	\N	5
8207050.04	Subsidiebaten van de Europese Unie subsidiebaten	\N	5
8207050.05	Subsidiebaten van bedrijven subsidiebaten	\N	5
8207050.06	Subsidiebaten van private organisaties subsidiebaten	\N	5
8207050.07	Subsidiebaten van overige private organisaties subsidiebaten	\N	5
8214110	Bijdragen van donateurs	\N	3
8214210	Bijdragen van leden	\N	3
8214310	Collecten	\N	3
8214320	Nalatenschappen	\N	3
8214330	Contributies	\N	3
8214340	Donaties en giften	\N	3
8214350	Eigen loterijen en prijsvragen	\N	3
8214380	Overige baten uit fondsenwerving	\N	3
8214410	Baten van bedrijfsleven	\N	3
8214510	Baten van loterijorganisaties	\N	3
8214610	Baten van subsidies van overheden	\N	3
8214710	Baten van verbonden organisaties zonder winststreven	\N	3
8214720	Baten van verbonden (internationale) organisaties	\N	3
8214810	Baten van andere organisaties zonder winststreven	\N	3
8214910	Andere baten	\N	3
4001010.01	Periodiek betaalde beloning van een bestuurder lonen en salarissen	\N	5
4001010.02	Beloningen betaalbaar op termijn van een bestuurder lonen en salarissen	\N	5
4001010.03	Uitkeringen bij beëindiging van het dienstverband van een bestuurder lonen en salarissen	\N	5
4001010.04	Winstdelingen en bonusbetalingen van een bestuurder lonen en salarissen	\N	5
4001020.01	Periodiek betaalde beloning van een commissaris lonen en salarissen	\N	5
4001020.02	Beloningen betaalbaar op termijn van een commissaris lonen en salarissen	\N	5
4001020.03	Uitkeringen bij beëindiging van het dienstverband van een commissaris lonen en salarissen	\N	5
4001020.04	Winstdelingen en bonusbetalingen van een commissaris lonen en salarissen	\N	5
4001020.05	Kosten intern toezicht	\N	5
4001040.01	Lonen en salarissen	\N	5
4001040.02	Lonen vervanging	\N	5
4001040.03	Lonen salariscorrectie	\N	5
4001070.01	Vakantiebijslag lonen en salarissen	\N	5
4001070.02	Vakantiebijslag uitbetaling verlofdagen	\N	5
4001070.03	Vakantiebijslag restant verlofuren	\N	5
4001090.01	Gratificaties lonen en salarissen	\N	5
4001160.01	Overige lonen en salarissen lonen en salarissen	\N	5
4001160.02	Overige lonen en salarissen wachtgeld/piket	\N	5
4001160.03	Overige lonen en salarissen stagevergoeding	\N	5
4001160.04	Overige lonen en salarissen kosten RVC niet salaris	\N	5
4001160.05	Overige lonen en salarissen nb/bt	\N	5
4002050.01	Overige sociale lasten sociale lasten	\N	5
4002050.02	Overige sociale lasten loonheffing eindheffing	\N	5
4002050.03	Overige sociale lasten premiekortingen	\N	5
4002050.04	Overige sociale lasten restant verlofuren - verlofdagen	\N	5
4002050.05	Overige sociale lasten restant vakantiegeld	\N	5
4002050.06	Overige sociale lasten restant vakantiedagen	\N	5
4002060	Eigen risicodragerschap	\N	3
4003010.01	Pensioenpremies	\N	5
4003010.02	Pensioenpremies PP	\N	5
4003010.03	Pensioenpremies OVP	\N	5
4003015.01	Aanvullende pensioenlasten	\N	5
4003015.02	Aanvullende pensioenlasten WIA excedent	\N	5
4003015.03	Aanvullende pensioenlasten WIA PP	\N	5
4003080.01	Overige pensioenlasten	\N	5
4003080.02	Overige pensioenlasten FLOW	\N	5
4199010.01	Doorberekende afschrijvingen immateriële vaste activa doorberekende afschrijvingen en waardeveranderingen	\N	5
4199010.02	Doorberekende afschrijvingen materiële vaste activa doorberekende afschrijvingen en waardeveranderingen	\N	5
4199020.01	Doorberekende waardeveranderingen immateriële vaste activa doorberekende afschrijvingen en waardeveranderingen	\N	5
4199020.02	Doorberekende waardeveranderingen materiële vaste activa doorberekende afschrijvingen en waardeveranderingen	\N	5
4199030.01	Doorberekende verkoopresultaten immateriële vaste activa doorberekende afschrijvingen en waardeveranderingen	\N	5
4199030.02	Doorberekende verkoopresultaten materiële vaste activa doorberekende afschrijvingen en waardeveranderingen	\N	5
4105505.01	Bijzondere waardeverminderingen van vastgoedbeleggingen in exploitatie	\N	5
4105505.02	Bijzondere waardeverminderingen van vastgoedbeleggingen in ontwikkeling	\N	5
4105515.01	Bijzondere waardeverminderingen van vastgoedbeleggingen in exploitatie	\N	5
4105515.02	Bijzondere waardeverminderingen van vastgoedbeleggingen in ontwikkeling	\N	5
4105599.01	Doorberekend / Overboeking ivm functionele indeling wijziging in de reële waarde van vastgoedbeleggingen in exploitatie	\N	5
4105599.02	Doorberekend / Overboeking ivm functionele indeling wijziging in de reële waarde van vastgoedbeleggingen in ontwikkeling	\N	5
4106015	Bijzondere waardevermindering vorderingen (korte termijn) overige bijzondere waardeverminderingen	\N	3
4106025	Bijzondere waardevermindering effecten (korte termijn) overige bijzondere waardeverminderingen	\N	3
4106030	Bijzondere waardevermindering overige vlottende activa overige bijzondere waardeverminderingen	\N	3
4106045	Liquide middelen	\N	3
4106210.01	Gerealiseerde waardeveranderingen van beleggingen in groepsmaatschappijen	\N	5
4106210.02	Gerealiseerde waardeveranderingen van beleggingen in andere deelnemingen	\N	5
4106210.03	Gerealiseerde waardeveranderingen van beleggingen in terreinen en gebouwen	\N	5
4106210.04	Gerealiseerde waardeveranderingen van beleggingen in andere beleggingen	\N	5
4106310.01	Niet-gerealiseerde waardeveranderingen van beleggingen in groepsmaatschappijen	\N	5
4106310.02	Niet-gerealiseerde waardeveranderingen van beleggingen in andere deelnemingen	\N	5
4106310.03	Niet-gerealiseerde waardeveranderingen van beleggingen in terreinen en gebouwen	\N	5
4106310.04	Niet-gerealiseerde waardeveranderingen van beleggingen in andere beleggingen	\N	5
4004010	Verteer werknemers (buiten werkplek, extern) overige personeelsgerelateerde kosten	\N	3
4004020	Maaltijden op de werkplek overige personeelsgerelateerde kosten	\N	3
4004030	Vaste vergoeding voor consumpties (niet-ambulante werknemer) overige personeelsgerelateerde kosten	\N	3
4004040	Rentevoordeel personeelslening (niet eigen woning of (elektrische) fiets/elektrische scooter) overige personeelsgerelateerde kosten	\N	3
4004050	Huisvesting en inwoning (incl energie,water, bewassing) niet ter vervulling dienstbetrekking overige personeelsgerelateerde kosten	\N	3
4004060	Vergoeding/verstrekking mobiele telefoon incl. abonnement (indien niet noodzakelijk) overige personeelsgerelateerde kosten	\N	3
4004070	Vergoeding telefoonabonnementen/internetabonnementen bij werknemer thuis (indien niet noodzakelijk) overige personeelsgerelateerde kosten	\N	3
4004080	Vergoeding/verstrekking van tablet (indien niet noodzakelijk) overige personeelsgerelateerde kosten	\N	3
4004090	Vergoeding/verstrekking van laptop (indien niet noodzakelijk) overige personeelsgerelateerde kosten	\N	3
4004100	Vergoeding/verstrekking van desktop (indien niet noodzakelijk) overige personeelsgerelateerde kosten	\N	3
4004110	Vergoeding/verstrekking computerprogrammatuur (indien niet noodzakelijk) overige personeelsgerelateerde kosten	\N	3
4004120	Inrichting werkplek thuis (exclusief arbovoorzieningen) overige personeelsgerelateerde kosten	\N	3
4004130	Vergoeding reiskosten voorzover boven € 0,19 per kilometer overige personeelsgerelateerde kosten	\N	3
4004140	Vergoeding van kosten van persoonlijke beschermingsmiddelen aan werknemer overige personeelsgerelateerde kosten	\N	3
4004150	Vergoeding van kosten van werkkleding die nagenoeg uitsluitend geschikt is om in te werken overige personeelsgerelateerde kosten	\N	3
4004160	Vergoeding van kosten van kleding die achterblijft op de werkplek overige personeelsgerelateerde kosten	\N	3
4004170	Verstrekking/vergoeding van overige kleding overige personeelsgerelateerde kosten	\N	3
4004180	Eerste huisvestingskosten (tot 18% van het loon) overige personeelsgerelateerde kosten	\N	3
4004190	Zakelijke verhuiskosten exclusief kosten overbrenging boedel (boven gerichte vrijstelling) overige personeelsgerelateerde kosten	\N	3
4004200	Personeelsfeesten (buiten de werkplek) overige personeelsgerelateerde kosten	\N	3
4004210	Kerstpakket aan personeel en postactieven overige personeelsgerelateerde kosten	\N	3
4004220	Geschenken met in hoofzaak ideële waarde bij feestdagen en jubilea overige personeelsgerelateerde kosten	\N	3
4004230	Andere geschenken in natura overige personeelsgerelateerde kosten	\N	3
4004240	Andere geschenken in de vorm van een geldsom overige personeelsgerelateerde kosten	\N	3
4004250	Fietsvergoeding overige personeelsgerelateerde kosten	\N	3
4004260	Bedrijfsfitness buiten de werkplek overige personeelsgerelateerde kosten	\N	3
4004270	Producten uit eigen bedrijf en kortingen voor zover niet vrijgesteld overige personeelsgerelateerde kosten	\N	3
4004280	Werkgeversbijdrage personeelsvereniging overige personeelsgerelateerde kosten	\N	3
4004290	Vergoeding werknemersbijdrage personeelsvereniging overige personeelsgerelateerde kosten	\N	3
4004300	Vergoeding vakbondscontributie overige personeelsgerelateerde kosten	\N	3
4004310	Personeelsreizen overige personeelsgerelateerde kosten	\N	3
4004320	Parkeren bij werk (niet zijnde auto van de zaak) (geen eigen parkeerterrein, parkeervergunning) overige personeelsgerelateerde kosten	\N	3
4004330	Parkeer-, veer- en tolgelden (niet zijnde auto van de zaak) overige personeelsgerelateerde kosten	\N	3
4004340	Persoonlijke verzorging overige personeelsgerelateerde kosten	\N	3
4004350	Representatievergoeding/relatiegeschenken aan werknemers overige personeelsgerelateerde kosten	\N	3
4004360	Eigen bijdrage werknemers voor kinderopvang op werkplek (dagopvang) overige personeelsgerelateerde kosten	\N	3
4004370	Eigen bijdrage werknemers voor kinderopvang op werkplek (bso) overige personeelsgerelateerde kosten	\N	3
4004380	Kinderopvang buiten de werkplek (factuurwaarde incl. btw of WEV) overige personeelsgerelateerde kosten	\N	3
4004390	Eigen bijdrage werknemers voor kinderopvang buiten de werkplek overige personeelsgerelateerde kosten	\N	3
4004400	Door inhoudingsplichte verrichte kinderopvang op werkplek (dagopvang) overige personeelsgerelateerde kosten	\N	3
4004410	Door inhoudingsplichte verrichte kinderopvang op werkplek (bso) overige personeelsgerelateerde kosten	\N	3
4004420	Overige werkkosten vrije ruimte overige personeelsgerelateerde kosten	\N	3
4004499	Doorberekend / Overboeking ivm functionele indeling werkkosten vrije ruimte	\N	3
4005010	Verteer werknemers op werkplek (geen maaltijden) overige personeelsgerelateerde kosten	\N	3
4005020	Huisvesting en inwoning (incl energie,water, bewassing) ter vervulling dienstbetrekking overige personeelsgerelateerde kosten	\N	3
4005030	Rentevoordeel personeelslening eigen woning en (elektrische) fiets of elektrische scooter overige personeelsgerelateerde kosten	\N	3
4005040	Ter beschikking stellen desktop computer op werkplek overige personeelsgerelateerde kosten	\N	3
4005050	Inrichting werkplek (niet thuis) overige personeelsgerelateerde kosten	\N	3
4005060	Inrichting werkplek arbo-voorzieningen (thuis) overige personeelsgerelateerde kosten	\N	3
4005070	Parkeren werkplek (niet zijnde auto van de zaak)(op parkeerterrein van werkgever) overige personeelsgerelateerde kosten	\N	3
4005080	Ter beschikking gestelde openbaarvervoerkaart/voordeelurenkaart (mede zakelijk gebruikt) overige personeelsgerelateerde kosten	\N	3
4005090	Verstrekking van persoonlijke beschermingsmiddelen (veiligheidsbril, werkschoenen) door werkgever overige personeelsgerelateerde kosten	\N	3
4005100	Verstrekking van werkkleding die nagenoeg uitsluitend geschikt is om in te werken door werkgever overige personeelsgerelateerde kosten	\N	3
4005110	Verstrekking van kleding die achterblijft op de werkplek overige personeelsgerelateerde kosten	\N	3
4005120	Verstrekking van kleding met bedrijfslogo van tenminste 70 cm² overige personeelsgerelateerde kosten	\N	3
4005130	Arbovoorzieningen overige personeelsgerelateerde kosten	\N	3
4005140	Personeelsfeesten (op de werkplek) overige personeelsgerelateerde kosten	\N	3
4005150	Bedrijfsfitness op de werkplek overige personeelsgerelateerde kosten	\N	3
4005160	Overige werkkosten nihilwaardering overige personeelsgerelateerde kosten	\N	3
4005199	Doorberekend / Overboeking ivm functionele indeling werkkosten met nihilwaardering	\N	3
4006010	Vergoeding reiskosten (tot € 0,19) per kilometer overige personeelsgerelateerde kosten	\N	3
4006020	Consumpties en maaltijden dienstreis overige personeelsgerelateerde kosten	\N	3
4006030	Maaltijden bij overwerk/werk op koopavonden overige personeelsgerelateerde kosten	\N	3
4006040	Vaste vergoeding voor consumpties (ambulante werknemer) overige personeelsgerelateerde kosten	\N	3
4006050	Opleidingen, studies, cursussen, congressen, seminars, symposia, excursies, studiereizen overige personeelsgerelateerde kosten	\N	3
4006060	Werkkosten gericht vrijgesteld, waarvan vakliteratuur overige personeelsgerelateerde kosten	\N	3
4006070	Inschrijving wettelijk en door beroepsgroep opgelegde registers overige personeelsgerelateerde kosten	\N	3
4006080	Dubbele huisvestingskosten overige personeelsgerelateerde kosten	\N	3
4006090	Extra kosten levensonderhoud overige personeelsgerelateerde kosten	\N	3
4006100	Kosten aanvragen/omzetten papieren (verblijfsvergunningen, visa, rijbewijzen) overige personeelsgerelateerde kosten	\N	3
4006110	Kosten medische keuringen, vaccinaties overige personeelsgerelateerde kosten	\N	3
4006120	Reiskosten naar land herkomst (familiebezoek, gezinshereniging) overige personeelsgerelateerde kosten	\N	3
4006130	Cursuskosten taal werkland (werknemer + gezin) overige personeelsgerelateerde kosten	\N	3
4006140	Eerste huisvestingskosten (boven 18% van het loon) overige personeelsgerelateerde kosten	\N	3
4006150	Extra (niet-zakelijke) telefoonkosten (gesprek) met land van herkomst overige personeelsgerelateerde kosten	\N	3
4006160	Opslagkosten boedel overige personeelsgerelateerde kosten	\N	3
4006170	Kosten kennismakingsreis werkland overige personeelsgerelateerde kosten	\N	3
4006180	Kosten 30% regeling overige personeelsgerelateerde kosten	\N	3
4006190	Zakelijke verhuiskosten: kosten overbrenging boedel overige personeelsgerelateerde kosten	\N	3
4006200	Zakelijke verhuiskosten exclusief kosten overbrenging boedel overige personeelsgerelateerde kosten	\N	3
4006210	Outplacementkosten overige personeelsgerelateerde kosten	\N	3
4006220	(Hotel)overnachtingen in verband met werk overige personeelsgerelateerde kosten	\N	3
4006230	Verstrekte producten en kortingen op producten uit eigen bedrijf (voor zover vrijgesteld) overige personeelsgerelateerde kosten	\N	3
4006240	Overige werkkosten gericht vrijgesteld overige personeelsgerelateerde kosten	\N	3
4006250	Arbovoorzieningen overige personeelsgerelateerde kosten	\N	3
4006260	Thuiswerkvergoeding overige personeelsgerelateerde kosten	\N	3
4006299	Doorberekend / Overboeking ivm functionele indeling werkkosten gericht vrijgesteld	\N	3
4007010	Vergoeding/verstrekking mobiele telefoon incl. abonnement (mits noodzakelijk) overige personeelsgerelateerde kosten	\N	3
4007020	Vergoeding/verstrekking van tablet (mits noodzakelijk) overige personeelsgerelateerde kosten	\N	3
4007030	Vergoeding/verstrekking van laptop (mits noodzakelijk) overige personeelsgerelateerde kosten	\N	3
4007040	Vergoeding/verstrekking van desktop (mits noodzakelijk) overige personeelsgerelateerde kosten	\N	3
4007050	Vergoeding/verstrekking computerprogrammatuur (mits noodzakelijk) overige personeelsgerelateerde kosten	\N	3
4007060	Overige werkkosten noodzakelijkheidscriterium overige personeelsgerelateerde kosten	\N	3
4007099	Doorberekend / Overboeking ivm functionele indeling werkkosten noodzakelijkscriterium	\N	3
4008010	Maaltijden met zakelijke relaties overige personeelsgerelateerde kosten	\N	3
4008020	Parkeer-, veer- en tolgelden (auto van de zaak) overige personeelsgerelateerde kosten	\N	3
4008030	Parkeren bij werk (auto van de zaak) (geen eigen parkeerterrein, parkeervergunning) overige personeelsgerelateerde kosten	\N	3
4008040	Overige werkkosten intermediair overige personeelsgerelateerde kosten	\N	3
4008099	Doorberekend / Overboeking ivm functionele indeling werkkosten intermediair	\N	3
4009010	Werkkosten belast loon t.a.v. privé-gebruik auto's overige personeelsgerelateerde kosten	\N	3
4009020	Genot dienstwoning overige personeelsgerelateerde kosten	\N	3
4009030	Geldboetes buitenlandse autoriteiten overige personeelsgerelateerde kosten	\N	3
4009040	Geldboetes binnenlandse autoriteiten overige personeelsgerelateerde kosten	\N	3
4009050	Vergoedingen en verstrekkingen ter zake van misdrijven overige personeelsgerelateerde kosten	\N	3
4009060	Vergoedingen en verstrekkingen ter zake van wapens en munitie overige personeelsgerelateerde kosten	\N	3
4009070	Vergoedingen en verstrekkingen ter zake van agressieve dieren overige personeelsgerelateerde kosten	\N	3
4009080	Overige werkkosten belast loon overige personeelsgerelateerde kosten	\N	3
4009090	Bestuurdersaansprakelijkheid	\N	3
4009099	Doorberekend / Overboeking ivm functionele indeling werkkosten belast loon	\N	3
4010010	Fruitmand, rouwkrans, bloemetje overige personeelsgerelateerde kosten	\N	3
4010020	Kleine geschenken (geen geld of waardebon) maximaal € 25 overige personeelsgerelateerde kosten	\N	3
4010030	Eenmalige uitkering/verstrekking bij 25/40-jarig diensttijdjubileum werknemer (voorzover = kleiner dan 1 x maandloon) overige personeelsgerelateerde kosten	\N	3
4010040	Werkgeversbijdrage personeelsvereniging (als werknemers geen aanspraak hebben op uitkeringen uit de pv) overige personeelsgerelateerde kosten	\N	3
4010050	Uitkering/verstrekking tot vergoeding door werknemer ivm met werk gelden schade/verlies persoonlijke zaken overige personeelsgerelateerde kosten	\N	3
4010060	Eenmalige uitkering/verstrekking bij overlijden werknemer, zijn partner of kinderen (voorzover kleiner dan 3 x maandloon) overige personeelsgerelateerde kosten	\N	3
4010070	Uitkering/verstrekking uit een personeelsfonds overige personeelsgerelateerde kosten	\N	3
4010080	Meewerkvergoeding partner inhoudingsplichtige (indien lager dan € 5.000) overige personeelsgerelateerde kosten	\N	3
4010090	Overige werkkosten geen of vrijgesteld loon overige personeelsgerelateerde kosten	\N	3
4010099	Doorberekend / Overboeking ivm functionele indeling werkkosten geen of vrijgesteld	\N	3
4011010	Werkkosten eindheffing overige personeelsgerelateerde kosten	\N	3
4011020	Correctie inzake BTW overige personeelsgerelateerde kosten	\N	3
4011030	Overboeking werkkosten overige personeelsgerelateerde kosten	\N	3
4011990	Doorberekende werkkosten overige personeelsgerelateerde kosten	\N	3
4011999	Doorberekend / Overboeking ivm functionele indeling werkkosten overig	\N	3
4012010.01	Uitzendkrachten overige personeelskosten	\N	5
4012010.02	Uitzendkrachten  formatief	\N	5
4012010.03	Uitzendkrachten projectmatig	\N	5
4012010.04	Uitzendkrachten boven formatief	\N	5
4012010.05	Uitzendkrachten programma's	\N	5
4201110	Gas huisvestingskosten	\N	3
4201120	Elektra huisvestingskosten	\N	3
4201130	Water huisvestingskosten	\N	3
4201140	Netdiensten huisvestingskosten	\N	3
4201270.01	Overige huisvestingskosten	\N	5
4201270.02	Overige huisvestingskosten glasbewassing	\N	5
4201270.03	Overige huisvestingskosten sanitaire voorzieningen	\N	5
4201270.04	Overige huisvestingskosten ongedierte bestrijding	\N	5
4201270.05	Overige huisvestingskosten reinigen vloer en buiten	\N	5
4201270.06	Overige huisvestingskosten beveiliging	\N	5
4201270.07	Overige huisvestingskosten kleine aanpassingen	\N	5
4201270.08	Overige huisvestingskosten bloemen	\N	5
4201270.09	Overige huisvestigingskosten interne huur huismeesterruimte	\N	5
4201270.10	Overige huisvestingskosten elektra huismeesterruimte	\N	5
4209010	Accountantshonoraria inzake het onderzoek van de jaarrekening accountants- en advieskosten	\N	3
4209020	Accountantshonoraria inzake andere controleopdrachten accountants- en advieskosten	\N	3
4209030	Accountantshonoraria inzake adviesdiensten op fiscaal terrein accountants- en advieskosten	\N	3
4209040	Accountantshonoraria inzake andere niet-controlediensten accountants- en advieskosten	\N	3
8405005	Waardeveranderingen groepsmaatschappijen	\N	3
8405010	Waardeveranderingen overige deelnemingen	\N	3
8405020	Langlopende vorderingen op deelnemingen	\N	3
8405030	Rekening-courant met deelnemingen	\N	3
8405040	Overige vorderingen	\N	3
8405060	Rekening-courant aandeelhouder	\N	3
8405070	Rekening-courant directie	\N	3
8405075	Leningen u/g	\N	3
8405130.01	Toegerekende organisatiekosten salarissen resultaat verkoop vastgoedportefeuille aan Verkoop Onder Voorwaarden	\N	5
8405130.02	Toegerekende organisatiekosten sociale lasten resultaat verkoop vastgoedportefeuille aan Verkoop Onder Voorwaarden	\N	5
8405130.03	Toegerekende organisatiekosten pensioenlasten resultaat verkoop vastgoedportefeuille aan Verkoop Onder Voorwaarden	\N	5
8405130.04	Toegerekende organisatiekosten afschrijvingen resultaat verkoop vastgoedportefeuille aan Verkoop Onder Voorwaarden	\N	5
8405130.05	Toegerekende organisatiekosten overige bedrijfslasten resultaat verkoop vastgoedportefeuille aan Verkoop Onder Voorwaarden	\N	5
8405130.06	Toegerekende organisatiekosten overige personeelslasten aan Verkoop Onder Voorwaarden	\N	5
8410015.01	Resultaat deelneming groepsmaatschappij 1	\N	5
8410015.02	Resultaat deelneming groepsmaatschappij 2	\N	5
8410015.03	Resultaat deelneming groepsmaatschappij 3	\N	5
8410015.04	Resultaat deelneming groepsmaatschappij 4	\N	5
8410015.05	Resultaat deelneming groepsmaatschappij 5	\N	5
\.


--
-- Data for Name: coa_definitions; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY public.coa_definitions (coa_id, name, country, version, created_at) FROM stdin;
1	RGS 3.7	Netherlands	3.7	2025-09-15 07:54:50.818128
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY public.companies (company_id, name, kvk_number, vat_number, coa_id, created_at) FROM stdin;
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY public.invoices (invoice_number, sender_company, sender_address, sender_vat, sender_kvk, sender_iban, receiver_company, receiver_address, receiver_vat, invoice_date, due_date, payment_terms, reference, subtotal, vat, total, currency, notes) FROM stdin;
149399531	KPN B.V.	Wilhelminakade 123, 3072 AP, Rotterdam	NL009292056B01	27124701	NL26 INGB 0000 0497 01	DTrading B.V.	Dorpsstraat 7, 4185 NA EST	\N	2025-08-13	2025-08-27	Automatic transfer on due date	\N	30.10	6.32	36.42	EUR	
\.


--
-- Data for Name: line_items; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY public.line_items (id, invoice_number, description, quantity, unit_price, line_total) FROM stdin;
1	149399531	KPN EEN Connext Centrale	1	5.00	5.00
2	149399531	KPN EEN Connext Pro Gebruiker	1	7.50	7.50
3	149399531	Telefoonnummer nieuw 1 085- nummer	1	1.00	1.00
4	149399531	KPN EEN Connext Pro Gebruiker (one-time fee)	1	15.00	15.00
5	149399531	Telefoonnummer actiekorting 6 maanden	1	-1.21	-1.21
6	149399531	KPN EEN Connext Centrale	1	5.00	5.00
7	149399531	KPN EEN Connext Pro Gebruiker	1	7.50	7.50
8	149399531	Telefoonnummer nieuw 1 085- nummer	1	1.00	1.00
9	149399531	KPN EEN Connext Pro Gebruiker (one-time fee)	1	15.00	15.00
10	149399531	Telefoonnummer actiekorting 6 maanden	1	-1.21	-1.21
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY public.transactions (transaction_id, company_id, account_id, date, description, debit, credit, created_at) FROM stdin;
\.


--
-- Name: accounts_account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jean
--

SELECT pg_catalog.setval('public.accounts_account_id_seq', 4964, true);


--
-- Name: bookings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jean
--

SELECT pg_catalog.setval('public.bookings_id_seq', 3, true);


--
-- Name: coa_definitions_coa_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jean
--

SELECT pg_catalog.setval('public.coa_definitions_coa_id_seq', 1, false);


--
-- Name: companies_company_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jean
--

SELECT pg_catalog.setval('public.companies_company_id_seq', 1, false);


--
-- Name: line_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jean
--

SELECT pg_catalog.setval('public.line_items_id_seq', 10, true);


--
-- Name: transactions_transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jean
--

SELECT pg_catalog.setval('public.transactions_transaction_id_seq', 1, false);


--
-- Name: accounts accounts_code_unique; Type: CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_code_unique UNIQUE (code);


--
-- Name: accounts accounts_number_unique; Type: CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_number_unique UNIQUE (number);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (account_id);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: coa_definitions coa_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.coa_definitions
    ADD CONSTRAINT coa_definitions_pkey PRIMARY KEY (coa_id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (company_id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (invoice_number);


--
-- Name: line_items line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.line_items
    ADD CONSTRAINT line_items_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (transaction_id);


--
-- Name: idx_coa_description; Type: INDEX; Schema: public; Owner: jean
--

CREATE INDEX idx_coa_description ON public.coa USING gin (description public.gin_trgm_ops);


--
-- Name: accounts accounts_coa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_coa_id_fkey FOREIGN KEY (coa_id) REFERENCES public.coa_definitions(coa_id) ON DELETE CASCADE;


--
-- Name: bookings bookings_account_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_account_number_fkey FOREIGN KEY (account_code) REFERENCES public.accounts(number);


--
-- Name: companies companies_coa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_coa_id_fkey FOREIGN KEY (coa_id) REFERENCES public.coa_definitions(coa_id);


--
-- Name: line_items line_items_invoice_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.line_items
    ADD CONSTRAINT line_items_invoice_number_fkey FOREIGN KEY (invoice_number) REFERENCES public.invoices(invoice_number);


--
-- Name: transactions transactions_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(account_id);


--
-- Name: transactions transactions_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(company_id);


--
-- PostgreSQL database dump complete
--

\unrestrict oRSgkdMq64lDV0WK9TYMBWHuuJ36Qif839Pffbr5MdVVuveFOqe6elpSCrPqdz1

