-- Profiling Stammdaten Summit

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

select res.CDMLIQUIPORT, count(*) from 
(
select * from 
(
select case
	   	   when 
		    (env.dmownertable = 'MM'
			and env.DESK = 'GELDMARKT'
			and env.book = 'TAGESGELDER'
			and ast.mmtype in ('DEPOSIT', 'LOAN'))
			or
			(env.dmownertable = 'MM'
			and env.DESK = 'INTGESCH'
			and env.book = 'INTTAGES'
			and ast.mmtype in ('CDEPO', 'CLOAN'))
		   then 'Tagesgeld'
		   when
		    (env.dmownertable = 'MM'
			and env.DESK = 'GELDMARKT'
			and env.book = 'TERMINGELDER'
			and ast.mmtype in ('DEPOSIT', 'LOAN'))
			or
			(env.dmownertable = 'MM'
			and env.DESK = 'INTGESCH'
			and env.book = 'INTTERMIN'
			and ast.mmtype in ('DEPOSIT', 'LOAN'))
		   then 'Termingeld'
		   when
		    env.dmownertable = 'MM'
			and env.DESK = 'GELDMARKT'
			and env.book = 'TAGESGELDER'
			and ast.mmtype in ('CDEPO', 'CLOAN')
		   then 'Tagesgeld b.a.w.'
		   when
		    env.dmownertable = 'REPO_TR'
			and env.DESK = 'GELDMARKT'
			and env.book = 'WP_LEIHE'
			and rep.reptype = 'SECL'
		   then 'Sec Lending'
		   when
		    env.dmownertable = 'REPO_TR'
			and env.DESK = 'GELDMARKT'
			and env.book = 'REPO'
			and rep.reptype = 'SBBK'
		   then 'Sell/Buy Back'
		   when
		    env.dmownertable = 'REPO_TR'
			and env.DESK = 'GELDMARKT'
			and env.book = 'REPO'
			and rep.reptype = 'BSBK'
		   then 'Buy/Sell Back'
		   when
		    env.dmownertable = 'REPO_TR'
			and env.DESK = 'GELDMARKT'
			and env.book = 'REPO'
			and rep.reptype = 'REPO'
		   then 'Repo'
		   when
		    (env.dmownertable = 'REPO_TR'
			and env.DESK = 'GELDMARKT'
			and env.book = 'REPO'
			and rep.reptype = 'REV'
			and rep.repomkttype = ' ')
			or
			(env.dmownertable = 'REPO_TR'
			and env.DESK = 'GELDMARKT'
			and env.book = 'REPO'
			and rep.reptype = 'REV'
			and rep.repomkttype = 'TRIPARTY')
		   then 'Reverse Repo'
		   when
		    env.dmownertable = 'REPO_TR'
			and env.DESK = 'GELDMARKT'
			and env.book = 'REPO'
			and rep.reptype = 'NOCL'
			and rep.repomkttype = 'CBK'
		   then 'Spitzenrefinanzierungsfazilität mit Zentralbanken'
		   when
		    env.dmownertable = 'REPO_TR'
			and env.DESK = 'GELDMARKT'
			and env.book = 'REPO'
			and rep.reptype = 'NOCL'
			and rep.repomkttype = 'CBKT'
		   then 'Wertpapierpensionsgeschäft mit Zentralbanken'
		   when
		    env.dmownertable = 'REPO_TR'
			and env.DESK = 'PORTFOLIO'
			and env.book = 'SICHERHEITEN'
			and rep.reptype = 'CMNC'
		   then 'Cash Collateral'
		   else ''
	   end as klassifizierung, 
	   env.FOLDER,
	   env.AUDIT_ENTITYSTATE, 
	   env.tradeid,
	   env.dmownertable, 
	   env.desk, 
	   env.book,
	   env.CDMFINZWECK,
	   env.CDMFXVERWZWECK,
	   env.cdmLiquiPort,
	   env.cdmhaltekategorie, 
	   env.CDMHALTEKATEGORIEIFRS,
	   env.CDMHALTEKATEGORIEIFRSFINAL,
	   ast.dmassetid,  
	   ast.mmtype,
	   ast.ccy, 
	   ast.effdate, 
	   ast.matdate, 
	   ast.interest_basis, 
	   ast.pors, 
	   ast.interest_fixfloat,
	   rep.reptype,
	   rep.repomkttype
	   --sfloat.sEVTYP,
	   --sfloat.sFLTYPE,
	   --azg.OE_ABT_FFC_ID,
from dmenv env

left outer join dmasset ast
on ast.dmownertable = env.dmownertable
and ast.tradeid = env.tradeid
and ast.audit_version = env.audit_version

left outer join dmrepo rep
on rep.tradeid = ast.tradeid
and rep.audit_version = ast.audit_version

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
