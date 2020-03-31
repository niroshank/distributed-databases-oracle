/*	Author: Niroshan Kumarasinghe 	
	IIT Student No: IIT2019269
	RGU Student No: RGU1912833
	Course: CMM702 Advanced Databases
	Assignment: COURSEWORK PART A
	Question: Number 04
	Description: Creating Tables Under Object-Relational Model
*/

----------------------------------------------- OBJECT TYPES ------------------------------------------

/* 	**NOTE**
	To replace an incomplete type with a complete definition, 
	include the phrase OR REPLACE
	The clause NOT FINAL enables us to create subtypes of the 
	customer type later if we wish
*/

BEGIN -- Creating types

-- Membership types (VIP or Standard)
CREATE TYPE Membership_objtyp AS OBJECT (
	MembershipNo NUMBER,
	Name VARCHAR2(20),
	Description VARCHAR2(100)
) NOT FINAL;
/

-- Membership charges and discount can be changed yearly.
-- Consider only current active Membership Subscription when registering members
CREATE OR REPLACE TYPE MembershipSubscription_objtyp AS OBJECT (
	Id NUMBER,
	Membership_ref REF Membership_objtyp,
	Fee NUMBER,
	Discount NUMBER,
	IsActive CHAR(2),
	ValidFrom DATE,
	ValidTo DATE,
	CreatedDate DATE
) NOT FINAL;
/

-- Customer personal details and payment details
CREATE OR REPLACE TYPE Customer_objtyp AS OBJECT (
	Id NUMBER,
	Name NUMBER,
	DateOfBirth DATE,
	Address NVARCHAR2(200),
	PaymentMethod NVARCHAR2(100),
	CardNumber NUMBER,
	CardExpiredDate DATE
) NOT FINAL;
/

-- Customer must register first under any membership type.
-- Payment Status (Paid, Suspected, Expired)
CREATE OR REPLACE TYPE CustomerMembershipSubscription_objtyp AS OBJECT (
	Id NUMBER,
	Customer_ref REF Customer_objtyp,
	MembershipSubscription_ref REF MembershipSubscription_objtyp,
	PaymentStatus NVARCHAR2(20),
	UpdatedDate DATE,
	CreatedDate DATE
) NOT FINAL;
/

-- Membership payments and booking payments
-- AccountType (Subscription, Booking)
CREATE OR REPLACE TYPE CustomerPayment_objtyp AS OBJECT (
	Id NUMBER,
	Customer_ref REF Customer_objtyp,
	AccountType NVARCHAR2(100),
	Payment NUMBER(7,2),
	PaymentDate DATE
) NOT FINAL;
/

-- Venues (London, Aberdeen)
CREATE TYPE Venue_objtyp AS OBJECT (
	VenueNo NUMBER,
	Name VARCHAR2(50),
	Address VARCHAR2(200),
	Availability NUMBER,
	Capacity NUMBER,
	UpdatedDate DATE,
	CreatedDate DATE
) NOT FINAL;
/

-- Employees at specific venues
CREATE OR REPLACE TYPE Employee_objtyp AS OBJECT (
	Id NUMBER,
	Venue_ref REF Venue_objtyp,
	Name VARCHAR2(200)
) NOT FINAL;
/

-- Employees can be assign to reservation or event item (can be a singer)
CREATE OR REPLACE TYPE StaffAssignment_objtyp AS OBJECT (
	Id NUMBER,
	Employee_ref REF Employee_objtyp,
	AssignStartDateTime DATE,
	AssignEndDateTime DATE
) NOT FINAL;
/

-- Event Types (Concert, Play, Meal)
CREATE TYPE EventType_objtyp AS OBJECT (
	eventTypeNo NUMBER,
	eventType VARCHAR2(20),
	description VARCHAR2(100)	
) NOT FINAL;
/

-- Age Ratings (8 - 15, 18 - 45, 18 - 75)
CREATE TYPE AgeRating_objtyp AS OBJECT (
	AgeRatingNo NUMBER,
	AgeFrom NUMBER,
	AgeTo NUMBER
) NOT FINAL;
/

