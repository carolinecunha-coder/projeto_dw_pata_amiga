-- =====================================================================================
--  ARQUIVO 2:  AS DIMENSOES PRONTAS  +  AS TABELAS DO MODELO
--  Case: Pata Amiga  |  PostgreSQL 16
-- =====================================================================================
--  Rode depois de: 01-carga-staging.sql
--
--  Vem prontas aqui:
--
--  1) dim_tempo e dim_loja, ja carregadas. Voce nao as constroi, apenas as usa.
--
--  2) O CREATE TABLE das outras quatro tabelas (dim_categoria, dim_praca,
--     bridge_loja_praca e fato_pedido), vazias. Voce as preenche nos
--     arquivos 03 e 04.
--
--  dim_tempo   A chave e a propria data em numero: 16/11/2023 vira 20231116.
--              A fato monta essa FK por calculo, sem JOIN.
--
--  dim_loja    Uma linha por loja, mais a linha -1. A coluna chave_loja traz o
--              nome padronizado (caixa alta, sem acento): e por ela que a fato
--              encontra a loja depois de limpar o nome da stg_pedido.
--
--  Toda dimensao tem a linha -1 = "Nao Informado". Nenhuma FK pode ficar nula:
--  quando o dado falta, ela aponta para essa linha.
-- =====================================================================================

DROP TABLE IF EXISTS dim_tempo;
CREATE TABLE dim_tempo (
    sk_tempo      INT PRIMARY KEY,   -- AAAAMMDD: a propria data em numero
    data          DATE,
    ano           INT,
    mes           INT,
    dia           INT,
    ano_mes       VARCHAR(7),
    nome_mes      VARCHAR(15),
    trimestre     INT,
    dia_semana    VARCHAR(15),
    fim_de_semana VARCHAR(3)
);
INSERT INTO dim_tempo VALUES
(-1, NULL, NULL, NULL, NULL, 'N/I', 'Nao Informado', NULL, 'Nao Informado', 'N/I');

