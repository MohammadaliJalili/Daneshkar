/* Formatted on 5/11/2024 12:46:09 PM (QP5 v5.391) */
--1. Total number of orders

SELECT COUNT (o.ORDERID) AS number_of_orders
  FROM ORDERS o;

--2. Total revenue

SELECT SUM (ORDERDETAILS.QUANTITY * PRODUCTS.PRICE)     AS total_sales
  FROM ORDERDETAILS
       JOIN PRODUCTS ON PRODUCTS.PRODUCTID = ORDERDETAILS.PRODUCTID;

--3. Top 5 customers based on their expenditure

  SELECT c.CUSTOMERID, c.CONTACTNAME, SUM (od.QUANTITY * p.PRICE) AS total_paid
    FROM CUSTOMERS c
         JOIN ORDERS o ON o.CUSTOMERID = c.CUSTOMERID
         JOIN ORDERDETAILS od ON od.ORDERID = o.ORDERID
         JOIN PRODUCTS p ON od.PRODUCTID = p.PRODUCTID
GROUP BY (c.CUSTOMERID, c.CONTACTNAME)
ORDER BY total_paid DESC
   FETCH FIRST 5 ROWS ONLY;

--4. Average amount of expenditure by Customer ID

  SELECT c.CUSTOMERID,
         c.CONTACTNAME,
         ROUND(AVG (od.QUANTITY * p.PRICE),2)     AS average_paid
    FROM CUSTOMERS c
         JOIN ORDERS o ON o.CUSTOMERID = c.CUSTOMERID
         JOIN ORDERDETAILS od ON od.ORDERID = o.ORDERID
         JOIN PRODUCTS p ON od.PRODUCTID = p.PRODUCTID
GROUP BY (c.CUSTOMERID, c.CONTACTNAME)
ORDER BY average_paid DESC;

--5. Rank customers based on the total amount of their order expenditures, but only consider customers who have placed more than 5 orders.

  SELECT c.CUSTOMERID,
         c.CONTACTNAME,
         SUM (od.QUANTITY)                                                 AS total_quantity,
         SUM (od.QUANTITY * p.PRICE)                                       AS total_paid,
         DENSE_RANK () OVER (ORDER BY SUM (od.QUANTITY * p.PRICE) DESC)    AS cutomer_rank
    FROM CUSTOMERS c
         JOIN ORDERS o ON o.CUSTOMERID = c.CUSTOMERID
         JOIN ORDERDETAILS od ON od.ORDERID = o.ORDERID
         JOIN PRODUCTS p ON od.PRODUCTID = p.PRODUCTID
GROUP BY (c.CUSTOMERID, c.CONTACTNAME)
  HAVING SUM (od.QUANTITY) > 5
ORDER BY total_paid DESC;

--6. The product that has generated the most revenue across all recorded orders

  SELECT p.PRODUCTID, p.PRODUCTNAME, (p.PRICE * SUM (od.quantity)) AS item_sold
    FROM PRODUCTS p JOIN ORDERDETAILS od ON p.PRODUCTID = od.PRODUCTID
GROUP BY p.PRODUCTID, p.PRODUCTNAME, p.PRICE
ORDER BY item_sold DESC
   FETCH FIRST 1 ROW ONLY;

--7. Number of products by Category

  SELECT c.CATEGORYID, c.CATEGORYNAME, COUNT (p.productid) num_of_products
    FROM CATEGORIES c JOIN PRODUCTS p ON c.CATEGORYID = p.CATEGORYID
GROUP BY c.CATEGORYID, c.CATEGORYNAME
ORDER BY num_of_products DESC;

--8. Determine the top-selling product in each category based on revenue

WITH
    product_rank
    AS
        (  SELECT c.CATEGORYID,
                  c.CATEGORYNAME,
                  p.productid,
                  p.productname,
                  SUM (p.price * od.quantity)                             AS total_product_sale,
                  RANK ()
                      OVER (PARTITION BY c.CATEGORYID
                            ORDER BY SUM (p.price * od.quantity) DESC)    AS ranking
             FROM CATEGORIES c
                  JOIN PRODUCTS p ON c.CATEGORYID = p.CATEGORYID
                  JOIN ORDERDETAILS od ON p.PRODUCTID = od.PRODUCTID
         GROUP BY c.CATEGORYID,
                  c.CATEGORYNAME,
                  p.productid,
                  p.productname)
SELECT categoryid,
       categoryname,
       productid,
       productname,
       total_product_sale
  FROM product_rank
 WHERE ranking = 1;

--9. Report the top 5 employees who generated the highest revenue, including their ID, first name, and last name

  SELECT e.EMPLOYEEID,
         (e.FIRSTNAME || ' ' || e.LASTNAME)     AS emp_name,
         SUM (p.price * od.quantity)            AS total_sale
    FROM employees e
         JOIN ORDERS o ON e.EMPLOYEEID = o.EMPLOYEEID
         JOIN ORDERDETAILS od ON od.ORDERID = o.ORDERID
         JOIN PRODUCTS p ON p.PRODUCTID = od.PRODUCTID
GROUP BY e.EMPLOYEEID, (e.FIRSTNAME || ' ' || e.LASTNAME)
ORDER BY total_sale DESC
   FETCH FIRST 5 ROWS ONLY;


