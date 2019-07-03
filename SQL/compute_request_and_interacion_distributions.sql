/* Compute request and interacion distributions by request type */

  SELECT   contact_type,
           dist_cnt AS contact_cnt,
           dist_cnt / SUM (dist_cnt) OVER () AS contact_ratio,
           cnt AS interaction_cnt,
           cnt / SUM (cnt) OVER () AS interaction_ratio
    FROM   (  SELECT   CASE
                          WHEN attrib0 = 'Tajekoztatas'
                               AND attrib1 IN
                                        ('Dijrendezettseg',
                                         'Modozati informacioadas')
                          THEN
                             attrib0 || ' ' || attrib1
                          WHEN attrib0 = 'Tajekoztatas'
                               AND attrib1 NOT IN
                                        ('Dijrendezettseg',
                                         'Modozati informacioadas')
                          THEN
                             attrib0 || ' ' || 'Egyeb'
                          ELSE
                             attrib0
                       END
                          AS contact_type,
                       COUNT (f_paid) AS cnt,
                       COUNT (DISTINCT f_paid) AS dist_cnt
                FROM   (SELECT   *
                          FROM   mesterr.export_pa_wflog5
                         WHERE       wflog_user LIKE 'CCC/%'
                                 AND f_idopont >= DATE '2019-01-01'
                                 AND TRIM (hun1) <> 'Visszalepes'
                                 AND f_paid LIKE 'S%'
                        UNION
                        SELECT   *
                          FROM   mesterr.export_pa_wflog5
                         WHERE       wflog_user LIKE 'CCC/%'
                                 AND f_idopont >= DATE '2019-01-01'
                                 AND TRIM (hun1) <> 'Visszalepes'
                                 AND f_paid LIKE 'K%'
                                 AND attrib0 IN
                                          ('Karbejelentes',
                                           'KARBEJELENTES',
                                           'GEPJARMUKAR',
                                           'SZEMLES VAGYONKAR',
                                           'SZEMLE NELKULI VAGYONKAR',
                                           'SZEMELYKAR'))
            GROUP BY   CASE
                          WHEN attrib0 = 'Tajekoztatas'
                               AND attrib1 IN
                                        ('Dijrendezettseg',
                                         'Modozati informacioadas')
                          THEN
                             attrib0 || ' ' || attrib1
                          WHEN attrib0 = 'Tajekoztatas'
                               AND attrib1 NOT IN
                                        ('Dijrendezettseg',
                                         'Modozati informacioadas')
                          THEN
                             attrib0 || ' ' || 'Egyeb'
                          ELSE
                             attrib0
                       END)
ORDER BY   2 DESC;



/* Compute request and interacion distributions by contact type AND contact channel*/

  SELECT   contact_type,
           contact_channel,
           dist_cnt AS contact_cnt,
           dist_cnt / SUM (dist_cnt) OVER () AS contact_ratio,
           dist_cnt / SUM (dist_cnt) OVER (PARTITION BY CONTACT_CHANNEL)
              AS contact_ratio_by_channel,
           cnt AS interaction_cnt,
           cnt / SUM (cnt) OVER () AS interaction_ratio,
           cnt / SUM (cnt) OVER (PARTITION BY CONTACT_CHANNEL)
              AS interaction_ratio_by_channel
    FROM   (  SELECT   contact_type,
                       contact_channel,
                       COUNT (f_paid) AS cnt,
                       COUNT (DISTINCT f_paid) AS dist_cnt
                FROM   (SELECT   b.*,
                                 CASE
                                    WHEN attrib0 = 'Tajekoztatas'
                                         AND attrib1 IN
                                                  ('Dijrendezettseg',
                                                   'Modozati informacioadas')
                                    THEN
                                       attrib0 || ' ' || attrib1
                                    WHEN attrib0 = 'Tajekoztatas'
                                         AND attrib1 NOT IN
                                                  ('Dijrendezettseg',
                                                   'Modozati informacioadas')
                                    THEN
                                       attrib0 || ' ' || 'Egyeb'
                                    ELSE
                                       attrib0
                                 END
                                    AS contact_type,
                                 FIRST_VALUE(event_channel)
                                    OVER (PARTITION BY f_paid
                                          ORDER BY f_idopont
                                          ROWS UNBOUNDED PRECEDING)
                                    AS contact_channel
                          FROM   (SELECT   a.*,
                                           CASE
                                              WHEN call_time IS NOT NULL
                                                   OR (attrib2 = 'Call Center'
                                                       AND attrib3 = 'CALL')
                                              THEN
                                                 'CALL'
                                              WHEN attrib2 = 'Mail'
                                                   AND attrib3 = 'Normal'
                                              THEN
                                                 'MAIL'
                                              WHEN attrib2 = 'Fax'
                                                   AND attrib3 = 'Normal'
                                              THEN
                                                 'FAX'
                                              WHEN attrib2 = 'PubWeb'
                                                   AND attrib3 = 'Normal'
                                              THEN
                                                 'PWEB'
                                              ELSE
                                                 'DOC'
                                           END
                                              AS event_channel
                                    FROM   mesterr.export_pa_wflog5 a
                                   WHERE       wflog_user LIKE 'CCC/%'
                                           AND f_idopont >= DATE '2019-01-01'
                                           AND TRIM (hun1) <> 'Visszalepes'
                                           AND f_paid LIKE 'S%'
                                  UNION
                                  SELECT   a.*,
                                           CASE
                                              WHEN call_time IS NOT NULL
                                                   OR (attrib2 = 'Call Center'
                                                       AND attrib3 = 'CALL')
                                              THEN
                                                 'CALL'
                                              WHEN attrib2 = 'Mail'
                                                   AND attrib3 = 'Normal'
                                              THEN
                                                 'MAIL'
                                              WHEN attrib2 = 'Fax'
                                                   AND attrib3 = 'Normal'
                                              THEN
                                                 'FAX'
                                              WHEN attrib2 = 'PubWeb'
                                                   AND attrib3 = 'Normal'
                                              THEN
                                                 'PWEB'
                                              ELSE
                                                 'DOC'
                                           END
                                              AS event_channel
                                    FROM   mesterr.export_pa_wflog5 a
                                   WHERE       wflog_user LIKE 'CCC/%'
                                           AND f_idopont >= DATE '2019-01-01'
                                           AND TRIM (hun1) <> 'Visszalepes'
                                           AND f_paid LIKE 'K%'
                                           AND attrib0 IN
                                                    ('Karbejelentes',
                                                     'KARBEJELENTES',
                                                     'GEPJARMUKAR',
                                                     'SZEMLES VAGYONKAR',
                                                     'SZEMLE NELKULI VAGYONKAR',
                                                     'SZEMELYKAR')) b)
            GROUP BY   contact_type, contact_channel)
ORDER BY   3 DESC;