INSERT INTO dim_tempo VALUES
(20230901,'2023-09-01',2023,9,1,'2023-09','Setembro',3,'Sexta','Nao'),
(20230902,'2023-09-02',2023,9,2,'2023-09','Setembro',3,'Sabado','Sim'),
(20230903,'2023-09-03',2023,9,3,'2023-09','Setembro',3,'Domingo','Sim'),
(20230904,'2023-09-04',2023,9,4,'2023-09','Setembro',3,'Segunda','Nao'),
(20230905,'2023-09-05',2023,9,5,'2023-09','Setembro',3,'Terca','Nao'),
(20230906,'2023-09-06',2023,9,6,'2023-09','Setembro',3,'Quarta','Nao'),
(20230907,'2023-09-07',2023,9,7,'2023-09','Setembro',3,'Quinta','Nao'),
(20230908,'2023-09-08',2023,9,8,'2023-09','Setembro',3,'Sexta','Nao'),
(20230909,'2023-09-09',2023,9,9,'2023-09','Setembro',3,'Sabado','Sim'),
(20230910,'2023-09-10',2023,9,10,'2023-09','Setembro',3,'Domingo','Sim'),
(20230911,'2023-09-11',2023,9,11,'2023-09','Setembro',3,'Segunda','Nao'),
(20230912,'2023-09-12',2023,9,12,'2023-09','Setembro',3,'Terca','Nao'),
(20230913,'2023-09-13',2023,9,13,'2023-09','Setembro',3,'Quarta','Nao'),
(20230914,'2023-09-14',2023,9,14,'2023-09','Setembro',3,'Quinta','Nao'),
(20230915,'2023-09-15',2023,9,15,'2023-09','Setembro',3,'Sexta','Nao'),
(20230916,'2023-09-16',2023,9,16,'2023-09','Setembro',3,'Sabado','Sim'),
(20230917,'2023-09-17',2023,9,17,'2023-09','Setembro',3,'Domingo','Sim'),
(20230918,'2023-09-18',2023,9,18,'2023-09','Setembro',3,'Segunda','Nao'),
(20230919,'2023-09-19',2023,9,19,'2023-09','Setembro',3,'Terca','Nao'),
(20230920,'2023-09-20',2023,9,20,'2023-09','Setembro',3,'Quarta','Nao'),
(20230921,'2023-09-21',2023,9,21,'2023-09','Setembro',3,'Quinta','Nao'),
(20230922,'2023-09-22',2023,9,22,'2023-09','Setembro',3,'Sexta','Nao'),
(20230923,'2023-09-23',2023,9,23,'2023-09','Setembro',3,'Sabado','Sim'),
(20230924,'2023-09-24',2023,9,24,'2023-09','Setembro',3,'Domingo','Sim'),
(20230925,'2023-09-25',2023,9,25,'2023-09','Setembro',3,'Segunda','Nao'),
(20230926,'2023-09-26',2023,9,26,'2023-09','Setembro',3,'Terca','Nao'),
(20230927,'2023-09-27',2023,9,27,'2023-09','Setembro',3,'Quarta','Nao'),
(20230928,'2023-09-28',2023,9,28,'2023-09','Setembro',3,'Quinta','Nao'),
(20230929,'2023-09-29',2023,9,29,'2023-09','Setembro',3,'Sexta','Nao'),
(20230930,'2023-09-30',2023,9,30,'2023-09','Setembro',3,'Sabado','Sim'),
(20231001,'2023-10-01',2023,10,1,'2023-10','Outubro',4,'Domingo','Sim'),
(20231002,'2023-10-02',2023,10,2,'2023-10','Outubro',4,'Segunda','Nao'),
(20231003,'2023-10-03',2023,10,3,'2023-10','Outubro',4,'Terca','Nao'),
(20231004,'2023-10-04',2023,10,4,'2023-10','Outubro',4,'Quarta','Nao'),
(20231005,'2023-10-05',2023,10,5,'2023-10','Outubro',4,'Quinta','Nao'),
(20231006,'2023-10-06',2023,10,6,'2023-10','Outubro',4,'Sexta','Nao'),
(20231007,'2023-10-07',2023,10,7,'2023-10','Outubro',4,'Sabado','Sim'),
(20231008,'2023-10-08',2023,10,8,'2023-10','Outubro',4,'Domingo','Sim'),
(20231009,'2023-10-09',2023,10,9,'2023-10','Outubro',4,'Segunda','Nao'),
(20231010,'2023-10-10',2023,10,10,'2023-10','Outubro',4,'Terca','Nao'),
(20231011,'2023-10-11',2023,10,11,'2023-10','Outubro',4,'Quarta','Nao'),
(20231012,'2023-10-12',2023,10,12,'2023-10','Outubro',4,'Quinta','Nao'),
(20231013,'2023-10-13',2023,10,13,'2023-10','Outubro',4,'Sexta','Nao'),
(20231014,'2023-10-14',2023,10,14,'2023-10','Outubro',4,'Sabado','Sim'),
(20231015,'2023-10-15',2023,10,15,'2023-10','Outubro',4,'Domingo','Sim'),
(20231016,'2023-10-16',2023,10,16,'2023-10','Outubro',4,'Segunda','Nao'),
(20231017,'2023-10-17',2023,10,17,'2023-10','Outubro',4,'Terca','Nao'),
(20231018,'2023-10-18',2023,10,18,'2023-10','Outubro',4,'Quarta','Nao'),
(20231019,'2023-10-19',2023,10,19,'2023-10','Outubro',4,'Quinta','Nao'),
(20231020,'2023-10-20',2023,10,20,'2023-10','Outubro',4,'Sexta','Nao'),
(20231021,'2023-10-21',2023,10,21,'2023-10','Outubro',4,'Sabado','Sim'),
(20231022,'2023-10-22',2023,10,22,'2023-10','Outubro',4,'Domingo','Sim'),
(20231023,'2023-10-23',2023,10,23,'2023-10','Outubro',4,'Segunda','Nao'),
(20231024,'2023-10-24',2023,10,24,'2023-10','Outubro',4,'Terca','Nao'),
(20231025,'2023-10-25',2023,10,25,'2023-10','Outubro',4,'Quarta','Nao'),
(20231026,'2023-10-26',2023,10,26,'2023-10','Outubro',4,'Quinta','Nao'),
(20231027,'2023-10-27',2023,10,27,'2023-10','Outubro',4,'Sexta','Nao'),
(20231028,'2023-10-28',2023,10,28,'2023-10','Outubro',4,'Sabado','Sim'),
(20231029,'2023-10-29',2023,10,29,'2023-10','Outubro',4,'Domingo','Sim'),
(20231030,'2023-10-30',2023,10,30,'2023-10','Outubro',4,'Segunda','Nao'),
(20231031,'2023-10-31',2023,10,31,'2023-10','Outubro',4,'Terca','Nao'),
(20231101,'2023-11-01',2023,11,1,'2023-11','Novembro',4,'Quarta','Nao'),
(20231102,'2023-11-02',2023,11,2,'2023-11','Novembro',4,'Quinta','Nao'),
(20231103,'2023-11-03',2023,11,3,'2023-11','Novembro',4,'Sexta','Nao'),
(20231104,'2023-11-04',2023,11,4,'2023-11','Novembro',4,'Sabado','Sim'),
(20231105,'2023-11-05',2023,11,5,'2023-11','Novembro',4,'Domingo','Sim'),
(20231106,'2023-11-06',2023,11,6,'2023-11','Novembro',4,'Segunda','Nao'),
(20231107,'2023-11-07',2023,11,7,'2023-11','Novembro',4,'Terca','Nao'),
(20231108,'2023-11-08',2023,11,8,'2023-11','Novembro',4,'Quarta','Nao'),
(20231109,'2023-11-09',2023,11,9,'2023-11','Novembro',4,'Quinta','Nao'),
(20231110,'2023-11-10',2023,11,10,'2023-11','Novembro',4,'Sexta','Nao'),
(20231111,'2023-11-11',2023,11,11,'2023-11','Novembro',4,'Sabado','Sim'),
(20231112,'2023-11-12',2023,11,12,'2023-11','Novembro',4,'Domingo','Sim'),
(20231113,'2023-11-13',2023,11,13,'2023-11','Novembro',4,'Segunda','Nao'),
(20231114,'2023-11-14',2023,11,14,'2023-11','Novembro',4,'Terca','Nao'),
(20231115,'2023-11-15',2023,11,15,'2023-11','Novembro',4,'Quarta','Nao'),
(20231116,'2023-11-16',2023,11,16,'2023-11','Novembro',4,'Quinta','Nao'),
(20231117,'2023-11-17',2023,11,17,'2023-11','Novembro',4,'Sexta','Nao'),
(20231118,'2023-11-18',2023,11,18,'2023-11','Novembro',4,'Sabado','Sim'),
(20231119,'2023-11-19',2023,11,19,'2023-11','Novembro',4,'Domingo','Sim'),
(20231120,'2023-11-20',2023,11,20,'2023-11','Novembro',4,'Segunda','Nao'),
(20231121,'2023-11-21',2023,11,21,'2023-11','Novembro',4,'Terca','Nao'),
(20231122,'2023-11-22',2023,11,22,'2023-11','Novembro',4,'Quarta','Nao'),
(20231123,'2023-11-23',2023,11,23,'2023-11','Novembro',4,'Quinta','Nao'),
(20231124,'2023-11-24',2023,11,24,'2023-11','Novembro',4,'Sexta','Nao'),
(20231125,'2023-11-25',2023,11,25,'2023-11','Novembro',4,'Sabado','Sim'),
(20231126,'2023-11-26',2023,11,26,'2023-11','Novembro',4,'Domingo','Sim'),
(20231127,'2023-11-27',2023,11,27,'2023-11','Novembro',4,'Segunda','Nao'),
(20231128,'2023-11-28',2023,11,28,'2023-11','Novembro',4,'Terca','Nao'),
(20231129,'2023-11-29',2023,11,29,'2023-11','Novembro',4,'Quarta','Nao'),
(20231130,'2023-11-30',2023,11,30,'2023-11','Novembro',4,'Quinta','Nao'),
(20231201,'2023-12-01',2023,12,1,'2023-12','Dezembro',4,'Sexta','Nao'),
(20231202,'2023-12-02',2023,12,2,'2023-12','Dezembro',4,'Sabado','Sim'),
(20231203,'2023-12-03',2023,12,3,'2023-12','Dezembro',4,'Domingo','Sim'),
(20231204,'2023-12-04',2023,12,4,'2023-12','Dezembro',4,'Segunda','Nao'),
(20231205,'2023-12-05',2023,12,5,'2023-12','Dezembro',4,'Terca','Nao'),
(20231206,'2023-12-06',2023,12,6,'2023-12','Dezembro',4,'Quarta','Nao'),
(20231207,'2023-12-07',2023,12,7,'2023-12','Dezembro',4,'Quinta','Nao'),
(20231208,'2023-12-08',2023,12,8,'2023-12','Dezembro',4,'Sexta','Nao'),
(20231209,'2023-12-09',2023,12,9,'2023-12','Dezembro',4,'Sabado','Sim');
INSERT INTO dim_tempo VALUES
(20231210,'2023-12-10',2023,12,10,'2023-12','Dezembro',4,'Domingo','Sim'),
(20231211,'2023-12-11',2023,12,11,'2023-12','Dezembro',4,'Segunda','Nao'),
(20231212,'2023-12-12',2023,12,12,'2023-12','Dezembro',4,'Terca','Nao'),
(20231213,'2023-12-13',2023,12,13,'2023-12','Dezembro',4,'Quarta','Nao'),
(20231214,'2023-12-14',2023,12,14,'2023-12','Dezembro',4,'Quinta','Nao'),
(20231215,'2023-12-15',2023,12,15,'2023-12','Dezembro',4,'Sexta','Nao'),
(20231216,'2023-12-16',2023,12,16,'2023-12','Dezembro',4,'Sabado','Sim'),
(20231217,'2023-12-17',2023,12,17,'2023-12','Dezembro',4,'Domingo','Sim'),
(20231218,'2023-12-18',2023,12,18,'2023-12','Dezembro',4,'Segunda','Nao'),
(20231219,'2023-12-19',2023,12,19,'2023-12','Dezembro',4,'Terca','Nao'),
(20231220,'2023-12-20',2023,12,20,'2023-12','Dezembro',4,'Quarta','Nao'),
(20231221,'2023-12-21',2023,12,21,'2023-12','Dezembro',4,'Quinta','Nao'),
(20231222,'2023-12-22',2023,12,22,'2023-12','Dezembro',4,'Sexta','Nao'),
(20231223,'2023-12-23',2023,12,23,'2023-12','Dezembro',4,'Sabado','Sim'),
(20231224,'2023-12-24',2023,12,24,'2023-12','Dezembro',4,'Domingo','Sim'),
(20231225,'2023-12-25',2023,12,25,'2023-12','Dezembro',4,'Segunda','Nao'),
(20231226,'2023-12-26',2023,12,26,'2023-12','Dezembro',4,'Terca','Nao'),
(20231227,'2023-12-27',2023,12,27,'2023-12','Dezembro',4,'Quarta','Nao'),
(20231228,'2023-12-28',2023,12,28,'2023-12','Dezembro',4,'Quinta','Nao'),
(20231229,'2023-12-29',2023,12,29,'2023-12','Dezembro',4,'Sexta','Nao'),
(20231230,'2023-12-30',2023,12,30,'2023-12','Dezembro',4,'Sabado','Sim'),
(20231231,'2023-12-31',2023,12,31,'2023-12','Dezembro',4,'Domingo','Sim'),
(20240101,'2024-01-01',2024,1,1,'2024-01','Janeiro',1,'Segunda','Nao'),
(20240102,'2024-01-02',2024,1,2,'2024-01','Janeiro',1,'Terca','Nao'),
(20240103,'2024-01-03',2024,1,3,'2024-01','Janeiro',1,'Quarta','Nao'),
(20240104,'2024-01-04',2024,1,4,'2024-01','Janeiro',1,'Quinta','Nao'),
(20240105,'2024-01-05',2024,1,5,'2024-01','Janeiro',1,'Sexta','Nao'),
(20240106,'2024-01-06',2024,1,6,'2024-01','Janeiro',1,'Sabado','Sim'),
(20240107,'2024-01-07',2024,1,7,'2024-01','Janeiro',1,'Domingo','Sim'),
(20240108,'2024-01-08',2024,1,8,'2024-01','Janeiro',1,'Segunda','Nao'),
(20240109,'2024-01-09',2024,1,9,'2024-01','Janeiro',1,'Terca','Nao'),
(20240110,'2024-01-10',2024,1,10,'2024-01','Janeiro',1,'Quarta','Nao'),
(20240111,'2024-01-11',2024,1,11,'2024-01','Janeiro',1,'Quinta','Nao'),
(20240112,'2024-01-12',2024,1,12,'2024-01','Janeiro',1,'Sexta','Nao'),
(20240113,'2024-01-13',2024,1,13,'2024-01','Janeiro',1,'Sabado','Sim'),
(20240114,'2024-01-14',2024,1,14,'2024-01','Janeiro',1,'Domingo','Sim'),
(20240115,'2024-01-15',2024,1,15,'2024-01','Janeiro',1,'Segunda','Nao'),
(20240116,'2024-01-16',2024,1,16,'2024-01','Janeiro',1,'Terca','Nao'),
(20240117,'2024-01-17',2024,1,17,'2024-01','Janeiro',1,'Quarta','Nao'),
(20240118,'2024-01-18',2024,1,18,'2024-01','Janeiro',1,'Quinta','Nao'),
(20240119,'2024-01-19',2024,1,19,'2024-01','Janeiro',1,'Sexta','Nao'),
(20240120,'2024-01-20',2024,1,20,'2024-01','Janeiro',1,'Sabado','Sim'),
(20240121,'2024-01-21',2024,1,21,'2024-01','Janeiro',1,'Domingo','Sim'),
(20240122,'2024-01-22',2024,1,22,'2024-01','Janeiro',1,'Segunda','Nao'),
(20240123,'2024-01-23',2024,1,23,'2024-01','Janeiro',1,'Terca','Nao'),
(20240124,'2024-01-24',2024,1,24,'2024-01','Janeiro',1,'Quarta','Nao'),
(20240125,'2024-01-25',2024,1,25,'2024-01','Janeiro',1,'Quinta','Nao'),
(20240126,'2024-01-26',2024,1,26,'2024-01','Janeiro',1,'Sexta','Nao'),
(20240127,'2024-01-27',2024,1,27,'2024-01','Janeiro',1,'Sabado','Sim'),
(20240128,'2024-01-28',2024,1,28,'2024-01','Janeiro',1,'Domingo','Sim'),
(20240129,'2024-01-29',2024,1,29,'2024-01','Janeiro',1,'Segunda','Nao'),
(20240130,'2024-01-30',2024,1,30,'2024-01','Janeiro',1,'Terca','Nao'),
(20240131,'2024-01-31',2024,1,31,'2024-01','Janeiro',1,'Quarta','Nao'),
(20240201,'2024-02-01',2024,2,1,'2024-02','Fevereiro',1,'Quinta','Nao'),
(20240202,'2024-02-02',2024,2,2,'2024-02','Fevereiro',1,'Sexta','Nao'),
(20240203,'2024-02-03',2024,2,3,'2024-02','Fevereiro',1,'Sabado','Sim'),
(20240204,'2024-02-04',2024,2,4,'2024-02','Fevereiro',1,'Domingo','Sim'),
(20240205,'2024-02-05',2024,2,5,'2024-02','Fevereiro',1,'Segunda','Nao'),
(20240206,'2024-02-06',2024,2,6,'2024-02','Fevereiro',1,'Terca','Nao'),
(20240207,'2024-02-07',2024,2,7,'2024-02','Fevereiro',1,'Quarta','Nao'),
(20240208,'2024-02-08',2024,2,8,'2024-02','Fevereiro',1,'Quinta','Nao'),
(20240209,'2024-02-09',2024,2,9,'2024-02','Fevereiro',1,'Sexta','Nao'),
(20240210,'2024-02-10',2024,2,10,'2024-02','Fevereiro',1,'Sabado','Sim'),
(20240211,'2024-02-11',2024,2,11,'2024-02','Fevereiro',1,'Domingo','Sim'),
(20240212,'2024-02-12',2024,2,12,'2024-02','Fevereiro',1,'Segunda','Nao'),
(20240213,'2024-02-13',2024,2,13,'2024-02','Fevereiro',1,'Terca','Nao'),
(20240214,'2024-02-14',2024,2,14,'2024-02','Fevereiro',1,'Quarta','Nao'),
(20240215,'2024-02-15',2024,2,15,'2024-02','Fevereiro',1,'Quinta','Nao'),
(20240216,'2024-02-16',2024,2,16,'2024-02','Fevereiro',1,'Sexta','Nao'),
(20240217,'2024-02-17',2024,2,17,'2024-02','Fevereiro',1,'Sabado','Sim'),
(20240218,'2024-02-18',2024,2,18,'2024-02','Fevereiro',1,'Domingo','Sim'),
(20240219,'2024-02-19',2024,2,19,'2024-02','Fevereiro',1,'Segunda','Nao'),
(20240220,'2024-02-20',2024,2,20,'2024-02','Fevereiro',1,'Terca','Nao'),
(20240221,'2024-02-21',2024,2,21,'2024-02','Fevereiro',1,'Quarta','Nao'),
(20240222,'2024-02-22',2024,2,22,'2024-02','Fevereiro',1,'Quinta','Nao'),
(20240223,'2024-02-23',2024,2,23,'2024-02','Fevereiro',1,'Sexta','Nao'),
(20240224,'2024-02-24',2024,2,24,'2024-02','Fevereiro',1,'Sabado','Sim'),
(20240225,'2024-02-25',2024,2,25,'2024-02','Fevereiro',1,'Domingo','Sim'),
(20240226,'2024-02-26',2024,2,26,'2024-02','Fevereiro',1,'Segunda','Nao'),
(20240227,'2024-02-27',2024,2,27,'2024-02','Fevereiro',1,'Terca','Nao'),
(20240228,'2024-02-28',2024,2,28,'2024-02','Fevereiro',1,'Quarta','Nao'),
(20240229,'2024-02-29',2024,2,29,'2024-02','Fevereiro',1,'Quinta','Nao'),
(20240301,'2024-03-01',2024,3,1,'2024-03','Marco',1,'Sexta','Nao'),
(20240302,'2024-03-02',2024,3,2,'2024-03','Marco',1,'Sabado','Sim'),
(20240303,'2024-03-03',2024,3,3,'2024-03','Marco',1,'Domingo','Sim'),
(20240304,'2024-03-04',2024,3,4,'2024-03','Marco',1,'Segunda','Nao'),
(20240305,'2024-03-05',2024,3,5,'2024-03','Marco',1,'Terca','Nao'),
(20240306,'2024-03-06',2024,3,6,'2024-03','Marco',1,'Quarta','Nao'),
(20240307,'2024-03-07',2024,3,7,'2024-03','Marco',1,'Quinta','Nao'),
(20240308,'2024-03-08',2024,3,8,'2024-03','Marco',1,'Sexta','Nao'),
(20240309,'2024-03-09',2024,3,9,'2024-03','Marco',1,'Sabado','Sim'),
(20240310,'2024-03-10',2024,3,10,'2024-03','Marco',1,'Domingo','Sim'),
(20240311,'2024-03-11',2024,3,11,'2024-03','Marco',1,'Segunda','Nao'),
(20240312,'2024-03-12',2024,3,12,'2024-03','Marco',1,'Terca','Nao'),
(20240313,'2024-03-13',2024,3,13,'2024-03','Marco',1,'Quarta','Nao'),
(20240314,'2024-03-14',2024,3,14,'2024-03','Marco',1,'Quinta','Nao'),
(20240315,'2024-03-15',2024,3,15,'2024-03','Marco',1,'Sexta','Nao'),
(20240316,'2024-03-16',2024,3,16,'2024-03','Marco',1,'Sabado','Sim'),
(20240317,'2024-03-17',2024,3,17,'2024-03','Marco',1,'Domingo','Sim'),
(20240318,'2024-03-18',2024,3,18,'2024-03','Marco',1,'Segunda','Nao');
INSERT INTO dim_tempo VALUES
(20240319,'2024-03-19',2024,3,19,'2024-03','Marco',1,'Terca','Nao'),
(20240320,'2024-03-20',2024,3,20,'2024-03','Marco',1,'Quarta','Nao'),
(20240321,'2024-03-21',2024,3,21,'2024-03','Marco',1,'Quinta','Nao'),
(20240322,'2024-03-22',2024,3,22,'2024-03','Marco',1,'Sexta','Nao'),
(20240323,'2024-03-23',2024,3,23,'2024-03','Marco',1,'Sabado','Sim'),
(20240324,'2024-03-24',2024,3,24,'2024-03','Marco',1,'Domingo','Sim'),
(20240325,'2024-03-25',2024,3,25,'2024-03','Marco',1,'Segunda','Nao'),
(20240326,'2024-03-26',2024,3,26,'2024-03','Marco',1,'Terca','Nao'),
(20240327,'2024-03-27',2024,3,27,'2024-03','Marco',1,'Quarta','Nao'),
(20240328,'2024-03-28',2024,3,28,'2024-03','Marco',1,'Quinta','Nao'),
(20240329,'2024-03-29',2024,3,29,'2024-03','Marco',1,'Sexta','Nao'),
(20240330,'2024-03-30',2024,3,30,'2024-03','Marco',1,'Sabado','Sim'),
(20240331,'2024-03-31',2024,3,31,'2024-03','Marco',1,'Domingo','Sim'),
(20240401,'2024-04-01',2024,4,1,'2024-04','Abril',2,'Segunda','Nao'),
(20240402,'2024-04-02',2024,4,2,'2024-04','Abril',2,'Terca','Nao'),
(20240403,'2024-04-03',2024,4,3,'2024-04','Abril',2,'Quarta','Nao'),
(20240404,'2024-04-04',2024,4,4,'2024-04','Abril',2,'Quinta','Nao'),
(20240405,'2024-04-05',2024,4,5,'2024-04','Abril',2,'Sexta','Nao'),
(20240406,'2024-04-06',2024,4,6,'2024-04','Abril',2,'Sabado','Sim'),
(20240407,'2024-04-07',2024,4,7,'2024-04','Abril',2,'Domingo','Sim'),
(20240408,'2024-04-08',2024,4,8,'2024-04','Abril',2,'Segunda','Nao'),
(20240409,'2024-04-09',2024,4,9,'2024-04','Abril',2,'Terca','Nao'),
(20240410,'2024-04-10',2024,4,10,'2024-04','Abril',2,'Quarta','Nao'),
(20240411,'2024-04-11',2024,4,11,'2024-04','Abril',2,'Quinta','Nao'),
(20240412,'2024-04-12',2024,4,12,'2024-04','Abril',2,'Sexta','Nao'),
(20240413,'2024-04-13',2024,4,13,'2024-04','Abril',2,'Sabado','Sim'),
(20240414,'2024-04-14',2024,4,14,'2024-04','Abril',2,'Domingo','Sim'),
(20240415,'2024-04-15',2024,4,15,'2024-04','Abril',2,'Segunda','Nao'),
(20240416,'2024-04-16',2024,4,16,'2024-04','Abril',2,'Terca','Nao'),
(20240417,'2024-04-17',2024,4,17,'2024-04','Abril',2,'Quarta','Nao'),
(20240418,'2024-04-18',2024,4,18,'2024-04','Abril',2,'Quinta','Nao'),
(20240419,'2024-04-19',2024,4,19,'2024-04','Abril',2,'Sexta','Nao'),
(20240420,'2024-04-20',2024,4,20,'2024-04','Abril',2,'Sabado','Sim'),
(20240421,'2024-04-21',2024,4,21,'2024-04','Abril',2,'Domingo','Sim'),
(20240422,'2024-04-22',2024,4,22,'2024-04','Abril',2,'Segunda','Nao');

