CREATE SECURITY POLICY [dbo].[SourceData_SpidFilter_Policy]
    ADD FILTER PREDICATE [dbo].[fn_SpidFilter]([SpidFilter]) ON [dbo].[SourceData]
    WITH (STATE = ON);

