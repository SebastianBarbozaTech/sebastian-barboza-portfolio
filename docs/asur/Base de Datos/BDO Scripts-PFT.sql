--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.3

-- Started on 2025-09-14 16:32:46

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 22155)
-- Name: acceso_funcionalidades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.acceso_funcionalidades (
    id_funcionalidad integer NOT NULL,
    id_perfil integer NOT NULL
);


ALTER TABLE public.acceso_funcionalidades OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 22158)
-- Name: actividades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.actividades (
    id_actividad bigint NOT NULL,
    actividad_nom character varying(100) NOT NULL,
    actividad_des character varying(255),
    objetivo character varying(255),
    fec_actividad date NOT NULL,
    hora_activdad time without time zone NOT NULL,
    duracion integer,
    inscripcion boolean,
    costo integer,
    fec_inscripcion date,
    tipo_pago character varying(10) NOT NULL,
    act_observaciones character varying(100),
    id_tipo_actividad integer,
    id_aux_administrativo bigint,
    id_espacio integer,
    act_estado boolean
);


ALTER TABLE public.actividades OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 22163)
-- Name: actividades_id_actividad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.actividades_id_actividad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.actividades_id_actividad_seq OWNER TO postgres;

--
-- TOC entry 5065 (class 0 OID 0)
-- Dependencies: 217
-- Name: actividades_id_actividad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.actividades_id_actividad_seq OWNED BY public.actividades.id_actividad;


--
-- TOC entry 218 (class 1259 OID 22164)
-- Name: aud_usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aud_usuarios (
    id_aud_usuario integer NOT NULL,
    fecha_hora timestamp without time zone NOT NULL,
    operacion character varying(20) NOT NULL,
    terminal character varying(20) NOT NULL,
    id_usuario integer NOT NULL,
    tabla_afectada character varying(50) NOT NULL
);


ALTER TABLE public.aud_usuarios OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 22167)
-- Name: aud_usuarios_id_aud_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aud_usuarios_id_aud_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.aud_usuarios_id_aud_usuario_seq OWNER TO postgres;

--
-- TOC entry 5066 (class 0 OID 0)
-- Dependencies: 219
-- Name: aud_usuarios_id_aud_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aud_usuarios_id_aud_usuario_seq OWNED BY public.aud_usuarios.id_aud_usuario;


--
-- TOC entry 220 (class 1259 OID 22168)
-- Name: aux_administrativos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aux_administrativos (
    id_aux_administrativo integer NOT NULL,
    id_usuario integer NOT NULL
);


ALTER TABLE public.aux_administrativos OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 22171)
-- Name: aux_administrativos_id_aux_administrativo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aux_administrativos_id_aux_administrativo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.aux_administrativos_id_aux_administrativo_seq OWNER TO postgres;

--
-- TOC entry 5067 (class 0 OID 0)
-- Dependencies: 221
-- Name: aux_administrativos_id_aux_administrativo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aux_administrativos_id_aux_administrativo_seq OWNED BY public.aux_administrativos.id_aux_administrativo;


--
-- TOC entry 222 (class 1259 OID 22172)
-- Name: ciudad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ciudad (
    id_ciudad integer NOT NULL,
    nom_ciudad character varying(40) NOT NULL,
    id_departamento integer
);


ALTER TABLE public.ciudad OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 22175)
-- Name: ciudad_id_ciudad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ciudad_id_ciudad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ciudad_id_ciudad_seq OWNER TO postgres;

--
-- TOC entry 5068 (class 0 OID 0)
-- Dependencies: 223
-- Name: ciudad_id_ciudad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ciudad_id_ciudad_seq OWNED BY public.ciudad.id_ciudad;


--
-- TOC entry 224 (class 1259 OID 22176)
-- Name: departamentos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departamentos (
    id_departamento integer NOT NULL,
    nom_departamento character varying(20) NOT NULL,
    id_pais integer
);


ALTER TABLE public.departamentos OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 22179)
-- Name: departamentos_id_departamento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.departamentos_id_departamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departamentos_id_departamento_seq OWNER TO postgres;

--
-- TOC entry 5069 (class 0 OID 0)
-- Dependencies: 225
-- Name: departamentos_id_departamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.departamentos_id_departamento_seq OWNED BY public.departamentos.id_departamento;


--
-- TOC entry 226 (class 1259 OID 22180)
-- Name: espacios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.espacios (
    id_espacio integer NOT NULL,
    nom_espacio character varying(20) NOT NULL,
    capacidad integer NOT NULL,
    precio_socio numeric(10,2),
    precio_no_socio numeric(10,2),
    vig_precio date,
    esp_observacion character varying(100),
    esp_estado boolean
);


ALTER TABLE public.espacios OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 22183)
-- Name: espacios_id_espacio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.espacios_id_espacio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.espacios_id_espacio_seq OWNER TO postgres;

--
-- TOC entry 5070 (class 0 OID 0)
-- Dependencies: 227
-- Name: espacios_id_espacio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.espacios_id_espacio_seq OWNED BY public.espacios.id_espacio;


--
-- TOC entry 228 (class 1259 OID 22184)
-- Name: funcionalidades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.funcionalidades (
    id_funcionalidad integer NOT NULL,
    nom_funcionalidad character varying(10) NOT NULL,
    des_funcionalidad character varying(50),
    fun_estado boolean NOT NULL
);


ALTER TABLE public.funcionalidades OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 22187)
-- Name: funcionalidades_id_funcionalidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.funcionalidades_id_funcionalidad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.funcionalidades_id_funcionalidad_seq OWNER TO postgres;

