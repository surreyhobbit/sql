-- Profiling Stammdaten Summit

--***************Derivate "Asset-Based"****************************************************************

--Ausprägungen Klassifizierung:
--Cap
--Floor
--Collar
--Zinsswap/Zinswährungsswap
--Portfolio CDS
--Single Name CDS
--Finanzgarantie

SELECT *
  FROM (SELECT   CASE
                    WHEN env.dmownertable = 'CAPTR'
                    AND env.desk = 'DERIVATIVE'
                    AND ast.TYPE = 'IRG'
                    AND ast.SUBTYPE = 'CAP'
                       THEN 'Cap'
                    WHEN env.dmownertable = 'CAPTR'
                    AND env.desk = 'DERIVATIVE'
                    AND ast.TYPE = 'IRG'
                    AND ast.SUBTYPE = 'FLOOR'
                       THEN 'Floor'
                    WHEN env.dmownertable = 'CAPTR'
                    AND env.desk = 'DERIVATIVE'
                    AND ast.TYPE = 'IRG'
                    AND ast.SUBTYPE NOT IN ('CAP', 'FLOOR')
                       THEN 'Collar'
                    WHEN (    env.dmownertable IN ('SWAP', 'EXOTIC')
                          AND env.desk = 'DERIVATIVE'
                          AND env.book = 'DERIVATE'
                         )
                     OR (    env.dmownertable IN ('SWAP', 'EXOTIC')
                         AND env.desk = 'K'
                         AND env.book = 'K_DERIVATE'
                        )
                       THEN 'Zinsswap/Zinswährungsswap'
                    WHEN env.dmownertable = 'EXOTIC'
                    AND env.desk = 'KV_DERIVATE'
                    AND env.book = 'POOL_CDS'
                       THEN 'Portfolio CDS'
                    WHEN env.dmownertable = 'EXOTIC'
                    AND env.desk = 'KV_DERIVATE'
                    AND env.book = 'SINGLE_CDS'
                       THEN 'Single Name CDS'
                    WHEN env.dmownertable = 'EXOTIC'
                    AND env.desk = 'KV_DERIVATE'
                    AND env.book = 'FINGAR_CDS'
                       THEN 'Finanzgarantie'
                    ELSE ''
                 END AS klassifizierung,
                 env.tradeid, env.dmownertable, env.desk, env.book,
                 env.audit_authorized, env.audit_version,
                 env.cdmhaltekategorie, env.tradedate, env.structureid,
                 env.cdmfinzweck, env.cdmfxverwzweck,
                 env.cdmhaltekategorieifrs, env.cdmhaltekategorieifrsfinal,
                 env.cdmliquiport, env.company, env.folder, ast.dmassetid,
                 ast.TYPE, ast.SUBTYPE, ast.ccy, ast.effdate, ast.matdate,
                 ast.interest_basis, ast.pors, ast.interest_fixfloat,
                 ast.sched_pay_freq, cdo.transactionid
            --azg.OE_ABT_FFC_ID,
        FROM     dmenv env LEFT OUTER JOIN dmasset ast
                 ON ast.dmownertable = env.dmownertable
               AND ast.tradeid = env.tradeid
               AND ast.audit_version = env.audit_version
--left outer join AZG0005 azg
--on azg.OWNER_TABLE = ast.dmownertable
--and azg.TRADE_ID = ast.tradeid
                 LEFT OUTER JOIN
                 (SELECT oiss.tradeid, pool.transactionid
                    FROM cdmcdoiss oiss INNER JOIN cdmcdopool pool
                         ON pool.transactionid = oiss.transactionid
                       AND pool.audit_version = oiss.audit_version
                   WHERE pool.audit_current = 'Y'
                     AND pool.audit_entitystate NOT IN ('PEND', 'DONE')
                     AND oiss.tradeid <> ' ') cdo ON cdo.tradeid = ast.tradeid
           WHERE env.audit_authorized = 'Y'
             AND env.audit_entitystate NOT IN ('PEND', 'DONE')
        ORDER BY env.tradeid) prod
 WHERE prod.klassifizierung IS NOT NULL



--***************Derivate "FX-Geschäfte"****************************************************************

--Ausprägungen Klassifizierung:
--Devisenswap
--Kassa
--Termin

