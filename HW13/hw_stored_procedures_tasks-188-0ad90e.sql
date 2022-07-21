/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

CREATE FUNCTION Sales.HighestPurchase()
RETURNS INT
AS
    BEGIN
        DECLARE @CustometID INT;
        WITH OrderAmount
            AS (SELECT il.InvoiceID, 
                         SUM(il.Quantity * ISNULL(il.UnitPrice, si.UnitPrice)) AS Amount
                FROM Sales.InvoiceLines il
                    INNER JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
                GROUP BY il.InvoiceID)
            SELECT TOP 1 @CustometID = c.CustomerID
            FROM Sales.Invoices i
                INNER JOIN OrderAmount oa ON i.InvoiceID = oa.InvoiceID
                INNER JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
            ORDER BY oa.Amount DESC;
        RETURN @CustometID;
    END;
GO

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

CREATE PROCEDURE Sales.GetCustomerTotalPurchaseAmount 
                @CustomerID INT
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT @CustomerId AS [CustomerId], 
        (
            SELECT SUM(il.Quantity * il.UnitPrice)
            FROM Sales.InvoiceLines il
                INNER JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
            WHERE i.CustomerID = @CustomerID
        ) AS [TotalAmount];
    END;
GO

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

CREATE FUNCTION Sales.GetCustomerTotalPurchaseAmountFunction
					(@CustomerId INT)
RETURNS MONEY
AS
    BEGIN
        RETURN
        (
            SELECT SUM(il.Quantity * il.UnitPrice)
            FROM Sales.InvoiceLines il
                INNER JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
            WHERE i.CustomerID = @CustomerID
        );
    END;
GO

-- Функция аналогична процедуре из задания №2. Разницы в производительности нет

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

-- Три последних собранных заказа сотрудником.
ALTER FUNCTION Sales.GetPackedInvoicesByPersonId(@PersonId INT)
RETURNS TABLE
AS
	RETURN(	
		SELECT TOP 3 i.InvoiceID
		FROM Sales.Invoices i
		WHERE i.PackedByPersonID = @PersonId
		ORDER BY i.InvoiceID, i.InvoiceDate DESC
	);
GO

-- Вызов функции.
SELECT p.PersonID, p.FullName, TopInvoices.InvoiceId
FROM Application.People p
CROSS APPLY (
	SELECT ti.InvoiceId
	FROM Sales.GetPackedInvoicesByPersonId(p.PersonId) ti
) AS TopInvoices
WHERE p.IsEmployee = 1

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
