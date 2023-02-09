
SELECT * FROM dbo.NashvilleHousing

--standardize date format--

select SaleDateConverted , convert(date,SaleDate) FROM ProjectPortfolio.dbo.NashvilleHousing

update NashvilleHousing set SaleDate = convert(date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted =convert(date,SaleDate)

--populate property address--

select *
FROM ProjectPortfolio.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select p1.ParcelID,p1.PropertyAddress,p2.ParcelID,p2.PropertyAddress isnull(p1.propertyAddress,p2.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvilleHousing as p1
join ProjectPortfolio.dbo.NashvilleHousing as p2
	on p1.parcelID=p2.ParcelID
	and p1.UniqueID <> p2.UniqueID
where p1.PropertyAddress is null

update p1
set PropertyAddress =isnull(p1.propertyAddress,p2.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvilleHousing as p1
join ProjectPortfolio.dbo.NashvilleHousing as p2
	on p1.parcelID=p2.ParcelID
	and p1.UniqueID <> p2.UniqueID
where p1.propertyAddress is null

--breaking out address  into individual columns (addresss,city,state)--

select PropertyAddress
FROM ProjectPortfolio.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address
, substring(PropertyAddress,charindex(',',PropertyAddress)+1, len(PropertyAddress)) as Address

FROM ProjectPortfolio.dbo.NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)


alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress,charindex(',',PropertyAddress)+1, len(PropertyAddress))

select * FROM ProjectPortfolio.dbo.NashvilleHousing

select
parsename(replace(OwnerAddress,',','.'),3)
,parsename(replace(OwnerAddress,',','.'),2)
,parsename(replace(OwnerAddress,',','.'),1)
FROM ProjectPortfolio.dbo.NashvilleHousing

select substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address
, substring(PropertyAddress,charindex(',',PropertyAddress)+1, len(PropertyAddress)) as Address

FROM ProjectPortfolio.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)


alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)


alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1)

-- changing Y and N to Yes and No in "sold as vacant" column--

select distinct(SoldAsVacant),count(SoldAsVacant)
FROM ProjectPortfolio.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	end
FROM ProjectPortfolio.dbo.NashvilleHousing

update ProjectPortfolio.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	end

-- Removing Duplicates--

with RowNumCTE as(
select *,
	row_number() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num

FROM ProjectPortfolio.dbo.NashvilleHousing
--order by ParcelID
)

SELECT *
FROM RowNumCTE
where row_num>1
order by PropertyAddress

SELECT * FROM ProjectPortfolio.dbo.NashvilleHousing

-- deleting some unused columns--

select * from ProjectPortfolio.dbo.NashvilleHousing

alter table ProjectPortfolio.dbo.NashvilleHousing
drop column OwnerAddress,TaxDistrict, propertyAddress

alter table ProjectPortfolio.dbo.NashvilleHousing
drop column SaleDate