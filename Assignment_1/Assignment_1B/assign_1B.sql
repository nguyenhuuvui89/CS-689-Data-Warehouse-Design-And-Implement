select * from states;
select * from employment_categories;
select * from education_codes;
select * from person_economic_info

-- Question 1
CREATE VIEW additional_person_info AS
SELECT states.us_state_terr, employment_categories.category_description, 
education_codes.education_level_achieved, person_economic_info.*
FROM person_economic_info
JOIN states ON states.numeric_id = person_economic_info.address_state
JOIN employment_categories ON employment_categories.employment_category = person_economic_info.employment_category
JOIN education_codes ON education_codes.code = person_economic_info.education;
----
SELECT * FROM additional_person_info;

-- Question 2.

--Method_1:
SELECT us_state_terr as state_name, count (own_computer) as Num_own_computers
FROM additional_person_info
WHERE own_computer = 1
GROUP BY us_state_terr;

----Method_2:
SELECT us_state_terr as state_name, sum(own_computer) as Num_own_computers
FROM additional_person_info
GROUP BY us_state_terr
HAVING sum(own_computer) > 0;

-- Question 3.

SELECT us_state_terr as state_name, sum(own_computer) as total_own_computers
FROM additional_person_info
GROUP BY us_state_terr
HAVING sum(own_computer) = 0;

--Question 4.

SELECT us_state_terr as state_name, education_level_achieved as Education_Level,
count(*) as Numbers_respondents, sum(own_computer) as Total_own_computers, 
avg(income) as  Avg_income
FROM additional_person_info 
GROUP BY CUBE(us_state_terr,education_level_achieved)
ORDER BY us_state_terr;

-----Question 5.

SELECT us_state_terr as state_name, avg(income) as Avg_income,
Dense_rank() OVER (ORDER BY avg(income) DESC) as DenseRankState
FROM additional_person_info 
GROUP BY us_state_terr
ORDER BY DenseRankState;

---Question 6.

SELECT A.*, 
Round(((cast(A.internet_user as decimal)/cast(nullif(A.num_own_computer,0) as decimal))*100),2) as percent_internet_user 
FROM
	(SELECT us_state_terr as state_name, count(*) as num_people_reported, 
	count(case when internet <> 0 then 1 ELSE NULL END) as internet_user,
	count(case when own_computer = 1 then 1 ELSE NULL END) as num_own_computer, 
	cast(max(income) as money) as highest_income, 
	cast(avg(income) as money) as average_income
	from additional_person_info
	group by us_state_terr
	order by us_state_terr) A;

---Question 7

SELECT A.*, 
Round(((cast(A.internet_user as decimal)/cast(nullif(A.num_own_computer,0) as decimal))*100),2) as percent_internet_user 
FROM
	(SELECT us_state_terr as state_name, education_level_achieved as education_level,
	count(*) as num_people_reported, 
	count(case when internet <> 0 then 1 ELSE NULL END) as internet_user,
	count(case when own_computer = 1 then 1 ELSE NULL END) as num_own_computer, 
	cast(max(income) as money) as highest_income, 
	cast(avg(income) as money) as average_income
	from additional_person_info
	group by (us_state_terr, education_level_achieved)
	order by us_state_terr) A;
	
-----Question 8

SELECT address_state, us_state_terr as state_name, cast(avg(income) as money) as Avg_income,
cast(lag(avg(income)) over (order by address_state) as money) as avg_previous_state_income,
case 
	when avg(income) > lag(avg(income)) over(order by address_state) then 'Higher than previous state'
	when avg(income) < lag(avg(income)) over(order by address_state) then 'Lower than previous state'
	when avg(income) = lag(avg(income)) over(order by address_state) then 'Same previous state'
	end avg_income_range, 
cast(lead(avg(income)) over (order by address_state) as money) as avg_next_state_income
FROM additional_person_info 
GROUP BY us_state_terr, address_state

---
