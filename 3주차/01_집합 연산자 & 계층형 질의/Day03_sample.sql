CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT,
    author TEXT,
    genre TEXT,
    price REAL
);

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    book_id INTEGER,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

INSERT INTO books (title, author, genre, price) 
VALUES
('To Kill a Mockingbird', 'Harper Lee', 'Fiction', 12.99),
('1984', 'George Orwell', 'Science Fiction', 10.99),
('The Great Gatsby', 'F. Scott Fitzgerald', 'Classic', 9.99),
('Pride and Prejudice', 'Jane Austen', 'Romance', 8.99),
('The Catcher in the Rye', 'J.D. Salinger', 'Fiction', 11.99);

INSERT INTO customers (name, email) 
VALUES
('Alice', 'alice@gmail.com'),
('Bob', 'bob@yahoo.com'),
('Charlie', 'charlie@outlook.com');

INSERT INTO purchases (customer_id, book_id, purchase_date) 
VALUES
(1, 1, '2024-04-25'), -- Alice purchased 'To Kill a Mockingbird'
(1, 3, '2024-04-27'), -- Alice purchased 'The Great Gatsby'
(2, 2, '2024-04-26'); -- Bob purchased '1984'

-- ──────────────────────────────────────────────────────────
-- 5-1. 기본 계층형 질의 - 보고 체계 전체 조회
-- ──────────────────────────────────────────────────────────
WITH RECURSIVE emp_hierarchy(
    EmployeeId, FirstName, LastName, Title, ReportsTo, lvl
) AS (
    -- Anchor: 최상위 직원 (Root)
    SELECT EmployeeId, FirstName, LastName, Title, ReportsTo,
           0 AS lvl
    FROM employees
    WHERE ReportsTo IS NULL

    UNION ALL

    -- Recursive: 직속 부하 반복 탐색
    SELECT e.EmployeeId, e.FirstName, e.LastName,
           e.Title, e.ReportsTo, h.lvl + 1
    FROM employees e
    JOIN emp_hierarchy h ON e.ReportsTo = h.EmployeeId
)
SELECT lvl                                                AS 계층레벨,
       EmployeeId                                         AS 직원ID,
       SUBSTR('                ', 1, lvl * 4)
           || FirstName || ' ' || LastName                AS 직원명,
       Title                                              AS 직책,
       ReportsTo                                          AS 관리자ID
FROM emp_hierarchy
ORDER BY lvl, EmployeeId;


-- ──────────────────────────────────────────────────────────
-- 5-2. 계층형 + 집계 - 직원별 담당 고객 수 포함 조회
-- ──────────────────────────────────────────────────────────
WITH RECURSIVE emp_hier(
    EmployeeId, FirstName, LastName, Title, ReportsTo, lvl
) AS (
    SELECT EmployeeId, FirstName, LastName, Title, ReportsTo, 0 AS lvl
    FROM employees
    WHERE ReportsTo IS NULL

    UNION ALL

    SELECT e.EmployeeId, e.FirstName, e.LastName,
           e.Title, e.ReportsTo, h.lvl + 1
    FROM employees e
    JOIN emp_hier h ON e.ReportsTo = h.EmployeeId
)
SELECT h.lvl        AS 계층레벨,
       h.EmployeeId AS 직원ID,
       SUBSTR('                ', 1, h.lvl * 4)
           || h.FirstName || ' ' || h.LastName AS 직원명,
       h.Title      AS 직책,
       COUNT(c.CustomerId)                     AS 담당고객수,
       ROUND(SUM(i.Total), 2)                  AS 담당매출합계
FROM emp_hier h
LEFT JOIN customers c ON h.EmployeeId = c.SupportRepId
LEFT JOIN invoices  i ON c.CustomerId  = i.CustomerId
GROUP BY h.EmployeeId, h.lvl, h.FirstName, h.LastName, h.Title
ORDER BY h.lvl, h.EmployeeId;


-- ──────────────────────────────────────────────────────────
-- 5-3. 경로(PATH) + 리프(Leaf) 노드 판별
-- ──────────────────────────────────────────────────────────
WITH RECURSIVE emp_path(
    EmployeeId, FirstName, LastName, Title, ReportsTo, lvl, path
) AS (
    SELECT EmployeeId, FirstName, LastName, Title, ReportsTo,
           0,
           FirstName || ' ' || LastName AS path
    FROM employees
    WHERE ReportsTo IS NULL

    UNION ALL

    SELECT e.EmployeeId, e.FirstName, e.LastName,
           e.Title, e.ReportsTo, p.lvl + 1,
           p.path || ' > ' || e.FirstName || ' ' || e.LastName
    FROM employees e
    JOIN emp_path p ON e.ReportsTo = p.EmployeeId
)
SELECT lvl        AS 계층레벨,
       EmployeeId AS 직원ID,
       path       AS 조직경로,
       Title      AS 직책,
       CASE
           WHEN EmployeeId NOT IN (
               SELECT ReportsTo
               FROM employees
               WHERE ReportsTo IS NOT NULL
           ) THEN 'Leaf'
           ELSE 'Branch'
       END AS 노드유형
FROM emp_path
ORDER BY path;


-- ──────────────────────────────────────────────────────────
-- 5-4. 계층형 + UNION ALL - 레벨별 인원 + 전체 합계
-- ──────────────────────────────────────────────────────────
WITH RECURSIVE emp_cte(
    EmployeeId, FirstName, LastName, Title, ReportsTo, lvl
) AS (
    SELECT EmployeeId, FirstName, LastName, Title, ReportsTo, 0
    FROM employees
    WHERE ReportsTo IS NULL

    UNION ALL

    SELECT e.EmployeeId, e.FirstName, e.LastName,
           e.Title, e.ReportsTo, c.lvl + 1
    FROM employees e
    JOIN emp_cte c ON e.ReportsTo = c.EmployeeId
)
SELECT 'Level ' || CAST(lvl AS TEXT) AS 계층레벨,
       COUNT(*)                      AS 직원수
FROM emp_cte
GROUP BY lvl

UNION ALL

SELECT '── 합계', COUNT(*)
FROM emp_cte

ORDER BY 계층레벨;