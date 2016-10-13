-- Ermittlung der DIS - relevanten Geschäfte bzw. Komponenten
with REL_KOMP as (Select e.audit_version, e.company, e.cdmliquiport, e.tradedate, e.cdmhaltekategorieifrsfinal, e.cdmhaltekategorieifrs, e.cdmfinzweck, e.cdmtranche, e.tradestatus, e.ref_dt, e.wf_run_id as env_run 
                                                                                                , fst.HERK_SYS_SL, fst.SPLIT_SEP, fst.OBJ_TYP_GES_SL, fst.strukt_flg, fos.MANDANT_DIS_SL, fos.BUKRS_SL, ftt.trade_type
                                                                                                , fhi.hkat_i9_sl, fss.status_id, fds.depot_id, fpi.portfolio_i9_sl   
                                                                                                , fstk.* from DISSTA.STA_SUK_VDTS_DMENV e join (select ROW_NUMBER() OVER (PARTITION BY fstk.eg_tik_id, fstk.komp_nr order by fstk.subid desc)
                                                                                                        AS row_num, fstk.*
                                                                                                from DISCORE.DWH_FMTE_SUMMIT_TRADE_KOMP fstk) fstk on e.tradeid = fstk.tradeid and e.dmownertable = fstk.dmownertable 
                                                                                  join DISCORE.DWH_FMTE_SUMMIT_TRADE fst on fstk.EG_TIK_ID = fst.EG_TIK_ID
                                                                                  left join DISCORE.DWH_FMRE_ORG_SUMMIT fos on e.COMPANY = fos.company
                                                                                  left join DISCORE.DWH_FMRE_TRADETYPE_SUMMIT ftt on e.dmownertable = ftt.dmownertable
                                                                                  left join DISCORE.DWH_FMRE_HKAT_IFRS9_SUMMIT fhi on fhi.cdmhaltekategorieifrs = e.cdmhaltekategorieifrs  
                                                                                  left join DISCORE.DWH_FMRE_STATUS_SUMMIT fss on e.tradestatus = fss.tradestatus
                                                                                  left join DISCORE.DWH_FMRE_DEPOT_SUMMIT fds on e.cdmliquiport = fds.cmdliquiport
                                                                                                                              and fst.herk_sys_sl = fds.herk_sys_sl
                                                                                  left join DISCORE.DWH_FMRE_PORTFOLIO_IFRS9_SUMMIT fpi on e.cdmliquiport = fpi.cdmliquiport                                                                           
where e.audit_current = 'Y'
and e.dmownertable = 'BOND_TR'
and e.wf_run_id = (select MAX(wf_run_id) from DISSTA.STA_SUK_VDTS_DMENV)
and fst.HERK_SYS_SL = '101'
and fst.DIS_CORE_REL_FLG = '1'
and fstk.DIS_CORE_REL_FLG = '1'
and fstk.wf_name = 'wf_core_summit_dwh_fmte_m3_kfw'
)
,
-- Ermittlung ZGS - Daten -- outer join - falls ZGS - Daten fehlen
GET_REL_KOMP_ZGS as (select zgs.ID, zgs.prod_stufe_4_id, zgs.oe_abt_ffc_id, zgs.wf_run_id as zgs_run, a.* from REL_KOMP a left join DISSTA.STA_ZGS_AZG0005 zgs on a.tradeid = zgs.trade_id and a.dmownertable = zgs.owner_table
where zgs.wf_run_id = (select MAX(wf_run_id) from DISSTA.STA_ZGS_AZG0005)
--and row_num = 1
)
,
-- Ermittlung zusätzlicher Informationen zu den Trades
GET_WP_TRADE_KOMP as (Select  CASE WHEN gsf1.gsform_sl IS NOT NULL THEN gsf1.gsform_sl
                              WHEN gsf2.gsform_sl IS NOT NULL THEN gsf2.gsform_sl
                              WHEN gsf3.gsform_sl IS NOT NULL THEN gsf3.gsform_sl
                              ELSE '999' END AS gsform_sl, 
                              CASE WHEN gsf1.REL_IFRS_SL IS NOT NULL THEN gsf1.REL_IFRS_SL
                              WHEN gsf2.REL_IFRS_SL IS NOT NULL THEN gsf2.REL_IFRS_SL
                              WHEN gsf3.REL_IFRS_SL IS NOT NULL THEN gsf3.REL_IFRS_SL
                              ELSE '9' END AS REL_IFRS_SL 
                              , b.pors as bond_pors, b.valuedate, b.wf_run_id as b_run
                              , sec.sec, sec.audit_version as sec_audit_version, sec.wp_type, sec.cdmnachrangig, sec.cdmccc, sec.cdmtrennungspflicht, sec.cdmhaltekategorie, sec.subtype, sec.cdmimpairment
                              , sec.cdmimpairmentdate, sec.cdmzahlungsausfall, sec.cdmzahlungsausfallab, sec.cdmzahlungsausfallbis, sec.cdmamortisierungbis, sec.cdmstufenzins, sec.cdmverbrassetclass, sec.wf_run_id as sec_run
                              , fss.eg_tik_id as sec_tik, fss.ssd_flg
                              , dsa.effdate, dsa.matdate, dsa.interest_fixfloat, dsa.sched_pay_freq, dsa.interest_dmindex, dsa.wf_run_id as dsa_run
                              , frp.refi_port_sl
                              , st.eigen_em_id
                              , fhias.hkat_ias39_sl, a.*
                                                                                                from GET_REL_KOMP_ZGS a 
                                                                                                join DISSTA.STA_SUK_VDTS_DMBOND b on a.tradeid = b.tradeid  
                                                                                                                                  and a.audit_version = b.audit_version
                                                                                                join DISSTA.STA_SUK_VDTS_DMSEC sec on b.sec = sec.sec
                                                                                                join DISCORE.DWH_FMTE_SUMMIT_SECURITY fss on sec.sec = fss.sec
                                                                                                join DISSTA.STA_SUK_VDTS_DMSASSET dsa on sec.dmassetid = dsa.dmassetid
                                                                                                                                      and sec.audit_version = dsa.audit_version
                                                                                                left join (select * from DISCORE.DWH_FMRE_REFI_PORT_SUMMIT WHERE CDMFINZWECK_REL_FLG = '1' 
                                                                                                                                                           and subtype_rel_flg = '1') frp 
                                                                                                on frp.cdmfinzweck = a.cdmfinzweck
                                                                                                and frp.subtype = sec.subtype     
                                                                                                left join DISCORE.DWH_FMRE_SECTYPE_SUMMIT st on st.wp_type = sec.wp_type
                                                                                                left join DISCORE.DWH_FMRE_HKAT_IAS39_SUMMIT fhias on fhias.cdmhaltekategorie = sec.cdmhaltekategorie                            
                                                                                                left join (select * from DISCORE.DWH_FMRE_GSFORM_WP_SUMMIT where SUBTYPE_REL_FLG = '1'
                                                                                                                                                       and VERBASCL_REL_FLG = '1') gsf1  
                                                                                                on sec.wp_type = gsf1.wp_type
                                                                                                and sec.subtype = gsf1.subtype
                                                                                                and sec.CDMVERBRASSETCLASS = gsf1.CDMVERBRASSETCLASS 
                                                                                                left join (select * from DISCORE.DWH_FMRE_GSFORM_WP_SUMMIT where SUBTYPE_REL_FLG = '0'
                                                                                                                                                       and VERBASCL_REL_FLG = '1') gsf2  
                                                                                                on sec.wp_type = gsf2.wp_type
                                                                                                and sec.CDMVERBRASSETCLASS = gsf2.CDMVERBRASSETCLASS
                                                                                                left join (select * from DISCORE.DWH_FMRE_GSFORM_WP_SUMMIT where SUBTYPE_REL_FLG = '0'
                                                                                                                                                       and VERBASCL_REL_FLG = '0') gsf3  
                                                                                                on sec.wp_type = gsf3.wp_type                                                                                                                                           
where fss.HERK_SYS_SL = '101'
and b.wf_run_id = (select MAX(wf_run_id) from DISSTA.STA_SUK_VDTS_DMBOND)
and sec.wf_run_id = (select MAX(wf_run_id) from DISSTA.STA_SUK_VDTS_DMSEC)
and dsa.wf_run_id = (select MAX(wf_run_id) from DISSTA.STA_SUK_VDTS_DMSASSET)
)
,
-- Ermittlung Geschäft-ID und restliche Informationen               
GET_GESCHAEFT_ID as (SELECT fcc.ccc_sl, CASE WHEN a.cdmtrennungspflicht = 'Y' THEN fed.emb_deri_sl 
                                             WHEN (a.cdmtrennungspflicht = 'N' and so.secid is not NULL) THEN '1'
                                             WHEN (a.cdmtrennungspflicht = 'N' and so.secid is NULL and a.interest_dmindex = 'FORM') THEN '1'
                                             WHEN (a.cdmtrennungspflicht = 'N' and so.secid is NULL and a.interest_dmindex <> 'FORM') THEN '0'
                                             ELSE '8' END as EMB_DERI_SL
                                             , so.secid, so.wf_run_id as so_run
                                             , fkv.KFVK_SL, fkv.akt_pas_sl, fns.nachrang_sl, fzk.zins_kond_sl, gf.gsart_sl, 
                                             CASE WHEN gf.gsart_sl is not NULL THEN a.tradeid||'.'||a.trade_type||'_'||gf.gsart_sl||'_'||a.HERK_SYS_SL||'_'||a.SPLIT_SEP
                                                  ELSE 'UNBEKANNT' END as GESCHAEFT_ID, a.* FROM GET_WP_TRADE_KOMP a
                                             left join DISCORE.DWH_RDGKGF gf on a.gsform_sl = gf.gsform_sl
                                             left join DISCORE.DWH_FMRE_CCC_SUMMIT fcc on a.cdmccc = fcc.cdmccc
                                             left join DISCORE.DWH_FMRE_EMB_DERI_SUMMIT fed on a.cdmhaltekategorie = fed.cdmhaltekategorie
                                             left join DISSTA.STA_SUK_VDTS_CDMSECOPT so on a.sec = so.secid
                                                                                        and a.sec_audit_version = so.audit_version
                                             left join DISCORE.DWH_FMRE_KFVK_SUMMIT fkv on a.bond_pors = fkv.pors
                                             left join DISCORE.DWH_FMRE_NACHRANG_SUMMIT fns on a.cdmnachrangig = fns.cdmnachrangig
                                             left join DISCORE.DWH_FMRE_ZINS_KOND_SUMMIT fzk on a.interest_fixfloat = fzk.interest_fixfloat
                                                                                             and a.sched_pay_freq = fzk.sched_pay_freq
where so.wf_run_id = (select MAX(wf_run_id) from DISSTA.STA_SUK_VDTS_CDMSECOPT)
)
,
-- Vorselektion CDO Pool Informationen  
GET_CDOPOOL_INFO as (select distinct cdi.transactionid, cdi.secid from DISSTA.STA_SUK_VDTS_CDMCDOPOOL cdp join DISSTA.STA_SUK_VDTS_CDMCDOISS cdi on cdp.transactionid = cdi.transactionid

where cdi.transactionid is not null
)
,
--Ermittlung erwartete Einträge für DISCORE Zieltabellen
EGADID AS
(
        SELECT CURRENT TIMESTAMP AS STAG_DT
                    , 0 AS LAUF_ID
                    , EG_TIK_ID
                    , CASE WHEN GESCHAEFT_ID = 'UNBEKANNT' THEN 'E'
                      ELSE 'S' END as STATUS_DS_SL
                    , MANDANT_DIS_SL
                    , HERK_SYS_SL
                    , BUKRS_SL
                    , GESCHAEFT_ID
                    , SPLIT_SEP
                    , OBJ_TYP_GES_SL
         FROM GET_GESCHAEFT_ID
         WHERE 
--         ID is not null
--         AND 
         KOMP_NR = '1'
)
,
EGADSD AS
(
        SELECT CURRENT TIMESTAMP AS STAG_DT
                    , 0 AS LAUF_ID
                    , EG_TIK_ID
                    , 'S' as STATUS_DS_SL
                    , effdate as LFZB_DT
                    , matdate as LFZE_DT
                    , CASE WHEN NACHRANG_SL IS NOT NULL THEN NACHRANG_SL
                           ELSE '9' END AS NACHRANG_SL
                    , '8' as BUCH_SL
                    , '2' as EIGEN_FREMD_SL
                    , CASE WHEN CCC_SL IS NOT NULL THEN CCC_SL
                           ELSE '99' END AS CCC_SL
                    , CASE WHEN ssd_flg = '1' AND AKT_PAS_SL IS NOT NULL THEN AKT_PAS_SL
                           WHEN ssd_flg = '1' AND AKT_PAS_SL IS NULL THEN 'Z'
                      ELSE 'Y' END AS AKT_PAS_SL
                    , CASE WHEN PORTFOLIO_I9_SL IS NOT NULL THEN PORTFOLIO_I9_SL
                      ELSE '999' END AS PORTFOLIO_I9_SL
                    , gsform_sl
                    , CASE WHEN cdmhaltekategorieifrsfinal = 'Y' and cdmhaltekategorieifrs is not null
                        THEN HKAT_I9_SL
                      ELSE 'ZZZ' END as HKAT_I9_SL                    
                    , CASE WHEN EMB_DERI_SL IS NOT NULL THEN EMB_DERI_SL
                      ELSE '9' END AS EMB_DERI_SL 
                    , '8' as ZUWEISUNG_SL
                    , CASE WHEN PROD_STUFE_4_ID <> '0' THEN PROD_STUFE_4_ID
                           ELSE 999999 END as PRODUKT_FFC_SL
                    , CASE WHEN OE_ABT_FFC_ID <> '0' THEN OE_ABT_FFC_ID 
                           ELSE 999999 END as VOE_ABT_SL
                    , KOMP_WAERS_ID as WAERS_ID
                    , '1' as MARGEN_AUSWEIS_SL
                    , CASE WHEN status_id IS NOT NULL THEN status_id
                           ELSE '9' END AS STATUS_ID        
                    , CASE WHEN ssd_flg = '1' AND refi_port_sl IS NOT NULL THEN REFI_PORT_SL       
                           WHEN ssd_flg = '1' AND refi_port_sl IS NULL THEN '7'
                           ELSE '6' END AS REFI_PORT_SL                      
         FROM GET_GESCHAEFT_ID
         WHERE 
         ID is not null
         AND 
         KOMP_NR = '1'
)
,
EGADRL AS
(
        SELECT CURRENT TIMESTAMP AS STAG_DT
                    , 0 AS LAUF_ID
                    , EG_TIK_ID
                    , 'S' as STATUS_DS_SL
                    , '1' as JUR_BEST_SL
                    , '0' as REL_HGB_SL
                    , REL_IFRS_SL
                    , '0' as REL_MEWE_SL               
         FROM GET_GESCHAEFT_ID
         WHERE 
         ID is not null
         AND 
         KOMP_NR = '1'
)
,
EGADTD AS
(
        SELECT CURRENT TIMESTAMP AS STAG_DT
                    , 0 AS LAUF_ID
                    , EG_TIK_ID
                    , 'S' as STATUS_DS_SL
                    , CASE WHEN HKAT_IAS39_SL IS NOT NULL THEN HKAT_IAS39_SL
                      ELSE '9' END AS HKAT_IAS39_SL
         FROM GET_GESCHAEFT_ID
         WHERE 
         ID is not null
         AND 
         KOMP_NR = '1'
)
,
EGRLSD AS
(
        SELECT CURRENT TIMESTAMP AS STAG_DT
                    , 0 AS LAUF_ID
                    , EG_TIK_ID
                    , KOMP_NR
                    , '3' as RL_ID
                    , 'S' as STATUS_DS_SL
                    , '1' AS AMORT_SL
         FROM GET_GESCHAEFT_ID
         WHERE 
--         ID is not null
--         AND 
         KOMP_NR = '1'
)
,
EGADRV AS
(
        SELECT CURRENT TIMESTAMP AS STAG_DT
                    , 0 AS LAUF_ID
                    , EG_TIK_ID
                    , 'S' as STATUS_DS_SL
                    , CASE WHEN id.CDMIMPAIRMENT IS NOT NULL THEN impfl.FLAG_SL
                      ELSE '9' END AS IMPAIRED_SL
                    , id.CDMIMPAIRMENTDATE as IMPAIRED_DT
                    , CASE WHEN id.CDMZAHLUNGSAUSFALL IS NOT NULL THEN zlfl.FLAG_SL
                      ELSE '9' END AS ZINSLOS_SL
                    , '00010101' as ZINSLOS_ERS_DT
                    , '00010101' as ZINSLOS_AKT_DT
                    , CASE WHEN id.ssd_flg = '1' THEN '8'
                      WHEN id.CDMZAHLUNGSAUSFALL IS NOT NULL THEN zafl.FLAG_SL
                      ELSE '9' END AS ZAHL_AUSF_SL
                    , CASE WHEN id.ssd_flg = '1' THEN '00010101'
                      ELSE id.CDMZAHLUNGSAUSFALLAB END AS ZAHL_AUSF_GUELT_AB
                    , CASE WHEN id.ssd_flg = '1' THEN '00010101'
                      ELSE id.CDMZAHLUNGSAUSFALLBIS END AS ZAHL_AUSF_GUELT_BIS 
         FROM GET_GESCHAEFT_ID id left join (SELECT * FROM DISCORE.DWH_FMRE_FLAG WHERE QUELLFELD = 'CDMIMPAIRMENT' AND REGEL = 'IMPAIRED_SL') impfl on impfl.HERK_SYS_SL = id.HERK_SYS_SL and impfl.QUELLWERT = id.CDMIMPAIRMENT
                                  left join (SELECT * FROM DISCORE.DWH_FMRE_FLAG WHERE QUELLFELD = 'CDMZAHLUNGSAUSFALL' AND REGEL = 'ZINSLOS_SL') zlfl on zlfl.HERK_SYS_SL = id.HERK_SYS_SL and zlfl.QUELLWERT = id.CDMZAHLUNGSAUSFALL
                                  left join (SELECT * FROM DISCORE.DWH_FMRE_FLAG WHERE QUELLFELD = 'CDMZAHLUNGSAUSFALL' AND REGEL = 'ZAHL_AUSF_SL') zafl on zafl.HERK_SYS_SL = id.HERK_SYS_SL and zafl.QUELLWERT = id.CDMZAHLUNGSAUSFALL
         WHERE 
--         ID is not null
--         AND 
         KOMP_NR = '1'
)
,
EGADKM AS
(
        SELECT CURRENT TIMESTAMP AS STAG_DT
                    , 0 AS LAUF_ID
                    , EG_TIK_ID
                    , KOMP_NR
                    , 'S' as STATUS_DS_SL
                    , KOMP_TYP_SL
                    , VATER_KNOTEN
                    , HIER_EBENE
                    , DIS_STRUKT_SL
                    , OBJ_TYP_KOMP_SL
         FROM GET_GESCHAEFT_ID
--         WHERE 
--         ID is not null
--         AND 
--         KOMP_NR = '1'

)
,
EGWTSD AS
(
        SELECT CURRENT TIMESTAMP AS STAG_DT
                    , 0 AS LAUF_ID
                    , EG_TIK_ID
                    , KOMP_NR
                    , 'S' as STATUS_DS_SL
                    , CASE WHEN eigen_em_id = '1' THEN '52'
                      WHEN depot_id IS NOT NULL THEN depot_id
                      ELSE '999' END AS DEPOT_ID
                    , CASE WHEN cdmtranche IS NOT NULL THEN cdmtranche
                      ELSE 'ZZ' END as TRANCHE
                    , tradedate as TRADE_DT
                    , valuedate as ERFUELL_DT
                    , komp_waers_id as KOMP_WAERS_SL
         FROM GET_GESCHAEFT_ID
           WHERE 
           ssd_flg = '0'  
--         ID is not null
--         AND 
--         KOMP_NR = '1'
)
,
EGDASD AS
(
        SELECT CURRENT TIMESTAMP AS STAG_DT
                    , 0 AS LAUF_ID
                    , EG_TIK_ID
                    , KOMP_NR
                    , 'S' as STATUS_DS_SL
                    , effdate as ZFSB_DT
                    , CASE WHEN CDMAMORTISIERUNGBIS = '99991231' THEN matdate
                      ELSE CDMAMORTISIERUNGBIS END AS ZFSE_DT
                    , 'Y' AS ZINS_METH_SL
                    , '8' AS LINIE_SL  
                    , '8' AS HAFTVER_ART_SL
                    , CASE WHEN zins_kond_sl IS NOT NULL THEN zins_kond_sl
                      ELSE '9' END AS ZINS_KOND_SL
                    , CASE WHEN kfvk_sl IS NOT NULL THEN kfvk_sl
                      ELSE '9' END AS KFVK_SL 
                    , '98' as DECKUNGS_STATUS_SL
                    , '8' as REDU_FIN_SL
                    , CASE WHEN id.CDMSTUFENZINS IS NOT NULL THEN szfl.FLAG_SL
                      ELSE '9' END AS STUFENZINS_SL
                    , '8' AS VERBILLIGUNG_SL
                    , '8' AS BETEIL_KAT_SL
                    , '-1' AS KV_TRANCHE_ID
                    , '00010101' as KUENDIGUNG_BANK_DT
                    , '8' AS KUNDENBEZ_ART_SL
                    , CASE WHEN cdo.transactionid is not null THEN to_char(cdo.transactionid)
                      ELSE '0' END as VERBR_TRANS_ID
                    , CASE WHEN id.subtype in ('CL', 'CLFG') THEN '1'
                      ELSE '0' END AS CRED_LINK_SL
                    , '8' AS ZINS_FIX_ZP_SL
                    , '8' AS MARGE_FIX_ZP_SL
                    , '8' AS ZINS_FIX_VERF_SL
                    , '8' AS FORD_ANK_SL
                    , '00010101' as VERTRAG_DT
                    , '00010101' as ERSTABRUF_DT
                    , '8' AS APL_TILGR_SL
                    , '00010101' as LETZTE_PROL_DT
                    , id.effdate as LFZB_KOMP_DT
                    , id.matdate as LFZE_KOMP_DT
                    , id.komp_waers_id as WAERS_KOMP_ID              
         FROM GET_GESCHAEFT_ID id left join (SELECT * FROM DISCORE.DWH_FMRE_FLAG WHERE QUELLFELD = 'CDMSTUFENZINS' AND REGEL = 'STUFENZINS_SL') szfl on szfl.HERK_SYS_SL = id.HERK_SYS_SL and szfl.QUELLWERT = id.CDMSTUFENZINS
                                  left join GET_CDOPOOL_INFO cdo on id.sec = cdo.secid
         WHERE
         ssd_flg = '1' 
--         ID is not null
--         AND 
--         KOMP_NR = '1'
)
,
VKEGEG AS
(
        SELECT CURRENT TIMESTAMP AS STAG_DT
                    , eg_tik_id AS EG_TIK_ID1
                    , '116' AS VK_TYP_SL
                    , 0 AS LAUF_ID
                    , sec_tik AS EG_TIK_ID2
                    , 'S' as STATUS_DS_SL
                    , '19010101' AS GUELTIG_VON_DT
                    , '29991231' AS GUELTIG_BIS_DT
        FROM GET_GESCHAEFT_ID
        WHERE 
--         ID is not null
--         AND 
         KOMP_NR = '1'
)

