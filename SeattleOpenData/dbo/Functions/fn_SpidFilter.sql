

CREATE FUNCTION dbo.fn_SpidFilter(@SpidFilter smallint)  
    RETURNS TABLE  
    WITH SCHEMABINDING , NATIVE_COMPILATION  
AS  
    RETURN  
        SELECT 1 AS fn_SpidFilter  
            WHERE @SpidFilter = @@spid;