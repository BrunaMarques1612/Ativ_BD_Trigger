CREATE DATABASE bancoHospital;    


CREATE TABLE pacientes(
	id_pacientes int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,    
	nomePaciente varchar(100) not null,
	sexo varchar (1),obito BIT
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


ALTER TABLE consultas
ADD CONSTRAINT FKEspecialidadeDaConsulta FOREIGN KEY    
	(id_especialidades)
REFERENCES    
	especialidades (id_especialidades);


ALTER TABLE consultas

ADD CONSTRAINT FKProfissionalDaConsulta FOREIGN KEY
	(id_profissionais)
REFERENCES 
	profissionais(id_profissionais);


insert into pacientes (nomePaciente, sexo)
values ('Clara','f'), ('Flora','f'), ('Taina','f');

insert into profissionais(nomeProfissionais)
values ('Karla'), ('Erick'), ('Heitor');

insert into especialidades (especialidade)
values ('Clinica geral'), ('Urologista'), ('Cardiologista');

insert into consultas (id_especialidades, id_pacientes, id_profissionais)
values (2,1,1), (1,2,2), (3,3,3);

insert into consultas (id_especialidades, id_pacientes, id_profissionais)
values (2,1,1), (1,2,2), (3,1,3);



DROP TABLE consultas;
DROP TABLE pacientes;
DROP TABLE profissionais;
DROP TABLE especialidades;


select * from pacientes;
select * from profissionais;
select * from especialidades;
select * from consultas;


CREATE TRIGGER ValidaDadosConsulta
AFTER INSERT OR UPDATE ON consultas
FOR EACH ROW
EXECUTE PROCEDURE ValidaDadosConsulta();

    
CREATE OR REPLACE function trgValidaDadosConsulta()
RETURNS trigger AS $trgValidaDadosConsulta$

BEGIN
	raise notice 'Triger Rodando :)!';
RETURN NEW;
END
$trgValidaDadosConsulta$ LANGUAGE plpgsql;


CREATE TRIGGER validaDadosConsulta
after insert or UPDATE on consultas
FOR EACH ROW
EXECUTE PROCEDURE trgValidaDadosConsulta();
