Select 
case when blocking_SESSION is null then 'Root' else 'Child' end as BlockerType,
SID, SERIAL#, blocking_session, STATUS, wait_class, seconds_in_wait, username, OSUSER, Machine, program, V$Session.SQL_ID
, Curnt.SQL_FULLTEXT as CurrentSQL, Prev.SQL_FULLTEXT as PrevSQL
from V$Session left outer join V$SQL Curnt on V$Session.SQL_ID = Curnt.SQL_ID and V$Session.sql_child_number = Curnt.child_number
left outer join V$SQL Prev on V$Session.PREV_SQL_ID = Prev.SQL_ID and V$Session.PREV_CHILD_NUMBER = Prev.child_number
where SID in (
select blocking_session from V$SESSION where blocking_session is not null UNION
select SID from V$SESSION where blocking_session is not null 
) 
order by SID

--ALTER SYSTEM KILL SESSION '404,33077';

--Open Transactions..
/*
select t.start_time,s.sid,s.serial#,s.username,s.status,s.schemaname,
s.osuser,s.process,s.machine,s.terminal,s.program,s.module,to_char(s.logon_time,'DD/MON/YY HH24:MI:SS') logon_time
from v$transaction t, v$session s
where s.saddr = t.ses_addr
order by start_time;

-- ASH
select SQL_EXEC_START, SQL_EXEC_ID, sql_id, SQL_CHILD_NUMBER, min(sample_time), max(sample_time), count(*), count(distinct sample_id)
from V$ACTIVE_SESSION_HISTORY H
where session_id = 595
group by SQL_EXEC_START, SQL_EXEC_ID, sql_id, SQL_CHILD_NUMBER
order by min(sample_time) desc
 
select  TIME_MODEL, SQL_EXEC_ID, SQL_EXEC_START,  in_connection_mgmt, IN_PARSE, IN_HARD_PARSE, IN_SQL_EXECUTION, IN_PLSQL_EXECUTION,  H.sql_id,
sample_id, sample_time, sysdate, session_id, SESSION_SERIAL#, H.SQL_CHILD_NUMBER, BLOCKING_SESSION, BLOCKING_SESSION_SERIAL#, SQL_FULLTEXT
from V$ACTIVE_SESSION_HISTORY H left outer join V$SQL on H.sql_id = V$SQL.SQL_ID and H.SQL_CHILD_NUMBER = V$SQL.Child_Number
where session_id = 595
order by sample_id desc

*/