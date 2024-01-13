# Q.1 What is the total amount each customer spent on Zomato?
select s.userid, sum(p.price) total_amount_spent from sales s inner join product p on s.product_id = p.product_id 
group by s.userid; 

# Q.2 How many days has each customer visited Zomato?
select userid, count(distinct created_date) as Distinct_Days from sales group by userid;

# Q.3 What was the first product purchased by each customer?
select * from
(select *, rank() over(partition by userid order by created_date asc) as rnk from sales) as a where rnk=1;

# Q.4 What is the most purchased item on the menu and how many times was it purchased by all customers?
select userid, count(product_id) as cnt from sales where product_id = 
(select product_id from sales group by product_id order by count(product_id) desc limit 1)
group by userid;

# Q. 5 Which item was the most popular for each customer?
select * from
(select *, rank() over(partition by userid order by cnt desc) as rnk from 
(select userid, product_id, count(product_id) as cnt from sales group by userid, product_id) a)b
where rnk = 1; 

#Q.6 Which item was purchased first by the customer after they became a member?

select * from
(select c.*, rank() over(partition by userid order by created_date) as rnk from
(select s.userid, s.created_date, s.product_id, gold_signup_date from sales s inner join goldusers_signup g on s.userid = g.userid and created_date>=gold_signup_date) c) d where rnk = 1;

#Q.7 Which item was purchased just before the customer became a gold member?
select * from
(select c.*, rank() over(partition by userid order by created_date desc) as rnk from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date from sales s 
inner join goldusers_signup g on s.userid = g.userid and created_date <=gold_signup_date)c)d where rnk = 1;

#Q.8 What is the total orders and amount spent for each member before they became a gold member?
select userid, count(created_date) as Order_purchased, sum(price) as Total_Amount_Spent from
(select c.*, d.price from
(select s.userid,s.created_date, s.product_id, g.gold_signup_date from sales s inner join goldusers_signup g on s.userid = g.userid and created_date<=gold_signup_date)c 
inner join product d on c.product_id = d.product_id)e
group by userid;

/* Q.9 If buying each product generates points for eg 5rs=2 zomato point and each product has different purchasing points for eg for p1 5rs=1
zomato point, for p2 10rs= 5 zomato point and p3 5rs= 1 zomato point, calculate points collected by each customers and for which product most 
points have been given till now.*/

select f.userid, round(sum(earned_points),1)*2.5 as Total_Money_Earned from
(select e.*,amt/points as Earned_Points from
(select d.*,
case when product_id =1 then 5 when product_id =2 then 2 when product_id = 3 then 5 else 0 end as points from
(select c.userid, c.product_id, sum(price) amt from
(select s.*, p.price  from sales s inner join product p on s.product_id = p.product_id) c  
group by c.userid, c.product_id) d) e) f group by userid;

select * from
(select *, rank() over(order by Total_Points_Earned desc) as rnk from 
(select product_id, round(sum(earned_points),1) as Total_Points_Earned from
(select e.*,amt/points as Earned_Points from
(select d.*,
case when product_id =1 then 5 when product_id =2 then 2 when product_id = 3 then 5 else 0 end as points from
(select c.userid, c.product_id, sum(price) amt from
(select s.*, p.price  from sales s inner join product p on s.product_id = p.product_id) c  
group by c.userid, c.product_id) d) e) f group by product_id) g) h where rnk =1;

/*Q.10 In the first one year after a customer joins the gold program (including their join date) irrespective of what the
customer has purchased they earn 5 zomato points for every 10 rs spent who earned more 1 or 3 and what was their points
earnings in their first year?*/

# 1 zomato point = Rs 2
select c.*, d.price*0.5 as total_points_earned from 
(select s.userid, s.created_date, product_id, g.gold_signup_date from sales s 
inner join goldusers_signup g on s.userid = g.userid and created_date >= gold_signup_date and created_date<=date_add("2017-04-21", interval 365 day) and date_add("2017-09-22", interval 365 day)) c 
inner join product d on c.product_id = d.product_id; 

# Q.11. Rank all the transaction of the customers?
select *, rank() over(partition by userid order by created_date) as Rnk from sales;

# Q.12 Rank all the transactions for each member whenever they are a zomato gold member for every non gold member transaction mark as na?
select d.*, case when rnk = 0 then 'na' else rnk end as rnk from
(select c.*, case when gold_signup_date is null then 0 else rank() over(partition by userid order by created_date desc) end as rnk from
(select s.*, gold_signup_date from sales s left join goldusers_signup g on s.userid = g.userid and created_date >= gold_signup_date)c)d;

