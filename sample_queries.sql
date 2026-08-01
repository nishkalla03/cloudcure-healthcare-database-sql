/*
=========================================================
CloudCure Healthcare Database
Author: Nishkalla Selva Ilangowan
Project: Group Project (My Contribution: SQL Development)
Platform: Oracle APEX
=========================================================

This file contains sample SQL queries developed for the
CloudCure Healthcare Database Project.

The queries demonstrate:

- Subqueries
- Multi-table JOINs
- Aggregate Functions
- Database Views

=========================================================
*/

---------------------------------------------------------
-- SECTION 1 : SUBQUERIES
---------------------------------------------------------

-- Query 1
-- Find appointments for patients with high-risk AI checkups

SELECT *
FROM APPOINTMENT
WHERE PatientID IN (
    SELECT PatientID
    FROM AI_CHECKUP
    WHERE RiskLevel = 'High'
);

---------------------------------------------------------

-- Query 2
-- Find doctors who have appointments today

SELECT *
FROM DOCTOR
WHERE DoctorID IN (
    SELECT DoctorID
    FROM APPOINTMENT
    WHERE TRUNC(DateTime) = TRUNC(SYSDATE)
);

---------------------------------------------------------

-- Query 3
-- Find patients diagnosed with diabetes

SELECT *
FROM PATIENT
WHERE PatientID IN (
    SELECT A.PatientID
    FROM APPOINTMENT A
    JOIN VIRTUAL_CONSULTATION VC
    ON A.AppointmentID = VC.AppointmentID
    WHERE LOWER(VC.Diagnosis) LIKE '%diabetes%'
);

---------------------------------------------------------

-- Query 4
-- Patients above 60 with AI checkups

SELECT *
FROM PATIENT
WHERE Age > 60
AND PatientID IN (
    SELECT DISTINCT PatientID
    FROM AI_CHECKUP
);

---------------------------------------------------------
-- SECTION 2 : MULTI-TABLE JOINS
---------------------------------------------------------

-- Query 5
-- Appointment details

SELECT
A.AppointmentID,
P.FullName AS PatientName,
D.FullName AS DoctorName,
A.DateTime
FROM APPOINTMENT A
JOIN PATIENT P
ON A.PatientID = P.PatientID
JOIN DOCTOR D
ON A.DoctorID = D.DoctorID;

---------------------------------------------------------

-- Query 6
-- Virtual consultation details

SELECT
VC.ConsultationID,
VC.Diagnosis,
P.FullName AS Patient,
D.Specialization
FROM VIRTUAL_CONSULTATION VC
JOIN APPOINTMENT A
ON VC.AppointmentID = A.AppointmentID
JOIN PATIENT P
ON A.PatientID = P.PatientID
JOIN DOCTOR D
ON A.DoctorID = D.DoctorID;

---------------------------------------------------------

-- Query 7
-- AI Checkup Results

SELECT
AC.CheckupID,
AC.PredictedCondition,
AC.RiskLevel,
P.BloodType
FROM AI_CHECKUP AC
JOIN PATIENT P
ON AC.PatientID = P.PatientID;

---------------------------------------------------------

-- Query 8
-- Consultation notes

SELECT
VC.ConsultationID,
VC.Notes,
P.FullName,
P.ChronicConditions
FROM VIRTUAL_CONSULTATION VC
JOIN APPOINTMENT A
ON VC.AppointmentID = A.AppointmentID
JOIN PATIENT P
ON A.PatientID = P.PatientID
WHERE P.ChronicConditions IS NOT NULL;

---------------------------------------------------------
-- SECTION 3 : AGGREGATE FUNCTIONS
---------------------------------------------------------

-- Query 9

SELECT
D.FullName,
COUNT(VC.ConsultationID) AS TotalConsultations
FROM VIRTUAL_CONSULTATION VC
JOIN APPOINTMENT A
ON VC.AppointmentID = A.AppointmentID
JOIN DOCTOR D
ON A.DoctorID = D.DoctorID
GROUP BY D.FullName;

---------------------------------------------------------

-- Query 10

SELECT
UrgencyLevel,
ROUND(AVG(Duration),2) AS AvgDuration
FROM APPOINTMENT
GROUP BY UrgencyLevel;

---------------------------------------------------------

-- Query 11

SELECT COUNT(*) AS HighRiskCheckups
FROM AI_CHECKUP
WHERE RiskLevel='High';

---------------------------------------------------------

-- Query 12

SELECT
P.FullName,
COUNT(A.AppointmentID) AS TotalAppointments
FROM PATIENT P
JOIN APPOINTMENT A
ON P.PatientID=A.PatientID
GROUP BY P.FullName;

---------------------------------------------------------
-- SECTION 4 : DATABASE VIEWS
---------------------------------------------------------

-- View 1

CREATE OR REPLACE VIEW view_patient_info AS

SELECT
PatientID,
FullName,
Gender,
Age,
ChronicConditions
FROM PATIENT;

---------------------------------------------------------

-- View 2

CREATE OR REPLACE VIEW view_doctor_summary AS

SELECT
D.DoctorID,
D.FullName,
COUNT(A.AppointmentID) AS TotalAppointments
FROM DOCTOR D
LEFT JOIN APPOINTMENT A
ON D.DoctorID=A.DoctorID
GROUP BY D.DoctorID,D.FullName;

---------------------------------------------------------

-- View 3

CREATE OR REPLACE VIEW view_ai_risk_summary AS

SELECT
RiskLevel,
COUNT(*) AS TotalCheckups
FROM AI_CHECKUP
GROUP BY RiskLevel;

---------------------------------------------------------

-- View 4

CREATE OR REPLACE VIEW view_followup_schedule AS

SELECT
VC.ConsultationID,
A.PatientID,
VC.FollowUpDate
FROM VIRTUAL_CONSULTATION VC
JOIN APPOINTMENT A
ON VC.AppointmentID=A.AppointmentID;