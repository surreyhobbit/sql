-- Profiling Stammdaten Summit

--*************** Wertpapiere / Bonds ****************************************************************

--Ausprägungen Klassifizierung:
--Eigene WP
--Fremde WP
--Schuldscheindarlehen

--select * from 
--(
select res.CDMLIQUIPORT, count(*) from
(
select --klassifizierung, --> Klassifizierung ist noch offen!!!!!!!!!!!!!!!!!
	   env.dmOwnertable,
	   env.FOLDER,
       env.tradeId,
	   env.tradedate,
	   env.CDMFINZWECK,
	   env.CDMFXVERWZWECK,
	   env.cdmliquiport,
	   env.producttype,
	   env.cdmhaltekategorie,
	   env.CDMHALTEKATEGORIEIFRS,
	   env.CDMHALTEKATEGORIEIFRSFINAL,
	   env.tradestatus,
	   env.audit_entitystate,
	   env.company,
	   env.book,
	   env.desk,
	   bond.sectype,
	   bond.ccy,
	   secast.sec,
	   secast.type,
	   secast.subtype,
	   secast.productname,
	   secast.cdmtrennungspflicht,
	   secast.CDMSECEFFDATE,
	   secast.cdmsecmatdate,
	   secast.issuer,
	   secast.issueprice,
	   secast.sizeissue,
	   secast.EXTERNALSOURCE,
	   secast.CDMCBOERSENNOTIERT,
	   secast.CDMBOERSENFAEHIG,
	   secast.CDMNOTENBANKF,
	   secast.PRICEFORMULA,
	   secast.LFORMAT_PRICEFORM_UNITS,
	   secast.REDEMPTIONPRICE,
	   secast.STEPDEBT,
	   secast.ccy,
	   secast.CDMGEWAEHRGEBER,
	   secast.CDMSTUFENZINS,
	   secast.CDMVERBRASSETCLASS,
	   secast.CDMVERBRASSETREGION,
	   secast.dmAssetId,
	   secast.interest_basis,
	   secast.Sched_Pay_Cal,
	   secast.effdate,
	   secast.matdate,
	   secast.interest_fixfloat,
	   --sfloat.sEVTYP,
	   --sfloat.sFLTYPE,
	   secast.pors,
	   cdo.transactionid
	   --azg.OE_ABT_FFC_ID,
from dmEnv env

left outer join dmBond bond
on env.tradeId = bond.tradeId
and env.audit_version = bond.audit_version

left outer join 
(
select sec.audit_action,
	   sec.audit_ishistory,		 
	   sec.sec,
	   sec.type,
	   sec.subtype,
	   sec.productname,
	   sec.cdmtrennungspflicht,
	   sec.CDMSECEFFDATE,
	   sec.cdmsecmatdate,
	   sec.issuer,
	   sec.issueprice,
	   sec.sizeissue,
	   sec.EXTERNALSOURCE,
	   sec.CDMCBOERSENNOTIERT,
	   sec.CDMBOERSENFAEHIG,
	   sec.CDMNOTENBANKF,
	   sec.PRICEFORMULA,
	   sec.LFORMAT_PRICEFORM_UNITS,
	   sec.REDEMPTIONPRICE,
	   sec.STEPDEBT,
	   sec.ccy,
	   sec.CDMGEWAEHRGEBER,
	   sec.CDMSTUFENZINS,
	   sec.CDMVERBRASSETCLASS,
	   sec.CDMVERBRASSETREGION,
	   sast.dmAssetId,
	   sast.interest_basis,
	   sast.Sched_Pay_Cal,
	   sast.effdate,
	   sast.matdate,
	   sast.interest_fixfloat,
	   sast.pors
	   --sfloat.sEVTYP,
	   --sfloat.sFLTYPE,
from dmSec sec

inner join dmSAsset sast
on sast.dmAssetId = sec.dmAssetId
and sast.audit_version = sec.audit_version

where sec.audit_current = 'Y' 
and sec.audit_entitystate not in ('PEND','DONE')
) secast
on secast.sec = bond.sec

left outer join 
(
select iss.secid,
	   pool.transactionid 
from cdmcdoiss iss

inner join cdmCDOpool pool
on pool.transactionid = iss.transactionid
and pool.audit_version = iss.audit_version

where pool.audit_current = 'Y'
and pool.audit_entitystate not in ('PEND','DONE')
and iss.secid <> ' '
) cdo
on cdo.secid = secast.sec

where env.dmOwnertable = 'BOND_TR'  
and env.audit_authorized = 'Y'
and env.audit_entitystate not in ('PEND','DONE')
and env.desk not in ('BEWERT','INTGESCH')
and bond.bondMktType not in  ('DEPTRN')
order by env.tradeId
--) prod

--where prod.klassifizierung is not null
) res
group by res.CDMLIQUIPORT
order by res.CDMLIQUIPORT
;

