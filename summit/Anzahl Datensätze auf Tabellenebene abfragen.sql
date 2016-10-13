select a.SCHED_PAY_FREQ, 
	   count(*) as num 

from dmsec s inner join 
	 dmsasset a
	 
on a.DMASSETID = s.DMASSETID
and a.AUDIT_VERSION = s.AUDIT_VERSION

where s.AUDIT_CURRENT='Y'

-- and s.ccy is null -- there are no null values
group by a.SCHED_PAY_FREQ
order by a.SCHED_PAY_FREQ
;




select CDMFXVERWZWECK, count(*) from dmEnv
group by CDMFXVERWZWECK
order by CDMFXVERWZWECK
;

select TRADEID, count(*) from dmEnv
where TRADEID is null
group by TRADEID
order by TRADEID
;


