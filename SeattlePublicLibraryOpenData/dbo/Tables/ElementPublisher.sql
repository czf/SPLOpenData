CREATE TABLE [dbo].[ElementPublisher] (
    [BibNum]      BIGINT NOT NULL,
    [ReportDate]  DATE   NOT NULL,
    [PublisherId] BIGINT NULL,
    CONSTRAINT [PK_ItemPublisher] PRIMARY KEY CLUSTERED ([BibNum] ASC, [ReportDate] ASC),
    CONSTRAINT [FK_ItemPublisher_Publisher] FOREIGN KEY ([PublisherId]) REFERENCES [dbo].[Publisher] ([PublisherId])
);

