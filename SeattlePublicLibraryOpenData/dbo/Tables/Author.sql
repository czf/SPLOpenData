CREATE TABLE [dbo].[Author] (
    [AuthorId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [Name]     NVARCHAR (1000) NULL,
    CONSTRAINT [PK_Author] PRIMARY KEY CLUSTERED ([AuthorId] ASC)
);

