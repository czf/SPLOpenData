CREATE   PROCEDURE  dbo.[usp_ProcessCollectionInventoryJson]
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
			FROM dbo.ProcessedFile
			WHERE FilePath = @FilePath
		)
		BEGIN
			RETURN;
		END;

BEGIN TRANSACTION;
	INSERT INTO dbo.ProcessedFile(FilePath)
	VALUES(@FilePath);
	PRINT' PROCESSEDFILE'
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
	  SourceTitle NVARCHAR(4000) ,
		SourceAuthor NVARCHAR(1000) ,
		SourceISBN varchar(1000) ,
		SourcePublicationYear nvarchar(50),
		SourcePublisher nvarchar(4000) ,
		SourceSubjects nvarchar(4000) ,
		SourceItemType varchar(50) ,
		SourceItemCollection varchar(50) ,
		SourceFloatingItem varchar(10) ,
		SourceItemLocation varchar(50) ,
		SourceReportDate DATE,
		SourceItemCount INT);

	INSERT INTO #SourceData
	
	  Select SourceBibNum,
		ISNULL(SourceTitle,''),
		ISNULL(SourceAuthor,''),
		ISNULL(SourceISBN,''),
		ISNULL(SourcePublicationYear,''),
		ISNULL(SourcePublisher,''),
		ISNULL(SourceSubjects,''),
		ISNULL(SourceItemType,''),
		ISNULL(SourceItemCollection,''),
		ISNULL(SourceFloatingItem ,''),
		ISNULL(SourceItemLocation,''),
		SourceReportDate ,
		SourceItemCount
	  FROM        Openjson(@JsonContent,N'strict $') A
	  CROSS APPLY Openjson(A.value) 
	  WITH( 
		SourceBibNum BIGINT '$.bibnum', 
		SourceTitle NVARCHAR(4000) '$.title',
		SourceAuthor NVARCHAR(1000) '$.author',
		SourceISBN varchar(1000) '$.isbn',
		SourcePublicationYear nvarchar(50) '$.publicationyear',
		SourcePublisher nvarchar(4000) '$.publisher',
		SourceSubjects nvarchar(4000) '$.subjects',
		SourceItemType varchar(50) '$.itemtype',
		SourceItemCollection varchar(50) '$.itemcollection',
		SourceFloatingItem varchar(10) '$.floatingitem',
		SourceItemLocation varchar(50) '$.itemlocation',
		SourceReportDate date '$.reportdate',
		SourceItemCount int '$.itemcount') b;

		SET @JsonContent = NULL;
		PRINT 'INSERT INTO #SOURCEDATA'


		BEGIN TRANSACTION
		PRINT 'BEGIN REFERENCE TABLES'
			INSERT INTO dbo.Author(Name)
			SELECT DISTINCT SourceAuthor FROM #SourceData SD
			WHERE NOT EXISTS(SELECT 1 FROM Author A where Name = SourceAuthor);
		PRINT 'AUTHOR'
			INSERT INTO dbo.Title(Title)
			SELECT DISTINCT SourceTitle FROM #SourceData SD
			WHERE NOT EXISTS(SELECT 1 FROM Title A where A.Title = SourceTitle);
			PRINT 'TITLE'
			INSERT INTO dbo.PublicationYear(PublicationYear)
			SELECT DISTINCT SourcePublicationYear FROM #SourceData SD
			WHERE NOT EXISTS(SELECT 1 FROM PublicationYear A where A.PublicationYear = SourcePublicationYear);
			PRINT 'PUBLICATIONYEAR'
			INSERT INTO dbo.Publisher(PublisherName)
			SELECT DISTINCT SourcePublisher FROM #SourceData SD
			WHERE NOT EXISTS(SELECT 1 FROM Publisher A where A.PublisherName = SourcePublisher);
			PRINT 'PUBLISHER'
		
			INSERT INTO dbo.Subject(Subject)
			SELECT DISTINCT TRIM(value)  FROM #SourceData SD
			cross apply STRING_SPLIT(SD.SourceSubjects,',') subject
			WHERE NOT EXISTS(SELECT 1 FROM Subject S WHERE S.Subject = TRIM(value) );

			PRINT 'SUBJECT'
			INSERT INTO dbo.ElementISBN
			SELECT DISTINCT SourceBibNum, SourceReportDate, TRIM(value) FROM #SourceData SD
			CROSS APPLY STRING_SPLIT(SD.SourceISBN,',') isbn
			WHERE NOT EXISTS(SELECT 1 FROM ElementISBN E WHERE E.BibNum = SD.SourceBibNum AND E.ReportDate = SD.SourceReportDate AND E.ISBN = TRIM(value))
			PRINT 'ELEMENTISBN'
			COMMIT;
			PRINT 'ELMENTDETAIL START'

		INSERT INTO dbo.ElementDetail 
		SELECT DISTINCT
			SourceBibNum,
			SourceReportDate,
			TitleId,
			AuthorId,
			PublisherId,
			PublicationYearId
		FROM 
			 #SourceData 
			SD
		INNER JOIN Author A ON A.Name = SD.SourceAuthor
		INNER JOIN Title T ON T.Title = SD.SourceTitle
		INNER JOIN PublicationYear PY ON PY.PublicationYear = SD.SourcePublicationYear
		INNER JOIN Publisher P ON P.PublisherName = SD.SourcePublisher
		EXCEPT 
		SELECT DISTINCT
			SourceBibNum,
			SourceReportDate,
			TitleId,
			AuthorId,
			PublisherId,
			PublicationYearId
		FROM 
			 #SourceData 
			SD
		inner join dbo.ElementDetail ED on ED.BibNum = SD.SourceBibNum and ED.ReportDate = SD.SourceReportDate

		PRINT 'ELEMENTINVENTORY START'
		INSERT INTO dbo.ElementInventory(
		BibNum,
		ReportDate,
		ItemTypeCode,
		ItemCollectionCode,
		ItemLocationCode,
		FloatingItem,
		ItemCount)
		SELECT 
			SD.SourceBibNum,
			SD.SourceReportDate,
			SD.SourceItemType,
			SD.SourceItemCollection,
			SD.SourceItemLocation,
			CASE WHEN SD.SourceFloatingItem = 'Floating' THEN 1 ELSE 0 END AS SourceIsFloatingItem,
			SD.SourceItemCount
		FROM #SourceData SD
		PRINT 'DONE'
		drop table #SourceData
      COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
	  PRINT 'IN CATCH';
	  THROW;
  END CATCH;
END;