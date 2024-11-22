SELECT id AS id, name AS aerolinea
FROM airline AS origen
WHERE NOT EXISTS (
    SELECT 1 
    FROM PrimerCubo.dbo.dimAerolinea AS dest
    WHERE dest.idAerolinea = origen.id
)

SELECT airport.id, airport.name AS aeropuerto, city.name AS ciudad, country.name AS pais
FROM airport
INNER JOIN city ON airport.id_city = city.id
INNER JOIN country ON city.id_country = country.id
WHERE NOT EXISTS (
    SELECT 1
    FROM PrimerCubo.dbo.dimDestino AS dest
    WHERE dest.idDestino = airport.id
)

SELECT airport.id, airport.name AS aeropuerto, city.name AS ciudad, country.name AS pais
FROM     airport INNER JOIN
                  city ON airport.id_city = city.id INNER JOIN
                  country ON city.id_country = country.id



SELECT 
    id AS id,           
    YEAR(flight_date) AS year, 
    MONTH(flight_date) AS month,
    DAY(flight_date) AS day    
FROM 
    flight;

SELECT 
    id AS idModelo, 
    description 
FROM 
    plane_model
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM PrimerCubo.dbo.dimModelo AS dest
        WHERE dest.idModelo = plane_model.id
    );

SELECT 
    id AS idTiempo,           
    YEAR(flight_date) AS year, 
    MONTH(flight_date) AS month,
    DAY(flight_date) AS day    
FROM 
    flight
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM PrimerCubo.dbo.dimTiempo AS dest
        WHERE dest.idTiempo = flight.id
    );


SELECT 
    f.id AS idFecha, 
    fn.id_airport_goal AS idDestino, 
    fn.id_airline AS idAerolinea, 
    a.id_plane_model AS idAvion, 
    DATEDIFF(HOUR, fn.departure_time, fn.arrival_time) AS horas_de_vuelo
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
JOIN 
    airplane a ON f.id_airplane = a.id
JOIN 
    plane_model pm ON a.id_plane_model = pm.id;


SELECT 
    f.id AS idFecha, 
    rf.id AS idRol,  -- Ahora obtenemos el id del rol desde role_flight
    fn.id_airline AS idAerolinea, 
    a.id_plane_model AS idAvion, 
    DATEDIFF(HOUR, fn.departure_time, fn.arrival_time) AS horas_de_vuelo
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
JOIN 
    airplane a ON f.id_airplane = a.id
JOIN 
    plane_model pm ON a.id_plane_model = pm.id
JOIN
    flight_crew_role fcr ON f.id = fcr.id_flight  
JOIN
    role_flight rf ON fcr.id_role = rf.id;  


--- opcion dos
-- Tuplas para vuelos que ocurren en un solo d�a
SELECT 
    f.id AS idFecha, 
    rf.id AS idRol, 
    fn.id_airline AS idAerolinea, 
    a.id_plane_model AS idAvion, 
    f.flight_date AS fechaVuelo,
    DATEDIFF(HOUR, fn.departure_time, fn.arrival_time) AS horas_de_vuelo
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
JOIN 
    airplane a ON f.id_airplane = a.id
JOIN 
    plane_model pm ON a.id_plane_model = pm.id
JOIN
    flight_crew_role fcr ON f.id = fcr.id_flight  
JOIN
    role_flight rf ON fcr.id_role = rf.id
WHERE 
    CAST(fn.arrival_time AS DATETIME) <= DATEADD(DAY, 1, f.flight_date)  -- El vuelo termina el mismo d�a o antes

UNION ALL

-- Tuplas para vuelos que abarcan dos d�as
SELECT 
    f.id AS idFecha, 
    rf.id AS idRol, 
    fn.id_airline AS idAerolinea, 
    a.id_plane_model AS idAvion, 
    f.flight_date AS fechaVuelo,
    DATEDIFF(HOUR, fn.departure_time, CAST(f.flight_date AS DATETIME) + 1) AS horas_de_vuelo
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
JOIN 
    airplane a ON f.id_airplane = a.id
JOIN 
    plane_model pm ON a.id_plane_model = pm.id
JOIN
    flight_crew_role fcr ON f.id = fcr.id_flight  
JOIN
    role_flight rf ON fcr.id_role = rf.id
WHERE 
    CAST(fn.arrival_time AS DATETIME) > DATEADD(DAY, 1, f.flight_date);

------

	-- Tuplas para vuelos que ocurren en un solo d�a OPCION FINAL
