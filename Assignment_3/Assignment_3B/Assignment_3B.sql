CREATE TABLE Ships_Staging (
	ShipName Varchar (500),
	ShipType Varchar (500),
	Nationality Varchar (500));


SELECT * FROM Ships_Staging;

SELECT * FROM trips_staging;

-- Question 4:

--- Count Rows for Trips_Staging
SELECT Count(*) as Number_Rows
From trips_staging;
--- Count Rows for Ships_Staging
SELECT Count(*) as Number_Rows_S
From Ships_staging;

---- Question 5:

SELECT ShipName, ShipType, nationality
From Ships_staging
Group by ShipName, ShipType, Nationality; 
---

--- Question 6:

SELECT ShipName, ShipType, Nationality
FROM Trips_staging
EXCEPT
SELECT ShipName, ShipType, Nationality
FROM ships_staging
Group by ShipName, ShipType, Nationality
--
--
/*SELECT Distinct Trip.ShipName, Trip.ShipType, Trip.Nationality
FROM Trips_staging as Trip
WHERE ( Trip.ShipName, Trip.ShipType, Trip.Nationality) NOT IN (
    SELECT ShipName, ShipType, Nationality
    FROM ships_staging)*/


-- Question 7

(SELECT ShipName, ShipType, nationality
From Ships_staging
Group by ShipName, ShipType, Nationality)
UNION
(SELECT ShipName, ShipType, Nationality
FROM Trips_staging
EXCEPT
SELECT ShipName, ShipType, Nationality
FROM ships_staging
Group by ShipName, ShipType, Nationality);
---
DROP TABLE DimShipSQL;


-- Question 8
CREATE TABLE DimShipSQL (
	DimShipID Serial PRIMARY KEY,
	ShipName	Varchar (500),
	ShipType	Varchar (500),
	Nationality	Varchar (500)
);

SELECT * From Ship_Distinct;


----- Create a Ship_Distinct View
CREATE VIEW Ship_Distinct AS
(SELECT ShipName, ShipType, nationality
From Ships_staging
Group by ShipName, ShipType, Nationality)
UNION
(SELECT ShipName, ShipType, Nationality
FROM Trips_staging
EXCEPT
SELECT ShipName, ShipType, Nationality
FROM ships_staging
Group by ShipName, ShipType, Nationality)
------
----Question 9

INSERT INTO DimShipSQL(ShipName, shiptype, nationality)
SELECT Ship_Distinct.ShipName, Ship_Distinct.Shiptype, Ship_Distinct.Nationality
From Ship_Distinct;

SELECT * FROM DimShipSQL;

SELECT Count(*) As Number_rows
From DimShipSQL;

---- Question 11

CREATE TABLE TripFactSQL (
	TripFactSQL Serial PRIMARY KEY,
	DimShipID Int NOT NULL,
	TripRecID Int,
	TripDate Date,
	Distance Int,
	ShipSpeed Int,
	drLatDeg Int,
	Constraint fk_DimShip
	Foreign Key (DimShipID)
	References DimShipSQL(DimShipID));

DROP Table tripfactsql;
Select * from tripfactsql

Select * From trips_staging 


---- Question 12
/*When join If some records in the "Trips_Staging" table have NULL values in either the "ShipName", "shiptype", or "nationality" columns, 
----then those records will not be returned by the JOIN clause in your query
-----Old------
Select Trip.RecID as TripRecID, Trip.RecID, Ship.DimShipID, Trip.Year, 
		Trip.Month, Trip.Day, Trip.Distance, Trip.Shipspeed, Trip.drlatdeg
From Trips_Staging Trip
JOIN DimShipSQL Ship On Trip.ShipName = Ship.shipname
						And Trip.shiptype = Ship.shiptype
						AND Trip.nationality = Ship.nationality	*/

-------New-----
---------------
Select Trip.RecID as TripRecID, Trip.RecID, Ship.DimShipID, Trip.Year, 
		Trip.Month, Trip.Day, Trip.Distance, Trip.Shipspeed, Trip.drlatdeg
From Trips_Staging Trip
JOIN DimShipSQL Ship 	ON coalesce(Ship.nationality,'') = coalesce(Trip.nationality,'')
						AND COALESCE(Ship.shipname,'') = COALESCE(Trip.shipname,'')
						AND COALESCE(Ship.shiptype,'') = COALESCE(Trip.shiptype,'')
						
select count(*) number_rows from Trips_staging;

----- Question 13
--- Create TripShip_Views
CREATE VIEW TripShips_View AS
Select Trip.RecID as TripRecID, Trip.RecID, Ship.DimShipID, Trip.Year, 
		Trip.Month, Trip.Day, Trip.Distance, Trip.Shipspeed, Trip.drlatdeg
