--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.3

-- Started on 2025-11-08 23:48:50

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
-- TOC entry 8 (class 2615 OID 47100)
-- Name: dw; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dw;


ALTER SCHEMA dw OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 47099)
-- Name: ods; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA ods;


ALTER SCHEMA ods OWNER TO postgres;

--
-- TOC entry 6 (class 2615 OID 47098)
-- Name: staging; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA staging;


ALTER SCHEMA staging OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 47483)
-- Name: dblink; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA staging;


--
-- TOC entry 5059 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


--
-- TOC entry 301 (class 1255 OID 47656)
-- Name: p_dwh_dt_actividad(); Type: PROCEDURE; Schema: dw; Owner: postgres
--

CREATE PROCEDURE dw.p_dwh_dt_actividad()
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO dw.dt_actividad (id_actividad, nombre_actividad, tipo_pago, costo, duracion, id_tipo_actividad_sk, id_espacio_sk)
    SELECT 
        a.id_actividad,
        a.nombre_actividad,
        UPPER(a.tipo_pago) AS tipo_pago,
        a.costo,
        a.duracion,
        t.sk_tipo_actividad AS id_tipo_actividad_sk,
        e.sk_espacio AS id_espacio_sk
    FROM ods.ods_d_actividad a
    JOIN dw.dt_tipo_actividad t ON a.id_tipo_actividad = t.id_tipo_actividad
    JOIN dw.dt_espacio e ON a.id_espacio = e.id_espacio
    ON CONFLICT (id_actividad) DO UPDATE
    SET nombre_actividad = EXCLUDED.nombre_actividad,
        tipo_pago = EXCLUDED.tipo_pago,
        costo = EXCLUDED.costo,
        duracion = EXCLUDED.duracion,
        id_tipo_actividad_sk = EXCLUDED.id_tipo_actividad_sk,
        id_espacio_sk = EXCLUDED.id_espacio_sk;
END;
$$;


ALTER PROCEDURE dw.p_dwh_dt_actividad() OWNER TO postgres;

--
-- TOC entry 288 (class 1255 OID 47655)
-- Name: p_dwh_dt_espacio(); Type: PROCEDURE; Schema: dw; Owner: postgres
--

CREATE PROCEDURE dw.p_dwh_dt_espacio()
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO dw.dt_espacio (id_espacio, nombre_espacio, capacidad, estado)
    SELECT id_espacio, nombre_espacio, capacidad, estado
    FROM ods.ods_d_espacio
    ON CONFLICT (id_espacio) DO UPDATE
    SET nombre_espacio = EXCLUDED.nombre_espacio,
        capacidad = EXCLUDED.capacidad,
        estado = EXCLUDED.estado;
END;
$$;


ALTER PROCEDURE dw.p_dwh_dt_espacio() OWNER TO postgres;

--
-- TOC entry 300 (class 1255 OID 47657)
-- Name: p_dwh_dt_tiempo(date, date); Type: PROCEDURE; Schema: dw; Owner: postgres
--

CREATE PROCEDURE dw.p_dwh_dt_tiempo(IN start_date date, IN end_date date)
    LANGUAGE plpgsql
    AS $$
DECLARE
    d DATE := start_date;
BEGIN
    WHILE d <= end_date LOOP
        INSERT INTO dw.dt_tiempo(fecha_sk, fecha, dia, mes, anio, trimestre, dia_semana)
        VALUES (
            TO_CHAR(d,'YYYYMMDD')::INT,
            d,
            EXTRACT(DAY FROM d)::INT,
            EXTRACT(MONTH FROM d)::INT,
            EXTRACT(YEAR FROM d)::INT,
            EXTRACT(QUARTER FROM d)::INT,
            EXTRACT(DOW FROM d)::INT
        )
        ON CONFLICT (fecha_sk) DO NOTHING;

        d := d + INTERVAL '1 day';
    END LOOP;
END;
$$;


ALTER PROCEDURE dw.p_dwh_dt_tiempo(IN start_date date, IN end_date date) OWNER TO postgres;

--
-- TOC entry 287 (class 1255 OID 47654)
-- Name: p_dwh_dt_tipo_actividad(); Type: PROCEDURE; Schema: dw; Owner: postgres
--

CREATE PROCEDURE dw.p_dwh_dt_tipo_actividad()
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO dw.dt_tipo_actividad (id_tipo_actividad, nombre_tipo, descripcion)
    SELECT id_tipo_actividad, nombre_tipo, descripcion
    FROM ods.ods_d_tipo_actividad
    ON CONFLICT (id_tipo_actividad) DO UPDATE
    SET nombre_tipo = EXCLUDED.nombre_tipo,
        descripcion = EXCLUDED.descripcion;
END;
$$;


ALTER PROCEDURE dw.p_dwh_dt_tipo_actividad() OWNER TO postgres;

--
-- TOC entry 286 (class 1255 OID 47653)
-- Name: p_dwh_dt_usuario(); Type: PROCEDURE; Schema: dw; Owner: postgres
--

CREATE PROCEDURE dw.p_dwh_dt_usuario()
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO dw.dt_usuario (id_usuario, nombre_completo, tipo_usuario, correo, estado)
    SELECT id_usuario, nombre_completo, tipo_usuario, correo, estado
    FROM ods.ods_d_usuario
    ON CONFLICT (id_usuario) DO UPDATE
    SET nombre_completo = EXCLUDED.nombre_completo,
        tipo_usuario = EXCLUDED.tipo_usuario,
        correo = EXCLUDED.correo,
        estado = EXCLUDED.estado;
END;
$$;


ALTER PROCEDURE dw.p_dwh_dt_usuario() OWNER TO postgres;

--
-- TOC entry 302 (class 1255 OID 47669)
-- Name: p_dwh_ht_inscriptos(); Type: PROCEDURE; Schema: dw; Owner: postgres
--

CREATE PROCEDURE dw.p_dwh_ht_inscriptos()
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO dw.ht_inscriptos (
        sk_usuario, 
        sk_actividad, 
        sk_fecha, 
        ins_cancelada,
        id_espacio_sk,
        id_tipo_actividad_sk
    )
    SELECT 
        u.sk_usuario AS sk_usuario,
        a.sk_actividad AS sk_actividad,
        TO_CHAR(h.fecha_inscripcion,'YYYYMMDD')::INT AS sk_fecha,
        h.ins_cancelada,
        a.id_espacio_sk,
        a.id_tipo_actividad_sk
    FROM ods.ods_h_inscriptos h
    JOIN dw.dt_usuario u ON h.id_usuario = u.id_usuario
    JOIN dw.dt_actividad a ON h.id_actividad = a.id_actividad
    ON CONFLICT (sk_usuario, sk_actividad, sk_fecha)
    DO UPDATE 
        SET ins_cancelada = EXCLUDED.ins_cancelada,
            id_espacio_sk = EXCLUDED.id_espacio_sk,
            id_tipo_actividad_sk = EXCLUDED.id_tipo_actividad_sk;
END;
$$;


ALTER PROCEDURE dw.p_dwh_ht_inscriptos() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 238 (class 1259 OID 47606)
-- Name: dt_actividad; Type: TABLE; Schema: dw; Owner: postgres
--

CREATE TABLE dw.dt_actividad (
    sk_actividad integer NOT NULL,
    id_actividad bigint,
    nombre_actividad character varying(100),
    tipo_pago character varying(20),
    costo numeric(10,2),
    duracion integer,
    id_tipo_actividad_sk integer,
    id_espacio_sk integer
);


ALTER TABLE dw.dt_actividad OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 47605)
-- Name: dt_actividad_sk_actividad_seq; Type: SEQUENCE; Schema: dw; Owner: postgres
--

CREATE SEQUENCE dw.dt_actividad_sk_actividad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dw.dt_actividad_sk_actividad_seq OWNER TO postgres;

--
-- TOC entry 5060 (class 0 OID 0)
-- Dependencies: 237
-- Name: dt_actividad_sk_actividad_seq; Type: SEQUENCE OWNED BY; Schema: dw; Owner: postgres
--

ALTER SEQUENCE dw.dt_actividad_sk_actividad_seq OWNED BY dw.dt_actividad.sk_actividad;


--
-- TOC entry 236 (class 1259 OID 47597)
-- Name: dt_espacio; Type: TABLE; Schema: dw; Owner: postgres
--

CREATE TABLE dw.dt_espacio (
    sk_espacio integer NOT NULL,
    id_espacio integer,
    nombre_espacio character varying(100),
    capacidad integer,
    estado boolean
);


ALTER TABLE dw.dt_espacio OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 47596)
-- Name: dt_espacio_sk_espacio_seq; Type: SEQUENCE; Schema: dw; Owner: postgres
--

CREATE SEQUENCE dw.dt_espacio_sk_espacio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dw.dt_espacio_sk_espacio_seq OWNER TO postgres;

--
-- TOC entry 5061 (class 0 OID 0)
-- Dependencies: 235
-- Name: dt_espacio_sk_espacio_seq; Type: SEQUENCE OWNED BY; Schema: dw; Owner: postgres
--

ALTER SEQUENCE dw.dt_espacio_sk_espacio_seq OWNED BY dw.dt_espacio.sk_espacio;


--
-- TOC entry 239 (class 1259 OID 47624)
-- Name: dt_tiempo; Type: TABLE; Schema: dw; Owner: postgres
--

CREATE TABLE dw.dt_tiempo (
    fecha_sk integer NOT NULL,
    fecha date,
    dia integer,
    mes integer,
    anio integer,
    trimestre integer,
    dia_semana integer
);


ALTER TABLE dw.dt_tiempo OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 47588)
-- Name: dt_tipo_actividad; Type: TABLE; Schema: dw; Owner: postgres
--

CREATE TABLE dw.dt_tipo_actividad (
    sk_tipo_actividad integer NOT NULL,
    id_tipo_actividad integer,
    nombre_tipo character varying(50),
    descripcion character varying(255)
);


ALTER TABLE dw.dt_tipo_actividad OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 47587)
-- Name: dt_tipo_actividad_sk_tipo_actividad_seq; Type: SEQUENCE; Schema: dw; Owner: postgres
--

CREATE SEQUENCE dw.dt_tipo_actividad_sk_tipo_actividad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dw.dt_tipo_actividad_sk_tipo_actividad_seq OWNER TO postgres;

--
-- TOC entry 5062 (class 0 OID 0)
-- Dependencies: 233
-- Name: dt_tipo_actividad_sk_tipo_actividad_seq; Type: SEQUENCE OWNED BY; Schema: dw; Owner: postgres
--

ALTER SEQUENCE dw.dt_tipo_actividad_sk_tipo_actividad_seq OWNED BY dw.dt_tipo_actividad.sk_tipo_actividad;


--
-- TOC entry 232 (class 1259 OID 47579)
-- Name: dt_usuario; Type: TABLE; Schema: dw; Owner: postgres
--

CREATE TABLE dw.dt_usuario (
    sk_usuario integer NOT NULL,
    id_usuario bigint,
    nombre_completo character varying(150),
    tipo_usuario character varying(50),
    correo character varying(100),
    estado boolean
);


ALTER TABLE dw.dt_usuario OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 47578)
-- Name: dt_usuario_sk_usuario_seq; Type: SEQUENCE; Schema: dw; Owner: postgres
--

CREATE SEQUENCE dw.dt_usuario_sk_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dw.dt_usuario_sk_usuario_seq OWNER TO postgres;

--
-- TOC entry 5063 (class 0 OID 0)
-- Dependencies: 231
-- Name: dt_usuario_sk_usuario_seq; Type: SEQUENCE OWNED BY; Schema: dw; Owner: postgres
--

ALTER SEQUENCE dw.dt_usuario_sk_usuario_seq OWNED BY dw.dt_usuario.sk_usuario;


--
-- TOC entry 241 (class 1259 OID 47630)
-- Name: ht_inscriptos; Type: TABLE; Schema: dw; Owner: postgres
--

CREATE TABLE dw.ht_inscriptos (
    id_inscripcion bigint NOT NULL,
    sk_usuario integer,
    sk_actividad integer,
    sk_fecha integer,
    ins_cancelada boolean,
    id_espacio_sk integer,
    id_tipo_actividad_sk integer
);


ALTER TABLE dw.ht_inscriptos OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 47629)
-- Name: ht_inscriptos_id_inscripcion_seq; Type: SEQUENCE; Schema: dw; Owner: postgres
--

CREATE SEQUENCE dw.ht_inscriptos_id_inscripcion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dw.ht_inscriptos_id_inscripcion_seq OWNER TO postgres;

--
-- TOC entry 5064 (class 0 OID 0)
-- Dependencies: 240
-- Name: ht_inscriptos_id_inscripcion_seq; Type: SEQUENCE OWNED BY; Schema: dw; Owner: postgres
--

ALTER SEQUENCE dw.ht_inscriptos_id_inscripcion_seq OWNED BY dw.ht_inscriptos.id_inscripcion;


--
-- TOC entry 243 (class 1259 OID 47686)
-- Name: vw_actividades_mes; Type: VIEW; Schema: dw; Owner: postgres
--

CREATE VIEW dw.vw_actividades_mes AS
 SELECT ta.nombre_tipo AS tipo_actividad,
    a.nombre_actividad,
    t.anio,
    t.mes,
    count(h.id_inscripcion) AS cantidad_inscripciones,
    round((((sum(
        CASE
            WHEN h.ins_cancelada THEN 1
            ELSE 0
        END))::numeric / (count(*))::numeric) * (100)::numeric), 2) AS tasa_cancelacion
   FROM (((dw.ht_inscriptos h
     JOIN dw.dt_actividad a ON ((h.sk_actividad = a.sk_actividad)))
     JOIN dw.dt_tipo_actividad ta ON ((a.id_tipo_actividad_sk = ta.sk_tipo_actividad)))
     JOIN dw.dt_tiempo t ON ((h.sk_fecha = t.fecha_sk)))
  GROUP BY ta.nombre_tipo, a.nombre_actividad, t.anio, t.mes
  ORDER BY t.anio, t.mes, (count(h.id_inscripcion)) DESC;


ALTER VIEW dw.vw_actividades_mes OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 47675)
-- Name: vw_espacios_mes; Type: VIEW; Schema: dw; Owner: postgres
--

CREATE VIEW dw.vw_espacios_mes AS
 SELECT e.nombre_espacio,
    t.anio,
    t.mes,
    count(h.id_inscripcion) AS cantidad_inscripciones,
    round((((sum(
        CASE
            WHEN h.ins_cancelada THEN 1
            ELSE 0
        END))::numeric / (count(*))::numeric) * (100)::numeric), 2) AS tasa_cancelacion
   FROM (((dw.ht_inscriptos h
     JOIN dw.dt_actividad a ON ((h.sk_actividad = a.sk_actividad)))
     JOIN dw.dt_espacio e ON ((a.id_espacio_sk = e.sk_espacio)))
     JOIN dw.dt_tiempo t ON ((h.sk_fecha = t.fecha_sk)))
  GROUP BY e.nombre_espacio, t.anio, t.mes
  ORDER BY t.anio, t.mes, (count(h.id_inscripcion)) DESC;


ALTER VIEW dw.vw_espacios_mes OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 47692)
-- Name: vw_participacion_socio_mes; Type: VIEW; Schema: dw; Owner: postgres
--

