-- MySQL Script generated by MySQL Workbench
-- Sun Nov 20 22:02:28 2022
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema psy_rework
-- -----------------------------------------------------
-- Este es una remasterización del código SQL ya que PD crea tablas de relación algo confusas.
DROP SCHEMA IF EXISTS `psy_rework` ;

-- -----------------------------------------------------
-- Schema psy_rework
--
-- Este es una remasterización del código SQL ya que PD crea tablas de relación algo confusas.
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `psy_rework` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin ;
USE `psy_rework` ;

-- -----------------------------------------------------
-- Table `psy_rework`.`THERAPISTS`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `psy_rework`.`THERAPISTS` ;

CREATE TABLE IF NOT EXISTS `psy_rework`.`THERAPISTS` (
  `id_tp` INT NOT NULL AUTO_INCREMENT,
  `speciality_tp` CHAR(50) NULL,
  `degrees_tp` CHAR(50) NULL,
  `pass_tp` VARCHAR(255) NOT NULL,
  `email_tp` VARCHAR(45) NOT NULL,
  `firstname_tp` CHAR(100) NULL,
  `lastname_tp` CHAR(100) NULL,
  `dv_tp` CHAR(1) NOT NULL,
  `disabled` TINYINT NULL DEFAULT 0,
  `run_tp` INT NULL,
  PRIMARY KEY (`id_tp`),
  UNIQUE INDEX `run_tp_UNIQUE` (`run_tp` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `psy_rework`.`SURVEYS`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `psy_rework`.`SURVEYS` ;

CREATE TABLE IF NOT EXISTS `psy_rework`.`SURVEYS` (
  `id_svy` INT NOT NULL AUTO_INCREMENT,
  `desc_svy` CHAR(250) NULL,
  `name_svy` CHAR(75) NULL,
  `disabled` TINYINT NULL DEFAULT 0,
  `THERAPISTS_id_tp` INT NOT NULL,
  PRIMARY KEY (`id_svy`),
  INDEX `fk_SURVEYS_THERAPISTS1_idx` (`THERAPISTS_id_tp` ASC) VISIBLE,
  CONSTRAINT `fk_SURVEYS_THERAPISTS1`
    FOREIGN KEY (`THERAPISTS_id_tp`)
    REFERENCES `psy_rework`.`THERAPISTS` (`id_tp`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `psy_rework`.`QUESTIONS`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `psy_rework`.`QUESTIONS` ;

CREATE TABLE IF NOT EXISTS `psy_rework`.`QUESTIONS` (
  `id_qtn` INT NOT NULL AUTO_INCREMENT,
  `qtn_text` CHAR(250) NULL,
  `disabled` TINYINT NULL DEFAULT 0,
  `SURVEYS_id_svy` INT NOT NULL,
  PRIMARY KEY (`id_qtn`),
  INDEX `fk_QUESTIONS_SURVEYS_idx` (`SURVEYS_id_svy` ASC) VISIBLE,
  CONSTRAINT `fk_QUESTIONS_SURVEYS`
    FOREIGN KEY (`SURVEYS_id_svy`)
    REFERENCES `psy_rework`.`SURVEYS` (`id_svy`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `psy_rework`.`ANSWERS`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `psy_rework`.`ANSWERS` ;

CREATE TABLE IF NOT EXISTS `psy_rework`.`ANSWERS` (
  `id_ans` INT NOT NULL AUTO_INCREMENT,
  `text_ans` CHAR(250) NULL,
  `points_ans` INT NULL,
  `QUESTIONS_id_qtn` INT NOT NULL,
  PRIMARY KEY (`id_ans`),
  INDEX `fk_ANSWERS_QUESTIONS1_idx` (`QUESTIONS_id_qtn` ASC) VISIBLE,
  CONSTRAINT `fk_ANSWERS_QUESTIONS1`
    FOREIGN KEY (`QUESTIONS_id_qtn`)
    REFERENCES `psy_rework`.`QUESTIONS` (`id_qtn`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `psy_rework`.`PATIENTS`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `psy_rework`.`PATIENTS` ;

CREATE TABLE IF NOT EXISTS `psy_rework`.`PATIENTS` (
  `id_pat` INT NOT NULL AUTO_INCREMENT,
  `passport_pat` VARCHAR(250) NULL,
  `birthdate_pat` DATE NOT NULL,
  `run_pat` INT NOT NULL,
  `dv_pat` CHAR(1) NULL,
  `THERAPISTS_id_tp` INT NOT NULL,
  `firstname_pat` CHAR(100) NULL,
  `lastname_pat` CHAR(100) NULL,
  `address_pat` CHAR(100) NULL,
  `prof_pat` CHAR(100) NULL DEFAULT 'estudiante',
  PRIMARY KEY (`id_pat`),
  UNIQUE INDEX `run_pat_UNIQUE` (`run_pat` ASC) VISIBLE,
  INDEX `fk_PATIENTS_THERAPISTS1_idx` (`THERAPISTS_id_tp` ASC) VISIBLE,
  CONSTRAINT `fk_PATIENTS_THERAPISTS1`
    FOREIGN KEY (`THERAPISTS_id_tp`)
    REFERENCES `psy_rework`.`THERAPISTS` (`id_tp`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `psy_rework`.`RESULTS`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `psy_rework`.`RESULTS` ;

CREATE TABLE IF NOT EXISTS `psy_rework`.`RESULTS` (
  `id_res` INT NOT NULL AUTO_INCREMENT,
  `comment_res` CHAR(100) NULL,
  `SURVEYS_id_svy` INT NOT NULL,
  PRIMARY KEY (`id_res`),
  INDEX `fk_RESULTS_SURVEYS1_idx` (`SURVEYS_id_svy` ASC) VISIBLE,
  CONSTRAINT `fk_RESULTS_SURVEYS1`
    FOREIGN KEY (`SURVEYS_id_svy`)
    REFERENCES `psy_rework`.`SURVEYS` (`id_svy`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `psy_rework`.`RESPONSES`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `psy_rework`.`RESPONSES` ;

CREATE TABLE IF NOT EXISTS `psy_rework`.`RESPONSES` (
  `id_resp` INT NOT NULL AUTO_INCREMENT,
  `choice_resp` INT NULL,
  `comments_resp` VARCHAR(255) NULL,
  `SURVEYS_id_svy` INT NOT NULL,
  `PATIENTS_id_pat` INT NOT NULL,
  `ANSWERS_id_ans` INT NOT NULL,
  `QUESTIONS_id_qtn` INT NOT NULL,
  `RESULTS_id_res` INT NOT NULL,
  PRIMARY KEY (`id_resp`),
  INDEX `fk_RESPONSES_SURVEYS1_idx` (`SURVEYS_id_svy` ASC) VISIBLE,
  INDEX `fk_RESPONSES_PATIENTS1_idx` (`PATIENTS_id_pat` ASC) VISIBLE,
  INDEX `fk_RESPONSES_ANSWERS1_idx` (`ANSWERS_id_ans` ASC) VISIBLE,
  INDEX `fk_RESPONSES_QUESTIONS1_idx` (`QUESTIONS_id_qtn` ASC) VISIBLE,
  INDEX `fk_RESPONSES_RESULTS1_idx` (`RESULTS_id_res` ASC) VISIBLE,
  CONSTRAINT `fk_RESPONSES_SURVEYS1`
    FOREIGN KEY (`SURVEYS_id_svy`)
    REFERENCES `psy_rework`.`SURVEYS` (`id_svy`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_RESPONSES_PATIENTS1`
    FOREIGN KEY (`PATIENTS_id_pat`)
    REFERENCES `psy_rework`.`PATIENTS` (`id_pat`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_RESPONSES_ANSWERS1`
    FOREIGN KEY (`ANSWERS_id_ans`)
    REFERENCES `psy_rework`.`ANSWERS` (`id_ans`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_RESPONSES_QUESTIONS1`
    FOREIGN KEY (`QUESTIONS_id_qtn`)
    REFERENCES `psy_rework`.`QUESTIONS` (`id_qtn`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_RESPONSES_RESULTS1`
    FOREIGN KEY (`RESULTS_id_res`)
    REFERENCES `psy_rework`.`RESULTS` (`id_res`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `psy_rework`.`DIAGNOSTICS`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `psy_rework`.`DIAGNOSTICS` ;

CREATE TABLE IF NOT EXISTS `psy_rework`.`DIAGNOSTICS` (
  `id_diag` INT NOT NULL AUTO_INCREMENT,
  `obs_diag` CHAR(250) NULL,
  `PATIENTS_id_pat` INT NOT NULL,
  `THERAPISTS_id_tp` INT NOT NULL,
  `RESULTS_id_res` INT NOT NULL,
  PRIMARY KEY (`id_diag`),
  INDEX `fk_DIAGNOSTICS_PATIENTS1_idx` (`PATIENTS_id_pat` ASC) VISIBLE,
  INDEX `fk_DIAGNOSTICS_THERAPISTS1_idx` (`THERAPISTS_id_tp` ASC) VISIBLE,
  INDEX `fk_DIAGNOSTICS_RESULTS1_idx` (`RESULTS_id_res` ASC) VISIBLE,
  CONSTRAINT `fk_DIAGNOSTICS_PATIENTS1`
    FOREIGN KEY (`PATIENTS_id_pat`)
    REFERENCES `psy_rework`.`PATIENTS` (`id_pat`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_DIAGNOSTICS_THERAPISTS1`
    FOREIGN KEY (`THERAPISTS_id_tp`)
    REFERENCES `psy_rework`.`THERAPISTS` (`id_tp`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_DIAGNOSTICS_RESULTS1`
    FOREIGN KEY (`RESULTS_id_res`)
    REFERENCES `psy_rework`.`RESULTS` (`id_res`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
