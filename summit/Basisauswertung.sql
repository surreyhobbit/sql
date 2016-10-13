select *
from dmenv e
where e.tradestatus  IN     ('CANC','VER','MAT')
and   e.dmownertable NOT IN ('BOND_TR')
;

select tradeid from (
select dmownertable, tradeid, dmassetid, count(*) as anz
from dmasset
group by dmownertable, tradeid, dmassetid
order by 1,2,3
)
where anz <> 1

;

select *
from dmforex
;

select distinct dmownertable
from dmasset

;

select dmownertable, tradeid, count(*) as anz
from dmenv
where 
group by dmownertable, tradeid
order by 1,2
-- Ownertable & Trade-ID ist eindeutig
;


select audit_entitystate, audit_authorized, tradestatus, count(*)
from dmenv
group by audit_entitystate, audit_authorized, tradestatus
order by 1,2,3
;

select *
from dmenv
;

select *
from dmpostingevent p
inner join dmenv e
on  e.dmownertable = p.ownertable
and e.tradeid      = p.tradeid
and e.tradestatus  in ('VER')
and e.AUDIT_AUTHORIZED = 'N'


;

select *
from dmenv
where tradeid = '52344F'
