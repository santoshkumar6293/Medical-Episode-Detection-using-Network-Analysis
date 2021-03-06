-- Filtering for Top 10 diagnosis codes and excluding Lab Codes and Office Visits
-- Filtering for Employer ID and Plan Administrator ID
-- Removing Procedure Codes with Degrees > 2000

SELECT * INTO TABLE_TOP8_INT_1_PRUNE FROM 
(
SELECT * FROM [4C].[cba-mysql5].[medical]
WHERE  [DATA_DIAGNOSISPRINCIPAL] IN ('25000','4019','2724','78650','V7612','4011','7242','78900')
AND [IDENT_EMPLOYERID]='1003' 
AND [IDENT_PLANADMINISTRATORID]='1002' 
AND [DATA_PROCEDURECODE] NOT BETWEEN ('80047') AND ('89398')
AND [DATA_PROCEDURECODE] NOT LIKE '%992%'
AND [DATA_PROCEDURECODE] NOT IN ('36415','99396','71020','G0202','77052','96372','93010','93000','71010','93306','J1100','90471','J3301','20610','810','97110','74177','73630','70450','72100','97140','92014','J1030','43239','77080','J0696','J1040','72148','740','98941','74176','A0425','93018','78452','A7035','73030','92015','76830','97001','A7038','97014','99053','93016','73562','76705','G8427','J1885','11100','77051','73721','G0206','93970','J0702','93971','73560','76642','45378','71260','76942','E0562','92250','A0427','A7037','E0601','45380','A7034','77063','90791','72040','74000','92012','99386','72141','99000','76856','17000','93880','73610','71275','76536','72110','92083','92004','1036F','94729','73564','70553','95811','95886','97012','98940','7025F','G6056','94060','97530','73130','G6031','95810','71250','92134','72170','17110','45385','790','76700','93458','70551','93015','Q0091','73221','77003','G6042','99395','92133','G6044','G6053','A7030','73510','G0479','94010','70486','20550','72050','76770','G0431','90670','G0204','94640','90715','73502','36416','73620','73110','72125','74178','62311','G6052','A7039','17003','90837','840','A7046','97035','98943','92557','G6045','J3420','97010','90658','92567','G6046','64483','51798','A4604','36620','43235','94726','G0434','90686','94760','99397','76937','90688','90732','90834','G8417','97112','A9500','Q9967','72131','93227','A7032','66984','G6058','670','A7031','94727','20611','76641','20605','E0143','1480','142','A4550','A0429','G6043','1400','E1390','400','G0483','77001','64493','58100','77002','72158','74020','J3490','77067','95941','95004','99051','93922','99144','A7033','95165','31575','93325','93224','52000','A0428','90792','92136','72070','3008F','J2001','96413','22851','20552','73590','11101','72146','64494','73080','36556','97032','96365','31231','3342F','96103','1402','73565','95938','47562','G6030','74022','1810','69210','G8482','99140','10060','G0482','27447','96375','78815','G6037','99406','L3908','96101','630','3341F','72072','J2550','G6040','73140','76882','20600','A0426','1630','G6036','78227','J1200','G6032','L4361','76514','70491','G0477','90472','63047','64484','J2930','L4360','J2785','64450','96367','93925','76377','36561','90833','95911','95909','73718','77427','Q9966','G0283','73070','73700','73120','70544','77300','93320','64415','952','94762','S0612','90736','93226','G8754','77263','G9637','64635','G8420','93923','G0008','64636','95024','77334','G0480','910','J7030','72020','92928','77057','G6051','A4556','10022','S0020','70498','29826','G6041','11042','95910','J2250','73600','27096','64495','62310','E0431','97002','300','G8752','3074F','797','93312','E0730','78306','532','L1902','G0481','95806','74160','64447','95117','E0163','J2405','G0121','20930','70496','96415','11750','77290','73100','76775','29881','74220','99385','96360','1936','77059','19083','92020','64721','J1020','3078F','A7036','20936','71270','74420','G6034','95937','22845','J7613','96374','73500','E0570','A0398','99024','22840','73090','11721','E0114','G0180','G8783','20553','96361','74183','L3260','93350','77280')
) TABLE_TOP8_INT_1


