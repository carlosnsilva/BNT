CREATE OR REPLACE FUNCTION insertVeiculo()
RETURNS TRIGGER AS $$
BEGIN
    NEW.renavam := gerar_renavam(NEW.placa);
    RETURN NEW;
END; $$
LANGUAGE plpgsql;

CREATE TRIGGER tgInsertVeiculo
BEFORE INSERT ON veiculo
FOR EACH ROW
EXECUTE PROCEDURE insertVeiculo();


CREATE OR REPLACE FUNCTION insertMulta()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.idInfracao) <= 6
       OR
       (SELECT sum(inf.pontos) FROM multa as mul LEFT JOIN infracao as inf on mul.idInfracao = inf.idInfracao WHERE mul.renavam = NEW.renavam AND mul.dataInfracao <= NEW.dataInfracao AND mul.dataInfracao >= date(NEW.dataInfracao - interval '1 year')) >= 20
    THEN
        UPDATE condutor as cond
        SET situacaoCNH = 'S'
        WHERE cond.idCadastro = NEW.idCondutor;
    END IF;

    RETURN NEW;
END; $$
LANGUAGE plpgsql;

CREATE TRIGGER tgInsertMulta
BEFORE INSERT ON multa
FOR EACH ROW
EXECUTE PROCEDURE insertMulta();

-- Trigger Licenciamento-Veículo

CREATE OR REPLACE FUNCTION Lin_Veiculo()
RETURNS TRIGGER AS $$
BEGIN
    NEW.placa := gerar_licenciamento(OLD.renavam);
    RETURN NEW;
END; $$
LANGUAGE plpgsql;

CREATE TRIGGER tgLin_Vei()
AFTER INSERT ON veiculo
FOR EACH ROW
EXECUTE PROCEDURE Lin_Veiculo();

CREATE OR REPLACE FUNCTION Transf()
RETURNS TRIGGER AS $$
BEGIN 
    NEW.idCadastro, NEW.nome, OLD.renavam, NEW.dataVenda, NEW.dataCompra
END; $$
LANGUAGE plpgsql;

CREATE TRIGGER tg_Transf()
BEFORE INSERT ON transferencia
FOR EACH ROW
EXECUTE PROCEDURE Transf();