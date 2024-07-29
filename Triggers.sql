/*
DROP TRIGGER trgAfterChangeOnEmployees_IsManager;
DROP TRIGGER trgAfterInsertOnTasks;
*/

CREATE TRIGGER trgAfterChangeOnEmployees_IsManager
	ON Employees
AFTER UPDATE
AS
	BEGIN
		DELETE FROM Managers 
		WHERE ManagerID IN (Select i.EmployeeID FROM inserted i WHERE i.IsManager = 0);	
	END;
GO

CREATE TRIGGER trgAfterInsertOnTasks
ON Tasks
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
	BEGIN
		INSERT INTO TaskHistory (TenantID, TaskID, EmployeeID, OperationType, NewTitle, NewDescription, NewPriority, NewStatus)
		SELECT 
			i.TenantID, i.TaskID, i.EmployeeID, 'INSERT', i.Title, i.Description, i.Priority, i.Status
		FROM inserted i;
	END

	IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
	BEGIN
		INSERT INTO TaskHistory (TenantID, TaskID, EmployeeID, OperationType, NewTitle, OldTitle, NewDescription, OldDescription, NewPriority, OldPriority, NewStatus, OldStatus)
		SELECT 
			i.TenantID, i.TaskID, i.EmployeeID, 'UPDATE', i.Title, d.Title, i.Description, d.Description, i.Priority, d.Priority, i.Status, d.Status
		FROM inserted i
		 JOIN deleted d 
		  ON d.TaskID = i.TaskID
		WHERE i.Title <> d.Title 
		   OR i.Description <> d.Description 
		   OR i.Priority <> d.Priority 
		   OR i.Status <> d.Status;
	END

	IF NOT EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
	BEGIN
		INSERT INTO TaskHistory (TenantID, TaskID, EmployeeID, OperationType, OldTitle, OldDescription, OldPriority, OldStatus)
		SELECT 
			d.TenantID, d.TaskID, d.EmployeeID, 'DELETE', d.Title, d.Description, d.Priority, d.Status
		FROM deleted d;
	END
END;
GO

