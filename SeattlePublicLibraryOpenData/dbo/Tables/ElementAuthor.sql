CREATE TABLE [dbo].[ElementAuthor] (
    [BibNum]     BIGINT NOT NULL,
    [ReportDate] DATE   NOT NULL,
    [AuthorId]   BIGINT NULL,
    CONSTRAINT [PK_ItemAuthor] PRIMARY KEY CLUSTERED ([BibNum] ASC, [ReportDate] ASC),
    CONSTRAINT [FK_ItemAuthor_Author] FOREIGN KEY ([AuthorId]) REFERENCES [dbo].[Author] ([AuthorId])
);

