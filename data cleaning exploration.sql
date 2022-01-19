-- cleaning sql queries

SELECT * 
FROM PortfolioProject.dbo.[Nashville housing]

-- standardize date format

SELECT SaleDate, CONVERT(date, SaleDate) 
FROM PortfolioProject.dbo.[Nashville housing]

UPDATE [Nashville housing]
SET SaleDate = CONVERT(date, SaleDate)

-- If it doesn't Update properly


ALTER TABLE [Nashville housing]
ADD SaleDateConverted Date; 

UPDATE [Nashville housing]
SET SaleDateConverted = CONVERT(date, SaleDate) 


SELECT SaleDateConverted, CONVERT(date, SaleDate) 
FROM PortfolioProject.dbo.[Nashville housing]


--Populate property address

SELECT * 
FROM PortfolioProject..[Nashville housing]
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.PropertyAddress, a.ParcelID, b.PropertyAddress, b.ParcelID, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..[Nashville housing] a
JOIN PortfolioProject..[Nashville housing] b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..[Nashville housing] a
JOIN PortfolioProject..[Nashville housing] b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--Seperate property addres into address,city,state

SELECT PropertyAddress
FROM PortfolioProject..[Nashville housing]

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress)) AS City


FROM PortfolioProject..[Nashville housing]



ALTER TABLE [Nashville housing]
ADD PropertySplitAddress nvarchar(255);

UPDATE [Nashville housing]
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1)


ALTER TABLE [Nashville housing]
ADD PropertySplitCity nvarchar(255);

UPDATE [Nashville housing]
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress)) 

--We created 2 new columns that will be added at the end of the table by using substring. 
SELECT * 
FROM PortfolioProject..[Nashville housing]


--Splitting owners address to state and city using PARSENAME

SELECT OwnerAddress
FROM PortfolioProject..[Nashville housing]
WHERE OwnerAddress IS NOT NULL


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Adress,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM PortfolioProject..[Nashville housing]
--WHERE OwnerAddress IS NOT NULL

--adding the new columns to the table 

ALTER TABLE PortfolioProject..[Nashville housing]
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject..[Nashville housing]
SET OwnerSplitAddress =   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

------
ALTER TABLE PortfolioProject..[Nashville housing]
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject..[Nashville housing]
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

------
ALTER TABLE PortfolioProject..[Nashville housing]
ADD OwnerSplitState nvarchar(255);

UPDATE PortfolioProject..[Nashville housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * 
from PortfolioProject..[Nashville housing] --Added the new columns to the table



--Change Y/ N to yes /no in soldAsVacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..[Nashville housing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
	END
FROM PortfolioProject..[Nashville housing]

UPDATE PortfolioProject..[Nashville housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						WHEN SoldAsVacant = 'NO' THEN 'No'

						ELSE SoldAsVacant
				   END
SELECT *
FROM PortfolioProject..[Nashville housing] --CHANGED Y/N TO YES/NO 


--Removing duplicates

WITH RowNumCTE AS(    --CREATING CTE i.e temporary table to check duplicate values
SELECT * ,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
	
FROM PortfolioProject..[Nashville housing] 
)
DELETE   ---DELETE all the duplicate values from cte i.e temporary table 
FROM RowNumCTE
WHERE row_num > 1


--Delete unused columns

SELECT * 
FROM PortfolioProject..[Nashville housing]

ALTER TABLE PortfolioProject..[Nashville housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate