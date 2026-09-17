use [TFM Imperial Tobacco]

select top 100*
from TablaMaestra5


DROP TABLE TablaMaestra4;

SELECT COUNT(*) AS Total_Filas FROM TablaMaestra5;
SELECT COUNT(DISTINCT Product_Code) AS Productos_Unicos FROM TablaMaestra5;

SELECT DISTINCT Product_Code FROM Product
EXCEPT
SELECT DISTINCT Product_Code FROM SalesDay;

SELECT Product_Code, COUNT(*) AS Entregas
FROM DeliveryDay
WHERE Product_Code IN ('Dome019','Dome586','Dome770','Don122','Inte190')
GROUP BY Product_Code;

SELECT Affiliated_Code, COUNT(*) AS Entregas
FROM DeliveryDay
WHERE Product_Code = 'Don122'
GROUP BY Affiliated_Code;