--dropping all the previously created tables

drop table customers cascade constraints;
drop table ProductCategories cascade constraints;
drop table products cascade constraints;
drop table orders cascade constraints;
drop table creditcards cascade constraints;
drop table invoices cascade constraints;
drop table reviews cascade constraints;
drop table recommendations cascade constraints;

--Dropping Previously created sequences
drop sequence customerid_seq;
drop sequence categoryID_seq;
drop sequence productID_seq;
drop sequence InvoiceID_seq;
drop sequence ReviewID_seq;
drop sequence RecommendationID_seq;
drop sequence Orderid_seq;

--Creating Sequences for Automatic ID Generation
create sequence categoryid_seq start with 1;
create sequence productid_seq start with 1;
create sequence Invoiceid_seq start with 1;
create sequence reviewid_seq start with 1;
create sequence recommendationid_seq start with 1;
create sequence customerid_seq start with 1;
create sequence orderid_seq start with 1;



--CUSTOMERS TABLE
CREATE TABLE customers(
  customerid int not null,
  name       varchar2(20),
  email      varchar2(50),
  city       varchar2(20),
  state      varchar2(20),
  zip        number,
 primary key (customerID)
);


--PRODUCTCATEGORIES TABLE
CREATE TABLE ProductCategories(
  categoryid    int not null,
  categoryname  varchar2(20),
  description   varchar2(100),
  primary key (categoryID)
); 


--PRODUCTS TABLE
CREATE TABLE products(
  productid         int not null,
  productname       varchar2(20),
  availablequantity number,
  unitprice         float,
  categoryid        int,
  primary key (productid),
  foreign key (categoryid) references ProductCategories(categoryid)
);


--ORDERS TABLE
CREATE TABLE orders(
  orderid      int not null,
  customerid   int,
  productid    int,
  quantity     int,
  orderdate    date,
  cc_number    number,
  primary key (orderid),
  foreign key (customerid) references customers(customerid),
  foreign key (productid) references products(productid)
);


--CREDITCARDS TABLE
CREATE TABLE creditcards(
  customerID        int,
  creditcard        number,
  creditcard_type   varchar2(15),
  expiration_year   number, 
  expiration_month  number, 
  primary key (creditcard),
  foreign key (customerid) references customers(customerid)
);


--INVOICES TABLE
CREATE TABLE invoices(
  invoiceid     int not null,
  orderid       int,
  customerid    int,
  creditcard   number(16),
  amount        number,
  primary key (invoiceid),
  foreign key (orderid) references orders(orderid),
  foreign key (customerid) references customers(customerid),
  foreign key (creditcard) references creditcards(creditcard)
);


--REVIEWS TABLE
CREATE TABLE reviews(
  reviewID        int not null,
  productID       int,
  reviewer_email  varchar2(20),
  starsgiven      number,
  review_text     varchar2(100),
  primary key (reviewID),
  foreign key (productID) references products(productID)
);


--RECOMMENDATIONS TABLE
CREATE TABLE recommendations(
  recommendationid           int not null,
  customerid                 int,
  recommendation_productid   int,
  primary key (recommendationid),
  foreign key (customerid) references customers(customerid)
);





--Memeber 1 Rishika Chamala
--Operation 1
--creating add customer procedure
create or replace procedure add_customer (
    p_name in customers.name%type,
    p_email in customers.email%type,
    p_city in customers.city%type,
    p_state in customers.state%type,
    p_zip in customers.zip%type,
    p_creditcard in creditcards.creditcard%type,
    p_creditcard_type in creditcards.creditcard_type%type,
    p_expiration_month in creditcards.expiration_month%type,
    p_expiration_year in creditcards.expiration_year%type
) as
  v_customerid number;
begin
  -- Get the next customerID from the sequence
  select customerid_seq.nextval into v_customerid from dual;
  
  insert into customers (customerid, name, email, city, state, zip)
  values (v_customerid, p_name, p_email, p_city, p_state, p_zip);
  
  insert into creditcards (customerid, creditcard, creditcard_type, expiration_month, expiration_year)
  values (v_customerid, p_creditcard, p_creditcard_type, p_expiration_month, p_expiration_year);
  
  commit;
  dbms_output.put_line('Customer added with ID: ' || v_customerid);
  dbms_output.put_line('Credit Card added with ID: ' || p_creditcard);
exception
  -- Output an error message if there is an exception
  when others then
    dbms_output.put_line('Error adding customer: ' || sqlerrm);
