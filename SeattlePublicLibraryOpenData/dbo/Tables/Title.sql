CREATE TABLE [dbo].[Title] (
    [TitleId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [Title]   NVARCHAR (4000) NOT NULL,
    CONSTRAINT [PK_Title] PRIMARY KEY CLUSTERED ([TitleId] ASC)
);

