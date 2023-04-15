--dropping all the previously created tables

drop table customers cascade constraints;
drop table ProductCategories cascade constraints;
drop table products cascade constraints;
drop table orders cascade constraints;
drop table creditcards cascade constraints;
drop table invoices cascade constraints;
drop table reviews cascade constraints;
drop table recommendations cascade constraints;


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
exec add_customer('Pat Wagner', 'pat@wagner.com', 'Washington', 'DC', 20001, 12348, 'VISA', 10, 2025);
exec add_customer('Mary Poppins', 'mary@poppins.com', 'Los Angeles', 'CA', 90001, 45678, 'Discover', 11, 2023);
exec add_customer('Rajeev Kumar', 'rajeev@kumar.com', 'New York', 'NY', 10001, 45679, 'Discover', 10, 2023);
exec add_customer('Mary Smith', 'mary@smith.com', 'Baltimore', 'MD', 21250, 12346, 'VISA', 10, 2023);
exec add_customer('John Smith', 'john@smith.com', 'Baltimore', 'MD', 21250, 12347, 'VISA', 9, 2023);
exec add_customer('John Smith', 'john@smith.com', 'Baltimore', 'MD', 21250, 34567, 'AMEX', 10, 2023);
exec add_customer('John Smith', 'john@smith.com', 'Baltimore', 'MD', 21250, 23456, 'MC', 9, 2024);


select * from creditcards;
select * from customers;

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
set serveroutput on
exec show_all_customers_in_state ('NY');


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
exec Add_Category('Music', 'Music related books');

select * from productcategories;


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
exec Add_Product('80inchTV',100, 1000,'Electronics');
exec Add_Product('BestOfBeyonce',100, 20,'Music');
exec Add_Product('BestOfTaylorSwift',100, 20,'Music');
exec Add_Product('BestOfEminem',100, 20,'Music');
exec Add_Product('BestOfWeeknd',100, 20,'Music');


--Creating a Procedure to insert data into orders table
create or replace procedure add_orders (cust_id in int, prod_id in int, quant in number, order_date in date) as
o_id number;
begin
select orderid_seq.nextval into o_id from dual;
insert into orders (orderid, customerid, productid, quantity, orderdate) values
(o_id, cust_id, prod_id,quant, order_date);
commit;
dbms_output.put_line('Orders added with id:' ||o_id);
exception
  -- Output an error message if there is an exception
  when others then
    dbms_output.put_line('Error adding order: ' || sqlerrm);
end;
/

--Calling the above procedure to add data into orders
exec add_orders(1,1,2, date '2023-05-10');
exec add_orders(1,4,30,date '2023-05-10');
exec add_orders(3,3,1, date '2023-05-11');
exec add_orders(1,1,2, date '2023-05-10');
exec add_orders(1,1,2, date '2023-05-10');
exec add_orders(1,1,2, date '2023-05-10');

--Member 3 Swapnil Sahu
--Opration 9 Place order Procedure
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
find_customer_id ('rajeev@kumar.com', custnid);
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
create or replace procedure find_order_by_date (
  p_order_date in date,
  p_order_id out number
)
is
begin
  -- Retrieve the order ID for the given order date
  select orderid into p_order_id
  from orders
  where orderdate = p_order_date;

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
find_order_by_date (date '2023-05-11', ordernid);
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
exec update_inventory(7, 2);


--creating invoice customer procedure to update the invoices table
create or replace procedure invoice_customer (
  p_order_id in number,
  p_customer_id in number,
  p_credit_card_num in varchar2,
  p_amount in number
)
is
  v_invoice_id number;
begin
  -- Get the next available invoice ID from the sequence
  select invoiceid_seq.nextval into v_invoice_id from dual;

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
exec invoice_customer(1, 1,12345,50);

select * from invoices;


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

    -- commit the transaction
    --commit;
exception
    when others then
        -- rollback the transaction in case of any errors
        rollback;
        raise;
end;
/

--Calling the above procedure
exec place_order('mary@poppins.com', '80inchTV', 2, 45678 , 2000 , date '2023-5-11');

--select * from products;
select * from invoices;


--Operation 10 Show_orders
declare
    V_TOTAL_ORDERS number := 0;
begin
    -- query to retrieve all orders
    for m in (
        select 
            c.name,
            o.QUANTITY,
            p.PRODUCTNAME,
            i.AMOUNT
        from 
            ORDERS o
            join CUSTOMERS c on o.CUSTOMERID = c.CUSTOMERID
            join PRODUCTS p on o.PRODUCTID = p.PRODUCTID
            join INVOICES i on o.ORDERID = i.ORDERID
    ) loop
        -- output order details
        DBMS_OUTPUT.PUT_LINE(
          'Name-' || ' ' || m.name || ' ' ||
         'Product-' || ' ' || m.PRODUCTNAME || ' ' ||
         'Quantity-' || ' ' || m.QUANTITY || ' ' ||
         'Amount-' || m.AMOUNT
        );
        
        -- add to the total number of orders
        V_TOTAL_ORDERS := V_TOTAL_ORDERS + 1;
    end loop;
    
    -- output grand total
    DBMS_OUTPUT.PUT_LINE('Grand Total: ' || V_TOTAL_ORDERS);
end;
/
commit;

CREATE OR REPLACE PROCEDURE INVOICE_CUSTOMER1 (Order_ID  INT, Customer_ID  INT, CREDITCARDNUMBER  NUMBER, AMOUNT  NUMBER) IS
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
end;
/

--Calling the above Procedure
exec report_orders_by_state('MD');


--Operation 12 Report_Low_Inventory




--Member 4 Atharva Puranik
--Operation 13 Invoice_Customer
create or replace procedure invoice_customer (
  p_order_id in number,
  p_customer_id in number,
  p_credit_card_num in varchar2,
  p_amount in number
)
is
  v_invoice_id number;
begin
  -- Get the next available invoice ID from the sequence
  select invoiceid_seq.nextval into v_invoice_id from dual;

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
exec invoice_customer(1, 1,12345,50);

--Opearation 14 Report Best Customers
create or replace procedure report_best_customers (a in int) is
cursor c1 is select c.name as cname, i.amount as amount from invoices i, customers c where c.customerid=i.customerid and  amount>a order by amount desc;
counter int;
begin
select count(1) into counter from invoices i, customers c where c.customerid=i.customerid and i.amount>a;
if counter<=0 then
dbms_output.put_line('No such customer');
else
for i in c1 loop
dbms_output.put_line('Customer Name: ' || i.cname ||'  | Amount: ' || i.amount);
end loop;
end if;
exception
when no_data_found then
dbms_output.put_line('no rows found');
end;
/

exec report_best_customers(10);

commit;



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





