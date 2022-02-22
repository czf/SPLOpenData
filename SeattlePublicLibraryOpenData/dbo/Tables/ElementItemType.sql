CREATE TABLE [dbo].[ElementItemType] (
    [BibNum]       BIGINT       NOT NULL,
    [ReportDate]   DATE         NOT NULL,
    [ItemTypeCode] VARCHAR (50) NULL,
    CONSTRAINT [PK_ElementItemType] PRIMARY KEY CLUSTERED ([BibNum] ASC, [ReportDate] ASC),
    CONSTRAINT [FK_ElementItemType_ItemType] FOREIGN KEY ([ItemTypeCode]) REFERENCES [dbo].[ItemType] ([Code])
);