-- Element Types (Band Group, Catering Service, Cast Member, Singer, Actor)
CREATE TYPE ElementType_objtyp AS OBJECT (
	ElementTypeNo NUMBER,
	ElementType VARCHAR2(200),
	Description VARCHAR2(200)
) NOT FINAL;
/

-- Perfomr Elements (One Direction Band, Enrique)
CREATE OR REPLACE TYPE PerformElement_objtyp AS OBJECT (
	Id NUMBER,
	ElementType_ref REF ElementType_objtyp,
	Name VARCHAR2(200),
	Description VARCHAR2(200)
) NOT FINAL;
/

-- Event can be assigned to any event type (concert, play or meal)
-- Available tickets will be updated after every booking
CREATE OR REPLACE TYPE Event_objtyp AS OBJECT (
	Id NUMBER,
	Venue_ref REF Venue_objtyp,
	EventType_ref REF EventType_objtyp,
	AgeRating_ref REF AgeRating_objtyp,
	Name VARCHAR2(200),
	Description VARCHAR2(200),
	AvailableTickets NUMBER,
	StartDateTime DATE,
	EndDateTime DATE,
	UpdatedDate DATE,
	CreatedDate DATE	
) NOT FINAL;
/

-- Event Item can be assigned to any perform element (One Direction, enrique)
-- Separate payments for each any every event item
-- staff member can be assigned to a event item (enrique needs a staff support)
CREATE OR REPLACE TYPE EventItem_objtyp AS OBJECT (
	Id NUMBER,
	Event_ref REF Event_objtyp,
	PerformElement_ref REF PerformElement_objtyp,
	StaffAssignment_ref REF StaffAssignment_objtyp,
	Payment NUMBER,
	PaymentDate DATE,
	IsStaffAssigned CHAR(2)
) NOT FINAL;
/

-- staff member can be assigned to a reservation
CREATE OR REPLACE TYPE Reservation_objtyp AS OBJECT (
	ReservationNo NUMBER,
	Event_ref REF Event_objtyp,
	StaffAssignment_ref REF StaffAssignment_objtyp,
	NoOfTickets NUMBER,
	Charge NUMBER,
	IsStaffAssigned CHAR(2)			
) NOT FINAL;
/

-- Single booking can have one or more reservations
CREATE TYPE ReservationList_ntabtyp AS TABLE OF Reservation_objtyp;
/

-- total bookings can be calculated by summing event item payments
CREATE OR REPLACE TYPE Booking_objtyp AS OBJECT (
	BookingNo NUMBER,
	Customer_ref REF Customer_objtyp,
	CreatedDate DATE,
	ReservationList_ntab ReservationList_ntabtyp,
	TotalPayment NUMBER
) NOT FINAL;
/

END;

----------------------------------------------- TYPES BODY -----------------------------

/* 	**NOTE**
	If a type has no methods, its definition consists just of a 
	CREATE TYPE statement.
	For a type that has methods, you must also define a type body to 
	complete the definition of the type
*/


----------------------------------------------- OBJECT TABLES --------------------------

/* 	**NOTE**
	Creating a type merely defines a logical structure; it does not create storage
	For a type that has methods, you must also define a type 
	body to complete the definition of the type
	Each row in an object table is a single object instance
	OBJECT IDENTIFIER IS SYSTEM GENERATED - Default OID
*/

BEGIN -- Creating object tables

CREATE TABLE Membership_objtab OF Membership_objtyp (MembershipNo PRIMARY KEY) 
	OBJECT IDENTIFIER IS PRIMARY KEY;
/

CREATE TABLE Customer_objtab OF Customer_objtyp (Id PRIMARY KEY)
	OBJECT IDENTIFIER IS PRIMARY KEY;
/

CREATE TABLE EventType_objtab OF EventType_objtyp (eventTypeNo PRIMARY KEY)
	OBJECT IDENTIFIER IS PRIMARY KEY;
/
	
CREATE TABLE AgeRating_objtab OF AgeRating_objtyp (AgeRatingNo PRIMARY KEY)
	OBJECT IDENTIFIER IS PRIMARY KEY;
/

CREATE TABLE ElementType_objtab OF ElementType_objtyp (ElementTypeNo PRIMARY KEY)
	OBJECT IDENTIFIER IS PRIMARY KEY;
/