--*************** Abfragen Ergebnismengen *******************
/*
select * from GET_WP_TRADE_KOMP
where eg_tik_id = '38991869'
*/

--select * from GET_GESCHAEFT_ID
--where eg_tik_id = '39309688'



--*************** Abfragen DISCORE Zieltabellen *******************

--EGADID
select EG_TIK_ID, MANDANT_DIS_SL, HERK_SYS_SL, BUKRS_SL, GESCHAEFT_ID, SPLIT_SEP, OBJ_TYP_GES_SL from EGADID
minus
select EG_TIK_ID, MANDANT_DIS_SL, HERK_SYS_SL, BUKRS_SL, GESCHAEFT_ID, SPLIT_SEP, OBJ_TYP_GES_SL from DISCORE.DWH_EGADID


/*
--EGADSD
-- select * from DISCORE.DWH_EGADSD
select EG_TIK_ID, LFZB_DT, LFZE_DT, NACHRANG_SL, BUCH_SL, EIGEN_FREMD_SL, CCC_SL, AKT_PAS_SL, GSFORM_SL, HKAT_I9_SL, EMB_DERI_SL, ZUWEISUNG_SL, WAERS_ID, MARGEN_AUSWEIS_SL, STATUS_ID
--PORTFOLIO_I9_SL, PRODUKT_FFC_SL, VOE_ABT_SL, REFI_PORT_SL
from EGADSD
minus
select EG_TIK_ID, TO_CHAR(LFZB_DT,'YYYYMMDD') as LFZB_DT, TO_CHAR(LFZE_DT,'YYYYMMDD') as LFZE_DT, NACHRANG_SL, BUCH_SL, EIGEN_FREMD_SL, CCC_SL, AKT_PAS_SL, GSFORM_SL, HKAT_I9_SL, EMB_DERI_SL, ZUWEISUNG_SL, WAERS_ID, MARGEN_AUSWEIS_SL, STATUS_ID
--PORTFOLIO_I9_SL, PRODUKT_FFC_SL, VOE_ABT_SL, REFI_PORT_SL
from DISCORE.DWH_EGADSD
*/
/*
--EGADSD Detail check
select 'expected', EG_TIK_ID, LFZB_DT, LFZE_DT, NACHRANG_SL, BUCH_SL, EIGEN_FREMD_SL, CCC_SL, AKT_PAS_SL, GSFORM_SL, HKAT_I9_SL, EMB_DERI_SL, ZUWEISUNG_SL, WAERS_ID, MARGEN_AUSWEIS_SL, STATUS_ID, REFI_PORT_SL
--PORTFOLIO_I9_SL, PRODUKT_FFC_SL, VOE_ABT_SL, REFI_PORT_SL
from EGADSD
where eg_tik_id = 39309688
union all
select 'delivered', EG_TIK_ID, TO_CHAR(LFZB_DT,'YYYYMMDD') as LFZB_DT, TO_CHAR(LFZE_DT,'YYYYMMDD') as LFZE_DT, NACHRANG_SL, BUCH_SL, EIGEN_FREMD_SL, CCC_SL, AKT_PAS_SL, GSFORM_SL, HKAT_I9_SL, EMB_DERI_SL, ZUWEISUNG_SL, WAERS_ID, MARGEN_AUSWEIS_SL, STATUS_ID, REFI_PORT_SL
--PORTFOLIO_I9_SL, PRODUKT_FFC_SL, VOE_ABT_SL, REFI_PORT_SL
from DISCORE.DWH_EGADSD
where eg_tik_id = 39309688
*/

