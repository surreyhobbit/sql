select env.dmownertable, env.desk, env.book, ass.subtype, max(ass.matdate), env.AUDIT_ENTITYSTATE, count(*) from dmenv env
inner join dmasset ass
on ass.tradeid = env.tradeid
and ass.audit_version = env.audit_version
where env.dmownertable in ('CAPTR', 'SWAP', 'EXOTIC')
--and desk in ('DERIVATIVE', 'K', 'KV_DERIVATIVE'
and env.audit_current = 'Y'
group by env.dmownertable, env.desk, env.book, ass.subtype, ass.matdate, env.AUDIT_ENTITYSTATE
order by env.dmownertable, env.desk, env.book, ass.subtype, ass.matdate, env.AUDIT_ENTITYSTATE

select env.dmownertable, env.desk, env.book,