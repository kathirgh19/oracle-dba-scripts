
--/STEPS TO DO BACK UP AND RESTORE DATABASE SCHEMAS ON DIFFERENT ORACLE SERVERS/

--run these queries on Source server sqlplus window 

create or replace directory dumpbackup as 'K:\dumpbackup';

grant read,write on directory dumpbackup to expimpdp;

GRANT EXECUTE ON DBMS_FILE_TRANSFER to expimpdp;

grant read,write on directory dumpbackup to system; 


--Run this on Source server cmd prompt window to export backup 
expdp expimpdp/impexpdp@AESOP DIRECTORY=dumpbackup full=y DUMPFILE=FULL_PROD_29THJAN.dmp LOGFILE=FULL_29TH_JAN.log consistent=y



--transfer the data dump files to target server on a desired location

--Run this query on Target server sqlplus window to restrict the connections during Restore
ALTER SYSTEM ENABLE RESTRICTED SESSION;
SELECT LOGINS FROM V$INSTANCE;
 
--All Active connected sessions on Oracle server
SELECT s.sid, s.serial#, s.username, s.status, s.machine, s.program, s.module, TO_CHAR(s.logon_Time, 'DD-MON-YYYY HH24:MI:SS') 
AS logon_time, p.spid AS os_process_id FROM v$session s, v$process p
WHERE s.paddr = p.addr  AND s.status = 'ACTIVE'
AND s.type = 'USER' -- Filter out background processes (optional, but usually helpful)
ORDER BY  s.logon_Time;

--KILL the active seesions except system, sys user accounts.
ALTER SYSTEM KILL SESSION '503,45268' IMMEDIATE;

--Run this query on Target server sqlplus window, you will get drop statements of db objects and  
--you have to copy those into a separate sql file and you can run that file to drop the schema objects from target server
select 'drop ' ||OBJECT_TYPE||' ' ||OWNER||'.'||object_name||';' from dba_objects where owner IN ('AESOP','PLATO','OPUS');

select 'drop ' ||OBJECT_TYPE||' ' ||OWNER||'.'||object_name||' CASCADE CONSTRAINTS;' from dba_objects where owner IN ('AESOP','PLATO','OPUS');


--run this query to check all db objects have been dropped and it should not give any objects
select owner,count(*) from dba_objects where owner in ('AESOP') group by owner;
select owner,count(*) from dba_objects where owner in ('PLATO') group by owner;
select owner,count(*) from dba_objects where owner in ('OPUS') group by owner;


--run the following queries on Target server sqlplus window 
create user expimpdp identified by impexpdp;

grant dba to expimpdp;
 
create or replace directory dumpbackup as 'K:\dumpbackup';
 
grant read,write on directory dumpbackup to system;
 
grant read,write on directory dumpbackup to expimpdp;

GRANT EXECUTE ON DBMS_FILE_TRANSFER to expimpdp;

ALTER SYSTEM DISABLE RESTRICTED SESSION;
SELECT LOGINS FROM V$INSTANCE;
 
 
--run this on target server cmd prompt window to IMPORT the data dump file 
impdp expimpdp/impexpdp@AESOPTST DIRECTORY=dumpbackup DUMPFILE=FULL_PROD_29THJAN.DMP SCHEMAS=AESOP,PLATO,OPUS LOGFILE=FULL_IMP_29TH_JAN.log
--this will does not require username since the statement itself has username..

   --(OR)--

impdp DIRECTORY=dumpbackup DUMPFILE=FULL_PROD_4THOCT.DMP SCHEMAS=AESOP,PLATO,OPUS LOGFILE=FULL_IMP_4TH_OCT.log
--this will require username and password to proceed import..


 
--run these queries on source and target server to compare the database objects 

set lines 333 pages 999;
select object_type, count(*) from dba_objects where owner='AESOP' GROUP BY object_type, owner;

set lines 333 pages 999;
select object_type, count(*) from dba_objects where owner='OPUS' GROUP BY object_type, owner;

set lines 333 pages 999;
select object_type, count(*) from dba_objects where owner='PLATO' GROUP BY object_type, owner;


--run this on target server sqlplus window to recompile invalid database objects
@C:\ORACLE_HOME\rdbms\admin\utlrp.sql

(OR)

-- run this to recompile invalid objects
EXEC UTL_RECOMP.RECOMP_SERIAL();

(OR)

open the schema browser on TOAD and select invalid objects for the schemas and try to re compile.


--run this on Target server sqlplus window to get the invalid db objects
SELECT owner, object_type, object_name, status FROM dba_objects WHERE  status = 'INVALID' ORDER BY owner, object_type, object_name;


--run these queries on target server sqlplus window 
@C:\SQL\POST_RESTORE.sql

@K:\RESTORE\08-role_privs_only.sql   -- if necessary

@K:\RESTORE\09-user_privs_only.sql   -- if necessary

@K:\RESTORE\10-EVERYONE.sql          -- if necessary




/*
---------------------
select tb.tablespace_name, tf.file_name from dba_tablespaces tb 
left join dba_temp_files tf 
on tf.tablespace_name = tb.tablespace_name 
where tb.contents = 'TEMPORARY';

ALTER TABLESPACE TEMP ADD TEMPFILE 'D:\ORACLE\AESOP\TEMP01.DBF'

     SIZE 20971520  REUSE AUTOEXTEND ON NEXT 655360  MAXSIZE 32767M;

ALTER TABLESPACE TEMP_NEW ADD TEMPFILE 'D:\ORACLE\AESOP\TEMP-NEW01.DBF'

     SIZE 4000M REUSE AUTOEXTEND ON NEXT 1048576000  MAXSIZE 8000M;

ALTER TABLESPACE TEMP_NEW ADD TEMPFILE 'D:\ORACLE\AESOP\TEMP-NEW02.DBF'

     SIZE 4000M REUSE AUTOEXTEND ON NEXT 1048576000  MAXSIZE 8000M;

ALTER TABLESPACE TEMP_NEW ADD TEMPFILE 'D:\ORACLE\AESOP\TEMP-NEW03.DBF'

     SIZE 4000M REUSE AUTOEXTEND ON NEXT 1048576000  MAXSIZE 8000M;

ALTER TABLESPACE TEMP_NEW ADD TEMPFILE 'D:\ORACLE\AESOP\TEMP-NEW04.DBF'

     SIZE 4000M REUSE AUTOEXTEND ON NEXT 1048576000  MAXSIZE 8000M;
	 
---------------------------
*/
 
 
 -- Taking single table Backup and Restore.....
 
expdp expimpdp/impexpdp@AESOP TABLES=AESOP.TRNSCHEDULEHDR DIRECTORY=dumpbackup DUMPFILE=TRNSCHEDULEHDR_export.dmp
 
impdp expimpdp/impexpdp@AESOPTST TABLES=AESOP.TRNSCHEDULEHDR DIRECTORY=dumpbackup DUMPFILE=TRNSCHEDULEHDR_export.dmp TABLE_EXISTS_ACTION=REPLACE
 

 



