/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select saledateconverted, convert(date, saledate)
From PortfolioProject.dbo.NashvilleHousing

update nashvillehousing
set saledate = convert(date, saledate)

alter table NashvilleHousing
add saledateconverted date;

update nashvillehousing
set saledateconverted = convert(date, saledate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--where propertyaddress is null
order by parcelid


Select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject..nashvillehousing b
	on a.parcelid = b.parcelid
	and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject..nashvillehousing b
	on a.parcelid = b.parcelid
	and a.[uniqueid] <> b.[uniqueid]

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select propertyaddress
From PortfolioProject.dbo.NashvilleHousing
--where propertyaddress is null
--order by parcelid

select
substring(PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1) as Address
,substring(PropertyAddress, CHARINDEX(',', propertyaddress)+1, len(propertyaddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update nashvillehousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1)

alter table NashvilleHousing
add PropertySplitCity  nvarchar(255);

update nashvillehousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', propertyaddress)+1, len(propertyaddress))


select *
from PortfolioProject..NashvilleHousing

select owneraddress
from PortfolioProject..NashvilleHousing

select
PARSENAME(replace(owneraddress, ',', '.'), 3)
, PARSENAME(replace(owneraddress, ',', '.'), 2)
, PARSENAME(replace(owneraddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update nashvillehousing
set OwnerSplitAddress = PARSENAME(replace(owneraddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity  nvarchar(255);

update nashvillehousing
set OwnerSplitCity = PARSENAME(replace(owneraddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update nashvillehousing
set OwnerSplitState = PARSENAME(replace(owneraddress, ',', '.'), 1)





--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct (SoldAsVacant), count(soldasvacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

select Soldasvacant
, case when soldasvacant = 'Y' Then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end
from PortfolioProject..NashvilleHousing


Update NashvilleHousing
Set soldasvacant = case when soldasvacant = 'Y' Then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE AS(
Select *, 
	ROW_NUMBER() over(
	partition by parcelid,
	propertyaddress, 
	saleprice, 
	saledate, 
	legalreference
	order by uniqueID
	) row_num
from PortfolioProject..NashvilleHousing
--order by parcelid
)
Delete
From RowNumCTE
where row_num >1
--order by propertyaddress



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column saledate








-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