CREATE VIEW dw.vw_participacion_socio_mes AS
 SELECT ta.nombre_tipo AS tipo_actividad,
    t.anio,
    t.mes,
    u.tipo_usuario,
    count(h.id_inscripcion) AS cantidad_inscripciones,
    round((((sum(
        CASE
            WHEN h.ins_cancelada THEN 1
            ELSE 0
        END))::numeric / (count(*))::numeric) * (100)::numeric), 2) AS tasa_cancelacion
   FROM ((((dw.ht_inscriptos h
     JOIN dw.dt_usuario u ON ((h.sk_usuario = u.sk_usuario)))
     JOIN dw.dt_actividad a ON ((h.sk_actividad = a.sk_actividad)))
     JOIN dw.dt_tipo_actividad ta ON ((a.id_tipo_actividad_sk = ta.sk_tipo_actividad)))
     JOIN dw.dt_tiempo t ON ((h.sk_fecha = t.fecha_sk)))
  GROUP BY ta.nombre_tipo, t.anio, t.mes, u.tipo_usuario
  ORDER BY t.anio, t.mes, ta.nombre_tipo, u.tipo_usuario;


ALTER VIEW dw.vw_participacion_socio_mes OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 47544)
-- Name: ods_d_actividad; Type: TABLE; Schema: ods; Owner: postgres
--

CREATE TABLE ods.ods_d_actividad (
    id_actividad bigint NOT NULL,
    nombre_actividad character varying(100),
    tipo_pago character varying(20),
    costo numeric(10,2),
    duracion integer,
    id_tipo_actividad integer,
    id_espacio integer
);


ALTER TABLE ods.ods_d_actividad OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 47534)
-- Name: ods_d_espacio; Type: TABLE; Schema: ods; Owner: postgres
--

CREATE TABLE ods.ods_d_espacio (
    id_espacio integer NOT NULL,
    nombre_espacio character varying(100),
    capacidad integer,
    estado boolean
);


ALTER TABLE ods.ods_d_espacio OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 47529)
-- Name: ods_d_tipo_actividad; Type: TABLE; Schema: ods; Owner: postgres
--

CREATE TABLE ods.ods_d_tipo_actividad (
    id_tipo_actividad integer NOT NULL,
    nombre_tipo character varying(50),
    descripcion character varying(255)
);


ALTER TABLE ods.ods_d_tipo_actividad OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 47539)
-- Name: ods_d_usuario; Type: TABLE; Schema: ods; Owner: postgres
--

CREATE TABLE ods.ods_d_usuario (
    id_usuario bigint NOT NULL,
    correo character varying(100),
    estado boolean,
    nombre_completo character varying(150),
    tipo_usuario character varying(50)
);


ALTER TABLE ods.ods_d_usuario OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 47560)
-- Name: ods_h_inscriptos; Type: TABLE; Schema: ods; Owner: postgres
--

CREATE TABLE ods.ods_h_inscriptos (
    id_inscripcion integer NOT NULL,
    id_usuario bigint,
    id_actividad bigint,
    fecha_inscripcion date,
    mes_inscripcion integer,
    anio_inscripcion integer,
    ins_cancelada boolean
);


ALTER TABLE ods.ods_h_inscriptos OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 47559)
-- Name: ods_h_inscriptos_id_inscripcion_seq; Type: SEQUENCE; Schema: ods; Owner: postgres
--

CREATE SEQUENCE ods.ods_h_inscriptos_id_inscripcion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ods.ods_h_inscriptos_id_inscripcion_seq OWNER TO postgres;

--
-- TOC entry 5065 (class 0 OID 0)
-- Dependencies: 229
-- Name: ods_h_inscriptos_id_inscripcion_seq; Type: SEQUENCE OWNED BY; Schema: ods; Owner: postgres
--

ALTER SEQUENCE ods.ods_h_inscriptos_id_inscripcion_seq OWNED BY ods.ods_h_inscriptos.id_inscripcion;


--
-- TOC entry 221 (class 1259 OID 47451)
-- Name: d_actividad; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE staging.d_actividad (
    id_actividad bigint NOT NULL,
    nombre_actividad character varying(100),
    tipo_pago character varying(20),
    costo numeric(10,2),
    duracion integer,
    id_tipo_actividad integer,
    id_espacio integer
);


ALTER TABLE staging.d_actividad OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 47424)
-- Name: d_espacio; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE staging.d_espacio (
    id_espacio integer NOT NULL,
    nombre_espacio character varying(100),
    capacidad integer,
    estado boolean
);


ALTER TABLE staging.d_espacio OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 47419)
-- Name: d_tipo_actividad; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE staging.d_tipo_actividad (
    id_tipo_actividad integer NOT NULL,
    nombre_tipo character varying(50),
    descripcion character varying(255)
);


ALTER TABLE staging.d_tipo_actividad OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 47414)
-- Name: d_usuario; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE staging.d_usuario (
    id_usuario bigint NOT NULL,
    nombre_completo character varying(150),
    tipo_usuario character varying(50),
    correo character varying(100),
    telefono character varying(50),
    id_ciudad integer,
    categoria_socio character varying(50),
    dif_auditiva boolean,
    len_sena boolean
);


ALTER TABLE staging.d_usuario OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 47467)
-- Name: h_inscriptos; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE staging.h_inscriptos (
    id_inscripcion integer NOT NULL,
    id_usuario bigint,
    id_actividad bigint,
    fecha_inscripcion date,
    ins_cancelada boolean
);


ALTER TABLE staging.h_inscriptos OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 47466)
-- Name: h_inscriptos_id_inscripcion_seq; Type: SEQUENCE; Schema: staging; Owner: postgres
--

CREATE SEQUENCE staging.h_inscriptos_id_inscripcion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE staging.h_inscriptos_id_inscripcion_seq OWNER TO postgres;

--
-- TOC entry 5066 (class 0 OID 0)
-- Dependencies: 222
-- Name: h_inscriptos_id_inscripcion_seq; Type: SEQUENCE OWNED BY; Schema: staging; Owner: postgres
--

ALTER SEQUENCE staging.h_inscriptos_id_inscripcion_seq OWNED BY staging.h_inscriptos.id_inscripcion;


--
-- TOC entry 4826 (class 2604 OID 47609)
-- Name: dt_actividad sk_actividad; Type: DEFAULT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_actividad ALTER COLUMN sk_actividad SET DEFAULT nextval('dw.dt_actividad_sk_actividad_seq'::regclass);


--
-- TOC entry 4825 (class 2604 OID 47600)
-- Name: dt_espacio sk_espacio; Type: DEFAULT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_espacio ALTER COLUMN sk_espacio SET DEFAULT nextval('dw.dt_espacio_sk_espacio_seq'::regclass);


--
-- TOC entry 4824 (class 2604 OID 47591)
-- Name: dt_tipo_actividad sk_tipo_actividad; Type: DEFAULT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_tipo_actividad ALTER COLUMN sk_tipo_actividad SET DEFAULT nextval('dw.dt_tipo_actividad_sk_tipo_actividad_seq'::regclass);


--
-- TOC entry 4823 (class 2604 OID 47582)
-- Name: dt_usuario sk_usuario; Type: DEFAULT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_usuario ALTER COLUMN sk_usuario SET DEFAULT nextval('dw.dt_usuario_sk_usuario_seq'::regclass);


--
-- TOC entry 4827 (class 2604 OID 47633)
-- Name: ht_inscriptos id_inscripcion; Type: DEFAULT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.ht_inscriptos ALTER COLUMN id_inscripcion SET DEFAULT nextval('dw.ht_inscriptos_id_inscripcion_seq'::regclass);


--
-- TOC entry 4822 (class 2604 OID 47563)
-- Name: ods_h_inscriptos id_inscripcion; Type: DEFAULT; Schema: ods; Owner: postgres
--

ALTER TABLE ONLY ods.ods_h_inscriptos ALTER COLUMN id_inscripcion SET DEFAULT nextval('ods.ods_h_inscriptos_id_inscripcion_seq'::regclass);


--
-- TOC entry 4821 (class 2604 OID 47470)
-- Name: h_inscriptos id_inscripcion; Type: DEFAULT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY staging.h_inscriptos ALTER COLUMN id_inscripcion SET DEFAULT nextval('staging.h_inscriptos_id_inscripcion_seq'::regclass);


--
-- TOC entry 5050 (class 0 OID 47606)
-- Dependencies: 238
-- Data for Name: dt_actividad; Type: TABLE DATA; Schema: dw; Owner: postgres
--

COPY dw.dt_actividad (sk_actividad, id_actividad, nombre_actividad, tipo_pago, costo, duracion, id_tipo_actividad_sk, id_espacio_sk) FROM stdin;
16	1	Taller LSU	TRANSFER	300.00	90	9	9
17	2	Charla sobre inclusión	EFECTIVO	0.00	60	10	11
18	3	Evento Día del Sordo	TRANSFER	200.00	180	11	9
19	4	Taller de cocina	EFECTIVO	250.00	120	9	10
20	5	Charla de accesibilidad	TRANSFER	0.00	60	10	11
21	6	Clases de fútbol adaptado	TRANSFER	150.00	120	12	12
22	7	Taller de pintura	EFECTIVO	200.00	90	9	10
23	8	Charla motivacional	EFECTIVO	0.00	60	10	11
24	9	Feria de integración	TRANSFER	100.00	180	11	9
25	10	Taller de música	EFECTIVO	250.00	120	9	9
26	11	Taller de tecnología accesible	TRANSFER	200.00	120	9	10
27	12	Charla de salud auditiva	EFECTIVO	0.00	60	10	11
28	13	Taller de costura inclusiva	EFECTIVO	180.00	90	9	10
29	14	Evento de fin de año	TRANSFER	300.00	180	11	9
30	15	Torneo recreativo	EFECTIVO	100.00	120	12	12
\.


--
-- TOC entry 5048 (class 0 OID 47597)
-- Dependencies: 236
-- Data for Name: dt_espacio; Type: TABLE DATA; Schema: dw; Owner: postgres
--

COPY dw.dt_espacio (sk_espacio, id_espacio, nombre_espacio, capacidad, estado) FROM stdin;
9	1	Salón Principal	50	t
10	2	Aula Taller	25	t
11	3	Sala Reuniones	15	t
12	4	Patio Exterior	40	t
\.


--
-- TOC entry 5051 (class 0 OID 47624)
-- Dependencies: 239
-- Data for Name: dt_tiempo; Type: TABLE DATA; Schema: dw; Owner: postgres
--