CREATE TABLE Venue_objtab OF Venue_objtyp (VenueNo PRIMARY KEY)
	OBJECT IDENTIFIER IS PRIMARY KEY;	
/
	
CREATE TABLE MembershipSubscription_objtab OF MembershipSubscription_objtyp (
	PRIMARY KEY (Id),
	FOREIGN KEY (Membership_ref) REFERENCES Membership_objtab)
	OBJECT IDENTIFIER IS PRIMARY KEY;
/

CREATE TABLE CustomerMembershipSubscription_objtab OF CustomerMembershipSubscription_objtyp	(
	PRIMARY KEY (Id),
	FOREIGN KEY (Customer_ref) REFERENCES Customer_objtab,
	FOREIGN KEY (MembershipSubscription_ref) REFERENCES MembershipSubscription_objtab)
	OBJECT IDENTIFIER IS PRIMARY KEY;

CREATE TABLE CustomerPayment_objtab OF CustomerPayment_objtyp (
	PRIMARY KEY (Id),
	FOREIGN KEY (Customer_ref) REFERENCES Customer_objtab)
	OBJECT IDENTIFIER IS PRIMARY KEY;
/

CREATE TABLE Employee_objtab OF Employee_objtyp (
	PRIMARY KEY (Id),
	FOREIGN KEY (Venue_ref) REFERENCES Venue_objtab)
	OBJECT IDENTIFIER IS PRIMARY KEY;
/ 

CREATE TABLE StaffAssignment_objtab OF StaffAssignment_objtyp (
	PRIMARY KEY (Id),
	FOREIGN KEY (Employee_ref) REFERENCES Employee_objtab)
	OBJECT IDENTIFIER IS PRIMARY KEY;
/

CREATE TABLE PerformElement_objtab OF PerformElement_objtyp (
	PRIMARY KEY (Id),
	FOREIGN KEY (ElementType_ref) REFERENCES ElementType_objtab)
	OBJECT IDENTIFIER IS PRIMARY KEY;
/

CREATE TABLE Event_objtab OF Event_objtyp (
	PRIMARY KEY (Id),
	FOREIGN KEY (EventType_ref) REFERENCES EventType_objtab,
	FOREIGN KEY (Venue_ref) REFERENCES Venue_objtab,
	FOREIGN KEY (AgeRating_ref) REFERENCES AgeRating_objtab)
	OBJECT IDENTIFIER IS PRIMARY KEY;
/ 

CREATE TABLE EventItem_objtab OF EventItem_objtyp (
	PRIMARY KEY (Id),
	FOREIGN KEY (Event_ref) REFERENCES Event_objtab,
	FOREIGN KEY (PerformElement_ref) REFERENCES PerformElement_objtab,
	FOREIGN KEY (StaffAssignment_ref) REFERENCES StaffAssignment_objtab)
	OBJECT IDENTIFIER IS PRIMARY KEY;
/

/* 	Following lines pertain to the storage specification and properties of the nested table column, 
	ReservationList_ntab. 
	The rows of a nested table are stored in a separate storage table. 
	This storage table cannot be directly queried by the user but can be referenced 
	in DDL statements for maintenance purposes. 
	A hidden column in the storage table, called the NESTED_TABLE_ID, matches the rows 
	with their corresponding parent row. 
	All the elements in the nested table belonging to a particular parent have the same 
	NESTED_TABLE_ID value. 
	For example, all the elements of the nested table of a given row of Booking_objtab 
	have the same value of NESTED_TABLE_ID. 
	The nested table elements that belong to a different row of Booking_objtab have a 
	different value of NESTED_TABLE_ID.
	In the preceding CREATE TABLE example, Line 5 indicates that the rows of 
	ReservationList_ntab nested table are to be stored in a separate table 
	(referred to as the storage table) named BookingReservation_ntab. 
	The STORE AS clause also permits you to specify the constraint and 
	storage specification for the storage table. 
	In this example, Line 7 indicates that the storage table is 
	an index-organized table (IOT). 
	In general, storing nested table rows in an IOT is beneficial because it 
	provides clustering of rows belonging to the same parent. 
	The specification of COMPRESS on the IOT saves storage space because, 
	if you do not specify COMPRESS, 
	the NESTED_TABLE_ID part of the IOT's key is repeated for every row of a parent row object. 
	If, however, you specify COMPRESS, the NESTED_TABLE_ID is stored only 
	once for each parent row object.
*/

