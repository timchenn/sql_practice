-- 185. 部门工资前三高的所有员工
-- Write your MySQL query statement below

with agg_tbl as 
(
select 
    b.name as Department
  , a.name as Employee
  , a.salary
  , dense_rank() over(partition by b.name  order by a.salary desc) as rnk
from employee as a 
left join department as b
  on a.departmentId = b.id
)
select 
    Department
  , Employee
  , Salary
from agg_tbl
where 1 = 1
and rnk <= 3
;









-- 262. 行程和用户
-- # Write your MySQL query statement below

with base_tbl as 
(
select 
    request_at as day
  , count(distinct case when lower(status) like '%cancelled%' then id else null end) as cancelled_order
  , count(distinct id) as tot_order
from trips as a 
inner join users as b
  on a.client_id = b.users_id
  and lower(b.banned) = 'no'
inner join users as c
  on a.driver_id = c.users_id
  and lower(c.banned) = 'no'
where 1 = 1
and request_at between '2013-10-01' and '2013-10-03'
group by 1
)
select 
    Day
  , round(cancelled_order / tot_order, 2) as 'Cancellation Rate'
from base_tbl
order by 1
;


-- ----- ----- ----- ----- ----- ----- Unanswered

-- 569. 员工薪水中位数

SELECT 
    id, company, salary 
FROM (
	SELECT
		id, company, salary,
		row_number() over(partition by company order by salary) as tag,
		count(id) over(partition by company) as total
	FROM employee
) t
WHERE t.tag IN (floor((total + 1) / 2), floor((total + 2) / 2));



-- ----- ----- ----- ----- ----- ----- Unanswered

--  579. 查询员工的累计薪水
SELECT E1.Id,
    E1.Month,
    SUM(E2.Salary) AS Salary
FROM EMPLOYEE AS E1
LEFT JOIN EMPLOYEE AS E2
    ON E1.ID = E2.ID
    AND E2.MONTH BETWEEN E1.MONTH - 2 AND E1.MONTH
WHERE (E1.ID,E1.MONTH) NOT IN 
    (SELECT ID,MAX(MONTH) AS MONTH FROM EMPLOYEE GROUP BY 1)
GROUP BY 1,2
ORDER BY 1 ASC,2 DESC
；

select 
	id,	month,
	sum(salary) over(partition by id order by month range 2 preceding) salary
from (
	select
		id, month, salary, 
		row_number() over(partition by id order by month desc) rk
	from employee
) e1 where rk >= 2
order by id, month desc;
