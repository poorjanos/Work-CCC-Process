/* Formatted on 2019. 02. 15. 13:00:37 (QP5 v5.115.810.9015) */
/* Preprocess CCC logdata */

/* Gen base table and rename cols */
DROP TABLE T_CCC_PA_OUTPUT5;
COMMIT;

CREATE TABLE T_CCC_PA_OUTPUT5
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
                  REGEXP_REPLACE (hun1, '->.*', '')
            END
               AS activity_hu,
            REGEXP_REPLACE (hun1eng, '->.*', '') AS activity_en,
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
            attrib1 as info_reason_hu,
            case when attrib1 = 'AEGON elerhetosegek kiadasa' then 'Provide AEGON contact info'
            when attrib1 = 'Ajanlat allapot informacio keres' then 'Provide proposal status info'
            when  attrib1 = 'Dijrendezettseg' then 'Premium status'
            when attrib1 = 'Intervencios visszajelzes' then 'Intervention feedback'
            when attrib1 = 'Modozati informacioadas' then 'Provide product info'
            else 'Other'
            as info_reason_en
     FROM   mesterr.export_pa_wflog3
    WHERE       wflog_user LIKE 'CCC/%'
            AND f_paid LIKE 'S%'
            AND hun1 IS NOT NULL
            AND TRIM (hun1) <> 'Visszalepes'
            and attrib0 in ('Torles', 'Tajekoztatas');

COMMIT;


/* Define then drop cases with first event outside 201701.01. and 2018.12.01.*/
DELETE FROM   T_CCC_PA_OUTPUT5
      WHERE   case_id IN
                    (SELECT   case_id
                       FROM   (  SELECT   case_id,
                                          MIN (event_end) first_event_date
                                   FROM   T_CCC_PA_OUTPUT5
                               GROUP BY   case_id)
                      WHERE   first_event_date < DATE '2017-01-01'
                              OR first_event_date >= DATE '2019-01-01');

COMMIT;