end;
/

--Calling the above Procedure to insert data
exec add_customer('John Smith', 'john@smith.com', 'Baltimore', 'MD', 21250, 12345, 'VISA', 10, 2023);
exec add_customer('Pat Wagner', 'pat@smith.com', 'Baltimore', 'MD', 21250, 12348, 'VISA', 10, 2025);
exec add_customer('Mary Poppins', 'mary@poppins.com', 'New York', 'NY', 12345, 45678, 'Discover', 11, 2023);
exec add_customer('Rajeev Kumar', 'rajeev@kumar.org', 'Columbia', 'SC', 44250, 45679, 'Discover', 10, 2023);
exec add_customer('Mary Smith', 'mary@smith.com', 'Baltimore', 'MD', 21250, 12346, 'VISA', 10, 2023);
exec add_customer('Johnny Smith', 'john@smith1.com', 'Baltimore', 'MD', 21250, 12347, 'VISA', 9, 2023);
exec add_customer('Johna Smith', 'john@smith2.com', 'Baltimore', 'MD', 21250, 34567, 'AMEX', 10, 2023);
exec add_customer('Johni Smith', 'john@smith3.com', 'Baltimore', 'MD', 21250, 23456, 'MC', 9, 2024);
exec add_customer('Joe Poppins', 'joe@poppins.com', 'New York', 'NY', 12345, 23457, 'MC', 9, 2024);


--Operation 2 
--creating show all customers in state procedure
create or replace procedure show_all_customers_in_state (
  p_state in varchar2
)
is
begin
  for c in (select customers.name, customers.email, customers.city, creditcards.creditcard, creditcards.creditcard_type
            from customers
            join creditcards on customers.customerid = creditcards.customerid
            where customers.state = p_state)
  loop
    dbms_output.put_line('Name: ' || c.name);
    dbms_output.put_line('Email: ' || c.email);
    dbms_output.put_line('Address: ' || c.city || ', ' || p_state);
    dbms_output.put_line('credit card: ' || c.creditcard ||' '|| 'type:' ||' '|| c.creditcard_type);
    dbms_output.put_line('-----------------------');
  end loop;
exception
  when others then
    dbms_output.put_line('An error occurred: ' || sqlcode || ' - ' || sqlerrm);
end;
/

--Calling the above Procedure to show customer details according the state given

exec show_all_customers_in_state ('NY');

--operation 4

CREATE OR REPLACE PROCEDURE Report_Cards_Expire(expire_date IN DATE)
AS
  v_customer_info VARCHAR2(1000);
BEGIN
  FOR c IN (
    SELECT customers.name || ' - ' || creditcards.creditcard || ' (' || creditcards.creditcard_type || ')' AS customer_info
    FROM customers
    JOIN creditcards ON customers.customerID = creditcards.customerID
    WHERE TO_DATE(creditcards.expiration_year || '-' || creditcards.expiration_month, 'YYYY-MM') BETWEEN ADD_MONTHS(expire_date, -2) AND expire_date
    ORDER BY customers.name
  )
  LOOP
    v_customer_info := v_customer_info || c.customer_info || CHR(10);
  END LOOP;

  IF v_customer_info IS NULL THEN
    dbms_output.put_line('No credit cards are expiring within the next two months.');
  ELSE
    dbms_output.put_line('The following credit cards are expiring within the next two months:');
    dbms_output.put_line(v_customer_info);
  END IF;
END;
/

--Member 2 Suman Pogul
--Operation 5
--creating procedure Add_Category
create or replace procedure Add_Category(
category_name in ProductCategories.Categoryname%type, 
category_desc in ProductCategories.Description%type
)
IS
Begin
Insert into ProductCategories values(categoryID_seq.nextval, category_name, category_desc);
dbms_output.put_line('Product Category added successfully.');
Exception
when no_data_found then
dbms_output.put_line('no rows found');
when others then
dbms_output.put_line('SQLCODE: ' || SQLCODE);
dbms_output.put_line('SQLERRM: ' || SQLERRM);
End;
/

--Calling the above procedure to add new category
exec Add_Category('Electronics', 'Mobile devices products');
exec Add_Category('Music', 'Music Casettes');
exec Add_Category('Books', 'Fictional/Non-Fictional related books');
exec Add_Category('Automotive', 'Motor Vehicle Parts');
exec Add_Category('Furniture', 'Domestic Furniture');


--Operation 6 
--creating procedure Add_product
--creating a helper function to find product category id
create or replace function FIND_PRODUCT_CATEGORY_ID(
category_n in ProductCategories.Categoryname%type
)
return int
IS
cat_ID int;
Begin
Select categoryID into cat_ID from ProductCategories where categoryname = category_n;
return cat_ID;
Exception
when no_data_found then
dbms_output.put_line('Category do not exists');
return -1;
END;
/

--calling the above function to see the category id
declare
cat_id number;
begin
cat_id := find_product_category_id('Electronics');
dbms_output.put_line('Category ID is' ||' ' ||cat_id);
end;
/

--Creating Add_Product Procedure
create or replace procedure Add_Product(
product_name in products.productname%type,
available_quantity in products.availablequantity%type,
unit_price in products.unitprice%type,
category_name in ProductCategories.categoryname%type
) 
IS
category_ID ProductCategories.categoryID%type;
Begin
category_ID := FIND_PRODUCT_CATEGORY_ID(category_name);
insert into products values (productID_seq.nextval, product_name, available_quantity, unit_price, category_ID);
dbms_output.put_line('Product added successfully.');
Exception
when no_data_found then
dbms_output.put_line('no rows found');
when others then
dbms_output.put_line('SQLCODE: ' || SQLCODE);
dbms_output.put_line('SQLERRM: ' || SQLERRM);
End;
/


--calling the above procedure to add products to the products table
exec Add_Product('40inchTV',100, 200,'Electronics');
exec Add_Product('50inchTV',100, 300,'Electronics');
exec Add_Product('60inchTV',100, 400,'Electronics');
exec Add_Product('80inchTV',100, 1000,'Electronics');
exec Add_Product('BestOfBeyonce',100, 20,'Music');
exec Add_Product('BestOfTaylorSwift',100, 20,'Music');
exec Add_Product('BestOfEminem',100, 20,'Music');
exec Add_Product('BestOfWeeknd',100, 20,'Music');

--Operation 7
--creating Update_Inventory procedure
create or replace procedure Update_Inventory(
  product_id in int,
  quantity in number
)
is
new_quant number;
begin
  -- Update the inventory for the product
  update products
  set availablequantity = availablequantity - quantity
  where productid = product_id;

  select availablequantity into new_quant from products where productid = product_id;

  dbms_output.put_line('Product Quantity updated for product ID ' || product_id || ' with new quantity ' || new_quant);

exception
  when no_data_found then
    dbms_output.put_line('No inventory found for product ID ' || product_id);
end;
/

select * from products;

--Operation 8
--creating Report_Inventory procedure

create or replace procedure Report_Inventory
is
begin
dbms_output.put_line('Category Name: ' || 'Total Products Quantity');
for cat1 in (select categoryname, (select SUM(availablequantity) from products
WHERE products.categoryid = ProductCategories.categoryid)
as total_quantity from ProductCategories)
loop
dbms_output.put_line(cat1.categoryname || ': ' || cat1.total_quantity);
End loop;
End;
/

--calling the above procedure
exec Report_Inventory;




--Creating a Procedure to insert data into orders table
create or replace procedure add_orders (cust_id in int, prod_id in int, quant in number, order_date in date, cc_num in number) as
o_id number;
begin
select orderid_seq.nextval into o_id from dual;
insert into orders (orderid, customerid, productid, quantity, orderdate, cc_number) values
(o_id, cust_id, prod_id,quant, order_date,cc_num);
commit;
dbms_output.put_line('Orders added with id:' ||o_id);
exception
  -- Output an error message if there is an exception
  when others then
    dbms_output.put_line('Error adding order: ' || sqlerrm);
end;
/

--Calling the above procedure to add data into orders
exec add_orders(1,2,2, date '2023-05-10', 12345);
exec add_orders(1,5,30,date '2023-05-09', 12345);
exec add_orders(5,4,1, date '2023-05-11', 12346);
exec add_orders(3,6,10,date '2023-06-20', 45678);
exec add_orders(3,7,10,date '2023-06-20', 45678);
exec add_orders(3,8,10,date '2023-06-20', 45678);
exec add_orders(3,5,25,date '2023-06-20', 45678);



--Member 3 Sahu, Swapnil
--Operation 9 Place order Procedure
--For this we need 3 helper procedures to fetch customer id, product id and orderid
--creating helper function find_customer_id from email
create or replace procedure find_customer_id(
  email_address in varchar2,
  customer_id out number
)
is
begin
  select customerid into customer_id from customers where email = email_address;
  dbms_output.put_line('Customer Id is' ||' '||customer_id);
