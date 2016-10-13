SELECT E.TRADEID, E.DMOWNERTABLE, E.DESK, E.BOOK, E.AUDIT_ENTITYSTATE, D.CDMKVNR AS DARLEHEN
FROM DMENV E,
     CDMLOANS D
WHERE      
      D.TRADEID = E.TRADEID
  AND E.AUDIT_AUTHORIZED = 'Y'
  AND E.TRADESTATUS NOT IN ('PEND','DONE')
  AND E.AUDIT_ENTITYSTATE='VER'
  
-- K-SWAP SPEZIFISCH:
 
   AND E.DESK='K'
   AND E.FOLDER='SWAPLOAN'
   AND E.BOOK='K_DERIVATE'