
SELECT * FROM NashVillaHousing

--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format for SaleData Field
-- Show salesDate , converted salesDate
-- Existing salesDate in datetime format after import from excel so option as follow
-- 1)  Create new column UpdateSaleDate to hold data in date format
-- 2)  Update field UpdateSaleDate to intended format YYYY-MM-DD  
--------------------------------------------------------------------------------------------------------------------------

SELECT SALEDATE, CONVERT(DATE,SALEDATE),UpdateSaleDate FROM NashVillaHousing

ALTER TABLE NashVillaHousing
ADD UpdateSaleDate date

UPDATE NashVillaHousing
SET UpdateSaleDate = CONVERT(DATE,SALEDATE)

--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data
-- In this case, realise ParcelID can determine PropertyAddress so 
-- create a query to update PropertyAddress for the null records
-- ParcelID,PropertyAddress,fillingAddress
-- ISNULL() function returns a specified value if the expression is NULL
--

SELECT [UniqueID ], ParcelID,PropertyAddress 
FROM NashVillaHousing
WHERE PropertyAddress is null 
ORDER BY ParcelID

SELECT a.[UniqueID ],b.[UniqueID ] ,a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashVillaHousing a JOIN NashVillaHousing b on a.ParcelID = b.ParcelID
WHERE a.PropertyAddress is null AND a.[UniqueID ] <> b.[UniqueID ]    
order by a.PropertyAddress

UPDATE a
SET PropertyAddress = iSNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashVillaHousing a 
JOIN NashVillaHousing b 
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null     



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT * FROM NashVillaHousing
SELECT PropertyAddress FROM NashVillaHousing
SELECT OwnerAddress FROM NashVillaHousing


-- Breaking Property Address and update to new columns PropertySplitAddress,PropertySplitCity
-- The SUBSTRING() function extracts some characters from a string
-- SUBSTRING(string, start, length)
-- CHARINDEX() function searches for a substring in a string, and returns the position.
-- If the substring is not found, this function returns 0.
-- Note: This function performs a case-insensitive search.

SELECT PropertyAddress,
SUBSTRING( PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS PropertySplitAddress,
SUBSTRING( PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) AS PropertySplitCity
FROM NashVillaHousing

ALTER TABLE NashVillaHousing
ADD PropertySplitAddress nvarchar(255) ,PropertySplitCity nvarchar(255)

UPDATE NashVillaHousing
SET PropertySplitAddress = SUBSTRING( PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
UPDATE NashVillaHousing
SET PropertySplitCity = SUBSTRING( PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

-- Breaking Owner Address and update to new columns OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
-- PARSENAME function return results with period NOT commas and backwards
-- PARSENAME('object_name', object_piece)
-- REPLACE() function replaces all occurrences of a substring within a string, with a new substring.
-- REPLACE(string, old_string, new_string)

SELECT PARSENAME(OwnerAddress,1) FROM NashVillaHousing

SELECT OwnerAddress, 
PARSENAME(replace(OwnerAddress,',','.'),3) as OwnerSplitAddress , 
PARSENAME(replace(OwnerAddress,',','.'),2) as OwnerSplitCity,
PARSENAME(replace(OwnerAddress,',','.'),1) as OwnerSplitState
FROM NashVillaHousing

ALTER TABLE NashVillaHousing
ADD OwnerSplitAddress nvarchar(255) ,OwnerSplitCity nvarchar(255),OwnerSplitState nvarchar(255)

UPDATE NashVillaHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)
UPDATE NashVillaHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)
UPDATE NashVillaHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

SELECT * FROM NashVillaHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
-- CASE STATEMENT 
--CASE
--    WHEN condition1 THEN result1
--    WHEN condition2 THEN result2
--    WHEN conditionN THEN resultN
--    ELSE result
--END 

SELECT distinct(SoldAsVacant) FROM NashVillaHousing

SELECT SoldAsVacant, 
case when SoldAsVacant = 'Y'then 'Yes'
     when SoldAsVacant = 'N'then 'No'
	 else SoldAsVacant
	 end
FROM NashVillaHousing
order by SoldAsVacant

update NashVillaHousing 
set SoldAsVacant = 
case when SoldAsVacant = 'Y'then 'Yes'
     when SoldAsVacant = 'N'then 'No'
	 else SoldAsVacant
	 end


--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates records
-- Usually we do not delete records. for practise only

WITH CTE_RowNum as (
select * , 
ROW_NUMBER() over (
	PARTITION BY 
	ParcelID,
	SalePrice,
	LegalReference
	ORDER BY UniqueID
	) rowNum

From NashVillaHousing
)

delete from NashvillaHousing
where [UniqueID ] in (
Select [UniqueID ] From CTE_RowNum
Where rowNum > 1 );


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns 
-- OwnerAddress -> split 
-- ProprtyAddress -> split 
-- SaleDate -> split 
-- TaxDistrict -> redundant 

select * from NashvillaHousing

ALTER TABLE NashvillaHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