--
-- TOC entry 5071 (class 0 OID 0)
-- Dependencies: 229
-- Name: funcionalidades_id_funcionalidad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.funcionalidades_id_funcionalidad_seq OWNED BY public.funcionalidades.id_funcionalidad;


--
-- TOC entry 230 (class 1259 OID 22188)
-- Name: inscripcion_actividades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inscripcion_actividades (
    id_usuario bigint NOT NULL,
    id_actividad bigint NOT NULL,
    fec_inscripcion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ins_cancelada boolean DEFAULT false
);


ALTER TABLE public.inscripcion_actividades OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 22193)
-- Name: pago; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pago (
    id_pago bigint NOT NULL,
    fecha_cobro date NOT NULL,
    monto numeric(10,2) NOT NULL,
    forma_cobro character varying(10) NOT NULL,
    id_actividad bigint,
    id_reserva bigint,
    id_usuario bigint NOT NULL,
    cuota boolean NOT NULL,
    CONSTRAINT pago_forma_cobro_check CHECK (((forma_cobro)::text = ANY (ARRAY[('EFECTIVO'::character varying)::text, ('TRANSFERENCIA'::character varying)::text, ('DEBITO'::character varying)::text, ('CREDITO'::character varying)::text])))
);


ALTER TABLE public.pago OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 22197)
-- Name: pago_id_pago_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pago_id_pago_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pago_id_pago_seq OWNER TO postgres;

--
-- TOC entry 5072 (class 0 OID 0)
-- Dependencies: 232
-- Name: pago_id_pago_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pago_id_pago_seq OWNED BY public.pago.id_pago;


--
-- TOC entry 233 (class 1259 OID 22198)
-- Name: paises; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paises (
    id_pais integer NOT NULL,
    nom_pais character varying(100) NOT NULL
);


ALTER TABLE public.paises OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 22201)
-- Name: paises_id_pais_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.paises_id_pais_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.paises_id_pais_seq OWNER TO postgres;

--
-- TOC entry 5073 (class 0 OID 0)
-- Dependencies: 234
-- Name: paises_id_pais_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.paises_id_pais_seq OWNED BY public.paises.id_pais;


--
-- TOC entry 235 (class 1259 OID 22202)
-- Name: password_reset_token; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_token (
    token character varying(255) NOT NULL,
    user_id bigint,
    expiration timestamp without time zone,
    used boolean DEFAULT false
);


ALTER TABLE public.password_reset_token OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 22206)
-- Name: perfiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.perfiles (
    id_perfil integer NOT NULL,
    nom_perfil character varying(10) NOT NULL,
    des_perfil character varying(50),
    per_estado boolean NOT NULL
);


ALTER TABLE public.perfiles OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 22209)
-- Name: perfiles_id_perfil_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.perfiles_id_perfil_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.perfiles_id_perfil_seq OWNER TO postgres;

--
-- TOC entry 5074 (class 0 OID 0)
-- Dependencies: 237
-- Name: perfiles_id_perfil_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.perfiles_id_perfil_seq OWNED BY public.perfiles.id_perfil;


--
-- TOC entry 238 (class 1259 OID 22210)
-- Name: reserva_espacios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reserva_espacios (
    id_reserva bigint NOT NULL,
    fec_reserva_actividad date,
    hora_reserva_actividad time without time zone,
    duracion integer,
    cantidad_personas integer,
    fec_vto_sena date GENERATED ALWAYS AS ((fec_reserva_actividad - '5 days'::interval)) STORED,
    fec_pago_senia date,
    imp_pagado numeric(10,2),
    imp_a_pagar numeric(10,2),
    fec_conf_reserva date,
    hora_conf_reserva time without time zone,
    res_cancelada boolean DEFAULT false,
    id_usuario bigint NOT NULL,
    id_espacio integer NOT NULL,
    sdo_pendiente numeric GENERATED ALWAYS AS ((imp_a_pagar - imp_pagado)) STORED
);


ALTER TABLE public.reserva_espacios OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 22218)
-- Name: reserva_espacios_id_reserva_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reserva_espacios_id_reserva_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reserva_espacios_id_reserva_seq OWNER TO postgres;

--
-- TOC entry 5075 (class 0 OID 0)
-- Dependencies: 239
-- Name: reserva_espacios_id_reserva_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reserva_espacios_id_reserva_seq OWNED BY public.reserva_espacios.id_reserva;


--
-- TOC entry 240 (class 1259 OID 22219)
-- Name: socios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.socios (
    id_socio bigint NOT NULL,
    cat_socio character varying(50) NOT NULL,
    dif_auditiva boolean NOT NULL,
    len_sena boolean NOT NULL,
    id_usuario bigint,
    id_subcomision integer
);


ALTER TABLE public.socios OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 22222)
-- Name: socios_id_socio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.socios_id_socio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.socios_id_socio_seq OWNER TO postgres;

--
-- TOC entry 5076 (class 0 OID 0)
-- Dependencies: 241
-- Name: socios_id_socio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.socios_id_socio_seq OWNED BY public.socios.id_socio;


--
-- TOC entry 242 (class 1259 OID 22223)
-- Name: subcomisiones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subcomisiones (
    id_subcomision integer NOT NULL,
    nom_subcomision character varying(20) NOT NULL,
    des_subcomision character varying(50)
);


ALTER TABLE public.subcomisiones OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 22226)
-- Name: subcomisiones_id_subcomision_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.subcomisiones_id_subcomision_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.subcomisiones_id_subcomision_seq OWNER TO postgres;

--
-- TOC entry 5077 (class 0 OID 0)
-- Dependencies: 243
-- Name: subcomisiones_id_subcomision_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.subcomisiones_id_subcomision_seq OWNED BY public.subcomisiones.id_subcomision;


