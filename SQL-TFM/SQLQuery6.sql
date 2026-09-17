use [TFM Imperial Tobacco]

USE [TFM Imperial Tobacco];

WITH Product_Clean AS (
    SELECT Product_Code, SIZE, Format,
           ROW_NUMBER() OVER (
               PARTITION BY Product_Code 
               ORDER BY CASE WHEN Format = 'ATA' THEN 1 ELSE 2 END
           ) AS rn
    FROM Product
)
SELECT Product_Code, SIZE, Format
FROM Product_Clean
WHERE rn = 1;
-- Limpieza previa: Natu122 duplicado
WITH Product_Clean AS (
    SELECT Product_Code, SIZE, Format,
           ROW_NUMBER() OVER (
               PARTITION BY Product_Code 
               ORDER BY CASE WHEN Format = 'ATA' THEN 1 ELSE 2 END
           ) AS rn
    FROM Product
)

SELECT s.*, 
       a.Affiliated_NAME, a.POSTALCODE, a.PROVINCIA, a.Location, a.Tam_m2,
       p.SIZE, p.Format
INTO TablaMaestra3
FROM SalesDay s
LEFT JOIN AffiliatedOutlets_Enriched a 
    ON s.Affiliated_Code = a.Affiliated_Code
LEFT JOIN Product_Clean p
    ON s.Product_Code = p.Product_Code
    AND p.rn = 1;




SELECT TOP 3 * FROM DeliveryDay;
SELECT TOP 3 * FROM [dbo].[OutOfStock(Rotura)];
SELECT TOP 3 * FROM RouteDay;


USE [TFM Imperial Tobacco]

Select s.*, a.Affiliated_NAME, a.POSTALCODE, a.PROVINCIA, a.Location, a.Tam_m2 

--INTO TablaMaestra3

From SalesDay s
LEFT JOIN AffiliatedOutlets_Enriched a 
ON s.Affiliated_Code = a.Affiliated_Code

 

-- PASO 1: Añadir las columnas vacías
ALTER TABLE TablaMaestra3
ADD Delivery_Unidades FLOAT,
    Flag_OoS     INT,
    Flag_Ruta    INT;


-- PASO 2: Rellenar entregas
UPDATE TablaMaestra3
SET Delivery_Unidades = (
    SELECT ISNULL(SUM(d.Delivery_Uds), 0)
    FROM DeliveryDay d
    WHERE d.Delivery_DAY      = TablaMaestra3.Sales_DAY
    AND d.Affiliated_Code     = TablaMaestra3.Affiliated_Code
    AND d.Product_Code        = TablaMaestra3.Product_Code
);

-- PASO 3: Rellenar flag de rotura de stock
UPDATE TablaMaestra3
SET Flag_OoS = (
    SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM [dbo].[OutOfStock(Rotura)] o
    WHERE o.OoS_DAY           = TablaMaestra3.Sales_DAY
    AND o.Affiliated_Code     = TablaMaestra3.Affiliated_Code
    AND o.Product_Code        = TablaMaestra3.Product_Code
);

-- PASO 4 corregido: Flag de ruta
UPDATE TablaMaestra3
SET Flag_Ruta = (
    SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM RouteDay r
    WHERE CAST(CONVERT(VARCHAR, r.Route_DAY, 112) AS FLOAT)
          = TablaMaestra3.Sales_DAY
    AND r.Affiliated_Code = TablaMaestra3.Affiliated_Code
);

-- Añadir las tres columnas que faltan
ALTER TABLE TablaMaestra3
ADD SIZE        VARCHAR(20),
    Formato     VARCHAR(10);

-- Rellenar SIZE y Formato desde Product
UPDATE TablaMaestra3
SET SIZE    = p.SIZE,
    Formato = p.Format
FROM Product p
WHERE TablaMaestra3.Product_Code = p.Product_Code;

--Eliminar columna CPRO
--ALTER TABLE TablaMaestra3
--DROP COLUMN CPRO;

select top 100*
from TablaMaestra3


-- Verificación
SELECT TOP 5
    Sales_DAY, Affiliated_Code, Product_Code,
    CPRO, SIZE, Formato
FROM TablaMaestra3;

select top 100*
from TablaMaestra3


--PROBATINAS DE VERIFICACIÓN--
--SELECT TOP 20
    Sales_DAY,
    Affiliated_Code,
    Product_Code,
    Sales_Uds,
    Delivery_Unidades,
    Flag_OoS,
    Flag_Ruta
FROM TablaMaestra3
ORDER BY Flag_OoS DESC;


--PROBATINAS DE VERIFICACIÓN--
-- Cuántos días tuvieron rotura declarada
SELECT COUNT(*) AS Dias_Con_Rotura
FROM TablaMaestra3
WHERE Flag_OoS = 1;

-- Cuántos días había ruta programada
SELECT COUNT(*) AS Dias_Con_Ruta
FROM TablaMaestra3
WHERE Flag_Ruta = 1;

-- Cuántos registros tienen entregas negativas
SELECT COUNT(*) AS Entregas_Negativas
FROM TablaMaestra3
WHERE Delivery_Unidades < 0;