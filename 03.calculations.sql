
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

select 
    company
  , percentile(cast(salary as bigint), 0.5) as salary
from employee
group by 1
order by 1
;



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