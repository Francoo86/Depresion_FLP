INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (14622655, 'Psicologo', 'Clinico', 'test123', 'Elizabeth@email.com', 'Elizabeth', 'CarlsonSusan', 6);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (13837859, 'Psicologo', 'Clinico', 'test123', 'Marcus@email.com', 'Marcus', 'Stevens', 2);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (45856665, 'Psicologo', 'Clinico', 'test123', 'Andrew@email.com', 'Andrew', 'Smith', 4);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (40001105, 'Psicologo', 'Clinico', 'test123', 'Theodore@email.com', 'Theodore', 'Williams', 0);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (42695644, 'Psicologo', 'Clinico', 'test123', 'Debra@email.com', 'Debra', 'Allen', 3);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (12508269, 'Psicologo', 'Clinico', 'test123', 'Jennifer@email.com', 'Jennifer', 'Mason', 9);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (94731316, 'Psicologo', 'Clinico', 'test123', 'Laura@email.com', 'Laura', 'Carrillo', 3);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (43738377, 'Psicologo', 'Clinico', 'test123', 'Nancy@email.com', 'Nancy', 'Murphy', 3);
INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (48795155, 'Psicologo', 'Clinico', 'test123', 'George@email.com', 'George', 'Robinson', 5);

INSERT INTO `SURVEYS`(desc_svy, name_svy, `THERAPISTS_id_tp`) VALUES ("Test de Beck para determinar depresión.", "Prueba Survey", 1);
INSERT INTO `SURVEYS`(desc_svy, name_svy, `THERAPISTS_id_tp`) VALUES ("Encuesta sobre Half-Life 3.", "Prueba HL2 Survey", 1);

INSERT INTO `SURVEYS`(desc_svy, name_svy, `THERAPISTS_id_tp`) VALUES ("Descripcion de Prueba", "Test 45", 2);
INSERT INTO `SURVEYS`(desc_svy, name_svy, `THERAPISTS_id_tp`) VALUES ("hola hola", "Test hola", 2);

SELECT * FROM `SURVEYS`;

SELECT run_tp as 'RUT Psicologo', dv_tp AS 'Digito Verificador' 
    ,firstname_tp AS 'Nombres', lastname_tp AS 'Apellidos', speciality_tp as "Especialidad", degrees_tp as "Estudios" FROM `THERAPISTS` WHERE disabled=false;
SELECT COUNT(`THERAPISTS_id_tp`) FROM `SURVEYS` WHERE `THERAPISTS_id_tp`=1;
INSERT INTO `QUESTIONS` (qtn_text, `SURVEYS_id_svy`) VALUES ("¿Cuantas manzanas tiene pedrito?", 2);

SELECT * FROM `QUESTIONS`;

SELECT name_svy as "Nombre encuesta", desc_svy as "Descripcion" FROM `SURVEYS` where `THERAPISTS_id_tp` = 1;
SELECT LAST_INSERT_ID();