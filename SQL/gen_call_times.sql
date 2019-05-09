/* TCT Volume and FTE */
SELECT   c.*, ido_sec / 60 / 60 / 7 / mnap as FTE
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
           
 
/* EXPORT4 Volume and FTE */
SELECT   a.idoszak, db, ido_sec / 60 / 60 / 7 / mnap AS FTE
  FROM   (  SELECT   TRUNC (f_idopont, 'MM') AS idoszak,
                     COUNT (f_paid) AS db,
                     SUM (call_time) AS ido_sec
              FROM   MESTERR.EXPORT_PA_WFLOG5
             WHERE   call_time > 0
             and hun1 is not null
             and wflog_user LIKE 'CCC/%'
          GROUP BY   TRUNC (f_idopont, 'MM')
          ORDER BY   TRUNC (f_idopont, 'MM')) a,
         t_mnap b
 WHERE   a.idoszak = b.idoszak;



/* Formatted on 2019. 05. 09. 15:20:18 (QP5 v5.115.810.9015) */
SELECT   COUNT ( * )
  FROM   MESTERR.EXPORT_PA_WFLOG5
 WHERE   call_time is not null AND hun1 IS NULL AND wflog_user LIKE 'CCC/%';
 
 
select * from  MESTERR.EXPORT_PA_WFLOG5;