--
-- TOC entry 244 (class 1259 OID 22227)
-- Name: telefonos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telefonos (
    id_usuario integer NOT NULL,
    nro_telefono character varying(10) NOT NULL,
    tipo_telefono character varying(20) NOT NULL
);


ALTER TABLE public.telefonos OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 22230)
-- Name: tipo_actividades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_actividades (
    id_tipo_actividad integer NOT NULL,
    tipo_act_nombre character varying(20) NOT NULL,
    tipo_act_descripcion character varying(100),
    fec_baja date,
    raz_baja character varying(100),
    comentario character varying(200),
    tipo_act_estado boolean NOT NULL
);


ALTER TABLE public.tipo_actividades OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 22233)
-- Name: tipo_actividades_id_tipo_actividad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tipo_actividades_id_tipo_actividad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tipo_actividades_id_tipo_actividad_seq OWNER TO postgres;

--
-- TOC entry 5078 (class 0 OID 0)
-- Dependencies: 246
-- Name: tipo_actividades_id_tipo_actividad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tipo_actividades_id_tipo_actividad_seq OWNED BY public.tipo_actividades.id_tipo_actividad;


--
-- TOC entry 247 (class 1259 OID 22234)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id_usuario bigint NOT NULL,
    nro_documento character varying(10) NOT NULL,
    pri_nombre character varying(50) NOT NULL,
    seg_nombre character varying(50),
    pri_apellido character varying(50) NOT NULL,
    seg_apellido character varying(50),
    tipo_doc character varying(10) NOT NULL,
    fec_nacimiento date NOT NULL,
    tipo_usuario character varying(50) NOT NULL,
    correo character varying(100) NOT NULL,
    contrasena_hash character varying(255) NOT NULL,
    usu_estado boolean NOT NULL,
    calle character varying(100) NOT NULL,
    nro_puerta character varying(10) NOT NULL,
    cod_postal character varying(10),
    id_perfil integer,
    id_ciudad integer,
    id_pais integer NOT NULL,
    id_departamento integer,
    CONSTRAINT usuarios_tipo_doc_check CHECK (((tipo_doc)::text = ANY (ARRAY[('CI'::character varying)::text, ('DNI'::character varying)::text, ('PASAPORTE'::character varying)::text, ('OTRO'::character varying)::text])))
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 22240)
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarios_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_usuario_seq OWNER TO postgres;

--
-- TOC entry 5079 (class 0 OID 0)
-- Dependencies: 248
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarios_id_usuario_seq OWNED BY public.usuarios.id_usuario;


--
-- TOC entry 4774 (class 2604 OID 22241)
-- Name: actividades id_actividad; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actividades ALTER COLUMN id_actividad SET DEFAULT nextval('public.actividades_id_actividad_seq'::regclass);


--
-- TOC entry 4775 (class 2604 OID 22242)
-- Name: aud_usuarios id_aud_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aud_usuarios ALTER COLUMN id_aud_usuario SET DEFAULT nextval('public.aud_usuarios_id_aud_usuario_seq'::regclass);


--
-- TOC entry 4776 (class 2604 OID 22243)
-- Name: aux_administrativos id_aux_administrativo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aux_administrativos ALTER COLUMN id_aux_administrativo SET DEFAULT nextval('public.aux_administrativos_id_aux_administrativo_seq'::regclass);


--
-- TOC entry 4777 (class 2604 OID 22244)
-- Name: ciudad id_ciudad; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudad ALTER COLUMN id_ciudad SET DEFAULT nextval('public.ciudad_id_ciudad_seq'::regclass);


--
-- TOC entry 4778 (class 2604 OID 22245)
-- Name: departamentos id_departamento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamentos ALTER COLUMN id_departamento SET DEFAULT nextval('public.departamentos_id_departamento_seq'::regclass);


--
-- TOC entry 4779 (class 2604 OID 22246)
-- Name: espacios id_espacio; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.espacios ALTER COLUMN id_espacio SET DEFAULT nextval('public.espacios_id_espacio_seq'::regclass);


--
-- TOC entry 4780 (class 2604 OID 22247)
-- Name: funcionalidades id_funcionalidad; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionalidades ALTER COLUMN id_funcionalidad SET DEFAULT nextval('public.funcionalidades_id_funcionalidad_seq'::regclass);


--
-- TOC entry 4783 (class 2604 OID 22248)
-- Name: pago id_pago; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pago ALTER COLUMN id_pago SET DEFAULT nextval('public.pago_id_pago_seq'::regclass);


--
-- TOC entry 4784 (class 2604 OID 22249)
-- Name: paises id_pais; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paises ALTER COLUMN id_pais SET DEFAULT nextval('public.paises_id_pais_seq'::regclass);


--
-- TOC entry 4786 (class 2604 OID 22250)
-- Name: perfiles id_perfil; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfiles ALTER COLUMN id_perfil SET DEFAULT nextval('public.perfiles_id_perfil_seq'::regclass);


--
-- TOC entry 4787 (class 2604 OID 22251)
-- Name: reserva_espacios id_reserva; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reserva_espacios ALTER COLUMN id_reserva SET DEFAULT nextval('public.reserva_espacios_id_reserva_seq'::regclass);


--
-- TOC entry 4791 (class 2604 OID 22252)
-- Name: socios id_socio; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socios ALTER COLUMN id_socio SET DEFAULT nextval('public.socios_id_socio_seq'::regclass);


--
-- TOC entry 4792 (class 2604 OID 22253)
-- Name: subcomisiones id_subcomision; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subcomisiones ALTER COLUMN id_subcomision SET DEFAULT nextval('public.subcomisiones_id_subcomision_seq'::regclass);