-- Tuplas para vuelos que ocurren en un solo d�a
SELECT 
    f.id AS idFecha, 
    rf.id AS idRol, 
    fn.id_airline AS idAerolinea, 
    a.id_plane_model AS idAvion, 
    f.flight_date AS fechaVuelo,
    fn.departure_time AS hora_partida,
    fn.arrival_time AS hora_llegada,
    fn.arrival_date AS fecha_llegada,
    DATEDIFF(HOUR, fn.departure_time, fn.arrival_time) AS horas_de_vuelo
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
JOIN 
    airplane a ON f.id_airplane = a.id
JOIN 
    plane_model pm ON a.id_plane_model = pm.id
JOIN
    flight_crew_role fcr ON f.id = fcr.id_flight  
JOIN
    role_flight rf ON fcr.id_role = rf.id
WHERE 
    fn.arrival_date = f.flight_date -- El vuelo llega el mismo d�a

UNION ALL

-- Tuplas para vuelos que abarcan dos d�as (d�a de salida)
SELECT 
    f.id AS idFecha, 
    rf.id AS idRol, 
    fn.id_airline AS idAerolinea, 
    a.id_plane_model AS idAvion, 
    f.flight_date AS fechaVuelo,
    fn.departure_time AS hora_partida,
    '23:59:59' AS hora_llegada,  -- �ltima hora del d�a de salida
    f.flight_date AS fecha_llegada, -- Mismo d�a para esta parte
    DATEDIFF(HOUR, fn.departure_time, '23:59:59') AS horas_de_vuelo
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
JOIN 
    airplane a ON f.id_airplane = a.id
JOIN 
    plane_model pm ON a.id_plane_model = pm.id
JOIN
    flight_crew_role fcr ON f.id = fcr.id_flight  
JOIN
    role_flight rf ON fcr.id_role = rf.id
WHERE 
    fn.arrival_date > f.flight_date -- El vuelo llega al d�a siguiente

UNION ALL

-- Tuplas para vuelos que abarcan dos d�as (d�a de llegada)
SELECT 
    fn.id AS idFecha, 
    rf.id AS idRol, 
    fn.id_airline AS idAerolinea, 
    a.id_plane_model AS idAvion, 
    fn.arrival_date AS fechaVuelo, -- D�a de llegada
    '00:00:00' AS hora_partida, -- Primer momento del d�a de llegada
    fn.arrival_time AS hora_llegada,
    fn.arrival_date AS fecha_llegada,
    DATEDIFF(HOUR, '00:00:00', fn.arrival_time) AS horas_de_vuelo
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
JOIN 
    airplane a ON f.id_airplane = a.id
JOIN 
    plane_model pm ON a.id_plane_model = pm.id
JOIN
    flight_crew_role fcr ON f.id = fcr.id_flight  
JOIN
    role_flight rf ON fcr.id_role = rf.id
WHERE 
    fn.arrival_date > f.flight_date -- El vuelo llega al d�a siguiente



------------------------------ CODIGO FINAL--------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------

-- Tuplas para vuelos que ocurren en un solo d�a
SELECT 
    f.id AS idFecha, 
    rf.id AS idRol, 
    fn.id_airline AS idAerolinea, 
    a.id_plane_model AS idAvion, 
    DATEDIFF(HOUR, fn.departure_time, fn.arrival_time) AS horas_de_vuelo,
    fc.id AS idTripulacion -- A�adido el id de la tripulaci�n
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
JOIN 
    airplane a ON f.id_airplane = a.id
JOIN 
    plane_model pm ON a.id_plane_model = pm.id
JOIN
    flight_crew_role fcr ON f.id = fcr.id_flight  
JOIN
    role_flight rf ON fcr.id_role = rf.id
JOIN
    flight_crew fc ON fcr.id_flight_crew = fc.id  -- A�adido el JOIN con flight_crew
WHERE 
    fn.arrival_date = f.flight_date -- El vuelo llega el mismo d�a
    AND NOT EXISTS (
        SELECT 1 
        FROM SegundoParcial.dbo.factVuelo fc
        WHERE fc.idTiempo = f.id 
          AND fc.idRol = rf.id 
          AND fc.idAerolinea = fn.id_airline 
          AND fc.idModelo = a.id_plane_model
    )

UNION ALL

-- Tuplas para vuelos que abarcan dos d�as (d�a de salida)
SELECT 
    f.id AS idFecha, 
    rf.id AS idRol, 
    fn.id_airline AS idAerolinea, 
    a.id_plane_model AS idAvion, 
    DATEDIFF(HOUR, fn.departure_time, '23:59:59') AS horas_de_vuelo,
    fc.id AS idTripulacion -- A�adido el id de la tripulaci�n
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
JOIN 
    airplane a ON f.id_airplane = a.id
