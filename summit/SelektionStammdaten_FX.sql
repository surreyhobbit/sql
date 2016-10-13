select e.dmOwnertable,
       e.tradeId,
	   e.audit_entitystate,
       e.*, 
	   f.*

from dmEnv e, dmForex f

where e.dmOwnertable in ('FXSPOT','FXFWD','FXSWAP')
  -- Join Bedingungen:
  and e.dmOwnertable  = f.dmOwnertable
  and e.tradeId       = f.tradeId
  and e.audit_version = f.audit_version
  -- Juristischer Bestand:
  and e.audit_authorized = 'Y'
  and e.audit_entitystate not in ('PEND','DONE')
  
order by e.tradeId