--
-- TOC entry 4793 (class 2604 OID 22254)
-- Name: tipo_actividades id_tipo_actividad; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_actividades ALTER COLUMN id_tipo_actividad SET DEFAULT nextval('public.tipo_actividades_id_tipo_actividad_seq'::regclass);


--
-- TOC entry 4794 (class 2604 OID 22255)
-- Name: usuarios id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuarios_id_usuario_seq'::regclass);


--
-- TOC entry 5026 (class 0 OID 22155)
-- Dependencies: 215
-- Data for Name: acceso_funcionalidades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.acceso_funcionalidades (id_funcionalidad, id_perfil) FROM stdin;
\.


--
-- TOC entry 5027 (class 0 OID 22158)
-- Dependencies: 216
-- Data for Name: actividades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.actividades (id_actividad, actividad_nom, actividad_des, objetivo, fec_actividad, hora_activdad, duracion, inscripcion, costo, fec_inscripcion, tipo_pago, act_observaciones, id_tipo_actividad, id_aux_administrativo, id_espacio, act_estado) FROM stdin;
\.


--
-- TOC entry 5029 (class 0 OID 22164)
-- Dependencies: 218
-- Data for Name: aud_usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.aud_usuarios (id_aud_usuario, fecha_hora, operacion, terminal, id_usuario, tabla_afectada) FROM stdin;
\.


--
-- TOC entry 5031 (class 0 OID 22168)
-- Dependencies: 220
-- Data for Name: aux_administrativos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.aux_administrativos (id_aux_administrativo, id_usuario) FROM stdin;
1	1
\.


--
-- TOC entry 5033 (class 0 OID 22172)
-- Dependencies: 222
-- Data for Name: ciudad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ciudad (id_ciudad, nom_ciudad, id_departamento) FROM stdin;
1	Artigas	1
2	Canelones	2
3	Ciudad de la Costa	2
4	Las Piedras	2
5	Pando	2
6	Barros Blancos	2
7	Progreso	2
8	Melo	3
9	Río Branco	3
10	Colonia del Sacramento	4
11	Carmelo	4
12	Nueva Helvecia	4
13	Juan Lacaze	4
14	Rosario	4
15	Nueva Palmira	4
16	Durazno	5
17	Trinidad	6
18	Florida	7
19	Minas	8
20	Maldonado	9
21	San Carlos	9
22	Punta del Este	9
23	Piriápolis	9
24	Pan de Azúcar	9
25	Aiguá	9
26	Montevideo	10
27	Paysandú	11
28	Fray Bentos	12
29	Rivera	13
30	Rocha	14
31	Salto	15
32	San José de Mayo	16
33	Ciudad del Plata	16
34	Libertad	16
35	Mercedes	17
36	Dolores	17
37	Tacuarembó	18
38	Paso de los Toros	18
39	Treinta y Tres	19
\.


--
-- TOC entry 5035 (class 0 OID 22176)
-- Dependencies: 224
-- Data for Name: departamentos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departamentos (id_departamento, nom_departamento, id_pais) FROM stdin;
1	Artigas	229
2	Canelones	229
3	Cerro Largo	229
4	Colonia	229
5	Durazno	229
6	Flores	229
7	Florida	229
8	Lavalleja	229
9	Maldonado	229
10	Montevideo	229
11	Paysandú	229
12	Río Negro	229
13	Rivera	229
14	Rocha	229
15	Salto	229
16	San José	229
17	Soriano	229
18	Tacuarembó	229
19	Treinta y Tres	229
\.


--
-- TOC entry 5037 (class 0 OID 22180)
-- Dependencies: 226
-- Data for Name: espacios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.espacios (id_espacio, nom_espacio, capacidad, precio_socio, precio_no_socio, vig_precio, esp_observacion, esp_estado) FROM stdin;
\.


--
-- TOC entry 5039 (class 0 OID 22184)
-- Dependencies: 228
-- Data for Name: funcionalidades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.funcionalidades (id_funcionalidad, nom_funcionalidad, des_funcionalidad, fun_estado) FROM stdin;
\.


--
-- TOC entry 5041 (class 0 OID 22188)
-- Dependencies: 230
-- Data for Name: inscripcion_actividades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inscripcion_actividades (id_usuario, id_actividad, fec_inscripcion, ins_cancelada) FROM stdin;
\.


--
-- TOC entry 5042 (class 0 OID 22193)
-- Dependencies: 231
-- Data for Name: pago; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pago (id_pago, fecha_cobro, monto, forma_cobro, id_actividad, id_reserva, id_usuario, cuota) FROM stdin;
\.