-- =====================================================================================
--  DIM_LOJA  (pronta)
-- =====================================================================================
--  32 lojas mais a linha -1. O porte sai da area de venda: Pequena < 150 m2,
--  Media 150 a 400, Grande > 400. E por ele que a P1 e a P3 agrupam.
--  populacao_cidade e o denominador da P5: itens por mil habitantes.
DROP TABLE IF EXISTS dim_loja;
CREATE TABLE dim_loja (
    sk_loja          INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    cod_loja         VARCHAR(10),
    chave_loja       VARCHAR(80),   -- nome padronizado: caixa alta, sem acento
    nome_loja        VARCHAR(80),
    cidade           VARCHAR(60),
    uf               VARCHAR(3),
    mesorregiao      VARCHAR(40),
    populacao_cidade INT,
    area_venda_m2    INT,
    porte            VARCHAR(20),
    faixa_franquia   VARCHAR(15),
    formato_loja     VARCHAR(20)
);
INSERT INTO dim_loja (sk_loja, cod_loja, chave_loja, nome_loja, cidade, uf, mesorregiao,
                      populacao_cidade, area_venda_m2, porte, faixa_franquia, formato_loja)
VALUES (-1,'N/I','NAO INFORMADO','Nao Informado','Nao Informado','N/I','Nao Informado',
        NULL,NULL,'Nao Informado','Nao Informado','Nao Informado');

