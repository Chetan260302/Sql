use ig_clone;
select * from photo_tags;
select * from comments;
select * from follows;
select * from likes;
select * from photos;
select * from tags;
select * from users order by created_at;

/*Rewarding Most Loyal Users: People who have been using the platform for the longest time.
Your Task: Find the 5 oldest users of the Instagram from the database provided*/

select * 
from users 
order by created_at  limit 5;

/*2.Remind Inactive Users to Start Posting: By sending them promotional emails to post their 1st photo.
Your Task: Find the users who have never posted a single photo on Instagram*/

select u.*
from users u
left join photos p on u.id=p.user_id
where p.user_id is null;

/*3.Declaring Contest Winner: The team started a contest and the user who gets the most likes on a single photo will win the contest now they wish to declare the winner.
Your Task: Identify the winner of the contest and provide their details to the team*/

select  u.username,u.id,l.photo_id,count(l.user_id)
from users u
join photos p on u.id=p.user_id
join likes l on p.id=l.photo_id
group by u.username,u.id,l.photo_id
order by count(l.user_id) desc limit 1 ;

/*4. Hashtag Researching: A partner brand wants to know, 
which hashtags to use in the post to reach the most people on the platform
Your Task: Identify and suggest the top 5 most commonly used hashtags on the platform*/

select t.id,t.tag_name,count(pt.tag_id)
from photo_tags pt 
join tags t on pt.tag_id=t.id
group by t.id,t.tag_name
order by count(pt.tag_id) desc limit 5;

/* Launch AD Campaign: The team wants to know, which day would be the best day to launch ADs.
Your Task: What day of the week do most users register on? 
Provide insights on when to schedule an ad campaign*/

select dayname(created_at),count(username) as totalregistered
 from users 
 group by dayname(created_at)
 order by  count(username) desc limit 2;
 
 /*User Engagement: Are users still as active and post on Instagram or they are making fewer posts
Your Task: Provide how many times does average user posts on Instagram. 
Also, provide the total number of photos on Instagram/total number of users*/
 
select sum(totalPhotosPostedByEach)/count(totalPhotosPostedByEach) as avgPhotosPosted from(
select user_id,count(id) as totalPhotosPostedByEach
from photos
group by user_id)x;

 SELECT (SELECT COUNT(*)FROM photos)/(SELECT COUNT(*) FROM users);

/*Bots & Fake Accounts: The investors want to know if the platform is crowded with fake and dummy accounts
Your Task: Provide data on users (bots) who have liked every single photo on the site 
(since any normal user would not be able to do this).*/

select u.*,count(u.id) as total_likes
from users u
join likes l on u.id=l.user_id
group by u.id
having count(u.id) =(select count(*) from photos);









