
-- ----------------------------------------------------------------------------------------------------------------------------------
-- students' seats
-- ----------------------------------------------------------------------------------------------------------------------------------


-- swap seat for adjacemtn students

drop table if exists seat;
create temp table seat
(
  id int
, student varchar(32)
);

insert into seat
values
(1, 'Abbot'),
(2, 'Doris'),
(3, 'Emerson'),
(4, 'Green'),
(5, 'James')
;

-- asnwers

select 
    case
	  when id % 2 <> 0 and id = (select count(*) from seat) then id -- last row
	  -- if not last row
	  when id % 2 <> 0 then id + 1 
	  when id % 2 = 0 then id - 1
	end as id
  , student
from seat
order by 1
;



-- ----------------------------------------------------------------------------------------------------------------------------------
-- department salary
-- ----------------------------------------------------------------------------------------------------------------------------------

-- calculate the median salary within each department

drop table if exists employee;
create temp table employee
(
  id int
, company varchar(32)
, salary int
);

insert into employee
values
(1, 'A', 2341)
, (2, 'A', 341)
, (3, 'A', 15)
, (4, 'A', 15314)
, (5, 'A', 451)
, (6, 'A', 513)
, (7, 'B', 15)
, (8, 'B', 13)
, (9, 'B', 1154)
, (10, 'B', 1345)
, (11, 'B', 1221)
, (12, 'B', 234)
, (13, 'C', 2345)
, (14, 'C', 2645)
, (15, 'C', 2645)
, (16, 'C', 2652)
, (17, 'C', 65)
;

-- asnwers

-- getting median
select 
    company
  , percentile(cast(salary as bigint), 0.5) as salary
from employee
group by 1
order by 1
;


-- using rank but NOT the precise median
-- -- if the number of each group is an even number then it would return the higher / lower of the 2
select a.id, a.company, a.salary
from
  (
  select a.*, row_number() over(partition by company order by salary desc) as rnk
  -- select a.*, row_number() over(partition by company order by salary asc) as rnk
  from employee as a
  ) as a
inner join 
  (
  select company, round(count(*) / 2) as med_rnk
  from employee
  group by 1
  ) as b 
  on a.company = b.company
 and a.rnk = b.med_rnk

order by 1, 2, 3
;


-- ----------------------------------------------------------------------------------------------------------------------------------
-- department salary
-- ----------------------------------------------------------------------------------------------------------------------------------

-- for each month, what's the department's avg salary compared to company wide avg salary?
-- -- higher
-- -- same
-- -- lower


drop table if exists salary;
create temp table salary
(
  id int
, employee_id int
, amount int
, pay_date date
);

insert into salary
values
(1, 1, 9000, '2017-03-31'),
(2, 2, 6000, '2017-03-31'),
(3, 3, 10000, '2017-03-31'),
(4, 1, 7000, '2017-02-28'),
(5, 2, 6000, '2017-02-28'),
(6, 3, 8000, '2017-02-28')
;

select * from salary;

drop table if exists employee;
create temp table employee
(
  employee_id int
, department_id int
);

insert into employee
values
(1, 1),
(2, 2),
(3, 2)
;

-- asnwers
select 
    a.pay_month
  , a.department_id
  , case 
      when avg_salary_dept > avg_salary_comp then 'higher'
      when avg_salary_dept < avg_salary_comp then 'lower'
      when avg_salary_dept = avg_salary_comp then 'same'
	end as comparison
from 
  (
  select date_format(pay_date, 'yyyy-MM') as pay_month, department_id, avg(amount) as avg_salary_dept
  from salary as a 
  left join employee as b
    on a.employee_id = b.employee_id
  group by 1, 2
  ) as a
left join 
  (
  select date_format(pay_date, 'yyyy-MM') as pay_month, avg(amount) as avg_salary_comp
  from salary as a 
  left join employee as b
    on a.employee_id = b.employee_id
  group by 1
  ) as b
  on a.pay_month = b.pay_month
order by 1 desc, 2
;