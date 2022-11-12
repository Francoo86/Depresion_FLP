# Crear tabla según el ejemplo.
# https://www.w3schools.com/mysql/mysql_create_table.asp
# Ejecutar script en MySQL Workbench.

CREATE TABLE Persons (
    PersonID int,
    LastName varchar(255),
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
);

INSERT INTO Persons (PersonID, LastName, FirstName, Address, City) VALUES (1, "Simpson", "Bart", "Av.Siempre Viva", "Iquique");

SELECT * FROM Persons;

# Alterar la tabla personas para modificar la columna de ids, para hacerlos autoincrementables.
ALTER TABLE Persons MODIFY COLUMN PersonID INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
UPDATE Persons SET FirstName = "Homero", LastName = "Simpson" WHERE PersonID=1;
# Verificar si existe un ID.
SELECT COUNT(1) FROM Persons WHERE PersonID=4;
INSERT INTO Persons (LastName, FirstName, Address, City) VALUES ("Vidal", "Arturo", "Av. Heroes de la Concepcion", "IQQ");