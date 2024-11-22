CREATE DATABASE SegundoParcial;
USE SegundoParcial;

CREATE TABLE dimRol (
    idRol INT PRIMARY KEY,
    nombre VARCHAR(50)
);

CREATE TABLE dimAerolinea (
    idAerolinea INT PRIMARY KEY,
    [name] char(255)
);

CREATE TABLE dimModelo (
    idModelo INT PRIMARY KEY,
    descripcion VARCHAR(255)
);

CREATE TABLE dimTiempo (
    idTiempo NVARCHAR(50) PRIMARY KEY,
    año INT,
    mes INT,
	dia INT
);

CREATE TABLE dimTripulacion (
	idCrew INT PRIMARY KEY,
	nombre VARCHAR(101)
)

CREATE TABLE factVuelo (
    idAerolinea INT,
    idTiempo NVARCHAR(50),
    idRol INT,
    idModelo INT,
	idTripulacion INT,
    horasVuelo int,
    PRIMARY KEY (idAerolinea, idTiempo, idRol, idModelo, idTripulacion),
    
    FOREIGN KEY (idAerolinea) REFERENCES dimAerolinea(idAerolinea),
    FOREIGN KEY (idTiempo) REFERENCES dimTiempo(idTiempo),
    FOREIGN KEY (idRol) REFERENCES dimRol(idRol),
    FOREIGN KEY (idModelo) REFERENCES dimModelo(idModelo),
	FOREIGN KEY (idTripulacion) REFERENCES dimTripulacion(idCrew)
);

EXEC sp_rename 'factCrew', 'factVuelo';

Truncate table factCrew


ALTER TABLE dimTiempo
ALTER COLUMN idTiempo NVARCHAR(50) PRIMARY KEY

EXEC sp_rename 'dimCrew', 'dimTripulacion';
select * from factVuelo


select * from dimAerolinea
select * from dimTripulacion
