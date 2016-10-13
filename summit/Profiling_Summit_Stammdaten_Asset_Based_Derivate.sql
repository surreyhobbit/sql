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

select res.CDMLIQUIPORT, count(*) from
(
select * from 
(
select case
		   when 
		    env.dmownertable = 'CAPTR'
		    and env.DESK = 'DERIVATIVE'
		    and ast.type = 'IRG'
		    and ast.subtype = 'CAP'
		   then 'Cap'
		   when
		    env.dmownertable = 'CAPTR'
		    and env.DESK = 'DERIVATIVE'
		    and ast.type = 'IRG'
		    and ast.subtype = 'FLOOR'
		   then 'Floor'
		   when
		    env.dmownertable = 'CAPTR'
		    and env.DESK = 'DERIVATIVE'
		    and ast.type = 'IRG'
		    and ast.subtype not in ('CAP', 'FLOOR')
		   then 'Collar'
		   when
		    (env.dmownertable in ('SWAP', 'EXOTIC')
		    and env.DESK = 'DERIVATIVE'
		    and env.book = 'DERIVATE')
		    or
		    (env.dmownertable in ('SWAP', 'EXOTIC')
		    and env.DESK = 'K'
		    and env.book = 'K_DERIVATE')
		   then 'Zinsswap/Zinswährungsswap'
		   when
		    env.dmownertable = 'EXOTIC'
		    and env.DESK = 'KV_DERIVATE'
		    and env.book = 'POOL_CDS'
		   then 'Portfolio CDS'
		   when
		    env.dmownertable = 'EXOTIC'
		    and env.DESK = 'KV_DERIVATE'
		    and env.book = 'SINGLE_CDS'
		   then 'Single Name CDS'
		   when
		    env.dmownertable = 'EXOTIC'
		    and env.DESK = 'KV_DERIVATE'
		    and env.book = 'FINGAR_CDS'
		   then 'Finanzgarantie'
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
	   env.structureid, 
	   ast.dmassetid, 
	   ast.type, 
	   ast.subtype, 
	   ast.ccy, 
	   ast.effdate, 
	   ast.matdate, 
	   ast.interest_basis, 
	   ast.pors, 
	   ast.interest_fixfloat,
	   cdo.transactionid
	   --azg.OE_ABT_FFC_ID,
from dmenv env 

left outer join dmasset ast
on ast.dmownertable = env.dmownertable
and ast.tradeid = env.tradeid
and ast.audit_version = env.audit_version
--left outer join AZG0005 azg
--on azg.OWNER_TABLE = ast.dmownertable
--and azg.TRADE_ID = ast.tradeid 

left outer join	
(
select oiss.tradeid, pool.transactionid from cdmcdoiss oiss
inner join cdmCDOpool pool
on pool.transactionid = oiss.transactionid
and pool.audit_version = oiss.audit_version
where pool.audit_current = 'Y'
and pool.audit_entitystate not in ('PEND','DONE')
and oiss.tradeid <> ' '
) cdo
on cdo.tradeid = ast.tradeid

where env.audit_authorized = 'Y'
and env.audit_entitystate not in ('PEND','DONE')
order by env.tradeId
) prod

where prod.klassifizierung is not null
) res
group by res.CDMLIQUIPORT
order by res.CDMLIQUIPORT

;
