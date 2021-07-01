--Data cleaning in SQL Queries

Select * FROM PortfolioProject.dbo.[Nashville Housing]

--////////////////
--Standardize date format

Select SaleDateConverted, CONVERT(date,SaleDate)
FROM PortfolioProject.dbo.[Nashville Housing]

Update [Nashville Housing]
SET SaleDate = CONVERT(date,SaleDate)

ALTER table [Nashville Housing]
ADD SaleDateConverted date;

Update [Nashville Housing]
SET SaleDateConverted = CONVERT(date,SaleDate)
--/////////////////
--Populate Property Address Data

Select *
FROM PortfolioProject.dbo.[Nashville Housing]
--WHERE PropertyAddress is null
ORDER by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.[Nashville Housing] a
JOIN PortfolioProject.dbo.[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.[Nashville Housing] a
JOIN PortfolioProject.dbo.[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 
--/////////////////////////
--Breaking out Address into individual columns (Address, City, State) PropertyAddress

Select PropertyAddress
FROM PortfolioProject.dbo.[Nashville Housing]
--WHERE PropertyAddress is null
--ORDER by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.[Nashville Housing]

ALTER table [Nashville Housing]
ADD PropertySplitAddress Nvarchar(255);

Update [Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1)

ALTER table [Nashville Housing]
ADD PropertySplitCity Nvarchar(255);

Update [Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.[Nashville Housing]




--Breaking out Address into individual columns (Address, City, State) OwnerAddress

Select OwnerAddress
From PortfolioProject.dbo.[Nashville Housing]

Select
PARSENAME(Replace(OwnerAddress,',' , '.'), 3) -- address
, PARSENAME(Replace(OwnerAddress,',' , '.'), 2) -- city
, PARSENAME(Replace(OwnerAddress,',' , '.'), 1) -- state
From PortfolioProject.dbo.[Nashville Housing]



ALTER table [Nashville Housing]
ADD OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing]
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',' , '.'), 3)

ALTER table [Nashville Housing]
ADD OwnerSplitCity Nvarchar(255);

Update [Nashville Housing]
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',' , '.'), 2)

ALTER table [Nashville Housing]
ADD OwnerSplitState Nvarchar(255);

Update [Nashville Housing]
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',' , '.'), 1)

Select *
From PortfolioProject.dbo.[Nashville Housing]
--//////////////////////////
--Change Y and N to Yes and No in "Sold as Vacant" column


Select distinct (SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.[Nashville Housing]
Group by SoldAsVacant
Order by 2





SELECT SoldAsVacant
, Case When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From PortfolioProject.dbo.[Nashville Housing]

Update [Nashville Housing]
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
--////////////////////////
--Remove duplicates

With RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER by 
					UniqueID
					) row_num

From PortfolioProject.dbo.[Nashville Housing]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1 
order by PropertyAddress
--/////////////////////////
--Delete Unused Columns



Select *
From PortfolioProject.dbo.[Nashville Housing]

Alter table PortfolioProject.dbo.[Nashville Housing]
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

Alter table PortfolioProject.dbo.[Nashville Housing]
DROP Column SaleDate