
-- ----------------------------------------------------------------------------------------------------------------------------------
-- department salary
-- ----------------------------------------------------------------------------------------------------------------------------------

-- get department's highest salary
drop table if exists employee;
create temp table employee
(
  id int
, name varchar(32)
, salary int
, departmentid int
);

insert into employee
values
(1, 'Joe', 70000, 1),
(2, 'Henry', 80000, 2),
(3, 'Sam', 60000, 2),
(4, 'Max', 90000, 1)
;

drop table if exists dept;
create temp table dept
(
  id int
, name varchar(32)
);

insert into dept
values
(1, 'IT'),
(2, 'Sales')
;

-- answers
select b.name as department, a.name as employee, a.salary as salary
from 
  (
  select a.*, dense_rank() over(partition by departmentid order by salary desc) as rnk
  from employee as a
  ) as a
left join dept as b
  on a.departmentid = b.id
where 1 = 1
and rnk = 1
order by 3 desc
;


select 
    dep.name as department
  , emp.name as employee
  , emp.salary as salary
from dept dep, employee emp
where 1 = 1
and emp.departmentid = dep.id
and emp.salary = (select max(salary) from employee e2 where e2.departmentid = dep.id)
order by 3 desc
;


select
    d.name as department
  , e.name as employee
  , e.salary as salary
from employee e,
    (
	  select departmentid, max(salary) as max 
	  from employee
	  group by departmentid
	  ) t,
	  dept d
where 1 = 1
and e.departmentid = t.departmentid
and e.salary = t.max
and e.departmentid = d.id
order by 3 desc
;






-- get department's top 3 highest salary
drop table if exists employee;
create temp table employee
(
  id int
, name varchar(32)
, salary int
, departmentid int
);

insert into employee
values
(1, 'Joe', 70000, 1),
(2, 'Henry', 80000, 2),
(3, 'Sam', 60000, 2),
(4, 'Max', 90000, 1),
(5, 'Janet', 69000, 1),
(6, 'Randy', 85000, 1)
;

drop table if exists dept;
create temp table dept
(
  id int
, name varchar(32)
);

insert into dept
values
(1, 'IT'),
(2, 'Sales')
;

-- answers

select b.name as department, a.name as employee, a.salary as salary
from 
(
select a.*, row_number() over(partition by departmentid order by salary desc) as rnk
from employee as a
) as a
left join dept as b
  on a.departmentid = b.id
where 1 = 1
and rnk <= 3
order by 1, 3 desc
;