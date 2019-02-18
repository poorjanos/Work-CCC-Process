/* Formatted on 2019. 02. 15. 13:00:37 (QP5 v5.115.810.9015) */
/* Preprocess CCC logdata */

/* Gen base table and rename cols */
DROP TABLE T_CCC_PA_OUTPUT3;
COMMIT;

CREATE TABLE T_CCC_PA_OUTPUT3
AS
   SELECT   f_paid AS case_id,
            f_idopont AS event_end,
            wflog_user AS user_id,
            CASE
               WHEN attrib2 = 'Call Center' THEN 'CALL'
               WHEN attrib2 = 'Mail' THEN 'MAIL'
               WHEN attrib2 = 'Fax' THEN 'FAX'
               WHEN attrib2 = 'PubWeb' THEN 'PWEB'
               ELSE 'DOC'
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
                  REPLACE (hun1, '->', ' ide: ')
            END
               AS activity_hu,
            REPLACE (hun1eng, '->', ' to ') AS activity_en,
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
               AS case_type_prob_cat
     FROM   mesterr.export_pa_wflog3
    WHERE       wflog_user LIKE 'CCC/%'
            AND f_paid LIKE 'S%'
            AND hun1 IS NOT NULL
            AND TRIM (hun1) <> 'Visszalepes';

COMMIT;


/* Define then drop cases with first event outside 201701.01. and 2018.12.01.*/
DELETE FROM   t_ccc_pa_output3
      WHERE   case_id IN
                    (SELECT   case_id
                       FROM   (  SELECT   case_id,
                                          MIN (event_end) first_event_date
                                   FROM   t_ccc_pa_output3
                               GROUP BY   case_id)
                      WHERE   first_event_date < DATE '2017-01-01'
                              OR first_event_date >= DATE '2019-01-01');

COMMIT;


/* Define then drop case types with freq under 1.00% */
DROP TABLE case_type_to_keep;
COMMIT;

CREATE TABLE case_type_to_keep                                 --compute freqs
AS
   SELECT   *
     FROM   (SELECT   a.case_type_hu,
                      a.case_type_cnt,
                      b.total,
                      a.case_type_cnt / b.total AS case_type_rate
               FROM   (  SELECT   DISTINCT
                                  case_type_hu,
                                  COUNT (DISTINCT case_id) AS case_type_cnt
                           FROM   T_CCC_PA_OUTPUT3
                       GROUP BY   case_type_hu
                       ORDER BY   2 DESC) a,
                      (SELECT   COUNT (DISTINCT case_id) AS total
                         FROM   T_CCC_PA_OUTPUT3) b)
    WHERE   case_type_rate > 0.01 AND case_type_hu IS NOT NULL;
COMMIT;



DELETE FROM   t_ccc_pa_output3                    --delete low freq case types
      WHERE   case_type_hu NOT IN
                    (     SELECT   case_type_hu FROM case_type_to_keep)
              OR case_type_hu IS NULL;

COMMIT;