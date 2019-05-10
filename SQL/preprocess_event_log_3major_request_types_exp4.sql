/* Formatted on 2019. 05. 08. 13:53:38 (QP5 v5.115.810.9015) */
/* Preprocess CCC logdata for 3 major request types*/

/*******************************************************************************/

/* Gen base table and rename cols for CONTRACT DELETION */
DROP TABLE T_CCC_PA_OUTPUT_TORLES;
COMMIT;

CREATE TABLE T_CCC_PA_OUTPUT_TORLES
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
                  REGEXP_REPLACE (nvl(hun1, '!'||attrib1), '->.*', '')
            END
               AS activity_hu,
            REGEXP_REPLACE (nvl(hun1eng, '!'||attrib1eng ), '->.*', '') AS activity_en,
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
     FROM   mesterr.export_pa_wflog5
    WHERE       wflog_user LIKE 'CCC/%'
            AND f_paid LIKE 'S%'
            --AND hun1 IS NOT NULL
            --AND TRIM (hun1) <> 'Visszalepes'
            AND attrib0 = 'Torles';

COMMIT;


/* Compute most common info types to upgrade activity names*/
DROP TABLE t_ccc_info_reason_most_common_torles;
COMMIT;

CREATE TABLE t_ccc_info_reason_most_common_torles
AS
   SELECT   attrib1, attrib1eng
     FROM   (SELECT   attrib1,
                      attrib1eng,
                      db,
                      db / SUM (db) OVER () AS ratio
               FROM   (  SELECT   attrib1, attrib1eng, COUNT (case_id) AS db
                           FROM   T_CCC_PA_OUTPUT_TORLES
                          WHERE   activity_hu = 'Tajekoztatas'
                       GROUP BY   attrib1, attrib1eng
                       ORDER BY   3 DESC))
    WHERE   ratio > 0.01;

COMMIT;

UPDATE   T_CCC_PA_OUTPUT_TORLES
   SET   attrib1 = 'Egyéb'
 WHERE   attrib1 NOT IN
               (SELECT   attrib1 FROM t_ccc_info_reason_most_common_torles);

COMMIT;

UPDATE   T_CCC_PA_OUTPUT_TORLES
   SET   attrib1eng = 'Other'
 WHERE   attrib1eng NOT IN
               (SELECT   attrib1eng FROM t_ccc_info_reason_most_common_torles);

COMMIT;

UPDATE   T_CCC_PA_OUTPUT_TORLES
   SET   activity_hu = activity_hu || ' ' || attrib1
 WHERE   activity_hu = 'Tajekoztatas';

COMMIT;

UPDATE   T_CCC_PA_OUTPUT_TORLES
   SET   activity_en = activity_en || ' ' || attrib1eng
 WHERE   activity_en = 'Provide information';

COMMIT;

/*******************************************************************************/

/* Gen base table and rename cols for PROVIDE INFORMATION */
DROP TABLE T_CCC_PA_OUTPUT_TAJ;
COMMIT;

CREATE TABLE T_CCC_PA_OUTPUT_TAJ
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
                  REGEXP_REPLACE (nvl(hun1, '!'||attrib1), '->.*', '')
            END
               AS activity_hu,
            REGEXP_REPLACE (nvl(hun1eng, '!'||attrib1eng ), '->.*', '') AS activity_en,
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
     FROM   mesterr.export_pa_wflog5
    WHERE       wflog_user LIKE 'CCC/%'
            AND f_paid LIKE 'S%'
            --AND hun1 IS NOT NULL
            --AND TRIM (hun1) <> 'Visszalepes'
            AND attrib0 = 'Tajekoztatas';

COMMIT;

/* Compute most common info types to upgrade activity names*/
DROP TABLE t_ccc_info_reason_most_common_taj;
COMMIT;

