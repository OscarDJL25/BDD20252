use covidHistorico
select* from datoscovid
use covidHistorico
/*****************************************
1.- Listar el top 5 de las entidades con más casos confirmados por cada uno de los años registrados en la base de datos.
 Requisitos:
 Significado de los valores de los catálogos:
 ENTIDAD_RES: Identifica la entidad de residencia del paciente.
 FECHA_INGRESO: Identifica la fecha de ingreso del paciente a la unidad de atención.
 CLASIFICACION_FINAL: Identifica si el paciente es un caso de COVID-19 según el catálogo "CLASIFICACION_FINAL_COVID".
1: CASO DE COVID-19 CONFIRMADO POR ASOCIACIÓN CLÍNICA EPIDEMIOLÓGICA,
2:CASO DE COVID-19 CONFIRMADO POR COMITÉ DE  DICTAMINACIÓN,
3:CASO DE SARS-COV-2  CONFIRMADO
 Responsable de la consulta: Pérez Iturbe Carolina
 Comentarios: 
-ROW_NUMBER(): Enumera los resultados de un conjunto de resultados.
Concretamente, devuelve el número secuencial de una fila dentro de una partición
de un conjunto de resultados, empezando por 1 para la primera fila de cada partición.
-OVER: Define una ventana o un conjunto especificado por el usuario de
filas dentro de un conjunto de resultados de consulta.
-PARTITION BY: Divide el conjunto de resultados de la consulta en particiones. La 
función se aplica a cada partición por separado y el cálculo se reinicia para cada partición.

*****************************************/ 

WITH Ranking AS (
    SELECT 
		ENTIDAD_RES, YEAR(FECHA_INGRESO) AS año, COUNT(*) AS num_casos_confirmados,
        ROW_NUMBER() OVER (PARTITION BY YEAR(FECHA_INGRESO) ORDER BY COUNT(*) DESC) AS rank
    FROM datoscovid
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3')
    GROUP BY ENTIDAD_RES, YEAR(FECHA_INGRESO)
)
SELECT ENTIDAD_RES, año, num_casos_confirmados
FROM Ranking
WHERE rank <= 5
ORDER BY año, rank;


/*****************************************
2.-Listar el municipio con mas casos confirmados recuperados por estado y por año.
Requisitos:
Significado de los valores de los catálogos:
ENTIDAD_RES: Identifica la entidad de residencia del paciente.
FECHA_INGRESO: Identifica la fecha de ingreso del paciente a la unidad de atención.
CLASIFICACION_FINAL: Identifica si el paciente es un caso de COVID-19 según el catálogo "CLASIFICACION_FINAL_COVID".
1: CASO DE COVID-19 CONFIRMADO POR ASOCIACIÓN CLÍNICA EPIDEMIOLÓGICA,
2:CASO DE COVID-19 CONFIRMADO POR COMITÉ DE  DICTAMINACIÓN,
3:CASO DE SARS-COV-2  CONFIRMADO
FECHA_DEF:Identifica la fecha en que el paciente falleció, en caso de recuperación se coloca 9999-99-99
MUNICIPIO_RES:Identifica el municipio de residencia del paciente.
Responsable de la consulta: Pérez Iturbe Carolina
Comentarios:
-ROW_NUMBER(): Enumera los resultados de un conjunto de resultados.
Concretamente, devuelve el número secuencial de una fila dentro de una partición
de un conjunto de resultados, empezando por 1 para la primera fila de cada partición.
-OVER: Define una ventana o un conjunto especificado por el usuario de
filas dentro de un conjunto de resultados de consulta.
-PARTITION BY: Divide el conjunto de resultados de la consulta en particiones. La 
función se aplica a cada partición por separado y el cálculo se reinicia para cada partición.
*****************************************/ 
WITH CasosRecuperados AS (
    SELECT 
        YEAR(FECHA_INGRESO) AS año, ENTIDAD_RES, MUNICIPIO_RES, COUNT(*) AS num_casos_recuperados
    FROM datoscovid
    WHERE 
		  CLASIFICACION_FINAL IN ('1', '2', '3') 
          AND FECHA_DEF = '9999-99-99'  
    GROUP BY 
			YEAR(FECHA_INGRESO), ENTIDAD_RES, MUNICIPIO_RES
),
Ranking AS (
    SELECT 
        año, ENTIDAD_RES, MUNICIPIO_RES, num_casos_recuperados,
        ROW_NUMBER() OVER (PARTITION BY año, ENTIDAD_RES ORDER BY num_casos_recuperados DESC) AS rn
    FROM 
		CasosRecuperados
)
SELECT 
	año, ENTIDAD_RES, MUNICIPIO_RES, num_casos_recuperados
