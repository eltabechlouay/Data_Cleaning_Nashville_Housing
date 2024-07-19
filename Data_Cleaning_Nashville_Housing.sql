-- Viewing and Checking the whole data:
select *
from housing.data;

--------------------------------------------------------------------------------------

-- First, the SaleDate is not in standard format, we convert the date then:
select SaleDate, convert(Date,SaleDate)
from housing.data;

Alter table housing.data
add SaleDate_Converted Date;

update housing.data
set SaleDate_Converted = convert(Date,SaleDate)

select SaleDate_Converted
from housing.data;

----------------------------------------------------------------------------------------

-- The PropertyAddress needs to be populated: (It has null values)
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from housing.data a join housing.data b
on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from housing.data a join housing.data b
on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

--Re-executing the code above showed no null values, so the values in PropertyAddress have been successfully updated.
-------------------------------------------------------------------------------------------------------------------------------

-- Now we need to break the PropertyAddress into individual columns (Address,City,State):
select PropertyAddress
from housing.data;

select substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as Address
from housing.data;

ALter table housing.data
add PropertySplitAddress nvarchar(255),
PropertySplitCity nvarchar(255);

update housing.data
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress));

--Now to check the whole data:
select *
from housing.data;

-----------------------------------------------------------------------------------------------------------------

-- We need to split the OwnerAddress as well, but I'll try a different method this time:
select OwnerAddress
from housing.data;

select PARSENAME(REPLACE(OwnerAddress, ',','.'), 1),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
from housing.data;

-- Applying the whole process like PropertyAddress
ALter table housing.data
add OwnerSplitAddress nvarchar(255),
OwnerSplitCity nvarchar(255),
OwnerSPlitState nvarchar(255);

update housing.data
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1);

select *
from housing.data;
------------------------------------------------------------------------------------------------------------------

-- SoladAsVacant field needs to be simplified by using Y as Yes and N as No
select distinct SoldAsVacant, count(SoldAsVacant)
from housing.data
group by SoldAsVacant
order by 2;

select SoldAsVacant, case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from housing.data;

update housing.data
set SoldAsVacant = case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end;

------------------------------------------------------------------------------------------

-- Removing Duplicates in the data:
with rownumber as(
select *,
row_number() over (partition by
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by UniqueID) row_num
from housing.data)
--delete
--from rownumber
--where row_num > 1;

select *
from rownumber
where row_num > 1
order by PropertyAddress;

--------------------------------------------------------------------------------------------------

--Now to finally delete unused columns:

select *
from housing.data

alter table housing.data
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
