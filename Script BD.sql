/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     15/11/2022 23:34:06                          */
/*==============================================================*/


drop table if exists ANSWERS;

drop table if exists CONTAINS_1;

drop table if exists CREATES;

drop table if exists PAIENT;

drop table if exists POLL;

drop table if exists PSYCHOLOGIST;

drop table if exists QUESTIONS;

drop table if exists REPLYS;

drop table if exists TEST;

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
   primary key (ID_ANSWERS)
);

/*==============================================================*/
/* Table: CONTAINS_1                                            */
/*==============================================================*/
create table CONTAINS_1
(
   ID_QUESTION          int not null,
   ID_TEST              int not null,
   primary key (ID_QUESTION, ID_TEST)
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
/* Table: PAIENT                                                */
/*==============================================================*/
create table PAIENT
(
   ID_USER              int not null,
   ID_POLL              int not null,
   RUN                  int,
   NAMES                char(250),
   DESCRIPCION          char(250),
   PHONE_NUMBER         int,
   EMAIL                char(250),
   SEX                  char(250),
   TOTAL_POINTS         int,
   primary key (ID_USER)
);

/*==============================================================*/
/* Table: POLL                                                  */
/*==============================================================*/
create table POLL
(
   ID_POLL              int not null,
   primary key (ID_POLL)
);

/*==============================================================*/
/* Table: PSYCHOLOGIST                                          */
/*==============================================================*/
create table PSYCHOLOGIST
(
   ID_USER              int not null,
   ID_POLL              int not null,
   RUN                  int,
   NAMES                char(250),
   DESCRIPCION          char(250),
   PHONE_NUMBER         int,
   EMAIL                char(250),
   DIAGNOSTIC_PATIENT   char(250),
   ESPECIALIDAD         char(250),
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
   DELETE_AT            char(250),
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
/* Table: TEST                                                  */
/*==============================================================*/
create table TEST
(
   ID_TEST              int not null,
   ID_POLL              int not null,
   RESULTS              char(250),
   TOTAL_POINTS         int,
   QUESTIONS            char(250),
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
   primary key (ID_USER)
);

alter table ANSWERS add constraint FK_CONTAINS_3 foreign key (ID_POLL)
      references POLL (ID_POLL) on delete restrict on update restrict;

alter table ANSWERS add constraint FK_HAVES foreign key (ID_QUESTION)
      references QUESTIONS (ID_QUESTION) on delete restrict on update restrict;

alter table CONTAINS_1 add constraint FK_CONTAINS_1 foreign key (ID_QUESTION)
      references QUESTIONS (ID_QUESTION) on delete restrict on update restrict;

alter table CONTAINS_1 add constraint FK_CONTAINS_5 foreign key (ID_TEST)
      references TEST (ID_TEST) on delete restrict on update restrict;

alter table CREATES add constraint FK_CREATES foreign key (ID_TEST)
      references TEST (ID_TEST) on delete restrict on update restrict;

alter table CREATES add constraint FK_CREATES2 foreign key (ID_USER)
      references PSYCHOLOGIST (ID_USER) on delete restrict on update restrict;

alter table PAIENT add constraint FK_CAN_BE2 foreign key (ID_USER)
      references USERS (ID_USER) on delete restrict on update restrict;

alter table PSYCHOLOGIST add constraint FK_CAN_BE foreign key (ID_USER)
      references USERS (ID_USER) on delete restrict on update restrict;

alter table REPLYS add constraint FK_REPLYS foreign key (ID_TEST)
      references TEST (ID_TEST) on delete restrict on update restrict;

alter table REPLYS add constraint FK_REPLYS2 foreign key (ID_USER)
      references PAIENT (ID_USER) on delete restrict on update restrict;

alter table TEST add constraint FK_CONTAINS_4 foreign key (ID_POLL)
      references POLL (ID_POLL) on delete restrict on update restrict;

alter table USERS add constraint FK_CONTAINS_2 foreign key (ID_POLL)
      references POLL (ID_POLL) on delete restrict on update restrict;

