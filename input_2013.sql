-->a
SELECT NU_IMPO batch, 
	SUM(ROUND(CASE CO_MONE
	  WHEN 'SOL' THEN IM_ARGU_ORIG / FA_CAMB 
	  ELSE IM_ARGU_ORIG / 1 
	END,2)) AS amount
/*	,TI_DOCU_TESO, NU_DOCU_TESO, IM_ARGU_ORIG, FA_CAMB_BASE, ROUND(IM_ARGU_ORIG * FA_CAMB_BASE, 2) IM_CALC_PEN, IM_ARGU_NACI, FA_CAMB_BASE, */ 
FROM TDSEGU_ARGU 
WHERE NU_IMPO IN 
(
	SELECT CO_LOTE
	FROM OFIVENT..TCDOCU_CLIE C  INNER JOIN OFIVENT..TDDOCU_CLIE D
	ON C.TI_DOCU = D.TI_DOCU AND C.NU_DOCU = D.NU_DOCU
	WHERE YEAR(C.FE_DOCU) = 2013
	AND C.TI_DOCU = 'FAC'
	AND NOT C.CO_ESTA_DOCU = 'ANU'
	GROUP BY CO_LOTE
)
GROUP BY NU_IMPO
ORDER BY NU_IMPO
/*	AND CO_LOTE IN ('888B','1000')*/

-->b
SELECT NU_IMPO batch, CO_ITEM name, CA_IMPO * 1000 units, IM_UNIT / 1000 value,  (CA_IMPO * IM_UNIT) IM_MATE_OC, 
(
	SELECT SUM(CA_IMPO * IM_UNIT) IM_TOT_OC
	FROM TDIMPT_ORCO WHERE NU_IMPO = IM.NU_IMPO
	GROUP BY NU_IMPO
) IM_TOT_OC
FROM TDIMPT_ORCO IM 
WHERE NU_IMPO IN 
(
	SELECT CO_LOTE
	FROM OFIVENT..TCDOCU_CLIE C  INNER JOIN OFIVENT..TDDOCU_CLIE D
	ON C.TI_DOCU = D.TI_DOCU AND C.NU_DOCU = D.NU_DOCU
	WHERE YEAR(C.FE_DOCU) = 2013
	AND C.TI_DOCU = 'FAC'
	AND NOT C.CO_ESTA_DOCU = 'ANU'
	GROUP BY CO_LOTE
)
/*	AND CO_LOTE IN ('888B','1000') */

-->c
SELECT batch, name_from, SUM(units_from) units_from, name_to, SUM(units_to) units_to
FROM 
(
	SELECT D1.NU_DOCU, D1.CO_LOTE batch, D1.CO_ITEM name_from, D1.CA_DOCU_MOVI units_from, D2.CO_ITEM name_to, D2.CA_DOCU_MOVI units_to
	FROM TDDOCU_ALMA D1 INNER JOIN TDDOCU_ALMA D2 ON D1.TI_DOCU_TRFR = D2.TI_DOCU AND D1.NU_DOCU_TRFR = D2.NU_DOCU
	WHERE D1.TI_SITU = 'ACT' 
	AND D2.TI_SITU = 'ACT'
	AND D1.NU_DOCU IN 
	(
		SELECT MIN(DD1.NU_DOCU)		
		FROM TDDOCU_ALMA DD1 INNER JOIN TDDOCU_ALMA DD2 ON DD1.TI_DOCU_TRFR = DD2.TI_DOCU AND DD1.NU_DOCU_TRFR = DD2.NU_DOCU
		WHERE DD1.TI_SITU = 'ACT' 
		AND DD1.TI_DOCU IN ('STP')
		AND NOT DD1.TI_DOCU IN ('ITR','STR')
		GROUP BY DD1.CO_ITEM, DD1.CO_LOTE, DD2.CO_ITEM
	)
	AND D1.CO_LOTE IN 
	(
		SELECT CO_LOTE
		FROM OFIVENT..TCDOCU_CLIE C  INNER JOIN OFIVENT..TDDOCU_CLIE D
		ON C.TI_DOCU = D.TI_DOCU AND C.NU_DOCU = D.NU_DOCU
		WHERE YEAR(C.FE_DOCU) = 2013
		AND C.TI_DOCU = 'FAC'
		AND NOT C.CO_ESTA_DOCU = 'ANU'
		GROUP BY CO_LOTE
	)
	AND D1.TI_DOCU IN ('STP')
	AND NOT D1.TI_DOCU IN ('ITR','STR')
) main
GROUP BY batch, name_from, name_to
/*	AND D1.CO_LOTE IN ('888B','1000') */

-->d 
SELECT CO_ITEM name, CO_LOTE batch
, (SELECT CO_RUBR FROM TMITEM I WHERE I.CO_ITEM = D.CO_ITEM) category
, YEAR(C.FE_DOCU) year,  CA_DOCU units, PR_VENT price
FROM OFIVENT..TCDOCU_CLIE C  INNER JOIN OFIVENT..TDDOCU_CLIE D
ON C.TI_DOCU = D.TI_DOCU AND C.NU_DOCU = D.NU_DOCU
WHERE YEAR(C.FE_DOCU) = 2013
AND C.TI_DOCU = 'FAC'
AND NOT C.CO_ESTA_DOCU = 'ANU'
/*AND D.CO_LOTE IN ('888B','1000')*/

