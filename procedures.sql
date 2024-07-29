/*
DROP PROCEDURE dbo.AddTask;
DROP PROCEDURE dbo.UpdateTask;
DROP PROCEDURE dbo.DeleteTask;
DROP PROCEDURE dbo.GetTasksForEmployer;
DROP PROCEDURE dbo.GetTasksForManager;
*/

CREATE PROCEDURE AddTask (
	@TenantID INT,
    @EmployeeID INT,
    @Title NVARCHAR(255),
    @Priority NVARCHAR(50),
    @Description NVARCHAR(MAX),
    @Status NVARCHAR(50)
)
AS
	BEGIN
		INSERT INTO Tasks (EmployeeID, Title, Priority, Description, Status, TenantID)
		VALUES (@EmployeeID, @Title, @Priority, @Description, @Status, @TenantID);
    
		DECLARE @TaskID INT = SCOPE_IDENTITY();
	END;
GO

CREATE PROCEDURE UpdateTask (
    @TaskID INT,
    @EmployeeID INT,
    @Title NVARCHAR(255),
    @Priority NVARCHAR(50),
    @Description NVARCHAR(MAX),
    @Status NVARCHAR(50)
)
AS
BEGIN
    UPDATE Tasks
    SET 
		EmployeeID = @EmployeeID,
		Title = @Title,
        Priority = @Priority,
        Description = @Description,
        Status = @Status,
        UpdatedAt = GETDATE()
    WHERE TaskID = @TaskID;
END;
GO

CREATE PROCEDURE DeleteTask (
    @TaskID INT,
    @EmployeeID INT
)
AS
BEGIN
    DELETE FROM Tasks
    WHERE TaskID = @TaskID;
END;
GO

CREATE PROCEDURE GetTasksForEmployee (
    @EmployeeID INT,
	@TenantID INT
)
AS
BEGIN
    SELECT t.TaskID, t.Title, t.Priority, t.Description, t.Status, t.CreatedAt, t.UpdatedAt
    FROM Tasks t
    WHERE t.EmployeeID = @EmployeeID AND t.TenantID = @TenantID
    ORDER BY t.CreatedAt DESC;
END;
GO

CREATE PROCEDURE GetTasksForManager (
	@ManagerID INT,
    @EmployeeID INT,
	@TenantID INT,
	@GetStatistics BIT = 0
)
AS
BEGIN
	IF @GetStatistics = 0
		BEGIN
			SELECT t.EmployeeID, t.TaskID, t.Title, t.Priority, t.Description, t.Status, t.CreatedAt
			FROM Tasks t
			WHERE t.TenantID = @TenantID 
				AND (t.EmployeeID = @ManagerID 
						OR t.EmployeeID IN (Select SubordinateEmployeeID 
										FROM Managers m
										Where m.TenantID = @TenantID 
											AND m.ManagerID = @ManagerID))
			ORDER BY t.CreatedAt DESC;
		END
	ELSE
		BEGIN
			Select TaskMonth, EmployeeID, Status, QTY 
			FROM (SELECT DATEFROMPARTS(YEAR(t.CreatedAt), MONTH(t.CreatedAt), 1) AS TaskMonth,
				   t.EmployeeID, 
				   t.Status, 
				   COUNT(t.Status) AS QTY
			FROM Tasks t
			WHERE t.TenantID = @TenantID 
				AND (t.EmployeeID = @ManagerID OR 
						t.EmployeeID IN (Select SubordinateEmployeeID 
										FROM Managers m
										Where m.TenantID = @TenantID 
											AND m.ManagerID = @ManagerID))
			GROUP BY DATEFROMPARTS(YEAR(t.CreatedAt), MONTH(t.CreatedAt), 1),
					 t.EmployeeID,
					 t.Status) s 
			ORDER BY TaskMonth DESC;
		END
END;
GO