CREATE TABLE t_ccc_info_reason_most_common_taj
AS
   SELECT   attrib1, attrib1eng
     FROM   (SELECT   attrib1,
                      attrib1eng,
                      db,
                      db / SUM (db) OVER () AS ratio
               FROM   (  SELECT   attrib1, attrib1eng, COUNT (case_id) AS db
                           FROM   T_CCC_PA_OUTPUT_TAJ
                          WHERE   activity_hu = 'Tajekoztatas'
                       GROUP BY   attrib1, attrib1eng
                       ORDER BY   3 DESC))
    WHERE   ratio > 0.01;

COMMIT;

UPDATE   T_CCC_PA_OUTPUT_TAJ
   SET   attrib1 = 'Egyéb'
 WHERE   attrib1 NOT IN
               (SELECT   attrib1 FROM t_ccc_info_reason_most_common_taj);

COMMIT;

UPDATE   T_CCC_PA_OUTPUT_TAJ
   SET   attrib1eng = 'Other'
 WHERE   attrib1eng NOT IN
               (SELECT   attrib1eng FROM t_ccc_info_reason_most_common_taj);

COMMIT;

UPDATE   T_CCC_PA_OUTPUT_TAJ
   SET   activity_hu = activity_hu || ' ' || attrib1
 WHERE   activity_hu = 'Tajekoztatas';

COMMIT;

UPDATE   T_CCC_PA_OUTPUT_TAJ
   SET   activity_en = activity_en || ' ' || attrib1eng
 WHERE   activity_en = 'Provide information';

COMMIT;


/*******************************************************************************/

/* Gen base table and rename cols for CLAIM REPORT */
DROP TABLE T_CCC_PA_OUTPUT_KAR;
COMMIT;

CREATE TABLE T_CCC_PA_OUTPUT_KAR
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
                  REGEXP_REPLACE (nvl(hun1, '!'||attrib1 ), '->.*', '')
            END
               AS activity_hu,
            REGEXP_REPLACE (nvl(hun1eng, '!'||attrib1eng ), '->.*', '') AS activity_en,
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
     FROM   mesterr.export_pa_wflog5
    WHERE       wflog_user LIKE 'CCC/%'
            AND f_paid LIKE 'K%'
            --AND hun1 IS NOT NULL
            --AND TRIM (hun1) <> 'Visszalepes'
            AND attrib0 IN
                     ('Karbejelentes', 'GEPJARMUKAR', 'SZEMLES VAGYONKAR');

COMMIT;

UPDATE   T_CCC_PA_OUTPUT_KAR a
   SET   product_line = 'HOUSE'
 WHERE   a.product_line IS NULL AND REGEXP_LIKE (a.product_code, '^2.968.*')
         OR REGEXP_LIKE (a.product_code, '^2.954.*');

COMMIT;

UPDATE   T_CCC_PA_OUTPUT_KAR a
   SET   case_type_hu = 'Karbejelentes';

COMMIT;

UPDATE   T_CCC_PA_OUTPUT_KAR a
   SET   case_type_en = 'Claim report';

COMMIT;

/*******************************************************************************/

/* Merge top3 */
DROP TABLE T_CCC_PA_OUTPUT_TOP3;
COMMIT;

CREATE TABLE T_CCC_PA_OUTPUT_TOP3
AS
   SELECT   * FROM T_CCC_PA_OUTPUT_TORLES
   UNION
   SELECT   * FROM T_CCC_PA_OUTPUT_TAJ
   UNION
   SELECT   * FROM T_CCC_PA_OUTPUT_KAR;

COMMIT;


/* Define then drop cases with first event outside 201701.01. and 2018.12.01.*/

DELETE FROM   T_CCC_PA_OUTPUT_TOP3
      WHERE   case_id IN
                    (SELECT   case_id
                       FROM   (  SELECT   case_id,
                                          MIN (event_end) first_event_date
                                   FROM   T_CCC_PA_OUTPUT_TOP3
                               GROUP BY   case_id)
                      WHERE   first_event_date < DATE '2017-01-01'
                              OR first_event_date >= DATE '2019-01-01');

COMMIT;