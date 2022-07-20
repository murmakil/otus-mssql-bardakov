/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

DECLARE @CustomerNames NVARCHAR(MAX);
SET @CustomerNames =
(
    SELECT
			'[' + c.CustomerName + ']' + ',' as 'data()'
	FROM
		(
			SELECT DISTINCT CustomerName
			FROM [Sales].[Customers] c
		) c
	FOR XML PATH ('')
);

IF @CustomerNames IS NOT NULL
BEGIN
	SET @CustomerNames = LEFT(@CustomerNames, LEN(@CustomerNames) - 1);
END

DECLARE @PivotSQL NVARCHAR(MAX) = 'SELECT 
    InvoiceMonth, ' + @CustomerNames + '
FROM
    (
    SELECT 
        Dates.InvoiceMonth, 
        c.CustomerName, 
        I.InvoiceID
    FROM Sales.Customers AS C
    INNER JOIN Sales.Invoices AS I
        ON I.CustomerID = C.CustomerID
    CROSS APPLY
        (
            SELECT 
            InvoiceMonth = FORMAT(DATEADD(MM, DATEDIFF(MM, 0, I.InvoiceDate), 0), ''dd.MM.yyyy'')
        ) AS Dates
    ) AS D PIVOT(COUNT(D.[InvoiceID]) FOR D.CustomerName IN(' + @CustomerNames + ')) AS P
ORDER BY 
    CAST(P.InvoiceMonth AS DATE);'

EXECUTE sp_executesql @PivotSQL;