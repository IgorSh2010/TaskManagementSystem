CREATE DATABASE TaskManagementSystem;
GO

USE TaskManagementSystem;
GO

/*
drop table [dbo].[TaskHistory];
drop table [dbo].[Tasks];
drop table [dbo].[Managers];
drop table [dbo].[Employees];
drop table [dbo].[Roles];
drop table [dbo].[Tenants];

*/

CREATE TABLE Roles (
    RoleID INT IDENTITY PRIMARY KEY,
    RoleName NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE Tenants (
    TenantID INT IDENTITY PRIMARY KEY,
    TenantName NVARCHAR(255) NOT NULL
);

CREATE TABLE Employees (
    EmployeeID INT IDENTITY PRIMARY KEY,
	RoleID INT NOT NULL,
    EmployeeName NVARCHAR(255) NOT NULL,
	SystemUser NVARCHAR(255) NOT NULL,
	IsManager BIT NOT NULL DEFAULT 0,
	TenantID INT,
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
GO

CREATE TABLE Managers (
	RecID INT IDENTITY PRIMARY KEY,
    ManagerID INT,
    ManagerName NVARCHAR(255) NOT NULL,
	SubordinateEmployeeID INT NOT NULL,
	TenantID INT,
	FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID)  ON DELETE CASCADE,
	FOREIGN KEY (SubordinateEmployeeID) REFERENCES Employees(EmployeeID)  ON DELETE NO ACTION,
	CONSTRAINT unique_manager UNIQUE (ManagerID, SubordinateEmployeeID)
);
GO

CREATE TABLE Tasks (
    TaskID INT IDENTITY PRIMARY KEY,
    EmployeeID INT NOT NULL,
    Title NVARCHAR(255) NOT NULL,
    Priority NVARCHAR(50),
    Description NVARCHAR(MAX),
    Status NVARCHAR(50) NOT NULL,
	TenantID INT,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO

CREATE TABLE TaskHistory (
    TaskHistoryID INT IDENTITY PRIMARY KEY,
	TenantID INT,
    TaskID INT NOT NULL,
    EmployeeID INT NOT NULL,
	OperationType NVARCHAR(20),
	OldTitle NVARCHAR(255),
	NewTitle NVARCHAR(255),
    OldDescription NVARCHAR(MAX),
	NewDescription NVARCHAR(MAX),
	OldPriority NVARCHAR(50),
	NewPriority NVARCHAR(50),
	OldStatus NVARCHAR(50),
	NewStatus NVARCHAR(50),
    ChangeDate DATETIME NOT NULL DEFAULT GETDATE(),
	ChangeUser NVARCHAR(255) NOT NULL DEFAULT SYSTEM_USER,
    FOREIGN KEY (TaskID) REFERENCES Tasks(TaskID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO