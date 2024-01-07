/*
Cleaning the data through SQL Queries for Nashville Housing 
*/
select * from master.dbo.Nashvillehousing

................................................................................................

---standardize the date format from 2013-04-09 00:00:00.000 to 


Select SaleDate, CONVERT(DATE, SaleDate)
FROM master.dbo.Nashvillehousing

/* Here couldnt convert the date column so, SaleDateConverted coloumn is added and updated with newer data format*/
ALTER TABLE Nashvillehousing
Add SaleDateConverted Date;

UPDATE master.dbo.Nashvillehousing
SET SaleDateCOnverted = CONVERT(DATE, SaleDate)


-------------------------------------------------------------------------------------------------------------------
/* Populating Property address data */

--- check the property address rows which are null in the above query
SELECT PropertyAddress
FROM master.dbo.Nashvillehousing
WHERE PropertyAddress is null

----- checking the total null rows in the data

SELECT *
FROM master.dbo.Nashvillehousing
WHERE PropertyAddress is null
order by ParcelID

----It is observed that there is null in property address so, we self joined the table to identify based on ParcelID and UniqueID
SELECT a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM master.dbo.Nashvillehousing a
JOIN master.dbo.Nashvillehousing b
ON a.ParcelID = b.ParcelID and a.[UniqueID ] != b.[UniqueID ] 
where a.PropertyAddress is NULL


-------Replacing null with propertyaddress (adding a column and then updating in next query)
SELECT a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM master.dbo.Nashvillehousing a
JOIN master.dbo.Nashvillehousing b
ON a.ParcelID = b.ParcelID and a.[UniqueID ] != b.[UniqueID ] 
where a.PropertyAddress is NULL


--------Updating the Null Values
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM master.dbo.Nashvillehousing a
JOIN master.dbo.Nashvillehousing b
ON a.ParcelID = b.ParcelID and a.[UniqueID ] != b.[UniqueID ] 
where a.PropertyAddress is NULL

-----------------------------------------------------------------------------------------------------------------------------------
/* Breaking the property address into individual columns of address, city and State */

SELECT PropertyAddress,
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM master.dbo.Nashvillehousing 

--- Now we have to add these as address as columns to the data by first alter and then update statement

ALTER TABLE Nashvillehousing
Add PropertySplitAddress varchar(300);

UPDATE master.dbo.Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

------ altering and adding city column
ALTER TABLE Nashvillehousing
Add PropertyCityAddress varchar(250);

UPDATE master.dbo.Nashvillehousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


---- I found there is a mistake in the column name, so I am altering it
EXEC sp_rename 'master.dbo.Nashvillehousing.SaleDateCOnverted', 'SaleDateConverted', 'COLUMN';


SELECT * FROM master.dbo.Nashvillehousing

---- NOW, The same modification is to be done OwnerAddress but with differenet Function PARSENAME


select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from master.dbo.Nashvillehousing


---------Split Address by Altering and Updating column
ALTER TABLE Nashvillehousing
Add OwnerSplitAddress varchar(300);

UPDATE master.dbo.Nashvillehousing
SET OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 



---------Split City by Altering and Updating column
ALTER TABLE Nashvillehousing
Add  OwnerSplitCity varchar(300);

UPDATE master.dbo.Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


---------Split State by Altering and Updating column
ALTER TABLE Nashvillehousing
Add OwnerSplitState varchar(300);

UPDATE master.dbo.Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select * 
from Nashvillehousing

---------------------------------------------------------------------------------------------------------------------------------

---Checking to changw Y and N to Yes and Noin Sold as Vacant
select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from Nashvillehousing
group by SoldAsVacant
order by 2


----Changing Y to Yes and N to No
select 
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END
From Nashvillehousing


---Updating it to Yes and No
Update Nashvillehousing
Set SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END
From Nashvillehousing

-------------------------------------------------------------------------------------------------------------------------------
/*Remove the duplicates */

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress, SalePrice, 
	SaleDate, LegalReference
	ORDER BY
	UniqueID) row_num
From master.dbo.Nashvillehousing)
SELECT *
From RowNumCTE
WHERE row_num>1
--ORDER BY PropertyAddress

------------------------------------------------------------------------------------------------------------------------------------
---Delete Unused Columns
select * 
FROM Nashvillehousing

ALTER TABLE master.dbo.Nashvillehousing
DROP Column PropertyAddress, OwnerAddress, SaleDate, TaxDistrict
-----------------------------------------------------------------------------------------------------------------------------------

Cleaned Data
select * from master.dbo.Nashvillehousing