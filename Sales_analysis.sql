Create database DataAnalytics


select * from INFORMATION_SCHEMA.TABLES

select * from INFORMATION_SCHEMA.columns
where TABLE_NAME = 'dim_customers'


select product_name,category,product_line from dim_products

select  min(order_date) as first_order,max(order_date) as last_order,
datediff(year,min(order_date),max(order_date)),
datediff(month,min(order_date),max(order_date))
from fact_sales    

select min(birthdate) as oldest_mf, max(birthdate),
datediff(year,min(birthdate),getdate()) as oldest_mf ,
datediff(year,max(birthdate),getdate()) as youngest_mf from dim_customers

select * from fact_sales 
select * from dim_products
select * from dim_customers


--  Most expensive products
select price,category,subcategory,product_name from dim_products
join fact_sales on dim_products.product_key=fact_sales.product_key
where price = (select max(price) from fact_sales);

--  Cheapest products
select price,category,subcategory,product_name from dim_products
join fact_sales on dim_products.product_key=fact_sales.product_key
where price = (select min(price) from fact_sales);


-- 1. Sales performace (How is the buisness performing) ?

select sum(sales_amount) as total_revenue from fact_sales 

select count(distinct order_number) as total_number_of_orders from fact_sales 

select count(customer_key) as number_of_customers from dim_customers

select avg(sales_amount) as average_order_value from fact_sales 

select sum(quantity) from fact_sales


-- Products that earned the most
select top 10 product_name,category,subcategory,sum(sales_amount)as total_revenue from fact_sales f 
join dim_products p on p.product_key=f.product_key group by p.product_name,p.category,p.subcategory order by total_revenue desc
-- Products that sold the most 
select top 10 product_name,category,price,sales_amount,sum(quantity) total_units from fact_sales
join dim_products on fact_sales.product_key=dim_products.product_key
group by product_name,category,price,sales_amount
order by total_units desc

-- Categories that earned the most
select sum(sales_amount)as total_sales,category,subcategory from fact_sales 
join dim_products on dim_products.product_key=fact_sales.product_key
group by category,subcategory order by total_sales desc

-- Revenue of bikes 

select sum(sales_amount) as total_sales from fact_sales 
join dim_products on dim_products.product_key=fact_sales.product_key
where category = 'Bikes' 

select subcategory,sum(sales_amount) as total_sales from fact_sales 
join dim_products on dim_products.product_key=fact_sales.product_key
where category = 'Bikes' 
group by subcategory
order by total_sales desc

-- Revenue of non bikes products
select sum(sales_amount) as total_sales from fact_sales 
join dim_products on dim_products.product_key=fact_sales.product_key
where category <> 'Bikes' 

select subcategory,sum(sales_amount) as total_sales from fact_sales 
join dim_products on dim_products.product_key=fact_sales.product_key
where category <> 'Bikes' 
group by subcategory
order by total_sales desc

-- Products that has been ordered the most 
select top 10 product_name,category,price,sales_amount,count(distinct order_number) number_of_orders from fact_sales
join dim_products on fact_sales.product_key=dim_products.product_key
group by product_name,category,price,sales_amount    
order by number_of_orders desc

-- Categories that sold the most
select top 10 sum(quantity)as quantity_sold,category,subcategory from fact_sales 
join dim_products on dim_products.product_key=fact_sales.product_key
group by category,subcategory order by quantity_sold desc



-- Most quantity purchased by order 
select order_number,order_date,first_name,last_name,sum(quantity) as units_ordered
from fact_sales s join dim_customers c on s.customer_key=c.customer_key
group by order_number,order_date,first_name,last_name
order by units_ordered desc


-- Products that generate the most profit 
select 
top 20
product_name,
sum(cost*quantity) as total_cost,
sum(sales_amount) as total_sales,
SUM(sales_amount - cost * quantity) AS profit 
from fact_sales f
join dim_products p on f.product_key=p.product_key
group by product_name
order by profit desc  




select top 10 sum(quantity)as quantity_sold,category,subcategory from fact_sales 
join dim_products on dim_products.product_key=fact_sales.product_key
group by category,subcategory order by quantity_sold desc


-- Dates with the most orders 

select 
 YEAR(order_date) AS year,
 MONTH(order_date) AS month,
count(distinct order_number) number_of_orders
from fact_sales
group by YEAR(order_date), MONTH(order_date)
order by number_of_orders desc

-- Most ordered product for each date 

with products_number_of_orders_per_date as
(
select YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    product_name,
    count(distinct order_number) as number_of_orders from dim_products p 
join fact_sales f on p.product_key=f.product_key
group by YEAR(order_date),MONTH(order_date),product_name
)
select year,month,
product_name,
number_of_orders 
from (
select *,row_number() over ( partition by year,month order by number_of_orders desc)
 as rn from products_number_of_orders_per_date
) x
where rn = 1 
order by year,month asc ;


-- Years with the most revenue
select 
  YEAR(order_date) AS year,
sum(sales_amount) total_sales
from fact_sales
group by YEAR(order_date) 
order by total_sales desc
-- months with the most revenue
select 
  MONTH(order_date) AS month,
sum(sales_amount) total_sales
from fact_sales
group by MONTH(order_date) 
order by total_sales desc
--months with the most orders
select 
  MONTH(order_date) AS month,
count(distinct order_number) total_orders
from fact_sales
group by MONTH(order_date) 
order by total_orders desc

-- Customer Analysis 

-- Customers who ordered the most
select  c.customer_key,c.first_name,c.last_name ,c.country,count(distinct order_number) as number_of_orders
 from dim_customers c join fact_sales f on f.customer_key =c.customer_key
 group by c.customer_key,c.first_name,c.last_name ,c.country
order by number_of_orders desc  

-- Customers who spent the most

select distinct c.customer_key,c.first_name,c.last_name ,c.country,sum(sales_amount) as total_spent
 from dim_customers c join fact_sales f on f.customer_key =c.customer_key
 group by c.customer_key,c.first_name,c.last_name ,c.country
order by total_spent desc  
-- Most ordered product and expensive product for each customer
with customer_behav
as
(
select distinct c.customer_key,c.first_name,c.last_name ,c.country,product_name,
sum(sales_amount) as total_spent_on_product,count(product_name) as number_of_orders
 from dim_customers c join fact_sales f on f.customer_key =c.customer_key 
 join dim_products p on p.product_key =f.product_key 
 group by c.customer_key,c.first_name,c.last_name ,c.country,product_name
 )
select customer_key,first_name,last_name ,country,product_name 
from
(select *,row_number() over(partition by customer_key order by number_of_orders desc) as rn
from customer_behav
)x
where rn=1



-- Average spent by customer 
select  c.customer_key,first_name,last_name,avg(sales_amount) average_spent from dim_customers c
join fact_sales f on c.customer_key=f.customer_key group by c.customer_key,c.first_name,c.last_name
order by average_spent desc

-- Average spent by customer per order 

with total_spent_by_order as 
(
select c.customer_key,f.order_number,sum(sales_amount) total_spent from fact_sales f
join dim_customers c on c.customer_key=f.customer_key group by c.customer_key,order_number
)
select c.customer_key,c.first_name,c.last_name,avg(total_spent) average_spent_by_order 
from total_spent_by_order o join dim_customers c  on c.customer_key=o.customer_key
group by c.customer_key,c.first_name,c.last_name
order by average_spent_by_order desc

-- Most spending countries 
select country,sum(sales_amount) as total_sales from dim_customers c
join fact_sales f on f.customer_key=c.customer_key
group by country
order by total_sales desc

--Countries with the most orders
select country,count(distinct order_number) as total_orders from dim_customers c
join fact_sales f on c.customer_key=f.customer_key
group by country
order by total_orders desc

-- Number of customers per country 
select country,count(distinct f.customer_key) as number_of_customers from dim_customers c 
 join fact_sales f on f.customer_key =c.customer_key 
 group by country
 order by number_of_customers desc

 -- Most ordered product by country 
 with number_products_per_country as (
 select country 
 ,product_name ,
 count( distinct order_number) as number_of_orders
 from dim_customers c 
 join fact_sales f on c.customer_key=f.customer_key 
 join dim_products p on p.product_key =f.product_key
 group by country,product_name
 order by number_of_orders desc
 )

 select country,
 product_name,
 number_of_orders
 from (
 select *, row_number() over (partition by country order by number_of_products desc )as rn
 from number_products_per_country
 )x
 where rn between 1 and 5

