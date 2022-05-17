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










-- ----- ----- ----- ----- ----- ----- Unanswered

--  601. 体育馆的人流量
SELECT 
    id, visit_date, people
FROM (
     SELECT 
        id, visit_date, people, count(*) over(partition by tag) as cnt_tag
     FROM (
        SELECT 
            id, visit_date, people, id - row_number() over(order by id) as tag
        FROM 
            stadium
        WHERE 
            people >= 100
    ) t
) y
WHERE 
    cnt_tag >= 3
ORDER BY id
;









-- 615. 平均工资：部门与公司比较

with base_tbl as 
(
select distinct
    date_format(pay_date, '%Y-%m') as pay_month
  , department_id
  , avg(amount) over(partition by pay_date, department_id) as dept_avg_salary
  , avg(amount) over(partition by pay_date) as company_avg_salary
from salary as a 
left join employee as b 
  on a.employee_id = b.employee_id
)
select distinct
    pay_month
  , department_id
  , case 
      when dept_avg_salary > company_avg_salary then 'higher'
      when dept_avg_salary = company_avg_salary then 'same'
      when dept_avg_salary < company_avg_salary then 'lower'
    end as comparison
from base_tbl
order by 2, 1


with dept as 
(
select
    date_format(pay_date, '%Y-%m') as pay_month
  , department_id
  , avg(amount) as dept_avg_salary
from salary as a 
left join employee as b 
  on a.employee_id = b.employee_id
group by 1, 2
), 
company as 
(
select
    date_format(pay_date, '%Y-%m') as pay_month
  , avg(amount) as company_avg_salary
from salary as a 
left join employee as b 
  on a.employee_id = b.employee_id
group by 1
)
select 
    a.pay_month
  , a.department_id
  , case 
      when dept_avg_salary > company_avg_salary then 'higher'
      when dept_avg_salary = company_avg_salary then 'same'
      when dept_avg_salary < company_avg_salary then 'lower'
    end as comparison
from dept as a 
left join company as b 
  on a.pay_month = b.pay_month
;




-- 618. 学生地理信息报告

select
     max(case when continent='America' then name else null end) as America
    ,max(case when continent='Asia' then name else null end) as Asia
    ,max(case when continent='Europe' then name else null end) as Europe
from(
    select row_number() over(partition by continent order by name) as rn
    , a.* from student as a
) t
group by rn



-- 1097. 游戏玩法分析 V

with base_tbl as 
(
select 
    player_id
  , min(event_date) as install_dt
  , min(event_date) + interval '1' day as 1d_retention_dt
from activity
group by 1
)
select 
    install_dt
  , count(distinct case when install_dt = event_date then a.player_id else null end) as installs
  , round(count(distinct case when 1d_retention_dt = event_date then a.player_id else null end) / count(distinct case when install_dt = event_date then a.player_id else null end), 2) as day1_retention
from base_tbl as a
left join activity as b 
  on a.player_id = b.player_id
group by 1
;

SELECT 
    first_date install_dt, 
    count(distinct a.player_id) installs,
    round(count(distinct b.player_id) / count(distinct a.player_id), 2) Day1_retention
FROM (
    SELECT 
        player_id, 
        min(event_date) first_date 
    FROM activity 
    GROUP BY player_id
) a
LEFT JOIN activity b ON a.player_id = b.player_id and DATEDIFF(b.event_date, a.first_date) = 1
GROUP BY first_date
ORDER BY first_date;





-- 1127. 用户购买平台
select 
	t2.spend_date,
	t1.platform,
	sum(if(t1.platform = t2.platform, amount, 0)) as total_amount,
	count(if(t1.platform = t2.platform, 1, null)) as total_users
from (
	select 'mobile' as platform union
	select 'desktop' as platform union
	select 'both' as platform 
) t1, (
	select 
		user_id,
		spend_date, 
		any_value(if(count(platform) = 2, 'both', platform)) platform,
		sum(amount) amount
	from spending
	group by user_id, spend_date
) t2 group by t2.spend_date, t1.platform