FROM 
	Ranking
WHERE 
	rn = 1;

/*****************************************
3.-Listar el porcentaje de casos confirmados en cada una de las siguientes  morbilidades a nivel nacional: diabetes, obesidad e hipertensión.
Requisitos:
Significado de los valores de los catálogos:
CLASIFICACION_FINAL: Identifica si el paciente es un caso de COVID-19 según el catálogo "CLASIFICACION_FINAL_COVID".
1: CASO DE COVID-19 CONFIRMADO POR ASOCIACIÓN CLÍNICA EPIDEMIOLÓGICA,
2:CASO DE COVID-19 CONFIRMADO POR COMITÉ DE  DICTAMINACIÓN,
3:CASO DE SARS-COV-2  CONFIRMADO
DIABETES: Identifica si el paciente tiene un diagnóstico de diabetes. 1 = SI
OBESIDAD: Identifica si el paciente tiene diagnóstico de obesidad. 1 = SI
HIPERTENSION:Identifica si el paciente tiene un diagnóstico de hipertensión. 1 = SI
Responsable de la consulta: Pérez Iturbe Carolina
Comentarios:
-CAST: Esta funcion convierte una expresión de un tipo de datos a otro
-CASE: Evalúa una lista de condiciones y devuelve una de las varias expresiones de resultado posibles.
La expresión CASE sencilla compara una expresión con un conjunto de expresiones sencillas para determinar el resultado 
admite un argumento ELSE opcional.
*****************************************/ 

SELECT 
    'Diabetes' AS Morbilidad,
    CAST((SUM(CASE WHEN diabetes = 1 AND clasificacion_final IN ('1', '2', '3') THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN clasificacion_final IN ('1', '2', '3') THEN 1 ELSE 0 END)) AS DECIMAL(5, 2)) AS Porcentaje
FROM 
    datoscovid

UNION ALL

SELECT 
    'Obesidad' AS Morbilidad,
    CAST((SUM(CASE WHEN obesidad = 1 AND clasificacion_final IN ('1', '2', '3') THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN clasificacion_final IN ('1', '2', '3') THEN 1 ELSE 0 END)) AS DECIMAL(5, 2)) AS Porcentaje
FROM 
    datoscovid

UNION ALL

SELECT 
    'Hipertension' AS Morbilidad,
    CAST((SUM(CASE WHEN hipertension = 1 AND clasificacion_final IN ('1', '2', '3') THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN clasificacion_final IN ('1', '2', '3') THEN 1 ELSE 0 END)) AS DECIMAL(5, 2)) AS Porcentaje
FROM 
    datoscovid;

