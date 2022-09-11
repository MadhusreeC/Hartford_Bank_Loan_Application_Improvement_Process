select * from verification_agency;

CREATE TABLE Verification_Agency(
Agency_ID varchar(30) PRIMARY KEY,
Agency_Name varchar(30),
Agency_Email_ID varchar(50),
Agency_Contact_Number INT
);

CREATE TABLE Processing_Clerk(
Clerk_ID varchar(30) PRIMARY KEY,
Clerk_First_Name varchar(30),
Clerk_Last_Name varchar(30),
Clerk_Email_ID varchar(50),
Clerk_SSN int
);

select * from Processing_Clerk;

CREATE TABLE credit_rating_bureau(
Bureau_ID varchar(30) PRIMARY KEY,
Bureau_Name varchar(50),
Bureau_Email_ID varchar(50)
);

select * from credit_rating_bureau;

CREATE TABLE Cases(
Case_ID varchar(30) PRIMARY KEY,
Clerk_ID_FK varchar(30),
Agency_ID_FK varchar(30),
Verified INT,
Bureau_ID_FK varchar(30),
CONSTRAINT Clerk_FK FOREIGN KEY (Clerk_ID_FK) REFERENCES processing_clerk(clerk_id),
CONSTRAINT Agency_FK FOREIGN KEY (Agency_ID_FK) REFERENCES verification_agency(agency_id),
CONSTRAINT Bureau_FK FOREIGN KEY (Bureau_ID_FK) REFERENCES credit_rating_bureau(bureau_id)
);

select * from cases;



CREATE TABLE Agents(
Agent_ID varchar(30) PRIMARY KEY,
Agent_First_Name varchar(30),
Agent_Last_Name varchar(30),
Agent_Phone_No INT,
Agent_Email_ID varchar(50),
Agency_ID_FK varchar(30),
CONSTRAINT Agency_FK_Agents FOREIGN KEY (Agency_ID_FK) REFERENCES verification_agency(agency_id)
);

select * from agents;

CREATE TABLE credit_review_committee(
Member_ID varchar(30) PRIMARY KEY,
Member_First_Name varchar(50),
Member_Last_Name varchar(50),
Member_Email_ID varchar(50),
Member_Designation varchar(30)
);

select * from credit_review_committee;

CREATE TABLE Rejected_Applications(
Rejected_Case_ID varchar(30) PRIMARY KEY,
Bureau_ID_FK varchar(30),
Rejected INT,
Member_ID_FK varchar(30),
CONSTRAINT BureauID_FK FOREIGN KEY (Bureau_ID_FK) REFERENCES credit_rating_bureau(bureau_id),
CONSTRAINT Member_FK FOREIGN KEY (Member_ID_FK) REFERENCES credit_review_committee(Member_ID)
);

select * from rejected_applications;



CREATE TABLE Loan_Request(
Loan_Request_ID int PRIMARY KEY,
Loan_Request_Date date NOT NULL,
Loan_Amount int NOT NULL,
Loan_Deadline date NOT NULL,
Application_Processing_Fees int,
loan_type varchar(30) NOT NULL,
Bureau_ID_FK varchar(30),
Member_ID_FK varchar(30),
CONSTRAINT BureauIDI_FK FOREIGN KEY (Bureau_ID_FK) REFERENCES credit_rating_bureau(bureau_id),
CONSTRAINT MemberI_FK FOREIGN KEY (Member_ID_FK) REFERENCES credit_review_committee(Member_ID)
);

select * from loan_request;

CREATE TABLE LOAN_APPLICATION (
APPLICATION_ID Int,
APPLICANT_NAME varchar(255),
APPLICANT_ADDRESS varchar(255),
APPLICANT_DOB date,
DATE_of_APPLICATION date,
APPLICANT_SSN Int,
APPLICANT_CONTACT_NUMBER Int,
APPLICANT_GENDER varchar(10),
APPLICANT_CITIZENSHIP varchar(255),
APPLICANT_CREDIT_SCORE Int,
APPLICANT_INCOME Int,
APPLICANT_EMAIL_ID varchar(255),
Clerk_ID_FK varchar(30),
CONSTRAINT Clerk_FKI FOREIGN KEY (Clerk_ID_FK) REFERENCES processing_clerk(clerk_id)
);

select * from loan_application;

-- the queries are also attached in the docx file with the benefit in business context

--Query 1
SELECT COUNT(DISTINCT(la.application_id)) Num_Applicants,
ROUND(AVG((SYSDATE - la.applicant_dob)/365.25),0) Avg_Age,
ROUND(AVG(la.applicant_income),2) Avg_Income,
ROUND(AVG(la.applicant_credit_score),2) Avg_Cred,
ROUND(VARIANCE(la.applicant_credit_score),2) Var_Cred,
COUNT(DISTINCT(lr.loan_request_id)) Num_Approved
FROM loan_application la FULL JOIN processing_clerk pc
ON(la.clerk_id_fk = pc.clerk_id)
FULL JOIN cases ca
ON(ca.clerk_id_fk = pc.clerk_id)
FULL JOIN credit_rating_bureau crb
ON(crb.bureau_id = ca.bureau_id_fk)
FULL JOIN loan_request lr
ON(lr.bureau_id_fk = crb.bureau_id)
WHERE lr.bureau_id_fk IS NOT NULL;


--Query 2 

SELECT pc.clerk_id, pc.clerk_last_name, count(ca.verified)
FROM processing_clerk pc JOIN cases ca
ON(pc.clerk_id = ca.clerk_id_fk)
GROUP BY pc.clerk_id, pc.clerk_last_name;

-- Query 3

SELECT
COUNT(DISTINCT(lr.loan_request_id)) Num_Approved
FROM loan_application la FULL JOIN processing_clerk pc
ON(la.clerk_id_fk = pc.clerk_id)
FULL JOIN cases ca
ON(ca.clerk_id_fk = pc.clerk_id)
FULL JOIN credit_rating_bureau crb
ON(crb.bureau_id = ca.bureau_id_fk)
FULL JOIN loan_request lr
ON(lr.bureau_id_fk = crb.bureau_id)
WHERE lr.member_id_fk IS NOT NULL;


--Query 4
SELECT la.application_id, la.applicant_name, la.applicant_credit_score, la.applicant_income,
(CASE WHEN la.applicant_credit_score >= 547.3 AND la.applicant_income >= 109592.72 THEN 'Very Likely to be Accepted'
WHEN (la.applicant_credit_score >= 547.3 AND la.applicant_income <= 109592.72)
OR (la.applicant_credit_score <= 547.3 AND la.applicant_income >= 109592.72) THEN 'May be Accepted'
ELSE 'Likely Not Accepted'
END) AS Predicted_Acceptance
FROM loan_application la JOIN processing_clerk pc
ON(la.clerk_id_fk = pc.clerk_id)
;

-- Query 5
SELECT DISTINCT l.LOAN_REQUEST_ID, a.APPLICATION_ID, a.APPLICANT_NAME, l.Loan_Amount, l.Loan_type
FROM loan_application a
JOIN CASES c
on a.CLERK_ID_FK = c.CLERK_ID_FK
JOIN loan_request l
on l.Bureau_Id_FK = c.Bureau_Id_FK
WHERE Loan_Type= ANY (SELECT loan_type FROM loan_request WHERE loan_amount > 52011)
order by loan_type;