exception
  when no_data_found then
    dbms_output.put_line('Email Address does not exist');
end;
/

--calling the above procedure 
declare
custnid number;
begin
find_customer_id ('rajeev@kumar.org', custnid);
--dbms_output.put_line('Customer ID is' ||custnid);
end;
/

--creating helper function find_product_id to get product id from product name
create or replace procedure find_product_id(
  product_name in varchar2,
  product_id out number
)
is
begin
  select productid into product_id from products where productname = product_name;
  dbms_output.put_line('Product ID is' ||' '||product_id);
exception
  when no_data_found then
    dbms_output.put_line('product name does not exist');
end;
/

--calling the above procedure 
declare
prodnid number;
begin
find_product_id ('BestOfBeyonce', prodnid);
--dbms_output.put_line('Product ID is' ||prodnid);
end;
/

--creating helper function find_order_by_date to get order id from order date
Create or replace procedure find_order_by_date (
p_order_date in date,
p_order_id out number
)
is
cursor c_orders (order_date date) is
select orderid
from orders
where orderdate = order_date;
begin
-- Open the cursor and fetch the order ID
open c_orders(p_order_date);
fetch c_orders into p_order_id;

-- Close the cursor
close c_orders;

-- Print a message to indicate the result
if p_order_id is not null then
dbms_output.put_line('Order ID for order date ' || p_order_date || ': ' || p_order_id);
else
dbms_output.put_line('No order found for order date ' || p_order_date);
end if;
exception
when no_data_found then
dbms_output.put_line('No order found for order date ' || p_order_date);
when others then
dbms_output.put_line('Error finding order: ' || sqlerrm);
end;
/

--calling the above procedure
declare
ordernid number;
begin
find_order_by_date (date '2023-06-20', ordernid);
--dbms_output.put_line('Order ID is' ||ordernnid);
end;
/

--creating update inventory procedure to update in the products table
create or replace procedure update_inventory (
  product_id in number,
  quantity in number
)
is
new_quant number;
begin
  -- Update the inventory for the product
  update products
  set availablequantity = availablequantity - quantity
  where productid = product_id;

  select availablequantity into new_quant from products where productid = product_id;

  dbms_output.put_line('Product Quantity updated for product ID ' || product_id || ' with new quantity ' || new_quant);

exception
  when no_data_found then
    dbms_output.put_line('No inventory found for product ID ' || product_id);
end;
/

--calling the above procedure
exec update_inventory(6,8);

--creating invoice customer procedure to update the invoices table
create or replace procedure invoice_customer (
p_order_id in number,
p_customer_id in number,
p_credit_card_num in varchar2,
p_amount in number
) is
v_invoice_id number;
cursor c_invoiceid is
select invoiceid_seq.nextval
from dual;
begin
open c_invoiceid;
fetch c_invoiceid into v_invoice_id;
close c_invoiceid;

-- Insert a new record into the Invoice table
insert into invoices(invoiceid, orderid, customerid, creditcard, amount)
values (v_invoice_id, p_order_id, p_customer_id, p_credit_card_num, p_amount);

-- Print a message to indicate that the invoice was created
dbms_output.put_line('Invoice ' || v_invoice_id || ' created for Customer ID ' || p_customer_id || ' for amount $' || p_amount);
exception
when others then
dbms_output.put_line('Error creating invoice: ' || sqlerrm);
end;
/

--calling the above procedure
exec invoice_customer(1, 2,12345,50);



--Creating the place_order procedure
create or replace procedure place_order (
    cust_email in varchar2,
    product_name in varchar2,
    quant in number,
    cc_num in number,
    amt in number,
    order_date date
)
as
    cust_id number;
    prod_id number;
    order_id number;
begin
    -- find the customer ID based on their email address
    find_customer_id(cust_email, cust_id);

    -- find the product ID based on its name
    find_product_id(product_name, prod_id);
    
    --find the order ID based on its date
    find_order_by_date(order_date, order_id);

    -- call the Update_Inventory procedure to update the product inventory
    update_inventory(prod_id, quant);

    -- call the Invoice_Customer procedure to generate an invoice for the order
    invoice_customer(order_id, cust_id, cc_num, amt );
    

    --commit;
exception
    when no_data_found then
        dbms_output.put_line('No data found');
end;
/

