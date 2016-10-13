-- Profiling Stammdaten Summit

--*************** Optionen ****************************************************************

--Ausprägungen Klassifizierung:
--Swaption
--Zinsoption

select res.CDMLIQUIPORT, count(*) from
(
select * from 
(
select case
	   	   when 
		    env.dmownertable = 'SWAPTION'
			and env.DESK = 'DERIVATIVE'
			and env.book = 'DERIVATE'
			and env.structureid = ' '
		   then 'Swaption'
		   when
		    env.dmownertable = 'CAPTR'
			and env.DESK = 'DERIVATIVE'
			and env.book = 'DERIVATE'
			and env.structureid = ' '
		   then 'Zinsoption'
		   else ''
	   end as klassifizierung,
	   env.FOLDER,
	   env.AUDIT_ENTITYSTATE, 
	   env.tradeid, 
	   env.dmownertable, 
	   env.desk,
	   env.book,
	   env.CDMLIQUIPORT,
	   env.CDMFINZWECK,
	   env.CDMFXVERWZWECK,
	   env.cdmhaltekategorie, 
	   env.CDMHALTEKATEGORIEIFRS,
	   env.CDMHALTEKATEGORIEIFRSFINAL,
	   env.tradedate,
	   opt.expdate,
	   opt.pors,
	   opt.notccy,
	   opt.StkCcy,
	   opt.style,
	   opt.underlying,
	   opt.strike,
	   opt.SettleData_StlMode,
	   opt.PremData_Premium,
	   opt.PremData_Ccy,
	   opt.PremData_Date,
	   opt.porc,
	   opt.SETTLEDATA_PARTEXER
	   --azg.OE_ABT_FFC_ID,
from dmenv env

left outer join dmoption opt
on opt.dmownertable = env.dmownertable
and opt.tradeid = env.tradeid
and opt.audit_version = env.audit_version

--left outer join AZG0005 azg
--on azg.OWNER_TABLE = opt.dmownertable
--and azg.TRADE_ID = opt.tradeid

where env.audit_authorized = 'Y'
and env.audit_entitystate not in ('PEND','DONE')
order by env.tradeId
) prod

where prod.klassifizierung is not null

) res
group by res.CDMLIQUIPORT
order by res.CDMLIQUIPORT
;