/*****************************************
4.-Listar los municipios que no tengan casos confirmados  en todas las morbilidades: hipertensión, diabetes, obesidad y tabaquismo.
Requisitos:
Significado de los valores de los catálogos:
ENTIDAD_RES: Identifica la entidad de residencia del paciente.
CLASIFICACION_FINAL: Identifica si el paciente es un caso de COVID-19 según el catálogo "CLASIFICACION_FINAL_COVID".
1: CASO DE COVID-19 CONFIRMADO POR ASOCIACIÓN CLÍNICA EPIDEMIOLÓGICA,
2:CASO DE COVID-19 CONFIRMADO POR COMITÉ DE  DICTAMINACIÓN,
3:CASO DE SARS-COV-2  CONFIRMADO
MUNICIPIO_RES:Identifica el municipio de residencia del paciente.
DIABETES: Identifica si el paciente tiene un diagnóstico de diabetes. 1 = SI
OBESIDAD: Identifica si el paciente tiene diagnóstico de obesidad. 1 = SI
HIPERTENSION:Identifica si el paciente tiene un diagnóstico de hipertensión. 1 = SI
TABAQUISMO: Identifica si el paciente tiene hábito de tabaquismo. 1 = SI
Responsable de la consulta: Pérez Iturbe Carolina
Comentarios: Sin comentarios
*****************************************/ 
select distinct 
				Entidad_Res, Municipio_res
from
	datoscovid
where
	CLASIFICACION_FINAL not in(1,2,3) and HIPERTENSION=1 and OBESIDAD=1 and diabetes=1 and TABAQUISMO=1

/*****************************************
--5.- Listar los estados con más casos recuperados con neumonia.
Requisitos:
Significado de los valores de los catálogos:
ENTIDAD_RES: Identifica la entidad de residencia del paciente.
FECHA_DEF:Identifica la fecha en que el paciente falleció, en caso de recuperación se coloca 9999-99-99
CLASIFICACION_FINAL 
1: CASO DE COVID-19 CONFIRMADO POR ASOCIACIÓN CLÍNICA EPIDEMIOLÓGICA,
2:CASO DE COVID-19 CONFIRMADO POR COMITÉ DE  DICTAMINACIÓN,
3:CASO DE SARS-COV-2  CONFIRMADO
NEUMONIA: Identifica si al paciente se le diagnosticó con neumonía. 1 = SI.
Responsable de la consulta:Pérez Iturbe Carolina
Comentarios: 
-TOP: Limita las filas devueltas en un conjunto de resultados de la consulta a un número o porcentaje de filas especificado en SQL Server.
Esta consulta no se divide por años ya que esto no se especifica es el resultado total, se muestran unicamente 3 ya que 
la consulta dice listar los estados con más casos recuperados y no se epecifica cuantos. 
*****************************************/ 
WITH CasosRecuperados AS (
    SELECT 
        ENTIDAD_RES,
        COUNT(*) AS num_casos_recuperados_con_neumonia
    FROM datoscovid
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
          AND FECHA_DEF = '9999-99-99' 
          AND NEUMONIA = '1' 
    GROUP BY ENTIDAD_RES
)
SELECT TOP 3 
    ENTIDAD_RES,
    num_casos_recuperados_con_neumonia
FROM CasosRecuperados
ORDER BY num_casos_recuperados_con_neumonia DESC;  

/*****************************************
6.- Listar el total de casos confirmados/sospechosos por estado en cada uno de los años registrados en la base de datos.
Requisitos:
Significado de los valores de los catálogos:
ENTIDAD_RES: Identifica la entidad de residencia del paciente.
FECHA_INGRESO: Identifica la fecha de ingreso del paciente a la unidad de atención.
CLASIFICACION_FINAL: Identifica si el paciente es un caso de COVID-19 según el catálogo "CLASIFICACION_FINAL_COVID".
1: CASO DE COVID-19 CONFIRMADO POR ASOCIACIÓN CLÍNICA EPIDEMIOLÓGICA,
2: CASO DE COVID-19 CONFIRMADO POR COMITÉ DE  DICTAMINACIÓN,
3: CASO DE SARS-COV-2  CONFIRMADO
6: CASO SOSPECHOSO
Responsable de la consulta: Pérez Iturbe Carolina
Comentarios: Sin comentarios
*****************************************/ 
select year(FECHA_INGRESO) as año, count(*) num_casos, ENTIDAD_RES
from datoscovid
where CLASIFICACION_FINAL in ('1', '2','3','6') 
group by year(FECHA_INGRESO), ENTIDAD_RES
order by año, ENTIDAD_RES asc


/*****************************************
--7.-Para el año 2020 y 2021 cual fue el mes con mas casos registrados, confirmados, sospechosos, por estado registrado en la base de datos
Requisitos:
Significado de los valores de los catálogos:
ENTIDAD_RES: Identifica la entidad de residencia del paciente.
FECHA_INGRESO: Identifica la fecha de ingreso del paciente a la unidad de atención.
CLASIFICACION_FINAL: Identifica si el paciente es un caso de COVID-19 según el catálogo "CLASIFICACION_FINAL_COVID".
1: CASO DE COVID-19 CONFIRMADO POR ASOCIACIÓN CLÍNICA EPIDEMIOLÓGICA,
2:CASO DE COVID-19 CONFIRMADO POR COMITÉ DE  DICTAMINACIÓN,
3:CASO DE SARS-COV-2  CONFIRMADO
6: CASO SOSPECHOSO
Responsable de la consulta: Pérez Iturbe Carolina
Comentarios: 
-ROW_NUMBER(): Enumera los resultados de un conjunto de resultados.
Concretamente, devuelve el número secuencial de una fila dentro de una partición
de un conjunto de resultados, empezando por 1 para la primera fila de cada partición.
-OVER: Define una ventana o un conjunto especificado por el usuario de
filas dentro de un conjunto de resultados de consulta.
-PARTITION BY: Divide el conjunto de resultados de la consulta en particiones. La 
función se aplica a cada partición por separado y el cálculo se reinicia para cada partición.
*****************************************/ 
WITH CasosPorMes AS (
SELECT 
     ENTIDAD_RES, YEAR(FECHA_INGRESO) AS Año, MONTH(FECHA_INGRESO) AS Mes, 
     COUNT(*) AS total_casos
FROM 
     datoscovid
WHERE 
     CLASIFICACION_FINAL IN ('1', '2', '3', '6') AND YEAR(FECHA_INGRESO) IN (2020, 2021) 
GROUP BY 
     ENTIDAD_RES, YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO)
),
Ranking AS (
    SELECT 
        ENTIDAD_RES, Año, Mes, total_casos,
        ROW_NUMBER() OVER (PARTITION BY ENTIDAD_RES, Año ORDER BY total_casos DESC) AS ranking
    FROM 
        CasosPorMes
)
SELECT 
    CasospM.ENTIDAD_RES, CasospM.Año, CasospM.Mes, CasospM.total_casos
FROM 
    Ranking CasospM
WHERE 
    CasospM.ranking = 1 
ORDER BY 
    CasospM.Año;
		
