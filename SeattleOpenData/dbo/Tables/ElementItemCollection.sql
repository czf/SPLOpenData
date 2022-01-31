CREATE TABLE [dbo].[ElementItemCollection] (
    [BibNum]             BIGINT       NOT NULL,
    [ReportDate]         DATE         NOT NULL,
    [ItemCollectionCode] VARCHAR (50) NULL,
    CONSTRAINT [PK_ElementItemCollection] PRIMARY KEY CLUSTERED ([BibNum] ASC, [ReportDate] ASC)
);

