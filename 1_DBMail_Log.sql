USE msdb ;  
GO  

-- Show the subject, the time that the mail item row was last  
-- modified, and the log information.  
-- Join sysmail_faileditems to sysmail_event_log   
-- on the mailitem_id column.  
-- In the WHERE clause list items where danw was in the recipients,  
-- copy_recipients, or blind_copy_recipients.  
-- These are the items that would have been sent  
-- to danw.  

--SELECT items.subject,  
--    items.last_mod_date  
--    ,l.description FROM dbo.sysmail_faileditems as items  
--INNER JOIN dbo.sysmail_event_log AS l  
--    ON items.mailitem_id = l.mailitem_id  
--WHERE items.recipients LIKE '%tanda%'    
--    OR items.copy_recipients LIKE '%tanda%'   
--    OR items.blind_copy_recipients LIKE '%tanda%'  
--GO  

--select * from dbo.sysmail_event_log where log_date >= '2020-10-31'
--select * from dbo.sysmail_log where log_date >= getdate()-3
select m.* from (select 'Failed' AS [Sent_Failed], mailitem_id, CONVERT(VARCHAR,send_request_date, 101) AS SendDate, recipients, ISNULL(copy_recipients,'') AS copy_recipients, ISNULL(blind_copy_recipients,'') AS blind_copy_recipients, [subject], body  from dbo.sysmail_faileditems where send_request_date >= getdate()-2
UNION ALL
select 'Sent' AS [Sent_Failed], mailitem_id, CONVERT(VARCHAR,send_request_date, 101) AS SendDate, recipients, ISNULL(copy_recipients, '') AS copy_recipients, ISNULL(blind_copy_recipients,'') AS blind_copy_recipients, [subject], body from dbo.sysmail_sentitems where send_request_date >= getdate()-2
) m ORDER BY [Sent_Failed], SendDate, recipients



