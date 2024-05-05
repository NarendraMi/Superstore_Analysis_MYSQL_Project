-- Use Database 
use superstores;

-- Data cleaning part start from here
alter table orderlist modify column OrderDate date;
alter table orderlist modify column OrderID varchar(255) not null;
alter table orderlist modify column CustomerName varchar(255);
alter table orderlist modify column Region varchar(255);
alter table orderlist modify column Segment varchar(255);
alter table orderlist modify column ShipDate date;
alter table orderlist modify column ShipMode varchar(255);
alter table orderlist modify column OrderPriority varchar(255);
-- Slpit City Sate Country into 3 Columns City,State,Country
alter table orderlist add City varchar(255);
alter table orderlist add State varchar(255);
alter table orderlist add Country varchar(255);

-- Find the city, state and country name from column City_State_Country
select City_State_Country, substring(City_State_Country,1,locate(',',City_State_Country)-1) as Country,
trim(substring_index(substring_index(City_State_Country,',',2),',',-1)) as State,
substring_index(City_State_Country,',',-1) as City from orderlist;  

-- Update city,state and country name in City,Stateand Country column in table orderlist
SET SQL_SAFE_UPDATES = 0;
update orderlist set Country=trim(substring(City_State_Country,1,locate(',',City_State_Country)-1));
update orderlist set State=trim(substring_index(substring_index(City_State_Country,',',2),',',-1));
update orderlist set City=trim(substring_index(City_State_Country,',',-1));

select * from orderlist limit 5;

-- Adding new Category column using the following mapping as per the first 3 characters in the ProductName column.alter
-- a. TEC - Technology
-- b. OFS - Office Suplies
-- c. FUR - Furniture
select * from eachorderbreakdown;
alter table eachorderbreakdown add column Category varchar(255);
update eachorderbreakdown set Category= case when left(ProductName,3)='TEC' then 'Technology'
when left(ProductName,3)='OFS' then 'Office Suplies'
when left(ProductName,3)='FUR' then 'Furniture'
end;

-- Remove duplicate rows from eachorderbreakdown table, if all column values are matching.
delete t1 from eachorderbreakdown t1
join (
    select *,row_number() over(partition by OrderID,ProductName,Discount,Sales,Profit,Quantity,SubCategory,Category order by OrderID)
as rownumber from eachorderbreakdown
) t2 on t1.OrderID = t2.OrderID
      and t1.ProductName = t2.ProductName
      and t1.Discount = t2.Discount
      and t1.Sales = t2.Sales
      and t1.Profit = t2.Profit
      and t1.Quantity = t2.Quantity
      and t1.SubCategory = t2.SubCategory
      and t1.Category = t2.Category
where t2.rownumber > 1;

-- Replace blank with NA in OrderPriority in orderlist table.
select count(*) from orderlist where OrderPriority='';
update orderlist set OrderPriority= case when OrderPriority='' then 'NA' end;
-- Data Cleaning parts end here
