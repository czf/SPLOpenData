--use SeattleOpenData;
create   procedure t 
AS
declare  @FilePath VARCHAR(max)
set @FilePath = 'C:\dev\solutions\SPLOpenData\target\libraryResultTemp_0.json'


BEGIN TRANSACTION;
    DECLARE @JsonContent NVARCHAR(max);
	 --https://stackoverflow.com/questions/13831472/using-a-variable-in-openrowset-query
    DECLARE @Sql NVARCHAR(max) = 'SELECT @JsonContentOUT = BulkColumn FROM OPENROWSET (BULK ''' + @FilePath + ''', SINGLE_CLOB) AS IMPORT;';
    EXECUTE sp_executesql
      @Sql,
      N'@JsonContentOUT NVARCHAR(MAX) OUTPUT',
      @JsonContentOUT = @JsonContent output;

	  select @JsonContent

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
	  SourceTitle,
		SourceAuthor,
		SourceISBN,
		SourcePublicationYear,
		SourcePublisher,
		SourceSubjects,
		SourceItemType,
		SourceItemCollection,
		SourceFloatingItem ,
		SourceItemLocation,
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
		
		INSERT INTO dbo.Author(Name)
		SELECT DISTINCT SourceAuthor FROM #SourceData SD
		WHERE NOT EXISTS(SELECT 1 FROM Author A where Name = SourceAuthor);
		
		INSERT INTO dbo.Title(Title)
		SELECT DISTINCT SourceTitle FROM #SourceData SD
		WHERE NOT EXISTS(SELECT 1 FROM Title A where A.Title = SourceTitle);

		INSERT INTO dbo.PublicationYear(PublicationYear)
		SELECT DISTINCT SourcePublicationYear FROM #SourceData SD
		WHERE NOT EXISTS(SELECT 1 FROM PublicationYear A where A.PublicationYear = SourcePublicationYear);

		INSERT INTO dbo.Publisher(PublisherName)
		SELECT DISTINCT SourcePublisher FROM #SourceData SD
		WHERE NOT EXISTS(SELECT 1 FROM Publisher A where A.PublisherName = SourcePublisher);

		
		INSERT INTO dbo.Subject(Subject)
		SELECT DISTINCT TRIM(value)  FROM #SourceData SD
		cross apply STRING_SPLIT(SD.SourceSubjects,',') subject
		WHERE NOT EXISTS(SELECT 1 FROM Subject S WHERE S.Subject = TRIM(value) );

		INSERT INTO dbo.ElementISBN
		SELECT DISTINCT SourceBibNum, SourceReportDate, TRIM(value) FROM #SourceData SD
		CROSS APPLY STRING_SPLIT(SD.SourceISBN,',') isbn
		WHERE NOT EXISTS(SELECT 1 FROM ElementISBN E WHERE E.BibNum = SD.SourceBibNum AND E.ReportDate = SD.SourceReportDate AND E.ISBN = TRIM(value))

		INSERT INTO dbo.ElementDetails 
		SELECT DISTINCT
			SourceBibNum,
			SourceReportDate,
			TitleId,
			AuthorId,
			PublisherId,
			PublicationYearId
		FROM #SourceData SD
		INNER JOIN Author A ON A.Name = SD.SourceAuthor
		INNER JOIN Title T ON T.Title = SD.SourceTitle
		INNER JOIN PublicationYear PY ON PY.PublicationYear = SD.SourcePublicationYear
		INNER JOIN Publisher P ON P.PublisherName = SD.SourcePublisher
		WHERE NOT EXISTS( SELECT 1 FROM dbo.ElementDetails ED WHERE ED.BibNum = SD.SourceBibNum and ED.ReportDate = SD.SourceReportDate)

		
		drop table #SourceData
      COMMIT TRANSACTION;

	  
	  select * from elementisbn