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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: select year(i.invoicedate) as [Год продажи], month(i.invoicedate) as [Месяц продажи], avg(il.unitprice) as [Средняя цена], SUM(il.UnitPrice * il.Quantity) AS [Общая сумма]
	  from sales.invoices as i
	  join sales.invoicelines as il
	   on il.invoiceid = i.invoiceid
	  group by year(i.invoicedate),  month(i.invoicedate)
	  order by [Год продажи], [Месяц продажи]
/*
2. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: select year(i.invoicedate) as [Год продажи], month(i.invoicedate) as [Месяц продажи], SUM(il.UnitPrice * il.Quantity) as [Общая сумма]
	  from sales.invoices as i
	  join sales.invoicelines as il
	   on il.invoiceid = i.invoiceid
	  group by year(i.invoicedate), month(i.invoicedate)
	  having SUM(il.UnitPrice * il.Quantity) > 10000
	  order by [Год продажи], [Месяц продажи]
/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: select  year(i.invoicedate) as [Год продажи], month(i.invoicedate) as [Месяц продажи], il.Description as [Наименование товара], SUM(il.UnitPrice * il.Quantity) as [Cумма продаж], min(i.InvoiceDate) as [Дата первой продажи], sum(il.Quantity) as [Количество проданного]
	  from sales.invoices as i
	  join sales.invoicelines as il
	   on il.invoiceid = i.invoiceid
	  group by  year(i.invoicedate), month(i.invoicedate), il.Description
	  having sum(il.Quantity) < 50
	  order by [Год продажи], [Месяц продажи]
-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
