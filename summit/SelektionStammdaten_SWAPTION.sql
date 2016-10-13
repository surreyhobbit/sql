select e.dmOwnertable,
       e.tradeId,
	   e.audit_entitystate,
	   a.dmAssetId,
       e.*, 
	   a.*,
	   o.*

from dmEnv e, dmAsset a, dmOption o

-- nicht so klar:
-- --> wollen wir die 2 Legs des zugrunde liegenden Swaps??
-- --> evtl. nur Join dmEnv, dmOption!!

where e.dmOwnertable  = 'SWAPTION'
  -- Join Bedingungen:
  and e.dmOwnertable  = a.dmOwnertable
  and e.tradeId       = a.tradeId
  and e.audit_version = a.audit_version
  and e.dmOwnertable  = o.dmOwnertable
  and e.tradeId       = o.tradeId
  and e.audit_version = o.audit_version  
  -- Juristischer Bestand:
  and e.audit_authorized = 'Y'
  and e.audit_entitystate not in ('PEND','DONE')
  
order by e.tradeId