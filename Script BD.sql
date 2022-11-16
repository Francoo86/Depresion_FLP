/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     16/11/2022 0:23:05                           */
/*==============================================================*/


drop table if exists ANSWERS;

drop table if exists CONTAINS_1;

drop table if exists CREATES;

drop table if exists PATIENTS;

drop table if exists POLLS;

drop table if exists PSYCHOLOGISTS;

drop table if exists QUESTIONS;

drop table if exists REPLYS;

drop table if exists TESTS;

drop table if exists USERS;

/*==============================================================*/
/* Table: ANSWERS                                               */
/*==============================================================*/
create table ANSWERS
(
   ID_ANSWERS           int not null,
   ID_QUESTION          int not null,
   ID_POLL              int not null,
   POINTS_A             int,
   TEXT_A               char(250),
   ATTRIBUTE_15         char(250),
   DISABLE              bool,
   primary key (ID_ANSWERS)
);

/*==============================================================*/
/* Table: CONTAINS_1                                            */
/*==============================================================*/
create table CONTAINS_1
(
   ID_TEST              int not null,
   ID_QUESTION          int not null,
   primary key (ID_TEST, ID_QUESTION)
);

/*==============================================================*/
/* Table: CREATES                                               */
/*==============================================================*/
create table CREATES
(
   ID_USER              int not null,
   ID_TEST              int not null,
   primary key (ID_USER, ID_TEST)
);

/*==============================================================*/
/* Table: PATIENTS                                              */
/*==============================================================*/
create table PATIENTS
(
   ID_USER              int not null,
   ID_POLL              int,
   RUN                  int,
   NAMES                char(250),
   DESCRIPCION          char(250),
   PHONE_NUMBER         int,
   EMAIL                char(250),
   DISABLE              bool,
   PASSWORD_USERS       varchar(255),
   LAST_NAME            char(250),
   SEX                  char(250),
   TOTAL_POINTS         int,
   PASSPORT             char(250),
   primary key (ID_USER)
);

/*==============================================================*/
/* Table: POLLS                                                 */
/*==============================================================*/
create table POLLS
(
   ID_POLL              int not null,
   DISABLE              bool,
   primary key (ID_POLL)
);

/*==============================================================*/
/* Table: PSYCHOLOGISTS                                         */
/*==============================================================*/
create table PSYCHOLOGISTS
(
   ID_USER              int not null,
   ID_POLL              int,
   RUN                  int,
   NAMES                char(250),
   DESCRIPCION          char(250),
   PHONE_NUMBER         int,
   EMAIL                char(250),
   DISABLE              bool,
   PASSWORD_USERS       varchar(255),
   LAST_NAME            char(250),
   DIAGNOSTIC_PATIENT   char(250),
   SPECIALTY            char(250),
   primary key (ID_USER)
);

/*==============================================================*/
/* Table: QUESTIONS                                             */
/*==============================================================*/
create table QUESTIONS
(
   ID_QUESTION          int not null,
   QUESTION             char(250),
   DESCRIPCION_QUESTION char(250),
   DISABLE              bool,
   primary key (ID_QUESTION)
);

/*==============================================================*/
/* Table: REPLYS                                                */
/*==============================================================*/
create table REPLYS
(
   ID_USER              int not null,
   ID_TEST              int not null,
   primary key (ID_USER, ID_TEST)
);

/*==============================================================*/
/* Table: TESTS                                                 */
/*==============================================================*/
create table TESTS
(
   ID_TEST              int not null,
   ID_POLL              int not null,
   RESULTS              char(250),
   TOTAL_POINTS         int,
   QUESTIONS            char(250),
   DISABLE              bool,
   primary key (ID_TEST)
);

/*==============================================================*/
/* Table: USERS                                                 */
/*==============================================================*/
create table USERS
(
   ID_USER              int not null,
   ID_POLL              int not null,
   RUN                  int,
   NAMES                char(250),
   DESCRIPCION          char(250),
   PHONE_NUMBER         int,
   EMAIL                char(250),
   DISABLE              bool,
   PASSWORD_USERS       varchar(255),
   LAST_NAME            char(250),
   primary key (ID_USER)
);

alter table ANSWERS add constraint FK_CONTAINS_4 foreign key (ID_POLL)
      references POLLS (ID_POLL) on delete restrict on update restrict;

alter table ANSWERS add constraint FK_HAVES foreign key (ID_QUESTION)
      references QUESTIONS (ID_QUESTION) on delete restrict on update restrict;

alter table CONTAINS_1 add constraint FK_CONTAINS_1 foreign key (ID_TEST)
      references TESTS (ID_TEST) on delete restrict on update restrict;

alter table CONTAINS_1 add constraint FK_CONTAINS_2 foreign key (ID_QUESTION)
      references QUESTIONS (ID_QUESTION) on delete restrict on update restrict;

alter table CREATES add constraint FK_CREATES foreign key (ID_USER)
      references PSYCHOLOGISTS (ID_USER) on delete restrict on update restrict;

alter table CREATES add constraint FK_CREATES2 foreign key (ID_TEST)
      references TESTS (ID_TEST) on delete restrict on update restrict;

alter table PATIENTS add constraint FK_CAN_BE2 foreign key (ID_USER)
      references USERS (ID_USER) on delete restrict on update restrict;

alter table PSYCHOLOGISTS add constraint FK_CAN_BE foreign key (ID_USER)
      references USERS (ID_USER) on delete restrict on update restrict;

alter table REPLYS add constraint FK_REPLYS foreign key (ID_USER)
      references PATIENTS (ID_USER) on delete restrict on update restrict;

alter table REPLYS add constraint FK_REPLYS2 foreign key (ID_TEST)
      references TESTS (ID_TEST) on delete restrict on update restrict;

alter table TESTS add constraint FK_CONTAINS_5 foreign key (ID_POLL)
      references POLLS (ID_POLL) on delete restrict on update restrict;

alter table USERS add constraint FK_CONTAINS_3 foreign key (ID_POLL)
      references POLLS (ID_POLL) on delete restrict on update restrict;