-- Demography of customers that ordered the most 
select datediff(year,birthdate,getdate()) as age,count(distinct(order_number)) as number_of_orders 
from dim_customers c join fact_sales f on f.customer_key =c.customer_key
group by datediff(year,birthdate,getdate())
order by number_of_orders desc


-- Customers who come back 15 dayrs or less after their first purchase 
with orders as 
(select distinct c.customer_key,first_name,last_name,cast(order_date as date) as order_date from dim_customers c 
join fact_sales f on c.customer_key=f.customer_key )

,next_order as 
(select customer_key,first_name,last_name,order_date,lead(order_date)
over(partition by customer_key order by order_date)as next_order_date from orders )

select distinct customer_key,
first_name,
last_name,
order_date,
next_order_date
from next_order where datediff(d,order_date,next_order_date) between 1 and 15

-- Customers who made one order and never came back
select c.customer_key,
first_name,
last_name,
count(distinct cast(f.order_date as date)) as total_order_days
from dim_customers c 
join fact_sales f on f.customer_key=c.customer_key
group by c.customer_key,first_name,last_name
having count(distinct cast(f.order_date as date)) = 1

-- how long does it take customers to make another purchase on average ?

with orders as 
(select distinct c.customer_key,first_name,last_name,cast(order_date as date) as order_date from dim_customers c 
join fact_sales f on c.customer_key=f.customer_key )

,next_order as 
(select customer_key,first_name,last_name,order_date,lead(order_date)
over(partition by customer_key order by order_date)as next_order_date from orders )

,customer_avg_gap as (
select customer_key, avg(datediff(d, order_date, next_order_date)) as avg_gap
from next_order
where next_order_date is not null
group by customer_key
)
select avg(avg_gap) as avg_days_between_orders from customer_avg_gap 


-- top 10 spenders
;with top_50_spenders as (
select top 50  c.customer_key,c.first_name,c.last_name ,c.country,sum(sales_amount) as total_spent
 from dim_customers c join fact_sales f on f.customer_key =c.customer_key
 group by c.customer_key,c.first_name,c.last_name ,c.country
order by total_spent desc  
)

-- Revenue from top spenders 
select sum(total_spent) from top_50_spenders 
-- total revenue
select sum(sales_amount) from fact_sales 

--Most ordered prodcut from the most spenging customers
;with customer_product_stats as (
    select 
        c.customer_key,
        c.first_name,
        c.last_name,
        c.country,
        p.product_name,
        count(p.product_name) as times_ordered,
        sum(f.sales_amount) as product_spend,
        max(f.sales_amount) as max_single_sale
    from dim_customers c
    join fact_sales f on f.customer_key = c.customer_key
    join dim_products p on p.product_key = f.product_key
    group by c.customer_key, c.first_name, c.last_name, c.country, p.product_name
),

customer_totals as (
    select customer_key, sum(product_spend) as total_spent
    from customer_product_stats
    group by customer_key
),

ranked as (
    select 
        s.*,
        t.total_spent,
        row_number() over (partition by s.customer_key order by s.times_ordered desc) as rn_most_ordered,
        row_number() over (partition by s.customer_key order by s.max_single_sale desc) as rn_most_expensive
    from customer_product_stats s
    join customer_totals t on t.customer_key = s.customer_key
)

select 
    customer_key, first_name, last_name, country, total_spent,
    max(case when rn_most_ordered = 1 then product_name end) as most_ordered_product,
    max(case when rn_most_ordered = 1 then times_ordered end) as times_ordered,
    max(case when rn_most_ordered = 1 then product_spend end) as product_spend,
    max(case when rn_most_expensive = 1 then product_name end) as most_expensive_product,
    max(case when rn_most_expensive = 1 then max_single_sale end) as max_single_sale,
    max(case when rn_most_expensive = 1 then times_ordered end) as times_ordered
from ranked
group by customer_key, first_name, last_name, country, total_spent
order by total_spent desc


