CREATE TABLE [dbo].[ElementSubject] (
    [BibNum]     BIGINT NOT NULL,
    [ReportDate] DATE   NOT NULL,
    [SubjectId]  BIGINT NOT NULL,
    CONSTRAINT [PK_ItemSubject] PRIMARY KEY CLUSTERED ([BibNum] ASC, [ReportDate] ASC, [SubjectId] ASC)
);

