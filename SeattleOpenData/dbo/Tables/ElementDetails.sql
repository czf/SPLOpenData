CREATE TABLE [dbo].[ElementDetails] (
    [BibNum]            BIGINT NOT NULL,
    [ReportDate]        DATE   NOT NULL,
    [TitleId]           BIGINT NULL,
    [AuthorId]          BIGINT NULL,
    [PublisherId]       BIGINT NULL,
    [PublicationYearId] INT    NULL,
    CONSTRAINT [PK_ElementDetails] PRIMARY KEY CLUSTERED ([BibNum] ASC, [ReportDate] ASC),
    CONSTRAINT [FK_ElementDetails_Author] FOREIGN KEY ([AuthorId]) REFERENCES [dbo].[Author] ([AuthorId]),
    CONSTRAINT [FK_ElementDetails_PublicationYear] FOREIGN KEY ([PublicationYearId]) REFERENCES [dbo].[PublicationYear] ([PublicationYearId]),
    CONSTRAINT [FK_ElementDetails_Publisher] FOREIGN KEY ([PublisherId]) REFERENCES [dbo].[Publisher] ([PublisherId]),
    CONSTRAINT [FK_ElementDetails_Title] FOREIGN KEY ([TitleId]) REFERENCES [dbo].[Title] ([TitleId])
);



