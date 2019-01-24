--1
CREATE DATABASE Store;

--2
use Store;
CREATE TABLE Customer (
    CustomerId int not null IDENTITY(1,1) PRIMARY KEY,
    Nume varchar(100) NOT NULL,
    Email varchar(100)
);

Create table Employee
(
	EmployeeId int not null identity(1,1) primary key,
	Nume varchar(100),
	Email varchar(100)
);

Create table Category
(
	CategoryId int not null identity(1,1) primary key,
	Nume varchar(100),
	EmployeeId int not null

	constraint fk_Category_Employee
	foreign key (EmployeeId)
	references Employee (EmployeeId)
);



Create table Product
(
	ProductId int not null identity(1,1) primary key,
	Nume varchar(100),
	CategoryId int not null,
	[Description] varchar(100),
	Price int

	constraint fk_Product_Category
	foreign key (CategoryId)
	references Category (CategoryId),
);

Create table [Order]
(
	OrderId int not null identity(1,1) primary key,
	Numar int,
	[Data] DateTime,
	CustomerId int,
	[Status] varchar(100),
	TotalPrice int 

	constraint fk_Order_Customer
	foreign key (CustomerId)
	references Customer (CustomerId)
);

Create table OrderProduct
(
	OrderId int not null,
	ProductId int not null,
	NumberOfProducts int not null
	primary key (OrderId, ProductId)

	constraint fk_OrderProduct_Product
	foreign key (ProductId)
	references Product (ProductId),

	constraint fk_OrderProduct_Order
	foreign key (OrderId)
	references [Order] (OrderId)
);
--Customer
Insert into Customer values ('Monica', 'monica@wantsome.com');
Insert into Customer values ('Monica2', 'monica@yahoo.com');
Insert into Customer values ('Alina', 'alina@wantsome.com');
Insert into Customer values ('Georgiana', 'georgiana@wantsome.com');

--Employee
Insert into Employee values ('Employee1', 'employee@wantsome.com');
Insert into Employee values ('Employee2', 'employee@yahoo.com');
Insert into Employee values ('Employee3', 'employee@wantsome.com');
Insert into Employee values ('Employee4', 'employee@wantsome.com');

--Category
Insert into Category values ('Make-up', 1);
Insert into Category values ('Hair', 1);
Insert into Category values ('Food', 2);
Insert into Category values ('Imobiliare', 3);
Insert into Category values ('Mobilier', 4);

--Product
Insert into Product values ('Product1', 1,'test',20);
Insert into Product values ('Fond de ten', 1,'test',200);
Insert into Product values ('Eye-liner', 1,'test',15);
Insert into Product values ('Perie', 2,'test',50);
Insert into Product values ('Nachos', 3,'test',11.2);
Insert into Product values ('Apartament', 3,'test',600000);
Insert into Product values ('Noptiera', 4,'test',300);

--Order
Insert into [Order] values (1,GETDATE(),1,'pending',0);
Insert into [Order] values (2,GETDATE(),1,'pending',0);
Insert into [Order] values (3,GETDATE(),1,'pending',0);
Insert into [Order] values (4,GETDATE(),1,'pending',0);
Insert into [Order] values (5,GETDATE(),1,'pending',0);
Insert into [Order] values (6,GETDATE(),1,'pending',0);
Insert into [Order] values (7,GETDATE(),1,'pending',0);
Insert into [Order] values (8,GETDATE(),1,'pending',0);
Insert into [Order] values (9,GETDATE(),1,'pending',0);
Insert into [Order] values (10,GETDATE(),2,'pending',0);
Insert into [Order] values (11,GETDATE(),3,'pending',0);
Insert into [Order] values (12,GETDATE(),3,'pending',0);
Insert into [Order] values (13,GETDATE(),3,'pending',0);
Insert into [Order] values (14,GETDATE(),4,'pending',0);
Insert into [Order] values (15,GETDATE(),4,'pending',0);

--OrderProduct
Insert into OrderProduct values (1,1,2);
Insert into OrderProduct values (2,2,3);
Insert into OrderProduct values (3,3,4);
Insert into OrderProduct values (4,4,21);
Insert into OrderProduct values (5,5,1);
Insert into OrderProduct values (6,5,10);
Insert into OrderProduct values (7,6,12);
Insert into OrderProduct values (8,7,12);
Insert into OrderProduct values (9,1,23);
Insert into OrderProduct values (10,3,4);
Insert into OrderProduct values (11,4,7);
Insert into OrderProduct values (12,6,8);
Insert into OrderProduct values (13,2,9);
Insert into OrderProduct values (14,2,5);
Insert into OrderProduct values(1,2,10);

DBCC CHECKIDENT (Employee, RESEED, 0)

--4
Use Store;
Select * from Customer;

Select * from Employee;

Select * from Category;

Select * from Product;

Select * from OrderProduct;

Select * from [Order];

--5
Select * from Customer where Email LIKE '%@wantsome.com';

--6
Select SUM(Price) as Price from Product group by CategoryId;

--7

Select c.Nume from Customer c join [Order] o on c.CustomerId=o.CustomerId group by o.CustomerId, c.Nume
having count(o.CustomerId)>8;

