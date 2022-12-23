delete from job_data where ds is null
select * from job_data



/*Number of jobs reviewed: Amount of jobs reviewed over time.
Your task: Calculate the number of jobs reviewed per hour per day for November 2020?*/

select 
cast(sum(jobsReviewed)/cast(24 as decimal)/cast(30 as decimal) as decimal(10,5))  as jobs_reviewed_per_hour
from(
select count(*) as jobsReviewed
from job_data
where ds between '2020-11-01' and '2020-11-30'
and event in('transfer','decision'))x

/*Throughput: It is the no. of events happening per second.
Your task: Let’s say the above metric is called throughput.
Calculate 7 day rolling average of throughput? For throughput, do you prefer daily metric or 7-day rolling and why?*/

select ds,throughput,avg(throughput) over(order by ds rows between 6 preceding  and current row) as rolling_average from(
select ds,
cast(count(*)/cast(24 as decimal)/cast(30 as decimal) as decimal(10,5))  as throughput
from job_data
where event in('transfer','decision')
group by ds)x

/*Percentage share of each language: Share of each language for different contents.
Your task: Calculate the percentage share of each language in the last 30 days?*/


select language,count(*) as lang_cnt,
cast((count(*)/cast((select count(*) from job_data) as decimal) *100) as decimal(10,2)) as percentage_share,
(select count(*) from job_data) as total_lang_cnt
from job_data
group by language

/*Duplicate rows: Rows that have the same value present in them.
Your task: Let’s say you see some duplicate rows in the data. How will you display duplicates from the table?*/

select * from(
select *,
ROW_NUMBER() over (partition by job_id order by job_id) as rn
from job_data)x
where x.rn>1



select * from [Table-1 users]
select * from [Table-2 events] 
select * from [Table-3 email_events]

/*User Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service.
Your task: Calculate the weekly user engagement?*/

select DATEPART(year,created_at)as year,DATEPART(week,created_at)as week_no,count( distinct user_id) as weekly_active_users
from [Table-1 users]
where state='active'
group by DATEPART(year,created_at),DATEPART(week,created_at)


/*User Growth: Amount of users growing over time for a product.
Your task: Calculate the user growth for product?*/

select DATEADD(MONTH,DATEDIFF(month,0,occurred_at),0) as signupmonth,
count(distinct user_id) as num_users
from [Table-2 events]
where event_type='signup_flow'
group by DATEADD(MONTH,DATEDIFF(month,0,occurred_at),0) 

/*Weekly Retention: Users getting retained weekly after signing-up for a product.
Your task: Calculate the weekly retention of users-sign up cohort?*/


select DATEPART(year,occurred_at)as year,DATEPART(week,occurred_at)as week_no,count( distinct user_id) as weekly_active_users
from [Table-2 events]
where event_type='signup_flow'
group by DATEPART(year,occurred_at),DATEPART(week,occurred_at)

/*Weekly Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service weekly.
Your task: Calculate the weekly engagement per device?*/

select device,
datepart(week,occurred_at) as week,count(user_id) as Weekly_users
from [Table-2 events]
where event_type='engagement'
group by device,
datepart(week,occurred_at) 

/*Email Engagement: Users engaging with the email service.
Your task: Calculate the email engagement metrics?*/

select action,count(*) as users_engaging
from [Table-3 email_events]
group by action