/*
-- EGADRL
select EG_TIK_ID, JUR_BEST_SL, REL_HGB_SL, REL_IFRS_SL, REL_MEWE_SL from EGADRL
minus
select EG_TIK_ID, JUR_BEST_SL, REL_HGB_SL, REL_IFRS_SL, REL_MEWE_SL from DISCORE.DWH_EGADRL
*/
/*
-- EGADRL Detail Check
select 'expected', EG_TIK_ID, JUR_BEST_SL, REL_HGB_SL, REL_IFRS_SL, REL_MEWE_SL from EGADRL
where eg_tik_id = 38991837
union all
select 'delivered', EG_TIK_ID, JUR_BEST_SL, REL_HGB_SL, REL_IFRS_SL, REL_MEWE_SL from DISCORE.DWH_EGADRL
where eg_tik_id = 38991837
*/

/*
-- EGADTD
select EG_TIK_ID, HKAT_IAS39_SL from EGADTD
minus
select EG_TIK_ID, HKAT_IAS39_SL from DISCORE.DWH_EGADTD
*/
/*
-- EGADTD Detail Check
select 'expected', EG_TIK_ID, HKAT_IAS39_SL from EGADTD
where eg_tik_id = 11570568
union all
select 'delivered', EG_TIK_ID, HKAT_IAS39_SL from DISCORE.DWH_EGADTD
where eg_tik_id = 11570568
*/

