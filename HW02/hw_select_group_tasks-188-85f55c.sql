/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

TODO: select StockItemID, StockItemName
	  from Warehouse.StockItems
	  where StockItemName like '%urgent%' or StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

TODO: select s.SupplierID, s.SupplierName
	  from Purchasing.Suppliers as s
	  left join  Purchasing.PurchaseOrders as p
		on s.SupplierID = p.SupplierID
	  where p.SupplierID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

TODO: select o.orderid, format(o.OrderDate, 'dd.MM.yyyy') as orderdate,
	  datename (month, o.orderdate) as месяц, datepart (q, o.orderdate) as квартал,
	  case when month(o.orderdate) in (1,2,3,4) then 1
		   when month(o.orderdate) in (5,6,7,8) then 2
		   else 3 end as треть,
	  c.CustomerName
	  from Sales.Orders as o
	  inner join Sales.Customers as c
	   on c.CustomerID = o.CustomerID
	  inner join sales.OrderLines as ol
	   on ol.orderid = o.OrderID
	  where ol.UnitPrice > 100 or (ol.Quantity > 20 and ol.PickingCompletedWhen is not null)
	  order by квартал, треть, o.OrderDate
	  offset  1000 rows fetch next 100 rows only
	
/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

TODO: select dm.DeliveryMethodName, po.ExpectedDeliveryDate, s.[SupplierName], p.FullName
      from [Application].[DeliveryMethods] as dm
	  join  [Purchasing].[PurchaseOrders] as po
		on po.DeliveryMethodID = dm.DeliveryMethodID
	  join [Purchasing].[Suppliers] as s
		on s.SupplierID = po.SupplierID
	  join [Application].[People] as p
		on p.PersonID = po.ContactPersonID
	  where month(po.ExpectedDeliveryDate) = 1 
	  and dm.DeliveryMethodName in ('Air Freight', 'Refrigerated Air Freight')
	  and po.IsOrderFinalized = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

TODO: SELECT TOP 10 c.CustomerName AS [Client], p.FullName AS [Employee], O.OrderDate
	  FROM Sales.Orders AS O
      INNER JOIN Sales.Customers AS c ON C.CustomerID = O.CustomerID
      INNER JOIN Application.People AS p ON p.PersonID = O.SalespersonPersonID
      ORDER BY O.OrderDate DESC
	  
/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

TODO: SELECT DISTINCT C.CustomerID AS [ClientId], C.CustomerName AS [ClientName], C.PhoneNumber
	  FROM Warehouse.StockItems AS I
	  INNER JOIN Sales.OrderLines AS OL ON OL.StockItemID = I.StockItemID
	  INNER JOIN Sales.Orders AS O ON O.OrderID = OL.OrderID
	  INNER JOIN Sales.Customers AS C ON C.CustomerID = O.CustomerID
	  WHERE I.StockItemName='Chocolate frogs 250g'