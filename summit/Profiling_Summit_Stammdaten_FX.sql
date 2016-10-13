-- Profiling Stammdaten Summit

--***************Derivate "FX-Geschäfte"****************************************************************

--Ausprägungen Klassifizierung:
--Devisenswap
--Kassa
--Termin

select res.CDMLIQUIPORT, count(*) from
(
select * from 
(
select case
	   	   when 
		    env.dmownertable = 'FXSWAP'
		   then 'Devisenswap'
		   when
		    env.dmownertable = 'FXSPOT'
		   then 'Kassa'
		   when
		    env.dmownertable = 'FXFWD'
		   then 'Termin'
		   else ''
	   end as klassifizierung, 
	   env.FOLDER,
	   env.AUDIT_ENTITYSTATE,
	   env.tradeid, 
	   env.dmownertable, 
	   env.DESK,
	   env.book,
	   env.CDMLIQUIPORT,
	   env.CDMFINZWECK,
	   env.cdmhaltekategorie, 
	   env.CDMHALTEKATEGORIEIFRS,
	   env.CDMHALTEKATEGORIEIFRSFINAL,
	   env.tradedate,
	   env.CDMFXVERWZWECK,
	   env.structureid,
	   fx.spotdate,
	   fx.valdate,
	   fx.xrate,
	   fx.spotrate,
	   fx.fwdsoldamt,
	   fx.boughtamt,
	   fx.pors, 
	   fx.soldccy,
	   fx.boughtccy
	   --azg.OE_ABT_FFC_ID,
from dmenv env

left outer join dmforex fx
on fx.dmownertable = env.dmownertable
and fx.tradeid = env.tradeid
and fx.audit_version = env.audit_version

--left outer join AZG0005 azg
--on azg.OWNER_TABLE = ast.dmownertable
--and azg.TRADE_ID = ast.tradeid

where env.audit_authorized = 'Y'
and env.audit_entitystate not in ('PEND','DONE')
order by env.tradeId
) prod

where prod.klassifizierung is not null
) res
group by res.CDMLIQUIPORT
order by res.CDMLIQUIPORT
;