CREATE TABLE Booking_objtab OF Booking_objtyp (
	PRIMARY KEY (BookingNo),
    FOREIGN KEY (Customer_ref) REFERENCES Customer_objtab)
	OBJECT IDENTIFIER IS PRIMARY KEY
	NESTED TABLE ReservationList_ntab STORE AS BookingReservation_ntab (
		(PRIMARY KEY(NESTED_TABLE_ID, ReservationNo)) 
		ORGANIZATION INDEX COMPRESS)
    RETURN AS LOCATOR
/

END;
----------------------------------------------- SCOPES FOR TABLES ------------------------

/* 	You can constrain a column type, collection element, 
	or object type attribute to reference a specified object table 
	by using the SQL constraint subclause SCOPE IS when you declare the REF
	Scoped REF types require less storage space and allow more efficient access 
	than unscoped REF types.
*/

BEGIN;

ALTER TABLE MembershipSubscription_objtab
   ADD (SCOPE FOR (Membership_ref) IS Membership_objtab);
/ 
  
ALTER TABLE CustomerMembershipSubscription_objtab
   ADD (SCOPE FOR (MembershipSubscription_ref) IS MembershipSubscription_objtab)
   ADD (SCOPE FOR (Customer_ref) IS Customer_objtab);
/

ALTER TABLE CustomerPayment_objtab
   ADD (SCOPE FOR (Customer_ref) IS Customer_objtab);
/

ALTER TABLE Employee_objtab
   ADD (SCOPE FOR (Venue_ref) IS Venue_objtab);
/

ALTER TABLE StaffAssignment_objtab
   ADD (SCOPE FOR (Employee_ref) IS Employee_objtab);
/

ALTER TABLE PerformElement_objtab
   ADD (SCOPE FOR (ElementType_ref) IS ElementType_objtab);
/

ALTER TABLE Event_objtab
   ADD (SCOPE FOR (Venue_ref) IS Venue_objtab)
   ADD (SCOPE FOR (EventType_ref) IS EventType_objtab)
   ADD (SCOPE FOR (AgeRating_ref) IS AgeRating_objtab);
/

ALTER TABLE EventItem_objtab
   ADD (SCOPE FOR (Event_ref) IS Event_objtab)
   ADD (SCOPE FOR (PerformElement_red) IS PerformElement_objtab)
   ADD (SCOPE FOR (StaffAssignment_ref) IS StaffAssignment_objtab);
/

ALTER TABLE Booking_objtab
   ADD (SCOPE FOR (Customer_ref) IS Customer_objtab);
/

ALTER TABLE BookingReservation_ntab
   ADD (SCOPE FOR (Event_ref) IS Event_objtab)
   ADD (SCOPE FOR (StaffAssignment_ref) IS StaffAssignment_objtab);
/

END;

----------------------------------------------- INSERT QUIRIES ------------------------------------------

/*
	**ASSUMPTIONS**
	Data insertion has been done according to the spaceformance case study and some 
	assumptions were made.
	Meal, Concert, and Play are three different types of events.
	Employee has one venue, staff support can be assigned to available employees 
	within the particular venue.
*/

BEGIN -- Creating data insertion

INSERT INTO Membership_objtab VALUES(1, 'Standard', 'Standard Anual Membership');
INSERT INTO Membership_objtab VALUES(2, 'VIP', 'VIP Anual Membership');
/
INSERT INTO MembershipSubscription_objtab VALUES(
	1,(SELECT REF(m) FROM Membership_objtab m WHERE m.MembershipNo = 1),25000.00,0,1,'01 Jan 2020','31 Dec 2020',SYSDATE);
INSERT INTO MembershipSubscription_objtab VALUES(
	2,(SELECT REF(m) FROM Membership_objtab m WHERE m.MembershipNo = 1),75000.00,20,1,'01 Jan 2020','31 Dec 2020',SYSDATE);