--Most expensive products bought from the most spending customers
with customer_spending as (
 select f.customer_key ,
 first_name,
 last_name,
 product_name ,
 category,
 subcategory,
 sum(sales_amount) as sales_per_product
 from dim_customers c 
 join fact_sales f on c.customer_key=f.customer_key    
 join dim_products p on p.product_key =f.product_key
 group by f.customer_key ,
 first_name,last_name,
 product_name ,
 category,
 subcategory
 )
 ,customer_totals as (
    select customer_key, sum(sales_per_product) as total_spent
    from customer_spending
    group by customer_key
)

 select x.customer_key,
 ct.total_spent,
 x.first_name,
 x.last_name,
 x.product_name,
 x.category,
 x.subcategory,
 x.sales_per_product
 from (
 select cs.customer_key,cs.first_name,cs.last_name,cs.product_name,cs.category,cs.subcategory,cs.sales_per_product, row_number() over (partition by customer_key order by sales_per_product desc )as rn
 from customer_spending cs 
 )x
 join customer_totals ct on x.customer_key=ct.customer_key
 where x.rn between 1 and 5
 order by ct.total_spent desc, x.customer_key, x.rn   


-- Customer segmentation (RFM) 1st Method

;with customer_metrics as (
    select 
        c.customer_key,
        c.first_name,
        c.last_name,
        count(distinct f.order_number) as order_count,
        sum(f.sales_amount) as total_spending,
         datediff(d,max(f.order_date),'2014-01-28') as days_passed
    from dim_customers c
    join fact_sales f on c.customer_key = f.customer_key
    group by c.customer_key, c.first_name, c.last_name
),



medians as (
    select 
        percentile_cont(0.5) within group (order by order_count) 
            over () as median_orders,
        percentile_cont(0.5) within group (order by total_spending) 
            over () as median_spending,
        percentile_cont(0.5) within group (order by days_passed) 
            over () as median_days_passed

    from customer_metrics
)
select distinct
    cm.customer_key,
    cm.first_name,
    cm.last_name,
    cm.order_count,
    cm.total_spending,
    cm.days_passed,
    case when cm.days_passed <=m.median_days_passed  then 'Recent' else 'Lapsed' end as recency_segment,
    case when cm.order_count >= m.median_orders then 'High Frequency' else 'Low Frequency' end as freq_segment,
    case when cm.total_spending >= m.median_spending then 'High Spending' else 'Low Spending' end as spend_segment
from customer_metrics cm
cross join medians m
order by cm.total_spending desc



--Customer segmentation (RFM) 2st Method
;with snapshot as (
    select max(order_date) as snapshot_date from fact_sales
),

customer_metrics as (
    select 
        c.customer_key,
        c.first_name,
        c.last_name,
        count(distinct f.order_number) as order_count,
        sum(f.sales_amount) as total_spending,
        max(f.order_date) as last_order_date
    from dim_customers c
    join fact_sales f on c.customer_key = f.customer_key
    group by c.customer_key, c.first_name, c.last_name
),

with_recency as (
    select cm.*, datediff(day, cm.last_order_date, s.snapshot_date) as recency_days
    from customer_metrics cm
    cross join snapshot s
),

ranked as (
    select *,
        ntile(2) over (order by recency_days asc) as recency_tile,   -- fewer days = better, so asc
        ntile(2) over (order by order_count desc) as freq_tile,       -- more orders = better, so desc
        ntile(2) over (order by total_spending desc) as spend_tile
    from with_recency
)

select 
    customer_key, first_name, last_name,
    order_count, total_spending, recency_days,
    case when recency_tile = 1 then 'Recent' else 'Lapsed' end as recency_segment,
    case when freq_tile = 1 then 'High Frequency' else 'Low Frequency' end as freq_segment,
    case when spend_tile = 1 then 'High Spending' else 'Low Spending' end as spend_segment
from ranked
order by total_spending desc


with yearly_sales as (
    select 
        year(order_date) as order_year,
        sum(sales_amount) as total_sales
    from fact_sales
    where year(order_date) is not null
    group by year(order_date)
     
)

select 
    order_year,
    total_sales,
    lag(total_sales) over (order by order_year) as previous_year_sales,
    total_sales - lag(total_sales) over (order by order_year) as absolute_growth,
    round(
        100.0 * (total_sales - lag(total_sales) over (order by order_year))
        / nullif(lag(total_sales) over (order by order_year), 0),
        2
    ) as yoy_growth_pct
from yearly_sales
order by order_year

--DAX
-- percentage of customers who made one order and who made more than one 

-- Top 10 customers → % revenue 
--Top 10% customers → % revenue
-- Top 20 products → % revenue