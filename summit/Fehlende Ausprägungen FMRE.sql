select cdmliquiport, count(*) from dmenv
where audit_authorized = 'Y'
and dmownertable = 'BOND_TR'
group by cdmliquiport
order by cdmliquiport

select CDMHALTEKATEGORIEIFRS, count(*) from dmenv
where audit_authorized = 'Y'
and dmownertable in ('BOND_TR', 'CAPTR', 'SWAP', 'EXOTIC', 'MM', 'REPO_TR', 'FXSPOT', 'FXFWD', 'FXSWAP', 'SWAPTION')
group by CDMHALTEKATEGORIEIFRS
order by CDMHALTEKATEGORIEIFRS


select cdmfinzweck, cdmliquiport, count(*) from dmenv
where audit_authorized = 'Y'
and dmownertable in ('BOND_TR', 'CAPTR', 'SWAP', 'EXOTIC', 'MM', 'REPO_TR', 'FXSPOT', 'FXFWD', 'FXSWAP', 'SWAPTION')
group by cdmfinzweck, cdmliquiport
order by cdmfinzweck, cdmliquiport

select * from cdmmust_cashflow
where tradeid = '145932F'