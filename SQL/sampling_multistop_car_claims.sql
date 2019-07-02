/* Generate event patterns */
SELECT   event_order, cnt
  FROM   (  SELECT   event_order, COUNT (case_id) AS cnt
              FROM   (  SELECT   case_id,
                                 LISTAGG (call || '_' || activity_hu, ',')
                                    WITHIN GROUP (ORDER BY event_end)
                                    AS event_order
                          FROM   (SELECT   case_id,
                                           event_end,
                                           case_type_en,
                                           product_line,
                                           activity_hu,
                                           CASE
                                              WHEN call_time IS NOT NULL
                                                   AND activity_hu IN
                                                            ('Tajekoztatas',
                                                             'Reklamacio OKK-ba tovabbitas')
                                              THEN
                                                 'CALL'
                                              ELSE
                                                 NULL
                                           END
                                              AS call
                                    FROM   T_CCC_PA_OUTPUT_TOP3_2019)
                         WHERE   product_line = 'CAR'
                                 AND case_type_en = 'Claim report'
                                 AND activity_hu NOT IN
                                          ('Tevekenyseg atadas',
                                           'Kapcsolattartas',
                                           'Gepjarmu karbejelentes',
                                           'Karrogzitesre adas')
                      GROUP BY   case_id)
          GROUP BY   event_order
          ORDER BY   2 DESC);


/* Generate sample */
SELECT   REGEXP_SUBSTR (case_id, 'K-2019/[0-9]{1,6}') AS case_id,
         REGEXP_REPLACE (REGEXP_REPLACE (event_order, 'CALL_', ''), '_', '') as event_pattern
  FROM   (  SELECT   case_id,
                     LISTAGG (call || '_' || activity_hu, ',')
                        WITHIN GROUP (ORDER BY event_end)
                        AS event_order
              FROM   (SELECT   case_id,
                               event_end,
                               case_type_en,
                               product_line,
                               activity_hu,
                               CASE
                                  WHEN call_time IS NOT NULL
                                       AND activity_hu IN
                                                ('Tajekoztatas',
                                                 'Reklamacio OKK-ba tovabbitas')
                                  THEN
                                     'CALL'
                                  ELSE
                                     NULL
                               END
                                  AS call
                        FROM   T_CCC_PA_OUTPUT_TOP3_2019)
             WHERE   product_line = 'CAR' AND case_type_en = 'Claim report'
                     AND activity_hu NOT IN
                              ('Tevekenyseg atadas',
                               'Kapcsolattartas',
                               'Gepjarmu karbejelentes',
                               'Karrogzitesre adas')
          GROUP BY   case_id)
 WHERE   case_id LIKE 'K-2019%'
         AND event_order IN
                  ('_Karbejelentes szemlere kiadva,CALL_Tajekoztatas',
                   '_Karbejelentes szemlere kiadva,_Reklamacio OKK-ba tovabbitas',
                   '_Karbejelentes szemlere kiadva,CALL_Tajekoztatas,CALL_Tajekoztatas',
                   '_Karbejelentes szemlere kiadva,CALL_Tajekoztatas,CALL_Reklamacio OKK-ba tovabbitas')
 ORDER BY 2;