select e.dmOwnertable,
       e.tradeId,
	   e.audit_entitystate,
	   a.dmAssetId,
       e.*, 
	   a.*,
	   r.*

from dmEnv e, dmAsset a, dmRepo r

where e.dmOwnertable  = 'REPO_TR'
  -- Join Bedingungen:
  and e.dmOwnertable  = a.dmOwnertable
  and e.tradeId       = a.tradeId
  and e.audit_version = a.audit_version
  and e.tradeId       = r.tradeId
  and e.audit_version = r.audit_version
  -- Juristischer Bestand:
  and e.audit_authorized = 'Y'
  and e.audit_entitystate not in ('PEND','DONE')
  
order by e.tradeId