select e.dmOwnertable,
       e.tradeId,
	   e.audit_entitystate,
	   a.dmAssetId,
       e.*, 
	   a.*

from dmEnv e, dmAsset a

where e.dmOwnertable  = 'SWAP'
  -- Join Bedingungen:
  and e.dmOwnertable  = a.dmOwnertable
  and e.tradeId       = a.tradeId
  and e.audit_version = a.audit_version
  -- Juristischer Bestand:
  and e.audit_authorized = 'Y'
  and e.audit_entitystate not in ('PEND','DONE')
  
order by e.tradeId