SELECT *
  FROM (SELECT   CASE
                    WHEN env.dmownertable = 'FXSWAP'
                       THEN 'Devisenswap'
                    WHEN env.dmownertable = 'FXSPOT'
                       THEN 'Kassa'
                    WHEN env.dmownertable = 'FXFWD'
                       THEN 'Termin'
                    ELSE ''
                 END AS klassifizierung,
                 env.tradeid, env.dmownertable, env.desk, env.book,
                 env.audit_authorized, env.audit_version,
                 env.cdmhaltekategorie, env.tradedate, env.structureid,
                 env.cdmfinzweck, env.cdmfxverwzweck,
                 env.cdmhaltekategorieifrs, env.cdmhaltekategorieifrsfinal,
                 env.cdmliquiport, env.company, env.folder, fx.spotdate,
                 fx.valdate, fx.xrate, fx.spotrate, fx.soldamt, fx.fwdsoldamt,
                 fx.boughtamt, fx.fwdboughtamt, fx.shortvaldate, fx.pors,
                 fx.soldccy, fx.boughtccy
            --azg.OE_ABT_FFC_ID,
        FROM     dmenv env LEFT OUTER JOIN dmforex fx
                 ON fx.dmownertable = env.dmownertable
               AND fx.tradeid = env.tradeid
               AND fx.audit_version = env.audit_version
--left outer join AZG0005 azg
--on azg.OWNER_TABLE = ast.dmownertable
--and azg.TRADE_ID = ast.tradeid
        WHERE    env.audit_authorized = 'Y'
             AND env.audit_entitystate NOT IN ('PEND', 'DONE')
        ORDER BY env.tradeid) prod
 WHERE prod.klassifizierung IS NOT NULL



--***************Geldmarktgeschäfte/Repo "Asset-Based"****************************************************************

--Ausprägungen Klassifizierung:
--Tagesgeld
--Termingeld
--Tagesgeld b.a.w.
--Sec Lending
--Sell/Buy Back
--Buy/Sell Back
--Repo
--Reverse Repo
--Spitzenrefinanzierungsfazilität mit Zentralbanken
--Wertpapierpensionsgeschäft mit Zentralbanken
--Cash Collateral

SELECT *
  FROM (SELECT   CASE
                    WHEN (    env.dmownertable = 'MM'
                          AND env.desk = 'GELDMARKT'
                          AND env.book = 'TAGESGELDER'
                          AND ast.mmtype IN ('DEPOSIT', 'LOAN')
                         )
                     OR (    env.dmownertable = 'MM'
                         AND env.desk = 'INTGESCH'
                         AND env.book = 'INTTAGES'
                         AND ast.mmtype IN ('CDEPO', 'CLOAN')
                        )
                       THEN 'Tagesgeld'
                    WHEN (    env.dmownertable = 'MM'
                          AND env.desk = 'GELDMARKT'
                          AND env.book = 'TERMINGELDER'
                          AND ast.mmtype IN ('DEPOSIT', 'LOAN')
                         )
                     OR (    env.dmownertable = 'MM'
                         AND env.desk = 'INTGESCH'
                         AND env.book = 'INTTERMIN'
                         AND ast.mmtype IN ('DEPOSIT', 'LOAN')
                        )
                       THEN 'Termingeld'
                    WHEN env.dmownertable = 'MM'
                    AND env.desk = 'GELDMARKT'
                    AND env.book = 'TAGESGELDER'
                    AND ast.mmtype IN ('CDEPO', 'CLOAN')
                       THEN 'Tagesgeld b.a.w.'
                    WHEN env.dmownertable = 'REPO_TR'
                    AND env.desk = 'GELDMARKT'
                    AND env.book = 'WP_LEIHE'
                    AND rep.reptype = 'SECL'
                       THEN 'Sec Lending'
                    WHEN env.dmownertable = 'REPO_TR'
                    AND env.desk = 'GELDMARKT'
                    AND env.book = 'REPO'
                    AND rep.reptype = 'SBBK'
                       THEN 'Sell/Buy Back'
                    WHEN env.dmownertable = 'REPO_TR'
                    AND env.desk = 'GELDMARKT'
                    AND env.book = 'REPO'
                    AND rep.reptype = 'BSBK'
                       THEN 'Buy/Sell Back'
                    WHEN env.dmownertable = 'REPO_TR'
                    AND env.desk = 'GELDMARKT'
                    AND env.book = 'REPO'
                    AND rep.reptype = 'REPO'
                       THEN 'Repo'
                    WHEN (    env.dmownertable = 'REPO_TR'
                          AND env.desk = 'GELDMARKT'
                          AND env.book = 'REPO'
                          AND rep.reptype = 'REV'
                          AND rep.repomkttype = ' '
                         )
                     OR (    env.dmownertable = 'REPO_TR'
                         AND env.desk = 'GELDMARKT'
                         AND env.book = 'REPO'
                         AND rep.reptype = 'REV'
                         AND rep.repomkttype = 'TRIPARTY'
                        )
                       THEN 'Reverse Repo'
                    WHEN env.dmownertable = 'REPO_TR'
                    AND env.desk = 'GELDMARKT'
                    AND env.book = 'REPO'
                    AND rep.reptype = 'NOCL'
                    AND rep.repomkttype = 'CBK'
                       THEN 'Spitzenrefinanzierungsfazilität mit Zentralbanken'
                    WHEN env.dmownertable = 'REPO_TR'
                    AND env.desk = 'GELDMARKT'
                    AND env.book = 'REPO'
                    AND rep.reptype = 'NOCL'
                    AND rep.repomkttype = 'CBKT'
                       THEN 'Wertpapierpensionsgeschäft mit Zentralbanken'
                    WHEN env.dmownertable = 'REPO_TR'
                    AND env.desk = 'PORTFOLIO'
                    AND env.book = 'SICHERHEITEN'
                    AND rep.reptype = 'CMNC'
                       THEN 'Cash Collateral'
                    ELSE ''
                 END AS klassifizierung,
                 env.tradeid, env.dmownertable, env.desk, env.book,
                 env.audit_authorized, env.audit_version,
                 env.cdmhaltekategorie, env.tradedate, env.structureid,
                 env.cdmfinzweck, env.cdmfxverwzweck,
                 env.cdmhaltekategorieifrs, env.cdmhaltekategorieifrsfinal,
                 env.cdmliquiport, env.company, env.folder, ast.dmassetid,
                 ast.TYPE, ast.SUBTYPE, ast.ccy, ast.effdate, ast.matdate,
                 ast.interest_basis, ast.pors, ast.interest_fixfloat,
                 ast.sched_pay_freq, rep.reptype, rep.repomkttype
            --sfloat.sEVTYP,
            --sfloat.sFLTYPE,
            --azg.OE_ABT_FFC_ID,
        FROM     dmenv env LEFT OUTER JOIN dmasset ast
                 ON ast.dmownertable = env.dmownertable
               AND ast.tradeid = env.tradeid
               AND ast.audit_version = env.audit_version
                 LEFT OUTER JOIN dmrepo rep
                 ON rep.tradeid = ast.tradeid
               AND rep.audit_version = ast.audit_version
--left outer join AZG0005 azg
--on azg.OWNER_TABLE = ast.dmownertable
--and azg.TRADE_ID = ast.tradeid
        WHERE    env.audit_authorized = 'Y'
             AND env.audit_entitystate NOT IN ('PEND', 'DONE')
        ORDER BY env.tradeid) prod
 WHERE prod.klassifizierung IS NOT NULL


