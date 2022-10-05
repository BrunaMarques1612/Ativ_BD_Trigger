-- Database: bancoHospital

--DROP DATABASE IF EXISTS "bancoHospital";

CREATE DATABASE "bancoHospital"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Portuguese_Brazil.1252'
    LC_CTYPE = 'Portuguese_Brazil.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
	

CREATE TABLE pacientes(
	id_pacientes int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,    
	nomePaciente varchar(100) not null,
	sexo varchar (1),
	obito BIT
);

CREATE TABLE profissionais(
	id_profissionais int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	nomeProfissionais varchar(100),
	insertDate TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE especialidades(
	id_especialidades int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	especialidade varchar(100),
	insertDate TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE consultas (
	id_consultas int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_especialidades int,
	id_pacientes int,
	id_profissionais int,
	insertDate TIMESTAMP NOT NULL DEFAULT NOW()
);

DROP TABLE consultas;
DROP TABLE pacientes;
DROP TABLE profissionais;
DROP TABLE especialidades;


ALTER TABLE consultas
ADD CONSTRAINT FKEspecialidadeDaConsulta FOREIGN KEY    
	(id_especialidades)
REFERENCES    
	especialidades (id_especialidades);

ALTER TABLE consultas ADD COLUMN last_user_updated varchar(100);
ALTER TABLE consultas ADD COLUMN last_time_updated TIMESTAMP;

ALTER TABLE consultas
ADD CONSTRAINT FKProfissionalDaConsulta FOREIGN KEY
	(id_profissionais)
REFERENCES 
	profissionais(id_profissionais);


insert into pacientes (nomePaciente, sexo)
values ('Flora','f'), ('Steve','m'), ('Taina','f');

insert into profissionais(nomeProfissionais)
values ('Karla'), ('Erick'), ('Heitor');

insert into especialidades (especialidade)
values ('Ginecologista'), ('Urologista'), ('Cardiologista');

insert into consultas (id_pacientes, id_profissionais, id_especialidades)
values (1,1,1), (2,2,2), (3,3,3);

insert into consultas (id_pacientes, id_profissionais, id_especialidades)
values (2,2,2);

insert into consultas (id_pacientes, id_profissionais, id_especialidades)
values (1,1,1), (3,1,1);

insert into consultas (id_pacientes, id_profissionais, id_especialidades)
values (1,3,3), (2,3,3), (3,3,3);

--null para profissional
insert into consultas (id_especialidades, id_pacientes)
values (3,3);

--null para especialidade
insert into consultas (id_pacientes, id_profissionais)
values (2,2);

-- null pra paciente
insert into consultas (id_especialidades, id_profissionais)
values (1,1);


select * from pacientes;
select * from profissionais;
select * from especialidades;
select * from consultas;


select c.id_consultas, pac.nomePaciente, p.nomeProfissionais, e.especialidade, c.insertDate, c.last_user_updated,c.last_time_updated
	from consultas as c
	inner join pacientes as pac on pac.id_pacientes = c.id_pacientes
	inner join especialidades as e on e.id_especialidades = c.id_especialidades
	inner join profissionais as p on p.id_profissionais = c.id_profissionais
	
	
CREATE TRIGGER ValidaDadosConsulta
	AFTER INSERT OR UPDATE ON consultas
	FOR EACH ROW
	EXECUTE PROCEDURE ValidaDadosConsulta();
	
CREATE TRiGGER verifynull
	AFTER INSERT OR UPDATE ON consultas
	FOR EACH ROW
	EXECUTE PROCEDURE verifynull();
	
CREATE OR REPLACE FUNCTION ValidaDadosConsulta()
	RETURNS TRIGGER AS $$
	DECLARE
	paciente_row	RECORD;
	especialidade_row RECORD;
	BEGIN
        SELECT INTO paciente_row
        *  FROM pacientes as p 
		where id_pacientes = NEW.id_pacientes;

        SELECT INTO especialidade_row
        *  FROM especialidades as e
		where id_especialidades = NEW.id_especialidades;

        IF paciente_row.sexo = 'm'
		AND especialidade_row.especialidade = 'Ginecologista' THEN
           RAISE EXCEPTION 'A especialidade em Ginecologia atende apenas pacientes do sexo feminino';
        ELSEIF paciente_row.sexo = 'f' 
		AND especialidade_row.especialidade = 'Urologista' THEN
           RAISE EXCEPTION 'A especialidade em Urologia atende apenas pacientes do sexo masculino';
        END IF;
    
NEW.last_time_updated := current_timestamp;
NEW.last_user_updated := paciente_row.nomePaciente;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION verifynull()
RETURNS TRIGGER AS $null$
BEGIN
	IF NEW.id_pacientes IS NULL THEN
            RAISE EXCEPTION 'Paciente inválido ou não inserido';
        END IF;
        
        IF NEW.id_especialidades IS NULL THEN
            RAISE EXCEPTION 'Especialidade inválida ou não inserida';
        END IF;

        IF NEW.id_profissionais IS NULL THEN
            RAISE EXCEPTION 'Profissional inválido ou não inserido';
        END IF;

RETURN NEW;
END
$null$ LANGUAGE plpgsql;
