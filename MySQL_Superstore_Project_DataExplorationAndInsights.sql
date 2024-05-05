use superstores;
-- Data Exploration - Means to find the insights from the data.

-- 1. List the top 10 orders with the heighest sales from eachorderbreakdown table.
select * from eachorderbreakdown order by sales desc limit 10;

-- 2. Show the no. of order for each product category in eachorderbreakdown table.
select Category,count(*) as Number_Of_Orders from eachorderbreakdown group by Category;

-- 3. Find the total profit for each sub-category in eachorderbreakdown table.
select SubCategory,sum(Profit) as Total_Profit from eachorderbreakdown group by SubCategory;

-- 4. Identify the customer with the heighest total sales across all orders.
select CustomerName,sum(sales) as Total_Sales from orderlist ol
join eachorderbreakdown ob
on ol.OrderID=ob.OrderID
group by CustomerName order by Total_Sales desc limit 1;

-- 5. Find the month with the heighest average sales in orderlist table.
-- select * from orderlist;
select month(OrderDate) as Month, avg(sales) Heighest_Average_Sales from orderlist ol
join eachorderbreakdown ob
on ol.OrderID=ob.OrderID
group by month(OrderDate) order by Heighest_Average_Sales desc limit 1;

-- 6. Find out the average quantity ordered by customers whose first name starts with an alphate 's'?
select avg(Quantity) as Avg_Quantity from orderlist ol
join eachorderbreakdown ob
on ol.OrderID=ob.OrderID
where left(CustomerName,1)='S';

-- 7. Find out how many new customers were acquired in the year 2014?
select count(*) as New_Customer from(
select CustomerName,min(OrderDate) as New_Customer from orderlist group by CustomerName
having year(min(OrderDate))=2014) as CustomerWithFirstOrderIn2014;

-- 8. Calculate the percentage of total profit contributed by each sub-category to the overall profit.
select SubCategory,sum(Profit) as SubCategory_TotalProfit,
round(sum(Profit)/(select sum(Profit) from eachorderbreakdown) * 100,2) as ProfitContributedByEachSubCategoryInPercent
from eachorderbreakdown group by SubCategory order by SubCategory;

-- 9. Find the average sales per customer, considering only customers who have made more than one order. 
-- Using CET
with Customers_Avgerage_Sales as (
select CustomerName,count(distinct(ol.OrderID)) as NumberOfOrders,avg(Sales) as AverageSales
from orderlist ol
join eachorderbreakdown eob
on ol.OrderID=eob.OrderID
group by CustomerName)
select CustomerName,round(AverageSales,2) from Customers_Avgerage_Sales where NumberOfOrders >1;

-- 10. Identify the TOP Performing sub-category in each category based on total sales. Include the Sub-Category name,
-- total sales and a ranking of sub-category withing each category.
-- select * from eachorderbreakdown limit 3;
-- Using CET
with Top_SubCategory as (
select Category,SubCategory,sum(Sales) as TotalSales,
rank() over(partition by Category order by sum(Sales) desc) as SubCategory_Rank from eachorderbreakdown
group by Category,SubCategory)
select SubCategory,TotalSales from Top_SubCategory where SubCategory_Rank=1 order by SubCategory;
