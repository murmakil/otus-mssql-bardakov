/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

SELECT i.InvoiceID, 
    c.CustomerName, 
    i.InvoiceDate, 
(
    SELECT SUM(il.Quantity * il.UnitPrice)
    FROM Sales.InvoiceLines AS il
    WHERE il.InvoiceID = i.InvoiceID
) AS [OrderSum], 
(
    SELECT SUM(il2.Quantity * il2.UnitPrice)
    FROM Sales.InvoiceLines AS il2
        INNER JOIN Sales.Invoices AS i2 ON il2.InvoiceID = i2.InvoiceID
    WHERE i2.InvoiceDate <= EOMONTH(i.InvoiceDate)
        AND i2.InvoiceDate >= '20150101' AND i2.InvoiceDate < '20160101'
) [CumulativeTotal]
FROM Sales.Invoices AS i
    INNER JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
    INNER JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
WHERE i.InvoiceDate >= '20150101' AND i.InvoiceDate < '20160101'
ORDER BY i.InvoiceDate, i.InvoiceID ;
--Время работы SQL Server:
   --Время ЦП = 52891 мс, затраченное время = 54851 мс.

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

select  i.InvoiceID, c.CustomerName, i.InvoiceDate, sum (il.unitprice * il.quantity) over (partition by i.invoiceid) as ordersum
, SUM(il.Quantity * il.UnitPrice) OVER (ORDER BY DATEPART(YEAR, i.InvoiceDate), DATEPART(MONTH, i.InvoiceDate)) [CumulativeTotal]
from Sales.Invoices as i
join Sales.Customers as c
 on c.CustomerID = i.CustomerID
join Sales.InvoiceLines as il
 on il.InvoiceID = i.InvoiceID
where i.InvoiceDate >= '20150101' AND i.InvoiceDate < '20160101'

--Время работы SQL Server:
   -- ЦП = 468 мс, затраченное время = 1796 мс.

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

WITH ProductMonthSales
AS (
    SELECT si.StockItemName, 
        SUM(il.Quantity) AS [TotalQuantity], 
        MONTH(i.InvoiceDate) AS [MonthNumber]
    FROM Sales.InvoiceLines il
        INNER JOIN [Sales].[Invoices] i ON il.InvoiceID = i.InvoiceID 
        INNER JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
	WHERE YEAR(i.InvoiceDate) = 2016
    GROUP BY si.StockItemName, MONTH(i.InvoiceDate)
),
ProductSalesNumbered
AS (
    SELECT ProductMonthSales.StockItemName, 
        ProductMonthSales.TotalQuantity, 
        ProductMonthSales.MonthNumber, 
        ROW_NUMBER() OVER(PARTITION BY ProductMonthSales.MonthNumber ORDER BY ProductMonthSales.TotalQuantity DESC) AS [Num]
    FROM ProductMonthSales
)
SELECT psm.StockItemName, psm.TotalQuantity
FROM ProductSalesNumbered psm
WHERE psm.Num <= 2
ORDER BY psm.MonthNumber, psm.TotalQuantity DESC;

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT si.StockItemID, 
    si.StockItemName, 
    si.Brand, 
    ROW_NUMBER() OVER(PARTITION BY LEFT(si.StockItemName, 1) ORDER BY si.StockItemName) [NumbererFirstChar], 
    COUNT(*) OVER() [TotalCount], 
    COUNT(*) OVER(PARTITION BY LEFT(si.StockItemName, 1)) [TotalCountFirstChar], 
    LEAD(si.StockItemID) OVER(ORDER BY si.StockItemName) [NextId], 
    LAG(si.StockItemID) OVER(ORDER BY si.StockItemName) [PrevId], 
    LAG(si.StockItemName, 2, 'No items') OVER(ORDER BY si.StockItemName) [Prevx2Name],
    NTILE(30) OVER(ORDER BY si.TypicalWeightPerUnit) [GroupWeight]
FROM Warehouse.StockItems si
ORDER BY si.StockItemName;

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

SELECT p.PersonID, 
       p.FullName, 
       c.CustomerID, 
       c.CustomerName, 
       r.TransactionDate, 
       r.TransactionAmount
FROM
(
    SELECT ct.CustomerID, 
           i.SalespersonPersonID, 
           ct.TransactionDate, 
           ct.TransactionAmount, 
           ROW_NUMBER() OVER(PARTITION BY SalespersonPersonID ORDER BY TransactionDate DESC) AS [Num]
    FROM Sales.CustomerTransactions ct
         INNER JOIN Sales.Invoices i ON ct.InvoiceID = i.InvoiceID
) AS r
INNER JOIN Application.People p ON r.SalespersonPersonID = p.PersonID
INNER JOIN Sales.Customers c ON r.CustomerID = c.CustomerID
WHERE r.[num] = 1;

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT c.CustomerID, 
       c.CustomerName, 
       subq.StockItemID, 
       subq.StockItemName, 
       subq.UnitPrice, 
       subq.InvoiceDate
FROM
(
    SELECT i.CustomerID, 
           il.StockItemID, 
           si.StockItemName, 
           si.UnitPrice, 
           i.InvoiceDate, 
           ROW_NUMBER() OVER(PARTITION BY i.CustomerID ORDER BY si.UnitPrice DESC) AS [Num]
    FROM Sales.InvoiceLines il
         INNER JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
         INNER JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
) AS subq
INNER JOIN Sales.Customers c ON subq.CustomerID = c.CustomerID
WHERE subq.Num <= 2;

Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 