--Calling the above procedure
exec place_order('john@smith.com', '50inchTV', 2, 12345 , 600 ,date '2023-05-10');
exec place_order('john@smith.com', 'BestOfBeyonce', 30, 12345 , 600 ,date '2023-05-10');
exec place_order('mary@smith.com', '80inchTV', 1, 12346 , 1000 ,date '2023-05-11');
exec place_order('mary@poppins.com', 'BestOfTaylorSwift', 10, 45678 , 2000 ,date '2023-06-20');
exec place_order('mary@poppins.com', 'BestOfEminem', 10, 45678 , 2000 ,date '2023-06-20');
exec place_order('mary@poppins.com', 'BestOfWeeknd', 10, 45678 , 2000 ,date '2023-06-20');
exec place_order('mary@poppins.com', 'BestOfBeyonce', 25, 45678 , 5000 ,date '2023-06-20');
exec place_order('mary@poppins.com', '50inchTV', 2, 45678 , 600 ,date '2023-06-20');




--Operation 10 Show_orders
set serveroutput on
declare
    v_total_orders number := 0;
begin
    -- query to retrieve all orders
    for m in (
        select 
            c.name,
            o.quantity,
            p.productname,
            i.amount
        from 
            orders o
            join customers c on o.customerid = c.customerid
            join products p on o.productid = p.productid
            join invoices i on o.orderid = i.orderid
    ) loop
        -- output order details
        dbms_output.put_line(
          'Name-' || ' ' || m.name || ' ' ||
         'Product-' || ' ' || m.productname || ' ' ||
         'Quantity-' || ' ' || m.quantity || ' ' ||
         'Amount-' || m.amount
        );
        
        -- add to the total number of orders
        v_total_orders := v_total_orders + 1;
    end loop;
    
    -- output grand total
    dbms_output.put_line('Grand Total: ' || v_total_orders);
    exception
    when no_data_found then
        dbms_output.put_line('No data found');
end;
/
commit;


--Operation 11 Creating Report_Orders_by_State Procedure
create or replace procedure report_orders_by_state(c_state in varchar2)
is
  total_orders number := 0; -- Total number of orders placed
  total_amount number := 0; -- Total amount of dollars spent
begin
  dbms_output.put_line('Customer Name | Customer Email | Total Orders | Total Amount');
  dbms_output.put_line('---------------------------------------------------------------');
  
  for order_rec in (select c.name, c.email, count(o.orderid) as total_orders, sum(o.amount) as total_amount
                    from invoices o
                    inner join customers c on o.customerid = c.customerid
                    where c.state = c_state
                    group by c.name, c.email)
  loop
    dbms_output.put_line(order_rec.name || ' | ' || order_rec.email || ' | ' || order_rec.total_orders || ' | ' || order_rec.total_amount);
    total_orders := total_orders + order_rec.total_orders;
    total_amount := total_amount + order_rec.total_amount;
  end loop;
  
  dbms_output.put_line('---------------------------------------------------------------');
  dbms_output.put_line('Grand Total: ' || total_orders || ' orders | $' || total_amount);
  exception
    when no_data_found then
        dbms_output.put_line('No data found');
end;
/

--Calling the above Procedure
exec report_orders_by_state('MD');


--Operation 12 Report_Low_Inventory

-- Create a compound trigger that automatically shows products with low inventory
create or replace trigger report_low_inventory
for update or insert on products -- Trigger fires for update or insert on the Product table
compound trigger

  -- Define a package-level collection to store product IDs that need to be processed
  type product_id_list is table of products.productid%type;
  products_to_update product_id_list := product_id_list();
  
  after each row is
  begin
    -- Check if the updated or inserted row has a quantity below 50
    if :new.availablequantity < 50 then
      -- Add the product ID to the collection
      products_to_update.extend;
      products_to_update(products_to_update.last) := :new.productid;
    end if;
  end after each row;

  after statement is
  begin
    -- Loop through the product IDs in the collection and display the product information
    for i in 1..products_to_update.count loop
      -- Retrieve the product information
      declare
        v_product_id products.productid%type;
        v_product_name products.productname%type;
        v_quantity products.availablequantity%type;
      begin
        select productid, productname, availablequantity
        into v_product_id, v_product_name, v_quantity
        from products
        where productid = products_to_update(i);

        -- Display the product information on the screen
        dbms_output.put_line('Product ID: ' || v_product_id);
        dbms_output.put_line('Product Name: ' || v_product_name);
        dbms_output.put_line('Available Quantity: ' || v_quantity);
      end;
    end loop;
    
    -- Clear the collection for the next trigger execution
    products_to_update.delete;
  end after statement;
  