-- Query for finding combinations of procedure codes for all the patients for top 10 diagnosis codes

SELECT * INTO TABLE_TOP8_INT_3_PRUNE  FROM 
(
SELECT  DISTINCT ABC.[DATA_PROCEDURECODE] as Source, DEF.[DATA_PROCEDURECODE] as Target, ABC.[IDENT_PATIENTID]
                     FROM
                     (
					 SELECT * FROM TABLE_TOP8_INT_1_PRUNE 
                     ) ABC INNER JOIN 
                     ( 
					 SELECT * FROM TABLE_TOP8_INT_1_PRUNE
                     ) DEF 
                     ON ABC.[IDENT_PATIENTID]=DEF.[IDENT_PATIENTID] 
                     AND ABC.[DATA_PROCEDURECODE] < DEF.[DATA_PROCEDURECODE]
) AS TABLE_TOP8_INT_3

-- Query for finding weights for all the patients for top 10 diagnosis codes

SELECT * INTO TABLE_TOP8_INT_4_PRUNE  FROM 
(
SELECT Table_1.Source, Table_1.Target , COUNT(DISTINCT [IDENT_PATIENTID]) AS WEIGHTS FROM 
(
SELECT  DISTINCT ABC.[DATA_PROCEDURECODE] as Source, DEF.[DATA_PROCEDURECODE] as Target, ABC.[IDENT_PATIENTID]
                     FROM
                     (
					SELECT * FROM TABLE_TOP8_INT_1_PRUNE
                     ) ABC INNER JOIN 
                     ( 
                    SELECT * FROM TABLE_TOP8_INT_1_PRUNE
                     ) DEF 
                     ON ABC.[IDENT_PATIENTID]=DEF.[IDENT_PATIENTID] 
                     AND ABC.[DATA_PROCEDURECODE] < DEF.[DATA_PROCEDURECODE]
) Table_1 GROUP BY  Table_1.Source, Table_1.Target
)  as TABLE_TOP8_INT_4

-- Query for creating edges table for top 10 diagnosis codes

SELECT * INTO EDGES_TOP8_PRUNE FROM 
(
SELECT 
INT_3.SOURCE, 
INT_3.TARGET, 
INT_3.[IDENT_PATIENTID],
INT_4.WEIGHTS
 FROM TABLE_TOP8_INT_3_PRUNE  AS INT_3 INNER JOIN TABLE_TOP8_INT_4_PRUNE AS INT_4
ON INT_3.SOURCE=INT_4.SOURCE 
AND INT_3.TARGET=INT_4.TARGET
) AS EDGE_WEIGHTS

-- Query for creating vertices table for top 10 diagnosis codes

SELECT * INTO VERTICES_TOP8_PRUNE FROM 
(
SELECT SOURCE AS NAME FROM EDGES_TOP8_PRUNE
UNION
SELECT TARGET AS NAME FROM EDGES_TOP8_PRUNE
) AS VERTICES

