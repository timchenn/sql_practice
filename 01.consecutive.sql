-- ----------------------------------------------------------------------------------------------------------------------------------
-- seat id
-- ----------------------------------------------------------------------------------------------------------------------------------

-- query all the consecutive seats
drop table if exists cinema;
create temp table cinema
(
seat_id int
, free int
);

insert into cinema
values
(1, 1),
(2, 0),
(3, 1),
(4, 1),
(5, 1)
;

-- answers

select * from cinema;

select distinct(a.seat_id)
from cinema a
inner join cinema b
on abs(a.seat_id - b.seat_id) = 1
and a.free = 1 and b.free = 1
-- and a.free = true and b.free = true
order by a.seat_id
;


select a.seat_id
from cinema a
where 1 = 1
and a.free = 1
and 
(
a.seat_id + 1 in (select seat_id from cinema where free = 1)
or 
a.seat_id - 1 in (select seat_id from cinema where free = 1)
)
order by a.seat_id
;


-- ----------------------------------------------------------------------------------------------------------------------------------
-- logs
-- ----------------------------------------------------------------------------------------------------------------------------------


-- query all the numbers that appears 3 times consecutively
drop table if exists logs;
create temp table logs
(
  id int
, num int
);

insert into logs
values
(1, 1),
(2, 1),
(3, 1),
(4, 2),
(5, 1),
(6, 2),
(7, 2),
(8, 4),
(9, 4),
(10, 4)
;

-- answers

select distinct a.num
from logs a, logs b, logs c
where 1 = 1
and a.id = b.id - 1 
and b.id = c.id - 1
and a.num = b.num
and b.num = c.num
order by 1
;