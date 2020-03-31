/*	Author: Niroshan Kumarasinghe 	
	IIT Student No: IIT2019269
	RGU Student No: RGU1912833
	Course: CMM702 Advanced Databases
	Assignment: COURSEWORK PART A
	Question: Number 05
	Description: Implement a distributed relational database environment 
*/

--------------------------------- CONFIGURATION ---------------------------------

-- Define databases addresses for establishing connections
-- Update tnsnames.ora file

-- Aberdeen site  
ABERDEEN_REMOTE =
  (DESCRIPTION=
    (ADDRESS=
	   (PROTOCOL=TCP)
	   (HOST=aberdeen-remote-site-db.cl3owxxdu7ya.ap-southeast-1.rds.amazonaws.com)
	   (PORT=1521))
    (CONNECT_DATA=
	   (SERVICE_NAME=ORCL))
    )
  ) 

--------------------------------- CREATE DB LINK ---------------------------------

-- Create database links to establish a connection with the remote site(s)

-- Connect local database - london.spaceformance.com
CONNECT system/orcl;

-- Site 02 - Aberdeen
CREATE DATABASE LINK aberdeen.spaceformance.com CONNECT TO "ADMIN" IDENTIFIED BY "Kasuk123"
USING 'ABERDEEN_REMOTE';

--------------------------------- CREATE FRAGMENTS ---------------------------------

/*
	01. Horizontal Fragmentation
	Fragments divide by venue
	Fragment 01 in london site and fragment 02 in aberdeen site
*/

-- Create fragment 01 - London site (local)
-- Naming convension (Venue - London)
CREATE TABLE London_Staff_tab (
	StaffId NUMBER NOT NULL PRIMARY KEY,
	Name VARCHAR2(100) NOT NULL,
	DateOfBirth DATE NOT NULL,
	Salary NUMBER(8,2) NOT NULL,
	Venue VARCHAR2(50) NOT NULL,
	HireDate DATE NOT NULL
);
/

-- Insert data into london site
INSERT INTO London_Staff_tab VALUES 
	(2,'Willian Gill', '14 MAR 1977', 45000.00, 'London', '12 MAR 2018');
INSERT INTO London_Staff_tab VALUES 
	(5,'Johnathan Paula', '21 OCT 1991', 23004.30, 'London', '23 FEB 2020');
INSERT INTO London_Staff_tab VALUES 
	(8,'Hendrick Aliws', '04 APR 1971',23499.99, 'London', '12 JAN 2003');
INSERT INTO London_Staff_tab VALUES 
	(9,'Clian Takk', '23 MAR 1991', 12999.32, 'London', '01 OCT 2012');
INSERT INTO London_Staff_tab VALUES 
	(10,'Riyan Drwan', '04 JUN 1982', 11000.00, 'London', '07 DEC 2011');
/

-- View london staff table
SELECT * FROM London_Staff_tab;
/

-- Connect to aberdeen remote site
CONNECT ADMIN/Kasuk123@aberdeen-remote-site-db.cl3owxxdu7ya.ap-southeast-1.rds.amazonaws.com/ORCL;

-- Create fragment 02 - Aberdeen (remote)
-- Specific venue naming convension (Aberdeen)
CREATE TABLE Aberdeen_Staff_tab (
	StaffId NUMBER NOT NULL PRIMARY KEY,
	Name VARCHAR2(100) NOT NULL,
	DateOfBirth DATE NOT NULL,
	Salary NUMBER(8,2) NOT NULL,
	Venue VARCHAR2(50) NOT NULL,
	HireDate DATE NOT NULL
);
/

-- Insert data for aberdeen site
INSERT INTO Aberdeen_Staff_tab VALUES (1,'Rick Jason', '04 APR 1994', 23000.00, 'Aberdeen', '04 APR 2019');
INSERT INTO Aberdeen_Staff_tab VALUES (3,'Brian Mack', '25 FEB 1989', 34000.00, 'Aberdeen', '11 SEP 2016');
INSERT INTO Aberdeen_Staff_tab VALUES (4,'Andrew Osek', '11 JAN 1968',43400.00, 'Aberdeen', '15 JUN 2018');
INSERT INTO Aberdeen_Staff_tab VALUES (7,'Chrish Gill', '15 SEP 1992', 78499.43, 'Aberdeen', '26 APR 2015');
/

-- Grant permission
GRANT SELECT ON Aberdeen_Staff_tab TO PUBLIC;
/

-- Maintain location transparency by assigning synonym to aberdeen fragment.
CREATE SYNONYM Aberdeen_Staff_tab FOR Aberdeen_Staff_tab@aberdeen.spaceformance.com;
/

