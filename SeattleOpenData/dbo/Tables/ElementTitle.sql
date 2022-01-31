CREATE TABLE [dbo].[ElementTitle] (
    [BibNum]     BIGINT NOT NULL,
    [ReportDate] DATE   NOT NULL,
    [TitleId]    BIGINT NOT NULL,
    CONSTRAINT [PK_ItemTitle] PRIMARY KEY CLUSTERED ([BibNum] ASC, [ReportDate] ASC),
    CONSTRAINT [FK_ItemTitle_Title] FOREIGN KEY ([TitleId]) REFERENCES [dbo].[Title] ([TitleId])
);

