/*BÀI TẬP TỔNG HỢP PHẦN SQL*/

/*a. Truy xuất các name của tất cả employee có sex là male trong 
Department “Research” mà làm cho ít nhất một project nhiều hơn 10 giờ một tuần.*/
SELECT Fname, Lname
FROM EMPLOYEE E INNER JOIN WORKS_ON WO ON E.Ssn = WO.Essn
WHERE Sex = 'M' AND [Hours] > 10

/*b. Tìm tên của tất cả employee được giám sát trực tiếp bởi manager của phòng ban “Research”.*/
SELECT Fname, Lname
FROM EMPLOYEE JOIN DEPARTMENT ON Super_ssn = Mgr_ssn
WHERE Dname = 'Research'

/*c. Với mỗi project, liệt kê tên project, và tổng số giờ một tuần mà tất cả nhân viên phải làm cho project đó.*/
SELECT Pname, SUM([Hours]) AS 'tổng số giờ một tuần mà tất cả nhân viên phải làm cho project'
FROM PROJECT JOIN WORKS_ON ON Pnumber = Pno
GROUP BY Pname

/*d. Với mỗi phòng ban, liệt kê tên phòng ban và tên của tất cả các employee làm việc cho phòng ban đó.*/
SELECT Dname, Fname, Lname
FROM EMPLOYEE JOIN DEPARTMENT ON Dnumber = Dno
ORDER BY Dname

/*e. Liệt kê tên của tất cả employee không làm bất cứ project nào ở “Houston”.*/
SELECT DISTINCT Fname, Lname
FROM EMPLOYEE
WHERE EMPLOYEE.Ssn NOT IN (SELECT WORKS_ON.Essn
                           FROM WORKS_ON
                                    JOIN PROJECT ON PROJECT.Pnumber = WORKS_ON.Pno
                           WHERE Plocation = 'Houston')

/*f. Liệt kê tên của tất cả employee làm việc cho tất cả các project ở “Houston”.*/
SELECT DISTINCT Fname, Lname
FROM EMPLOYEE E JOIN WORKS_ON W ON Ssn = Essn
WHERE Pno IN (SELECT Pnumber
              FROM Project
              WHERE Plocation = 'Houston')
GROUP BY Fname, Lname
HAVING COUNT(*) = (SELECT COUNT(*) FROM Project WHERE Plocation = 'Houston') 

/*g. Tìm các employee có tổng số dự án tham gia nhiều nhất trong công ty.*/
SELECT Fname, Lname, A.SODUAN
FROM EMPLOYEE, (SELECT Essn, COUNT(Pno) SODUAN FROM WORKS_ON GROUP BY Essn) A 
WHERE EMPLOYEE.Ssn = A.Essn AND A.SODUAN = (SELECT MAX(B.SODUAN) 
                                            FROM (SELECT Essn, COUNT(Pno) SODUAN FROM WORKS_ON GROUP BY Essn) B )

/*h.Liệt kê tên các employee có lương cao nhất trong mỗi phòng ban.*/
SELECT EMPLOYEE.Fname + ' ' + EMPLOYEE.Lname AS Name, DEPARTMENT.Dname, EMPLOYEE.Salary
FROM EMPLOYEE JOIN (SELECT ROW_NUMBER() OVER( PARTITION BY Dname ORDER BY Salary DESC) AS RN, Fname, Lname, Dname, Salary 
                    FROM EMPLOYEE JOIN DEPARTMENT ON Dno = Dnumber) A 
                ON EMPLOYEE.Fname = A.Fname
              JOIN DEPARTMENT ON EMPLOYEE.Dno = DEPARTMENT.Dnumber
WHERE RN = 1
               
/*i. Với mỗi phòng ban, tìm các employee có tổng số dự án tham gia nhiều nhất trong phòng ban đó*/
SELECT Fname, Lname, Ssn , Dno, COUNT(distinct Pno ) AS totalProject
FROM WORKS_ON JOIN EMPLOYEE ON EMPLOYEE.Ssn = WORKS_ON.Essn
GROUP BY Fname, Lname, Ssn, Dno
HAVING COUNT(distinct Pno) >= ALL(SELECT COUNT(distinct W.Pno)
                              FROM  EMPLOYEE E JOIN WORKS_ON W ON 
                                   E.Ssn = W.Essn
                              WHERE E.Dno = EMPLOYEE.Dno
                              GROUP BY E.Ssn )

/*Liệt kê last name của tất cả các manager của các department nhưng không tham gia project nào*/
SELECT Fname + ' ' + Lname AS Name
FROM (SELECT Dname, Ssn, Fname, Lname FROM EMPLOYEE JOIN DEPARTMENT ON Ssn = Mgr_ssn) A
WHERE A.Ssn NOT IN (SELECT Essn FROM WORKS_ON)



/*2, CẬP NHẬT DỮ LIỆU*/

/*Nhân viên có mã là “123456789” thay đổi địa chỉ thành “123 Lý Thường Kiệt F.14 Q.10*/
UPDATE EMPLOYEE
SET Address = '123 Lý Thường Kiệt F.14 Q.10'
WHERE Ssn = 123456789

/*Mối quan hệ của nhân viên “Franklin” với người phụ thuộc “Joy” thay đổi thành “Friend”*/
UPDATE DEPENDENT
SET Relationship = 'Friend'
WHERE Essn = (SELECT Ssn FROM EMPLOYEE WHERE Fname = 'Franklin')

/*Tất cả nhân viên của phòng ban có ít nhất một vị trí ở “Houston” được tăng lương gấp đôi*/
UPDATE EMPLOYEE
SET Salary = Salary*2
WHERE Dno IN (SELECT Dnumber FROM DEPT_LOCATIONS WHERE Dlocation = 'Houston')

/*Trừ 5% lương cho các nhân viên có tổng số dự án tham gia ít hơn 2*/
UPDATE EMPLOYEE
SET Salary = Salary - Salary*0.05
WHERE Ssn IN (SELECT Essn
             FROM WORKS_ON 
             GROUP BY Essn
             HAVING COUNT(Pno) < 2)

