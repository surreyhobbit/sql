select e.dmOwnertable,
       e.tradeId,
	   e.audit_entitystate,
	   s.sec,
	   a.dmAssetId,
       e.*, 
	   b.*,
	   s.*,
	   a.*

from dmEnv e, dmBond b, dmSec s, dmSAsset a

where e.dmOwnertable = 'BOND_TR'
  -- Join Bedingungen:
  and e.tradeId       = b.tradeId
  and e.audit_version = b.audit_version
  and s.sec           = b.sec
  and s.dmAssetId     = a.dmAssetId
  -- Juristischer Bestand:
  and e.audit_authorized = 'Y'
  and e.audit_entitystate not in ('PEND','DONE')
  and e.desk not in ('BEWERT','INTGESCH')
  and b.bondMktType not in  ('DEPTRN')
  
order by e.tradeId