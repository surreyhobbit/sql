select * from dmenv e 
inner join dmbond b
on b.tradeid = e.tradeid
and b.audit_version = e.audit_version
inner join cdmmicroaccounting a
on a.secid = b.sec
where e.AUDIT_AUTHORIZED = 'Y'
--and substr(e.CDMIAS_PRODUKTSCHUESSEL,114,1) = '1'
and e.tradeid in 
('123129F',
'126587F',
'123316F',
'178502F',
'109716F',
'53648F',
'53775F',
'71801F',
'50706F',
'50763F',
'53248F',
'178503F',
'178504F',
'79962F',
'51641F',
'51738F',
'121424F',
'61060F',
'63993F',
'65599F',
'81271F')

select * from kdart5.dth_cdmmicroaccounting
--where secid = 'DE000A0XXM38'

select * from kdart5.dts_dmbond
where sec = 'XS0951381523'

select * from kdart5.dts_dmenv
where substr(CDMIAS_PRODUKTSCHUESSEL,114,1) = '1'
and audit_authorized = 'Y'


select substr(CDMIAS_PRODUKTSCHUESSEL,114,1) from kdart5.dts_dmenv
where tradeid = '53648F'

select * from dmenv
where tradeid = '53648F'