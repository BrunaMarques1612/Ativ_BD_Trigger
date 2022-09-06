CREATE TABLE pacientes(
id_pacientes int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
nome_paciente varchar(40) not null,
sexo varchar(1),
obito boolean,
insertDate TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE profissionais(
id_profissionais int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
nome_profissionais varchar(50),
insertDate TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE especialidades(
id_especialidade int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
nome_especialidades varchar(50),
insertDate TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE consultas(
id_consultas int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,       
especialidade_id integer, 
pacientes_id integer,
profissionais_id integer,
insertDate TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE obitos(
id_obitos serial PRIMARY KEY,
obs text
);


ALTER TABLE consultas
ADD CONSTRAINT FkEspecialidadeDaConsulta FOREIGN KEY
    (especialidade_id)
REFERENCES
    especialidades(id);

ALTER TABLE consultas
ADD CONSTRAINT FkProfissionalDaConsulta FOREIGN KEY   
    (profissionais_id)
REFERENCES
    profissionais(id);


insert into pacientes (nome_paciente, sexo)
values ('Luiz','m'), ('Gabriela','f'), ('Erica','f');

insert into profissionais(nomeProfissionais)
values ('Karla'), ('Erick'), ('Heitor');

insert into especialidades (especialidade)
values ('Clinica geral'), ('Urologista'), ('Cardiologista');

insert into consultas (id_especialidades, id_pacientes, id_profissionais)
values (2,1,1), (1,2,2), (3,3,3);


DROP TABLE consultas;

select * from pacientes;
select * from profissionais;
select * from especialidades;
select * from consultas;


ALTER TABLE consultas ADD COLUMN last_user_updated varchar(100);
ALTER TABLE consultas ADD COLUMN last_time_updated timestamp;


select c.id_consultas, pac.nome_Paciente, p.nome_Profissionais, e.especialidade, c.insertDate
	from consultas as c
	inner join pacientes as pac on pac.id_pacientes = c.id_pacientes
	inner join especialidades as e on e.id_especialidades = c.id_especialidades
	inner join profissionais as p on p.id_profissionais = c.id_profissionais


CREATE OR REPLACE FUNCTION trgValidaDadosConsulta()  
RETURNS trigger AS $trgValidarDadosConsulta$


DECLARE
 pacientes_row record;
 especialidades_row record;


BEGIN
        IF NEW.especialidade_id IS NULL THEN
            RAISE EXCEPTION 'especialidade_id nao informada (Consulta precisa de uma especialidade)';
        END IF;
        
        IF NEW.pacientes_id IS NULL THEN
            RAISE EXCEPTION 'Consulta precisa de um paciente';
        END IF;

        IF NEW.profissionais_id IS NULL THEN
            RAISE EXCEPTION 'Indicar profissional';
        END IF;

        SELECT INTO pacientes_row
        *  FROM pacientes as p where p.id = NEW.pacientes_id;

        SELECT INTO especialidades_row
        *  FROM especialidades as esp where especialidades.id = NEW.especialidade_id;

        IF pacientes_row.sexo = 'm' AND especialidades_row.nome = 'ginecologista' THEN
           RAISE EXCEPTION 'Ginecologista apenas para pacientes do sexo feminino';
        ELSEIF pacientes_row.sexo = 'f' AND especialidades_row.nome = 'urologista' THEN
           RAISE EXCEPTION 'Urologista apenas para pacientes do sexo masculino';
        END IF;        
        
        NEW.last_time_updated := current_timestamp;
        NEW.last_user_updated := 'nomeDoUsuario';
        RETURN NEW;
END;


$trgValidaDadosConsulta$ LANGUAGE plpgsql; 


CREATE TRIGGER ValidarDadosConsulta
BEFORE INSERT OR UPDATE ON consultas
FOR EACH ROW
EXECUTE PROCEDURE trgValidaDadosConsulta();