From Trips_Staging Trip
JOIN DimShipSQL Ship 	ON coalesce(Ship.nationality,'') = coalesce(Trip.nationality,'')
						AND COALESCE(Ship.shipname,'') = COALESCE(Trip.shipname,'')
						AND COALESCE(Ship.shiptype,'') = COALESCE(Trip.shiptype,'')

-------
------
-- Create Function to handle invalid date like 28 Feb, 1850-11-31
Create or REPLACE function date_transform (str text, format text)
returns date as 
$$
begin 
	return to_date(str,format);
exception
	When OTHERS then return null;
end;
$$ language plpgsql;

------

---- Create view TripShip_date_transformed
CREATE VIEW TripShip_date_transformed As
SELECT DimShipId,TripRecID,RecID,Year,Month,Day,Distance,Shipspeed,drlatdeg,
    CASE WHEN Year IS NOT NULL AND Month IS NOT NULL AND Day IS NOT NULL THEN
                date_transform(CONCAT(Year, '-', Month, '-', Day), 'YYYY-MM-DD')
        ELSE NULL
    END AS TripDate
FROM Tripships_view

SELECT Recid, YEAR, MONTH, DAY, TripDate
FROM TripShip_date_transformed
where recid >107

---------- 
SELECT *
FROM TripShip_date_transformed
where year = 1850 and day = 31;

--------- Question 14

INSERT INTO TripFactSQL(dimshipid,triprecid,tripdate,distance,shipspeed,drlatdeg)
SELECT TripShip_date_transformed.dimshipid, TripShip_date_transformed.triprecid, 
		TripShip_date_transformed.tripdate, TripShip_date_transformed.distance,
		TripShip_date_transformed.shipspeed, TripShip_date_transformed.drlatdeg
From TripShip_date_transformed;

----- Question 15
Select * from TripFactSQL;

Select Count(*) as number_rows from TripFactSQL;

----Extra Credit

Select * from Trips_staging_weather

Create table Dim_Weather (
	weather_id Serial Primary Key,
	weather varchar(500),
	windforce varchar (500),
	winddirection varchar (500),
	precipitationdescription varchar (1000)
)

Select * from Dim_Weather;
------
Create VIEW Weather_distinct AS
Select weather, windforce, winddirection,precipitationdescriptor
From Trips_Staging_weather
Group By weather, windforce, winddirection,precipitationdescriptor;
----
Select * from weather_distinct;
--- Load Data into dim_weather
INSERT INTO dim_weather (weather, windforce, winddirection,precipitationdescription)
Select weather_distinct.weather, weather_distinct.windforce, weather_distinct.winddirection, weather_distinct.precipitationdescriptor
From weather_distinct;
----

CREATE View TripShip_Weather_load AS
Select TW.RecID As TripRecId, Ship.DimShipId, TW.distance, TW.shipspeed, TW.drlatdeg, 
	DW.weather_id, TW.weather,TW.winddirection, TW.windforce, TW.precipitationdescriptor, 
	TW.Year, TW.Month,TW.Day,
    CASE WHEN Year IS NOT NULL AND Month IS NOT NULL AND Day IS NOT NULL THEN
                date_transform(CONCAT(Year, '-', Month, '-', Day), 'YYYY-MM-DD')
        ELSE NULL
    END AS TripDate
From trips_staging_weather TW
Join DimShipSQL Ship ON coalesce(Ship.nationality,'') = coalesce(TW.nationality,'')
						AND COALESCE(Ship.shipname,'') = COALESCE(TW.shipname,'')
						AND COALESCE(Ship.shiptype,'') = COALESCE(TW.shiptype,'')
Join dim_weather DW on coalesce(DW.weather,'') = COALESCE(TW.weather,'')
					And coalesce(DW.winddirection,'') = coalesce(TW.winddirection,'')
					AND coalesce(DW.windforce,'') = coalesce(TW.windforce,'')
					AND COALESCE(DW.precipitationdescription,'') = COALESCE(TW.precipitationdescriptor,'')
					
select * from tripship_weather_load;				
--------
CREATE TABLE TripFact_WeatherSQL (
	TripFactSQL Serial PRIMARY KEY,
	DimShipID Int NOT NULL,
	Weather_id Int Not Null,
	TripRecID Int,
	TripDate Date,
	Distance Int,
	ShipSpeed Int,
	drLatDeg Int,
	Constraint fk_DimShip
	Foreign Key (DimShipID)
	References DimShipSQL(DimShipID),
	Constraint fk_dim_weather
	Foreign Key (weather_id)
	References dim_weather(weather_id)
);
-----Load 
INSERT INTO TripFact_WeatherSQL(dimshipid,weather_id,triprecid,tripdate,distance,shipspeed,drlatdeg)
SELECT TL.dimshipid, TL.weather_id,TL.triprecid, 
		TL.tripdate, TL.distance, TL.shipspeed, TL.drlatdeg
From tripship_weather_load TL;
-----
Select * from tripfact_weathersql
Select count(*) from tripfact_weathersql
						