/*
-- EGRLSD
select EG_TIK_ID, KOMP_NR, RL_ID, AMORT_SL from EGRLSD
minus
select EG_TIK_ID, KOMP_NR, RL_ID, AMORT_SL from DISCORE.DWH_EGRLSD
*/

/*
-- EGADRV
select EG_TIK_ID, IMPAIRED_SL, IMPAIRED_DT, ZINSLOS_SL, ZINSLOS_ERS_DT, ZINSLOS_AKT_DT, ZAHL_AUSF_SL, ZAHL_AUSF_GUELT_AB, ZAHL_AUSF_GUELT_BIS from EGADRV
minus
select EG_TIK_ID, IMPAIRED_SL, TO_CHAR(IMPAIRED_DT,'YYYYMMDD') As IMPAIRED_DT, ZINSLOS_SL, TO_CHAR(ZINSLOS_ERS_DT,'YYYYMMDD') as ZINSLOS_ERS_DT, TO_CHAR(ZINSLOS_AKT_DT,'YYYYMMDD') as ZINSLOS_AKT_DT, ZAHL_AUSF_SL, TO_CHAR(ZAHL_AUSF_GUELT_AB,'YYYYMMDD') as ZAHL_AUSF_GUELT_AB, TO_CHAR(ZAHL_AUSF_GUELT_BIS,'YYYYMMDD') as ZAHL_AUSF_GUELT_BIS from DISCORE.DWH_EGADRV
*/

