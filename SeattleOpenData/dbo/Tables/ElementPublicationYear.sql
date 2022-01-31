CREATE TABLE [dbo].[ElementPublicationYear] (
    [BibNum]            BIGINT NOT NULL,
    [ReportDate]        DATE   NOT NULL,
    [PublicationYearId] INT    NULL,
    CONSTRAINT [PK_ItemPublicationYear] PRIMARY KEY CLUSTERED ([BibNum] ASC, [ReportDate] ASC),
    CONSTRAINT [FK_ItemPublicationYear_PublicationYear] FOREIGN KEY ([PublicationYearId]) REFERENCES [dbo].[PublicationYear] ([PublicationYearId])
);

