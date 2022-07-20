/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

DECLARE @Sql NVARCHAR(MAX);
DECLARE @FilePath NVARCHAR(256) = 'D:\StockItems.xml';
SET @Sql = '
	MERGE [Warehouse].[StockItems] AS target
	USING
	(
		SELECT 
			[Name] = MY_XML.Item.value(''@Name'', ''nvarchar(100)''),
			[SupplierID] = MY_XML.Item.value(''SupplierID[1]'', ''int''),
			[UnitPackageID] = MY_XML.Item.value(''Package[1]/UnitPackageID[1]'', ''int''),
			[OuterPackageID] = MY_XML.Item.value(''Package[1]/OuterPackageID[1]'', ''int''),
			[QuantityPerOuter] = MY_XML.Item.value(''Package[1]/QuantityPerOuter[1]'', ''int''),
			[TypicalWeightPerUnit] = MY_XML.Item.value(''Package[1]/TypicalWeightPerUnit[1]'', ''decimal(18,3)''),
			[LeadTimeDays] = MY_XML.Item.value(''LeadTimeDays[1]'', ''int''),
			[IsChillerStock] = MY_XML.Item.value(''IsChillerStock[1]'', ''bit''),
			[TaxRate] = MY_XML.Item.value(''TaxRate[1]'', ''decimal(18,3)''),
			[UnitPrice] = MY_XML.Item.value(''UnitPrice[1]'', ''decimal(18,2)'')
					FROM
					(
						SELECT cast(MY_XML AS xml)
						FROM OPENROWSET( BULK N'''+ @FilePath +''', SINGLE_BLOB ) AS T(MY_XML)
					) AS T(MY_XML)
					CROSS APPLY MY_XML.nodes(''StockItems/Item'') AS MY_XML (Item)
				) AS source ([Name], [SupplierID], [UnitPackageID], [OuterPackageID], [QuantityPerOuter], [TypicalWeightPerUnit], [LeadTimeDays], [IsChillerStock], [TaxRate], [UnitPrice])
				ON (target.[StockItemName] = source.[Name])
				WHEN MATCHED
				THEN 
					UPDATE SET
						target.[SupplierID] = source.[SupplierID],
						target.[UnitPackageID] = source.[UnitPackageID],
						target.[OuterPackageID] = source.[OuterPackageID],
						target.[QuantityPerOuter] = source.[QuantityPerOuter],
						target.[TypicalWeightPerUnit] = source.[TypicalWeightPerUnit],
						target.[LeadTimeDays] = source.[LeadTimeDays],
						target.[IsChillerStock] = source.[IsChillerStock],
						target.[TaxRate] = source.[TaxRate],
						target.[UnitPrice] = source.[UnitPrice]
				WHEN NOT MATCHED
				THEN 
					INSERT ([StockItemName],
							[SupplierID],
							[UnitPackageID],
							[OuterPackageID],
							[QuantityPerOuter],
							[TypicalWeightPerUnit],
							[LeadTimeDays],
							[IsChillerStock],
							[TaxRate],
							[UnitPrice],
							[LastEditedBy]
						)
					VALUES (source.[Name],
							source.[SupplierID],
							source.[UnitPackageID],
							source.[OuterPackageID],
							source.[QuantityPerOuter],
							source.[TypicalWeightPerUnit],
							source.[LeadTimeDays],
							source.[IsChillerStock],
							source.[TaxRate],
							source.[UnitPrice],
							2
						);
			';
			PRINT @Sql;

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

DECLARE @dataQuery nvarchar(max) = '
SELECT [@Name] = [StockItemName], 
    [Package] = (CAST(
(
    SELECT [UnitPackageID], 
        [OuterPackageID], 
        [QuantityPerOuter], 
        [TypicalWeightPerUnit]
    FROM [Warehouse].[StockItems] sip
    WHERE si.[StockItemID] = sip.[StockItemID] FOR XML PATH('''')
) AS XML)), 
    [LeadTimeDays], 
    [IsChillerStock], 
    [TaxRate], 
    [UnitPrice]
FROM [Warehouse].[StockItems] si FOR XML PATH(''''Item''''), ROOT(''''StockItems'''');';

DECLARE @bcpQuery nvarchar(max) = 'EXEC xp_cmdshell ''bcp "'+ @dataQuery +'" QUERYOUT "C:\OTUS\StockItems2.xml" -T -c -t''';
EXEC sp_executesql @bcpQuery;


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT 
	StockItemID,
	StockItemName,
	CustomFields,
	JSON_VALUE(CustomFields, '$.CountryOfManufacture') as CountryOfManufacture,
	IIF( LEN( split.[FirstTag] ) > 1, 
		split.[FirstTag], NULL) as [FirstTag],
	JSON_VALUE(CustomFields, '$.Range') as [Range]
FROM Warehouse.StockItems
CROSS APPLY(
	SELECT TOP 1 
		REPLACE( REPLACE( REPLACE(value,'[','') ,']','')  ,'"','') as [FirstTag]
	FROM
		STRING_SPLIT( JSON_QUERY(CustomFields, '$.Tags') , ',')
) split
/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

SELECT si.*
FROM [Warehouse].[StockItems] si
CROSS APPLY OPENJSON(CustomFields, '$.Tags')
WHERE Value = 'Vintage';