--*************** Optionen ****************************************************************

--Ausprägungen Klassifizierung:
--Swaption
--Zinsoption

SELECT *
  FROM (SELECT   CASE
                    WHEN env.dmownertable = 'SWAPTION'
                    AND env.desk = 'DERIVATIVE'
                    AND env.book = 'DERIVATE'
                    AND env.structureid = ' '
                       THEN 'Swaption'
                    WHEN env.dmownertable = 'CAPTR'
                    AND env.desk = 'DERIVATIVE'
                    AND env.book = 'DERIVATE'
                    AND env.structureid = ' '
                       THEN 'Zinsoption'
                    ELSE ''
                 END AS klassifizierung,
                 env.tradeid, env.dmownertable, env.desk, env.book,
                 env.audit_authorized, env.audit_version,
                 env.cdmhaltekategorie, env.tradedate, env.structureid,
                 env.cdmfinzweck, env.cdmfxverwzweck,
                 env.cdmhaltekategorieifrs, env.cdmhaltekategorieifrsfinal,
                 env.cdmliquiport, env.company, env.folder, opt.dmoptionid,
                 opt.exercise, opt.expdate, opt.pors, opt.eventproc,
                 opt.notccy, opt.stkccy, opt.style, opt.underlying,
                 opt.strike, opt.settledata_stlmode, opt.premdata_premium,
                 opt.premdata_ccy, opt.premdata_date, opt.porc,
                 opt.settledata_partexer
            --azg.OE_ABT_FFC_ID,
        FROM     dmenv env LEFT OUTER JOIN dmoption opt
                 ON opt.dmownertable = env.dmownertable
               AND opt.tradeid = env.tradeid
               AND opt.audit_version = env.audit_version
--left outer join AZG0005 azg
--on azg.OWNER_TABLE = opt.dmownertable
--and azg.TRADE_ID = opt.tradeid
        WHERE    env.audit_authorized = 'Y'
             AND env.audit_entitystate NOT IN ('PEND', 'DONE')
        ORDER BY env.tradeid) prod
 WHERE prod.klassifizierung IS NOT NULL


--*************** Wertpapier-Trades / Schuldscheindarlehen ****************************************************************

--Ausprägungen Klassifizierung:
--Eigene WP
--Fremde WP
--Aktive SSD
--Passive SSD


