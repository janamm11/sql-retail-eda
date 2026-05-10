-- uswd sql alchemy to insert data from python

select * from electronics;
describe electronics;

-- cleaning of data
select distinct `sub category` from electronics; # no cleaning needed
-- price column
-- data constists of $ sign and $299.99through-$449.99

select price, replace(replace(price,'$',''),',','') from electronics;
update  electronics
set price=  replace(replace(price,'$',''),',','') ;
-- the , and $ were removed and replaced
set sql_safe_updates= 0;

select price, (substring_index(replace(price,'-',''),'through',1) +
substring_index(replace(price,'-',''),'through',-1))/2 from electronics;

update electronics 
set price=  (substring_index(replace(price,'-',''),'through',1) +
substring_index(replace(price,'-',''),'through',-1))/2 
where price like '%through%';

select * from electronics;

-- discount column

alter table electronics
add column discount_given varchar(3) after discount;


select discount,
   case when discount like '%No Discount%' then 'No'
   else 'Yes'
   end from electronics;

update electronics
set discount_given= case when discount like '%No Discount%' then 'No' else 'Yes' end;

alter table electronics
add column MRP decimal(50,2) after Price ;

select price,Discount,
   case when Discount like '%No Discount%' then price
        when discount like '%After %' then price + regexp_replace(Discount,'[^0-9]','')
        else round(price*1.27,2)
        end 
        from electronics;
        
update electronics
set MRP= case when Discount like '%No Discount%' then price
        when discount like '%After %' then round(price + regexp_replace(Discount,'[^0-9]',''),2)
        else round(price*1.27, 2)
        end ;

select * from electronics;

-- reducing cardinality of discount column on basis of discount type or groups
select distinct discount from electronics;

alter table electronics change column discount discount_type text;

select discount_type,
   case when discount_type like '%No Discount%' then 'No Discount'
        when discount_type like '%Price Valid%' then 'price valid'
        when discount_type like '%After%' then 'Flat Discount Offers'
        else 'Special Discount' end
        from electronics;
        
update electronics
set discount_type= case when discount_type like '%No Discount%' then 'No Discount'
        when discount_type like '%Price Valid%' then 'price valid'
        when discount_type like '%After%' then 'Flat Discount Offers'
        else 'Special Discount' end;
        
-- drop currency column
alter table electronics
drop column Currency;

select * from electronics ;

-- rating ciolumn has Rated 4.8 out of 5 stars based on 125 reviews. kind values and null too
-- extract ratings and count of reviews
alter table electronics 
add column Average_Rating decimal(5,2) after Rating;

-- select rating, regexp_substr(rating, '[0-9]') from electronics; #only 4 is extracted out of 4.8

select rating, regexp_substr(rating, '[0-9]+(\\.[0-9]+)?') from electronics; #useful to extract value after decimal
update electronics
set average_rating = regexp_substr(rating, '[0-9]+(\\.[0-9]+)?');

-- number of reviews
alter table electronics
add column review_count int after rating;

select rating, regexp_substr(rating, '[0-9]+(?=\\s+reviews)') from electronics;

update electronics
set review_count= regexp_substr(rating, '[0-9]+(?=\\s+reviews)');

alter table electronics
drop column rating;
--
select * from electronics;

-- title
select distinct title from electronics; # output- > Duracell Coppertop Alkaline AA Batteries, 40-count (company name ,product

 alter table electronics
 add column Brandname varchar(30) after title;
 
 select title, substring_index(title,' ',1) from electronics; # returns first word ...seems brandname
 
 update electronics
 set Brandname= substring_index(title,' ',1);
 select distinct brandname from electronics;
 
DELETE FROM electronics
WHERE brandname LIKE '$%'
   OR brandname IN ('My', 'MW', 'Handy', 'CHARGE', 'Singing');
   
SET SQL_SAFE_UPDATES = 0;   
   
