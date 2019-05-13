/* Test: TCT Volume and FTE */
SELECT   c.*, ido_sec / 60 / 60 / 7 / mnap AS FTE
  FROM   (SELECT   a.*, b.mnap
            FROM   (  SELECT   TRUNC (idopont, 'MM') AS idoszak,
                               COUNT (f_hivas_azon) db,
                               SUM (ido) ido_sec
                        FROM   (SELECT   DISTINCT f_hivas_azon, idopont, ido
                                  FROM   mesterr.pa_ivk_hivasido)
                    GROUP BY   TRUNC (idopont, 'MM')
                    ORDER BY   TRUNC (idopont, 'MM')) a,
                   t_mnap b
           WHERE   a.idoszak = b.idoszak) c;


/* Test: EXPORT5 Volume and FTE */
SELECT   a.idoszak, db, ido_sec / 60 / 60 / 7 / mnap AS FTE
  FROM   (  SELECT   TRUNC (f_idopont, 'MM') AS idoszak,
                     COUNT (f_paid) AS db,
                     SUM (call_time) AS ido_sec
              FROM   MESTERR.EXPORT_PA_WFLOG5
             WHERE   call_time > 0 --and hun1 is not null
                     AND wflog_user LIKE 'CCC/%'
          GROUP BY   TRUNC (f_idopont, 'MM')
          ORDER BY   TRUNC (f_idopont, 'MM')) a,
         t_mnap b
 WHERE   a.idoszak = b.idoszak;



/* Formatted on 2019. 05. 10. 10:24:01 (QP5 v5.115.810.9015) */
DROP TABLE t_call_times;
COMMIT;

CREATE TABLE t_call_times
AS
     SELECT   DISTINCT
              f_paid AS case_id,
              f_idopont AS event_end,
              wflog_user AS user_id,
              CASE
                 WHEN call_time IS NOT NULL
                      OR (attrib2 = 'Call Center' AND attrib3 = 'CALL')
                 THEN
                    'CALL'
                 WHEN attrib2 = 'Mail' AND attrib3 = 'Normal'
                 THEN
                    'MAIL'
                 WHEN attrib2 = 'Fax' AND attrib3 = 'Normal'
                 THEN
                    'FAX'
                 WHEN attrib2 = 'PubWeb' AND attrib3 = 'Normal'
                 THEN
                    'PWEB'
                 ELSE
                    'DOC'
              END
                 AS event_channel,
              CASE
                 WHEN hun1 = 'Vegrehajtva'
                 THEN
                    'Vegrehajtas'
                 WHEN hun1 = 'Reklamacio  OKK-ba tovabbitva'
                 THEN
                    'Reklamacio OKK-ba tovabbitas'
                 ELSE
                    REGEXP_REPLACE (NVL (hun1, attrib1), '->.*', '')
              END
                 AS activity_hu,
              REGEXP_REPLACE (NVL (hun1eng, attrib1eng), '->.*', '')
                 AS activity_en,
              attrib0 AS case_type_hu,
              attrib0eng AS case_type_en,
              attrib0_p AS case_type_prob,
              CASE
                 WHEN attrib0_p >= 0.9 THEN '0.9-'
                 WHEN attrib0_p BETWEEN 0.8 AND 0.89999 THEN '0.8-0.9'
                 WHEN attrib0_p BETWEEN 0.7 AND 0.79999 THEN '0.7-0.8'
                 WHEN attrib0_p BETWEEN 0.6 AND 0.69999 THEN '0.6-0.7'
                 WHEN attrib0_p BETWEEN 0.5 AND 0.59999 THEN '0.5-0.6'
                 WHEN attrib0_p < 0.5 THEN '-0.5'
              END
                 AS case_type_prob_cat,
              product_line,
              product_code,
              attrib1,
              attrib1eng,
              call_time
       FROM   MESTERR.EXPORT_PA_WFLOG5
      WHERE   call_time > 0                             --and hun1 is not null
                           AND wflog_user LIKE 'CCC/%'
   ORDER BY   1, 2;
COMMIT;



/* Fix Claim report*/
UPDATE   t_call_times
   SET   case_type_en = 'Claim report'
 WHERE   case_type_en IN ('Car claim', 'Property claim with inspection');

COMMIT;



/* Add specification to provide info reason */
DROP TABLE t_ccc_info_reason_most_common;
COMMIT;

CREATE TABLE t_ccc_info_reason_most_common
AS
   SELECT   attrib1, attrib1eng
     FROM   (SELECT   attrib1,
                      attrib1eng,
                      db,
                      db / SUM (db) OVER () AS ratio
               FROM   (  SELECT   attrib1, attrib1eng, COUNT (case_id) AS db
                           FROM   t_call_times
                           where activity_en = 'Provide information'
                       GROUP BY   attrib1, attrib1eng
                       ORDER BY   3 DESC))
    WHERE   ratio > 0.01;

COMMIT;


UPDATE   t_call_times
   SET   attrib1eng = 'Other'
 WHERE   attrib1eng NOT IN
               (SELECT   attrib1eng FROM t_ccc_info_reason_most_common);
COMMIT;


UPDATE   t_call_times
   SET   activity_en = activity_en || ' ' || attrib1eng
 WHERE   activity_en = 'Provide information';
COMMIT;