SELECT *
  FROM (SELECT   CASE
                    WHEN env.dmownertable = 'BOND_TR'
                    AND env.desk IN ('PORTFOLIO', 'FUNDING')
                    AND env.book NOT IN ('MITTELANLAGE', 'ERP')
                    AND env.book NOT LIKE 'SSD%'
                    AND env.book NOT LIKE 'REFIDAR%'
                    AND secast.issuer NOT IN ('76330001', '73170003')
                       THEN 'Fremde WP'
                    WHEN env.dmownertable = 'BOND_TR'
                    AND env.desk IN ('PORTFOLIO', 'FUNDING')
                    AND env.book NOT IN ('MITTELANLAGE', 'ERP')
                    AND env.book NOT LIKE 'SSD%'
                    AND env.book NOT LIKE 'REFIDAR%'
                    AND secast.issuer IN ('76330001', '73170003')
                       THEN 'Eigene WP'
                    WHEN env.dmownertable = 'BOND_TR'
                    AND env.desk = 'INTGESCH'
                    AND env.book = 'MITTELANLAGE'
                       THEN 'Aktive SSD'
                    WHEN env.dmownertable = 'BOND_TR'
                    AND env.desk = 'FUNDING'
                    AND (   env.book = 'ERP'
                         OR env.book LIKE 'SSD%'
                         OR env.book LIKE 'REFIDAR%'
                        )
                       THEN 'Passive SSD'
                    ELSE ''
                 END AS klassifizierung,
                 env.dmownertable, env.tradeid, env.tradedate,
                 env.cdmliquiport, env.producttype, env.cdmhaltekategorie,
                 env.tradestatus, env.audit_entitystate, env.company,
                 env.book, env.desk, bond.sectype, bond.ccy, secast.sec,
                 secast.TYPE, secast.SUBTYPE, secast.productname,
                 secast.cdmtrennungspflicht, secast.cdmseceffdate,
                 secast.cdmsecmatdate, secast.issuer, secast.issueprice,
                 secast.sizeissue, secast.externalsource,
                 secast.cdmcboersennotiert, secast.cdmboersenfaehig,
                 secast.cdmnotenbankf, secast.priceformula,
                 secast.lformat_priceform_units, secast.redemptionprice,
                 secast.stepdebt, secast.cdmgewaehrgeber, secast.cdmstufenzins,
                 secast.cdmverbrassetclass, secast.cdmverbrassetregion,
                 secast.dmassetid, secast.interest_basis,
                 secast.sched_pay_cal, secast.effdate, secast.matdate,
                 secast.interest_fixfloat,
                                          --sfloat.sEVTYP,
                                          --sfloat.sFLTYPE,
                                          secast.pors, cdo.transactionid
            --azg.OE_ABT_FFC_ID,
        FROM     dmenv env LEFT OUTER JOIN dmbond bond
                 ON env.tradeid = bond.tradeid
               AND env.audit_version = bond.audit_version
                 LEFT OUTER JOIN
                 (SELECT sec.audit_action, sec.audit_ishistory, sec.sec,
                         sec.TYPE, sec.SUBTYPE, sec.productname,
                         sec.cdmtrennungspflicht, sec.cdmseceffdate,
                         sec.cdmsecmatdate, sec.issuer, sec.issueprice,
                         sec.sizeissue, sec.externalsource,
                         sec.cdmcboersennotiert, sec.cdmboersenfaehig,
                         sec.cdmnotenbankf, sec.priceformula,
                         sec.lformat_priceform_units, sec.redemptionprice,
                         sec.stepdebt, sec.ccy, sec.cdmgewaehrgeber,
                         sec.cdmstufenzins, sec.cdmverbrassetclass,
                         sec.cdmverbrassetregion, sast.dmassetid,
                         sast.interest_basis, sast.sched_pay_cal,
                         sast.effdate, sast.matdate, sast.interest_fixfloat,
                         sast.pors
                    --sfloat.sEVTYP,
                    --sfloat.sFLTYPE,
                  FROM   dmsec sec INNER JOIN dmsasset sast
                         ON sast.dmassetid = sec.dmassetid
                       AND sast.audit_version = sec.audit_version
                   WHERE sec.audit_current = 'Y'
                     AND sec.audit_entitystate NOT IN ('PEND', 'DONE')) secast
                 ON secast.sec = bond.sec
                 LEFT OUTER JOIN
                 (SELECT iss.secid, pool.transactionid
                    FROM cdmcdoiss iss INNER JOIN cdmcdopool pool
                         ON pool.transactionid = iss.transactionid
                       AND pool.audit_version = iss.audit_version
                   WHERE pool.audit_current = 'Y'
                     AND pool.audit_entitystate NOT IN ('PEND', 'DONE')
                     AND iss.secid <> ' ') cdo ON cdo.secid = secast.sec
           WHERE env.audit_current = 'Y'
             AND env.audit_entitystate NOT IN ('PEND', 'DONE')
--and env.desk not in ('BEWERT','INTGESCH')
--and bond.bondMktType not in  ('DEPTRN')
        ORDER BY env.tradeid) prod
 WHERE prod.klassifizierung IS NOT NULL