COPY dw.dt_tiempo (fecha_sk, fecha, dia, mes, anio, trimestre, dia_semana) FROM stdin;
20230101	2023-01-01	1	1	2023	1	0
20230102	2023-01-02	2	1	2023	1	1
20230103	2023-01-03	3	1	2023	1	2
20230104	2023-01-04	4	1	2023	1	3
20230105	2023-01-05	5	1	2023	1	4
20230106	2023-01-06	6	1	2023	1	5
20230107	2023-01-07	7	1	2023	1	6
20230108	2023-01-08	8	1	2023	1	0
20230109	2023-01-09	9	1	2023	1	1
20230110	2023-01-10	10	1	2023	1	2
20230111	2023-01-11	11	1	2023	1	3
20230112	2023-01-12	12	1	2023	1	4
20230113	2023-01-13	13	1	2023	1	5
20230114	2023-01-14	14	1	2023	1	6
20230115	2023-01-15	15	1	2023	1	0
20230116	2023-01-16	16	1	2023	1	1
20230117	2023-01-17	17	1	2023	1	2
20230118	2023-01-18	18	1	2023	1	3
20230119	2023-01-19	19	1	2023	1	4
20230120	2023-01-20	20	1	2023	1	5
20230121	2023-01-21	21	1	2023	1	6
20230122	2023-01-22	22	1	2023	1	0
20230123	2023-01-23	23	1	2023	1	1
20230124	2023-01-24	24	1	2023	1	2
20230125	2023-01-25	25	1	2023	1	3
20230126	2023-01-26	26	1	2023	1	4
20230127	2023-01-27	27	1	2023	1	5
20230128	2023-01-28	28	1	2023	1	6
20230129	2023-01-29	29	1	2023	1	0
20230130	2023-01-30	30	1	2023	1	1
20230131	2023-01-31	31	1	2023	1	2
20230201	2023-02-01	1	2	2023	1	3
20230202	2023-02-02	2	2	2023	1	4
20230203	2023-02-03	3	2	2023	1	5
20230204	2023-02-04	4	2	2023	1	6
20230205	2023-02-05	5	2	2023	1	0
20230206	2023-02-06	6	2	2023	1	1
20230207	2023-02-07	7	2	2023	1	2
20230208	2023-02-08	8	2	2023	1	3
20230209	2023-02-09	9	2	2023	1	4
20230210	2023-02-10	10	2	2023	1	5
20230211	2023-02-11	11	2	2023	1	6
20230212	2023-02-12	12	2	2023	1	0
20230213	2023-02-13	13	2	2023	1	1
20230214	2023-02-14	14	2	2023	1	2
20230215	2023-02-15	15	2	2023	1	3
20230216	2023-02-16	16	2	2023	1	4
20230217	2023-02-17	17	2	2023	1	5
20230218	2023-02-18	18	2	2023	1	6
20230219	2023-02-19	19	2	2023	1	0
20230220	2023-02-20	20	2	2023	1	1
20230221	2023-02-21	21	2	2023	1	2
20230222	2023-02-22	22	2	2023	1	3
20230223	2023-02-23	23	2	2023	1	4
20230224	2023-02-24	24	2	2023	1	5
20230225	2023-02-25	25	2	2023	1	6
20230226	2023-02-26	26	2	2023	1	0
20230227	2023-02-27	27	2	2023	1	1
20230228	2023-02-28	28	2	2023	1	2
20230301	2023-03-01	1	3	2023	1	3
20230302	2023-03-02	2	3	2023	1	4
20230303	2023-03-03	3	3	2023	1	5
20230304	2023-03-04	4	3	2023	1	6
20230305	2023-03-05	5	3	2023	1	0
20230306	2023-03-06	6	3	2023	1	1
20230307	2023-03-07	7	3	2023	1	2
20230308	2023-03-08	8	3	2023	1	3
20230309	2023-03-09	9	3	2023	1	4
20230310	2023-03-10	10	3	2023	1	5
20230311	2023-03-11	11	3	2023	1	6
20230312	2023-03-12	12	3	2023	1	0
20230313	2023-03-13	13	3	2023	1	1
20230314	2023-03-14	14	3	2023	1	2
20230315	2023-03-15	15	3	2023	1	3
20230316	2023-03-16	16	3	2023	1	4
20230317	2023-03-17	17	3	2023	1	5
20230318	2023-03-18	18	3	2023	1	6
20230319	2023-03-19	19	3	2023	1	0
20230320	2023-03-20	20	3	2023	1	1
20230321	2023-03-21	21	3	2023	1	2
20230322	2023-03-22	22	3	2023	1	3
20230323	2023-03-23	23	3	2023	1	4
20230324	2023-03-24	24	3	2023	1	5
20230325	2023-03-25	25	3	2023	1	6
20230326	2023-03-26	26	3	2023	1	0
20230327	2023-03-27	27	3	2023	1	1
20230328	2023-03-28	28	3	2023	1	2
20230329	2023-03-29	29	3	2023	1	3
20230330	2023-03-30	30	3	2023	1	4
20230331	2023-03-31	31	3	2023	1	5
20230401	2023-04-01	1	4	2023	2	6
20230402	2023-04-02	2	4	2023	2	0
20230403	2023-04-03	3	4	2023	2	1
20230404	2023-04-04	4	4	2023	2	2
20230405	2023-04-05	5	4	2023	2	3
20230406	2023-04-06	6	4	2023	2	4
20230407	2023-04-07	7	4	2023	2	5
20230408	2023-04-08	8	4	2023	2	6
20230409	2023-04-09	9	4	2023	2	0
20230410	2023-04-10	10	4	2023	2	1
20230411	2023-04-11	11	4	2023	2	2
20230412	2023-04-12	12	4	2023	2	3
20230413	2023-04-13	13	4	2023	2	4
20230414	2023-04-14	14	4	2023	2	5
20230415	2023-04-15	15	4	2023	2	6
20230416	2023-04-16	16	4	2023	2	0
20230417	2023-04-17	17	4	2023	2	1
20230418	2023-04-18	18	4	2023	2	2
20230419	2023-04-19	19	4	2023	2	3
20230420	2023-04-20	20	4	2023	2	4
20230421	2023-04-21	21	4	2023	2	5
20230422	2023-04-22	22	4	2023	2	6
20230423	2023-04-23	23	4	2023	2	0
20230424	2023-04-24	24	4	2023	2	1
20230425	2023-04-25	25	4	2023	2	2
20230426	2023-04-26	26	4	2023	2	3
20230427	2023-04-27	27	4	2023	2	4
20230428	2023-04-28	28	4	2023	2	5
20230429	2023-04-29	29	4	2023	2	6
20230430	2023-04-30	30	4	2023	2	0
20230501	2023-05-01	1	5	2023	2	1
20230502	2023-05-02	2	5	2023	2	2
20230503	2023-05-03	3	5	2023	2	3
20230504	2023-05-04	4	5	2023	2	4
20230505	2023-05-05	5	5	2023	2	5
20230506	2023-05-06	6	5	2023	2	6
20230507	2023-05-07	7	5	2023	2	0
20230508	2023-05-08	8	5	2023	2	1
20230509	2023-05-09	9	5	2023	2	2
20230510	2023-05-10	10	5	2023	2	3
20230511	2023-05-11	11	5	2023	2	4
20230512	2023-05-12	12	5	2023	2	5
20230513	2023-05-13	13	5	2023	2	6
20230514	2023-05-14	14	5	2023	2	0
20230515	2023-05-15	15	5	2023	2	1
20230516	2023-05-16	16	5	2023	2	2
20230517	2023-05-17	17	5	2023	2	3
20230518	2023-05-18	18	5	2023	2	4
20230519	2023-05-19	19	5	2023	2	5
20230520	2023-05-20	20	5	2023	2	6
20230521	2023-05-21	21	5	2023	2	0
20230522	2023-05-22	22	5	2023	2	1
20230523	2023-05-23	23	5	2023	2	2
20230524	2023-05-24	24	5	2023	2	3
20230525	2023-05-25	25	5	2023	2	4
20230526	2023-05-26	26	5	2023	2	5
20230527	2023-05-27	27	5	2023	2	6
20230528	2023-05-28	28	5	2023	2	0
20230529	2023-05-29	29	5	2023	2	1
20230530	2023-05-30	30	5	2023	2	2
20230531	2023-05-31	31	5	2023	2	3
20230601	2023-06-01	1	6	2023	2	4
20230602	2023-06-02	2	6	2023	2	5
20230603	2023-06-03	3	6	2023	2	6
20230604	2023-06-04	4	6	2023	2	0
20230605	2023-06-05	5	6	2023	2	1
20230606	2023-06-06	6	6	2023	2	2
20230607	2023-06-07	7	6	2023	2	3
20230608	2023-06-08	8	6	2023	2	4
20230609	2023-06-09	9	6	2023	2	5
20230610	2023-06-10	10	6	2023	2	6
20230611	2023-06-11	11	6	2023	2	0
20230612	2023-06-12	12	6	2023	2	1
20230613	2023-06-13	13	6	2023	2	2
20230614	2023-06-14	14	6	2023	2	3
20230615	2023-06-15	15	6	2023	2	4
20230616	2023-06-16	16	6	2023	2	5
20230617	2023-06-17	17	6	2023	2	6
20230618	2023-06-18	18	6	2023	2	0
20230619	2023-06-19	19	6	2023	2	1
20230620	2023-06-20	20	6	2023	2	2
20230621	2023-06-21	21	6	2023	2	3
20230622	2023-06-22	22	6	2023	2	4
20230623	2023-06-23	23	6	2023	2	5
20230624	2023-06-24	24	6	2023	2	6
20230625	2023-06-25	25	6	2023	2	0
20230626	2023-06-26	26	6	2023	2	1
20230627	2023-06-27	27	6	2023	2	2
20230628	2023-06-28	28	6	2023	2	3
20230629	2023-06-29	29	6	2023	2	4
20230630	2023-06-30	30	6	2023	2	5
20230701	2023-07-01	1	7	2023	3	6
20230702	2023-07-02	2	7	2023	3	0
20230703	2023-07-03	3	7	2023	3	1
20230704	2023-07-04	4	7	2023	3	2
20230705	2023-07-05	5	7	2023	3	3
20230706	2023-07-06	6	7	2023	3	4
20230707	2023-07-07	7	7	2023	3	5
20230708	2023-07-08	8	7	2023	3	6
20230709	2023-07-09	9	7	2023	3	0
20230710	2023-07-10	10	7	2023	3	1
20230711	2023-07-11	11	7	2023	3	2
20230712	2023-07-12	12	7	2023	3	3
20230713	2023-07-13	13	7	2023	3	4
20230714	2023-07-14	14	7	2023	3	5
20230715	2023-07-15	15	7	2023	3	6
20230716	2023-07-16	16	7	2023	3	0
20230717	2023-07-17	17	7	2023	3	1
20230718	2023-07-18	18	7	2023	3	2
20230719	2023-07-19	19	7	2023	3	3
20230720	2023-07-20	20	7	2023	3	4
20230721	2023-07-21	21	7	2023	3	5
20230722	2023-07-22	22	7	2023	3	6
20230723	2023-07-23	23	7	2023	3	0
20230724	2023-07-24	24	7	2023	3	1
20230725	2023-07-25	25	7	2023	3	2
20230726	2023-07-26	26	7	2023	3	3
20230727	2023-07-27	27	7	2023	3	4
20230728	2023-07-28	28	7	2023	3	5
20230729	2023-07-29	29	7	2023	3	6
20230730	2023-07-30	30	7	2023	3	0
20230731	2023-07-31	31	7	2023	3	1
20230801	2023-08-01	1	8	2023	3	2
20230802	2023-08-02	2	8	2023	3	3
20230803	2023-08-03	3	8	2023	3	4
20230804	2023-08-04	4	8	2023	3	5
20230805	2023-08-05	5	8	2023	3	6
20230806	2023-08-06	6	8	2023	3	0
20230807	2023-08-07	7	8	2023	3	1
20230808	2023-08-08	8	8	2023	3	2
20230809	2023-08-09	9	8	2023	3	3
20230810	2023-08-10	10	8	2023	3	4
20230811	2023-08-11	11	8	2023	3	5
20230812	2023-08-12	12	8	2023	3	6
20230813	2023-08-13	13	8	2023	3	0
20230814	2023-08-14	14	8	2023	3	1
20230815	2023-08-15	15	8	2023	3	2
20230816	2023-08-16	16	8	2023	3	3
20230817	2023-08-17	17	8	2023	3	4
20230818	2023-08-18	18	8	2023	3	5
20230819	2023-08-19	19	8	2023	3	6
20230820	2023-08-20	20	8	2023	3	0
20230821	2023-08-21	21	8	2023	3	1
20230822	2023-08-22	22	8	2023	3	2
20230823	2023-08-23	23	8	2023	3	3
20230824	2023-08-24	24	8	2023	3	4
20230825	2023-08-25	25	8	2023	3	5
20230826	2023-08-26	26	8	2023	3	6
20230827	2023-08-27	27	8	2023	3	0
20230828	2023-08-28	28	8	2023	3	1
20230829	2023-08-29	29	8	2023	3	2
20230830	2023-08-30	30	8	2023	3	3
20230831	2023-08-31	31	8	2023	3	4
20230901	2023-09-01	1	9	2023	3	5
20230902	2023-09-02	2	9	2023	3	6
20230903	2023-09-03	3	9	2023	3	0
20230904	2023-09-04	4	9	2023	3	1
20230905	2023-09-05	5	9	2023	3	2
20230906	2023-09-06	6	9	2023	3	3
20230907	2023-09-07	7	9	2023	3	4
20230908	2023-09-08	8	9	2023	3	5
20230909	2023-09-09	9	9	2023	3	6
20230910	2023-09-10	10	9	2023	3	0
20230911	2023-09-11	11	9	2023	3	1
20230912	2023-09-12	12	9	2023	3	2
20230913	2023-09-13	13	9	2023	3	3
20230914	2023-09-14	14	9	2023	3	4
20230915	2023-09-15	15	9	2023	3	5
20230916	2023-09-16	16	9	2023	3	6
20230917	2023-09-17	17	9	2023	3	0
20230918	2023-09-18	18	9	2023	3	1
20230919	2023-09-19	19	9	2023	3	2
20230920	2023-09-20	20	9	2023	3	3
20230921	2023-09-21	21	9	2023	3	4
20230922	2023-09-22	22	9	2023	3	5
20230923	2023-09-23	23	9	2023	3	6
20230924	2023-09-24	24	9	2023	3	0
20230925	2023-09-25	25	9	2023	3	1
20230926	2023-09-26	26	9	2023	3	2
20230927	2023-09-27	27	9	2023	3	3
20230928	2023-09-28	28	9	2023	3	4
20230929	2023-09-29	29	9	2023	3	5
20230930	2023-09-30	30	9	2023	3	6
20231001	2023-10-01	1	10	2023	4	0
20231002	2023-10-02	2	10	2023	4	1
20231003	2023-10-03	3	10	2023	4	2
20231004	2023-10-04	4	10	2023	4	3
20231005	2023-10-05	5	10	2023	4	4
20231006	2023-10-06	6	10	2023	4	5
20231007	2023-10-07	7	10	2023	4	6
20231008	2023-10-08	8	10	2023	4	0
20231009	2023-10-09	9	10	2023	4	1
20231010	2023-10-10	10	10	2023	4	2
20231011	2023-10-11	11	10	2023	4	3
20231012	2023-10-12	12	10	2023	4	4
20231013	2023-10-13	13	10	2023	4	5
20231014	2023-10-14	14	10	2023	4	6
20231015	2023-10-15	15	10	2023	4	0
20231016	2023-10-16	16	10	2023	4	1
20231017	2023-10-17	17	10	2023	4	2
20231018	2023-10-18	18	10	2023	4	3
20231019	2023-10-19	19	10	2023	4	4
20231020	2023-10-20	20	10	2023	4	5
20231021	2023-10-21	21	10	2023	4	6
20231022	2023-10-22	22	10	2023	4	0
20231023	2023-10-23	23	10	2023	4	1
20231024	2023-10-24	24	10	2023	4	2
20231025	2023-10-25	25	10	2023	4	3
20231026	2023-10-26	26	10	2023	4	4
20231027	2023-10-27	27	10	2023	4	5
20231028	2023-10-28	28	10	2023	4	6
20231029	2023-10-29	29	10	2023	4	0
20231030	2023-10-30	30	10	2023	4	1
20231031	2023-10-31	31	10	2023	4	2
20231101	2023-11-01	1	11	2023	4	3
20231102	2023-11-02	2	11	2023	4	4
20231103	2023-11-03	3	11	2023	4	5
20231104	2023-11-04	4	11	2023	4	6
20231105	2023-11-05	5	11	2023	4	0
20231106	2023-11-06	6	11	2023	4	1
20231107	2023-11-07	7	11	2023	4	2
20231108	2023-11-08	8	11	2023	4	3
20231109	2023-11-09	9	11	2023	4	4
20231110	2023-11-10	10	11	2023	4	5
20231111	2023-11-11	11	11	2023	4	6
20231112	2023-11-12	12	11	2023	4	0
20231113	2023-11-13	13	11	2023	4	1
20231114	2023-11-14	14	11	2023	4	2
20231115	2023-11-15	15	11	2023	4	3
20231116	2023-11-16	16	11	2023	4	4
20231117	2023-11-17	17	11	2023	4	5
20231118	2023-11-18	18	11	2023	4	6
20231119	2023-11-19	19	11	2023	4	0
20231120	2023-11-20	20	11	2023	4	1
20231121	2023-11-21	21	11	2023	4	2
20231122	2023-11-22	22	11	2023	4	3
20231123	2023-11-23	23	11	2023	4	4
20231124	2023-11-24	24	11	2023	4	5
20231125	2023-11-25	25	11	2023	4	6
20231126	2023-11-26	26	11	2023	4	0
20231127	2023-11-27	27	11	2023	4	1
20231128	2023-11-28	28	11	2023	4	2
20231129	2023-11-29	29	11	2023	4	3
20231130	2023-11-30	30	11	2023	4	4
20231201	2023-12-01	1	12	2023	4	5
20231202	2023-12-02	2	12	2023	4	6
20231203	2023-12-03	3	12	2023	4	0
20231204	2023-12-04	4	12	2023	4	1
20231205	2023-12-05	5	12	2023	4	2
20231206	2023-12-06	6	12	2023	4	3
20231207	2023-12-07	7	12	2023	4	4
20231208	2023-12-08	8	12	2023	4	5
20231209	2023-12-09	9	12	2023	4	6
20231210	2023-12-10	10	12	2023	4	0
20231211	2023-12-11	11	12	2023	4	1
20231212	2023-12-12	12	12	2023	4	2
20231213	2023-12-13	13	12	2023	4	3
20231214	2023-12-14	14	12	2023	4	4
20231215	2023-12-15	15	12	2023	4	5
20231216	2023-12-16	16	12	2023	4	6
20231217	2023-12-17	17	12	2023	4	0
20231218	2023-12-18	18	12	2023	4	1
20231219	2023-12-19	19	12	2023	4	2
20231220	2023-12-20	20	12	2023	4	3
20231221	2023-12-21	21	12	2023	4	4
20231222	2023-12-22	22	12	2023	4	5
20231223	2023-12-23	23	12	2023	4	6
20231224	2023-12-24	24	12	2023	4	0
20231225	2023-12-25	25	12	2023	4	1
20231226	2023-12-26	26	12	2023	4	2
20231227	2023-12-27	27	12	2023	4	3
20231228	2023-12-28	28	12	2023	4	4
20231229	2023-12-29	29	12	2023	4	5
20231230	2023-12-30	30	12	2023	4	6
20231231	2023-12-31	31	12	2023	4	0
20240101	2024-01-01	1	1	2024	1	1
20240102	2024-01-02	2	1	2024	1	2
20240103	2024-01-03	3	1	2024	1	3
20240104	2024-01-04	4	1	2024	1	4
20240105	2024-01-05	5	1	2024	1	5
20240106	2024-01-06	6	1	2024	1	6
20240107	2024-01-07	7	1	2024	1	0
20240108	2024-01-08	8	1	2024	1	1
20240109	2024-01-09	9	1	2024	1	2
20240110	2024-01-10	10	1	2024	1	3
20240111	2024-01-11	11	1	2024	1	4
20240112	2024-01-12	12	1	2024	1	5
20240113	2024-01-13	13	1	2024	1	6
20240114	2024-01-14	14	1	2024	1	0
20240115	2024-01-15	15	1	2024	1	1
20240116	2024-01-16	16	1	2024	1	2
20240117	2024-01-17	17	1	2024	1	3
20240118	2024-01-18	18	1	2024	1	4
20240119	2024-01-19	19	1	2024	1	5
20240120	2024-01-20	20	1	2024	1	6
20240121	2024-01-21	21	1	2024	1	0
20240122	2024-01-22	22	1	2024	1	1
20240123	2024-01-23	23	1	2024	1	2
20240124	2024-01-24	24	1	2024	1	3
20240125	2024-01-25	25	1	2024	1	4
20240126	2024-01-26	26	1	2024	1	5
20240127	2024-01-27	27	1	2024	1	6
20240128	2024-01-28	28	1	2024	1	0
20240129	2024-01-29	29	1	2024	1	1
20240130	2024-01-30	30	1	2024	1	2
20240131	2024-01-31	31	1	2024	1	3
20240201	2024-02-01	1	2	2024	1	4
20240202	2024-02-02	2	2	2024	1	5
20240203	2024-02-03	3	2	2024	1	6
20240204	2024-02-04	4	2	2024	1	0
20240205	2024-02-05	5	2	2024	1	1
20240206	2024-02-06	6	2	2024	1	2
20240207	2024-02-07	7	2	2024	1	3
20240208	2024-02-08	8	2	2024	1	4
20240209	2024-02-09	9	2	2024	1	5
20240210	2024-02-10	10	2	2024	1	6
20240211	2024-02-11	11	2	2024	1	0
20240212	2024-02-12	12	2	2024	1	1
20240213	2024-02-13	13	2	2024	1	2
20240214	2024-02-14	14	2	2024	1	3
20240215	2024-02-15	15	2	2024	1	4
20240216	2024-02-16	16	2	2024	1	5
20240217	2024-02-17	17	2	2024	1	6
20240218	2024-02-18	18	2	2024	1	0
20240219	2024-02-19	19	2	2024	1	1
20240220	2024-02-20	20	2	2024	1	2
20240221	2024-02-21	21	2	2024	1	3
20240222	2024-02-22	22	2	2024	1	4
20240223	2024-02-23	23	2	2024	1	5
20240224	2024-02-24	24	2	2024	1	6
20240225	2024-02-25	25	2	2024	1	0
20240226	2024-02-26	26	2	2024	1	1
20240227	2024-02-27	27	2	2024	1	2
20240228	2024-02-28	28	2	2024	1	3
20240229	2024-02-29	29	2	2024	1	4
20240301	2024-03-01	1	3	2024	1	5
20240302	2024-03-02	2	3	2024	1	6
20240303	2024-03-03	3	3	2024	1	0
20240304	2024-03-04	4	3	2024	1	1
20240305	2024-03-05	5	3	2024	1	2
20240306	2024-03-06	6	3	2024	1	3
20240307	2024-03-07	7	3	2024	1	4
20240308	2024-03-08	8	3	2024	1	5
20240309	2024-03-09	9	3	2024	1	6
20240310	2024-03-10	10	3	2024	1	0
20240311	2024-03-11	11	3	2024	1	1
20240312	2024-03-12	12	3	2024	1	2
20240313	2024-03-13	13	3	2024	1	3
20240314	2024-03-14	14	3	2024	1	4
20240315	2024-03-15	15	3	2024	1	5
20240316	2024-03-16	16	3	2024	1	6
20240317	2024-03-17	17	3	2024	1	0
20240318	2024-03-18	18	3	2024	1	1
20240319	2024-03-19	19	3	2024	1	2
20240320	2024-03-20	20	3	2024	1	3
20240321	2024-03-21	21	3	2024	1	4
20240322	2024-03-22	22	3	2024	1	5
20240323	2024-03-23	23	3	2024	1	6
20240324	2024-03-24	24	3	2024	1	0
20240325	2024-03-25	25	3	2024	1	1
20240326	2024-03-26	26	3	2024	1	2
20240327	2024-03-27	27	3	2024	1	3
20240328	2024-03-28	28	3	2024	1	4
20240329	2024-03-29	29	3	2024	1	5
20240330	2024-03-30	30	3	2024	1	6
20240331	2024-03-31	31	3	2024	1	0
20240401	2024-04-01	1	4	2024	2	1
20240402	2024-04-02	2	4	2024	2	2
20240403	2024-04-03	3	4	2024	2	3
20240404	2024-04-04	4	4	2024	2	4
20240405	2024-04-05	5	4	2024	2	5
20240406	2024-04-06	6	4	2024	2	6
20240407	2024-04-07	7	4	2024	2	0
20240408	2024-04-08	8	4	2024	2	1
20240409	2024-04-09	9	4	2024	2	2
20240410	2024-04-10	10	4	2024	2	3
20240411	2024-04-11	11	4	2024	2	4
20240412	2024-04-12	12	4	2024	2	5
20240413	2024-04-13	13	4	2024	2	6
20240414	2024-04-14	14	4	2024	2	0
20240415	2024-04-15	15	4	2024	2	1
20240416	2024-04-16	16	4	2024	2	2
20240417	2024-04-17	17	4	2024	2	3
20240418	2024-04-18	18	4	2024	2	4
20240419	2024-04-19	19	4	2024	2	5
20240420	2024-04-20	20	4	2024	2	6
20240421	2024-04-21	21	4	2024	2	0
20240422	2024-04-22	22	4	2024	2	1
20240423	2024-04-23	23	4	2024	2	2
20240424	2024-04-24	24	4	2024	2	3
20240425	2024-04-25	25	4	2024	2	4
20240426	2024-04-26	26	4	2024	2	5
20240427	2024-04-27	27	4	2024	2	6
20240428	2024-04-28	28	4	2024	2	0
20240429	2024-04-29	29	4	2024	2	1
20240430	2024-04-30	30	4	2024	2	2
20240501	2024-05-01	1	5	2024	2	3
20240502	2024-05-02	2	5	2024	2	4
20240503	2024-05-03	3	5	2024	2	5
20240504	2024-05-04	4	5	2024	2	6
20240505	2024-05-05	5	5	2024	2	0
20240506	2024-05-06	6	5	2024	2	1
20240507	2024-05-07	7	5	2024	2	2
20240508	2024-05-08	8	5	2024	2	3
20240509	2024-05-09	9	5	2024	2	4
20240510	2024-05-10	10	5	2024	2	5
20240511	2024-05-11	11	5	2024	2	6
20240512	2024-05-12	12	5	2024	2	0
20240513	2024-05-13	13	5	2024	2	1
20240514	2024-05-14	14	5	2024	2	2
20240515	2024-05-15	15	5	2024	2	3
20240516	2024-05-16	16	5	2024	2	4
20240517	2024-05-17	17	5	2024	2	5
20240518	2024-05-18	18	5	2024	2	6
20240519	2024-05-19	19	5	2024	2	0
20240520	2024-05-20	20	5	2024	2	1
20240521	2024-05-21	21	5	2024	2	2
20240522	2024-05-22	22	5	2024	2	3
20240523	2024-05-23	23	5	2024	2	4
20240524	2024-05-24	24	5	2024	2	5
20240525	2024-05-25	25	5	2024	2	6
20240526	2024-05-26	26	5	2024	2	0
20240527	2024-05-27	27	5	2024	2	1
20240528	2024-05-28	28	5	2024	2	2
20240529	2024-05-29	29	5	2024	2	3
20240530	2024-05-30	30	5	2024	2	4
20240531	2024-05-31	31	5	2024	2	5
20240601	2024-06-01	1	6	2024	2	6
20240602	2024-06-02	2	6	2024	2	0
20240603	2024-06-03	3	6	2024	2	1
20240604	2024-06-04	4	6	2024	2	2
20240605	2024-06-05	5	6	2024	2	3
20240606	2024-06-06	6	6	2024	2	4
20240607	2024-06-07	7	6	2024	2	5
20240608	2024-06-08	8	6	2024	2	6
20240609	2024-06-09	9	6	2024	2	0
20240610	2024-06-10	10	6	2024	2	1
20240611	2024-06-11	11	6	2024	2	2
20240612	2024-06-12	12	6	2024	2	3
20240613	2024-06-13	13	6	2024	2	4
20240614	2024-06-14	14	6	2024	2	5
20240615	2024-06-15	15	6	2024	2	6
20240616	2024-06-16	16	6	2024	2	0
20240617	2024-06-17	17	6	2024	2	1
20240618	2024-06-18	18	6	2024	2	2
20240619	2024-06-19	19	6	2024	2	3
20240620	2024-06-20	20	6	2024	2	4
20240621	2024-06-21	21	6	2024	2	5
20240622	2024-06-22	22	6	2024	2	6
20240623	2024-06-23	23	6	2024	2	0
20240624	2024-06-24	24	6	2024	2	1
20240625	2024-06-25	25	6	2024	2	2
20240626	2024-06-26	26	6	2024	2	3
20240627	2024-06-27	27	6	2024	2	4
20240628	2024-06-28	28	6	2024	2	5
20240629	2024-06-29	29	6	2024	2	6
20240630	2024-06-30	30	6	2024	2	0
20240701	2024-07-01	1	7	2024	3	1
20240702	2024-07-02	2	7	2024	3	2
20240703	2024-07-03	3	7	2024	3	3
20240704	2024-07-04	4	7	2024	3	4
20240705	2024-07-05	5	7	2024	3	5
20240706	2024-07-06	6	7	2024	3	6
20240707	2024-07-07	7	7	2024	3	0
20240708	2024-07-08	8	7	2024	3	1
20240709	2024-07-09	9	7	2024	3	2
20240710	2024-07-10	10	7	2024	3	3
20240711	2024-07-11	11	7	2024	3	4
20240712	2024-07-12	12	7	2024	3	5
20240713	2024-07-13	13	7	2024	3	6
20240714	2024-07-14	14	7	2024	3	0
20240715	2024-07-15	15	7	2024	3	1
20240716	2024-07-16	16	7	2024	3	2
20240717	2024-07-17	17	7	2024	3	3
20240718	2024-07-18	18	7	2024	3	4
20240719	2024-07-19	19	7	2024	3	5
20240720	2024-07-20	20	7	2024	3	6
20240721	2024-07-21	21	7	2024	3	0
20240722	2024-07-22	22	7	2024	3	1
20240723	2024-07-23	23	7	2024	3	2
20240724	2024-07-24	24	7	2024	3	3
20240725	2024-07-25	25	7	2024	3	4
20240726	2024-07-26	26	7	2024	3	5
20240727	2024-07-27	27	7	2024	3	6
20240728	2024-07-28	28	7	2024	3	0
20240729	2024-07-29	29	7	2024	3	1
20240730	2024-07-30	30	7	2024	3	2
20240731	2024-07-31	31	7	2024	3	3
20240801	2024-08-01	1	8	2024	3	4
20240802	2024-08-02	2	8	2024	3	5
20240803	2024-08-03	3	8	2024	3	6
20240804	2024-08-04	4	8	2024	3	0
20240805	2024-08-05	5	8	2024	3	1
20240806	2024-08-06	6	8	2024	3	2
20240807	2024-08-07	7	8	2024	3	3
20240808	2024-08-08	8	8	2024	3	4
20240809	2024-08-09	9	8	2024	3	5
20240810	2024-08-10	10	8	2024	3	6
20240811	2024-08-11	11	8	2024	3	0
20240812	2024-08-12	12	8	2024	3	1
20240813	2024-08-13	13	8	2024	3	2
20240814	2024-08-14	14	8	2024	3	3
20240815	2024-08-15	15	8	2024	3	4
20240816	2024-08-16	16	8	2024	3	5
20240817	2024-08-17	17	8	2024	3	6
20240818	2024-08-18	18	8	2024	3	0
20240819	2024-08-19	19	8	2024	3	1
20240820	2024-08-20	20	8	2024	3	2
20240821	2024-08-21	21	8	2024	3	3
20240822	2024-08-22	22	8	2024	3	4
20240823	2024-08-23	23	8	2024	3	5
20240824	2024-08-24	24	8	2024	3	6
20240825	2024-08-25	25	8	2024	3	0
20240826	2024-08-26	26	8	2024	3	1
20240827	2024-08-27	27	8	2024	3	2
20240828	2024-08-28	28	8	2024	3	3
20240829	2024-08-29	29	8	2024	3	4
20240830	2024-08-30	30	8	2024	3	5
20240831	2024-08-31	31	8	2024	3	6
20240901	2024-09-01	1	9	2024	3	0
20240902	2024-09-02	2	9	2024	3	1
20240903	2024-09-03	3	9	2024	3	2
20240904	2024-09-04	4	9	2024	3	3
20240905	2024-09-05	5	9	2024	3	4
20240906	2024-09-06	6	9	2024	3	5
20240907	2024-09-07	7	9	2024	3	6
20240908	2024-09-08	8	9	2024	3	0
20240909	2024-09-09	9	9	2024	3	1
20240910	2024-09-10	10	9	2024	3	2
20240911	2024-09-11	11	9	2024	3	3
20240912	2024-09-12	12	9	2024	3	4
20240913	2024-09-13	13	9	2024	3	5
20240914	2024-09-14	14	9	2024	3	6
20240915	2024-09-15	15	9	2024	3	0
20240916	2024-09-16	16	9	2024	3	1
20240917	2024-09-17	17	9	2024	3	2
20240918	2024-09-18	18	9	2024	3	3
20240919	2024-09-19	19	9	2024	3	4
20240920	2024-09-20	20	9	2024	3	5
20240921	2024-09-21	21	9	2024	3	6
20240922	2024-09-22	22	9	2024	3	0
20240923	2024-09-23	23	9	2024	3	1
20240924	2024-09-24	24	9	2024	3	2
20240925	2024-09-25	25	9	2024	3	3
20240926	2024-09-26	26	9	2024	3	4
20240927	2024-09-27	27	9	2024	3	5
20240928	2024-09-28	28	9	2024	3	6
20240929	2024-09-29	29	9	2024	3	0
20240930	2024-09-30	30	9	2024	3	1
20241001	2024-10-01	1	10	2024	4	2
20241002	2024-10-02	2	10	2024	4	3
20241003	2024-10-03	3	10	2024	4	4
20241004	2024-10-04	4	10	2024	4	5
20241005	2024-10-05	5	10	2024	4	6
20241006	2024-10-06	6	10	2024	4	0
20241007	2024-10-07	7	10	2024	4	1
20241008	2024-10-08	8	10	2024	4	2
20241009	2024-10-09	9	10	2024	4	3
20241010	2024-10-10	10	10	2024	4	4
20241011	2024-10-11	11	10	2024	4	5
20241012	2024-10-12	12	10	2024	4	6
20241013	2024-10-13	13	10	2024	4	0
20241014	2024-10-14	14	10	2024	4	1
20241015	2024-10-15	15	10	2024	4	2
20241016	2024-10-16	16	10	2024	4	3
20241017	2024-10-17	17	10	2024	4	4
20241018	2024-10-18	18	10	2024	4	5
20241019	2024-10-19	19	10	2024	4	6
20241020	2024-10-20	20	10	2024	4	0
20241021	2024-10-21	21	10	2024	4	1
20241022	2024-10-22	22	10	2024	4	2
20241023	2024-10-23	23	10	2024	4	3
20241024	2024-10-24	24	10	2024	4	4
20241025	2024-10-25	25	10	2024	4	5
20241026	2024-10-26	26	10	2024	4	6
20241027	2024-10-27	27	10	2024	4	0
20241028	2024-10-28	28	10	2024	4	1
20241029	2024-10-29	29	10	2024	4	2
20241030	2024-10-30	30	10	2024	4	3
20241031	2024-10-31	31	10	2024	4	4
20241101	2024-11-01	1	11	2024	4	5
20241102	2024-11-02	2	11	2024	4	6
20241103	2024-11-03	3	11	2024	4	0
20241104	2024-11-04	4	11	2024	4	1
20241105	2024-11-05	5	11	2024	4	2
20241106	2024-11-06	6	11	2024	4	3
20241107	2024-11-07	7	11	2024	4	4
20241108	2024-11-08	8	11	2024	4	5
20241109	2024-11-09	9	11	2024	4	6
20241110	2024-11-10	10	11	2024	4	0
20241111	2024-11-11	11	11	2024	4	1
20241112	2024-11-12	12	11	2024	4	2
20241113	2024-11-13	13	11	2024	4	3
20241114	2024-11-14	14	11	2024	4	4
20241115	2024-11-15	15	11	2024	4	5
20241116	2024-11-16	16	11	2024	4	6
20241117	2024-11-17	17	11	2024	4	0
20241118	2024-11-18	18	11	2024	4	1
20241119	2024-11-19	19	11	2024	4	2
20241120	2024-11-20	20	11	2024	4	3
20241121	2024-11-21	21	11	2024	4	4
20241122	2024-11-22	22	11	2024	4	5
20241123	2024-11-23	23	11	2024	4	6
20241124	2024-11-24	24	11	2024	4	0
20241125	2024-11-25	25	11	2024	4	1
20241126	2024-11-26	26	11	2024	4	2
20241127	2024-11-27	27	11	2024	4	3
20241128	2024-11-28	28	11	2024	4	4
20241129	2024-11-29	29	11	2024	4	5
20241130	2024-11-30	30	11	2024	4	6
20241201	2024-12-01	1	12	2024	4	0
20241202	2024-12-02	2	12	2024	4	1
20241203	2024-12-03	3	12	2024	4	2
20241204	2024-12-04	4	12	2024	4	3
20241205	2024-12-05	5	12	2024	4	4
20241206	2024-12-06	6	12	2024	4	5
20241207	2024-12-07	7	12	2024	4	6
20241208	2024-12-08	8	12	2024	4	0
20241209	2024-12-09	9	12	2024	4	1
20241210	2024-12-10	10	12	2024	4	2
20241211	2024-12-11	11	12	2024	4	3
20241212	2024-12-12	12	12	2024	4	4
20241213	2024-12-13	13	12	2024	4	5
20241214	2024-12-14	14	12	2024	4	6
20241215	2024-12-15	15	12	2024	4	0
20241216	2024-12-16	16	12	2024	4	1
20241217	2024-12-17	17	12	2024	4	2
20241218	2024-12-18	18	12	2024	4	3
20241219	2024-12-19	19	12	2024	4	4
20241220	2024-12-20	20	12	2024	4	5
20241221	2024-12-21	21	12	2024	4	6
20241222	2024-12-22	22	12	2024	4	0
20241223	2024-12-23	23	12	2024	4	1
20241224	2024-12-24	24	12	2024	4	2
20241225	2024-12-25	25	12	2024	4	3
20241226	2024-12-26	26	12	2024	4	4
20241227	2024-12-27	27	12	2024	4	5
20241228	2024-12-28	28	12	2024	4	6
20241229	2024-12-29	29	12	2024	4	0
20241230	2024-12-30	30	12	2024	4	1
20241231	2024-12-31	31	12	2024	4	2
20250101	2025-01-01	1	1	2025	1	3
20250102	2025-01-02	2	1	2025	1	4
20250103	2025-01-03	3	1	2025	1	5
20250104	2025-01-04	4	1	2025	1	6
20250105	2025-01-05	5	1	2025	1	0
20250106	2025-01-06	6	1	2025	1	1
20250107	2025-01-07	7	1	2025	1	2
20250108	2025-01-08	8	1	2025	1	3
20250109	2025-01-09	9	1	2025	1	4
20250110	2025-01-10	10	1	2025	1	5
20250111	2025-01-11	11	1	2025	1	6
20250112	2025-01-12	12	1	2025	1	0
20250113	2025-01-13	13	1	2025	1	1
20250114	2025-01-14	14	1	2025	1	2
20250115	2025-01-15	15	1	2025	1	3
20250116	2025-01-16	16	1	2025	1	4
20250117	2025-01-17	17	1	2025	1	5
20250118	2025-01-18	18	1	2025	1	6
20250119	2025-01-19	19	1	2025	1	0
20250120	2025-01-20	20	1	2025	1	1
20250121	2025-01-21	21	1	2025	1	2
20250122	2025-01-22	22	1	2025	1	3
20250123	2025-01-23	23	1	2025	1	4
20250124	2025-01-24	24	1	2025	1	5
20250125	2025-01-25	25	1	2025	1	6
20250126	2025-01-26	26	1	2025	1	0
20250127	2025-01-27	27	1	2025	1	1
20250128	2025-01-28	28	1	2025	1	2
20250129	2025-01-29	29	1	2025	1	3
20250130	2025-01-30	30	1	2025	1	4
20250131	2025-01-31	31	1	2025	1	5
20250201	2025-02-01	1	2	2025	1	6
20250202	2025-02-02	2	2	2025	1	0
20250203	2025-02-03	3	2	2025	1	1
20250204	2025-02-04	4	2	2025	1	2
20250205	2025-02-05	5	2	2025	1	3
20250206	2025-02-06	6	2	2025	1	4
20250207	2025-02-07	7	2	2025	1	5
20250208	2025-02-08	8	2	2025	1	6
20250209	2025-02-09	9	2	2025	1	0
20250210	2025-02-10	10	2	2025	1	1
20250211	2025-02-11	11	2	2025	1	2
20250212	2025-02-12	12	2	2025	1	3
20250213	2025-02-13	13	2	2025	1	4
20250214	2025-02-14	14	2	2025	1	5
20250215	2025-02-15	15	2	2025	1	6
20250216	2025-02-16	16	2	2025	1	0
20250217	2025-02-17	17	2	2025	1	1
20250218	2025-02-18	18	2	2025	1	2
20250219	2025-02-19	19	2	2025	1	3
20250220	2025-02-20	20	2	2025	1	4
20250221	2025-02-21	21	2	2025	1	5
20250222	2025-02-22	22	2	2025	1	6
20250223	2025-02-23	23	2	2025	1	0
20250224	2025-02-24	24	2	2025	1	1
20250225	2025-02-25	25	2	2025	1	2
20250226	2025-02-26	26	2	2025	1	3
20250227	2025-02-27	27	2	2025	1	4
20250228	2025-02-28	28	2	2025	1	5
20250301	2025-03-01	1	3	2025	1	6
20250302	2025-03-02	2	3	2025	1	0
20250303	2025-03-03	3	3	2025	1	1
20250304	2025-03-04	4	3	2025	1	2
20250305	2025-03-05	5	3	2025	1	3
20250306	2025-03-06	6	3	2025	1	4
20250307	2025-03-07	7	3	2025	1	5
20250308	2025-03-08	8	3	2025	1	6
20250309	2025-03-09	9	3	2025	1	0
20250310	2025-03-10	10	3	2025	1	1
20250311	2025-03-11	11	3	2025	1	2
20250312	2025-03-12	12	3	2025	1	3
20250313	2025-03-13	13	3	2025	1	4
20250314	2025-03-14	14	3	2025	1	5
20250315	2025-03-15	15	3	2025	1	6
20250316	2025-03-16	16	3	2025	1	0
20250317	2025-03-17	17	3	2025	1	1
20250318	2025-03-18	18	3	2025	1	2
20250319	2025-03-19	19	3	2025	1	3
20250320	2025-03-20	20	3	2025	1	4
20250321	2025-03-21	21	3	2025	1	5
20250322	2025-03-22	22	3	2025	1	6
20250323	2025-03-23	23	3	2025	1	0
20250324	2025-03-24	24	3	2025	1	1
20250325	2025-03-25	25	3	2025	1	2
20250326	2025-03-26	26	3	2025	1	3
20250327	2025-03-27	27	3	2025	1	4
20250328	2025-03-28	28	3	2025	1	5
20250329	2025-03-29	29	3	2025	1	6
20250330	2025-03-30	30	3	2025	1	0
20250331	2025-03-31	31	3	2025	1	1
20250401	2025-04-01	1	4	2025	2	2
20250402	2025-04-02	2	4	2025	2	3
20250403	2025-04-03	3	4	2025	2	4
20250404	2025-04-04	4	4	2025	2	5
20250405	2025-04-05	5	4	2025	2	6
20250406	2025-04-06	6	4	2025	2	0
20250407	2025-04-07	7	4	2025	2	1
20250408	2025-04-08	8	4	2025	2	2
20250409	2025-04-09	9	4	2025	2	3
20250410	2025-04-10	10	4	2025	2	4
20250411	2025-04-11	11	4	2025	2	5
20250412	2025-04-12	12	4	2025	2	6
20250413	2025-04-13	13	4	2025	2	0
20250414	2025-04-14	14	4	2025	2	1
20250415	2025-04-15	15	4	2025	2	2
20250416	2025-04-16	16	4	2025	2	3
20250417	2025-04-17	17	4	2025	2	4
20250418	2025-04-18	18	4	2025	2	5
20250419	2025-04-19	19	4	2025	2	6
20250420	2025-04-20	20	4	2025	2	0
20250421	2025-04-21	21	4	2025	2	1
20250422	2025-04-22	22	4	2025	2	2
20250423	2025-04-23	23	4	2025	2	3
20250424	2025-04-24	24	4	2025	2	4
20250425	2025-04-25	25	4	2025	2	5
20250426	2025-04-26	26	4	2025	2	6
20250427	2025-04-27	27	4	2025	2	0
20250428	2025-04-28	28	4	2025	2	1
20250429	2025-04-29	29	4	2025	2	2
20250430	2025-04-30	30	4	2025	2	3
20250501	2025-05-01	1	5	2025	2	4
20250502	2025-05-02	2	5	2025	2	5
20250503	2025-05-03	3	5	2025	2	6
20250504	2025-05-04	4	5	2025	2	0
20250505	2025-05-05	5	5	2025	2	1
20250506	2025-05-06	6	5	2025	2	2
20250507	2025-05-07	7	5	2025	2	3
20250508	2025-05-08	8	5	2025	2	4
20250509	2025-05-09	9	5	2025	2	5
20250510	2025-05-10	10	5	2025	2	6
20250511	2025-05-11	11	5	2025	2	0
20250512	2025-05-12	12	5	2025	2	1
20250513	2025-05-13	13	5	2025	2	2
20250514	2025-05-14	14	5	2025	2	3
20250515	2025-05-15	15	5	2025	2	4
20250516	2025-05-16	16	5	2025	2	5
20250517	2025-05-17	17	5	2025	2	6
20250518	2025-05-18	18	5	2025	2	0
20250519	2025-05-19	19	5	2025	2	1
20250520	2025-05-20	20	5	2025	2	2
20250521	2025-05-21	21	5	2025	2	3
20250522	2025-05-22	22	5	2025	2	4
20250523	2025-05-23	23	5	2025	2	5
20250524	2025-05-24	24	5	2025	2	6
20250525	2025-05-25	25	5	2025	2	0
20250526	2025-05-26	26	5	2025	2	1
20250527	2025-05-27	27	5	2025	2	2
20250528	2025-05-28	28	5	2025	2	3
20250529	2025-05-29	29	5	2025	2	4
20250530	2025-05-30	30	5	2025	2	5
20250531	2025-05-31	31	5	2025	2	6
20250601	2025-06-01	1	6	2025	2	0
20250602	2025-06-02	2	6	2025	2	1
20250603	2025-06-03	3	6	2025	2	2
20250604	2025-06-04	4	6	2025	2	3
20250605	2025-06-05	5	6	2025	2	4
20250606	2025-06-06	6	6	2025	2	5
20250607	2025-06-07	7	6	2025	2	6
20250608	2025-06-08	8	6	2025	2	0
20250609	2025-06-09	9	6	2025	2	1
20250610	2025-06-10	10	6	2025	2	2
20250611	2025-06-11	11	6	2025	2	3
20250612	2025-06-12	12	6	2025	2	4
20250613	2025-06-13	13	6	2025	2	5
20250614	2025-06-14	14	6	2025	2	6
20250615	2025-06-15	15	6	2025	2	0
20250616	2025-06-16	16	6	2025	2	1
20250617	2025-06-17	17	6	2025	2	2
20250618	2025-06-18	18	6	2025	2	3
20250619	2025-06-19	19	6	2025	2	4
20250620	2025-06-20	20	6	2025	2	5
20250621	2025-06-21	21	6	2025	2	6
20250622	2025-06-22	22	6	2025	2	0
20250623	2025-06-23	23	6	2025	2	1
20250624	2025-06-24	24	6	2025	2	2
20250625	2025-06-25	25	6	2025	2	3
20250626	2025-06-26	26	6	2025	2	4
20250627	2025-06-27	27	6	2025	2	5
20250628	2025-06-28	28	6	2025	2	6
20250629	2025-06-29	29	6	2025	2	0
20250630	2025-06-30	30	6	2025	2	1
20250701	2025-07-01	1	7	2025	3	2
20250702	2025-07-02	2	7	2025	3	3
20250703	2025-07-03	3	7	2025	3	4
20250704	2025-07-04	4	7	2025	3	5
20250705	2025-07-05	5	7	2025	3	6
20250706	2025-07-06	6	7	2025	3	0
20250707	2025-07-07	7	7	2025	3	1
20250708	2025-07-08	8	7	2025	3	2
20250709	2025-07-09	9	7	2025	3	3
20250710	2025-07-10	10	7	2025	3	4
20250711	2025-07-11	11	7	2025	3	5
20250712	2025-07-12	12	7	2025	3	6
20250713	2025-07-13	13	7	2025	3	0
20250714	2025-07-14	14	7	2025	3	1
20250715	2025-07-15	15	7	2025	3	2
20250716	2025-07-16	16	7	2025	3	3
20250717	2025-07-17	17	7	2025	3	4
20250718	2025-07-18	18	7	2025	3	5
20250719	2025-07-19	19	7	2025	3	6
20250720	2025-07-20	20	7	2025	3	0
20250721	2025-07-21	21	7	2025	3	1
20250722	2025-07-22	22	7	2025	3	2
20250723	2025-07-23	23	7	2025	3	3
20250724	2025-07-24	24	7	2025	3	4
20250725	2025-07-25	25	7	2025	3	5
20250726	2025-07-26	26	7	2025	3	6
20250727	2025-07-27	27	7	2025	3	0
20250728	2025-07-28	28	7	2025	3	1
20250729	2025-07-29	29	7	2025	3	2
20250730	2025-07-30	30	7	2025	3	3
20250731	2025-07-31	31	7	2025	3	4
20250801	2025-08-01	1	8	2025	3	5
20250802	2025-08-02	2	8	2025	3	6
20250803	2025-08-03	3	8	2025	3	0
20250804	2025-08-04	4	8	2025	3	1
20250805	2025-08-05	5	8	2025	3	2
20250806	2025-08-06	6	8	2025	3	3
20250807	2025-08-07	7	8	2025	3	4
20250808	2025-08-08	8	8	2025	3	5
20250809	2025-08-09	9	8	2025	3	6
20250810	2025-08-10	10	8	2025	3	0
20250811	2025-08-11	11	8	2025	3	1
20250812	2025-08-12	12	8	2025	3	2
20250813	2025-08-13	13	8	2025	3	3
20250814	2025-08-14	14	8	2025	3	4
20250815	2025-08-15	15	8	2025	3	5
20250816	2025-08-16	16	8	2025	3	6
20250817	2025-08-17	17	8	2025	3	0
20250818	2025-08-18	18	8	2025	3	1
20250819	2025-08-19	19	8	2025	3	2
20250820	2025-08-20	20	8	2025	3	3
20250821	2025-08-21	21	8	2025	3	4
20250822	2025-08-22	22	8	2025	3	5
20250823	2025-08-23	23	8	2025	3	6
20250824	2025-08-24	24	8	2025	3	0
20250825	2025-08-25	25	8	2025	3	1
20250826	2025-08-26	26	8	2025	3	2
20250827	2025-08-27	27	8	2025	3	3
20250828	2025-08-28	28	8	2025	3	4
20250829	2025-08-29	29	8	2025	3	5
20250830	2025-08-30	30	8	2025	3	6
20250831	2025-08-31	31	8	2025	3	0
20250901	2025-09-01	1	9	2025	3	1
20250902	2025-09-02	2	9	2025	3	2
20250903	2025-09-03	3	9	2025	3	3
20250904	2025-09-04	4	9	2025	3	4
20250905	2025-09-05	5	9	2025	3	5
20250906	2025-09-06	6	9	2025	3	6
20250907	2025-09-07	7	9	2025	3	0
20250908	2025-09-08	8	9	2025	3	1
20250909	2025-09-09	9	9	2025	3	2
20250910	2025-09-10	10	9	2025	3	3
20250911	2025-09-11	11	9	2025	3	4
20250912	2025-09-12	12	9	2025	3	5
20250913	2025-09-13	13	9	2025	3	6
20250914	2025-09-14	14	9	2025	3	0
20250915	2025-09-15	15	9	2025	3	1
20250916	2025-09-16	16	9	2025	3	2
20250917	2025-09-17	17	9	2025	3	3
20250918	2025-09-18	18	9	2025	3	4
20250919	2025-09-19	19	9	2025	3	5
20250920	2025-09-20	20	9	2025	3	6
20250921	2025-09-21	21	9	2025	3	0
20250922	2025-09-22	22	9	2025	3	1
20250923	2025-09-23	23	9	2025	3	2
20250924	2025-09-24	24	9	2025	3	3
20250925	2025-09-25	25	9	2025	3	4
20250926	2025-09-26	26	9	2025	3	5
20250927	2025-09-27	27	9	2025	3	6
20250928	2025-09-28	28	9	2025	3	0
20250929	2025-09-29	29	9	2025	3	1
20250930	2025-09-30	30	9	2025	3	2
20251001	2025-10-01	1	10	2025	4	3
20251002	2025-10-02	2	10	2025	4	4
20251003	2025-10-03	3	10	2025	4	5
20251004	2025-10-04	4	10	2025	4	6
20251005	2025-10-05	5	10	2025	4	0
20251006	2025-10-06	6	10	2025	4	1
20251007	2025-10-07	7	10	2025	4	2
20251008	2025-10-08	8	10	2025	4	3
20251009	2025-10-09	9	10	2025	4	4
20251010	2025-10-10	10	10	2025	4	5
20251011	2025-10-11	11	10	2025	4	6
20251012	2025-10-12	12	10	2025	4	0
20251013	2025-10-13	13	10	2025	4	1
20251014	2025-10-14	14	10	2025	4	2
20251015	2025-10-15	15	10	2025	4	3
20251016	2025-10-16	16	10	2025	4	4
20251017	2025-10-17	17	10	2025	4	5
20251018	2025-10-18	18	10	2025	4	6
20251019	2025-10-19	19	10	2025	4	0
20251020	2025-10-20	20	10	2025	4	1
20251021	2025-10-21	21	10	2025	4	2
20251022	2025-10-22	22	10	2025	4	3
20251023	2025-10-23	23	10	2025	4	4
20251024	2025-10-24	24	10	2025	4	5
20251025	2025-10-25	25	10	2025	4	6
20251026	2025-10-26	26	10	2025	4	0
20251027	2025-10-27	27	10	2025	4	1
20251028	2025-10-28	28	10	2025	4	2
20251029	2025-10-29	29	10	2025	4	3
20251030	2025-10-30	30	10	2025	4	4
20251031	2025-10-31	31	10	2025	4	5
20251101	2025-11-01	1	11	2025	4	6
20251102	2025-11-02	2	11	2025	4	0
20251103	2025-11-03	3	11	2025	4	1
20251104	2025-11-04	4	11	2025	4	2
20251105	2025-11-05	5	11	2025	4	3
20251106	2025-11-06	6	11	2025	4	4
20251107	2025-11-07	7	11	2025	4	5
20251108	2025-11-08	8	11	2025	4	6
20251109	2025-11-09	9	11	2025	4	0
20251110	2025-11-10	10	11	2025	4	1
20251111	2025-11-11	11	11	2025	4	2
20251112	2025-11-12	12	11	2025	4	3
20251113	2025-11-13	13	11	2025	4	4
20251114	2025-11-14	14	11	2025	4	5
20251115	2025-11-15	15	11	2025	4	6
20251116	2025-11-16	16	11	2025	4	0
20251117	2025-11-17	17	11	2025	4	1
20251118	2025-11-18	18	11	2025	4	2
20251119	2025-11-19	19	11	2025	4	3
20251120	2025-11-20	20	11	2025	4	4
20251121	2025-11-21	21	11	2025	4	5
20251122	2025-11-22	22	11	2025	4	6
20251123	2025-11-23	23	11	2025	4	0
20251124	2025-11-24	24	11	2025	4	1
20251125	2025-11-25	25	11	2025	4	2
20251126	2025-11-26	26	11	2025	4	3
20251127	2025-11-27	27	11	2025	4	4
20251128	2025-11-28	28	11	2025	4	5
20251129	2025-11-29	29	11	2025	4	6
20251130	2025-11-30	30	11	2025	4	0
20251201	2025-12-01	1	12	2025	4	1
20251202	2025-12-02	2	12	2025	4	2
20251203	2025-12-03	3	12	2025	4	3
20251204	2025-12-04	4	12	2025	4	4
20251205	2025-12-05	5	12	2025	4	5
20251206	2025-12-06	6	12	2025	4	6
20251207	2025-12-07	7	12	2025	4	0
20251208	2025-12-08	8	12	2025	4	1
20251209	2025-12-09	9	12	2025	4	2
20251210	2025-12-10	10	12	2025	4	3
20251211	2025-12-11	11	12	2025	4	4
20251212	2025-12-12	12	12	2025	4	5
20251213	2025-12-13	13	12	2025	4	6
20251214	2025-12-14	14	12	2025	4	0
20251215	2025-12-15	15	12	2025	4	1
20251216	2025-12-16	16	12	2025	4	2
20251217	2025-12-17	17	12	2025	4	3
20251218	2025-12-18	18	12	2025	4	4
20251219	2025-12-19	19	12	2025	4	5
20251220	2025-12-20	20	12	2025	4	6
20251221	2025-12-21	21	12	2025	4	0
20251222	2025-12-22	22	12	2025	4	1
20251223	2025-12-23	23	12	2025	4	2
20251224	2025-12-24	24	12	2025	4	3
20251225	2025-12-25	25	12	2025	4	4
20251226	2025-12-26	26	12	2025	4	5
20251227	2025-12-27	27	12	2025	4	6
20251228	2025-12-28	28	12	2025	4	0
20251229	2025-12-29	29	12	2025	4	1
20251230	2025-12-30	30	12	2025	4	2
20251231	2025-12-31	31	12	2025	4	3
\.