-- Filtering for Top 10 diagnosis code and excluding Lab Codes and Office Visits
-- Filtering for Employer ID and Plan Administrator ID
-- Removing Procedure Codes with Degrees > 2000
-- FIltering only for the patients present in top 10 diagnosis codes

 SELECT * INTO TABLE_NOT_TOP8_INT_1_PRUNE FROM 
 (
 SELECT * FROM [4C].[cba-mysql5].[medical]
 WHERE  [DATA_DIAGNOSISPRINCIPAL] NOT IN ('25000','4019','2724','78650','V7612','4011','7242','78900')  
 AND [IDENT_EMPLOYERID]='1003' 
 AND [IDENT_PLANADMINISTRATORID]='1002' 
 AND [DATA_PROCEDURECODE] NOT BETWEEN ('80047') AND ('89398')
 AND [DATA_PROCEDURECODE] NOT LIKE '%992%'
 AND [DATA_PROCEDURECODE]  NOT IN ('36415','99396','71020','G0202','77052','96372','93010','93000','71010','93306','J1100','90471','J3301','20610','810','97110','74177','73630','70450','72100','97140','92014','J1030','43239','77080','J0696','J1040','72148','740','98941','74176','A0425','93018','78452','A7035','73030','92015','76830','97001','A7038','97014','99053','93016','73562','76705','G8427','J1885','11100','77051','73721','G0206','93970','J0702','93971','73560','76642','45378','71260','76942','E0562','92250','A0427','A7037','E0601','45380','A7034','77063','90791','72040','74000','92012','99386','72141','99000','76856','17000','93880','73610','71275','76536','72110','92083','92004','1036F','94729','73564','70553','95811','95886','97012','98940','7025F','G6056','94060','97530','73130','G6031','95810','71250','92134','72170','17110','45385','790','76700','93458','70551','93015','Q0091','73221','77003','G6042','99395','92133','G6044','G6053','A7030','73510','G0479','94010','70486','20550','72050','76770','G0431','90670','G0204','94640','90715','73502','36416','73620','73110','72125','74178','62311','G6052','A7039','17003','90837','840','A7046','97035','98943','92557','G6045','J3420','97010','90658','92567','G6046','64483','51798','A4604','36620','43235','94726','G0434','90686','94760','99397','76937','90688','90732','90834','G8417','97112','A9500','Q9967','72131','93227','A7032','66984','G6058','670','A7031','94727','20611','76641','20605','E0143','1480','142','A4550','A0429','G6043','1400','E1390','400','G0483','77001','64493','58100','77002','72158','74020','J3490','77067','95941','95004','99051','93922','99144','A7033','95165','31575','93325','93224','52000','A0428','90792','92136','72070','3008F','J2001','96413','22851','20552','73590','11101','72146','64494','73080','36556','97032','96365','31231','3342F','96103','1402','73565','95938','47562','G6030','74022','1810','69210','G8482','99140','10060','G0482','27447','96375','78815','G6037','99406','L3908','96101','630','3341F','72072','J2550','G6040','73140','76882','20600','A0426','1630','G6036','78227','J1200','G6032','L4361','76514','70491','G0477','90472','63047','64484','J2930','L4360','J2785','64450','96367','93925','76377','36561','90833','95911','95909','73718','77427','Q9966','G0283','73070','73700','73120','70544','77300','93320','64415','952','94762','S0612','90736','93226','G8754','77263','G9637','64635','G8420','93923','G0008','64636','95024','77334','G0480','910','J7030','72020','92928','77057','G6051','A4556','10022','S0020','70498','29826','G6041','11042','95910','J2250','73600','27096','64495','62310','E0431','97002','300','G8752','3074F','797','93312','E0730','78306','532','L1902','G0481','95806','74160','64447','95117','E0163','J2405','G0121','20930','70496','96415','11750','77290','73100','76775','29881','74220','99385','96360','1936','77059','19083','92020','64721','J1020','3078F','A7036','20936','71270','74420','G6034','95937','22845','J7613','96374','73500','E0570','A0398','99024','22840','73090','11721','E0114','G0180','G8783','20553','96361','74183','L3260','93350','77280')
 AND [IDENT_PATIENTID] IN (SELECT DISTINCT IDENT_PATIENTID  FROM EDGES_TOP8_PRUNE) 
 ) AS TABLE_NOT_TOP8_INT_1

 -- Query for including all other diagnosis codes for all the patients who were diagnosed in the top 10 diagnosis list 			

