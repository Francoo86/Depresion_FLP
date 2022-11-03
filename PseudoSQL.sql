CREATE DATABASE IF NOT EXISTS TestFLP

CREATE TABLE Users(
    id INT NOT NULL AUTO_INCREMENT,
    run INT,
    lv CHAR(1),
    names VARCHAR(75),
    father_name VARCHAR(50),
    mother_name VARCHAR(50),
    gender CHAR(1),
    birthday DATE,
    phone INT,

    CONSTRAINT PK_User PRIMARY KEY(id)
)

CREATE TABLE Questions(
    id INT NOT NULL AUTO_INCREMENT,
    question VARCHAR(35),
    description_q VARCHAR(80),
    deleted_at DATE,

    CONSTRAINT PK_Question PRIMARY KEY(id)
)

CREATE TABLE Answers(
    id INT NOT NULL AUTO_INCREMENT,
    question_id INT,
    point_ans int,
    text_ans VARCHAR(50),
    observation VARCHAR(100),

    CONSTRAINT PK_Answers PRIMARY KEY(id)
)

CREATE TABLE Polls(
    id INT NOT NULL AUTO_INCREMENT,
    patient_id ???,
    users ???,

)
