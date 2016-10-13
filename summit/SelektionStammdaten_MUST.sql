select e.dmOwnertable,
       e.tradeId as glTradeId,
	   e.audit_entitystate,
	   c.component_type,
	   c.component_name,
   	   e.*
	   
from dmENV e, cdmMUST_CASHFLOW c

where e.dmOwnertable  = 'MUST_TR'
  -- Join Bedingungen:
  and e.tradeId       = c.tradeId
  and e.audit_version = c.audit_version
  -- Juristischer Bestand:
  and e.audit_authorized = 'Y'
  and e.audit_entitystate not in ('PEND','DONE')
  
--------------------------------------------------------  
union select e.dmOwnertable,
       e.tradeId as glTradeId,
	   e.audit_entitystate,
	   c.component_type,
	   c.component_name,
   	   e.*
	   
from dmENV e, cdmMUST_PRINCIPAL c
  where e.dmOwnertable  = 'MUST_TR'
  -- Join Bedingungen:
  and e.tradeId       = c.tradeId
  and e.audit_version = c.audit_version
  -- Juristischer Bestand:
  and e.audit_authorized = 'Y'
  and e.audit_entitystate not in ('PEND','DONE')
  
--------------------------------------------------------  
union select e.dmOwnertable,
       e.tradeId as glTradeId,
	   e.audit_entitystate,
	   c.component_type,
	   c.component_name,
   	   e.*
	   
from dmENV e, cdmMUST_FEE c
  where e.dmOwnertable  = 'MUST_TR'
  -- Join Bedingungen:
  and e.tradeId       = c.tradeId
  and e.audit_version = c.audit_version
  -- Juristischer Bestand:
  and e.audit_authorized = 'Y'
  and e.audit_entitystate not in ('PEND','DONE')
  
order by glTradeId
