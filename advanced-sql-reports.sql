use northwind;

/*
Create Orders Report
--------------------------------------
- Show Customer First Name, Last Name
- Shipping Company Name
- Order Date (formatted as January, 1, 2018), Shipping Address (street, city, state, zip, country)
- Product Code, Product Name, List Price, quantity ordered, and total cost of line item
- Provide friendly column names
- Format numbers to have commas and limit decimals to two places
*/
SELECT 
	c.first_name as 'First Name',
    c.last_name as 'Last Name',
    s.company as 'Shipping Company Name',
    DATE_FORMAT(o.order_date, '%M, %D, %Y') as 'Order Date',
	CONCAT(o.ship_address, ', ', o.ship_city,', ', o.ship_state_province, ', ', o.ship_zip_postal_code, ', ', o.ship_country_region) as 'Shipping Address',
    p.product_code as 'Product Code',
    p.product_name as 'Product Name',
    p.list_price as 'List Price',
    format(ord_det.quantity, 0) as 'Quantity Ordered',
    format(ord_det.unit_price, 2) as 'Unit Price',
    format(quantity * ord_det.unit_price, 2) as 'Total Cost'
FROM orders o
INNER JOIN customers c ON c.id = o.customer_id
INNER JOIN shippers s ON s.id = o.shipper_id
INNER JOIN order_details ord_det ON o.id = ord_det.order_id
INNER JOIN products p ON ord_det.product_id = p.id;

/*
Create Monthly Sales Report by State
-------------------------------------------------
- Create Sales Report by year, month, by state
- Show total revenue - List Price * order quantity
- Limit to order lines invoiced
*/
SELECT 
	year(o.order_date) as year,
    month(o.order_date) as month,
    o.ship_state_province as state,
    FORMAT(SUM(p.list_price * ord_det.quantity), 2) as 'total_revenue' 
FROM orders o
INNER JOIN order_details ord_det ON ord_det.order_id = o.id
INNER JOIN products p ON p.id = ord_det.product_id
WHERE ord_det.status_id = 2
GROUP BY year, month, state
ORDER BY year ASC, month ASC, state ASC;

/*
Create Monthly Profit Report by Item
--------------------------------------------
- Create report by year, by month, by item
- Show total sales, cost, and profit List Price * order quantity - standard cost * order quantity
- Limit to order lines invoiced
- Use Equi-Join Syntax for table joins
*/
SELECT 
	date_format(o.order_date, '%Y.%m') as 'sales_month',
    p.product_name,
    SUM(p.list_price * ord_det.quantity) as 'sales',
    SUM(ord_det.quantity * p.standard_cost) as 'total_cost',
    SUM(p.list_price * ord_det.quantity - p.standard_cost * ord_det.quantity) as 'profit'
FROM orders o, order_details ord_det, products p
WHERE 
	o.id = ord_det.order_id AND
    p.id = ord_det.product_id AND
	ord_det.status_id = 2
GROUP BY sales_month, p.product_name
ORDER BY sales_month ASC, p.product_name ASC;

/*
Create Weekly Sales Report Per Employee
----------------------------------------------------------------
- Create a Weekly Sales Report per Employee
- Report should list each employee and show zero if the employee had no sales
- Should be values for each week company had sales
- Use outer joins
- Use ifnull function to provide zero values
- Hint - you will need to use a subquery for order data
*/
SELECT 
	e.first_name as 'First Name', 
    e.last_name as 'Last Name',
    week as 'Week',
    format(ifnull(sales, 0), 2) as 'Total Sales'
from employees e
LEFT JOIN (
	SELECT 
		o.employee_id,
		week(o.order_date) as week, 
		sum(o.shipping_fee + ord_det.quantity * p.list_price) as sales
	FROM orders o
	JOIN order_details ord_det ON o.id = ord_det.order_id
	JOIN products p ON p.id = ord_det.product_id
	GROUP BY o.employee_id, week
) as w_ord ON w_ord.employee_id = e.id
ORDER BY Week, e.last_name, e.first_name;