--8
--Creati un view care va afisa toti clientii si produsele comandate 
--de acestia.

Drop view [Customers and Product];

CREATE VIEW [Customers and Product] AS
Select c.Nume as Customer, products.Nume, o.DateOfInsertion, products.CategoryId  from Customer c 
join [Order] o on c.CustomerId=o.CustomerId
join OrderProduct orderProducts on o.OrderId=orderProducts.OrderId
join Product products on products.ProductId=orderProducts.ProductId

Select * from [Customers and Product]

--9
--Folositi view-ul de la punctul precedent pentru a afisa:
--Clientii care au comandat produse in primele trei luni ale anului.
--Clientii care au comandat produse dintr-o anumita categorie.

Select * from [Customers and Product] c where c.DateOfInsertion<'2019-04-01' and c.DateOfInsertion>='2019-01-01'

Select * from [Customers and Product] c where c.CategoryId=1

--10
--Creati o procedura care va modifica statusul unui Order. 
--Aceasta procedura va updata si LastModifiedDate.

drop procedure dbo.uspGetAddress;

CREATE PROCEDURE dbo.ModifyStatus @orderId int , @status nvarchar(60)
AS
Update [Order] set Status=@Status, LastModifiedDate=GETDATE() where OrderId=@orderId

GO

exec dbo.ModifyStatus @orderId = 1, @status = 'approved'

Select * from [Order];


EXEC sp_RENAME '[Order].Data', 'DateOfInsertion', 'COLUMN'

--11
--Creati un raport (select cu group by) pentru a afisa vanzarile pentru fiecare produs in parte.

Select p.Nume, count(op.ProductId) as Vanzari from Product p 
join OrderProduct op on p.ProductId=op.ProductId
group by op.ProductId, p.Nume;


--12
--Creati o functie care va calcula pretul total pentru o anumita comanda.

DROP FUNCTION dbo.CalculatePrice; 

CREATE FUNCTION dbo.CalculatePrice (@orderId INT, @productId INT)
RETURNS INT
AS BEGIN
    DECLARE @nrOfProducts int
	Declare @price int
    SET @nrOfProducts = (Select op.NumberOfProducts from [Order] o
join orderProduct op on op.OrderId=o.OrderId
join Product p on op.ProductId=p.ProductId
where o.OrderId=@orderId and op.ProductId=@productId);
	set @price = (Select p.Price from [Order] o
join orderProduct op on op.OrderId=o.OrderId
join Product p on op.ProductId=p.ProductId
where o.OrderId=@orderId and op.ProductId=@productId);
    RETURN @price* @nrofProducts;
END

Select o.OrderId, op.ProductId, op.NumberOfProducts, p.Price ,dbo.CalculatePrice (o.OrderId, op.ProductId) as ValueOfOrder
from [Order] o
join orderProduct op on op.OrderId=o.OrderId
join Product p on op.ProductId=p.ProductId;
 
 --13
 --Order Audit Table - OrderId, CustomerId, DateTime. - insert trigger
 drop table [audit];
 Create TABLE [Audit](
	OrderId INT,
	CustomerId INT,
	InsertDateTime DateTime,
	ApprovedDateTime DateTime
	
	constraint fk_Audit_Order
	foreign key (OrderId)
	references [Order] (OrderId),

	constraint fk_Audit_Customer
	foreign key (CustomerId)
	references Customer(CustomerId)
	) 

Select * from Audit;

Select * from [Order];

Insert into [Order] values (16,GETDATE(),4,'pending',0,null);

Drop trigger afterInsertInOrderTable;

create trigger afterInsertInOrderTable on [Order]
after insert  
as 
begin
	Insert into Audit(OrderId,CustomerId,InsertDateTime)
	select i.OrderId, i.CustomerId, getdate() from inserted i;

	PRINT 'AFTER INSERT trigger fired.'
end
go

 --14
--Order Audit - Cand order-ul are status approved = update pe coloana approvedat in audit table. update trigger


Select * from [Order];

drop trigger AfterUpdateStatusOnOrder;


create trigger AfterUpdateStatusOnOrder on [Order]
after update  
as 
	declare @status varchar(100);	
	declare @orderId INT;
	declare @count INT;

	select @status=i.[Status] from inserted i;	
	select @orderId=i.OrderId from inserted i;
		
	if @status='approved'
	begin 
		select @count= count(*) from audit where [Audit].OrderId=@orderId;
		if @count >0
		Begin
			Update [Audit] set ApprovedDateTime=getDate()
			where [Audit].OrderId=@orderId;
			PRINT 'AFTER UPDATE trigger fired and update in Audit table.' 
		end
		else
		begin		
			Insert into Audit(OrderId,CustomerId,InsertDateTime, ApprovedDateTime)
			select i.OrderId, i.CustomerId, getdate(), getdate() from inserted i;
			PRINT 'AFTER UPDATE trigger fired and insert in Audit table.'
		end
	end
go

exec dbo.ModifyStatus @orderId = 16, @status = 'approved'

Select * from [Order];

Select * from [Audit];