SELECT * INTO TABLE_NOT_TOP8_INT_3_PRUNE FROM 
(
SELECT  DISTINCT 
ABC.[DATA_PROCEDURECODE] as Source, 
DEF.[DATA_PROCEDURECODE] as Target, 
ABC.[IDENT_PATIENTID]
                     FROM
                     (
                     SELECT * FROM TABLE_NOT_TOP8_INT_1_PRUNE 
                     ) ABC INNER JOIN 
                     ( 
                     SELECT * FROM TABLE_NOT_TOP8_INT_1_PRUNE
                     ) DEF 
                     ON ABC.[IDENT_PATIENTID]=DEF.[IDENT_PATIENTID] 
                     AND ABC.[DATA_PROCEDURECODE] < DEF.[DATA_PROCEDURECODE]
) AS TABLE_NOT_25000_INT_3_EX_CPT

-- Query for calculating weights for all the patients who were diagnosed in the top 10 diagnosis list

SELECT * INTO TABLE_NOT_TOP8_INT_4_PRUNE FROM 
(
SELECT Table_1.Source, Table_1.Target , COUNT(DISTINCT [IDENT_PATIENTID]) AS WEIGHTS FROM 
(
SELECT  DISTINCT ABC.[DATA_PROCEDURECODE] as Source, DEF.[DATA_PROCEDURECODE] as Target, ABC.[IDENT_PATIENTID]
                     FROM
                     (
					SELECT * FROM TABLE_NOT_TOP8_INT_1_PRUNE
                     ) ABC INNER JOIN 
                     ( 
					SELECT * FROM TABLE_NOT_TOP8_INT_1_PRUNE
                     ) DEF 
                     ON ABC.[IDENT_PATIENTID]=DEF.[IDENT_PATIENTID] 
                     AND ABC.[DATA_PROCEDURECODE] < DEF.[DATA_PROCEDURECODE]
) Table_1 GROUP BY  Table_1.Source, Table_1.Target
)  as TABLE_NOT_25000_INT_4_EX_CPT

-- Query for creating edges table for all the patients who were diagnosed in the top 10 diagnosis list

SELECT * INTO EDGES_NOT_TOP8_PRUNE FROM 
(
SELECT 
INT_3.SOURCE, 
INT_3.TARGET, 
INT_3.[IDENT_PATIENTID],
INT_4.WEIGHTS
 FROM TABLE_NOT_TOP8_INT_3_PRUNE AS INT_3 INNER JOIN TABLE_NOT_TOP8_INT_4_PRUNE AS INT_4
ON INT_3.SOURCE=INT_4.SOURCE 
AND INT_3.TARGET=INT_4.TARGET
) AS EDGE_NOT_25000

-- Query for creating vertices table for all the patients who were diagnosed in the top 10 diagnosis list

SELECT * INTO VERTICES_NOT_TOP8_PRUNE FROM 
(
SELECT SOURCE AS NAME FROM EDGES_NOT_TOP8_PRUNE
UNION
SELECT TARGET AS NAME FROM EDGES_NOT_TOP8_PRUNE
) AS VERTICES_NOT_25000

-- Final Edges Table

SELECT * INTO EDGES_COMBINED_TOP8_PRUNE FROM 
(
SELECT TABLE_1.SOURCE, TABLE_1.TARGET, TABLE_1.IDENT_PATIENTID, SUM(WEIGHTS) AS WEIGHTS FROM
(
SELECT SOURCE , TARGET, IDENT_PATIENTID ,WEIGHTS FROM EDGES_TOP8_PRUNE
UNION
SELECT SOURCE , TARGET, IDENT_PATIENTID , WEIGHTS FROM EDGES_NOT_TOP8_PRUNE
) AS TABLE_1
GROUP BY TABLE_1.SOURCE, TABLE_1.TARGET, TABLE_1.IDENT_PATIENTID
) AS EDGES_COMBINED_WO_LAB_OFFICE_VISITS

-- Final Vertices Table

SELECT * INTO VERTICES_COMBINED_TOP8_PRUNE FROM 
(
SELECT * FROM VERTICES_TOP8_PRUNE
UNION 
SELECT * FROM VERTICES_NOT_TOP8_PRUNE
) AS VERTICES_COMBINED_WO_LAB_OFFICE_VISITS
