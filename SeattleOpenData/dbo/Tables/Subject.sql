CREATE TABLE [dbo].[Subject] (
    [SubjectId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [Subject]   NVARCHAR (4000) NULL,
    CONSTRAINT [PK_Subject] PRIMARY KEY CLUSTERED ([SubjectId] ASC)
);



