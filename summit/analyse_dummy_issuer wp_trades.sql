select env.tradeid, sec.wp_type, sec.issuer, env.tradestatus, env.desk, count(*) from kdart5.dts_dmenv env
inner join kdart5.dts_dmbond bond
on bond.tradeid = env.tradeid
and bond.audit_version = env.audit_version
inner join kdart5.dts_dmsec sec
on sec.sec = bond.sec
inner join kdart5.dts_dmpostingevent post
on post.tradeid = env.tradeid
and post.ownertable = env.DMOWNERTABLE
where sec.issuer not like '0%'
and sec.issuer not like '1%'
and sec.issuer not like '2%'
and sec.issuer not like '3%'
and sec.issuer not like '4%'
and sec.issuer not like '5%'
and sec.issuer not like '6%'
and sec.issuer not like '7%'
and sec.issuer not like '8%'
and sec.issuer not like '9%'
/*
where sec.issuer like '0%'
or sec.issuer like '1%'
or sec.issuer like '2%'
or sec.issuer like '3%'
or sec.issuer like '4%'
or sec.issuer like '5%'
or sec.issuer like '6%'
or sec.issuer like '7%'
or sec.issuer like '8%'
or sec.issuer like '9%'
*/
and env.audit_authorized = 'Y'
and env.dmownertable = 'BOND_TR'
and env.tradestatus = 'VER'
--and env.tradeid = '0000049598'
group by env.tradeid, sec.wp_type, sec.issuer, env.tradestatus, env.desk
order by env.tradeid, sec.wp_type, sec.issuer, env.tradestatus, env.desk

select * from dmpostingevent
where tradeid = '0000049598'