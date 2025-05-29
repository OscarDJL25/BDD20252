--Practica 2 "PLANES DE EJECUCION"
--// 1.- Crear una base de datos con el nombre: practicaPE 
create databese practicaPE

--// 2.- Copiar a la base de datos practicaPE las siguientes tablas de la base de datos AdventureWorks 
        use practicaPE
        
        ---/ a) Sales.SalesOrderHeader
                  select * 
                  into practicaPE.dbo.SalesOrderHeader
                  from AdventureWorks2019.Sales.SalesOrderHeader;
        --// select * from SalesOrderHeader --(31,465 rows)
        	
        ---/ b) Sales.SalesOrderHeader
                  select * 
                  into practicaPE.dbo.SalesOrderDetail
                  from AdventureWorks2019.Sales.SalesOrderDetail;
        --// select * from SalesOrderDetail --(121,317 rows)
        	
        ---/ c) Sales.Customer
                  select * 
                  into practicaPE.dbo.SalesCustomer
                  from AdventureWorks2019.Sales.Customer;
        --// select * from SalesCustomer --(19,820 rows)
        	
        ---/ d) Sales.Sales.Territory
                  select * 
                  into practicaPE.dbo.SalesTerritory
                  from AdventureWorks2019.Sales.SalesTerritory;
        --// select * from SalesTerritory --(10 rows)
        	
        ---/ e) Production.Product
                  select * 
                  into practicaPE.dbo.ProductionProduct
                  from AdventureWorks2019.Production.Product;
        --// select * from ProductionProduct --(504 rows)
        	
        ---/ f) Production.ProductCategory
                  select * 
                  into practicaPE.dbo.ProductionProductCategory
                  from AdventureWorks2019.Production.ProductCategory;
        --// select * from ProductionProductCategory --(4 rows)
        	
        ---/ g) Production.ProductSubcategory
                  select * 
                  into practicaPE.dbo.ProductionProductSubcategory
                  from AdventureWorks2019.Production.ProductSubcategory;
        --// select * from ProductionProductSubcategory --(37 rows)
        	
        ---/ h) PersonPerson
                  select BusinessEntityID, FirstName, LastName
                  into practicaPE.dbo.PersonPerson
                  from AdventureWorks2019.Person.Person; --(additionalcotactinfo is type with a shema collection)
        --// select * from PersonPerson --(19,972 rows)

--// 3.- Codificar las siguientes consultas 
    --a. Listar el producto más vendido de cada una de las categorías registradas en la base de datos. 
    --b. Listar el nombre de los clientes con más ordenes por cada uno de los territorios registrados en la base de datos. 
    --c. Listar los datos generales de las ordenes que tengan al menos los mismos productos de la orden con salesorderid =  43676. 

--// 4.- Generar los planes de ejecución de las consultas en la base de datos practicaPE y proponer índices para mejorar el rendimiento de las consultas. 
--// 5.- Generar los planes de ejecución de las consultas en la base de datos AdventureWorks y comparar con los planes de ejecución del punto 4. 
--// 6.- Generar los planes de ejecución de las consultas 3, 4 y 5 de la práctica de consultas en la base de datos Covid y proponer índices para mejorar el rendimiento. 
    -- Consulta 3; indice propuesto;
                  CREATE INDEX idx_morbilidades_confirmados
                  ON datoscovid (clasificacion_final)
                  INCLUDE (diabetes, obesidad, hipertension);
    -- Consulta 4; indice propuesto;
                  CREATE INDEX idx_filtros_con_include
                  ON datoscovid (CLASIFICACION_FINAL, HIPERTENSION, OBESIDAD, DIABETES, TABAQUISMO)
                  INCLUDE (Entidad_Res, Municipio_Res);
    -- Consulta 5; indice propuesto;
                  CREATE INDEX idx_casos_recuperados_neumonia_inc
                  ON datoscovid (CLASIFICACION_FINAL, FECHA_DEF, NEUMONIA)
                  INCLUDE (ENTIDAD_RES);


--// 7.- Comparar los planes de ejecución del punto 6 con los planes de ejecución de otro equipo. 
--// 8.- Conclusiones por equipo argumentando la selección de índices.