/    
INSERT INTO customer_objtab VALUES
(1,'Ravindu Bandara','04 APR 1994', '77/7c, Negombo', 'Credit Card', 3434345456576, '31 MAY 2021');    
INSERT INTO customer_objtab VALUES
(2,'Upul Fernando','11 JAN 1987', '667, Colombo', 'Credit Card', 3245678009, '31 MAY 2024');
/
INSERT INTO customermembershipsubscription_objtab VALUES(
    1,(SELECT REF(c) FROM customer_objtab c WHERE c.id = 1),
    (SELECT REF(m) FROM membershipsubscription_objtab m WHERE m.id = 1), 'Paid', SYSDATE, SYSDATE);
INSERT INTO customermembershipsubscription_objtab VALUES(
    2,(SELECT REF(c) FROM customer_objtab c WHERE c.id = 2),
    (SELECT REF(m) FROM membershipsubscription_objtab m WHERE m.id = 2), 'Paid', SYSDATE, SYSDATE);
/
INSERT INTO CustomerPayment_objtab VALUES(
    1, (SELECT REF(c) FROM customer_objtab c WHERE c.id = 1),'Subscription',25000.00, SYSDATE);
INSERT INTO CustomerPayment_objtab VALUES(
    2, (SELECT REF(c) FROM customer_objtab c WHERE c.id = 2),'Subscription',75000.00, SYSDATE);
/
INSERT INTO venue_objtab VALUES(1, 'Colombo Venue', '6/1, Colombo', 2000, 4000, SYSDATE, SYSDATE);
INSERT INTO venue_objtab VALUES(2, 'Negombo Venue', 'Main Street, Negombo', 500, 1000, SYSDATE, SYSDATE);
/
INSERT INTO employee_objtab VALUES(
    1,(SELECT REF(v) FROM venue_objtab v WHERE v.venueno = 1),'Kamal Sri');
INSERT INTO employee_objtab VALUES(
    2,(SELECT REF(v) FROM venue_objtab v WHERE v.venueno = 2),'Ovin Perera');
INSERT INTO employee_objtab VALUES(
    3,(SELECT REF(v) FROM venue_objtab v WHERE v.venueno = 1),'Pasan Fernando'); 
/   
INSERT INTO eventtype_objtab VALUES(1,'Meal','Meal event');
INSERT INTO eventtype_objtab VALUES(2,'Concert','Concert event');
INSERT INTO eventtype_objtab VALUES(3,'Play','Play event');
/
INSERT INTO agerating_objtab VALUES(1,4,12);
INSERT INTO agerating_objtab VALUES(2,12,21);
INSERT INTO agerating_objtab VALUES(3,21,70);
/
INSERT INTO elementtype_objtab VALUES(1,'Band', 'Performing band');
INSERT INTO elementtype_objtab VALUES(2,'Singer', 'Performing singer');
INSERT INTO elementtype_objtab VALUES(3,'Cast Member', 'Member of drama');
INSERT INTO elementtype_objtab VALUES(4,'Director', 'Director of play');
INSERT INTO elementtype_objtab VALUES(5,'Meal', 'Buffet');
/
INSERT INTO performelement_objtab VALUES(
    1,(SELECT REF(e) FROM elementtype_objtab e WHERE e.elementtypeno = 1),'Daddy', 'Music band');
INSERT INTO performelement_objtab VALUES(
    2,(SELECT REF(e) FROM elementtype_objtab e WHERE e.elementtypeno = 2),'Lahiru Perera', 'Singer');
INSERT INTO performelement_objtab VALUES(
    3,(SELECT REF(e) FROM elementtype_objtab e WHERE e.elementtypeno = 3),'Ruwan Bandara', 'Cast Member');
INSERT INTO performelement_objtab VALUES(
    4,(SELECT REF(e) FROM elementtype_objtab e WHERE e.elementtypeno = 3),'Dayani Alwis', 'Cast Member');     
INSERT INTO performelement_objtab VALUES(
    5,(SELECT REF(e) FROM elementtype_objtab e WHERE e.elementtypeno = 4),'Ranjan Gunatilake', 'Director of play'); 
INSERT INTO performelement_objtab VALUES(
    6,(SELECT REF(e) FROM elementtype_objtab e WHERE e.elementtypeno = 5),'Dinner Buffet', 'Meal festival'); 