JOIN 
    plane_model pm ON a.id_plane_model = pm.id
JOIN
    flight_crew_role fcr ON f.id = fcr.id_flight  
JOIN
    role_flight rf ON fcr.id_role = rf.id
JOIN
    flight_crew fc ON fcr.id_flight_crew = fc.id   -- A�adido el JOIN con flight_crew
WHERE 
    fn.arrival_date > f.flight_date -- El vuelo llega al d�a siguiente
    AND NOT EXISTS (
        SELECT 1 
        FROM SegundoParcial.dbo.factVuelo fc
        WHERE fc.idTiempo = f.id 
          AND fc.idRol = rf.id 
          AND fc.idAerolinea = fn.id_airline 
          AND fc.idModelo = a.id_plane_model
    )

UNION ALL

-- Tuplas para vuelos que abarcan dos d�as (d�a de llegada)
SELECT 
    f.id AS idFecha, 
    rf.id AS idRol, 
    fn.id_airline AS idAerolinea, 
    a.id_plane_model AS idAvion, 
    DATEDIFF(HOUR, '00:00:00', fn.arrival_time) AS horas_de_vuelo,
    fc.id AS idTripulacion -- A�adido el id de la tripulaci�n
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
JOIN 
    airplane a ON f.id_airplane = a.id
JOIN 
    plane_model pm ON a.id_plane_model = pm.id
JOIN
    flight_crew_role fcr ON f.id = fcr.id_flight  
JOIN
    role_flight rf ON fcr.id_role = rf.id
JOIN
    flight_crew fc ON fcr.id_flight_crew = fc.id   -- A�adido el JOIN con flight_crew
WHERE 
    fn.arrival_date > f.flight_date -- El vuelo llega al d�a siguiente
    AND NOT EXISTS (
        SELECT 1 
        FROM SegundoParcial.dbo.factVuelo fc
        WHERE fc.idTiempo = f.id 
          AND fc.idRol = rf.id 
          AND fc.idAerolinea = fn.id_airline 
          AND fc.idModelo = a.id_plane_model
    );



---Tripulacion
SELECT 
    fc.id AS idCrew, 
    CONCAT(p.name, ' ', p.last_name) AS nombre
FROM 
    flight_crew fc
INNER JOIN 
    person p ON fc.id_person = p.id
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM SegundoParcial.dbo.dimTripulacion dt
        WHERE dt.idCrew = fc.id
    );

SELECT id AS idRol, name
FROM role_flight rf
WHERE NOT EXISTS (
    SELECT 1
    FROM SegundoParcial.dbo.dimRol dr
    WHERE dr.idRol = rf.id
);


SELECT 
    id AS idTiempo,           
    YEAR(flight_date) AS year, 
    MONTH(flight_date) AS month,
    DAY(flight_date) AS day    
FROM 
    flight
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM SegundoParcial.dbo.dimTiempo AS dest
        WHERE dest.idTiempo = flight.id
    );
------------
------------------------------------------------------
SELECT 
    id AS idTiempo,           
    YEAR(flight_date) AS year, 
    MONTH(flight_date) AS month,
    DAY(flight_date) AS day    
FROM 
    flight

-- Tuplas originales para flight_date
UNION ALL

-- Tuplas adicionales para arrival_date cuando son diferentes de flight_date
SELECT 
    f.id AS idTiempo,           
    YEAR(fn.arrival_date) AS year, 
    MONTH(fn.arrival_date) AS month,
    DAY(fn.arrival_date) AS day    
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
WHERE 
    f.flight_date <> fn.arrival_date; -- Solo si las fechas son diferentes


----
-------------------------
-- Tuplas originales para flight_date
SELECT 
    CAST(f.id AS NVARCHAR) + '-1' AS idTiempo, -- ID original con sufijo '-1'
    YEAR(f.flight_date) AS year, 
    MONTH(f.flight_date) AS month,
    DAY(f.flight_date) AS day    
FROM 
    flight f
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM SegundoParcial.dbo.dimTiempo dt
        WHERE dt.idTiempo = CAST(f.id AS NVARCHAR) + '-1'
    )

UNION ALL

