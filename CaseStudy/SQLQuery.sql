select * from sales
select * from members
select * from menu

--1.What is the total amount each customer spent at the restaurant?

select s.customer_id,sum(m.price) as totalAmount
from sales s 
join menu m on s.product_id=m.product_id
group by customer_id


--2.How many days has each customer visited the restaurant?

select s.customer_id,count(distinct order_date) as totalDaysVisited
from sales s 
join menu m on s.product_id=m.product_id
group by customer_id

--3.What was the first item from the menu purchased by each customer?

select customer_id,order_date,product_name from(
select s.customer_id,s.order_date,m.product_name,dense_rank() over(partition by customer_id order by order_date) as dr
from sales s 
join menu m on s.product_id=m.product_id
group by customer_id ,order_date,product_name)x
where x.dr=1

--4.What is the most purchased item on the menu and how many times was it purchased by all customers?

select top 1 product_id,product_name,mostPurchaseProduct 
from (select  s.product_id,m.product_name,count(m.product_name) as mostPurchaseProduct
from sales s 
join menu m on s.product_id=m.product_id
group by s.product_id,product_name)x
order by mostPurchaseProduct desc

--5.Which item was the most popular for each customer?

with cte as(
select s.customer_id,product_name,count(product_name) as productPurchasedCount,
DENSE_RANK() over (partition by customer_id order by  count(product_name) desc) as dr
from sales s 
join menu m on s.product_id=m.product_id
group by customer_id,product_name
)
select customer_id,product_name,productPurchasedCount
from cte where cte.dr=1

--6.Which item was purchased first by the customer after they became a member?

with cte as(
select s.customer_id,s.order_date,m1.join_date,m.product_name,
DENSE_RANK() over(partition by s.customer_id order by s.order_date) as dr
from sales s
join menu m 
on s.product_id=m.product_id
join members m1 
on 
s.customer_id=m1.customer_id and
s.order_date >= m1.join_date)
select customer_id,order_date,join_date,product_name
from cte where cte.dr=1

--7.Which item was purchased just before the customer became a member?

with cte as(
select s.customer_id,s.order_date,m1.join_date,m.product_name,
DENSE_RANK() over(partition by s.customer_id order by s.order_date) as dr
from sales s
join menu m 
on s.product_id=m.product_id
join members m1 
on 
s.customer_id=m1.customer_id and
s.order_date < m1.join_date)
select customer_id,order_date,join_date,product_name
from cte where cte.dr=1

--8.What is the total items and amount spent for each member before they became a member?

select s.customer_id,count(m.product_name) as total_items,sum(m.price) as total_spent
from sales s
join menu m 
on s.product_id=m.product_id
join members m1 
on s.customer_id=m1.customer_id and
s.order_date < m1.join_date
group by s.customer_id

--9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select s.customer_id,
sum(case when product_name='sushi' then (price*2)*10 else price*10 end) as points
from sales s
join menu m 
on s.product_id=m.product_id
left join members m1 
on s.customer_id=m1.customer_id 
group by s.customer_id

--10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

with cte as 
(select *,EOMONTH('2021-01-31') as end_jan 
from members)
select s.customer_id,sum(case when
s.order_date between m1.join_date and dateadd(day,6,m1.join_date) then 
m.price*2 else m.price end) as points
from sales s
join menu m 
on s.product_id=m.product_id
join cte m1 
on s.customer_id=m1.customer_id 
and dateadd(day,7,s.order_date) between dateadd(day,7,m1.join_date) and m1.end_jan
group by s.customer_id

