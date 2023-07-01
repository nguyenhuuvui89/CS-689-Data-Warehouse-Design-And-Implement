select count(*) as number_records, 'VincentNguyen' as MyName, Current_Date as Current_Date
from manufacture_fact;
-----Part 3
--Question 1
SELECT * from 
(select c.manufacture_year, f.factory_label, sum(m.qty_passed) as total_units_passed, sum(m.qty_failed) as total_units_passed,
		RANK() OVER (PARTITION BY c.manufacture_year
					ORDER BY sum(m.qty_passed) DESC ) as Ranking
from factory_dim f
join manufacture_fact m ON m.factory_key = f.factory_key
join calendar_manufacture_dim c on c.manufacture_cal_key = m.manufacture_cal_key
GROUP BY c.manufacture_year, f.factory_label) a
Where a.Ranking <=3
Order By a.manufacture_year DESC, a.Ranking;

/*---Question 2
select * from calendar_manufacture_dim
-----
SELECT a.factory_label, a.manufacture_monthofyear, 
sum(a.total_unit_passed) as total_unit_passed, sum(a.total_unit_failed) as total_unit_failed
From
(SELECT f.factory_label, m.product_key,
c.manufacture_monthofyear, sum(m.qty_passed), sum(m.qty_failed),
rank() OVER (partition by f.factory_label, c.manufacture_monthofyear ORDER by sum(m.qty_passed) DESC) as rank
from factory_dim f
join manufacture_fact m ON m.factory_key = f.factory_key
join calendar_manufacture_dim c on c.manufacture_cal_key = m.manufacture_cal_key
where c.manufacture_year = 'mY2022'
group by m.product_key, f.factory_label, c.manufacture_monthofyear) a
where a.rank <=3
group by rollup(a.factory_label, a.manufacture_monthofyear)*/

------Question 2 Version 2.

SELECT f.factory_label As factory_name, 
CASE
	When c.manufacture_monthofyear is not null then right(c.manufacture_monthofyear,2) || '-' || 
to_char(to_date(right(c.manufacture_monthofyear,2), 'MM'), 'Month') 
	ELSE Null 
	End AS MONTH,
sum(m.qty_passed) as total_unit_passed, sum(m.qty_failed) as total_unit_failed
from factory_dim f
join manufacture_fact m ON m.factory_key = f.factory_key
join calendar_manufacture_dim c on c.manufacture_cal_key = m.manufacture_cal_key
where c.manufacture_year = 'mY2022'
group by ROLLUP(f.factory_label, c.manufacture_monthofyear)
order by f.factory_label, c.manufacture_monthofyear;
------


----Question 2--Extra Credit
select * from product_dim
-----

Select pr.factory_name, pr.month, pr.product_description, sum(pr.total_units_passed) as Total_units_passed, sum(pr.total_units_failed) as Total_units_failed FROM 
(SELECT f.factory_label As factory_name, 
CASE When c.manufacture_monthofyear is not null then right(c.manufacture_monthofyear,2) || '-' || 
to_char(to_date(right(c.manufacture_monthofyear,2), 'MM'), 'Month') ELSE Null End AS MONTH, 
left(p.product_description, position(' id' in p.product_description)) as product_description,sum(m.qty_passed) as Total_units_passed, 
sum(m.qty_failed) as Total_units_failed, 
rank() over(PARTITION by f.factory_label, c.manufacture_monthofyear order by sum(m.qty_passed) desc) as rank_s
from factory_dim f
join manufacture_fact m ON m.factory_key = f.factory_key
join calendar_manufacture_dim c on c.manufacture_cal_key = m.manufacture_cal_key
join product_dim p on p.product_key = m.product_key
where c.manufacture_year = 'mY2022'
group by f.factory_label, p.product_description, c.manufacture_monthofyear
order by f.factory_label, c.manufacture_monthofyear) pr
where pr.rank_s <=3
group by rollup(pr.factory_name, pr.month, pr.product_description)
ORDER By pr.factory_name, pr.month
-------
-----Question 3

SELECT f.factory_label As factory_name,
CASE When c.manufacture_monthofyear is not null then right(c.manufacture_monthofyear,2) || '-' || 
to_char(to_date(right(c.manufacture_monthofyear,2), 'MM'), 'Month') ELSE Null End AS MONTH, p.brand_label as Brand,
sum(m.qty_passed) as Total_units_passed, 
sum(m.qty_failed) as Total_units_failed 
from factory_dim f
join manufacture_fact m ON m.factory_key = f.factory_key
join calendar_manufacture_dim c on c.manufacture_cal_key = m.manufacture_cal_key
join product_dim p on p.product_key = m.product_key
where c.manufacture_year = 'mY2022'
group by rollup(f.factory_label, c.manufacture_monthofyear, p.brand_label)
order by f.factory_label, c.manufacture_monthofyear


----
select * from calendar_manufacture_dim
-----Question 4
SELECT f.factory_label As factory_name,
CASE When c.manufacture_monthofyear is not null then right(c.manufacture_monthofyear,2) || '-' || 
to_char(to_date(right(c.manufacture_monthofyear,2), 'MM'), 'Month') ELSE Null End AS MONTH, p.brand_label as Brand,
sum(m.qty_passed) as Total_units_passed, 
sum(m.qty_failed) as Total_units_failed 
from factory_dim f
join manufacture_fact m ON m.factory_key = f.factory_key
join calendar_manufacture_dim c on c.manufacture_cal_key = m.manufacture_cal_key
join product_dim p on p.product_key = m.product_key
where c.manufacture_year = 'mY2022'
group by cube(f.factory_label, c.manufacture_monthofyear, p.brand_label)
order by f.factory_label, c.manufacture_monthofyear

--- Question 6

select * from calendar_manufacture_dim
order by manufacture_year desc
-------
select c.manufacture_year as year, f.factory_label as factory_name, sum(m.qty_passed) as Quantity_passed
from factory_dim f
join manufacture_fact m ON m.factory_key = f.factory_key
join calendar_manufacture_dim c on c.manufacture_cal_key = m.manufacture_cal_key
where c.manufacture_year between 'mY2017' and 'mY2022' and c.manufacture_monthofyear = 'mMO02' 
group by c.manufacture_year, f.factory_label
order by c.manufacture_year desc

---Question 7
select * from crosstab()
CREATE EXTENSION IF NOT EXISTS tablefunc;
----
SELECT * FROM crosstab(
    'select f.factory_label as factory_name, c.manufacture_year as year, sum(m.qty_passed) as Quantity_passed
	from factory_dim f
	join manufacture_fact m ON m.factory_key = f.factory_key
	join calendar_manufacture_dim c on c.manufacture_cal_key = m.manufacture_cal_key
	where c.manufacture_year between ''mY2017'' and ''mY2022'' and c.manufacture_monthofyear = ''mMO02''
	group by f.factory_label, c.manufacture_year
	order by 1',
	'values (''mY2017''), (''mY2018''),(''mY2019''),(''mY2020''),(''mY2021''),(''mY2022'')')
	 AS ct (factory_name character varying(100), mY2017 numeric, mY2018 numeric, 
			mY2019 numeric, mY2020 numeric, mY2021 numeric, mY2022 numeric);
---
-----