/***************************************** 
Número de consulta. 8.-Listar el municipio con menos defunciones en el mes con más casos confirmados con 
neumonía en los años 2020 y 2021. 
Requisitos:  N/A
ENTIDAD_RES; 
MUNICIPIO_RES; Identifica el municipio de residencia del paciente. 
CLASIFICACION_FINAL = ‘1’; COVID-19 CONFIRMADO POR ASOCIACIÓN CLÍNICA EPIDEMIOLÓGICA 
NEUMONIA = '1' = SI ,Identifica si al paciente se le diagnosticó con neumonía. 
Responsable de la consulta. Pérez Iturbe Carolina  
MONTH ; devuelve la parte correspondiente al mes de un valor. 
HAVING; es una cláusula que se utiliza para filtrar los resultados de una consulta GROUP BY.   
*****************************************/ 
WITH MesMaxCasos AS (
	-- Paso 1: Obtener el mes con más casos de neumonía por estado
	SELECT 
		ENTIDAD_RES,
		MONTH(FECHA_INGRESO) AS mes_max,
		COUNT(*) AS total_casos
	FROM datoscovid
	WHERE CLASIFICACION_FINAL = '1' 
		AND NEUMONIA = '1'
		AND FECHA_INGRESO BETWEEN '2020-01-01' AND '2021-12-31'
	GROUP BY ENTIDAD_RES, MONTH(FECHA_INGRESO)
	HAVING COUNT(*) = (
		SELECT MAX(casos)
		FROM (
			SELECT 
				ENTIDAD_RES, 
				MONTH(FECHA_INGRESO) AS mes, 
				COUNT(*) AS casos
			FROM datoscovid
			WHERE CLASIFICACION_FINAL = '1' 
				AND NEUMONIA = '1'
				AND FECHA_INGRESO BETWEEN '2020-01-01' AND '2021-12-31'
			GROUP BY ENTIDAD_RES, MONTH(FECHA_INGRESO)
		) AS subquery
		WHERE subquery.ENTIDAD_RES = datoscovid.ENTIDAD_RES
	)
), MunicipioMenosDefunciones AS (
-- Paso 2: Encontrar el municipio con menos defunciones dentro del mes con más casos de neumonía
	SELECT 
		d.ENTIDAD_RES, 
		d.MUNICIPIO_RES, 
		COUNT(*) AS total_defunciones
	FROM datoscovid d
	JOIN MesMaxCasos m ON d.ENTIDAD_RES = m.ENTIDAD_RES AND MONTH(d.FECHA_INGRESO) = m.mes_max
	WHERE d.FECHA_DEF != '9999-99-99'  -- Solo fallecidos
	GROUP BY d.ENTIDAD_RES, d.MUNICIPIO_RES
	HAVING COUNT(*) = (
		SELECT MIN(defunciones)
		FROM (
			SELECT 
				ENTIDAD_RES, 
				MUNICIPIO_RES, 
				COUNT(*) AS defunciones
			FROM datoscovid
			WHERE FECHA_DEF != '9999-99-99'
				AND MONTH(FECHA_INGRESO) IN (SELECT mes_max FROM MesMaxCasos WHERE ENTIDAD_RES = datoscovid.ENTIDAD_RES)
			GROUP BY ENTIDAD_RES, MUNICIPIO_RES
		) AS subquery
		WHERE subquery.ENTIDAD_RES = d.ENTIDAD_RES
	)
)
SELECT * FROM MunicipioMenosDefunciones
ORDER BY ENTIDAD_RES;

/***************************************** 
Número de consulta. 9.-Listar el top 3 de municipios / ENTIDADES con menos casos recuperados en el año 2021. 
Requisitos:  N/A
ENTIDAD_RES; Identifica la entidad de residencia del paciente. 
FECHA_INGRESO; Identifica la fecha de ingreso del paciente a la unidad de atención. 
FECHA_DEF;  si es ‘9999-99-99’ entonces no murio 
Responsable de la consulta.		Oscar Daniel De Jesus Lucio
GROUP BY agrupa filas con valores idénticos en una o más columnas. 
ORDER BY; ordena los registros resultantes de una consulta por un campo o campos especificados en orden ascendente o descendente. 
*****************************************/  
SELECT TOP 3 
    ENTIDAD_RES, 
    COUNT(*) AS total_fallecimientos
FROM datoscovid
WHERE FECHA_INGRESO BETWEEN '2021-01-01' AND '2021-12-31' 
    AND FECHA_DEF != '9999-99-99'
GROUP BY ENTIDAD_RES
ORDER BY total_fallecimientos DESC;

/***************************************** 
Número de consulta. 10. Listar el porcentaje de casos confirmado por género en los años 2020 y 2021. 
Requisitos:  N/A
FECHA_INGRESO; Identifica la fecha de ingreso del paciente a la unidad de atención. 
CLASIFICACION_FINAL = '1' es CASO DE COVID-19 CONFIRMADO   
Responsable de la consulta.		Oscar Daniel De Jesus Lucio
ROUND; La función ROUND redondea los números hasta el valor entero o decimal más cercano 
*****************************************/  

