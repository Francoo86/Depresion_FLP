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

SELECT firstname_tp, lastname_tp FROM `THERAPISTS`;