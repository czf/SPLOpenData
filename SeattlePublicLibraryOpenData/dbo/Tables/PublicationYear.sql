CREATE TABLE [dbo].[PublicationYear] (
    [PublicationYearId] INT           IDENTITY (1, 1) NOT NULL,
    [PublicationYear]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_PublicationYear] PRIMARY KEY CLUSTERED ([PublicationYearId] ASC)
);

