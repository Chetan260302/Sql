use gdb023;
select * from dim_customer;
select * from dim_product;
select * from fact_gross_price;
select * from fact_manufacturing_cost;
select * from fact_pre_invoice_deductions;
select * from fact_sales_monthly;

/* I was Using older versions of mysql therefore I have solved all the queries without using With Clause and Window Functions*/

CREATE INDEX idx_fact_sales_monthly_product_code ON fact_sales_monthly (product_code);
CREATE INDEX idx_fact_gross_price_product_code ON fact_gross_price (product_code);

/*1 . Provide the list of markets in which customer "Atliq Exclusive" operates its
business in the APAC region.*/
select distinct market
from dim_customer 
where customer ="Atliq Exclusive" and region="APAC";

/*2. What is the percentage of unique product increase in 2021 vs. 2020? */
select count(distinct case when fiscal_year=2020 then product_code end) 
as unique_products_2020,
count(distinct case when fiscal_year=2021 then product_code end) as unique_products_2021,
round(((count(distinct case when fiscal_year=2021 then product_code end)-
count(distinct case when fiscal_year=2020 then product_code end))/
count(distinct case when fiscal_year=2020 then product_code end))*100,2) 
as percentage_chg
from fact_sales_monthly;

/*3 Provide a report with all the unique product counts for each segment and
sort them in descending order of product counts*/
select segment,count(distinct product_code) as product_count
from dim_product
group by segment
order by product_count desc;

/*4. Follow-up: Which segment had the most increase in unique products in
2021 vs 2020*/
select segment,count(distinct case when fiscal_year=2020 then dp.product_code end) 
as unique_products_2020,
count(distinct case when fiscal_year=2021 then dp.product_code end) as unique_products_2021,
(count(distinct case when fiscal_year=2021 then dp.product_code end)-
count(distinct case when fiscal_year=2020 then dp.product_code end)) as difference
from fact_sales_monthly fsm
inner join dim_product dp on fsm.product_code=dp.product_code
group by segment;

/*5 Get the products that have the highest and lowest manufacturing costs.*/
(select fmc.product_code,dp.product,manufacturing_cost
from fact_manufacturing_cost fmc
join dim_product dp on fmc.product_code=dp.product_code
order by manufacturing_cost desc limit 1)
union
(select fmc.product_code,dp.product,manufacturing_cost 
from fact_manufacturing_cost fmc
join dim_product dp on fmc.product_code=dp.product_code
order by manufacturing_cost asc limit 1);

/*6 Generate a report which contains the top 5 customers who received an
average high pre_invoice_discount_pct for the fiscal year 2021 and in the
Indian market.*/
select dc.customer_code,dc.customer,avg(pre_invoice_discount_pct) as average_discount_prctg
from fact_pre_invoice_deductions fd
join dim_customer dc on fd.customer_code=dc.customer_code
where fd.fiscal_year=2021
group by dc.customer
order by average_discount_prctg desc
limit 5;

/*7 Get the complete report of the Gross sales amount for the customer “Atliq
Exclusive” for each month. This analysis helps to get an idea of low and
high-performing months and take strategic decisions.
*/
select extract(month from date) as month,a.fiscal_year as year,
round(sum(gross_price*a.sold_quantity),2) as Gross_sales_Amount
from fact_sales_monthly a
join fact_gross_price b on a.product_code=b.product_code
join dim_customer c on a.customer_code=c.customer_code
where c.customer="Atliq Exclusive"
group by extract(month from date),a.fiscal_year;


/*8 In which quarter of 2020, got the maximum total_sold_quantity?
*/
select 
case when date between '2019-09-01' and '2019-11-31' then '1' 
when date between '2019-12-01' and '2020-02-31' then '2' 
when date between '2020-03-01' and '2020-5-31' then '3'
when date between '2020-06-01' and '2020-8-31' then '4' end
 as  Quarter,
Sum(sold_Quantity) as total_sold_quantity
from fact_sales_monthly 
where fiscal_year=2020
group by quarter;


/*9 Which channel helped to bring more gross sales in the fiscal year 2021
and the percentage of contribution? */

select dc.channel,
concat(round(sum(gross_price*sold_quantity/1000000),2),"M") as gross_sales_mln,
(SUM(fgp.gross_price * fsm.sold_quantity) / (SELECT SUM(fgp.gross_price * fsm.sold_quantity) 
FROM fact_gross_price fgp 
JOIN fact_sales_monthly fsm 
ON fgp.product_code = fsm.product_code 
WHERE fsm.fiscal_year = 2021)) * 100 AS percentage
from dim_customer dc
join fact_sales_monthly fsm on dc.customer_code=fsm.customer_code
join fact_gross_price fgp on fsm.product_code=fgp.product_code
where fsm.fiscal_year=2021
group by dc.channel;


/*10 Get the Top 3 products in each division that have a high
total_sold_quantity in the fiscal_year 2021? */

SELECT 
  dp.division,
  fsm.product_code,
  dp.product,
  SUM(fsm.sold_quantity) AS total_sold_quantity,
  (
    SELECT COUNT(DISTINCT sold_qty_sum)
    FROM (
      SELECT 
        product_code, 
        SUM(sold_quantity) AS sold_qty_sum
      FROM fact_sales_monthly
      WHERE fiscal_year = 2021
      GROUP BY product_code
    ) t2
    WHERE t2.sold_qty_sum > SUM(fsm.sold_quantity) AND t2.product_code IN (
      SELECT product_code 
      FROM dim_product 
      WHERE division = dp.division
    )
  ) +1 AS rank_order
FROM 
  dim_product dp
  INNER JOIN fact_sales_monthly fsm ON dp.product_code = fsm.product_code
WHERE 
  fsm.fiscal_year = 2021
GROUP BY 
  dp.division, 
  fsm.product_code, 
  dp.product
HAVING 
  SUM(fsm.sold_quantity) > 0
  AND (
    SELECT COUNT(DISTINCT sold_qty_sum)
    FROM (
      SELECT 
        product_code, 
        SUM(sold_quantity) AS sold_qty_sum
      FROM fact_sales_monthly
      WHERE fiscal_year = 2021
      GROUP BY product_code
    ) t2
    WHERE t2.sold_qty_sum > SUM(fsm.sold_quantity) AND t2.product_code IN (
      SELECT product_code 
      FROM dim_product 
      WHERE division = dp.division
    )
  ) < 3
ORDER BY 
  dp.division, 
  total_sold_quantity DESC;

  

