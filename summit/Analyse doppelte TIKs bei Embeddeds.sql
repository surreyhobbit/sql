
select e.tradeid, e.dmownertable, ba.secid, e.structureid from dmsec s
inner join dmback ba
on ba.secid = s.sec
-- s.sec, e.structureid, e.tradeid, e.dmownertable, e2.tradeid, e2.dmownertable from dmsec s
--inner join dmbond b
--on b.SEC = s.sec
--and b.audit_version = s.audit_version
inner join dmenv e
on e.tradeid = ba.tradeid
and e.audit_version = ba.audit_version
--inner join dmenv e2
--on e2.structureid = e.structureid
--and e2.audit_version = e.audit_version
--where s.cdmtrennungspflicht ='Y'
where s.audit_current = 'Y'
and e.audit_current = 'Y'
and e.audit_entitystate = 'VER'
--and ba.audit_current = 'Y'
--and e2.audit_current = 'Y'
and e.dmownertable not in ('BOND_TR')
and e.structureid <> ' '
--and ba.secid is not null
--and s.sec = 'SSD000013391'
--group by e2.tradeid, e2.dmownertable 
--group by s.sec, e.structureid, e2.tradeid, e2.dmownertable
--having count(*) > 1
order by s.sec, e.structureid



select * from dmenv
where structureid in ('S137382',
'S152121',
'S169467')


select * from dmenv
where tradeid = '78273F'


select s.sec, e.structureid, e.tradeid, e.dmownertable, e2.tradeid, e2.dmownertable from dmsec s
inner join dmbond b
on b.SEC = s.sec
--and b.audit_version = s.audit_version
inner join dmenv e
on e.tradeid = b.tradeid
and e.audit_version = b.audit_version
inner join dmenv e2
on e2.structureid = e.structureid
--and e2.audit_version = e.audit_version
where s.cdmtrennungspflicht ='Y'
and s.audit_current = 'Y'
and e.audit_current = 'Y'
and e2.audit_current = 'Y'
and e2.tradeid = '60243F'
and e2.dmownertable in ('SWAP', 'EXOTIC', 'MUST_TR', 'FX_SWAP')
and e.structureid <> ' '
--and s.sec = 'SSD000013391'
--group by e2.tradeid, e2.dmownertable 
--group by s.sec, e.structureid, e2.tradeid, e2.dmownertable
--having count(*) > 1

--select * from (

--select * from (
--select e2.tradeid, e2.dmownertable, count(*) as anz
select e1.*
from dmenv e1
inner join dmenv e2
  on  e2.structureid = e1.structureid
  and e2.audit_current = 'Y'
  and e2.dmownertable in ('SWAP', 'EXOTIC', 'MUST_TR', 'FX_SWAP')
  inner join dmback ba
  on 
where e1.DMOWNERTABLE = 'BOND_TR'
and   e1.audit_current = 'Y'
and   e1.audit_entitystate = 'VER'
--and   e2.audit_entitystate = 'VER'
and   e1.structureid <> ' '
--and   e2.tradeid = '79487F'
and   e1.ismirror <> 'Y'
and   substr(e1.tradeid,1,1) <> '2'
and   e1.cdmssdfrom = ' '
--group by e2.tradeid, e2.dmownertable
--)
--where anz > 1

select *
from dmenv
where 