INSERT INTO dim_loja (cod_loja, chave_loja, nome_loja, cidade, uf, mesorregiao,
                      populacao_cidade, area_venda_m2, porte, faixa_franquia,
                      formato_loja) VALUES
('LJ-001','PATA AMIGA BLUMENAU CENTRO','Pata Amiga Blumenau Centro','Blumenau','SC','Vale do Itajaí',361855,620,'Grande','Diamante','Megastore'),
('LJ-002','PATA AMIGA RIO DO SUL','Pata Amiga Rio do Sul','Rio do Sul','SC','Vale do Itajaí',73135,310,'Media','Diamante','Completa'),
('LJ-003','PATA AMIGA ITAJAI PRAIA','Pata Amiga Itajai Praia','Itajaí','SC','Vale do Itajaí',264054,480,'Grande','Ouro','Padrao'),
('LJ-004','PATA AMIGA BRUSQUE','Pata Amiga Brusque','Brusque','SC','Vale do Itajaí',143270,340,'Media','Ouro','Padrao'),
('LJ-005','PATA AMIGA TIMBO','Pata Amiga Timbo','Timbó','SC','Vale do Itajaí',45011,165,'Media','Ouro','Padrao'),
('LJ-006','PATA AMIGA INDAIAL','Pata Amiga Indaial','Indaial','SC','Vale do Itajaí',71987,230,'Media','Ouro','Padrao'),
('LJ-007','PATA AMIGA GASPAR','Pata Amiga Gaspar','Gaspar','SC','Vale do Itajaí',71133,245,'Media','Diamante','Megastore'),
('LJ-008','PATA AMIGA PRESIDENTE GETULIO','Pata Amiga Presidente Getulio','Presidente Getúlio','SC','Vale do Itajaí',16359,120,'Pequena','Diamante','Completa'),
('LJ-009','PATA AMIGA TAIO','Pata Amiga Taio','Taió','SC','Vale do Itajaí',18173,110,'Pequena','Ouro','Completa'),
('LJ-010','PATA AMIGA ITUPORANGA','Pata Amiga Ituporanga','Ituporanga','SC','Vale do Itajaí',25748,135,'Pequena','Prata','Padrao'),
('LJ-011','PATA AMIGA IBIRAMA','Pata Amiga Ibirama','Ibirama','SC','Vale do Itajaí',18613,115,'Pequena','Ouro','Completa'),
('LJ-012','PATA AMIGA RIO DOS CEDROS','Pata Amiga Rio dos Cedros','Rio dos Cedros','SC','Vale do Itajaí',11322,95,'Pequena','Ouro','Padrao'),
('LJ-013','PATA AMIGA JOINVILLE SUL','Pata Amiga Joinville Sul','Joinville','SC','Norte Catarinense',597658,760,'Grande','Ouro','Padrao'),
('LJ-014','PATA AMIGA JARAGUA DO SUL','Pata Amiga Jaragua do Sul','Jaraguá do Sul','SC','Norte Catarinense',184579,430,'Grande','Ouro','Padrao'),
('LJ-015','PATA AMIGA SAO BENTO DO SUL','Pata Amiga Sao Bento do Sul','São Bento do Sul','SC','Norte Catarinense',87310,260,'Media','Prata','Padrao'),
('LJ-016','PATA AMIGA ITAPOA','Pata Amiga Itapoa','Itapoá','SC','Norte Catarinense',20586,105,'Pequena','Prata','Padrao'),
('LJ-017','PATA AMIGA FLORIANOPOLIS NORTE','Pata Amiga Florianopolis Norte','Florianópolis','SC','Grande Florianópolis',537213,690,'Grande','Ouro','Padrao'),
('LJ-018','PATA AMIGA SAO JOSE KOBRASOL','Pata Amiga Sao Jose Kobrasol','São José','SC','Grande Florianópolis',250181,520,'Grande','Ouro','Padrao'),
('LJ-019','PATA AMIGA PALHOCA','Pata Amiga Palhoca','Palhoça','SC','Grande Florianópolis',168259,400,'Media','Ouro','Padrao'),
('LJ-020','PATA AMIGA SANTO AMARO DA IMPERATRIZ','Pata Amiga Santo Amaro da Imperatriz','Santo Amaro da Imperatriz','SC','Grande Florianópolis',22357,130,'Pequena','Diamante','Padrao'),
('LJ-021','PATA AMIGA CRICIUMA','Pata Amiga Criciuma','Criciúma','SC','Sul Catarinense',217392,450,'Grande','Ouro','Megastore'),
('LJ-022','PATA AMIGA TUBARAO','Pata Amiga Tubarao','Tubarão','SC','Sul Catarinense',105511,300,'Media','Ouro','Completa'),
('LJ-023','PATA AMIGA ARARANGUA','Pata Amiga Ararangua','Araranguá','SC','Sul Catarinense',68274,210,'Media','Ouro','Completa'),
('LJ-024','PATA AMIGA LAGUNA','Pata Amiga Laguna','Laguna','SC','Sul Catarinense',46122,175,'Media','Prata','Padrao'),
('LJ-025','PATA AMIGA LAGES','Pata Amiga Lages','Lages','SC','Serrana',158846,390,'Media','Prata','Padrao'),
('LJ-026','PATA AMIGA SAO JOAQUIM','Pata Amiga Sao Joaquim','São Joaquim','SC','Serrana',27234,125,'Pequena','Bronze','Padrao'),
('LJ-027','PATA AMIGA OTACILIO COSTA','Pata Amiga Otacilio Costa','Otacílio Costa','SC','Serrana',18227,100,'Pequena','Prata','Padrao'),
('LJ-028','PATA AMIGA CURITIBANOS','Pata Amiga Curitibanos','Curitibanos','SC','Serrana',39061,160,'Media','Bronze','Padrao'),
('LJ-029','PATA AMIGA CHAPECO','Pata Amiga Chapeco','Chapecó','SC','Oeste Catarinense',254235,470,'Grande','Prata','Padrao'),
('LJ-030','PATA AMIGA CONCORDIA','Pata Amiga Concordia','Concórdia','SC','Oeste Catarinense',74641,220,'Media','Prata','Padrao'),
('LJ-031','PATA AMIGA XANXERE','Pata Amiga Xanxere','Xanxerê','SC','Oeste Catarinense',52034,180,'Media','Bronze','Padrao'),
('LJ-032','PATA AMIGA SAO MIGUEL DO OESTE','Pata Amiga Sao Miguel do Oeste','São Miguel do Oeste','SC','Oeste Catarinense',41520,170,'Media','Bronze','Padrao');