WITH total_por_anio AS (
    SELECT 
        YEAR(FECHA_INGRESO) AS anio, 
        COUNT(*) AS total
    FROM datoscovid
    WHERE CLASIFICACION_FINAL = '1' 
        AND FECHA_INGRESO BETWEEN '2020-01-01' AND '2021-12-31'
    GROUP BY YEAR(FECHA_INGRESO)
)
SELECT 
    SEXO,
    COUNT(CASE WHEN YEAR(FECHA_INGRESO) = 2020 THEN 1 END) AS total_2020,
    COUNT(CASE WHEN YEAR(FECHA_INGRESO) = 2021 THEN 1 END) AS total_2021,
    ROUND(
        COUNT(CASE WHEN YEAR(FECHA_INGRESO) = 2020 THEN 1 END) * 100.0 
        / (SELECT total FROM total_por_anio WHERE anio = 2020), 2
    ) AS porcentaje_2020,
    ROUND(
        COUNT(CASE WHEN YEAR(FECHA_INGRESO) = 2021 THEN 1 END) * 100.0 
        / (SELECT total FROM total_por_anio WHERE anio = 2021), 2
    ) AS porcentaje_2021
FROM datoscovid
WHERE CLASIFICACION_FINAL = '1' 
    AND FECHA_INGRESO BETWEEN '2020-01-01' AND '2021-12-31'
    AND SEXO IN ('1', '2')
GROUP BY SEXO
ORDER BY SEXO;

/***************************************** 
Número de consulta. 11. Listar el porcentaje de casos hospitalizados por estado en el año 2020. 
Requisitos:  
TIPO_PACIENTE = '2' ; Hospitalizado 
FECHA_INGRESO; Identifica la fecha de ingreso del paciente a la unidad de atención.
Responsable de la consulta.  Oscar Daniel De Jesus Lucio
Comentarios: --

*****************************************/ 
SELECT 
    ENTIDAD_RES, 
    COUNT(*) AS total_hospitalizados,
    CAST(COUNT(*) * 1.0 / (SELECT COUNT(*) FROM datoscovid 
                           WHERE TIPO_PACIENTE = '2' 
                           AND FECHA_INGRESO BETWEEN '2020-01-01' AND '2020-12-31') 
         AS DECIMAL(4,2)) AS porcentaje_hospitalizados
FROM datoscovid
WHERE TIPO_PACIENTE = '2' 
    AND FECHA_INGRESO BETWEEN '2020-01-01' AND '2020-12-31'
    AND ENTIDAD_RES BETWEEN 1 AND 32
GROUP BY ENTIDAD_RES
ORDER BY ENTIDAD_RES;

/***************************************** 
Número de consulta. 12. Listar total de casos negativos por estado en los años 2020 y 2021. 
Requisitos:  
Significado de los valores de los catálogos. 
Responsable de la consulta.  Oscar Daniel De Jesus Lucio
SUM ; sumar conjuntos de datos y ver los resultados en una tabla. 
*****************************************/  
SELECT 
    ENTIDAD_RES, 
    COUNT(*) AS total_casos
FROM datoscovid
WHERE CLASIFICACION_FINAL = '7' 
    AND FECHA_INGRESO BETWEEN '2020-01-01' AND '2021-12-31'
    AND ENTIDAD_RES BETWEEN 01 AND 32 
GROUP BY ENTIDAD_RES
ORDER BY ENTIDAD_RES;

  
/***************************************** 
Número de consulta.	 13. Listar porcentajes de casos confirmados por género en el rango de edades de 20 a 30 años, 
						de 31 a 40 años, de 41 a 50 años, de 51 a 60 años y mayores a 60 años a nivel nacional. 
Requisitos:  ninguno
Significado de los valores de los catálogos; RESULTADO_LAB = '1' = POSITIVO A SARS-COV-2 , FECHA_DEF = '9999-99-99' = No murio
Responsable de la consulta.  Oscar Daniel De Jesus Lucio
SUM ; sumar conjuntos de datos y ver los resultados en una tabla. 
THEN; es el El resultado de una cláusula WHEN cuando se evalúa como true. 
 	[WHEN when_expression THEN then_expression] 
*****************************************/ 