/*
-- EGADKM
select EG_TIK_ID, KOMP_NR, KOMP_TYP_SL, VATER_KNOTEN, HIER_EBENE, DIS_STRUKT_SL, OBJ_TYP_KOMP_SL from EGADKM
minus
select EG_TIK_ID, KOMP_NR, KOMP_TYP_SL, VATER_KNOTEN, HIER_EBENE, DIS_STRUKT_SL, OBJ_TYP_KOMP_SL from DISCORE.DWH_EGADKM
*/

/*
-- EGWTSD
select EG_TIK_ID, KOMP_NR, TRANCHE, TRADE_DT, ERFUELL_DT, KOMP_WAERS_SL 
--, DEPOT_ID
from EGWTSD
minus
select EG_TIK_ID, KOMP_NR, TRANCHE, TO_CHAR(TRADE_DT,'YYYYMMDD') As TRADE_DT, TO_CHAR(ERFUELL_DT,'YYYYMMDD') As ERFUELL_DT, KOMP_WAERS_SL 
--, DEPOT_ID
from DISCORE.DWH_EGWTSD
*/
/*
-- EGWTSD Detail Check
select 'expected', EG_TIK_ID, KOMP_NR, DEPOT_ID, TRANCHE, TRADE_DT, ERFUELL_DT, KOMP_WAERS_SL from EGWTSD
where EG_TIK_ID = 38991861
union all
select 'delivered', EG_TIK_ID, KOMP_NR, DEPOT_ID, TRANCHE, TO_CHAR(TRADE_DT,'YYYYMMDD') As TRADE_DT, TO_CHAR(ERFUELL_DT,'YYYYMMDD') As ERFUELL_DT, KOMP_WAERS_SL from DISCORE.DWH_EGWTSD
where eg_tik_id = 38991861
*/

