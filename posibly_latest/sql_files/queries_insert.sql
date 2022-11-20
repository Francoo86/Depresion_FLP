-- Active: 1668824140759@@127.0.0.1@3306@psy_rework

/* REALIZAR 10 INSERTS CON TERAPEUTAS */

INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp)
VALUES (8490123, "Educacional", "Educacion", "randompass", "juanito@email.com", "Juanito Fulano", "Perez Ramirez", "4");

INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (14622655, 'Psicologo', 'Clinico', 'test123', 'Elizabeth@email.com', 'Elizabeth', 'CarlsonSusan', 6);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (13837859, 'Psicologo', 'Clinico', 'test123', 'Marcus@email.com', 'Marcus', 'Stevens', 2);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (45856665, 'Psicologo', 'Clinico', 'test123', 'Andrew@email.com', 'Andrew', 'Smith', 4);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (40001105, 'Psicologo', 'Clinico', 'test123', 'Theodore@email.com', 'Theodore', 'Williams', 0);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (42695644, 'Psicologo', 'Clinico', 'test123', 'Debra@email.com', 'Debra', 'Allen', 3);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (12508269, 'Psicologo', 'Clinico', 'test123', 'Jennifer@email.com', 'Jennifer', 'Mason', 9);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (94731316, 'Psicologo', 'Clinico', 'test123', 'Laura@email.com', 'Laura', 'Carrillo', 3);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (43738377, 'Psicologo', 'Clinico', 'test123', 'Nancy@email.com', 'Nancy', 'Murphy', 3);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (48795155, 'Psicologo', 'Clinico', 'test123', 'George@email.com', 'George', 'Robinson', 5);

SELECT * FROM `THERAPISTS` WHERE email_tp="juanito@email.com" and pass_tp="pholdermd5";

SELECT * FROM `THERAPISTS`;

SELECT * FROM `QUESTIONS` WHERE `SURVEYS_id_svy`=8;

-- Mostrar preguntas con su respectiva respuesta.
ALTER TABLE `RESPONSES` ADD COLUMN responses_num INT;

ALTER TABLE `PATIENTS` ADD `prof_pat` CHAR(100) DEFAULT 'estudiante';
ALTER TABLE `PATIENTS` DROP COLUMN prof_pat;
ALTER TABLE `PATIENTS` ALTER COLUMN prof_pat CHAR(100);
SELECT * FROm `RESPONSES`;

SELECT * FROM `PATIENTS`;

-- Obtener preguntas de una determinada encuesta.
SELECT q.id_qtn, q.qtn_text FROM `SURVEYS` sv INNER JOIN `QUESTIONS` q on q.`SURVEYS_id_svy` = sv.id_svy WHERE sv.id_svy = 1 AND q.disabled = false;
-- Test encontrar las respuestas.

SELECT q.id_qtn, q.qtn_text, a.text_ans, a.points_ans, a.id_ans FROM `SURVEYS` sv INNER JOIN `QUESTIONS` q on q.`SURVEYS_id_svy` = sv.id_svy INNER JOIN `ANSWERS` a 
ON q.id_qtn = a.`QUESTIONS_id_qtn` WHERE q.disabled = false;

SELECT q.id_qtn, q.qtn_text FROM `SURVEYS` sv INNER JOIN `QUESTIONS` q on q.`SURVEYS_id_svy` = sv.id_svy WHERE sv.id_svy = 1 AND q.disabled = false;
SELECT sv.name_svy, sv.desc_svy, tp.id_tp FROM `SURVEYS` sv INNER JOIN `THERAPISTS` tp ON tp.id_tp = sv.`THERAPISTS_id_tp` WHERE tp.disabled = false AND tp.id_tp = 2;

SELECT a.id_ans, q.qtn_text, a.text_ans, a.points_ans FROM `QUESTIONS` q INNER JOIN `ANSWERS` a ON q.id_qtn = a.`QUESTIONS_id_qtn` WHERE q.id_qtn = 6;
SELECT firstname_tp, lastname_tp FROM `THERAPISTS`;