-- View aberdeen staff synonym
SELECT * FROM Aberdeen_Staff_tab;
/

-- Create a VIEW which preserves fragmentation,location transparency 
-- which displays the global staff members distributed across multiple sites

-- Select London local fragment table and aberdeen synonym
CREATE VIEW Staff_tab AS
	(SELECT * FROM London_Staff_tab)
	UNION
	(SELECT * FROM Aberdeen_Staff_tab);
/

-- Visualise the view
SELECT * FROM Staff_tab;
/

-- Drop session;
DROP VIEW Staff_tab;
DROP SYNONYM Aberdeen_Staff_tab;
DROP TABLE London_Staff_tab;
/

CONNECT ADMIN/Kasuk123@aberdeen-remote-site-db.cl3owxxdu7ya.ap-southeast-1.rds.amazonaws.com/ORCL;
DROP TABLE Aberdeen_Staff_tab;
/

/*
	02. Vertical Fragmentation
	Fragments divide by columns
	Fragment 01 - Name, DateOfBirth 
	Fragment 02 - Salary, Venue, HireDate
*/

-- Create fragment 01 - London site (local)
-- vertically divided by spliting the columns (Name and DateOfBirth into London site)
CREATE TABLE Staff_tab_01 (
	StaffId NUMBER NOT NULL PRIMARY KEY,
	Name VARCHAR2(100) NOT NULL,
	DateOfBirth DATE NOT NULL
);
/

-- Insert data for london site
INSERT INTO Staff_tab_01 VALUES (2,'Willian Gill', '14 MAR 1977');
INSERT INTO Staff_tab_01 VALUES (5,'Johnathan Paula', '21 OCT 1991');
INSERT INTO Staff_tab_01 VALUES (8,'Hendrick Aliws', '04 APR 1971');
INSERT INTO Staff_tab_01 VALUES (9,'Clian Takk', '23 MAR 1991');
INSERT INTO Staff_tab_01 VALUES (10,'Riyan Drwan', '04 JUN 1982');
/

-- View london staff table
SELECT * FROM Staff_tab_01;
/

-- Connect to aberdeen remote
CONNECT ADMIN/Kasuk123@aberdeen-remote-site-db.cl3owxxdu7ya.ap-southeast-1.rds.amazonaws.com/ORCL
/

-- Create fragment 02 - Aberdeen
-- vertically divided by spliting the columns (Salary, Venue and HireDate into Aberdeen site)
CREATE TABLE Staff_tab_02 (
	StaffId NUMBER NOT NULL PRIMARY KEY,
	Salary NUMBER(8,2) NOT NULL,
	Venue VARCHAR2(50) NOT NULL,
	HireDate DATE NOT NULL
);
/

-- Insert data for aberdeen site
INSERT INTO Staff_tab_02 VALUES (2, 45000.00, 'London', '12 MAR 2018');
INSERT INTO Staff_tab_02 VALUES (5, 23004.30, 'London', '23 FEB 2020');
INSERT INTO Staff_tab_02 VALUES (8, 23499.99, 'London', '12 JAN 2003');
INSERT INTO Staff_tab_02 VALUES (9, 12999.32, 'London', '01 OCT 2012');
INSERT INTO Staff_tab_02 VALUES (10, 11000.00, 'London', '07 DEC 2011');
/

-- Grant permission
GRANT SELECT ON Aberdeen_Staff_tab TO PUBLIC;
/

-- Maintain location transparency by assigning aliases to aberdeen fragment.
CREATE SYNONYM Staff_tab_02 FOR Staff_tab_02@aberdeen.spaceformance.com;
/

-- View aberdeen synonym
SELECT * FROM Staff_tab_02;
/


-- Create a VIEW which preserves fragmentation, location transparency 
-- which displays the global staff members distributed across multiple sites
CREATE VIEW Staff_tab AS
	SELECT 
		l.StaffId,
        l.Name, 
        l.DateOfBirth,
        a.Salary,
        a.Venue,
        a.HireDate
    FROM Staff_tab_01 l
	FULL OUTER JOIN Staff_tab_02 a
	ON l.StaffId = a.StaffId;
/

-- Visualise the view
SELECT * FROM Staff_tab;
/

-- Drop sessions
DROP VIEW Staff_tab;
DROP SYNONYM Staff_tab_02;
DROP TABLE Staff_tab_02;
/
CONNECT ADMIN/Kasuk123@aberdeen-remote-site-db.cl3owxxdu7ya.ap-southeast-1.rds.amazonaws.com/ORCL;
DROP TABLE Staff_tab_02;
/

-- Drop links
DROP DATABASE LINK aberdeen.spaceformance.com;
/