--
-- TOC entry 5044 (class 0 OID 22198)
-- Dependencies: 233
-- Data for Name: paises; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.paises (id_pais, nom_pais) FROM stdin;
1	Afganistán
2	Islas Gland
3	Albania
4	Alemania
5	Andorra
6	Angola
7	Anguilla
8	Antártida
9	Antigua y Barbuda
10	Antillas Holandesas
11	Arabia Saudí
12	Argelia
13	Argentina
14	Armenia
15	Aruba
16	Australia
17	Austria
18	Azerbaiyán
19	Bahamas
20	Bahréin
21	Bangladesh
22	Barbados
23	Bielorrusia
24	Bélgica
25	Belice
26	Benin
27	Bermudas
28	Bhután
29	Bolivia
30	Bosnia y Herzegovina
31	Botsuana
32	Isla Bouvet
33	Brasil
34	Brunéi
35	Bulgaria
36	Burkina Faso
37	Burundi
38	Cabo Verde
39	Islas Caimán
40	Camboya
41	Camerún
42	Canadá
43	República Centroafricana
44	Chad
45	República Checa
46	Chile
47	China
48	Chipre
49	Isla de Navidad
50	Ciudad del Vaticano
51	Islas Cocos
52	Colombia
53	Comoras
54	República Democrática del Congo
55	Congo
56	Islas Cook
57	Corea del Norte
58	Corea del Sur
59	Costa de Marfil
60	Costa Rica
61	Croacia
62	Cuba
63	Dinamarca
64	Dominica
65	República Dominicana
66	Ecuador
67	Egipto
68	El Salvador
69	Emiratos Árabes Unidos
70	Eritrea
71	Eslovaquia
72	Eslovenia
73	España
74	Islas ultramarinas de Estados Unidos
75	Estados Unidos
76	Estonia
77	Etiopía
78	Islas Feroe
79	Filipinas
80	Finlandia
81	Fiyi
82	Francia
83	Gabón
84	Gambia
85	Georgia
86	Islas Georgias del Sur y Sandwich del Sur
87	Ghana
88	Gibraltar
89	Granada
90	Grecia
91	Groenlandia
92	Guadalupe
93	Guam
94	Guatemala
95	Guayana Francesa
96	Guinea
97	Guinea Ecuatorial
98	Guinea-Bissau
99	Guyana
100	Haití
101	Islas Heard y McDonald
102	Honduras
103	Hong Kong
104	Hungría
105	India
106	Indonesia
107	Irán
108	Iraq
109	Irlanda
110	Islandia
111	Israel
112	Italia
113	Jamaica
114	Japón
115	Jordania
116	Kazajstán
117	Kenia
118	Kirguistán
119	Kiribati
120	Kuwait
121	Laos
122	Lesotho
123	Letonia
124	Líbano
125	Liberia
126	Libia
127	Liechtenstein
128	Lituania
129	Luxemburgo
130	Macao
131	ARY Macedonia
132	Madagascar
133	Malasia
134	Malawi
135	Maldivas
136	Malí
137	Malta
138	Islas Malvinas
139	Islas Marianas del Norte
140	Marruecos
141	Islas Marshall
142	Martinica
143	Mauricio
144	Mauritania
145	Mayotte
146	México
147	Micronesia
148	Moldavia
149	Mónaco
150	Mongolia
151	Montserrat
152	Mozambique
153	Myanmar
154	Namibia
155	Nauru
156	Nepal
157	Nicaragua
158	Níger
159	Nigeria
160	Niue
161	Isla Norfolk
162	Noruega
163	Nueva Caledonia
164	Nueva Zelanda
165	Omán
166	Países Bajos
167	Pakistán
168	Palau
169	Palestina
170	Panamá
171	Papúa Nueva Guinea
172	Paraguay
173	Perú
174	Islas Pitcairn
175	Polinesia Francesa
176	Polonia
177	Portugal
178	Puerto Rico
179	Qatar
180	Reino Unido
181	Reunión
182	Ruanda
183	Rumania
184	Rusia
185	Sahara Occidental
186	Islas Salomón
187	Samoa
188	Samoa Americana
189	San Cristóbal y Nevis
190	San Marino
191	San Pedro y Miquelón
192	San Vicente y las Granadinas
193	Santa Helena
194	Santa Lucía
195	Santo Tomé y Príncipe
196	Senegal
197	Serbia y Montenegro
198	Seychelles
199	Sierra Leona
200	Singapur
201	Siria
202	Somalia
203	Sri Lanka
204	Suazilandia
205	Sudáfrica
206	Sudán
207	Suecia
208	Suiza
209	Surinam
210	Svalbard y Jan Mayen
211	Tailandia
212	Taiwán
213	Tanzania
214	Tayikistán
215	Territorio Británico del Océano Índico
216	Territorios Australes Franceses
217	Timor Oriental
218	Togo
219	Tokelau
220	Tonga
221	Trinidad y Tobago
222	Túnez
223	Islas Turcas y Caicos
224	Turkmenistán
225	Turquía
226	Tuvalu
227	Ucrania
228	Uganda
229	Uruguay
230	Uzbekistán
231	Vanuatu
232	Venezuela
233	Vietnam
234	Islas Vírgenes Británicas
235	Islas Vírgenes de los Estados Unidos
236	Wallis y Futuna
237	Yemen
238	Yibuti
239	Zambia
240	Zimbabue
\.


--
-- TOC entry 5046 (class 0 OID 22202)
-- Dependencies: 235
-- Data for Name: password_reset_token; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_token (token, user_id, expiration, used) FROM stdin;
\.


--
-- TOC entry 5047 (class 0 OID 22206)
-- Dependencies: 236
-- Data for Name: perfiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.perfiles (id_perfil, nom_perfil, des_perfil, per_estado) FROM stdin;
\.


--
-- TOC entry 5049 (class 0 OID 22210)
-- Dependencies: 238
-- Data for Name: reserva_espacios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reserva_espacios (id_reserva, fec_reserva_actividad, hora_reserva_actividad, duracion, cantidad_personas, fec_pago_senia, imp_pagado, imp_a_pagar, fec_conf_reserva, hora_conf_reserva, res_cancelada, id_usuario, id_espacio) FROM stdin;
\.


--
-- TOC entry 5051 (class 0 OID 22219)
-- Dependencies: 240
-- Data for Name: socios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.socios (id_socio, cat_socio, dif_auditiva, len_sena, id_usuario, id_subcomision) FROM stdin;
\.


