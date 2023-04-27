--cleaning data

--Standardize Date Format

Select SaleDate, Convert(Date,SaleDate)
From Practice..Housing

Update Housing
Set SaleDate =  Convert(Date,SaleDate)

--Populate Property Address Data

Select p.ParcelID,p.PropertyAddress, isnull(p.PropertyAddress,q.PropertyAddress)
From Practice..Housing as p
join Practice..Housing as q
on p.ParcelID = q.ParcelID
and p.UniqueID <> q.UniqueID
Where p.PropertyAddress is null
order by ParcelID

Update p
set PropertyAddress = isnull(p.PropertyAddress,q.PropertyAddress)
From Practice..Housing as p
join Practice..Housing as q
on p.ParcelID = q.ParcelID
and p.UniqueID <> q.UniqueID


--Breaking out Address into seperate columns

Select PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Street
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
From Practice.dbo.Housing


--adding street and city columns into table

ALTER TABLE Housing
ADD PropertyStreet nvarchar(200);

UPDATE Housing
SET PropertyStreet = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Housing
ADD PropertyCity nvarchar(200);

UPDATE Housing
SET PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


Select PARSENAME(REPLACE(OwnerAddress,',','.'),1) as OwnerAddressState
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerAddressCity
,PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerAddressStreet
From Practice.dbo.Housing

ALTER TABLE Housing
ADD OwnerAddressState nvarchar(200);

UPDATE Housing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

ALTER TABLE Housing
ADD OwnerAddressCity nvarchar(200);

UPDATE Housing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Housing
ADD OwnerAddressStreet nvarchar(200);

UPDATE Housing
SET OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

--Changing y and n to yes and no 
SELECT SoldAsVacant,
CASE
WHEN SoldAsVacant = 'N' THEN 'No'
WHEN SoldAsVacant = 'Y' THEN 'Yes'
ELSE SoldAsVacant
END as SoldAsVacants
FROM Housing

UPDATE Housing 
SET SoldAsVacant = CASE
WHEN SoldAsVacant = 'N' THEN 'No'
WHEN SoldAsVacant = 'Y' THEN 'Yes'
ELSE SoldAsVacant
END

--Removing Duplicates
WITH DUP AS(
SELECT *, ROW_NUMBER()OVER(PARTITION BY Parcelid,
										SalePrice,
										SaleDate,
										LegalReference 
										ORDER BY UniqueID) AS A
FROM Housing
)
SELECT *
FROM DUP
WHERE A > 1

--Deleting unused columns

ALTER TABLE Housing
DROP COLUMN SaleDate,OwnerAddress,PropertyAddress