end report_low_inventory;
/

-- Create a separate procedure to update the inventory
create or replace procedure update_inventory1 (
  product_id in number,
  quantity in number
)
is
new_quant number;
begin
  -- Update the inventory for the product
  update products
  set availablequantity = availablequantity + quantity
  where productid = product_id;

  select availablequantity into new_quant from products where productid = product_id;

  dbms_output.put_line('Product Quantity updated for product ID ' || product_id || ' with new quantity ' || new_quant);

exception
  when no_data_found then
    dbms_output.put_line('No inventory found for product ID ' || product_id);
end;
/
exec update_inventory1(5,50);


--Member 4 Atharva Puranik
--Operation 13 Invoice_Customer




CREATE OR REPLACE PROCEDURE INVOICE_CUSTOMER (Order_ID  INT, Customer_ID  INT, CREDITCARDNUMBER  NUMBER, AMOUNT  NUMBER) IS
counter1 int;
counter2 int;
BEGIN
select count(1) into counter1 from orders where orderid=order_ID;
select count(1) into counter2 from customers where customerid=customer_ID;


if counter1<=0 and counter2>0 then
dbms_output.put_line('No such order');
elsif counter2<=0 and counter1>0 then
dbms_output.put_line('No such customer');
elsif counter2<=0 and counter1<=0 then
dbms_output.put_line('No such order and customer');


else
insert into invoices values(InvoiceID_seq.nextval,Order_ID,Customer_ID, CREDITCARDNUMBER, AMOUNT );
end if;
Exception
when no_data_found then
Dbms_output.put_line('no rows found');


END;
/
--calling the above procedure
exec invoice_customer(1, 1,12345,50);


select * from invoices;






--Opearation 14 Report Best Customers
create or replace procedure report_best_customers (a in int) is
cursor c1 is select c.name as cname, SUM(i.amount) as amounts from invoices i, customers c where c.customerid=i.customerid  group by c.name having SUM(i.amount) > a order by SUM(i.amount) desc;
counter int;
begin
select count(1) into counter from invoices i, customers c where c.customerid=i.customerid and i.amount>a;
if counter<=0 then
dbms_output.put_line('No such customer');
else
for i in c1 loop
dbms_output.put_line('Customer Name: ' || i.cname ||'  | Amount: ' || i.amounts);
end loop;
end if;
exception
when no_data_found then
dbms_output.put_line('no rows found');
end;
/


exec report_best_customers(100);


















































--Operation 15 calculate_credit_card_fees


CREATE OR REPLACE PROCEDURE calculate_credit_card_fees
IS
  -- Declare variables to store the total fees for each credit card type
  visa_fee NUMBER := 0;
  mc_fee NUMBER := 0;
  amex_fee NUMBER := 0;
  discover_fee NUMBER := 0;
BEGIN
  -- Calculate the fees for each credit card type
  BEGIN
    SELECT SUM(amount * 0.03) INTO visa_fee FROM invoices i,creditcards c WHERE i.creditcard=c.creditcard and creditcard_type = 'VISA';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      visa_fee := 0;
  END;


  BEGIN
    SELECT SUM(amount * 0.03) INTO mc_fee FROM invoices i,creditcards c WHERE i.creditcard=c.creditcard and creditcard_type = 'MC';
if mc_fee is null then mc_fee :=0;
  end if;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      mc_fee := 0;
  END;


  BEGIN
    SELECT SUM(amount * 0.05) INTO amex_fee FROM invoices i,creditcards c WHERE i.creditcard=c.creditcard and creditcard_type = 'AMEX';
 if amex_fee is null then amex_fee :=0;
  end if;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      amex_fee := 0;
  END;


  BEGIN
    SELECT SUM(amount * 0.02) INTO discover_fee FROM invoices i,creditcards c WHERE i.creditcard=c.creditcard and creditcard_type = 'Discover';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      discover_fee := 0;
  END;


  -- Print the total fee for each credit card type
  DBMS_OUTPUT.PUT_LINE('VISA fee: $' || visa_fee);
  DBMS_OUTPUT.PUT_LINE('MC fee: $' || mc_fee);
  DBMS_OUTPUT.PUT_LINE('AMEX fee: $' || amex_fee);
  DBMS_OUTPUT.PUT_LINE('Discover fee: $' || discover_fee);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error calculating credit card fees: ' || SQLERRM);
