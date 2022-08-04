use nashville
go

select  *  from housing

--------------------------------------------------------------------------------------------------------------------

--standarize saledate format

select saledate from housing
select saledate, CONVERT(Date,SaleDate) date from housing

update housing
set saledate = CONVERT(Date,SaleDate)
--using this code the column wont actually update->create new column and try to insert data

alter table housing
add short_date date

update housing
set short_date = CONVERT(Date,SaleDate)

select SaleDate, short_date from housing

--worked, drop old column uf neccesary
alter table housing
drop column SaleDate

--------------------------------------------------------------------------------------------------------------------

--populate PropertyAdress where null

select * from housing
where PropertyAddress is null 
order by ParcelID


--join the tables to get the property adress with sales from the same parcel (it's the same adress)

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyaddress,b.PropertyAddress) as newadress from housing as a
join housing as b
on a.ParcelID=b.ParcelID and  a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress) from housing as a
join housing as b
on a.ParcelID=b.ParcelID and  a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------

--get adress and city from propertyaddress in separate columns

select PropertyAddress
,substring(PropertyAddress,charindex(',',PropertyAddress)+1,20) city
,substring(PropertyAddress,charindex(',',PropertyAddress)-50,50) adress
from housing

alter table housing add  property_adress text
alter table housing add property_city text

update housing
set property_adress = substring(PropertyAddress,charindex(',',PropertyAddress)-50,50)

update housing
set property_city = substring(PropertyAddress,charindex(',',PropertyAddress)+1,20)

select PropertyAddress,property_adress,property_city from housing


--worked, remove propertyadress if needbe
alter table housing
drop column propertyadress

--do the same with owner address

select OwnerAddress
,charindex(',',OwnerAddress) separator1
,charindex(',',owneraddress,charindex(',',owneraddress)+1) separator2
,substring(owneraddress,charindex(',',OwnerAddress)-50,50) as address
,substring(owneraddress,charindex(',',OwnerAddress)+1,charindex(',',owneraddress,charindex(',',owneraddress)+1)-charindex(',',OwnerAddress)-1) as city
,substring(owneraddress,charindex(',',owneraddress,charindex(',',owneraddress)+1)+1,5) as state
from housing

alter table housing add owner_address text
alter table housing add owner_city text
alter table housing add owner_state text

update housing
set owner_address = substring(owneraddress,charindex(',',OwnerAddress)-50,50)

update housing
set owner_city = substring(owneraddress,charindex(',',OwnerAddress)+1,charindex(',',owneraddress,charindex(',',owneraddress)+1)-charindex(',',OwnerAddress)-1)

update housing
set owner_state = substring(owneraddress,charindex(',',owneraddress,charindex(',',owneraddress)+1)+1,5)

select * from housing

--columns succesfully updated, can drop old column
alter table housing drop column owneraddress



--------------------------------------------------------------------------------------------------------------------
--update SoldAsVacant to "yes" and "no" 


select SoldAsVacant from housing
select distinct soldasvacant,COUNT(soldasvacant) from housing
group by SoldAsVacant

select soldasvacant,
case when soldasvacant = 'Y' then 'Yes' when soldasvacant = 'N' then 'No' else soldasvacant end
from housing
order by SoldAsVacant desc

update housing
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes' when soldasvacant = 'N' then 'No' else soldasvacant end
from housing

--remove old if needed


-------------------------------------------------------------------------------------------------------------------- 

--remove duplicates

--select duplicates and count
with row_num_cte as (
select *,
row_number() over (
partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference order by UniqueID) row_num
from housing)
select * from row_num_cte
where row_num>1 

--delete duplicates
with row_num_cte as (
select *,
row_number() over (
partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference order by UniqueID) row_num
from housing)
delete from row_num_cte
where row_num>1 
--order by ParcelID

select * from housing









