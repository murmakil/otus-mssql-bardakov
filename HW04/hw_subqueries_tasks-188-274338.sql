/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

TODO: with cte as (
	  select distinct SalespersonPersonID from sales.Invoices
      where InvoiceDate = '20150704')
	  select personid, fullname
	  from Application.People
	  where IsSalesperson = 1 and PersonID not in (select * from cte)

	  select p.personid, p.fullname
	  from Application.People as p
	  where p.IsSalesperson = 1 and not exists (
	  select 1 from sales.Invoices as i where i.SalespersonPersonID = p.PersonID and i.InvoiceDate = '20150704')

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

TODO: select distinct stockitemid, StockItemName, unitprice
	  from Warehouse.StockItems where UnitPrice = (select min(unitprice) from  Warehouse.StockItems)

	  ;WITH MinPrice
AS (SELECT TOP 1 si.UnitPrice
    FROM Warehouse.StockItems si
    ORDER BY si.UnitPrice ASC)
SELECT si.StockItemID, 
    si.StockItemName, si.UnitPrice
FROM Warehouse.StockItems si
WHERE si.UnitPrice = (
    SELECT mp.UnitPrice
    FROM MinPrice mp)

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

TODO: with cte as (select distinct top(5) * from Sales.CustomerTransactions
                   order by TransactionAmount desc)
	 select c.* from sales.customers as c
	 join cte on cte.CustomerID = c.CustomerID

	 SELECT c.*
FROM Sales.Customers c
     INNER JOIN Sales.CustomerTransactions ct ON c.CustomerID = ct.CustomerID
WHERE ct.TransactionAmount IN
(SELECT DISTINCT TOP 5 ct2.TransactionAmount
 FROM Sales.CustomerTransactions ct2
 ORDER BY ct2.TransactionAmount DESC)

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

TODO: SELECT c2.CityID, c2.CityName, p.FullName
FROM Sales.OrderLines ol
     INNER JOIN Sales.Orders o ON ol.OrderID = o.OrderID
     INNER JOIN Sales.Invoices i ON o.OrderID = i.OrderID
     INNER JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
     INNER JOIN Application.Cities c2 ON c.DeliveryCityID = c2.CityID
     INNER JOIN Application.People p ON i.PackedByPersonID = p.PersonID
WHERE ol.StockItemID IN
(
    SELECT TOP 3 si.StockItemID
    FROM Warehouse.StockItems si
    ORDER BY si.UnitPrice DESC
);

WITH TopProducts AS (
	SELECT TOP 3 si.StockItemID
    FROM Warehouse.StockItems si
    ORDER BY si.UnitPrice DESC
)
SELECT c2.CityID, c2.CityName, p.FullName
FROM Sales.OrderLines ol
     INNER JOIN Sales.Orders o ON ol.OrderID = o.OrderID
     INNER JOIN Sales.Invoices i ON o.OrderID = i.OrderID
     INNER JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
     INNER JOIN Application.Cities c2 ON c.DeliveryCityID = c2.CityID
     INNER JOIN Application.People p ON i.PackedByPersonID = p.PersonID
WHERE ol.StockItemID IN (SELECT tp.StockItemID FROM TopProducts tp)

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: напишите здесь свое решение