END;
/
BEGIN
  calculate_credit_card_fees;
END;
/






































































--Operation 16 find_stingy_customers


CREATE OR REPLACE PROCEDURE find_stingy_customers(X IN NUMBER)
IS
  -- Declare a cursor to select the total amount spent by each customer
  CURSOR c IS
   select * from (SELECT customerid, SUM(amount) as total_spent
    FROM invoices
    GROUP BY customerid
    ORDER BY total_spent)
    where rownum <= X
    order by total_spent desc;

  -- Declare variables to store the customer ID and total amount spent
  customer_id invoices.customerid%TYPE;
  total_spent NUMBER;

  -- Declare a counter to keep track of the number of stingy customers found
  counter NUMBER := 0;
  counter1 NUMBER;
BEGIN
  -- Iterate over the cursor and print the X most stingy customers
Select count(distinct customerid) INTO counter1 from invoices;

if counter1 < X then DBMS_OUTPUT.PUT_LINE ('Maximum Customer : ' || counter1||' | Entered Value: '||X);
DBMS_OUTPUT.PUT_LINE(CHR(10));
end if;

-- Raise an exception if no stingy customers are found
if X <= 0 THEN
    DBMS_OUTPUT.PUT_LINE('Enter a Valid Number greater than 0');
else
    FOR a IN c LOOP
    counter := counter + 1;
    customer_id := a.customerid;
    total_spent := a.total_spent;
    EXIT WHEN counter > X;
    DBMS_OUTPUT.PUT_LINE('Customer ID: ' || customer_id || ', Total Spent: ' || total_spent);
  END LOOP;

end if;  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error finding stingy customers: ' || SQLERRM);
END;
/
begin
find_stingy_customers (2);
end;
/



--Member 5 Rishitha Avula
--Operation 17 Add_Review
--creating helper function find_product_id to get product id from product name
create or replace procedure find_product_id(
  product_name in varchar2,
  product_id out number
)
is
begin
  select productid into product_id from products where productname = product_name;
  dbms_output.put_line('Product ID is' ||' '||product_id);
exception
  when no_data_found then
    dbms_output.put_line('product name does not exist');
end;
/

--calling the above procedure 
set serveroutput on
declare
prodnid number;
begin
find_product_id ('BestOfBeyonce', prodnid);
--dbms_output.put_line('Product ID is' ||prodnid);
end;
/


--creating the Add_review procedure
create or replace procedure add_review(product_name in varchar2, cust_email in varchar2, star_given in number,review_text in varchar2) as
review_id number;
prod_id number;
begin
if cust_email is null then
 dbms_output.put_line ('You do not have an email');
else
select reviewid_seq.nextval into review_id from dual;
find_product_id(product_name, prod_id);
insert into reviews (reviewid, productid, reviewer_email, starsgiven, review_text) values
(review_id, prod_id, cust_email, star_given, review_text);
dbms_output.put_line('Record successfully inserted for:' ||' ' || review_id);
end if;
end;
/

--calling the above procedure to insert records in the add_review table
set serveroutput on
exec add_review('50inchTV', 'john@smith.com', 2, 'not a good TV. It could be better');
exec add_review('50inchTV', 'barney@abc.com', 1, 'do not buy');
exec add_review('80inchTV', 'barney@abc.com', 5, 'Excellent. This is the best TV');
exec add_review('80inchTV', 'mary@smith.com', 5, 'Excellent. Best ever');
exec add_review('BestOfBeyonce', 'mary@smith.com', 5, 'Excellent. Best ever');
exec add_review('BestOfBeyonce', 'z@abc.com', 4, 'Enjoyed it');


--operation 18
--creating buy or be beware procedure
create or replace procedure buy_or_beware(x in number) as
  type product_type is record (
    avg_rating number,
    rating_stdev number,
    productid products.productid%type,
    productname products.productname%type
  );
  type product_table is table of product_type;
  top_products product_table;
  worst_products product_table;