/
INSERT INTO event_objtab VALUES(
    1,
    (SELECT REF(v) FROM venue_objtab v WHERE v.venueno = 1),
    (SELECT REF(e) FROM eventtype_objtab e WHERE e.eventtypeno = 2),
    (SELECT REF(a) FROM agerating_objtab a WHERE a.ageratingno = 3),
    'Sunday Night Event',
    'Event 01',
    100,
    TO_DATE('06/12/2020 18:00:00', 'MM/DD/YYYY HH24:MI:SS'),
    TO_DATE('06/12/2020 22:30:00', 'MM/DD/YYYY HH24:MI:SS'),
    SYSDATE,
    SYSDATE); 
/
INSERT INTO staffassignment_objtab VALUES(
    1,(SELECT REF(e) FROM employee_objtab e WHERE e.id = 1),
    TO_DATE('06/12/2020 18:00:00', 'MM/DD/YYYY HH24:MI:SS'),
    TO_DATE('06/12/2020 22:30:00', 'MM/DD/YYYY HH24:MI:SS'));
/
INSERT INTO eventitem_objtab VALUES(
    1,
    (SELECT REF(e) FROM event_objtab e WHERE e.id = 1),
    (SELECT REF(p) FROM performelement_objtab p WHERE p.id = 1),
    NULL,
    10000,
    SYSDATE,
    0);
INSERT INTO eventitem_objtab VALUES(
    2,
    (SELECT REF(e) FROM event_objtab e WHERE e.id = 1),
    (SELECT REF(p) FROM performelement_objtab p WHERE p.id = 2),
    (SELECT REF(s) FROM staffassignment_objtab s WHERE s.id = 1),
    14000,
    SYSDATE,
    1); 
/
INSERT INTO Booking_objtab
  SELECT  1001, REF(c),
          SYSDATE,
          ReservationList_ntabtyp(),
          12000
   FROM   Customer_objtab c
   WHERE  c.id = 1 ;
/   
INSERT INTO TABLE (
  SELECT  b.ReservationList_ntab
   FROM   Booking_objtab b
   WHERE  b.bookingno = 1001
  )
  SELECT  1, REF(e),NULL,5,1000,0
   FROM   event_objtab e
   WHERE  e.id = 1 ;
/
INSERT INTO TABLE (
  SELECT  b.ReservationList_ntab
   FROM   Booking_objtab b
   WHERE  b.bookingno = 1001
  )
  SELECT  2, REF(e),NULL,5,1000,0
   FROM   event_objtab e
   WHERE  e.id = 1 ; 
 /
 
END;
    
------------------------------------------ CLEAR TABLES --------------------------------------------

BEGIN -- Deleting data

DROP TABLE Booking_objtab;
/

DROP TABLE EventItem_objtab;
/

DROP TABLE Event_objtab;
/

DROP TABLE PerformElement_objtab;
/

DROP TABLE StaffAssignment_objtab;
/

DROP TABLE Employee_objtab;
/

DROP TABLE CustomerPayment_objtab;
/

DROP TABLE CustomerMembershipSubscription_objtab;
/

DROP TABLE MembershipSubscription_objtab;
/

DROP TABLE Venue_objtab;
/

DROP TABLE ElementType_objtab;
/

DROP TABLE AgeRating_objtab;
/

DROP TABLE EventType_objtab;
/

DROP TABLE Customer_objtab;
/

DROP TABLE Membership_objtab;
/

DROP TYPE Booking_objtyp;
/

DROP TYPE ReservationList_ntabtyp;
/

DROP TYPE Reservation_objtyp;
/

DROP TYPE EventItem_objtyp;
/

DROP TYPE Event_objtyp;
/

DROP TYPE PerformElement_objtyp;
/

DROP TYPE ElementType_objtyp;
/

DROP TYPE AgeRating_objtyp;
/

DROP TYPE EventType_objtyp;
/

DROP TYPE StaffAssignment_objtyp;
/

DROP TYPE Employee_objtyp;
/

DROP TYPE Venue_objtyp;
/

DROP TYPE CustomerPayment_objtyp;
/

DROP TYPE CustomerMembershipSubscription_objtyp;
/

DROP TYPE Customer_objtyp;
/

DROP TYPE MembershipSubscription_objtyp;
/

DROP TYPE Membership_objtyp;
/

END;




