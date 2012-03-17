-- soa-p provisioning script of postgresql RDBMS
-- JA Bride :  2 March 2011

create user esb with password 'esb';
create user bpel with password 'bpel';
create user poc with password 'poc';
grant all privileges on database esb to esb;
grant all privileges on database esb1 to esb;
grant all privileges on database bpel to bpel;
grant all privileges on database poc to poc;
alter user esb with password 'esb';
alter user bpel with password 'bpel';
alter user poc with password 'poc';