--
-- TOC entry 5046 (class 0 OID 47588)
-- Dependencies: 234
-- Data for Name: dt_tipo_actividad; Type: TABLE DATA; Schema: dw; Owner: postgres
--

COPY dw.dt_tipo_actividad (sk_tipo_actividad, id_tipo_actividad, nombre_tipo, descripcion) FROM stdin;
9	1	Taller	Actividades prácticas de aprendizaje
10	2	Charla	Charlas informativas y educativas
11	3	Evento	Eventos sociales o institucionales
12	4	Deporte	Actividades físicas o recreativas
\.


--
-- TOC entry 5044 (class 0 OID 47579)
-- Dependencies: 232
-- Data for Name: dt_usuario; Type: TABLE DATA; Schema: dw; Owner: postgres
--

COPY dw.dt_usuario (sk_usuario, id_usuario, nombre_completo, tipo_usuario, correo, estado) FROM stdin;
41	20	Matías Rey Peduzzi	SOCIO	MATI@gmail.com	t
42	2	Victoria Rey Peduzzi	SOCIO	vic@gmail.com	t
43	19	Virginia Peduzzi Mendez	NO SOCIO	virgi@gmail.com	t
44	1	Admin Admin Admin	ADMIN	admin@admin.com	t
45	17	Ana Rey Pérez	SOCIO	ana.perez@gmail.com	t
46	18	Luis Lopez Rodríguez	SOCIO	luis.rodriguez@gmail.com	t
47	3	Carla Fernández Gómez	NO SOCIO	carla.gomez@gmail.com	t
48	4	Jorge Peduzzi Fernández	SOCIO	jorge.fernandez@gmail.com	t
49	5	María Vega López	AUX	maria.lopez@gmail.com	t
50	6	Pedro Hornos Silva	SOCIO	pedro.silva@gmail.com	t
51	7	Valentina Lapaz Ramos	NO SOCIO	valentina.ramos@gmail.com	t
52	8	Andrea Alba Cruz	SOCIO	andrea.cruz@gmail.com	t
53	9	Camilo Messi Suárez	SOCIO	camilo.suarez@gmail.com	t
54	10	Sofía Martínez Paz	SOCIO	sofia.martinez@gmail.com	t
55	11	Esteban Pintos Iglesias	NO SOCIO	esteban.pintos@gmail.com	t
56	12	Lucía Reyes Reyes	SOCIO	lucia.reyes@gmail.com	t
57	13	Diego Benítez Palermo	SOCIO	diego.benitez@gmail.com	t
58	14	Micaela Ortiz Flores	SOCIO	micaela.ortiz@gmail.com	t
59	15	Ramiro Vega Ramírez	NO SOCIO	ramiro.vega@gmail.com	t
60	16	Juan Zapata Furtado	SOCIO	juan.zapata@gmail.com	t
\.


