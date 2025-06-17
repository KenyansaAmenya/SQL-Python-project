select * from walmart; 

select count(*)  from walmart;

select distinct  payment_method from walmart;

select 
     payment_method,
     count(*)
from walmart
group by payment_method;

select 
count (distinct branch)
from walmart;

select max(quantity) 
from walmart;

select min(quantity) 
from walmart;

-- Business problems

-- Q.1 Find diffrent payment methods  and number of transactions, number of quantiy sold

select 
     payment_method,
     count(*) as no_payments,
     sum(quantity) as no_quantity_sold
from walmart
group by payment_method;

-- Q .2 Identify the highest-rated category in each branch, displaying the branch, category
-- avg rating

select * from walmart; 

select 
branch,
category,
avg(rating) as avg_rating
from walmart 
group by 1, 2
order by 1, 3 desc;

select 
branch,
category,
avg(rating) as avg_rating,
rank() over(partition by branch order by avg(rating) desc) as rank
from walmart 
group by 1, 2;

select *
from 
(select 
branch,
category,
avg(rating) as avg_rating,
rank() over(partition by branch order by avg(rating) desc) as rank
from walmart 
group by 1, 2
)
where rank = 1;


-- Q. 3 Identify the busiest day for each branch based on the number of transactions
-- date type is in text data type lets convert the column to date

select date from walmart;

-- first convert
select 
      date,
      TO_DATE(date, 'DD/MM/YY') as formated_date
from walmart; 

-- then get the day name
select 
      date,
      TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name
from walmart;  

-- then find the branch that has the highest number of sales

select *
from
(select 
      branch,
      TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
      count(*) as no_transactions,
      rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by 1, 2
)
where rank = 1;

--Q. 4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

select 
      payment_method,
      sum(quantity) as no_qty_sold
from walmart
group by payment_method;


--Q. 5 Determine the average, minimum, and maximum rating of category for each city.
--  list the city, average_rating, min_rating, and max_rating.

select 
      city,
      category,
      MIN(rating) as min_rating,
      MAX(rating ) as max_rating,
      AVG(rating) as average_rating
from walmart
group by 1, 2;

-- Q. 6 calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin.#). list category and total_profit, ordered from the highest to the lowest

select 
     category,
     sum(total)
from walmart
group by 1;

-- if we need the profit mulply with margin

select 
     category,
     sum(total * profit_margin) as profit
from walmart
group by 1;

select 
     category,
     sum(total) as total_revenue,
     sum(total * profit_margin) as profit
from walmart
group by 1;

-- Q.7 Determine the most common payment method for each branch. Display branch and the preferred_payment_method


with cte
as
(select 
      branch,
      payment_method,
      count(*) as total_trans,
      rank() over(partition by branch order by COUNT(*) desc) as rank
from walmart
group by 1, 2     
)
select  * 
from cte
where rank = 1;

-- Q.8 categorize sales into 3 groups MORNING, AFTERNOON, EVENING
-- Find out which of the shift and number of invoices

select 
*,
		case 
			when extract (hour from(time::time)) < 12 then 'Morning'
			when extract (hour from(time::time)) between 12 and 17 then 'Afternoon'
			else 'Evening'
		end day_time
from walmart;


select 
        branch,
		case 
			when extract (hour from(time::time)) < 12 then 'Morning'
			when extract (hour from(time::time)) between 12 and 17 then 'Afternoon'
			else 'Evening'
		end day_time,
		count(*)
from walmart
group by 1, 2
order by 1, 3 desc;

-- Q.9 Identify 5 branch with highest decrease ratio in revenue
-- compare to last year * (current year 2023)

-- rdr == last_rev-cr_rev/ls_rev*100

select *,
to_date(date, 'DD/MM/YY') as formated_date
from walmart;

select *,
extract(year from to_date(date, 'DD/MM/YY')) as formated_date
from walmart;


select 
		     branch,
		     SUM(total) as revenue
		     from walmart
		     where extract(year from to_date(date, 'DD/MM/YY')) = 2022
		group by 1;

-- 2022 sales

with revenue_2022
as
(
		select 
		     branch,
		     SUM(total) as revenue
		     from walmart
		     where extract(year from to_date(date, 'DD/MM/YY')) = 2022
		group by 1
),

revenue_2023
as
(
		select 
		     branch,
		     SUM(total) as revenue
		     from walmart
		     where extract(year from to_date(date, 'DD/MM/YY')) = 2023
		group by 1
)

select 
      ls.branch,
      ls.revenue as last_year_revenue,
      cs.revenue as cr_year_revenue
from revenue_2022 as ls
join 
revenue_2023 as cs
on ls.branch = cs.branch
where 
     ls.revenue > cs.revenue;



-- 2022 sales

with revenue_2022
as
(
		select 
		     branch,
		     SUM(total) as revenue
		     from walmart
		     where extract(year from to_date(date, 'DD/MM/YY')) = 2022
		group by 1
),

revenue_2023
as
(
		select 
		     branch,
		     SUM(total) as revenue
		     from walmart
		     where extract(year from to_date(date, 'DD/MM/YY')) = 2023
		group by 1
)

select 
      ls.branch,
      ls.revenue as last_year_revenue,
      cs.revenue as cr_year_revenue,
      ROUND((ls.revenue - cs.revenue)::numeric/
           ls.revenue::numeric * 100, 
           2) as rev_dec_ratio
from revenue_2022 as ls
join 
revenue_2023 as cs
on ls.branch = cs.branch
where 
     ls.revenue > cs.revenue
order by 4 desc
limit 5;