UPDATE electronics
SET brandname = CASE 
    WHEN brandname IN ('Mac', 'iMac', 'MacBook', 'iPad', 'AirPods', 'Beats', 'Powerbeats', 'HomePod') THEN 'Apple'
    WHEN brandname IN ('Ring', 'Blink') THEN 'Amazon'
    ELSE brandname
  END;
 select distinct brandname from electronics;
 
 -- Check top brands by count
SELECT brandname, COUNT(*) as count
FROM electronics
GROUP BY brandname
ORDER BY count DESC
LIMIT 10;

 select * from electronics order by rand() limit 5 ;
 
 -- UNIVARIATE ANALYSIS (NUMERICAL COLUMN)
 -- PRICE
 -- 1 NULL VALUES
 select count(*) from electronics where price is null;  # 1 
 
 SELECT * FROM electronics WHERE price IS NULL;
 
 --  2 FIND MIN,MAX, AERAGE, STD
 alter table electronics
 modify column price decimal(20,2);
 
 select min(price) as minimum, max(price) as maximum,
 avg(price) as average, std(price) as std
 from electronics;
 
 -- rating
 -- Null percentage for rating
SELECT 
    ROUND(AVG(average_Rating IS NULL) * 100, 2) AS rating_null_percent,
    ROUND(AVG(Review_Count IS NULL) * 100, 2) AS review_null_percent
FROM electronics;
 
 -- percentile
 -- calculating maximum percentile for a value..eahc percentile has different values and i am choosing maximum
 select price,max(percentile) from(
 select price, round(percent_rank() over (order by price),2) as percentile from electronics
 )k group by price;
 
 delimiter //
 create procedure GetpriceBypercentile( in percentilevalue decimal(3,2), out price_limit decimal(10,2))
 begin
 select max(price)
 into price_limit
 from
 (
 select price, round(percent_rank() over (order by price),2) as percentile from electronics
 )k
 where percentile = percentilevalue;
 end //
 delimiter ;
 
call GetpriceBypercentile(0.25, @q1); 
call GetpriceBypercentile(0.52, @q2); 
call GetpriceBypercentile(0.76, @q3); 
select @q1 as 'Quarter1', @q2 as 'Median', @q3 as 'Quarter3';

-- outliers
select * from electronics where price < (@q1 -1.5*(@q3-@q1)) or price> (@q1 + 1.5*(@q3-@q1));
-- every outlier have high values...most be many value are low ...so the chart must be right  skewed(positive skewed)

-- create buckets
select buckets, count(*) from 
(
select price,
case
  when price between 0 and 500 then '0-0.5k'
  when price between 501 and 1500 then '0.5-1k'
  when price between 1501 and 3000 then '1.5-3k'
  when price between 3001 and 6000 then '3-6k'
  else '>6k'
  end as ' buckets'
  from electronics
  )k
  group by buckets;
  
  /* 0-0.5k	266
0.5-1k	249
1.5-3k	100
3-6k	18
>6k	      2   */

-- categorical column
-- 1 null values
select count(*) from electronics where `sub category` is null; -- 0
select `sub category` , count(`sub category`) as counts from electronics group by `sub category`;
select `sub category` , count(`sub category`) as counts from electronics group by `sub category` order by count(`sub category` ) desc limit 5;
/* Laptops & Notebook Computers	134
TVs	100
Home Security Systems & Cameras	62
Desktop Computers & PCs	57
Smart Home & Safety	54 */

-- rating and review
SELECT 
    ROUND(AVG(average_Rating IS NULL) * 100, 2) AS rating_null_percent,
    ROUND(AVG(Review_Count IS NULL) * 100, 2) AS review_null_percent
FROM electronics;  -- 6.30%

-- discount
-- Overall discount vs no discount

SELECT Discount_given,
    COUNT(*) AS count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM electronics) * 100, 2) AS percentage
FROM electronics
GROUP BY Discount_given
ORDER BY count DESC;

SELECT Discount_type,
    COUNT(*) AS count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM electronics) * 100, 2) AS percentage
FROM electronics
GROUP BY Discount_type
ORDER BY count DESC;