--
-- TOC entry 5053 (class 0 OID 47630)
-- Dependencies: 241
-- Data for Name: ht_inscriptos; Type: TABLE DATA; Schema: dw; Owner: postgres
--

COPY dw.ht_inscriptos (id_inscripcion, sk_usuario, sk_actividad, sk_fecha, ins_cancelada, id_espacio_sk, id_tipo_actividad_sk) FROM stdin;
1	44	18	20230910	f	9	11
2	47	25	20231001	f	9	9
3	48	25	20231002	f	9	9
4	53	18	20230915	f	9	11
5	55	18	20230920	t	9	11
6	56	25	20231010	f	9	9
7	57	30	20231215	f	12	12
8	58	30	20231216	t	12	12
9	59	25	20231018	f	9	9
10	60	25	20231020	f	9	9
11	45	18	20230925	f	9	11
12	46	30	20231218	f	12	12
13	43	30	20231220	t	12	12
14	41	30	20231222	f	12	12
15	50	30	20231226	f	12	12
16	51	18	20230927	f	9	11
17	52	25	20231025	t	9	9
18	53	30	20231228	f	12	12
19	54	18	20230929	f	9	11
20	55	25	20231029	f	9	9
21	56	18	20230926	f	9	11
22	58	18	20230914	f	9	11
23	60	30	20231223	f	12	12
24	46	25	20231003	f	9	9
25	41	18	20230919	f	9	11
26	44	19	20240301	f	10	9
27	42	19	20240303	t	10	9
28	48	21	20240502	f	12	12
29	49	22	20240601	f	10	9
30	50	22	20240603	f	10	9
31	51	26	20241001	f	10	9
32	52	26	20241002	t	10	9
33	53	29	20241201	f	9	11
34	54	29	20241203	f	9	11
35	55	19	20240304	f	10	9
36	56	19	20240306	f	10	9
37	58	21	20240505	f	12	12
38	45	22	20240607	f	10	9
39	46	26	20241003	f	10	9
40	43	26	20241005	f	10	9
41	42	29	20241207	t	9	11
42	47	29	20241208	f	9	11
43	49	21	20240510	f	12	12
44	50	21	20240512	f	12	12
45	51	22	20240610	f	10	9
46	52	22	20240612	f	10	9
47	53	22	20240613	t	10	9
48	54	26	20241007	f	10	9
49	55	26	20241009	f	10	9
50	56	26	20241011	f	10	9
51	57	19	20240310	f	10	9
52	58	19	20240311	f	10	9
53	59	21	20240507	f	12	12
54	60	22	20240608	f	10	9
55	45	26	20241013	f	10	9
56	46	29	20241208	f	9	11
57	43	29	20241209	t	9	11
58	41	26	20241012	f	10	9
59	48	29	20241210	f	9	11
60	49	29	20241211	f	9	11
61	50	29	20241212	f	9	11
62	51	29	20241213	f	9	11
63	54	19	20240305	f	10	9
64	44	16	20250105	f	9	9
65	42	16	20250106	f	9	9
66	47	16	20250107	f	9	9
67	48	16	20250108	t	9	9
68	49	20	20250401	f	11	10
69	50	20	20250402	t	11	10
70	51	23	20250701	f	11	10
71	52	23	20250702	f	11	10
72	53	24	20250801	f	9	11
73	54	24	20250802	f	9	11
74	55	24	20250803	t	9	11
75	56	27	20251001	f	11	10
76	57	27	20251002	f	11	10
77	58	27	20251003	f	11	10
78	59	27	20251004	t	11	10
79	46	28	20251103	f	10	9
80	43	28	20251104	t	10	9
81	41	28	20251105	f	10	9
82	44	23	20250703	f	11	10
83	42	23	20250704	f	11	10
84	47	24	20250805	f	9	11
85	48	24	20250806	t	9	11
86	49	24	20250807	f	9	11
87	51	27	20251006	f	11	10
88	52	27	20251007	f	11	10
89	53	27	20251008	f	11	10
90	54	27	20251009	f	11	10
\.


