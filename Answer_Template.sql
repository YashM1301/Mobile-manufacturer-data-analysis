--SQL Advance Case Study


--Q1--BEGIN 
	select distinct State from DIM_LOCATION as L
	join FACT_TRANSACTIONS as F on L.IDLocation = F.IDLocation
	join DIM_DATE as D on F.Date = D.DATE
	where D.YEAR>=2005;

--Q1--END

--Q2--BEGIN
	select top 1 State,country ='USA' from DIM_LOCATION as L
	join FACT_TRANSACTIONS as F on  L.IDLocation = F.IDLocation
	join DIM_MODEL M on F.IDModel = M.IDModel
	join DIM_MANUFACTURER as DM on M.IDManufacturer = DM.IDManufacturer
	where DM.Manufacturer_Name = 'Samsung'
	group by L.State
	order by count(*) desc;

--Q2--END

--Q3--BEGIN      
select MO.Model_Name,L.state,L.ZipCode,count(*) as Transaction_Count
from DIM_LOCATION L
join FACT_TRANSACTIONS F on L.IDLocation = F.IDLocation
join DIM_MODEL MO on F.IDModel = MO.IDModel
group by MO.Model_Name,L.ZipCode,L.State

--Q3--END

--Q4--BEGIN
select top 1  MO.Model_Name,Mo.Unit_price
from DIM_MODEL MO
order by MO.Unit_price

--Q4--END

--Q5--BEGIN
select Model_Name,manufacturer_name,AVG(Unit_price) as Avg_unit_price from DIM_MODEL as Model
inner join DIM_MANUFACTURER as Manu
on model.IDManufacturer = Manu.IDManufacturer
where Manufacturer_Name in (
select top 5 Manufacturer_Name from FACT_TRANSACTIONS as T
join DIM_MODEL as MOD
on MOD.IDModel = T.IDModel
join DIM_MANUFACTURER as Manu
on MOD.IDManufacturer = Manu.IDManufacturer
group by Manufacturer_Name
order by sum(quantity) desc)
group by Model_Name,Manufacturer_Name
order by Avg_unit_price desc;
--Q5--END

--Q6--BEGIN
select C.Customer_Name,AVG(F.TotalPrice) as Avg_Amt_Spent from DIM_CUSTOMER C
join FACT_TRANSACTIONS F on C.IDCustomer = F.IDCustomer
join DIM_DATE D on F.Date = D.DATE
where D.YEAR = 2009
group by C.Customer_Name
having avg(F.TotalPrice) > 500;

--Q6--END
	
--Q7--BEGIN  
select MO.model_Name from DIM_MODEL MO	
join FACT_TRANSACTIONS F on MO.IDModel = F.IDModel
join DIM_DATE D on F.Date = D.DATE
where D.YEAR IN (2008,2009,2010)
group by MO.Model_Name
having count(distinct D.year) =3
order by sum(F.Quantity) DESC
offset 0 rows fetch next 5 rows only;

--Q7--END	
--Q8--BEGIN
select * from (
select * from(
select manufacturer_Name,totalSales,Year,ROW_NUMBER() over(Order by totalSales desc) as _rank
from(select MF.Manufacturer_Name,D.YEAR,sum(T.TotalPrice) as totalSales
from DIM_MANUFACTURER as MF
join DIM_MODEL as MOD
on MF.IDManufacturer = MOD.IDManufacturer
join FACT_TRANSACTIONS as T
on MOD.IDModel = T.IDModel
join DIM_DATE as D
on T.Date = D.DATE
where D.YEAR = 2009
group by MF.Manufacturer_Name,D.YEAR) as table1) as table2
where _rank = 2
union
select * from(
select manufacturer_name,totalSales,Year,row_number() over(order by totalSales desc) as _rank
from(select MF.Manufacturer_Name,D.YEAR,sum(T.TotalPrice) as totalSales
from DIM_MANUFACTURER as MF
join DIM_MODEL as MOD
on MF.IDManufacturer = MOD.IDManufacturer
join FACT_TRANSACTIONS as T
on MOD.IDModel = T.IDModel
join DIM_DATE as D
on T.Date= D.DATE
where D.YEAR = 2010
group by MF.Manufacturer_Name,D.YEAR) as table3)as table4
where _rank = 2)
as mainTable;
--Q8--END

--Q9--BEGIN
select Distinct DM.Manufacturer_Name from DIM_MANUFACTURER DM	
join DIM_MODEL MO on DM.IDManufacturer = MO.IDManufacturer
join FACT_TRANSACTIONS F on MO.IDModel = F.IDModel
join DIM_DATE D on F.Date = D.DATE
where D.YEAR=2010
and DM.Manufacturer_Name not in(select distinct DM.Manufacturer_Name from DIM_MANUFACTURER DM
join DIM_MODEL MO on DM.IDManufacturer=MO.IDManufacturer
join FACT_TRANSACTIONS F on MO.IDModel= F.IDModel
join DIM_DATE D on F.Date =D.DATE
where D.YEAR=2009);

--Q9--END

--Q10--BEGIN
SELECT TOP 100
    CustomerName,
    Order_Year,
    Avg_Spend,
    Avg_Quantity,
    LAG(Avg_Spend) OVER (PARTITION BY CustomerName ORDER BY Order_Year) AS Prev_Avg_Spend,
    ((Avg_Spend - LAG(Avg_Spend) OVER (PARTITION BY CustomerName ORDER BY Order_Year)) / LAG(Avg_Spend) OVER (PARTITION BY CustomerName ORDER BY Order_Year)) * 100 AS Change_Spend_Percentage
FROM (
    SELECT
        C.Customer_Name AS CustomerName,
        YEAR(T.Date) AS Order_Year,
        AVG(T.TotalPrice) AS Avg_Spend,
        AVG(T.Quantity) AS Avg_Quantity
    FROM
        DIM_CUSTOMER C
    JOIN
        FACT_TRANSACTIONS T ON C.IDCustomer = T.IDCustomer
    GROUP BY
        C.Customer_Name, YEAR(T.Date)
) AS CustomerYearlyStats
ORDER BY
    Avg_Spend DESC;	


--Q10--END