-- =====================================================================================
--  AS TABELAS QUE VOCE VAI PREENCHER  -  ja criadas, e vazias
-- =====================================================================================
--  Abaixo estao os CREATE TABLE das quatro tabelas. Elas ficam vazias; voce as
--  preenche nos arquivos 03 e 04.
--
--  Os comentarios de cada coluna sao a especificacao do que gravar ali.

-- -------------------------------------------------------------------------------------
--  DIM_CATEGORIA        grao: UMA GRAFIA DA ORIGEM
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS dim_categoria;
CREATE TABLE dim_categoria (
    sk_categoria     INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    categoria_origem VARCHAR(50),   -- a grafia crua, como veio da origem
    nome_categoria   VARCHAR(30),   -- o nome padronizado: e por ele que se agrupa
    grupo_categoria  VARCHAR(20)    -- Alimentacao, Saude e Higiene, Bem-estar
);

-- -------------------------------------------------------------------------------------
--  DIM_PRACA            grao: UMA PRACA DE ATENDIMENTO
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS dim_praca;
CREATE TABLE dim_praca (
    sk_praca           INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    cod_praca          VARCHAR(10),
    nome_praca         VARCHAR(60),
    regional           VARCHAR(30),
    domicilios_com_pet INT          -- vem como '148.000': tire o ponto de milhar
);

