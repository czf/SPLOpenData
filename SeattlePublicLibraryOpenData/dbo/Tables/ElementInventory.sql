CREATE TABLE [dbo].[ElementInventory] (
    [BibNum]             BIGINT       NOT NULL,
    [ReportDate]         DATE         NOT NULL,
    [ItemTypeCode]       VARCHAR (50) NOT NULL,
    [ItemCollectionCode] VARCHAR (50) NOT NULL,
    [ItemLocationCode]   VARCHAR (50) NOT NULL,
    [FloatingItem]       BIT          NOT NULL,
    [ItemCount]          INT          NOT NULL,
    CONSTRAINT [PK_ElementInventory] PRIMARY KEY CLUSTERED ([BibNum] ASC, [ReportDate] ASC, [ItemTypeCode] ASC, [ItemCollectionCode] ASC, [ItemLocationCode] ASC, [FloatingItem] ASC),
    CONSTRAINT [FK_ElementInventory_ItemCollection] FOREIGN KEY ([ItemCollectionCode]) REFERENCES [dbo].[ItemCollection] ([Code]),
    CONSTRAINT [FK_ElementInventory_ItemLocation] FOREIGN KEY ([ItemLocationCode]) REFERENCES [dbo].[ItemLocation] ([Code]),
    CONSTRAINT [FK_ElementInventory_ItemType] FOREIGN KEY ([ItemTypeCode]) REFERENCES [dbo].[ItemType] ([Code])
);