begin
  select *
  bulk collect into top_products
  from (
    select avg(r.starsgiven) as avg_rating, stddev(r.starsgiven) as rating_stdev, p.productid, p.productname
    from reviews r
    join products p on r.productid = p.productid
    group by p.productid, p.productname
    order by avg_rating desc
  )
  where rownum <= x;

  select *
  bulk collect into worst_products
  from (
    select avg(r.starsgiven) as avg_rating, stddev(r.starsgiven) as rating_stdev, p.productid, p.productname
    from reviews r
    join products p on r.productid = p.productid
    group by p.productid, p.productname
    order by avg_rating asc
  )
  where rownum <= x;

  dbms_output.put_line('Top rated products:');
  for i in 1..top_products.count loop
    dbms_output.put_line(top_products(i).avg_rating || ' stars - Product ID: ' || top_products(i).productid || ' - Product Name: ' || top_products(i).productname || ' - Standard Deviation: ' || top_products(i).rating_stdev);
  end loop;

  dbms_output.put_line('Buyer Beware: Stay Away from...');
  for i in 1..worst_products.count loop
    dbms_output.put_line(worst_products(i).avg_rating || ' stars - Product ID: ' || worst_products(i).productid || ' - Product Name: ' || worst_products(i).productname || ' - Standard Deviation:' || worst_products(i).rating_stdev);
    end loop;
    
end;
/

--Calling the above procdedure
exec buy_or_beware (2);


--operation 19
--creating customer recommendation product procedure
create or replace procedure Recommend_To_Customer
( in_custid in number)
is
    tmp_avg_rating      INT;
    tmp_categoryid      INT;
    tmp_productid       INT;
    tmp_productname     varchar2(20);
    tmp_count           INT;
    
BEGIN
select avg(r.starsgiven) as avg_rating, p.categoryid, p.productid, p.productname
        into tmp_avg_rating, tmp_categoryid, tmp_productid, tmp_productname
        from reviews r
        join products p on r.productid = p.productid
        and ( r.productid not in (select productid from orders where customerid=in_custid) 
           and 
           p.categoryid in (select p.categoryid from products p join orders o on p.productid = o.productid  and o.customerid=in_custid))
        and rownum<=1
        group by p.categoryid, p.productid, p.productname
        order by avg_rating desc;
        
        if ( tmp_productid is null ) 
        then 
                dbms_output.put_line('Recommonded product is not found');
                return;
        end if;

        dbms_output.put_line('Recommonded product name : ' || tmp_productname || ' Productid : ' || tmp_productid || ' category id : ' || tmp_categoryid  );
select count(1) into tmp_count
        from recommendations 
        where customerid=in_custid and recommendation_productid=tmp_productid; 

        if ( tmp_count > 0 ) 
        then 
                dbms_output.put_line('Recommonded product already found in recommendations table. so, the product insert is skipped');
                return;
        else
                insert into recommendations (recommendationid, customerid, recommendation_productid) 
                values (recommendationid_seq.nextval, in_custid, tmp_productid);
                commit;
        end if;

	exception
		when no_data_found then
			dbms_output.put_line('Recommonded product is not found');
END;
/

exec Recommend_To_Customer(1);

--operation 20
-- List_Recommendations

create or replace procedure List_Recommendations

is
    tmp_custid            number;
    tmp_custname          varchar2(20);
    tmp_categoryid        number;
    tmp_rec_prodid	  number;
    tmp_rec_prodname      varchar2(20);
    tmp_avg_rating        integer;
    
    cursor c1 is 
	select o.customerid,c.name,p.categoryid from products p
	join orders o on p.productid=o.productid
	join customers c on c.customerid=o.customerid;


BEGIN

        --Get all the customer's list with purchased product category

        open c1;
        loop
                fetch c1 into tmp_custid, tmp_custname, tmp_categoryid;
                exit when c1%notfound;

                -- Find the recommended product in that category
                
		 select avg(r.starsgiven) as avg_rating, p.categoryid, p.productid, p.productname
		 into tmp_avg_rating, tmp_categoryid, tmp_rec_prodid, tmp_rec_prodname
		    from reviews r
		    join products p on r.productid = p.productid
		    and p.categoryid=tmp_categoryid
		    and p.productid not in (select productid from orders where customerid=tmp_custid) 
		    and rownum<=1
		    group by p.categoryid, p.productid, p.productname
		    order by avg_rating desc;   

		if ( tmp_rec_prodid is null ) then

			dbms_output.put_line('Recommonded product is not found');
		else 
                     dbms_output.put_line('Customer : ' || tmp_custname || ' ; category : ' || tmp_categoryid || ' ; Recommonded product : ' || tmp_rec_prodname || ' ; Average rating : ' || tmp_avg_rating );
		end if;
        end loop;
        close c1;

	exception
		when no_data_found then
			dbms_output.put_line(' ');
END;
/
set serveroutput on
exec List_Recommendations;