WITH CTE AS (
    SELECT 
        CASE 
            WHEN EDAD BETWEEN 20 AND 30 THEN '20-30'
            WHEN EDAD BETWEEN 31 AND 40 THEN '31-40'
            WHEN EDAD BETWEEN 41 AND 50 THEN '41-50'
            WHEN EDAD BETWEEN 51 AND 60 THEN '51-60'
            WHEN EDAD >= 61 THEN '61+'
        END AS rango_edad,
        SEXO,
        COUNT(*) AS total
    FROM datoscovid
    WHERE EDAD >= 20 AND CLASIFICACION_FINAL = '1'
    GROUP BY 
        CASE 
            WHEN EDAD BETWEEN 20 AND 30 THEN '20-30'
            WHEN EDAD BETWEEN 31 AND 40 THEN '31-40'
            WHEN EDAD BETWEEN 41 AND 50 THEN '41-50'
            WHEN EDAD BETWEEN 51 AND 60 THEN '51-60'
            WHEN EDAD >= 61 THEN '61+'
        END, 
        SEXO
)
SELECT 
    rango_edad,
    SUM(CASE WHEN SEXO = '1' THEN total ELSE 0 END) AS total_mujeres,
    SUM(CASE WHEN SEXO = '2' THEN total ELSE 0 END) AS total_hombres,
    SUM(total) AS total_rango,
    CAST(SUM(CASE WHEN SEXO = '1' THEN total ELSE 0 END) * 100.0 / SUM(total) AS DECIMAL(5,2)) AS porcentaje_mujeres,
    CAST(SUM(CASE WHEN SEXO = '2' THEN total ELSE 0 END) * 100.0 / SUM(total) AS DECIMAL(5,2)) AS porcentaje_hombres
FROM CTE
GROUP BY rango_edad
ORDER BY rango_edad;

/***************************************** 
Número de consulta.	 14 
Requisitos:  ninguno
Significado de los valores de los catálogos; RESULTADO_LAB = '1' = POSITIVO A SARS-COV-2 , FECHA_DEF = '9999-99-99' = No murio
Responsable de la consulta.  Oscar Daniel De Jesus Lucio
-CASE: Evalúa una lista de condiciones y devuelve una de las varias expresiones de resultado posibles. 
La expresión CASE sencilla compara una expresión con un conjunto de expresiones sencillas para determinar el resultado admite un argumento ELSE opcional. 
-GROUP BY: combina registros con valores idénticos en la lista de campos especificados en un único registro. 
*****************************************/ 
SELECT 
    CASE 
        WHEN EDAD <= 12 THEN 'NIÑOS'
        WHEN EDAD BETWEEN 13 AND 18 THEN 'ADOLESCENTES'
        WHEN EDAD BETWEEN 19 AND 69 THEN 'ADULTOS'
        WHEN EDAD >= 70 THEN 'ADULTOS MAYORES'
        ELSE 'SIN CLASIFICAR'
    END AS grupo_edad,    
    COUNT(CASE WHEN YEAR(FECHA_DEF) = 2020 THEN 1 END) AS defunciones_2020,
    COUNT(CASE WHEN YEAR(FECHA_DEF) = 2021 THEN 1 END) AS defunciones_2021
FROM datoscovid
WHERE CLASIFICACION_FINAL = '1' 
    AND FECHA_DEF BETWEEN '2020-01-01' AND '2021-12-31'    
GROUP BY 
    CASE 
        WHEN EDAD <= 12 THEN 'NIÑOS'
        WHEN EDAD BETWEEN 13 AND 18 THEN 'ADOLESCENTES'
        WHEN EDAD BETWEEN 19 AND 69 THEN 'ADULTOS'
        WHEN EDAD >= 70 THEN 'ADULTOS MAYORES'
        ELSE 'SIN CLASIFICAR'
    END
ORDER BY defunciones_2020 DESC, defunciones_2021 DESC;
