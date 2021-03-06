CREATE TABLE [dbo].[ItemCollection] (
    [Code]             VARCHAR (50)    NOT NULL,
    [Description]      NVARCHAR (1000) NULL,
    [FormatGroup]      NVARCHAR (50)   NULL,
    [FormatSubgroup]   NVARCHAR (50)   NULL,
    [CategoryGroup]    NVARCHAR (50)   NULL,
    [CategorySubgroup] NVARCHAR (50)   NULL,
    [AgeGroup]         VARCHAR (100)   NULL,
    CONSTRAINT [PK_ItemCollection] PRIMARY KEY CLUSTERED ([Code] ASC)
);

