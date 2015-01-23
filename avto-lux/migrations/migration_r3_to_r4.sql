CREATE TABLE avtolux_non_relation_data (
	name character varying(1024),
	code character varying(1024),
	sort integer,
	data_json json,
	id integer NOT NULL
);

CREATE SEQUENCE avtolux_non_relation_data_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;

ALTER SEQUENCE avtolux_non_relation_data_id_seq
	OWNED BY avtolux_non_relation_data.id;

ALTER TABLE ONLY avtolux_non_relation_data
	ALTER COLUMN id
	SET DEFAULT nextval('avtolux_non_relation_data_id_seq'::regclass);

ALTER TABLE ONLY avtolux_non_relation_data
	ADD CONSTRAINT avtolux_non_relation_data_code_key UNIQUE (code);

ALTER TABLE ONLY avtolux_non_relation_data
	ADD CONSTRAINT avtolux_non_relation_data_pkey PRIMARY KEY (id);
