
--Summit Zinsbegrenzungsgeschäft************************************************************ 

--Klassifikation CAP

select env.tradeid, ast.dmassetid, env.dmownertable, env.desk, env.book, ast.type, ast.subtype, ast.ccy, env.structureid from dmenv env
inner join dmasset ast
on ast.tradeid = env.tradeid
where env.dmownertable = 'CAPTR'
and env.DESK = 'DERIVATIVE'
and ast.type = 'IRG'
and ast.subtype = 'CAP'
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')

;

--Klassifikation FLOOR

select env.tradeid, ast.dmassetid, env.dmownertable, env.desk, env.book, ast.type, ast.subtype, ast.ccy, env.structureid from dmenv env
inner join dmasset ast
on ast.tradeid = env.tradeid
where env.dmownertable = 'CAPTR'
and env.DESK = 'DERIVATIVE'
and ast.type = 'IRG'
and ast.subtype = 'FLOOR'
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

--Klassifikation COLLAR

select env.tradeid, ast.dmassetid, env.dmownertable, env.desk, env.book, ast.type, ast.subtype, ast.ccy, env.structureid from dmenv env
inner join dmasset ast
on ast.tradeid = env.tradeid
where env.dmownertable = 'CAPTR'
and env.DESK = 'DERIVATIVE'
and ast.type = 'IRG'
and ast.subtype not in ('CAP', 'FLOOR')
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

--Summit Swap************************************************************ 

--Klassifikation Zinsswap(gleiche Währung pro trade)/Zinswährungsswap(unterschiedliche Währung pro trade)

select env.tradeid, ast.dmassetid, env.dmownertable, env.desk, env.book, ast.type, ast.subtype, ast.ccy, env.structureid from dmenv env
inner join dmasset ast
on ast.tradeid = env.tradeid
where 
(env.dmownertable in ('SWAP', 'EXOTIC')
and env.DESK = 'DERIVATIVE'
and env.book = 'DERIVATE')
or
(env.dmownertable in ('SWAP', 'EXOTIC')
and env.DESK = 'K'
and env.book = 'K_DERIVATE')
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;


--Summit Kreditderivat/Verbriefung********************************************************

--Klassifikation Portfolio CDS

select env.tradeid, ast.dmassetid, env.dmownertable, env.desk, env.book, ast.type, ast.subtype, ast.ccy, env.structureid from dmenv env
inner join dmasset ast
on ast.tradeid = env.tradeid
where env.dmownertable = 'EXOTIC'
and env.DESK = 'KV_DERIVATE'
and env.book = 'POOL_CDS'
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

--Klassifikation Single Name CDS

select env.tradeid, ast.dmassetid, env.dmownertable, env.desk, env.book, ast.type, ast.subtype, ast.ccy, env.structureid from dmenv env
inner join dmasset ast
on ast.tradeid = env.tradeid
where env.dmownertable = 'EXOTIC'
and env.DESK = 'KV_DERIVATE'
and env.book = 'SINGLE_CDS'
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

--Klassifikation Finanzgarantie

select ast.tradeid, ast.dmassetid, env.dmownertable, env.desk, env.book, ast.type, ast.subtype, ast.ccy, env.structureid from dmenv env
left outer join dmasset ast
on ast.tradeid = env.tradeid
where env.dmownertable = 'EXOTIC'
and env.DESK = 'KV_DERIVATE'
and env.book = 'FINGAR_CDS'
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;


--Summit Option************************************************************ 

--Klassifikation Swaption (Stand alone)

select env.tradeid, ast.dmassetid, env.dmownertable, env.desk, env.book, ast.type, ast.subtype, ast.ccy, env.structureid from dmenv env
inner join dmasset ast
on ast.tradeid = env.tradeid
where env.dmownertable = 'SWAPTION'
and env.DESK = 'DERIVATIVE'
and env.book = 'DERIVATE'
and env.structureid = ' '
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

--Klassifikation Zinsoption-

select env.tradeid, ast.dmassetid, env.dmownertable, env.desk, env.book, ast.type, ast.subtype, ast.ccy, env.structureid from dmenv env
inner join dmasset ast
on ast.tradeid = env.tradeid
where env.dmownertable = 'CAPTR'
and env.DESK = 'DERIVATIVE'
and env.book = 'DERIVATE'
and env.structureid = ' '
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')

;

--Summit Devisen*******************************************************

--Klassifikation Devisenswap

select env.tradeid, env.dmownertable, env.desk, env.book, env.structureid from dmenv env
inner join dmforex fx
on fx.tradeid = env.tradeid
where env.dmownertable = 'FXSWAP' 
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

--Klassifikation Kassa

select env.tradeid, env.dmownertable, env.desk, env.book, env.structureid from dmenv env
inner join dmforex fx
on fx.tradeid = env.tradeid
where env.dmownertable = 'FXSPOT' 
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

--Klassifikation Termin

select env.tradeid, env.dmownertable, env.desk, env.book, env.structureid from dmenv env
inner join dmforex fx
on fx.tradeid = env.tradeid
where env.dmownertable = 'FXFWD' 
and env.audit_authorized = 'Y'
and env.tradestatus not in ('PEND','DONE')
;

