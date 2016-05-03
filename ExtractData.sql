-------------------------------------------------------------------------------------------------------
-- this query select data from serie_temporali table, by: 
--    - type of dataseries (rainfall = 2, temperature = 6, relative humidity = 8, radiation = 13)
--    - basin mask with a buffer (the buffer is on station for convenience) 
--    - time (convert to unix epoch)
-- the time is converted to human date
-- the data values are hourly mediated 
-------------------------------------------------------------------------------------------------------

SELECT m.punti_monitoraggio_id,s.metadati_id,strftime('%Y-%m-%d %H', s.dataora / 1000, 'unixepoch') || ":00" as dataora, round(avg(s.valore),1) as valore,s.affidabilita
FROM serie_temporali s,metadati m
WHERE s.metadati_id IN (
	SELECT m.id FROM metadati m
	WHERE m.id IN (
		SELECT m.id FROM metadati m 
		WHERE m.tipologia_serie_temporali_id=8
		AND m.punti_monitoraggio_id IN (
			SELECT p.id FROM basin_mask bm, punti_monitoraggio p 
			WHERE ST_Intersects(bm.the_geom, ST_Buffer(p.the_geom, 5000))
		)
	)
)
AND s.dataora>=strftime('%s','2003-01-01 00:00:00')*1000
AND s.dataora<strftime('%s','2014-01-01 00:00:00')*1000
AND s.metadati_id=m.id
GROUP BY m.punti_monitoraggio_id, strftime('%Y-%m-%d %H', s.dataora / 1000, 'unixepoch')
