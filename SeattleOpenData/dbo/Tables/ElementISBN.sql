﻿CREATE TABLE [dbo].[ElementISBN] (
    [BibNum]     BIGINT       NOT NULL,
    [ReportDate] DATE         NOT NULL,
    [ISBN]       VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_ItemISBN] PRIMARY KEY CLUSTERED ([BibNum] ASC, [ReportDate] ASC, [ISBN] ASC)
);