/*
-- EGDASD
select EG_TIK_ID, KOMP_NR, ZFSB_DT, ZFSE_DT, ZINS_METH_SL, LINIE_SL, HAFTVER_ART_SL, ZINS_KOND_SL, KFVK_SL, DECKUNGS_STATUS_SL, REDU_FIN_SL, STUFENZINS_SL, VERBILLIGUNG_SL, BETEIL_KAT_SL, KV_TRANCHE_ID, KUENDIGUNG_BANK_DT, KUNDENBEZ_ART_SL, VERBR_TRANS_ID, CRED_LINK_SL, ZINS_FIX_ZP_SL, MARGE_FIX_ZP_SL, ZINS_FIX_VERF_SL, FORD_ANK_SL, VERTRAG_DT, ERSTABRUF_DT, APL_TILGR_SL, LETZTE_PROL_DT, LFZB_KOMP_DT, LFZE_KOMP_DT, WAERS_KOMP_ID from EGDASD
minus 
select EG_TIK_ID, KOMP_NR, TO_CHAR(ZFSB_DT,'YYYYMMDD') As ZFSB_DT, TO_CHAR(ZFSE_DT,'YYYYMMDD') As ZFSE_DT, ZINS_METH_SL, LINIE_SL, HAFTVER_ART_SL, ZINS_KOND_SL, KFVK_SL, DECKUNGS_STATUS_SL, REDU_FIN_SL, STUFENZINS_SL, VERBILLIGUNG_SL, BETEIL_KAT_SL, KV_TRANCHE_ID, TO_CHAR(KUENDIGUNG_BANK_DT,'YYYYMMDD') As KUENDIGUNG_BANK_DT, KUNDENBEZ_ART_SL, VERBR_TRANS_ID, CRED_LINK_SL, ZINS_FIX_ZP_SL, MARGE_FIX_ZP_SL, ZINS_FIX_VERF_SL, FORD_ANK_SL, TO_CHAR(VERTRAG_DT,'YYYYMMDD') As VERTRAG_DT, TO_CHAR(ERSTABRUF_DT,'YYYYMMDD') As ERSTABRUF_DT, APL_TILGR_SL, TO_CHAR(LETZTE_PROL_DT,'YYYYMMDD') As LETZTE_PROL_DT, TO_CHAR(LFZB_KOMP_DT,'YYYYMMDD') As LFZB_KOMP_DT, TO_CHAR(LFZE_KOMP_DT,'YYYYMMDD') As LFZE_KOMP_DT, WAERS_KOMP_ID from DISCORE.DWH_EGDASD
*/
/*
-- EGDASD Detail Check
select 'expected', EG_TIK_ID, KOMP_NR, ZFSB_DT, ZFSE_DT, ZINS_METH_SL, LINIE_SL, HAFTVER_ART_SL, ZINS_KOND_SL, KFVK_SL, DECKUNGS_STATUS_SL, REDU_FIN_SL, STUFENZINS_SL, VERBILLIGUNG_SL, BETEIL_KAT_SL, KV_TRANCHE_ID, KUENDIGUNG_BANK_DT, KUNDENBEZ_ART_SL, VERBR_TRANS_ID, CRED_LINK_SL, ZINS_FIX_ZP_SL, MARGE_FIX_ZP_SL, ZINS_FIX_VERF_SL, FORD_ANK_SL, VERTRAG_DT, ERSTABRUF_DT, APL_TILGR_SL, LETZTE_PROL_DT, LFZB_KOMP_DT, LFZE_KOMP_DT, WAERS_KOMP_ID from EGDASD
where EG_TIK_ID = 38992846
union all
select 'delivered', EG_TIK_ID, KOMP_NR, TO_CHAR(ZFSB_DT,'YYYYMMDD') As ZFSB_DT, TO_CHAR(ZFSE_DT,'YYYYMMDD') As ZFSE_DT, ZINS_METH_SL, LINIE_SL, HAFTVER_ART_SL, ZINS_KOND_SL, KFVK_SL, DECKUNGS_STATUS_SL, REDU_FIN_SL, STUFENZINS_SL, VERBILLIGUNG_SL, BETEIL_KAT_SL, KV_TRANCHE_ID, TO_CHAR(KUENDIGUNG_BANK_DT,'YYYYMMDD') As KUENDIGUNG_BANK_DT, KUNDENBEZ_ART_SL, VERBR_TRANS_ID, CRED_LINK_SL, ZINS_FIX_ZP_SL, MARGE_FIX_ZP_SL, ZINS_FIX_VERF_SL, FORD_ANK_SL, TO_CHAR(VERTRAG_DT,'YYYYMMDD') As VERTRAG_DT, TO_CHAR(ERSTABRUF_DT,'YYYYMMDD') As ERSTABRUF_DT, APL_TILGR_SL, TO_CHAR(LETZTE_PROL_DT,'YYYYMMDD') As LETZTE_PROL_DT, TO_CHAR(LFZB_KOMP_DT,'YYYYMMDD') As LFZB_KOMP_DT, TO_CHAR(LFZE_KOMP_DT,'YYYYMMDD') As LFZE_KOMP_DT, WAERS_KOMP_ID from DISCORE.DWH_EGDASD
where EG_TIK_ID = 38992846
*/

