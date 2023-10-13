/*

Cleaning Data in SQL Queries

*/

select *
from NationalHousings


--.......................................................................

--Standardize date format

select SaleDateConverted, CONVERT(Date,SaleDate)
from NationalHousings

UPDATE NationalHousings
SET SaleDate = CONVERT(Date,SaleDate)

Alter TABLE NationalHousings
Add SaleDateConverted Date;

UPDATE NationalHousings
SET SaleDateConverted = CONVERT(Date,SaleDate)


------------------------------------------------------------------------------------------

-- Populate property Address data

select *
from NationalHousings
order by ParcelID

select pars.ParcelID, pars.PropertyAddress, pros.ParcelID,  pros.PropertyAddress, ISNULL(pars.PropertyAddress, pros.PropertyAddress)
from NationalHousings pars
JOIN NationalHousings pros
     on pars.ParcelID = pros.ParcelID
	 AND pars.[UniqueID] <> pros.[UniqueID]
where pars.PropertyAddress is null


UPDATE pars
SET PropertyAddress = ISNULL(pars.PropertyAddress, pros.PropertyAddress)
from NationalHousings pars
JOIN NationalHousings pros
     on pars.ParcelID = pros.ParcelID
	 AND pars.[UniqueID] <> pros.[UniqueID]
where pars.PropertyAddress is null



-------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from NationalHousings
order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

from NationalHousings


Alter TABLE NationalHousings
Add PropertySplitAddress nvarchar(255);

UPDATE NationalHousings
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter TABLE NationalHousings
Add PropertySplitCity nvarchar(255);

UPDATE NationalHousings
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))



Select *
from NationalHousings



Select OwnerAddress
from NationalHousings


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NationalHousings


Alter TABLE NationalHousings
Add OwnerSplitAddress nvarchar(255);

UPDATE NationalHousings
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter TABLE NationalHousings
Add OwnerSplitCity nvarchar(255);

UPDATE NationalHousings
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter TABLE NationalHousings
Add OwnerSplitState nvarchar(255);

UPDATE NationalHousings
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from NationalHousings
Group by SoldAsVacant
Order by 2




Select SoldAsVacant,
  CASE When SoldAsVacant = 'Y' THEN 'YES'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   End
from NationalHousings


UPDATE NationalHousings
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   End





------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicate


With RowNumCTE AS(
Select *, 
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY 
				     UniqueID
					 ) row_num
from NationalHousings
--Order by ParcelID
)
Select *
from RowNumCTE
Where row_num > 1
order by PropertyAddress



------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Column

Select *
from NationalHousings

ALTER TABLE NationalHousings
DROP COLUMN OwnerAddress


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Stastical Analysis From 'LandValue' 'BuildingBalue' 'TotalValue' Field


Select LandValue, BuildingValue, TotalValue, (BuildingValue - LandValue) AS DifferenceInValue, (BuildingValue - LandValue)/TotalValue AS IncreaseDecreaseValue 
from NationalHousings
--Group by UniqueID
Order by YearBuilt desc