-- brandname
-- Total unique brands
SELECT COUNT(DISTINCT brandname) AS total_brands
FROM electronics; -- 80

-- Top brands by product count with avg price
SELECT brandname,
    COUNT(*) AS total_products,
    ROUND(AVG(Price), 2) AS avg_price
FROM electronics
GROUP BY brandname
ORDER BY total_products DESC
LIMIT 10;

-- Most expensive brand (min 10 products)
SELECT 
    brandname,
    COUNT(*) AS total_products,
    ROUND(AVG(Price), 2) AS avg_price
FROM electronics
WHERE brandname IN (
    SELECT brandname 
    FROM electronics 
    GROUP BY brandname 
    HAVING COUNT(*) >= 10
)
GROUP BY brandname
ORDER BY avg_price DESC
LIMIT 5;

-- Most discount offered by brand (min 10 products)
SELECT brandname,
    COUNT(*) AS total_products,
    ROUND(AVG(Discount_given != 'No') * 100, 2) AS discount_percentage
FROM electronics
GROUP BY brandname
HAVING total_products >= 10
ORDER BY discount_percentage DESC
LIMIT 5;

-- Brand selling most subcategories
SELECT brandname,
    COUNT(DISTINCT `Sub Category`) AS total_subcategories,
    GROUP_CONCAT(DISTINCT `Sub Category`) AS subcategories
FROM electronics
GROUP BY brandname
ORDER BY total_subcategories DESC
LIMIT 5;

-- review_count Basic distribution
SELECT 
    MIN(Review_Count) AS minimum,
    MAX(Review_Count) AS maximum,
    ROUND(AVG(Review_Count), 2) AS mean,
    COUNT(*) AS total_products
FROM electronics
WHERE Review_Count IS NOT NULL;
-- 1	6534	482.55	595

-- Product with highest reviews
SELECT Title, brandname, Review_Count
FROM electronics
ORDER BY Review_Count DESC
LIMIT 1;

-- brand with highest reviews in number
SELECT brandname,
    ROUND(AVG(Review_Count), 2) AS avg_reviews,
    SUM(Review_Count) AS total_reviews,
    COUNT(*) AS total_products
FROM electronics
WHERE Review_Count IS NOT NULL
GROUP BY brandname
having COUNT(*)>=10
ORDER BY avg_reviews DESC
LIMIT 10;

-- Review buckets vs rating
SELECT 
    CASE 
        WHEN Review_Count < 500 THEN 'Low (under 500)'
        WHEN Review_Count < 2000 THEN 'Medium (500-2000)'
        ELSE 'High (2000+)'
    END AS review_bucket,
    ROUND(AVG(average_Rating), 2) AS avg_rating,
    COUNT(*) AS total_products
FROM electronics
WHERE Review_Count IS NOT NULL 
AND Average_Rating IS NOT NULL
GROUP BY review_bucket
ORDER BY avg_rating DESC;

/*# review_bucket, avg_rating, total_products
'High (2000+)', '4.51', '37'
'Medium (500-2000)', '4.49', '104'
'Low (under 500)', '4.27', '454'
*/

-- Highest rated brand (min 10 products)
SELECT brandname,
    ROUND(AVG(average_Rating), 2) AS avg_rating,
    COUNT(*) AS total_products
FROM electronics
WHERE Average_Rating IS NOT NULL
GROUP BY brandname
HAVING total_products >= 10
ORDER BY avg_rating DESC
LIMIT 5;


-- num num column

-- Which subcategory is most expensive on average?
SELECT `Sub Category`,
    ROUND(AVG(Price), 2) AS avg_price,
    ROUND(MIN(Price), 2) AS min_price,
    ROUND(MAX(Price), 2) AS max_price
FROM electronics
GROUP BY `Sub Category`
ORDER BY avg_price DESC limit 5;

--  Which subcategory discounts most?
SELECT `Sub Category`,
    ROUND(AVG(Discount_given = 'Yes') * 100, 2) AS discount_percentage
FROM electronics
GROUP BY `Sub Category`
ORDER BY discount_percentage DESC limit 5;

-- Do discounted products get more reviews?
SELECT 
    Discount_given,
    ROUND(AVG(Review_Count), 2) AS avg_reviews,
    ROUND(AVG(average_Rating), 2) AS avg_rating,
    COUNT(*) AS total_products
FROM electronics
WHERE Review_Count IS NOT NULL
AND average_Rating IS NOT NULL
GROUP BY Discount_given;

-- Which subcategory gives best value? (high rating + low price)
SELECT 
    `Sub Category`,
    ROUND(AVG(Price), 2) AS avg_price,
    ROUND(AVG(average_Rating), 2) AS avg_rating,
    COUNT(*) AS total_products
FROM electronics
WHERE average_Rating IS NOT NULL
GROUP BY `Sub Category`
ORDER BY avg_price ASC,avg_rating DESC limit 5;

--  Which brand dominates premium segment? (price above 1500)
SELECT brandname,
    COUNT(*) AS premium_products,
    ROUND(AVG(Price), 2) AS avg_price,
    ROUND(AVG(average_Rating), 2) AS avg_rating
FROM electronics
WHERE Price > 1500
AND Average_Rating IS NOT NULL
GROUP BY brandname
HAVING premium_products >= 3
ORDER BY premium_products DESC
LIMIT 5;

-- Which brand has most consistent rating across products?
SELECT brandname,
    ROUND(AVG(average_Rating), 2) AS avg_rating,
    ROUND(STD(average_Rating), 2) AS rating_std,
    COUNT(*) AS total_products
FROM electronics
WHERE average_Rating IS NOT NULL
GROUP BY brandname
HAVING total_products >= 10
ORDER BY rating_std ASC
LIMIT 10;

-- which brand has varation in price
SELECT brandname,
    ROUND(MIN(Price), 2) AS min_price,
    ROUND(MAX(Price), 2) AS max_price,
    ROUND(MAX(Price) - MIN(Price), 2) AS price_range,
	ROUND(AVG(Price), 2) AS mean_price,
    ROUND(STD(Price), 2) AS std,
    COUNT(*) AS total_products
FROM electronics
GROUP BY brandname
HAVING total_products >= 10
ORDER BY price_range DESC
LIMIT 5;

-- Which subcategory has most brands competing?
SELECT `Sub Category`,
    COUNT(DISTINCT brandname) AS total_brands,
    COUNT(*) AS total_products,
    ROUND(AVG(Price), 2) AS avg_price
FROM electronics
GROUP BY `Sub Category`
ORDER BY total_brands DESC limit 5;

-- names of brand who has same subcategory
SELECT `Sub Category`,
    GROUP_CONCAT(DISTINCT brandname ORDER BY brandname) AS competing_brands
FROM electronics
GROUP BY `Sub Category`
ORDER BY `Sub Category`;

-- covairance
SELECT 
  AVG(price * average_rating) - (AVG(price) * AVG(average_rating)) AS covariance
FROM electronics;
-- -103 means negetive relation. when price goes up rating goes down

-- corelation
SELECT 
  (AVG(price * average_rating) - AVG(price) * AVG(average_rating)) / 
  (STDDEV(price) * STDDEV(average_rating)) AS correlation
FROM electronics;
-- -0.22 ( ther eis no strong negetive corelation kinda linear relationship)

-- slope
SELECT 
  (AVG(review_count * average_rating) - AVG(review_count) * AVG(average_rating)) /
  (AVG(review_count*review_count) - AVG(review_count) * AVG(review_count)) AS slope
FROM electronics;
-- If X increases by 1 → Y changes by exactly how much?
-- Slope = 0.000085 means →  if reviews increase by 1, rating increases by 0.000085

SELECT 
  (AVG(review_count * average_rating) - AVG(review_count) * AVG(average_rating)) 
  / 
  (STDDEV(review_count) * STDDEV(average_rating)) AS correlation
FROM electronics;
-- 0.16 a weak correlation as number is small

 
-- for exporting cleaned data
select * from electronics;
 