--
-- TOC entry 5040 (class 0 OID 47544)
-- Dependencies: 228
-- Data for Name: ods_d_actividad; Type: TABLE DATA; Schema: ods; Owner: postgres
--

COPY ods.ods_d_actividad (id_actividad, nombre_actividad, tipo_pago, costo, duracion, id_tipo_actividad, id_espacio) FROM stdin;
1	Taller LSU	TRANSFER	300.00	90	1	1
2	Charla sobre inclusión	EFECTIVO	0.00	60	2	3
3	Evento Día del Sordo	TRANSFER	200.00	180	3	1
4	Taller de cocina	EFECTIVO	250.00	120	1	2
5	Charla de accesibilidad	TRANSFER	0.00	60	2	3
6	Clases de fútbol adaptado	TRANSFER	150.00	120	4	4
7	Taller de pintura	EFECTIVO	200.00	90	1	2
8	Charla motivacional	EFECTIVO	0.00	60	2	3
9	Feria de integración	TRANSFER	100.00	180	3	1
10	Taller de música	EFECTIVO	250.00	120	1	1
11	Taller de tecnología accesible	TRANSFER	200.00	120	1	2
12	Charla de salud auditiva	EFECTIVO	0.00	60	2	3
13	Taller de costura inclusiva	EFECTIVO	180.00	90	1	2
14	Evento de fin de año	TRANSFER	300.00	180	3	1
15	Torneo recreativo	EFECTIVO	100.00	120	4	4
\.


