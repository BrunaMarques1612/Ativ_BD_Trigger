CREATE TABLE pacientes(
id serial PRIMARY KEY,
nome varchar(40) not null,
sexo varchar(1),
obito boolean,
insertedAt TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE profissionais(
id serial PRIMARY KEY,
nome varchar(50)
);

CREATE TABLE especialidades(
id serial PRIMARY KEY,
nome varchar(50)
);

CREATE TABLE consultas(
id serial PRIMARY KEY,       
especialidade_id integer, 
pacientes_id integer,
profissionais_id integer
);

CREATE TABLE obitos(
id serial PRIMARY KEY,
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


ALTER TABLE consultas ADD COLUMN last_user_updated varchar(100);
ALTER TABLE consultas ADD COLUMN last_time_updated timestamp;


CREATE OR REPLACE FUNCTION trgValidaDadosConsulta()  RETURNS trigger AS $trgValidarDadosConsulta$


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