--10. The average revenue generated per order by each employee

  SELECT e.EMPLOYEEID,
         (e.FIRSTNAME || ' ' || e.LASTNAME)                                     AS emp_name,
         ROUND (SUM (p.price * od.quantity) / COUNT (DISTINCT o.ORDERID), 2)    AS avg_sale
    FROM employees e
         JOIN ORDERS o ON e.EMPLOYEEID = o.EMPLOYEEID
         JOIN ORDERDETAILS od ON od.ORDERID = o.ORDERID
         JOIN PRODUCTS p ON p.PRODUCTID = od.PRODUCTID
GROUP BY e.EMPLOYEEID, (e.FIRSTNAME || ' ' || e.LASTNAME)
ORDER BY avg_sale DESC;

--11. The country with the highest number of recorded orders.

  SELECT c.COUNTRY, COUNT (o.orderid) AS number_of_orders
    FROM customers c JOIN ORDERS o ON c.CUSTOMERID = o.CUSTOMERID
GROUP BY (c.COUNTRY)
ORDER BY number_of_orders DESC
   FETCH FIRST 1 ROW ONLY;


--12. The total revenue from orders for each country

  SELECT c.COUNTRY, SUM (p.price * od.quantity) AS total_sale
    FROM CUSTOMERS c
         JOIN orders o ON c.CUSTOMERID = o.CUSTOMERID
         JOIN ORDERDETAILS od ON o.ORDERID = od.ORDERID
         JOIN products p ON p.PRODUCTID = od.PRODUCTID
GROUP BY c.country
ORDER BY total_sale DESC;

-- 13. The average price of each category

  SELECT c.CATEGORYID,
         c.CATEGORYNAME,
         ROUND (SUM (p.price) / COUNT (p.price), 2)     AS avg_category_price
    FROM categories c JOIN products p ON p.CATEGORYID = c.CATEGORYID
GROUP BY c.CATEGORYID, c.CATEGORYNAME
ORDER BY avg_category_price DESC;

-- 14. The most expensive category

  SELECT c.CATEGORYID, c.CATEGORYNAME
    FROM categories c JOIN products p ON p.CATEGORYID = c.CATEGORYID
GROUP BY c.CATEGORYID, c.CATEGORYNAME
ORDER BY ROUND (SUM (p.price) / COUNT (p.price), 2) DESC
   FETCH FIRST 1 ROW ONLY;



-- 15. The number of orders recorded each month during the year 1996

  SELECT EXTRACT (MONTH FROM o.ORDERDATE)     AS order_month,
         EXTRACT (YEAR FROM o.ORDERDATE)      AS order_year,
         COUNT (o.ORDERID)
    FROM orders o
GROUP BY EXTRACT (MONTH FROM o.ORDERDATE), EXTRACT (YEAR FROM o.ORDERDATE)
  HAVING EXTRACT (YEAR FROM o.ORDERDATE) = 1996
ORDER BY EXTRACT (MONTH FROM o.ORDERDATE);


--16. The average time interval between orders for each customer

WITH
    gap_date
    AS
        (SELECT o.CUSTOMERID,
                o.ORDERID,
                (  (MAX (o.ORDERDATE) OVER (PARTITION BY o.CUSTOMERID))
                 - (MIN (o.orderdate) OVER (PARTITION BY o.CUSTOMERID)))    AS gaptime
           FROM ORDERS o)
  SELECT gap_date.CUSTOMERID,
         c.customername,
         CASE
             WHEN COUNT (gap_date.customerid) > 1
             THEN
                 ROUND (gaptime / COUNT (gap_date.customerid - 1), 2)
             ELSE
                 0
         END    AS avg_gaptime
    FROM gap_date JOIN CUSTOMERS c ON c.CUSTOMERID = gap_date.CUSTOMERID
GROUP BY gap_date.CUSTOMERID, c.customername, gaptime
ORDER BY avg_gaptime DESC;

-- 17. The total number of orders for each season

WITH
    cal_season
    AS
        (SELECT o.ORDERID,
                CASE
                    WHEN TO_CHAR (o.orderdate, 'MM') BETWEEN 3 AND 5
                    THEN
                        'Spring'
                    WHEN TO_CHAR (o.orderdate, 'MM') BETWEEN 6 AND 8
                    THEN
                        'Summer'
                    WHEN TO_CHAR (o.orderdate, 'MM') BETWEEN 9 AND 11
                    THEN
                        'Autumn'
                    ELSE
                        'Winter'
                END    AS season
           FROM ORDERS o)
  SELECT season, COUNT (orderid)
    FROM cal_season
GROUP BY season
ORDER BY COUNT (orderid) DESC;

-- 18. The supplier that provided the highest number of items

  SELECT s.SUPPLIERID, s.SUPPLIERNAME, COUNT (p.productid) AS num_products
    FROM SUPPLIERS s JOIN PRODUCTS p ON s.SUPPLIERID = p.SUPPLIERID
GROUP BY s.SUPPLIERID, s.SUPPLIERNAME
ORDER BY COUNT (p.productid);

--19. The average price of goods supplied by each supplier

  SELECT s.SUPPLIERID, s.SUPPLIERNAME, ROUND (AVG (p.price), 2) AS avg_price
    FROM SUPPLIERS s JOIN PRODUCTS p ON p.SUPPLIERID = s.SUPPLIERID
GROUP BY s.SUPPLIERID, s.SUPPLIERNAME
ORDER BY ROUND(AVG(p.Price),2) DESC;