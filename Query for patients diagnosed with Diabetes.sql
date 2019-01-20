-- Filtering for Diagnosis Code= 25000 and excluding Lab Codes and Office Visits
-- Filtering for Employer ID and Plan Administrator ID

SELECT * INTO TABLE_25000_INT_1 FROM 
(
SELECT * FROM [4C].[cba-mysql5].[medical]
WHERE  [DATA_DIAGNOSISPRINCIPAL] = '25000'  
AND [IDENT_EMPLOYERID]='1003' 
AND [IDENT_PLANADMINISTRATORID]='1002' 
AND [DATA_PROCEDURECODE] NOT BETWEEN ('80047') AND ('89398')
AND [DATA_PROCEDURECODE] NOT LIKE '%992%'
) TABLE_25000_INT_1

-- Query for finding all combinations of procedure codes for all the patients

SELECT * INTO TABLE_25000_INT_3 FROM 
(
SELECT  DISTINCT ABC.[DATA_PROCEDURECODE] as Source, DEF.[DATA_PROCEDURECODE] as Target, ABC.[IDENT_PATIENTID]
                     FROM
                     (
					 SELECT * FROM TABLE_25000_INT_1
                     ) ABC INNER JOIN 
                     ( 
					 SELECT * FROM TABLE_25000_INT_1
                     ) DEF 
                     ON ABC.[IDENT_PATIENTID]=DEF.[IDENT_PATIENTID] 
                     AND ABC.[DATA_PROCEDURECODE] < DEF.[DATA_PROCEDURECODE]
) AS EDGE_TABLE

-- Query for assigning weights to edges

SELECT * INTO TABLE_25000_INT_4 FROM 
(
SELECT Table_1.Source, Table_1.Target , COUNT(DISTINCT [IDENT_PATIENTID]) AS WEIGHTS FROM 
(
SELECT  DISTINCT ABC.[DATA_PROCEDURECODE] as Source, DEF.[DATA_PROCEDURECODE] as Target, ABC.[IDENT_PATIENTID]
                     FROM
                     (
					SELECT * FROM TABLE_25000_INT_1
                     ) ABC INNER JOIN 
                     ( 
                    SELECT * FROM TABLE_25000_INT_1
                     ) DEF 
                     ON ABC.[IDENT_PATIENTID]=DEF.[IDENT_PATIENTID] 
                     AND ABC.[DATA_PROCEDURECODE] < DEF.[DATA_PROCEDURECODE]
) Table_1 GROUP BY  Table_1.Source, Table_1.Target
)  as WEIGHTS

-- Query for creating edges table

SELECT * INTO EDGES_25000 FROM 
(
SELECT 
INT_3.SOURCE, 
INT_3.TARGET, 
INT_3.[IDENT_PATIENTID],
INT_4.WEIGHTS
 FROM TABLE_25000_INT_3 AS INT_3 INNER JOIN TABLE_25000_INT_4 AS INT_4
ON INT_3.SOURCE=INT_4.SOURCE 
AND INT_3.TARGET=INT_4.TARGET
) AS EDGE_WEIGHTS

-- Query for creating vertices table

SELECT * INTO VERTICES_25000 FROM 
(
SELECT SOURCE AS NAME FROM EDGES_25000
UNION
SELECT TARGET AS NAME FROM EDGES_25000
) AS VERTICES
