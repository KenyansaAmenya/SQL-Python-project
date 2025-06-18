# SQL-Python-project
# walmart Data analysis using SQL & Python

### Project overview
---
This is a data analysis project in where the solutions are designed to extract critical business insights from Walmart sales data. I utilized Python for data processing and analysis, SQL for advanced querying, and structured problem-solving techniques to solve key business questions. This project helped me develop skills in data manipulation, SQL querying, and data pipeline creation.

---

## Project Steps

### 1. Set Up the Environment
   - **Tools Used**: Visual Studio Code (VS Code), Python,  PostgreSQL thro(Dbeaver or pgadmin 4). 
   - **Goal**: Create a structured workspace within VS Code and organize project folders for smooth development and data handling.

### 2. Setting Up Kaggle API
   - **API Setup**: I Obtained my Kaggle API token from [Kaggle](https://www.kaggle.com/) by navigating to my profile settings and downloaded the JSON file.
   - **Configuring Kaggle**: 
      - By Placing the downloaded `kaggle.json` file in my local `.kaggle` folder.
      - Then used the command `kaggle datasets download -d <dataset-path>` to pull datasets directly into my project.

### 3. Downloading Walmart Sales Data
   - **Data Source**: Using the Kaggle API to download the Walmart sales datasets from Kaggle.
   - **Dataset Link**: [Walmart Sales Dataset](https://www.kaggle.com/najir0123/walmart-10k-sales-datasets)
   - **Storage**: Saved the data in the `data/` folder for easy reference and access.

### 4. Installing Required Libraries and Load Data
   - **Libraries**: Install necessary Python libraries using:

     ```bash
     pip install pandas numpy sqlalchemy  psycopg2
     ```
   - **Loading Data**: Read the data into a Pandas DataFrame for initial analysis and transformations.

### 5. Explore the Data
   - **Goal**: I Conducted an initial data exploration to understand data distribution, check column names, types, and identify potential issues.
   - **Analysis**: In this I used functions like `.info()`, `.describe()`, and `.head()` to get a quick overview of the data structure and statistics.

### 6. Data Cleaning
   - **Remove Duplicates**: Identify and remove duplicate entries to avoid skewed results.
   ``` python
   df.duplicated().sum() # to identify duplicates

   df.drop_duplicates(inplace=True) # to drop duplicates
   ```
   - **Handle Missing Values**: Drop rows or columns with missing values if they are insignificant; fill values where essential.

   ```python
   df.isnull().sum() # to check nulls
   df.dropna(inplace=True) # to drop nulls
   ```
   - **Fix Data Types**: Ensure all columns have consistent data types (e.g., dates as `datetime`, prices as `float`).

   ```python
   # converting column data type  by removing the $ sign then converting
   df['unit_price'] = df['unit_price'].str.replace('$', '').astype(float)

   df.info() # to check if the data type has changed
   ```

   - **Currency Formatting**: Use `.replace()` to handle and format currency values for analysis.
   check the above
   - **Validation**: Check for any remaining inconsistencies and verify the cleaned data.

### 7. Feature Engineering
   - **Create New Columns**: Calculate the `Total Amount` for each transaction by multiplying `unit_price` by `quantity` and adding this as a new column.
   ```python 
   # create a column
   df['total'] = df['unit_price'] * df['quantity']
     df.head()
   ```
   - **Enhance Dataset**: Adding this calculated field will streamline further SQL analysis and aggregation tasks.

### 8. Load Data into PostgreSQL
   - **Set Up Connections**: Connect to MySQL and PostgreSQL using `sqlalchemy` and load the cleaned data into each database.
   ``` python
   from sqlalchemy import create_engine, psycopg2

        # connecting to the postgreSQL database psql
        
        engine = create_engine ("postgresql://username:pasword@localhost:port/dbname")

        try: 
            engine_psql
            print("Connection Succeded to PSQL")
        except: 
            print("Unable to connect")

   ```
   - **Table Creation**: Setting up tables in PostgreSQL using Python SQLAlchemy to automate table creation and data insertion.
   ```python
   df.to_sql(name='walmart', con=engine_psql, if_exists='append', index=False)
   ```
   - **Verification**: Run initial SQL queries to confirm that the data has been loaded accurately.
   ``` sql
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
   ```

### 9. SQL Analysis: Complex Queries and Business Problem Solving
   - **Business Problem-Solving**: I wrote and executed complex SQL queries to answer critical business questions, such as:
     - Revenue trends across branches and categories.
     - Identifying best-selling product categories.
     - Sales performance by time, city, and payment method.
     - Analyzing peak sales periods and customer buying patterns.
     - Profit margin analysis by branch and category.
```SQL
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
```

### 10. Project Publishing and Documentation
   - **Project Publishing**: After finishing I Published the completed project on GitHub with the following files:
     - The `README.md` file (this document).
     - Jupyter Notebooks (if applicable).
     - SQL query scripts.
     - Data files dowloaded from Kaggle api.

     **Great thanks to Zero analyst the project**