-- -------------------------------------------------------------------------------------
--  BRIDGE_LOJA_PRACA    grao: UMA LOJA x UMA PRACA
-- -------------------------------------------------------------------------------------
--  A tabela PONTE. Uma loja entrega em mais de uma praca, e uma FK so comporta
--  um valor - entao a ligacao N:N vive aqui, com o fator de rateio dentro.
--
--  ATENCAO: a ponte e ligada pelo COD DA LOJA, e nao pela sk_loja.
DROP TABLE IF EXISTS bridge_loja_praca;
CREATE TABLE bridge_loja_praca (
    cod_loja      VARCHAR(10),
    sk_praca      INT,
    fator_publico DECIMAL(6,4),   -- 0,85 = 85% do publico daquela loja
    PRIMARY KEY (cod_loja, sk_praca)
);

-- -------------------------------------------------------------------------------------
--  FATO_PEDIDO          grao: UM PEDIDO       4.044 linhas
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS fato_pedido;
CREATE TABLE fato_pedido (
    sk_pedido        INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    numero_pedido    VARCHAR(20),   -- codigo do pedido, sem atributos

    -- as duas FKs de tempo: dois papeis da MESMA dim_tempo
    sk_tempo_pedido  INT NOT NULL,
    sk_tempo_entrega INT NOT NULL,  -- vale -1 se a entrega ainda nao aconteceu

    -- as demais FKs. Nenhuma pode ser nula: quando falta, vale -1
    sk_loja          INT NOT NULL,
    sk_categoria     INT NOT NULL,

    -- atributos que ficam na fato
    -- desconto e canal sao dois dominios de poucos valores. Como nada esta
    -- pendurado neles, ficam aqui na fato, padronizados uma vez no arquivo 04.
    houve_desconto   VARCHAR(15),   -- Sim / Nao / Nao Informado
    canal_pedido     VARCHAR(20),   -- App / Site / Loja Fisica / Telefone / WhatsApp
    dt_pedido        TIMESTAMP,   -- data e hora do pedido

    -- metricas ADITIVAS
    qt_itens         INT,
    vl_liquido       DECIMAL(15,2),

    -- os lags do processo, em dias. Calculados UMA vez, aqui na carga.
    -- Etapa nao cumprida grava NULL, nunca 0.
    dias_integracao_separacao INT,
    dias_separacao_nota       INT,
    dias_nota_despacho        INT,
    dias_despacho_entrega     INT,
    dias_total_ate_entrega    INT
);

-- =====================================================================================
--  CONFERENCIA DO QUE VEIO PRONTO
-- =====================================================================================
SELECT 'dim_tempo' AS tabela, COUNT(*) AS linhas, '236  (235 dias + a -1)' AS esperado
FROM dim_tempo
UNION ALL SELECT 'dim_loja', COUNT(*), '33  (32 lojas + a -1)' FROM dim_loja;

