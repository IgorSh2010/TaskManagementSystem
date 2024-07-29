INSERT INTO Roles (RoleName)
VALUES ('Administrator'), ('Manager'), ('Employer');
GO

INSERT INTO Tenants (TenantName)
VALUES ('Tenant1'), ('Tenant2'), ('Tenant3'), ('Tenant4'), ('Tenant5'),
('Tenant6'), ('Tenant7'), ('Tenant8'), ('Tenant9'), ('Tenant10');
GO

INSERT INTO Employees (RoleID, EmployeeName, SystemUser)
VALUES (1, 'Ihor Shepetko', 'i.shepetko');
GO

DECLARE @TenantID INT;
DECLARE @TenantName NVARCHAR(255);

DECLARE TenantCursor CURSOR FOR
SELECT TenantID, TenantName
FROM Tenants;

OPEN TenantCursor;
FETCH NEXT FROM TenantCursor INTO @TenantID, @TenantName;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @j INT = 1;
    WHILE @j <= 100
    BEGIN
		
        INSERT INTO Employees (TenantID, EmployeeName, SystemUser, IsManager, RoleID)
        VALUES (@TenantID, 
				CONCAT('Employee', @j, '_', @TenantName),
				CONCAT('Emp', @j, '.', @TenantName), 
				CASE WHEN @j % 10 = 0 THEN 1 ELSE 0 END, 
				CASE WHEN @j % 10 = 0 THEN 2 ELSE 3 END);
        
        SET @j = @j + 1;
    END

    FETCH NEXT FROM TenantCursor INTO @TenantID, @TenantName;
END

CLOSE TenantCursor;
DEALLOCATE TenantCursor;
GO

DECLARE @TenantID INT;
DECLARE @EmployeeID INT;
DECLARE @EmployeeName NVARCHAR(255);


DECLARE EmployeeCursor CURSOR FOR
SELECT TenantID, EmployeeID, EmployeeName
FROM Employees Where RoleID = 3;

OPEN EmployeeCursor;
FETCH NEXT FROM EmployeeCursor INTO @TenantID, @EmployeeID, @EmployeeName;

WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @RandomManagerID INT;

	SELECT @RandomManagerID = RandomManager
	FROM (SELECT TOP 1 RandomManager
			FROM (SELECT EmployeeID AS RandomManager
					from Employees
					where IsManager > 0 and TenantID = @TenantID 				
				 ) AS Manager
			ORDER BY NEWID()) rm;

    INSERT INTO Managers (TenantID, ManagerID, ManagerName,	SubordinateEmployeeID)
    VALUES (@TenantID, 
			@RandomManagerID,
			@EmployeeName, 
			@EmployeeID);

    FETCH NEXT FROM EmployeeCursor INTO @TenantID, @EmployeeID, @EmployeeName;
END
CLOSE EmployeeCursor;
DEALLOCATE EmployeeCursor;
GO

DECLARE @TenantID INT;
DECLARE @EmployeeID INT;

DECLARE EmployeeCursor CURSOR FOR
SELECT TenantID, EmployeeID
FROM Employees;

OPEN EmployeeCursor;
FETCH NEXT FROM EmployeeCursor INTO @TenantID, @EmployeeID;

WHILE @@FETCH_STATUS = 0
BEGIN

    DECLARE @l INT = 1;
    WHILE @l <= 1000
    BEGIN

		DECLARE @RandomPriorityValue NVARCHAR(30);
		DECLARE @RandomStatusValue NVARCHAR(30);

		SELECT @RandomPriorityValue = RandomPriorityValue
		FROM (SELECT TOP 1 RandomPriorityValue
			  FROM (SELECT 'Medium' AS RandomPriorityValue
					UNION ALL
					SELECT 'High'
					UNION ALL
					SELECT 'Low'				
				) AS PriorityValues
				ORDER BY NEWID()) rpv;

		SELECT @RandomStatusValue = RandomStatusValue
		FROM (SELECT TOP 1 RandomStatusValue
			  FROM (SELECT 'Planned' AS RandomStatusValue
					UNION ALL
					SELECT 'Complete'
					UNION ALL
					SELECT 'Cancelled'
					UNION ALL
					SELECT 'In Progress'
					UNION ALL
					SELECT 'On Hold'
					UNION ALL
					SELECT 'Blocked'				
				) AS StatusValues
				ORDER BY NEWID()) rsv;

        INSERT INTO Tasks (TenantID, EmployeeID, Title, Priority, Description, Status)
        VALUES (@TenantID, 
				@EmployeeID,
				CONCAT('Task-', @l), 
				@RandomPriorityValue,
				CONCAT('Description for task-', @l), 
				@RandomStatusValue);

        SET @l = @l + 1;
    END

    FETCH NEXT FROM EmployeeCursor INTO @TenantID, @EmployeeID;
END
CLOSE EmployeeCursor;
DEALLOCATE EmployeeCursor;
GO