--
-- TOC entry 5038 (class 0 OID 47534)
-- Dependencies: 226
-- Data for Name: ods_d_espacio; Type: TABLE DATA; Schema: ods; Owner: postgres
--

COPY ods.ods_d_espacio (id_espacio, nombre_espacio, capacidad, estado) FROM stdin;
1	Salón Principal	50	t
2	Aula Taller	25	t
3	Sala Reuniones	15	t
4	Patio Exterior	40	t
\.


--
-- TOC entry 5037 (class 0 OID 47529)
-- Dependencies: 225
-- Data for Name: ods_d_tipo_actividad; Type: TABLE DATA; Schema: ods; Owner: postgres
--

COPY ods.ods_d_tipo_actividad (id_tipo_actividad, nombre_tipo, descripcion) FROM stdin;
1	Taller	Actividades prácticas de aprendizaje
2	Charla	Charlas informativas y educativas
3	Evento	Eventos sociales o institucionales
4	Deporte	Actividades físicas o recreativas
\.


--
-- TOC entry 5039 (class 0 OID 47539)
-- Dependencies: 227
-- Data for Name: ods_d_usuario; Type: TABLE DATA; Schema: ods; Owner: postgres
--

COPY ods.ods_d_usuario (id_usuario, correo, estado, nombre_completo, tipo_usuario) FROM stdin;
20	MATI@gmail.com	t	Matías Rey Peduzzi	SOCIO
2	vic@gmail.com	t	Victoria Rey Peduzzi	SOCIO
19	virgi@gmail.com	t	Virginia Peduzzi Mendez	NO SOCIO
1	admin@admin.com	t	Admin Admin Admin	ADMIN
17	ana.perez@gmail.com	t	Ana Rey Pérez	SOCIO
18	luis.rodriguez@gmail.com	t	Luis Lopez Rodríguez	SOCIO
3	carla.gomez@gmail.com	t	Carla Fernández Gómez	NO SOCIO
4	jorge.fernandez@gmail.com	t	Jorge Peduzzi Fernández	SOCIO
5	maria.lopez@gmail.com	t	María Vega López	AUX
6	pedro.silva@gmail.com	t	Pedro Hornos Silva	SOCIO
7	valentina.ramos@gmail.com	t	Valentina Lapaz Ramos	NO SOCIO
8	andrea.cruz@gmail.com	t	Andrea Alba Cruz	SOCIO
9	camilo.suarez@gmail.com	t	Camilo Messi Suárez	SOCIO
10	sofia.martinez@gmail.com	t	Sofía Martínez Paz	SOCIO
11	esteban.pintos@gmail.com	t	Esteban Pintos Iglesias	NO SOCIO
12	lucia.reyes@gmail.com	t	Lucía Reyes Reyes	SOCIO
13	diego.benitez@gmail.com	t	Diego Benítez Palermo	SOCIO
14	micaela.ortiz@gmail.com	t	Micaela Ortiz Flores	SOCIO
15	ramiro.vega@gmail.com	t	Ramiro Vega Ramírez	NO SOCIO
16	juan.zapata@gmail.com	t	Juan Zapata Furtado	SOCIO
\.


--
-- TOC entry 5042 (class 0 OID 47560)
-- Dependencies: 230
-- Data for Name: ods_h_inscriptos; Type: TABLE DATA; Schema: ods; Owner: postgres
--

COPY ods.ods_h_inscriptos (id_inscripcion, id_usuario, id_actividad, fecha_inscripcion, mes_inscripcion, anio_inscripcion, ins_cancelada) FROM stdin;
91	1	3	2023-09-10	9	2023	f
92	3	10	2023-10-01	10	2023	f
93	4	10	2023-10-02	10	2023	f
94	9	3	2023-09-15	9	2023	f
95	11	3	2023-09-20	9	2023	t
96	12	10	2023-10-10	10	2023	f
97	13	15	2023-12-15	12	2023	f
98	14	15	2023-12-16	12	2023	t
99	15	10	2023-10-18	10	2023	f
100	16	10	2023-10-20	10	2023	f
101	17	3	2023-09-25	9	2023	f
102	18	15	2023-12-18	12	2023	f
103	19	15	2023-12-20	12	2023	t
104	20	15	2023-12-22	12	2023	f
105	6	15	2023-12-26	12	2023	f
106	7	3	2023-09-27	9	2023	f
107	8	10	2023-10-25	10	2023	t
108	9	15	2023-12-28	12	2023	f
109	10	3	2023-09-29	9	2023	f
110	11	10	2023-10-29	10	2023	f
111	12	3	2023-09-26	9	2023	f
112	14	3	2023-09-14	9	2023	f
113	16	15	2023-12-23	12	2023	f
114	18	10	2023-10-03	10	2023	f
115	20	3	2023-09-19	9	2023	f
116	1	4	2024-03-01	3	2024	f
117	2	4	2024-03-03	3	2024	t
118	4	6	2024-05-02	5	2024	f
119	5	7	2024-06-01	6	2024	f
120	6	7	2024-06-03	6	2024	f
121	7	11	2024-10-01	10	2024	f
122	8	11	2024-10-02	10	2024	t
123	9	14	2024-12-01	12	2024	f
124	10	14	2024-12-03	12	2024	f
125	11	4	2024-03-04	3	2024	f
126	12	4	2024-03-06	3	2024	f
127	14	6	2024-05-05	5	2024	f
128	17	7	2024-06-07	6	2024	f
129	18	11	2024-10-03	10	2024	f
130	19	11	2024-10-05	10	2024	f
131	2	14	2024-12-07	12	2024	t
132	3	14	2024-12-08	12	2024	f
133	5	6	2024-05-10	5	2024	f
134	6	6	2024-05-12	5	2024	f
135	7	7	2024-06-10	6	2024	f
136	8	7	2024-06-12	6	2024	f
137	9	7	2024-06-13	6	2024	t
138	10	11	2024-10-07	10	2024	f
139	11	11	2024-10-09	10	2024	f
140	12	11	2024-10-11	10	2024	f
141	13	4	2024-03-10	3	2024	f
142	14	4	2024-03-11	3	2024	f
143	15	6	2024-05-07	5	2024	f
144	16	7	2024-06-08	6	2024	f
145	17	11	2024-10-13	10	2024	f
146	18	14	2024-12-08	12	2024	f
147	19	14	2024-12-09	12	2024	t
148	20	11	2024-10-12	10	2024	f
149	4	14	2024-12-10	12	2024	f
150	5	14	2024-12-11	12	2024	f
151	6	14	2024-12-12	12	2024	f
152	7	14	2024-12-13	12	2024	f
153	10	4	2024-03-05	3	2024	f
154	1	1	2025-01-05	1	2025	f
155	2	1	2025-01-06	1	2025	f
156	3	1	2025-01-07	1	2025	f
157	4	1	2025-01-08	1	2025	t
158	5	5	2025-04-01	4	2025	f
159	6	5	2025-04-02	4	2025	t
160	7	8	2025-07-01	7	2025	f
161	8	8	2025-07-02	7	2025	f
162	9	9	2025-08-01	8	2025	f
163	10	9	2025-08-02	8	2025	f
164	11	9	2025-08-03	8	2025	t
165	12	12	2025-10-01	10	2025	f
166	13	12	2025-10-02	10	2025	f
167	14	12	2025-10-03	10	2025	f
168	15	12	2025-10-04	10	2025	t
169	18	13	2025-11-03	11	2025	f
170	19	13	2025-11-04	11	2025	t
171	20	13	2025-11-05	11	2025	f
172	1	8	2025-07-03	7	2025	f
173	2	8	2025-07-04	7	2025	f
174	3	9	2025-08-05	8	2025	f
175	4	9	2025-08-06	8	2025	t
176	5	9	2025-08-07	8	2025	f
177	7	12	2025-10-06	10	2025	f
178	8	12	2025-10-07	10	2025	f
179	9	12	2025-10-08	10	2025	f
180	10	12	2025-10-09	10	2025	f
\.


--
-- TOC entry 5034 (class 0 OID 47451)
-- Dependencies: 221
-- Data for Name: d_actividad; Type: TABLE DATA; Schema: staging; Owner: postgres
--

COPY staging.d_actividad (id_actividad, nombre_actividad, tipo_pago, costo, duracion, id_tipo_actividad, id_espacio) FROM stdin;
1	Taller LSU	Transfer	300.00	90	1	1
2	Charla sobre inclusión	Efectivo	0.00	60	2	3
3	Evento Día del Sordo	Transfer	200.00	180	3	1
4	Taller de cocina	Efectivo	250.00	120	1	2
5	Charla de accesibilidad	Transfer	0.00	60	2	3
6	Clases de fútbol adaptado	Transfer	150.00	120	4	4
7	Taller de pintura	Efectivo	200.00	90	1	2
8	Charla motivacional	Efectivo	0.00	60	2	3
9	Feria de integración	Transfer	100.00	180	3	1
10	Taller de música	Efectivo	250.00	120	1	1
11	Taller de tecnología accesible	Transfer	200.00	120	1	2
12	Charla de salud auditiva	Efectivo	0.00	60	2	3
13	Taller de costura inclusiva	Efectivo	180.00	90	1	2
14	Evento de fin de año	Transfer	300.00	180	3	1
15	Torneo recreativo	Efectivo	100.00	120	4	4
\.


--
-- TOC entry 5033 (class 0 OID 47424)
-- Dependencies: 220
-- Data for Name: d_espacio; Type: TABLE DATA; Schema: staging; Owner: postgres
--

COPY staging.d_espacio (id_espacio, nombre_espacio, capacidad, estado) FROM stdin;
1	Salón Principal	50	t
2	Aula Taller	25	t
3	Sala Reuniones	15	t
4	Patio Exterior	40	t
\.


--
-- TOC entry 5032 (class 0 OID 47419)
-- Dependencies: 219
-- Data for Name: d_tipo_actividad; Type: TABLE DATA; Schema: staging; Owner: postgres
--

COPY staging.d_tipo_actividad (id_tipo_actividad, nombre_tipo, descripcion) FROM stdin;
1	Taller	Actividades prácticas de aprendizaje
2	Charla	Charlas informativas y educativas
3	Evento	Eventos sociales o institucionales
4	Deporte	Actividades físicas o recreativas
\.


--
-- TOC entry 5031 (class 0 OID 47414)
-- Dependencies: 218
-- Data for Name: d_usuario; Type: TABLE DATA; Schema: staging; Owner: postgres
--

COPY staging.d_usuario (id_usuario, nombre_completo, tipo_usuario, correo, telefono, id_ciudad, categoria_socio, dif_auditiva, len_sena) FROM stdin;
20	Matías Rey Peduzzi	SOCIO	MATI@gmail.com	\N	7	\N	\N	\N
2	Victoria Rey Peduzzi	SOCIO	vic@gmail.com	\N	2	\N	\N	\N
19	Virginia Peduzzi Mendez	NO SOCIO	virgi@gmail.com	\N	6	\N	\N	\N
1	Admin Admin Admin	ADMIN	admin@admin.com	\N	28	\N	\N	\N
17	Ana Rey Pérez	SOCIO	ana.perez@gmail.com	\N	1	\N	\N	\N
18	Luis Lopez Rodríguez	SOCIO	luis.rodriguez@gmail.com	\N	1	Activo	t	t
3	Carla Fernández Gómez	NO SOCIO	carla.gomez@gmail.com	\N	2	\N	\N	\N
4	Jorge Peduzzi Fernández	SOCIO	jorge.fernandez@gmail.com	\N	1	Honorario	f	t
5	María Vega López	AUX	maria.lopez@gmail.com	\N	3	\N	\N	\N
6	Pedro Hornos Silva	SOCIO	pedro.silva@gmail.com	\N	1	Activo	t	t
7	Valentina Lapaz Ramos	NO SOCIO	valentina.ramos@gmail.com	\N	2	\N	\N	\N
8	Andrea Alba Cruz	SOCIO	andrea.cruz@gmail.com	\N	3	Adherente	f	f
9	Camilo Messi Suárez	SOCIO	camilo.suarez@gmail.com	\N	2	Activo	t	f
10	Sofía Martínez Paz	SOCIO	sofia.martinez@gmail.com	\N	1	Adherente	t	t
11	Esteban Pintos Iglesias	NO SOCIO	esteban.pintos@gmail.com	\N	1	\N	\N	\N
12	Lucía Reyes Reyes	SOCIO	lucia.reyes@gmail.com	\N	3	Honorario	f	t
13	Diego Benítez Palermo	SOCIO	diego.benitez@gmail.com	\N	1	Activo	t	t
14	Micaela Ortiz Flores	SOCIO	micaela.ortiz@gmail.com	\N	2	Activo	t	f
15	Ramiro Vega Ramírez	NO SOCIO	ramiro.vega@gmail.com	\N	2	\N	\N	\N
16	Juan Zapata Furtado	SOCIO	juan.zapata@gmail.com	\N	3	Activo	t	f
\.


--
-- TOC entry 5036 (class 0 OID 47467)
-- Dependencies: 223
-- Data for Name: h_inscriptos; Type: TABLE DATA; Schema: staging; Owner: postgres
--

COPY staging.h_inscriptos (id_inscripcion, id_usuario, id_actividad, fecha_inscripcion, ins_cancelada) FROM stdin;
1	1	3	2023-09-10	f
2	3	10	2023-10-01	f
3	4	10	2023-10-02	f
4	9	3	2023-09-15	f
5	11	3	2023-09-20	t
6	12	10	2023-10-10	f
7	13	15	2023-12-15	f
8	14	15	2023-12-16	t
9	15	10	2023-10-18	f
10	16	10	2023-10-20	f
11	17	3	2023-09-25	f
12	18	15	2023-12-18	f
13	19	15	2023-12-20	t
14	20	15	2023-12-22	f
15	6	15	2023-12-26	f
16	7	3	2023-09-27	f
17	8	10	2023-10-25	t
18	9	15	2023-12-28	f
19	10	3	2023-09-29	f
20	11	10	2023-10-29	f
21	12	3	2023-09-26	f
22	14	3	2023-09-14	f
23	16	15	2023-12-23	f
24	18	10	2023-10-03	f
25	20	3	2023-09-19	f
26	1	4	2024-03-01	f
27	2	4	2024-03-03	t
28	4	6	2024-05-02	f
29	5	7	2024-06-01	f
30	6	7	2024-06-03	f
31	7	11	2024-10-01	f
32	8	11	2024-10-02	t
33	9	14	2024-12-01	f
34	10	14	2024-12-03	f
35	11	4	2024-03-04	f
36	12	4	2024-03-06	f
37	14	6	2024-05-05	f
38	17	7	2024-06-07	f
39	18	11	2024-10-03	f
40	19	11	2024-10-05	f
41	2	14	2024-12-07	t
42	3	14	2024-12-08	f
43	5	6	2024-05-10	f
44	6	6	2024-05-12	f
45	7	7	2024-06-10	f
46	8	7	2024-06-12	f
47	9	7	2024-06-13	t
48	10	11	2024-10-07	f
49	11	11	2024-10-09	f
50	12	11	2024-10-11	f
51	13	4	2024-03-10	f
52	14	4	2024-03-11	f
53	15	6	2024-05-07	f
54	16	7	2024-06-08	f
55	17	11	2024-10-13	f
56	18	14	2024-12-08	f
57	19	14	2024-12-09	t
58	20	11	2024-10-12	f
59	4	14	2024-12-10	f
60	5	14	2024-12-11	f
61	6	14	2024-12-12	f
62	7	14	2024-12-13	f
63	10	4	2024-03-05	f
64	1	1	2025-01-05	f
65	2	1	2025-01-06	f
66	3	1	2025-01-07	f
67	4	1	2025-01-08	t
68	5	5	2025-04-01	f
69	6	5	2025-04-02	t
70	7	8	2025-07-01	f
71	8	8	2025-07-02	f
72	9	9	2025-08-01	f
73	10	9	2025-08-02	f
74	11	9	2025-08-03	t
75	12	12	2025-10-01	f
76	13	12	2025-10-02	f
77	14	12	2025-10-03	f
78	15	12	2025-10-04	t
79	18	13	2025-11-03	f
80	19	13	2025-11-04	t
81	20	13	2025-11-05	f
82	1	8	2025-07-03	f
83	2	8	2025-07-04	f
84	3	9	2025-08-05	f
85	4	9	2025-08-06	t
86	5	9	2025-08-07	f
87	7	12	2025-10-06	f
88	8	12	2025-10-07	f
89	9	12	2025-10-08	f
90	10	12	2025-10-09	f
\.


