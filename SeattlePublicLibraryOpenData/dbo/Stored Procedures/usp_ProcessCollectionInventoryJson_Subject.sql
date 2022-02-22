
CREATE   PROCEDURE  [dbo].[usp_ProcessCollectionInventoryJson_Subject]
@FilePath VARCHAR(max)
AS
BEGIN
--declare  
--set @FilePath = 'C:\dev\solutions\SPLOpenData\target\libraryResultTemp_0.json'
SET XACT_ABORT,
    NOCOUNT ON;
  BEGIN TRY
  print( 'START');
  		IF EXISTS(
			SELECT 1 
			FROM dbo.ProcessedFile_subject
			WHERE FilePath = @FilePath
		)
		BEGIN
			RETURN;
		END;
			  
BEGIN TRANSACTION;
	INSERT INTO dbo.ProcessedFile_subject(FilePath)
	VALUES(@FilePath);
	PRINT 'ProcessedFile_subject'
    DECLARE @JsonContent NVARCHAR(max);
	 --https://stackoverflow.com/questions/13831472/using-a-variable-in-openrowset-query
    DECLARE @Sql NVARCHAR(max) = 'SELECT @JsonContentOUT = BulkColumn FROM OPENROWSET (BULK ''' + @FilePath + ''', SINGLE_CLOB) AS IMPORT;';
    EXECUTE sp_executesql
      @Sql,
      N'@JsonContentOUT NVARCHAR(MAX) OUTPUT',
      @JsonContentOUT = @JsonContent output;
	  PRINT 'DYNAMIC SQL'
	  


	  CREATE TABLE #SourceData
	  (SourceBibNum BIGINT,
		SourceSubjects nvarchar(4000) ,
		SourceReportDate DATE);

	INSERT INTO #SourceData
	(
	SourceBibNum,
	SourceSubjects,
	SourceReportDate)
	
	  Select   SourceBibNum,
		ISNULL(SourceSubjects,''),		SourceReportDate 
	  FROM        Openjson(@JsonContent,N'strict $') A
	  CROSS APPLY Openjson(A.value) 
	  WITH( 
		SourceBibNum BIGINT '$.bibnum', 
		SourceSubjects nvarchar(4000) '$.subjects',
		SourceReportDate date '$.reportdate') b;

		SET @JsonContent = NULL;
		PRINT 'INSERT INTO #SourceData'
		

		BEGIN TRANSACTION
		
		
		
			--INSERT INTO dbo.Subject(Subject)
			--SELECT DISTINCT TRIM(value)  FROM #SourceData SD
			--cross apply STRING_SPLIT(SD.SourceSubjects,',') subject
			--WHERE NOT EXISTS(SELECT 1 FROM Subject S WHERE S.Subject = TRIM(value) );

			PRINT 'SUBJECT'
			INSERT INTO dbo.ElementSubject
			SELECT DISTINCT SourceBibNum, SourceReportDate, S.SubjectId FROM #SourceData SD
			CROSS APPLY STRING_SPLIT(SD.SourceSubjects,',') ss
			INNER JOIN [Subject] S ON s.[Subject] = ss.value
			WHERE NOT EXISTS(SELECT 1 FROM ElementSubject E WHERE E.BibNum = SD.SourceBibNum AND E.ReportDate = SD.SourceReportDate AND E.SubjectId = s.SubjectId)
			option(querytraceon 2332);
			PRINT 'ElementSubject'
			COMMIT;
			PRINT 'ELMENTDETAIL START'

		--INSERT INTO dbo.ElementDetail WITH(TABLOCK)
		--SELECT DISTINCT
		--	SourceBibNum,
		--	SourceReportDate,
		--	TitleId,
		--	AuthorId,
		--	PublisherId,
		--	PublicationYearId
		--FROM  
		--	 #SourceData SD 	
		--INNER JOIN Author A ON A.Name = SD.SourceAuthor
		--INNER JOIN Title T ON T.Title = SD.SourceTitle
		--INNER JOIN PublicationYear PY ON PY.PublicationYear = SD.SourcePublicationYear
		--INNER JOIN Publisher P ON P.PublisherName = SD.SourcePublisher
		--WHERE NOT EXISTS( SELECT 1 FROM dbo.ElementDetail ED WHERE ED.BibNum = SD.SourceBibNum and ED.ReportDate = SD.SourceReportDate)
		--option(querytraceon 2332);

		--EXCEPT 
		--SELECT DISTINCT
		--	SourceBibNum,
		--	SourceReportDate,
		--	TitleId,
		--	AuthorId,
		--	PublisherId,
		--	PublicationYearId
		--FROM 
		--	 #SourceData
		--	SD
		--inner join dbo.ElementDetail ED on ED.BibNum = SD.SourceBibNum and ED.ReportDate = SD.SourceReportDate



		PRINT 'DONE'
	
      COMMIT TRANSACTION;

  PRINT 'ALTER INDEX'
  ALTER INDEX PK_ItemSubject ON dbo.ElementSubject REBUILD;
  
  PRINT 'INDEX DONE'
  END TRY
  BEGIN CATCH
	  PRINT 'IN CATCH';
	  THROW;
  END CATCH;
END;