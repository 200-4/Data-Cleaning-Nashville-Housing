--Data Cleaning Using SQL QUERIES
select*
from [Portfolio PROJECT]..Sheet1$

--Standardize Date Format

 

UPDATE Sheet1$
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Sheet1$
ADD SaleDateConverted Date;

UPDATE Sheet1$
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate property Address date
SELECT *
FROM [Portfolio PROJECT]..Sheet1$
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio PROJECT]..Sheet1$ a
JOIN [Portfolio PROJECT]..Sheet1$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio PROJECT]..Sheet1$ a
JOIN [Portfolio PROJECT]..Sheet1$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking out Address into Individual Columns (Address, City,State)

SELECT PropertyAddress
FROM [Portfolio PROJECT]..Sheet1$
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,	 CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

FROM [Portfolio PROJECT]..Sheet1$


ALTER TABLE [Portfolio PROJECT]..Sheet1$
ADD PropertySplitAddress nvarchar(255);

UPDATE [Portfolio PROJECT]..Sheet1$
SET  PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [Portfolio PROJECT]..Sheet1$
ADD PropertySplitCity nvarchar(255);

UPDATE [Portfolio PROJECT]..Sheet1$
SET  PropertySplitCity = SUBSTRING(PropertyAddress,	 CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

--verify if object exists
SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'Sheet1$';
--Ensure you have the neccessary Permissions to alter the table

SELECT*
FROM sys.database_permissions
WHERE grantee_principal_id = DATABASE_PRINCIPAL_ID('NAA')

select*
from [Portfolio PROJECT]..Sheet1$



select OwnerAddress
from [Portfolio PROJECT]..Sheet1$

select PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
		PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
		PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
from [Portfolio PROJECT]..Sheet1$



ALTER TABLE [Portfolio PROJECT]..Sheet1$
ADD OwnerSplitAddress nvarchar(255);

UPDATE [Portfolio PROJECT]..Sheet1$
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE [Portfolio PROJECT]..Sheet1$
ADD OwnerSplitCity nvarchar(255);

UPDATE [Portfolio PROJECT]..Sheet1$
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) 

ALTER TABLE [Portfolio PROJECT]..Sheet1$
ADD OwnerSplitState nvarchar(255);

UPDATE [Portfolio PROJECT]..Sheet1$
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

select *
from [Portfolio PROJECT]..Sheet1$

--Change Y and N to Yes and No in "Sold as Vacant" field

select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
from [Portfolio PROJECT]..Sheet1$
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
from [Portfolio PROJECT]..Sheet1$

UPDATE [Portfolio PROJECT]..Sheet1$
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END

--REMOVE DUPLICATES
WITH RowNumCTE AS(
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM [Portfolio PROJECT]..Sheet1$
--ORDER BY ParcelID
)

SELECT*
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


--DELETE UNUSED COLUMNS
SELECT *
FROM  [Portfolio PROJECT]..Sheet1$

ALTER TABLE  [Portfolio PROJECT]..Sheet1$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 

ALTER TABLE  [Portfolio PROJECT]..Sheet1$
DROP COLUMN SaleDate 