-- Tuplas adicionales para arrival_date cuando son diferentes de flight_date
SELECT 
    CAST(f.id AS NVARCHAR) + '-2' AS idTiempo, -- ID original con sufijo '-2'
    YEAR(fn.arrival_date) AS year, 
    MONTH(fn.arrival_date) AS month,
    DAY(fn.arrival_date) AS day    
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
WHERE 
    f.flight_date <> fn.arrival_date -- Solo si las fechas son diferentes
    AND NOT EXISTS (
        SELECT 1 
        FROM SegundoParcial.dbo.dimTiempo dt
        WHERE dt.idTiempo = CAST(f.id AS NVARCHAR) + '-2'
    );







-- Tuplas para vuelos que ocurren en un solo d�a
SELECT 
    CAST(f.id AS NVARCHAR) + '-1' AS idTiempo, -- Sufijo �nico '-1' para vuelos en un solo d�a
    rf.id AS idRol, 
    fn.id_airline AS idAerolinea, 
    a.id_plane_model AS idAvion, 
	fc.id AS idTripulacion, -- A�adido el id de la tripulaci�n
    DATEDIFF(HOUR, fn.departure_time, fn.arrival_time) AS horas_de_vuelo
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
JOIN 
    airplane a ON f.id_airplane = a.id
JOIN 
    plane_model pm ON a.id_plane_model = pm.id
JOIN
    flight_crew_role fcr ON f.id = fcr.id_flight  
JOIN
    role_flight rf ON fcr.id_role = rf.id
JOIN
    flight_crew fc ON fcr.id_flight_crew = fc.id 
WHERE 
    fn.arrival_date = f.flight_date -- El vuelo llega el mismo d�a
	AND NOT EXISTS (
        SELECT 1 
        FROM SegundoParcial.dbo.factVuelo fc
        WHERE fc.idTiempo = idTiempo 
          AND fc.idRol = rf.id 
          AND fc.idAerolinea = fn.id_airline 
          AND fc.idModelo = a.id_plane_model
    )

UNION ALL

-- Tuplas para vuelos que abarcan dos d�as (d�a de salida)
SELECT 
    CAST(f.id AS NVARCHAR) + '-1' AS idTiempo, -- Sufijo �nico '-2' para el d�a de salida
    rf.id AS idRol, 
    fn.id_airline AS idAerolinea, 
    a.id_plane_model AS idAvion,
	fc.id AS idTripulacion, 
    DATEDIFF(HOUR, fn.departure_time, '23:59:59') AS horas_de_vuelo
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
JOIN 
    airplane a ON f.id_airplane = a.id
JOIN 
    plane_model pm ON a.id_plane_model = pm.id
JOIN
    flight_crew_role fcr ON f.id = fcr.id_flight  
JOIN
    role_flight rf ON fcr.id_role = rf.id
JOIN
    flight_crew fc ON fcr.id_flight_crew = fc.id 
WHERE 
    fn.arrival_date > f.flight_date -- El vuelo llega al d�a siguiente
	AND NOT EXISTS (
        SELECT 1 
        FROM SegundoParcial.dbo.factVuelo fc
        WHERE fc.idTiempo = idTiempo 
          AND fc.idRol = rf.id 
          AND fc.idAerolinea = fn.id_airline 
          AND fc.idModelo = a.id_plane_model
    )

UNION ALL

-- Tuplas para vuelos que abarcan dos d�as (d�a de llegada)
SELECT 
    CAST(f.id AS NVARCHAR) + '-2' AS idTiempo, -- Sufijo �nico '-3' para el d�a de llegada
    rf.id AS idRol, 
    fn.id_airline AS idAerolinea, 
    a.id_plane_model AS idAvion, 
	fc.id AS idTripulacion,
    DATEDIFF(HOUR, '00:00:00', fn.arrival_time) AS horas_de_vuelo
FROM 
    flight f
JOIN 
    flight_number fn ON f.id_flight_number = fn.id
JOIN 
    airplane a ON f.id_airplane = a.id
JOIN 
    plane_model pm ON a.id_plane_model = pm.id
JOIN
    flight_crew_role fcr ON f.id = fcr.id_flight  
JOIN
    role_flight rf ON fcr.id_role = rf.id
JOIN
    flight_crew fc ON fcr.id_flight_crew = fc.id 
WHERE 
    fn.arrival_date > f.flight_date -- El vuelo llega al d�a siguiente
	AND NOT EXISTS (
        SELECT 1 
        FROM SegundoParcial.dbo.factVuelo fc
        WHERE fc.idTiempo = idTiempo 
          AND fc.idRol = rf.id 
          AND fc.idAerolinea = fn.id_airline 
          AND fc.idModelo = a.id_plane_model
    )
