-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE dbo.[usp_ProcessSPLDataDictionaryJson]
	@FilePath VARCHAR(max)
AS
BEGIN
SET XACT_ABORT,
    NOCOUNT ON;
  BEGIN TRY
    BEGIN TRANSACTION
    DECLARE @JsonContent NVARCHAR(max);
	 --https://stackoverflow.com/questions/13831472/using-a-variable-in-openrowset-query
    DECLARE @Sql NVARCHAR(max) = 'SELECT @JsonContentOUT = BulkColumn FROM OPENROWSET (BULK ''' + @FilePath + ''', SINGLE_CLOB) AS IMPORT;';
    EXECUTE sp_executesql
      @Sql,
      N'@JsonContentOUT NVARCHAR(MAX) OUTPUT',
      @JsonContentOUT = @JsonContent output;

      
	  CREATE TABLE #SourceData
	  (SourceCode varchar(50), 
		SourceDescription NVARCHAR(1000),
		SourceCodeType VARCHAR(100),
		SourceFormatGroup nvarchar(50),
		SourceFormatSubgroup nvarchar(50),
		SourceCategoryGroup nvarchar(50),
		SourceCategorySubgroup nvarchar(50),
		SourceAgeGroup varchar(100));

	INSERT INTO #SourceData  
	  SELECT 
	  SourceCode, 
	  SourceDescription,
	  SourceCodeType,
	  SourceFormatGroup,
	  SourceFormatSubgroup,
	  SourceCategoryGroup,
	  SourceCategorySubgroup,
	  SourceAgeGroup
	  FROM        Openjson(@JsonContent,N'strict $') A
	  CROSS APPLY Openjson(A.value) 
	  WITH( 
		SourceCode varchar(50) '$.code', 
		SourceDescription NVARCHAR(1000) '$.description',
		SourceCodeType VARCHAR(100) '$.code_type',
		SourceFormatGroup nvarchar(50) '$.format_group',
		SourceFormatSubgroup nvarchar(50) '$.format_subgroup',
		SourceCategoryGroup nvarchar(50) '$.category_group',
		SourceCategorySubgroup nvarchar(50) '$.category_subgroup',
		SourceAgeGroup varchar(100) '$.age_group') b;

	SET @JsonContent = NULL;

	

	--Begin ItemCollection Delete, Update, Insert

	DELETE IC
	FROM dbo.ItemCollection IC
	RIGHT JOIN #SourceData SD ON IC.Code = SD.SourceCode
	WHERE IC.Code IS NULL;

	UPDATE IC
	SET 
		[Description] = SD.SourceDescription,
		FormatGroup = SD.SourceFormatGroup,
		FormatSubgroup = SD.SourceFormatSubgroup,
		CategoryGroup = SD.SourceCategoryGroup,
		CategorySubgroup = SD.SourceCategorySubgroup,
		AgeGroup = SD.SourceAgeGroup
	FROM dbo.ItemCollection IC
	INNER JOIN #SourceData SD ON IC.Code = SD.SourceCode
	WHERE SD.SourceCodeType = 'ItemCollection' ;
	

	INSERT INTO dbo.ItemCollection(
	Code,
	Description,
	FormatGroup,
	FormatSubgroup,
	CategoryGroup,
	CategorySubgroup,
	AgeGroup)
	
	SELECT 
	SourceCode,
	SourceDescription,
	SourceFormatGroup,
	SourceFormatGroup,
	SourceCategoryGroup,
	SourceCategorySubgroup,
	SourceAgeGroup
	FROM #SourceData SD
		WHERE 
		SourceCodeType = 'ItemCollection' AND
		NOT EXISTS(SELECT 1 FROM ItemCollection IC WHERE Code = SourceCode);

	--End ItemCollection Delete, Update, Insert

	--Begin ItemLocation Delete, Update, Insert
	DELETE IL
	FROM dbo.ItemLocation IL
	RIGHT JOIN #SourceData SD ON IL.Code = SD.SourceCode
	WHERE IL.Code IS NULL;

	UPDATE IL
	SET 
		[Description] = SD.SourceDescription,
		FormatGroup = SD.SourceFormatGroup,
		FormatSubgroup = SD.SourceFormatSubgroup,
		CategoryGroup = SD.SourceCategoryGroup,
		CategorySubgroup = SD.SourceCategorySubgroup,
		AgeGroup = SD.SourceAgeGroup
	FROM dbo.ItemCollection IL
	INNER JOIN #SourceData SD ON IL.Code = SD.SourceCode
	WHERE SD.SourceCodeType = 'Location' ;

	INSERT INTO dbo.ItemLocation(
	Code,
	Description,
	FormatGroup,
	FormatSubgroup,
	CategoryGroup,
	CategorySubgroup,
	AgeGroup)
	
	SELECT 
	SourceCode,
	SourceDescription,
	SourceFormatGroup,
	SourceFormatGroup,
	SourceCategoryGroup,
	SourceCategorySubgroup,
	SourceAgeGroup
	FROM #SourceData SD
		WHERE 
		SourceCodeType = 'Location' AND
		NOT EXISTS(SELECT 1 FROM ItemLocation IL WHERE Code = SourceCode);

	--End ItemLocation Delete, Update, Insert

	--Begin ItemType Delete, Update, Insert
	DELETE IT
	FROM dbo.ItemType IT
	RIGHT JOIN #SourceData SD ON IT.Code = SD.SourceCode
	WHERE IT.Code IS NULL;

	UPDATE IT
	SET 
		[Description] = SD.SourceDescription,
		FormatGroup = SD.SourceFormatGroup,
		FormatSubgroup = SD.SourceFormatSubgroup,
		CategoryGroup = SD.SourceCategoryGroup,
		CategorySubgroup = SD.SourceCategorySubgroup,
		AgeGroup = SD.SourceAgeGroup
	FROM dbo.ItemCollection IT
	INNER JOIN #SourceData SD ON IT.Code = SD.SourceCode
	WHERE SD.SourceCodeType = 'ItemType' ;


	INSERT INTO dbo.ItemType(
	Code,
	Description,
	FormatGroup,
	FormatSubgroup,
	CategoryGroup,
	CategorySubgroup,
	AgeGroup)
	
	SELECT 
	SourceCode,
	SourceDescription,
	SourceFormatGroup,
	SourceFormatGroup,
	SourceCategoryGroup,
	SourceCategorySubgroup,
	SourceAgeGroup
	FROM #SourceData SD
		WHERE 
		SourceCodeType = 'ItemType' AND
		NOT EXISTS(SELECT 1 FROM ItemType IT WHERE Code = SourceCode);




      COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
  END CATCH;
END;