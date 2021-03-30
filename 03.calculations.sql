
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



-- ----------------------------------------------------------------------------------------------------------------------------------
-- direct reports
-- ----------------------------------------------------------------------------------------------------------------------------------

-- find the manager with at least 5 direct reports


drop table if exists employee;
create temp table employee
(
  id int
, name varchar(32)
, department varchar(32)
, managerid int
);

insert into employee
values
(101, 'John', 'A', null),
(102, 'Dan', 'A', 101),
(103, 'James', 'A', 101),
(104, 'Amy', 'A', 101),
(105, 'Anne', 'A', 101),
(106, 'Ron', 'B', 101)
;

select * from employee;

-- asnwers

select name
from employee 
where 1 = 1
and id in 
  (
  select managerid
  from employee
  group by 1
  having 1 = 1
  and count(managerid) >= 5
  )
;


-- find duplicate columns

drop table if exists person;
create temp table person
(
  id int
, email varchar(32)
);

insert into person
values
  (1, 'a@gmail.com')
, (2, 'a@gmail.com')
, (3, 'b@gmail.com')
;

-- answers

select email
from person
group by 1
having count(*) > 1
;




-- ----------------------------------------------------------------------------------------------------------------------------------
-- score
-- ----------------------------------------------------------------------------------------------------------------------------------

-- rank the score
-- -- a comparison between 
-- -- -- row_number
-- -- -- dense_rank
-- -- -- rank

drop table if exists score;
create temp table score
(
  id int
, score decimal(4, 2)
);

insert into score
values
(1, 3.5),
(2, 3.65),
(3, 4),
(4, 3.85),
(5, 4),
(6, 3.65)
;

select * from score;

-- asnwers
select 
    score
  , rank() over(order by score desc) as rank
  , dense_rank() over(order by score desc) as dense_rank
  , row_number() over(order by score desc) as row_num_rank
from score
;




-- ----------------------------------------------------------------------------------------------------------------------------------
-- salary
-- ----------------------------------------------------------------------------------------------------------------------------------

-- find the cumulative salary of each employee 
-- -- excluding the most recent month
-- -- order by id asc and month desc

drop table if exists employee;
create temp table employee
(
  id int
, month int
, salary int
);

insert into employee
values
(1, 1, 20)
, (2, 1, 20)
, (1, 2, 30)
, (2, 2, 30)
, (3, 2, 40)
, (1, 3, 40)
, (3, 3, 60)
, (1, 4, 60)
, (3, 4, 70)
;

select * 
from employee
order by 1, 2
;

-- asnwers

select 
    a.id
  , max(b.month) as month
  , sum(b.salary) as salary
from employee as a
inner join employee as b
  on a.id = b.id
 and b.month between (a.month - 3) and (a.month - 1)
group by a.id, a.month
order by 1, 2 desc
;

select *
from employee as a
inner join employee as b
  on a.id = b.id
 and b.month between (a.month - 3) and (a.month - 1)
;

select 
    id
  , month
  , salary
from 
  (
  select
      id
    , month
    , sum(sum(salary)) over (partition by id order by month rows between 3 preceding and current row) as salary
    , row_number() over (partition by id order by month desc) as rnk
  
  from employee as a
  group by 1, 2
  having rnk <> 1
  order by 1, 2 desc
  )
;




-- ----------------------------------------------------------------------------------------------------------------------------------
-- trips
-- ----------------------------------------------------------------------------------------------------------------------------------


-- calculate the cancellation rate of unbanned users

drop table if exists trips;
create temp table trips
(
  id int
, client_id int
, driver_id int
, city_id int
, status varchar(32)
, request_at date
);
insert into trips
values
  (1, 1, 10, 1, 'completed', '2013-10-01')
, (2, 2, 11, 1, 'cancelled', '2013-10-01')
, (3, 3, 12, 6, 'completed', '2013-10-01')
, (4, 4, 13, 6, 'cancelled', '2013-10-01')
, (5, 1, 10, 1, 'completed', '2013-10-02')
, (6, 2, 11, 6, 'completed', '2013-10-02')
, (7, 3, 12, 6, 'completed', '2013-10-02')
, (8, 2, 12, 12, 'completed', '2013-10-03')
, (9, 3, 10, 12, 'completed', '2013-10-03')
, (10, 4, 13, 12, 'cancelled', '2013-10-03')
;

drop table if exists users;
create temp table users
(
  users_id int
, banned varchar(32)
, role varchar(32)
);
insert into users
values
  (1, 'No', 'client')
, (2, 'Yes', 'client') 
, (3, 'No', 'client') 
, (4, 'No', 'client') 
, (11, 'No', 'driver')
, (12, 'No', 'driver') 
, (13, 'No', 'driver') 
, (14, 'No', 'driver') 
;

select * from trips;
select * from users;


-- answers

select 
    request_at as day
  , round(sum(case when status = 'cancelled' then 1 else 0 end) / count(*), 2) as cencellation_rate
from trips as a
left join users as b
  on a.client_id = b.users_id
 and role = 'client'
where 1 = 1
and banned = 'No'
group by 1
order by 1
;



-- ----------------------------------------------------------------------------------------------------------------------------------
-- human traffic of stadium
-- ----------------------------------------------------------------------------------------------------------------------------------

drop table if exists stadium;
create temp table stadium
(
  id int
, date date
, people int
);
insert into stadium
values
  (1, '2017-01-01', 10)
, (2, '2017-01-02', 109)
, (3, '2017-01-03', 150)
, (4, '2017-01-04', 99)
, (5, '2017-01-05', 145)
, (6, '2017-01-06', 1455)
, (7, '2017-01-07', 199)
, (8, '2017-01-08', 188)
;


-- answers

with long_table as (
select
  *
  ,lag(people, 2) over (order by id asc) as pre2
  ,lag(people, 1) over (order by id asc) as pre1
  ,lead(people, 1) over (order by id asc) as nxt1
  ,lead(people, 2) over (order by id asc) as nxt2
from stadium
)
select
  id
  ,date
  ,people
from long_table
where people >= 100
  and ((pre2 >= 100 and pre1 >= 100) 
  or (pre1 >= 100 and nxt1 >= 100) 
  or (nxt1 >= 100 and nxt2 >= 100))
order by id;