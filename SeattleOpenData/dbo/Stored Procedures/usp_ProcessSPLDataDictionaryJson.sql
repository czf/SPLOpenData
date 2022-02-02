-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE dbo.[usp_ProcessSPLDataDictionaryJson]
	@FilePath VARCHAR(max)
AS
SET XACT_ABORT,
    NOCOUNT ON;
  BEGIN TRY;
    BEGIN TRANSACTION;
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