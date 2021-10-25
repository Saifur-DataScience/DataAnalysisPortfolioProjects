USE PortfolioProject; 

-- Let's see how the data looks like

SELECT * FROM NashvilleHousing; 


-- Let's see how many rows do we have in here

SELECT COUNT(UniqueID) FROM NashvilleHousing; 


-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate) FROM NashvilleHousing; 

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date;

SELECT SaleDate, CONVERT(Date, SaleDate) FROM NashvilleHousing; 


-- Let's quickly look at the Property Address column

SELECT PropertyAddress FROM NashvilleHousing;

-- We have null values in the PropertyAddress as well
-- Let's look at those as well

SELECT COUNT(UniqueID) 
FROM NashvilleHousing
WHERE PropertyAddress IS NULL; 

-- We have 29 Null Values in property address
-- Also, upon checking the date, we found that the ParcelID & Address are directly correlated

SELECT ParcelID, PropertyAddress
FROM NashvilleHousing
ORDER BY ParcelID; 

-- Let's see if all ParcelIDs have addresses or not
-- We will use Self Join to check this

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
	 ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL; 

-- We see that there are Null values for the first instance of ParcelID
-- So, we now need to replace all these Null values with the Address for second instance of ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
	   ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	 ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL; 

-- We need to replace the values for Null with the new column that we just populated

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	 ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL; 


-- Nothing populates with the below query, which mmeans the null values are replaced successfully

SELECT ParcelID FROM NashvilleHousing
WHERE PropertyAddress IS NULL; 


-- Let's now break address into Address, City & State

SELECT PropertyAddress FROM NashvilleHousing


-- I have gone through the column and see that there is a ',' that is separating Address with the State
-- Let's split the column based on the delimiter, which is a ',' in this case

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
FROM NashvilleHousing; 

-- We are also getting the ',' in the output
-- So, let's remove that as well

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
FROM NashvilleHousing; 


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM NashvilleHousing; 

-- Perfect! 

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)); 


SELECT * FROM NashvilleHousing; 


-- Let's also see the owner address column as well 

SELECT OwnerAddress FROM NashvilleHousing; 


-- We cleaned PropertyAddress column the hard way
-- Let's do the same to OwnerAddress but in a much better way

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing; 


-- Unique thing about PARSENAME is that it goes backwards
-- So, 1 in Parsename means that the last value is picked up and so on

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


ALTER TABLE NashvilleHousing
ADD OwnerAddressCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


ALTER TABLE NashvilleHousing
ADD OwnerAddressState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


SELECT * FROM NashvilleHousing; 

-- Great! The columns have populated at the end of the table now


-- Let's also look at the column SoldAsVacant

SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing; 

-- We have Yes, Y, No, N altogether in this column
-- So, we will have to change Y with Yes and N with No


SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant END
FROM NashvilleHousing; 


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				   WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant END

SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing; 

-- Perfect! 


-- Finally we will be deleting the duplicate rows from the data

WITH RowNumCTE as (
SELECT *, ROW_NUMBER() OVER (
		  PARTITION BY ParcelID, 
					   PropertyAddress, 
					   SalePrice, 
					   SaleDate, 
					   LegalReference
		  ORDER BY UniqueID
) RowNum
FROM NashvilleHousing 
)
SELECT *
FROM RowNumCTE
WHERE RowNum > 1; 


-- Let's now delete the columns that are redundant

SELECT * FROM NashvilleHousing; 

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress

