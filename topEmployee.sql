CREATE TABLE topEmp(
  empID VARCHAR(10) PRIMARY KEY,
  empName VARCHAR(30),
  voteID VARCHAR(12),
  year INT
);

create or replace function getDetails(out VARCHAR, out VARCHAR, out VARCHAR, out INT, out INT) returns setof record as
$$
    select empID, empName, voteID, year, conTop.votes from topEmp join conTop on empID=.conTop.empID;
$$
  language 'sql';

create or replace function getSpecDetails(in modYear INT, out VARCHAR, out VARCHAR, out VARCHAR, out INT, out INT) returns setof record as
$$
    select empID, empName, voteID, year, conTop.votes from topEmp join conTop on empID=.conTop.empID where year=modYear;
$$
  language 'sql';


create or replace function newtopEmp(emp_id VARCHAR, emp_Name VARCHAR, emp_votersID VARCHAR, emp_year INT) returns text as
$$
  declare
    test_id text;
    re_res text;
  begin
     select into test_id id from topEmp where year = emp_year and id=emp_id;
     if test_id isnull then

       insert into  topEmp (empID, empName, voteID, year) values (emp_id, emp_Name, emp_votersID, emp_year);
       re_res = 'Entry Added';

     else
       re_res = 'Entry already EXISTED';
     end if;
     return re_res;
  end;
$$
 language 'plpgsql';

create or replace function updateTopEmp(emp_id VARCHAR, emp_Name VARCHAR, emp_year INT, emp_votersID VARCHAR) returns text as
 $$
   declare
     test_id text;
     re_res text;
   begin
      select into test_id id from topEmp where year = emp_year and id=emp_id;
      if test_id isnull then
        re_res = 'Entry does not EXIST';
      else
      update topEmp  set empID=emp_id, empName=emp_Name, voteID=emp_votersID, year=emp_year where empID=emp_id;
        re_res = 'Entry updated';
      end if;
      return re_res;
   end;
 $$
  language 'plpgsql';

  CREATE TABLE conTop(
    votes INT,
    empYear INT,
    empID references topEmp(empID)
  );

create or replace function conTop(emp_votes INT, emp_year INT, emp_id VARCHAR) returns text as
   $$
     declare
       test_id text;
       re_res text;
     begin
        select into test_id id from conTop where year = emp_year and id=emp_id;
        if test_id isnull then
          insert into  conTop (votes, empYear, empID) values (emp_votes, emp_year, emp_id);
          re_res = 'Entry added';
        else
          re_res = 'Entry already exist';
        end if;
        return re_res;
     end;
   $$
    language 'plpgsql';

create or replace function Add_votes(emp_votes INT, emp_year INT, emp_id VARCHAR) returns text as
$$
  update conTop set votes=votes+emp_votes where empID=emp_id and empYear=emp_year;
$$
  language 'plpgsql';

create or replace function Sub_votes(emp_votes INT, emp_year INT, emp_id VARCHAR) returns text as
$$
  update conTop set votes=votes-emp_votes where empID=emp_id and empYear=emp_year;
$$
  language 'plpgsql';

create table conEntryEach(
  year int,
  empID references topEmp(empID),
  voteID references topEmp(voteID)
);
