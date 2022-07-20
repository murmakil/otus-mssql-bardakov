/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

CREATE TABLE #tempAdded (
	CustomerId INT PRIMARY KEY
);

INSERT INTO Sales.Customers (
		CustomerID
		, CustomerName
		, BillToCustomerId
		, CustomerCategoryID
		, PrimaryContactPersonID
		, DeliveryMethodID
		, DeliveryCityID
		, PostalCityID
		, AccountOpenedDate
		, StandardDiscountPercentage
		, IsStatementSent
		, IsOnCreditHold
		, PaymentDays
		, PhoneNumber
		, FaxNumber
		, WebsiteURL
		, DeliveryAddressLine1
		, DeliveryPostalCode
		, PostalAddressLine1
		, PostalPostalCode
		, LastEditedBy)
OUTPUT inserted.CustomerId INTO #tempAdded 
VALUES (NEXT VALUE FOR Sequences.CustomerID -- Customer Id
	, 'Supernic3 HomeWork #2 (#1 Row)' -- CustomerName
	, 1 -- BillToCustomerId
	, 3 -- CustomerCategoryId
	, 1001 -- PrimaryContactPersonId
	, 3 -- DeliveryMethodID
	, 15 -- DeliveryCityId
	, 15 -- PostalCityId
	, '20190529' -- Account Opened Date
	, 0.0 -- Standard Discount Percentage
	, 0 -- IsStatementSent
	, 0 -- IsOnCreditHold
	, 7 -- PaymentDays
	, '(977) 555-66-66' -- PhoneNumber
	, '(977) 555-66-55' -- FaxNumber
	, 'http://supernic3.homework' -- WebsiteURL
	, 'Shop 10' -- DeliveryAddressLine1
	, 90002 -- DeliveryPostalCode
	,' PO Box 101' -- PostalAddressLine1
	, 90002 -- PostalPostalCode
	, 15) -- LastEditedBy 

	-- #2
	, (NEXT VALUE FOR Sequences.CustomerID -- Customer Id
	, 'Supernic3 HomeWork #2 (#2 Row)' -- CustomerName
	, 1 -- BillToCustomerId
	, 3 -- CustomerCategoryId
	, 1001 -- PrimaryContactPersonId
	, 3 -- DeliveryMethodID
	, 15 -- DeliveryCityId
	, 15 -- PostalCityId
	, '20190529' -- Account Opened Date
	, 0.0 -- Standard Discount Percentage
	, 0 -- IsStatementSent
	, 0 -- IsOnCreditHold
	, 7 -- PaymentDays
	, '(977) 555-66-66' -- PhoneNumber
	, '(977) 555-66-55' -- FaxNumber
	, 'http://supernic3.homework' -- WebsiteURL
	, 'Shop 10' -- DeliveryAddressLine1
	, 90002 -- DeliveryPostalCode
	,' PO Box 101' -- PostalAddressLine1
	, 90002 -- PostalPostalCode
	, 15) -- LastEditedBy

	-- #3
	, (NEXT VALUE FOR Sequences.CustomerID -- Customer Id
	, 'Supernic3 HomeWork #2 (#3 Row)' -- CustomerName
	, 1 -- BillToCustomerId
	, 3 -- CustomerCategoryId
	, 1001 -- PrimaryContactPersonId
	, 3 -- DeliveryMethodID
	, 15 -- DeliveryCityId
	, 15 -- PostalCityId
	, '20190529' -- Account Opened Date
	, 0.0 -- Standard Discount Percentage
	, 0 -- IsStatementSent
	, 0 -- IsOnCreditHold
	, 7 -- PaymentDays
	, '(977) 555-66-66' -- PhoneNumber
	, '(977) 555-66-55' -- FaxNumber
	, 'http://supernic3.homework' -- WebsiteURL
	, 'Shop 10' -- DeliveryAddressLine1
	, 90002 -- DeliveryPostalCode
	,' PO Box 101' -- PostalAddressLine1
	, 90002 -- PostalPostalCode
	, 15) -- LastEditedBy

	-- #4
	, (NEXT VALUE FOR Sequences.CustomerID -- Customer Id
	, 'Supernic3 HomeWork #2 (#4  Row)' -- CustomerName
	, 1 -- BillToCustomerId
	, 3 -- CustomerCategoryId
	, 1001 -- PrimaryContactPersonId
	, 3 -- DeliveryMethodID
	, 15 -- DeliveryCityId
	, 15 -- PostalCityId
	, '20190529' -- Account Opened Date
	, 0.0 -- Standard Discount Percentage
	, 0 -- IsStatementSent
	, 0 -- IsOnCreditHold
	, 7 -- PaymentDays
	, '(977) 555-66-66' -- PhoneNumber
	, '(977) 555-66-55' -- FaxNumber
	, 'http://supernic3.homework' -- WebsiteURL
	, 'Shop 10' -- DeliveryAddressLine1
	, 90002 -- DeliveryPostalCode
	,' PO Box 101' -- PostalAddressLine1
	, 90002 -- PostalPostalCode
	, 15) -- LastEditedBy

	-- #5
	, (NEXT VALUE FOR Sequences.CustomerID -- Customer Id
	, 'Supernic3 HomeWork #2 (#5  Row)' -- CustomerName
	, 1 -- BillToCustomerId
	, 3 -- CustomerCategoryId
	, 1001 -- PrimaryContactPersonId
	, 3 -- DeliveryMethodID
	, 15 -- DeliveryCityId
	, 15 -- PostalCityId
	, '20190529' -- Account Opened Date
	, 0.0 -- Standard Discount Percentage
	, 0 -- IsStatementSent
	, 0 -- IsOnCreditHold
	, 7 -- PaymentDays
	, '(977) 555-66-66' -- PhoneNumber
	, '(977) 555-66-55' -- FaxNumber
	, 'http://supernic3.homework' -- WebsiteURL
	, 'Shop 10' -- DeliveryAddressLine1
	, 90002 -- DeliveryPostalCode
	,' PO Box 101' -- PostalAddressLine1
	, 90002 -- PostalPostalCode
	, 15) -- LastEditedBy
	;

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM Sales.Customers WHERE CustomerID = (SELECT TOP 1 CustomerID FROM #tempAdded);


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE Sales.Customers SET CustomerName = 'Supernic3 - Updated second row'
WHERE CustomerID = (SELECT TOP 1 CustomerID FROM #tempAdded);

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE Sales.Customers AS [target]
USING ( 
	-- Creating unknown row
	SELECT 'Supernic3 - Not matched customer' AS [CustomerName]
	UNION
	-- Exists row
	SELECT 'Supernic3 HomeWork #2 (#4  Row)' AS [CustomerName]
) AS source
ON [target].CustomerName = source.CustomerName
WHEN MATCHED
	THEN UPDATE SET CustomerName = source.CustomerName + ' Matched'
WHEN NOT MATCHED THEN
	INSERT (
		CustomerID
		, CustomerName
		, BillToCustomerId
		, CustomerCategoryID
		, PrimaryContactPersonID
		, DeliveryMethodID
		, DeliveryCityID
		, PostalCityID
		, AccountOpenedDate
		, StandardDiscountPercentage
		, IsStatementSent
		, IsOnCreditHold
		, PaymentDays
		, PhoneNumber
		, FaxNumber
		, WebsiteURL
		, DeliveryAddressLine1
		, DeliveryPostalCode
		, PostalAddressLine1
		, PostalPostalCode
		, LastEditedBy) 

	VALUES (123123123 -- Customer Id
		, source.CustomerName -- CustomerName from source
		, 1 -- BillToCustomerId
		, 3 -- CustomerCategoryId
		, 1001 -- PrimaryContactPersonId
		, 3 -- DeliveryMethodID
		, 15 -- DeliveryCityId
		, 15 -- PostalCityId
		, '20190529' -- Account Opened Date
		, 0.0 -- Standard Discount Percentage
		, 0 -- IsStatementSent
		, 0 -- IsOnCreditHold
		, 7 -- PaymentDays
		, '(977) 555-66-66' -- PhoneNumber
		, '(977) 555-66-55' -- FaxNumber
		, 'http://supernic3.homework' -- WebsiteURL
		, 'Shop 10' -- DeliveryAddressLine1
		, 90002 -- DeliveryPostalCode
		,' PO Box 101' -- PostalAddressLine1
		, 90002 -- PostalPostalCode
		, 15); -- LastEditedBy

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

EXEC sp_configure 'show advanced options', 1;  
GO

EXEC sp_configure 'xp_cmdshell', 1;  
GO 

RECONFIGURE;  
GO  


EXEC master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.Customers" out "C:\TestBCP\SalesCustomers.data" -T -w -t, -S WIN-J45VF4KNL0T'
GO

BEGIN TRAN

SELECT *  INTO [WideWorldImporters].Sales.Customers2 FROM [WideWorldImporters].Sales.Customers WHERE 1 = 2

BULK INSERT [WideWorldImporters].Sales.Customers2
	FROM "C:\TestBCP\SalesCustomers.data"
	WITH 
	(
		BATCHSIZE = 1000, 
		DATAFILETYPE = 'widechar',
		FIELDTERMINATOR = '#',
		ROWTERMINATOR ='\n',
		KEEPNULLS,
		TABLOCK,
		CODEPAGE=65001
	);

ROLLBACK TRAN