--
-- TOC entry 5053 (class 0 OID 22223)
-- Dependencies: 242
-- Data for Name: subcomisiones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subcomisiones (id_subcomision, nom_subcomision, des_subcomision) FROM stdin;
\.


--
-- TOC entry 5055 (class 0 OID 22227)
-- Dependencies: 244
-- Data for Name: telefonos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.telefonos (id_usuario, nro_telefono, tipo_telefono) FROM stdin;
\.


--
-- TOC entry 5056 (class 0 OID 22230)
-- Dependencies: 245
-- Data for Name: tipo_actividades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tipo_actividades (id_tipo_actividad, tipo_act_nombre, tipo_act_descripcion, fec_baja, raz_baja, comentario, tipo_act_estado) FROM stdin;
\.


--
-- TOC entry 5058 (class 0 OID 22234)
-- Dependencies: 247
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (id_usuario, nro_documento, pri_nombre, seg_nombre, pri_apellido, seg_apellido, tipo_doc, fec_nacimiento, tipo_usuario, correo, contrasena_hash, usu_estado, calle, nro_puerta, cod_postal, id_perfil, id_ciudad, id_pais, id_departamento) FROM stdin;
1	12345678	Admin	Admin	Admin	Admin	CI	1999-01-01	ADMIN	admin@admin.com	$2a$10$7lH/plxWmmKzCBDUhbN1Du35hwfBxHZl0xRsoaDYXG1z55iM/f/2G	t	18 de julio	1234	12345	\N	28	229	12
\.


--
-- TOC entry 5080 (class 0 OID 0)
-- Dependencies: 217
-- Name: actividades_id_actividad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.actividades_id_actividad_seq', 1, false);


--
-- TOC entry 5081 (class 0 OID 0)
-- Dependencies: 219
-- Name: aud_usuarios_id_aud_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.aud_usuarios_id_aud_usuario_seq', 1, false);


--
-- TOC entry 5082 (class 0 OID 0)
-- Dependencies: 221
-- Name: aux_administrativos_id_aux_administrativo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.aux_administrativos_id_aux_administrativo_seq', 1, false);


--
-- TOC entry 5083 (class 0 OID 0)
-- Dependencies: 223
-- Name: ciudad_id_ciudad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ciudad_id_ciudad_seq', 1, false);


--
-- TOC entry 5084 (class 0 OID 0)
-- Dependencies: 225
-- Name: departamentos_id_departamento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.departamentos_id_departamento_seq', 1, false);


--
-- TOC entry 5085 (class 0 OID 0)
-- Dependencies: 227
-- Name: espacios_id_espacio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.espacios_id_espacio_seq', 1, false);


--
-- TOC entry 5086 (class 0 OID 0)
-- Dependencies: 229
-- Name: funcionalidades_id_funcionalidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.funcionalidades_id_funcionalidad_seq', 1, false);


--
-- TOC entry 5087 (class 0 OID 0)
-- Dependencies: 232
-- Name: pago_id_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pago_id_pago_seq', 1, false);


--
-- TOC entry 5088 (class 0 OID 0)
-- Dependencies: 234
-- Name: paises_id_pais_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.paises_id_pais_seq', 1, false);


--
-- TOC entry 5089 (class 0 OID 0)
-- Dependencies: 237
-- Name: perfiles_id_perfil_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.perfiles_id_perfil_seq', 1, false);


--
-- TOC entry 5090 (class 0 OID 0)
-- Dependencies: 239
-- Name: reserva_espacios_id_reserva_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reserva_espacios_id_reserva_seq', 1, false);


--
-- TOC entry 5091 (class 0 OID 0)
-- Dependencies: 241
-- Name: socios_id_socio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.socios_id_socio_seq', 1, false);


--
-- TOC entry 5092 (class 0 OID 0)
-- Dependencies: 243
-- Name: subcomisiones_id_subcomision_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.subcomisiones_id_subcomision_seq', 1, false);


--
-- TOC entry 5093 (class 0 OID 0)
-- Dependencies: 246
-- Name: tipo_actividades_id_tipo_actividad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tipo_actividades_id_tipo_actividad_seq', 1, false);


--
-- TOC entry 5094 (class 0 OID 0)
-- Dependencies: 248
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_id_usuario_seq', 1, true);


--
-- TOC entry 4798 (class 2606 OID 22257)
-- Name: acceso_funcionalidades acceso_funcionalidades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.acceso_funcionalidades
    ADD CONSTRAINT acceso_funcionalidades_pkey PRIMARY KEY (id_funcionalidad, id_perfil);


--
-- TOC entry 4800 (class 2606 OID 22259)
-- Name: actividades actividades_actividad_nom_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actividades
    ADD CONSTRAINT actividades_actividad_nom_key UNIQUE (actividad_nom);


--
-- TOC entry 4802 (class 2606 OID 22261)
-- Name: actividades actividades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actividades
    ADD CONSTRAINT actividades_pkey PRIMARY KEY (id_actividad);


--
-- TOC entry 4804 (class 2606 OID 22263)
-- Name: aud_usuarios aud_usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aud_usuarios
    ADD CONSTRAINT aud_usuarios_pkey PRIMARY KEY (id_aud_usuario);


--
-- TOC entry 4806 (class 2606 OID 22265)
-- Name: aux_administrativos aux_administrativos_id_usuario_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aux_administrativos
    ADD CONSTRAINT aux_administrativos_id_usuario_key UNIQUE (id_usuario);


--
-- TOC entry 4808 (class 2606 OID 22267)
-- Name: aux_administrativos aux_administrativos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aux_administrativos
    ADD CONSTRAINT aux_administrativos_pkey PRIMARY KEY (id_aux_administrativo);


--
-- TOC entry 4810 (class 2606 OID 22269)
-- Name: ciudad ciudad_nom_ciudad_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudad
    ADD CONSTRAINT ciudad_nom_ciudad_key UNIQUE (nom_ciudad);


--
-- TOC entry 4812 (class 2606 OID 22271)
-- Name: ciudad ciudad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudad
    ADD CONSTRAINT ciudad_pkey PRIMARY KEY (id_ciudad);


--
-- TOC entry 4814 (class 2606 OID 22273)
-- Name: departamentos departamentos_nom_departamento_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_nom_departamento_key UNIQUE (nom_departamento);


--
-- TOC entry 4816 (class 2606 OID 22275)
-- Name: departamentos departamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_pkey PRIMARY KEY (id_departamento);


--
-- TOC entry 4818 (class 2606 OID 22277)
-- Name: espacios espacios_nom_espacio_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.espacios
    ADD CONSTRAINT espacios_nom_espacio_key UNIQUE (nom_espacio);


--
-- TOC entry 4820 (class 2606 OID 22279)
-- Name: espacios espacios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.espacios
    ADD CONSTRAINT espacios_pkey PRIMARY KEY (id_espacio);


--
-- TOC entry 4822 (class 2606 OID 22281)
-- Name: funcionalidades funcionalidades_nom_funcionalidad_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionalidades
    ADD CONSTRAINT funcionalidades_nom_funcionalidad_key UNIQUE (nom_funcionalidad);


--
-- TOC entry 4824 (class 2606 OID 22283)
-- Name: funcionalidades funcionalidades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionalidades
    ADD CONSTRAINT funcionalidades_pkey PRIMARY KEY (id_funcionalidad);


--
-- TOC entry 4826 (class 2606 OID 22285)
-- Name: inscripcion_actividades inscripcion_actividades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inscripcion_actividades
    ADD CONSTRAINT inscripcion_actividades_pkey PRIMARY KEY (id_usuario, id_actividad);


--
-- TOC entry 4828 (class 2606 OID 22287)
-- Name: pago pago_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_pkey PRIMARY KEY (id_pago);


--
-- TOC entry 4830 (class 2606 OID 22289)
-- Name: paises paises_nom_pais_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paises
    ADD CONSTRAINT paises_nom_pais_key UNIQUE (nom_pais);


--
-- TOC entry 4832 (class 2606 OID 22291)
-- Name: paises paises_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paises
    ADD CONSTRAINT paises_pkey PRIMARY KEY (id_pais);


--
-- TOC entry 4834 (class 2606 OID 22293)
-- Name: password_reset_token password_reset_token_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_token
    ADD CONSTRAINT password_reset_token_pkey PRIMARY KEY (token);


--
-- TOC entry 4836 (class 2606 OID 22295)
-- Name: perfiles perfiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfiles
    ADD CONSTRAINT perfiles_pkey PRIMARY KEY (id_perfil);


--
-- TOC entry 4838 (class 2606 OID 22297)
-- Name: reserva_espacios reserva_espacios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reserva_espacios
    ADD CONSTRAINT reserva_espacios_pkey PRIMARY KEY (id_reserva);


--
-- TOC entry 4840 (class 2606 OID 22299)
-- Name: socios socios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socios
    ADD CONSTRAINT socios_pkey PRIMARY KEY (id_socio);


--
-- TOC entry 4842 (class 2606 OID 22301)
-- Name: subcomisiones subcomisiones_nom_subcomision_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subcomisiones
    ADD CONSTRAINT subcomisiones_nom_subcomision_key UNIQUE (nom_subcomision);


--
-- TOC entry 4844 (class 2606 OID 22303)
-- Name: subcomisiones subcomisiones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subcomisiones
    ADD CONSTRAINT subcomisiones_pkey PRIMARY KEY (id_subcomision);


--
-- TOC entry 4846 (class 2606 OID 22305)
-- Name: telefonos telefonos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telefonos
    ADD CONSTRAINT telefonos_pkey PRIMARY KEY (id_usuario, nro_telefono, tipo_telefono);


--
-- TOC entry 4848 (class 2606 OID 22307)
-- Name: tipo_actividades tipo_actividades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_actividades
    ADD CONSTRAINT tipo_actividades_pkey PRIMARY KEY (id_tipo_actividad);


--
-- TOC entry 4850 (class 2606 OID 22309)
-- Name: tipo_actividades tipo_actividades_tipo_act_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_actividades
    ADD CONSTRAINT tipo_actividades_tipo_act_nombre_key UNIQUE (tipo_act_nombre);


--
-- TOC entry 4852 (class 2606 OID 22311)
-- Name: usuarios usuarios_correo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_correo_key UNIQUE (correo);


--
-- TOC entry 4854 (class 2606 OID 22313)
-- Name: usuarios usuarios_nro_documento_tipo_doc_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_nro_documento_tipo_doc_key UNIQUE (nro_documento, tipo_doc);


--
-- TOC entry 4856 (class 2606 OID 22315)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 4857 (class 2606 OID 22316)
-- Name: acceso_funcionalidades acceso_funcionalidades_id_funcionalidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.acceso_funcionalidades
    ADD CONSTRAINT acceso_funcionalidades_id_funcionalidad_fkey FOREIGN KEY (id_funcionalidad) REFERENCES public.funcionalidades(id_funcionalidad);


--
-- TOC entry 4858 (class 2606 OID 22321)
-- Name: acceso_funcionalidades acceso_funcionalidades_id_perfil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.acceso_funcionalidades
    ADD CONSTRAINT acceso_funcionalidades_id_perfil_fkey FOREIGN KEY (id_perfil) REFERENCES public.perfiles(id_perfil);