/*
-- VKEGEG
select EG_TIK_ID1, VK_TYP_SL, EG_TIK_ID2, GUELTIG_VON_DT, GUELTIG_BIS_DT from VKEGEG
minus 
select EG_TIK_ID1, VK_TYP_SL, EG_TIK_ID2, TO_CHAR(GUELTIG_VON_DT,'YYYYMMDD') As GUELTIG_VON_DT, TO_CHAR(GUELTIG_BIS_DT,'YYYYMMDD') As GUELTIG_BIS_DT from DISCORE.DWH_VKEGEG
--where VK_TYP_SL = '116'
*/
/*
-- VKEGEG Detail Check
select 'expected', EG_TIK_ID1, VK_TYP_SL, EG_TIK_ID2, GUELTIG_VON_DT, GUELTIG_BIS_DT from VKEGEG
where EG_TIK_ID1 = 38991879
union all
select 'delivered', EG_TIK_ID1, VK_TYP_SL, EG_TIK_ID2, TO_CHAR(GUELTIG_VON_DT,'YYYYMMDD') As GUELTIG_VON_DT, TO_CHAR(GUELTIG_BIS_DT,'YYYYMMDD') As GUELTIG_BIS_DT from DISCORE.DWH_VKEGEG
where EG_TIK_ID1 = 38991879
*/

--*************** Sonstige Abfragen *******************
/*
select ad1.eg_tik_id from EGADSD ad1
inner join DISCORE.DWH_EGADSD ad2
on ad1.eg_tik_id = ad2.eg_tik_id
and ad1.VOE_ABT_SL = ad2.VOE_ABT_SL 
where ad1.VOE_ABT_SL = '999999'
*/
/*
select cdmfinzweck, subtype, count(*) from GET_GESCHAEFT_ID
where ssd_flg = '1'
group by cdmfinzweck, subtype
*/