--
-- TOC entry 5067 (class 0 OID 0)
-- Dependencies: 237
-- Name: dt_actividad_sk_actividad_seq; Type: SEQUENCE SET; Schema: dw; Owner: postgres
--

SELECT pg_catalog.setval('dw.dt_actividad_sk_actividad_seq', 30, true);


--
-- TOC entry 5068 (class 0 OID 0)
-- Dependencies: 235
-- Name: dt_espacio_sk_espacio_seq; Type: SEQUENCE SET; Schema: dw; Owner: postgres
--

SELECT pg_catalog.setval('dw.dt_espacio_sk_espacio_seq', 12, true);


--
-- TOC entry 5069 (class 0 OID 0)
-- Dependencies: 233
-- Name: dt_tipo_actividad_sk_tipo_actividad_seq; Type: SEQUENCE SET; Schema: dw; Owner: postgres
--

SELECT pg_catalog.setval('dw.dt_tipo_actividad_sk_tipo_actividad_seq', 12, true);


--
-- TOC entry 5070 (class 0 OID 0)
-- Dependencies: 231
-- Name: dt_usuario_sk_usuario_seq; Type: SEQUENCE SET; Schema: dw; Owner: postgres
--

SELECT pg_catalog.setval('dw.dt_usuario_sk_usuario_seq', 60, true);


--
-- TOC entry 5071 (class 0 OID 0)
-- Dependencies: 240
-- Name: ht_inscriptos_id_inscripcion_seq; Type: SEQUENCE SET; Schema: dw; Owner: postgres
--

SELECT pg_catalog.setval('dw.ht_inscriptos_id_inscripcion_seq', 90, true);


--
-- TOC entry 5072 (class 0 OID 0)
-- Dependencies: 229
-- Name: ods_h_inscriptos_id_inscripcion_seq; Type: SEQUENCE SET; Schema: ods; Owner: postgres
--

SELECT pg_catalog.setval('ods.ods_h_inscriptos_id_inscripcion_seq', 180, true);


--
-- TOC entry 5073 (class 0 OID 0)
-- Dependencies: 222
-- Name: h_inscriptos_id_inscripcion_seq; Type: SEQUENCE SET; Schema: staging; Owner: postgres
--

SELECT pg_catalog.setval('staging.h_inscriptos_id_inscripcion_seq', 90, true);


--
-- TOC entry 4861 (class 2606 OID 47613)
-- Name: dt_actividad dt_actividad_id_actividad_key; Type: CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_actividad
    ADD CONSTRAINT dt_actividad_id_actividad_key UNIQUE (id_actividad);


--
-- TOC entry 4863 (class 2606 OID 47611)
-- Name: dt_actividad dt_actividad_pkey; Type: CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_actividad
    ADD CONSTRAINT dt_actividad_pkey PRIMARY KEY (sk_actividad);


--
-- TOC entry 4857 (class 2606 OID 47604)
-- Name: dt_espacio dt_espacio_id_espacio_key; Type: CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_espacio
    ADD CONSTRAINT dt_espacio_id_espacio_key UNIQUE (id_espacio);


--
-- TOC entry 4859 (class 2606 OID 47602)
-- Name: dt_espacio dt_espacio_pkey; Type: CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_espacio
    ADD CONSTRAINT dt_espacio_pkey PRIMARY KEY (sk_espacio);


--
-- TOC entry 4865 (class 2606 OID 47628)
-- Name: dt_tiempo dt_tiempo_pkey; Type: CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_tiempo
    ADD CONSTRAINT dt_tiempo_pkey PRIMARY KEY (fecha_sk);


--
-- TOC entry 4853 (class 2606 OID 47595)
-- Name: dt_tipo_actividad dt_tipo_actividad_id_tipo_actividad_key; Type: CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_tipo_actividad
    ADD CONSTRAINT dt_tipo_actividad_id_tipo_actividad_key UNIQUE (id_tipo_actividad);


--
-- TOC entry 4855 (class 2606 OID 47593)
-- Name: dt_tipo_actividad dt_tipo_actividad_pkey; Type: CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_tipo_actividad
    ADD CONSTRAINT dt_tipo_actividad_pkey PRIMARY KEY (sk_tipo_actividad);


--
-- TOC entry 4849 (class 2606 OID 47586)
-- Name: dt_usuario dt_usuario_id_usuario_key; Type: CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_usuario
    ADD CONSTRAINT dt_usuario_id_usuario_key UNIQUE (id_usuario);


--
-- TOC entry 4851 (class 2606 OID 47584)
-- Name: dt_usuario dt_usuario_pkey; Type: CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_usuario
    ADD CONSTRAINT dt_usuario_pkey PRIMARY KEY (sk_usuario);


--
-- TOC entry 4867 (class 2606 OID 47635)
-- Name: ht_inscriptos ht_inscriptos_pkey; Type: CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.ht_inscriptos
    ADD CONSTRAINT ht_inscriptos_pkey PRIMARY KEY (id_inscripcion);


--
-- TOC entry 4869 (class 2606 OID 47637)
-- Name: ht_inscriptos ht_inscriptos_sk_usuario_sk_actividad_sk_fecha_key; Type: CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.ht_inscriptos
    ADD CONSTRAINT ht_inscriptos_sk_usuario_sk_actividad_sk_fecha_key UNIQUE (sk_usuario, sk_actividad, sk_fecha);


--
-- TOC entry 4845 (class 2606 OID 47548)
-- Name: ods_d_actividad ods_d_actividad_pkey; Type: CONSTRAINT; Schema: ods; Owner: postgres
--

ALTER TABLE ONLY ods.ods_d_actividad
    ADD CONSTRAINT ods_d_actividad_pkey PRIMARY KEY (id_actividad);


--
-- TOC entry 4841 (class 2606 OID 47538)
-- Name: ods_d_espacio ods_d_espacio_pkey; Type: CONSTRAINT; Schema: ods; Owner: postgres
--

ALTER TABLE ONLY ods.ods_d_espacio
    ADD CONSTRAINT ods_d_espacio_pkey PRIMARY KEY (id_espacio);


--
-- TOC entry 4839 (class 2606 OID 47533)
-- Name: ods_d_tipo_actividad ods_d_tipo_actividad_pkey; Type: CONSTRAINT; Schema: ods; Owner: postgres
--

ALTER TABLE ONLY ods.ods_d_tipo_actividad
    ADD CONSTRAINT ods_d_tipo_actividad_pkey PRIMARY KEY (id_tipo_actividad);


--
-- TOC entry 4843 (class 2606 OID 47543)
-- Name: ods_d_usuario ods_d_usuario_pkey; Type: CONSTRAINT; Schema: ods; Owner: postgres
--

ALTER TABLE ONLY ods.ods_d_usuario
    ADD CONSTRAINT ods_d_usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 4847 (class 2606 OID 47565)
-- Name: ods_h_inscriptos ods_h_inscriptos_pkey; Type: CONSTRAINT; Schema: ods; Owner: postgres
--

ALTER TABLE ONLY ods.ods_h_inscriptos
    ADD CONSTRAINT ods_h_inscriptos_pkey PRIMARY KEY (id_inscripcion);


--
-- TOC entry 4835 (class 2606 OID 47455)
-- Name: d_actividad d_actividad_pkey; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY staging.d_actividad
    ADD CONSTRAINT d_actividad_pkey PRIMARY KEY (id_actividad);


--
-- TOC entry 4833 (class 2606 OID 47428)
-- Name: d_espacio d_espacio_pkey; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY staging.d_espacio
    ADD CONSTRAINT d_espacio_pkey PRIMARY KEY (id_espacio);


--
-- TOC entry 4831 (class 2606 OID 47423)
-- Name: d_tipo_actividad d_tipo_actividad_pkey; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY staging.d_tipo_actividad
    ADD CONSTRAINT d_tipo_actividad_pkey PRIMARY KEY (id_tipo_actividad);


--
-- TOC entry 4829 (class 2606 OID 47418)
-- Name: d_usuario d_usuario_pkey; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY staging.d_usuario
    ADD CONSTRAINT d_usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 4837 (class 2606 OID 47472)
-- Name: h_inscriptos h_inscriptos_pkey; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY staging.h_inscriptos
    ADD CONSTRAINT h_inscriptos_pkey PRIMARY KEY (id_inscripcion);


--
-- TOC entry 4878 (class 2606 OID 47619)
-- Name: dt_actividad dt_actividad_id_espacio_sk_fkey; Type: FK CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_actividad
    ADD CONSTRAINT dt_actividad_id_espacio_sk_fkey FOREIGN KEY (id_espacio_sk) REFERENCES dw.dt_espacio(sk_espacio);


--
-- TOC entry 4879 (class 2606 OID 47614)
-- Name: dt_actividad dt_actividad_id_tipo_actividad_sk_fkey; Type: FK CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.dt_actividad
    ADD CONSTRAINT dt_actividad_id_tipo_actividad_sk_fkey FOREIGN KEY (id_tipo_actividad_sk) REFERENCES dw.dt_tipo_actividad(sk_tipo_actividad);


--
-- TOC entry 4880 (class 2606 OID 47659)
-- Name: ht_inscriptos ht_inscriptos_id_espacio_sk_fkey; Type: FK CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.ht_inscriptos
    ADD CONSTRAINT ht_inscriptos_id_espacio_sk_fkey FOREIGN KEY (id_espacio_sk) REFERENCES dw.dt_espacio(sk_espacio);


--
-- TOC entry 4881 (class 2606 OID 47664)
-- Name: ht_inscriptos ht_inscriptos_id_tipo_actividad_sk_fkey; Type: FK CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.ht_inscriptos
    ADD CONSTRAINT ht_inscriptos_id_tipo_actividad_sk_fkey FOREIGN KEY (id_tipo_actividad_sk) REFERENCES dw.dt_tipo_actividad(sk_tipo_actividad);


--
-- TOC entry 4882 (class 2606 OID 47643)
-- Name: ht_inscriptos ht_inscriptos_sk_actividad_fkey; Type: FK CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.ht_inscriptos
    ADD CONSTRAINT ht_inscriptos_sk_actividad_fkey FOREIGN KEY (sk_actividad) REFERENCES dw.dt_actividad(sk_actividad);


--
-- TOC entry 4883 (class 2606 OID 47648)
-- Name: ht_inscriptos ht_inscriptos_sk_fecha_fkey; Type: FK CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.ht_inscriptos
    ADD CONSTRAINT ht_inscriptos_sk_fecha_fkey FOREIGN KEY (sk_fecha) REFERENCES dw.dt_tiempo(fecha_sk);


--
-- TOC entry 4884 (class 2606 OID 47638)
-- Name: ht_inscriptos ht_inscriptos_sk_usuario_fkey; Type: FK CONSTRAINT; Schema: dw; Owner: postgres
--

ALTER TABLE ONLY dw.ht_inscriptos
    ADD CONSTRAINT ht_inscriptos_sk_usuario_fkey FOREIGN KEY (sk_usuario) REFERENCES dw.dt_usuario(sk_usuario);


--
-- TOC entry 4874 (class 2606 OID 47554)
-- Name: ods_d_actividad ods_d_actividad_id_espacio_fkey; Type: FK CONSTRAINT; Schema: ods; Owner: postgres
--

ALTER TABLE ONLY ods.ods_d_actividad
    ADD CONSTRAINT ods_d_actividad_id_espacio_fkey FOREIGN KEY (id_espacio) REFERENCES ods.ods_d_espacio(id_espacio);


--
-- TOC entry 4875 (class 2606 OID 47549)
-- Name: ods_d_actividad ods_d_actividad_id_tipo_actividad_fkey; Type: FK CONSTRAINT; Schema: ods; Owner: postgres
--

ALTER TABLE ONLY ods.ods_d_actividad
    ADD CONSTRAINT ods_d_actividad_id_tipo_actividad_fkey FOREIGN KEY (id_tipo_actividad) REFERENCES ods.ods_d_tipo_actividad(id_tipo_actividad);


--
-- TOC entry 4876 (class 2606 OID 47571)
-- Name: ods_h_inscriptos ods_h_inscriptos_id_actividad_fkey; Type: FK CONSTRAINT; Schema: ods; Owner: postgres
--

ALTER TABLE ONLY ods.ods_h_inscriptos
    ADD CONSTRAINT ods_h_inscriptos_id_actividad_fkey FOREIGN KEY (id_actividad) REFERENCES ods.ods_d_actividad(id_actividad);


--
-- TOC entry 4877 (class 2606 OID 47566)
-- Name: ods_h_inscriptos ods_h_inscriptos_id_usuario_fkey; Type: FK CONSTRAINT; Schema: ods; Owner: postgres
--

ALTER TABLE ONLY ods.ods_h_inscriptos
    ADD CONSTRAINT ods_h_inscriptos_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES ods.ods_d_usuario(id_usuario);


--
-- TOC entry 4870 (class 2606 OID 47461)
-- Name: d_actividad d_actividad_id_espacio_fkey; Type: FK CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY staging.d_actividad
    ADD CONSTRAINT d_actividad_id_espacio_fkey FOREIGN KEY (id_espacio) REFERENCES staging.d_espacio(id_espacio);


--
-- TOC entry 4871 (class 2606 OID 47456)
-- Name: d_actividad d_actividad_id_tipo_actividad_fkey; Type: FK CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY staging.d_actividad
    ADD CONSTRAINT d_actividad_id_tipo_actividad_fkey FOREIGN KEY (id_tipo_actividad) REFERENCES staging.d_tipo_actividad(id_tipo_actividad);


--
-- TOC entry 4872 (class 2606 OID 47478)
-- Name: h_inscriptos h_inscriptos_id_actividad_fkey; Type: FK CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY staging.h_inscriptos
    ADD CONSTRAINT h_inscriptos_id_actividad_fkey FOREIGN KEY (id_actividad) REFERENCES staging.d_actividad(id_actividad);


--
-- TOC entry 4873 (class 2606 OID 47473)
-- Name: h_inscriptos h_inscriptos_id_usuario_fkey; Type: FK CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY staging.h_inscriptos
    ADD CONSTRAINT h_inscriptos_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES staging.d_usuario(id_usuario);


-- Completed on 2025-11-08 23:48:50

--
-- PostgreSQL database dump complete
--

