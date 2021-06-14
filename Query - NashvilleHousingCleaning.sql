/*
	Cleaning data with SQL Queries
*/


Select *
From PortfolioProject.dbo.NashvilleHousing;


-- Standardize date format

Select SaleDate, CONVERT(DATE, SaleDate)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateFormatted DATE

UPDATE NashvilleHousing
SET SaleDateFormatted = CONVERT(DATE, SaleDate);


-- Populate property address data

Select *
From PortfolioProject..NashvilleHousing
Order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is NULL;


-- Breaking out address into individual columns (Address | City | State)

Select PropertyAddress, OwnerAddress
From PortfolioProject..NashvilleHousing;

Select PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2) as PStreet,
	PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1) as PCity,

	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OStreet,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OCity,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OState
From PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertyStreet Nvarchar(255), PropertyCity Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerStreet Nvarchar(255), OwnerCity Nvarchar(255), OwnerState Nvarchar(255)

UPDATE NashvilleHousing
SET PropertyStreet = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2),
	PropertyCity = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)

UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject..NashvilleHousing


-- Changing 'Y'/'N' responses to 'Yes'/'No' in "Sold as vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant, CASE
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-- Remove Duplicates

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
From NashvilleHousing
)

DELETE
From RowNumCTE
Where row_num > 1

Select *
From NashvilleHousing


-- Delete unused columns

Select *
From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate