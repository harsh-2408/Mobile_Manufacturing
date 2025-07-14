----case study 2--------------
--1- List all the states in which we have customers who have bought cellphones  
--from 2005 till today.  
select State
from FACT_TRANSACTIONS as X
inner join DIM_DATE as Y
on X.Date=Y.DATE
inner join DIM_LOCATION as Z
on X.IDLocation=Z.IDLocation
inner join DIM_CUSTOMER as A
on X.IDCustomer=A.IDCustomer
where YEAR>2005


--2--What state in the US is buying the most 'Samsung' cell phones?   
select State
from FACT_TRANSACTIONS as X
inner join DIM_DATE as Y
on X.Date=Y.DATE
inner join DIM_LOCATION as Z
on X.IDLocation=Z.IDLocation
inner join DIM_MODEL as A
on X.IDModel=A.IDModel
where Country='US' and Model_Name like '%galaxy%'


--3 . Show the number of transactions for each model per zip code per state.  
select  count(Y.IDModel) as Count_trans,ZipCode,State,Model_Name
from FACT_TRANSACTIONS as X
inner join DIM_MODEL as Y
on X.IDModel=Y.IDModel
inner join DIM_LOCATION as Z
on X.IDLocation=Z.IDLocation
group by ZipCode,State,Model_Name

---4 . Show the cheapest cellphone (Output should contain the price also)
select top 1 Model_Name,sum(Unit_price) as price
from DIM_MODEL
group by Model_Name
order by price

--5 . Find out the average price for each model in the top5 manufacturers in  
--terms of sales quantity and order by average price.  
select * from DIM_MODEL
where IDManufacturer in(
	select top 5 Z.IDManufacturer
	from FACT_TRANSACTIONS as X
	inner join DIM_MODEL as Y
	on X.IDModel=Y.IDModel
	inner join DIM_MANUFACTURER as Z
	on Y.IDManufacturer=Z.IDManufacturer
	group by z.IDManufacturer
	order by sum(Quantity)desc,avg(TotalPrice)desc)

---6 . List the names of the customers and the average amount spent in 2009,  
---where the average is higher than 500 
select Customer_Name,avg(TotalPrice) as Avg_Spends
from FACT_TRANSACTIONS as A
inner join DIM_CUSTOMER as B
on A.IDCustomer=B.IDCustomer
inner join DIM_DATE as C
on C.DATE=A.Date
where YEAR=2009
group by Customer_Name
having avg(TotalPrice)>500

--7 . List if there is any model that was in the top 5 in terms of quantity,  
--simultaneously in 2008, 2009 and 2010  
with year_2008
as(
		select top 5 Model_Name
		from FACT_TRANSACTIONS as A
		inner join DIM_DATE as B
		on A.Date=B.DATE
		inner join DIM_MODEL as C
		on C.IDModel=A.IDModel
		where YEAR=2008
		group by Model_Name
		order by sum(Quantity) desc
),
year_2009
as(
         select top 5 Model_Name
		from FACT_TRANSACTIONS as A
		inner join DIM_DATE as B
		on A.Date=B.DATE
		inner join DIM_MODEL as C
		on C.IDModel=A.IDModel
		where YEAR=2009
		group by Model_Name
		order by sum(Quantity) desc
		
		 
),
year_2010
as(
      select top 5 Model_Name
		from FACT_TRANSACTIONS as A
		inner join DIM_DATE as B
		on A.Date=B.DATE
		inner join DIM_MODEL as C
		on C.IDModel=A.IDModel
		where YEAR=2010
		group by Model_Name
		order by sum(Quantity) desc
)
select * from year_2008
intersect
select * from year_2009
intersect
select * from year_2010

--8 . Show the manufacturer with the 2nd top sales in the year of 2009 and the  
--manufacturer with the 2nd top sales in the year of 2010. 
select * from(	
		select Manufacturer_Name,sum(TotalPrice) as Sales
		from FACT_TRANSACTIONS as X
		inner join DIM_DATE as Y
		on X.Date=Y.DATE
		inner join DIM_MODEL as Z
		on X.IDModel=Z.IDModel
		inner join DIM_MANUFACTURER as A
		on Z.IDManufacturer=A.IDManufacturer
		where YEAR=2009
		group by Manufacturer_Name
		order by Sales desc
		offset 1 row
		fetch next 1 row only
) as X
union 
select * from(
			select Manufacturer_Name,sum(TotalPrice) as Sales
			from FACT_TRANSACTIONS as X
			inner join DIM_DATE as Y
			on X.Date=Y.DATE
			inner join DIM_MODEL as Z
			on X.IDModel=Z.IDModel
			inner join DIM_MANUFACTURER as A
			on Z.IDManufacturer=A.IDManufacturer
			where YEAR=2010
			group by Manufacturer_Name
			order by Sales desc
			offset 1 row
			fetch next 1 row only
) as Z

---9 . Show the manufacturers that sold cellphones in 2010 but did not in 2009. 
select Manufacturer_Name---,sum(TotalPrice) as Sales
from FACT_TRANSACTIONS as X
inner join DIM_DATE as Y
on X.Date=Y.DATE
inner join DIM_MODEL as Z
on X.IDModel=Z.IDModel
inner join DIM_MANUFACTURER as A
on Z.IDManufacturer=A.IDManufacturer
where YEAR=2010
except
select Manufacturer_Name---,sum(TotalPrice) as Sales
from FACT_TRANSACTIONS as X
inner join DIM_DATE as Y
on X.Date=Y.DATE
inner join DIM_MODEL as Z
on X.IDModel=Z.IDModel
inner join DIM_MANUFACTURER as A
on Z.IDManufacturer=A.IDManufacturer
where YEAR=2009

---10 . Find top 10 customers and their average spend, average quantity by each  
---year. Also find the percentage of change in their spend. 
with top_10_cust
as(
	select top 10 IDCustomer,sum(TotalPrice) as Price
	from FACT_TRANSACTIONS
	group by IDCustomer
	order by Price desc
),
avg_spend
as(
	select C1.IDCustomer,YEAR(Date) as Years,avg(TotalPrice) as avg_price,
	avg(Quantity) as avg_qty
	from top_10_cust as C1
	inner join  FACT_TRANSACTIONS as F
	on f.IDCustomer=c1.IDCustomer
	group by c1.IDCustomer,year(Date)
),
prev_spend
as(
    select *,lag(avg_price,1)over (partition by idcustomer order by years)as lag
	from avg_spend
)
select Customer_Name,avg_price,Years,lag,(lag-avg_price)*100 as rev_change
from prev_spend as P
inner join DIM_CUSTOMER as D
on P.IDCustomer=D.IDCustomer









