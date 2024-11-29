CREATE DATABASE SegundoParcialFinal;
USE SegundoParcialFinal;

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


CREATE TABLE dimDestino (
    idDestino INT PRIMARY KEY,
    pais VARCHAR(100),
    ciudad VARCHAR(100),
    aeropuerto VARCHAR(255)
);

CREATE TABLE factVuelo (
    idAerolinea INT,
    idTiempo NVARCHAR(50),
    idRol INT,
    idModelo INT,
	idDestino INT,
	idTripulacion INT,
    horasVuelo int,
	vuelo int,
    PRIMARY KEY (idAerolinea, idTiempo, idRol, idModelo, idTripulacion, idDestino),
    
    FOREIGN KEY (idAerolinea) REFERENCES dimAerolinea(idAerolinea),
    FOREIGN KEY (idTiempo) REFERENCES dimTiempo(idTiempo),
    FOREIGN KEY (idRol) REFERENCES dimRol(idRol),
    FOREIGN KEY (idModelo) REFERENCES dimModelo(idModelo),
	FOREIGN KEY (idTripulacion) REFERENCES dimTripulacion(idCrew), 
	FOREIGN KEY (idDestino) REFERENCES dimDestino(idDestino)
);



EXEC sp_rename 'factCrew', 'factVuelo';

Truncate table factCrew


ALTER TABLE factVuelo
add vuelo INT

ALTER COLUMN idTiempo NVARCHAR(50) PRIMARY KEY

EXEC sp_rename 'dimCrew', 'dimTripulacion';
select * from factVuelo


drop table factVuelo
drop table dimTripulacion

select * from dimAerolinea
select * from dimTripulacion


truncate table factVuelo
