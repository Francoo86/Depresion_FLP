/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     16-11-2022 20:05:32                          */
/*==============================================================*/


drop table if exists ANSWERS;

drop table if exists CREATES;

drop table if exists CREATESVY;

drop table if exists DIAGNOSTICS;

drop table if exists PATIENTS;

drop table if exists PSYCHOLOGISTS;

drop table if exists QUESTIONS;

drop table if exists RESPONSE;

drop table if exists SURVEYS;

drop table if exists USERS;

/*==============================================================*/
/* Table: ANSWERS                                               */
/*==============================================================*/
create table ANSWERS
(
   ID_ANS               int not null,
   ID_QUESTION          int not null,
   ID_RESP              int,
   POINT_ANS            int,
   TEXT_ANS             char(250),
   OBS_ANS              char(250),
   primary key (ID_ANS)
);

/*==============================================================*/
/* Table: CREATES                                               */
/*==============================================================*/
create table CREATES
(
   ID_DIAG              int not null,
   ID_USR               int not null,
   ID_PSY               int not null,
   primary key (ID_DIAG, ID_USR, ID_PSY)
);

/*==============================================================*/
/* Table: CREATESVY                                             */
/*==============================================================*/
create table CREATESVY
(
   ID_SVY               int not null,
   ID_USR               int not null,
   ID_PSY               int not null,
   primary key (ID_SVY, ID_USR, ID_PSY)
);

/*==============================================================*/
/* Table: DIAGNOSTICS                                           */
/*==============================================================*/
create table DIAGNOSTICS
(
   ID_DIAG              int not null,
   ID_USR               int not null,
   ID_PAT               int not null,
   ID_RESP              int not null,
   RESULT_DIAG          char(250),
   TOTAL_POINTS_DIAG    int,
   DESC_DIAG            char(250),
   primary key (ID_DIAG)
);

/*==============================================================*/
/* Table: PATIENTS                                              */
/*==============================================================*/
create table PATIENTS
(
   ID_USR               int not null,
   ID_PAT               int not null,
   SEX_PAT              char(1),
   PASSPORT_PAT         char(250),
   BIRTHDATE_PAT        date,
   primary key (ID_USR, ID_PAT)
);

/*==============================================================*/
/* Table: PSYCHOLOGISTS                                         */
/*==============================================================*/
create table PSYCHOLOGISTS
(
   ID_USR               int not null,
   ID_PSY               int not null,
   SPECIALITY_PSY       char(100),
   DEGREES_PSY          char(100),
   primary key (ID_USR, ID_PSY)
);

/*==============================================================*/
/* Table: QUESTIONS                                             */
/*==============================================================*/
create table QUESTIONS
(
   ID_QUESTION          int not null,
   ID_SVY               int,
   QUESTION             char(250),
   DESC_QTN             char(250),
   DISABLED             bool default false,
   primary key (ID_QUESTION)
);

/*==============================================================*/
/* Table: RESPONSE                                              */
/*==============================================================*/
create table RESPONSE
(
   ID_RESP              int not null,
   ID_USR               int not null,
   ID_PAT               int not null,
   ID_SVY               int not null,
   COMMENTS_RESP        char(255),
   FINISH_DATE          date,
   primary key (ID_RESP)
);

/*==============================================================*/
/* Table: SURVEYS                                               */
/*==============================================================*/
create table SURVEYS
(
   ID_SVY               int not null,
   DISABLED             bool default false,
   DESC_SVY             char(250),
   primary key (ID_SVY)
);

/*==============================================================*/
/* Table: USERS                                                 */
/*==============================================================*/
create table USERS
(
   ID_USR               int not null,
   RUN_USR              int,
   FIRSTNAME_USR        char(250),
   PHONE_NUMBER         int,
   EMAIL_USR            char(250),
   PASS_USR             varchar(255),
   LASTNAME_USR         char(250),
   DISABLED             bool default false,
   primary key (ID_USR)
);

alter table ANSWERS add constraint FK_CONTAINS_1 foreign key (ID_RESP)
      references RESPONSE (ID_RESP) on delete restrict on update restrict;

alter table ANSWERS add constraint FK_HAVES foreign key (ID_QUESTION)
      references QUESTIONS (ID_QUESTION) on delete restrict on update restrict;

alter table CREATES add constraint FK_CREATES foreign key (ID_DIAG)
      references DIAGNOSTICS (ID_DIAG) on delete restrict on update restrict;

alter table CREATES add constraint FK_CREATES2 foreign key (ID_USR, ID_PSY)
      references PSYCHOLOGISTS (ID_USR, ID_PSY) on delete restrict on update restrict;

alter table CREATESVY add constraint FK_CREATESVY foreign key (ID_SVY)
      references SURVEYS (ID_SVY) on delete restrict on update restrict;

alter table CREATESVY add constraint FK_CREATESVY2 foreign key (ID_USR, ID_PSY)
      references PSYCHOLOGISTS (ID_USR, ID_PSY) on delete restrict on update restrict;

alter table DIAGNOSTICS add constraint FK_HAS foreign key (ID_USR, ID_PAT)
      references PATIENTS (ID_USR, ID_PAT) on delete restrict on update restrict;

alter table DIAGNOSTICS add constraint FK_HAVE_3 foreign key (ID_RESP)
      references RESPONSE (ID_RESP) on delete restrict on update restrict;

alter table PATIENTS add constraint FK_INHERITS2 foreign key (ID_USR)
      references USERS (ID_USR) on delete restrict on update restrict;

alter table PSYCHOLOGISTS add constraint FK_INHERITS foreign key (ID_USR)
      references USERS (ID_USR) on delete restrict on update restrict;

alter table QUESTIONS add constraint FK_CONTAINS foreign key (ID_SVY)
      references SURVEYS (ID_SVY) on delete restrict on update restrict;

alter table RESPONSE add constraint FK_HAVE foreign key (ID_SVY)
      references SURVEYS (ID_SVY) on delete restrict on update restrict;

alter table RESPONSE add constraint FK_REPLIES foreign key (ID_USR, ID_PAT)
      references PATIENTS (ID_USR, ID_PAT) on delete restrict on update restrict;

