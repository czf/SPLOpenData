CREATE TABLE [dbo].[Publisher] (
    [PublisherId]   BIGINT          IDENTITY (1, 1) NOT NULL,
    [PublisherName] NVARCHAR (4000) NULL,
    CONSTRAINT [PK_Publisher] PRIMARY KEY CLUSTERED ([PublisherId] ASC)
);



