USE WideWorldImporters
GO 

Create or alter Procedure dbo.defrecompile 
AS 
BEGIN 

-- utworzenie zmiennej tabelarycznej 

DECLARE @ilines TABLE 
	( 
	[InvoiceLineID] [int] NOT NULL primary key,
	[InvoiceID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[TaxAmount] [decimal](18, 2) NOT NULL,
	[LineProfit] [decimal](18, 2) NOT NULL,
	[ExtendedPrice] [decimal](18, 2) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL
	)

	-- zasilam zmienną tabelaryczną
	INSERT INTO @ilines select * from Sales.InvoiceLines

	--wylicz całkowity zysk dla klienta
	Select i.CustomerID, SUM(il.LineProfit) 
	FROM Sales.Invoices AS i
	INNER JOIN @ilines il
	ON i.InvoiceID = il.InvoiceID
	group by i.CustomerID

END;