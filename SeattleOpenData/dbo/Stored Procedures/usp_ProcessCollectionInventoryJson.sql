SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Description: process json into table
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_ProcessCollectionInventoryJson]
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

      	  Select * 
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




      COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
  END CATCH;