--
-- TOC entry 4859 (class 2606 OID 22326)
-- Name: actividades actividades_id_aux_administrativo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actividades
    ADD CONSTRAINT actividades_id_aux_administrativo_fkey FOREIGN KEY (id_aux_administrativo) REFERENCES public.aux_administrativos(id_aux_administrativo);


--
-- TOC entry 4860 (class 2606 OID 22331)
-- Name: actividades actividades_id_espacio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actividades
    ADD CONSTRAINT actividades_id_espacio_fkey FOREIGN KEY (id_espacio) REFERENCES public.espacios(id_espacio);


--
-- TOC entry 4861 (class 2606 OID 22336)
-- Name: actividades actividades_id_tipo_actividad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actividades
    ADD CONSTRAINT actividades_id_tipo_actividad_fkey FOREIGN KEY (id_tipo_actividad) REFERENCES public.tipo_actividades(id_tipo_actividad);


--
-- TOC entry 4862 (class 2606 OID 22341)
-- Name: aud_usuarios aud_usuarios_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aud_usuarios
    ADD CONSTRAINT aud_usuarios_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario);


--
-- TOC entry 4863 (class 2606 OID 22346)
-- Name: aux_administrativos aux_administrativos_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aux_administrativos
    ADD CONSTRAINT aux_administrativos_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario);


--
-- TOC entry 4864 (class 2606 OID 22351)
-- Name: ciudad ciudad_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudad
    ADD CONSTRAINT ciudad_id_departamento_fkey FOREIGN KEY (id_departamento) REFERENCES public.departamentos(id_departamento);


--
-- TOC entry 4865 (class 2606 OID 22356)
-- Name: departamentos departamentos_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.paises(id_pais);


--
-- TOC entry 4868 (class 2606 OID 22361)
-- Name: pago id_actividad_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT id_actividad_fk FOREIGN KEY (id_actividad) REFERENCES public.actividades(id_actividad);


--
-- TOC entry 4879 (class 2606 OID 22366)
-- Name: usuarios id_ciudad_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT id_ciudad_fk FOREIGN KEY (id_ciudad) REFERENCES public.ciudad(id_ciudad);


--
-- TOC entry 4880 (class 2606 OID 22371)
-- Name: usuarios id_departamento_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT id_departamento_fk FOREIGN KEY (id_departamento) REFERENCES public.departamentos(id_departamento);


--
-- TOC entry 4881 (class 2606 OID 22376)
-- Name: usuarios id_pais_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT id_pais_fk FOREIGN KEY (id_pais) REFERENCES public.paises(id_pais);


--
-- TOC entry 4869 (class 2606 OID 22381)
-- Name: pago id_reserva_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT id_reserva_fk FOREIGN KEY (id_reserva) REFERENCES public.reserva_espacios(id_reserva);


--
-- TOC entry 4866 (class 2606 OID 22386)
-- Name: inscripcion_actividades inscripcion_actividades_id_actividad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inscripcion_actividades
    ADD CONSTRAINT inscripcion_actividades_id_actividad_fkey FOREIGN KEY (id_actividad) REFERENCES public.actividades(id_actividad);


--
-- TOC entry 4867 (class 2606 OID 22391)
-- Name: inscripcion_actividades inscripcion_actividades_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inscripcion_actividades
    ADD CONSTRAINT inscripcion_actividades_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario);


--
-- TOC entry 4870 (class 2606 OID 22396)
-- Name: pago pago_id_actividad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_id_actividad_fkey FOREIGN KEY (id_actividad) REFERENCES public.actividades(id_actividad);


--
-- TOC entry 4871 (class 2606 OID 22401)
-- Name: pago pago_id_reserva_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_id_reserva_fkey FOREIGN KEY (id_reserva) REFERENCES public.reserva_espacios(id_reserva);


--
-- TOC entry 4872 (class 2606 OID 22406)
-- Name: pago pago_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario);


--
-- TOC entry 4873 (class 2606 OID 22411)
-- Name: password_reset_token password_reset_token_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_token
    ADD CONSTRAINT password_reset_token_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.usuarios(id_usuario);


--
-- TOC entry 4874 (class 2606 OID 22416)
-- Name: reserva_espacios reserva_espacios_id_espacio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reserva_espacios
    ADD CONSTRAINT reserva_espacios_id_espacio_fkey FOREIGN KEY (id_espacio) REFERENCES public.espacios(id_espacio);


--
-- TOC entry 4875 (class 2606 OID 22421)
-- Name: reserva_espacios reserva_espacios_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reserva_espacios
    ADD CONSTRAINT reserva_espacios_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario);


--
-- TOC entry 4876 (class 2606 OID 22426)
-- Name: socios socios_id_subcomision_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socios
    ADD CONSTRAINT socios_id_subcomision_fkey FOREIGN KEY (id_subcomision) REFERENCES public.subcomisiones(id_subcomision);


--
-- TOC entry 4877 (class 2606 OID 22431)
-- Name: socios socios_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socios
    ADD CONSTRAINT socios_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario);


--
-- TOC entry 4878 (class 2606 OID 22436)
-- Name: telefonos telefonos_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telefonos
    ADD CONSTRAINT telefonos_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario);


--
-- TOC entry 4882 (class 2606 OID 22441)
-- Name: usuarios usuarios_id_perfil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_id_perfil_fkey FOREIGN KEY (id_perfil) REFERENCES public.perfiles(id_perfil);


-- Completed on 2025-09-14 16:32:47

--
-- PostgreSQL database dump complete
--

