CREATE TABLE [dbo].[SourceData] (
    [SourceBibNum]          BIGINT          NULL,
    [SourceTitle]           NVARCHAR (4000) NULL,
    [SourceAuthor]          NVARCHAR (1000) NULL,
    [SourceISBN]            VARCHAR (1000)  NULL,
    [SourcePublicationYear] NVARCHAR (50)   NULL,
    [SourcePublisher]       NVARCHAR (4000) NULL,
    [SourceSubjects]        NVARCHAR (4000) NULL,
    [SourceItemType]        VARCHAR (50)    NULL,
    [SourceItemCollection]  VARCHAR (50)    NULL,
    [SourceFloatingItem]    VARCHAR (10)    NULL,
    [SourceItemLocation]    VARCHAR (50)    NULL,
    [SourceReportDate]      DATE            NULL,
    [SourceItemCount]       INT             NULL,
    [SpidFilter]            SMALLINT        DEFAULT (@@spid) NOT NULL,
    CONSTRAINT [CHK_SourceDataC_SpidFilter] CHECK ([SpidFilter]=@@spid),
    INDEX [ix_SpidFiler] NONCLUSTERED ([SpidFilter])
)
WITH (DURABILITY = SCHEMA_ONLY, MEMORY_OPTIMIZED = ON);

