--Nashville Housing Data Cleaning--

Select *
From dbo.NashvilleHousing

--Date formatting--

Select SaleDate, CONVERT(Date,SaleDate) AS Date
From dbo.NashvilleHousing

--Property Address Data--

Select *
From dbo.NashvilleHousing
Order by ParcelID


Select a.ParcelID, A.PropertyAddress, B.ParcelID, b.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
From dbo.NashvilleHousing A
JOIN dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is NULL


Update A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From dbo.NashvilleHousing A
JOIN dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is NULL

--Splitting Address to Individual Columns--

Select PropertyAddress
From dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address1
From dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From dbo.NashvilleHousing

Select OwnerAddress
From dbo.NashvilleHousing

Select 
PARSENAME(REPLACE (OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE (OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE (OwnerAddress, ',', '.') , 1) 
From dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From dbo.NashvilleHousing



--Changing Y=Yes & N=No and No in "Sold as Vacant field"--

Select Distinct (SoldASVacant), Count(SoldAsVacant)
From dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE 
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


--Removing Duplicates--

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
		     PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
ORDER BY
		     UniqueID
			 ) row_num
From dbo.NashvilleHousing
)
--Delete
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From dbo.NashvilleHousing


--Deleting Unused Columns--

Select *
From dbo.NashvilleHousing

Alter Table dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict,PropertyAddress


Alter Table dbo.NashvilleHousing
Drop Column SaleDate

