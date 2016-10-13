--Summit Geldhandel / Auftragsfinanzierung************************************************************ 

--Klassifikation Tagesgeld

select env.tradeid, ast.dmassetid, env.dmownertable, env.desk, env.book, ast.mmtype from dmenv env
inner join dmasset ast
on ast.tradeid = env.tradeid
where 
(env.dmownertable = 'MM'
and env.DESK = 'GELDMARKT'
and env.book = 'TAGESGELDER'
and ast.mmtype in ('DEPOSIT', 'LOAN'))
or
(env.dmownertable = 'MM'
and env.DESK = 'INTGESCH'
and env.book = 'INTTAGES'
and ast.mmtype in ('CDEPO', 'CLOAN'))
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')

;

--Klassifikation Termingeld

select env.tradeid, ast.dmassetid, env.dmownertable, env.desk, env.book, ast.mmtype from dmenv env
inner join dmasset ast
on ast.tradeid = env.tradeid
where 
(env.dmownertable = 'MM'
and env.DESK = 'GELDMARKT'
and env.book = 'TERMINGELDER'
and ast.mmtype in ('DEPOSIT', 'LOAN'))
or
(env.dmownertable = 'MM'
and env.DESK = 'INTGESCH'
and env.book = 'INTTERMIN'
and ast.mmtype in ('DEPOSIT', 'LOAN'))
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

--Klassifikation Tagesgeld b.a.w.

select env.tradeid, ast.dmassetid, env.dmownertable, env.desk, env.book, ast.mmtype from dmenv env
inner join dmasset ast
on ast.tradeid = env.tradeid
where 
(env.dmownertable = 'MM'
and env.DESK = 'GELDMARKT'
and env.book = 'TAGESGELDER'
and ast.mmtype in ('CDEPO', 'CLOAN'))
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

--Summit Wertpapierleihe*********************************************************** 

--Klassifikation Sec Lending

select env.tradeid, env.dmownertable, env.desk, env.book, rep.reptype, rep.repomkttype from dmenv env
inner join dmrepo rep
on rep.tradeid = env.tradeid
where 
env.dmownertable = 'REPO_TR'
and env.DESK = 'GELDMARKT'
and env.book = 'WP_LEIHE'
and rep.reptype = 'SECL'
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

--Summit Pensionsgeschäfte*********************************************************** 

--Klassifikation Sell/Buy Back

select env.tradeid, env.dmownertable, env.desk, env.book, rep.reptype, rep.repomkttype from dmenv env
inner join dmrepo rep
on rep.tradeid = env.tradeid
where 
env.dmownertable = 'REPO_TR'
and env.DESK = 'GELDMARKT'
and env.book = 'REPO'
and rep.reptype = 'SBBK'
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

--Klassifikation Buy/Sell Back

select env.tradeid, env.dmownertable, env.desk, env.book, rep.reptype, rep.repomkttype from dmenv env
inner join dmrepo rep
on rep.tradeid = env.tradeid
where 
env.dmownertable = 'REPO_TR'
and env.DESK = 'GELDMARKT'
and env.book = 'REPO'
and rep.reptype = 'BSBK'
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

--Klassifikation Repo

select env.tradeid, env.dmownertable, env.desk, env.book, rep.reptype, rep.repomkttype from dmenv env
inner join dmrepo rep
on rep.tradeid = env.tradeid
where 
env.dmownertable = 'REPO_TR'
and env.DESK = 'GELDMARKT'
and env.book = 'REPO'
and rep.reptype = 'REPO'
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

--Klassifikation Reverse Repo
select env.tradeid, env.dmownertable, env.desk, env.book, rep.reptype, rep.repomkttype from dmenv env
inner join dmrepo rep
on rep.tradeid = env.tradeid
where 
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
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')

--Summit Offenmarktgeschäfte*********************************************************** 

--Spitzenrefinanzierungsfazilität mit Zentralbanken

select env.tradeid, env.dmownertable, env.desk, env.book, rep.reptype, rep.repomkttype from dmenv env
inner join dmrepo rep
on rep.tradeid = env.tradeid
where 
env.dmownertable = 'REPO_TR'
and env.DESK = 'GELDMARKT'
and env.book = 'REPO'
and rep.reptype = 'NOCL'
and rep.repomkttype = 'CBK'
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

--Wertpapierpensionsgeschäft mit Zentralbanken

select env.tradeid, env.dmownertable, env.desk, env.book, rep.reptype, rep.repomkttype from dmenv env
inner join dmrepo rep
on rep.tradeid = env.tradeid
where 
env.dmownertable = 'REPO_TR'
and env.DESK = 'GELDMARKT'
and env.book = 'REPO'
and rep.reptype = 'NOCL'
and rep.repomkttype = 'CBKT'
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')

--Summit Collateral********************************************************** 

--Cash Collateral

select env.tradeid, env.dmownertable, env.desk, env.book, rep.reptype, rep.repomkttype from dmenv env
inner join dmrepo rep
on rep.tradeid = env.tradeid
where 
env.dmownertable = 'REPO_TR'
and env.DESK = 'PORTFOLIO'
and env.book = 'SICHERHEITEN'
and rep.reptype = 'CMNC'
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
