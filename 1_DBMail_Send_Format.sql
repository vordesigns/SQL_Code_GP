Exec sp_send_dbmail  @profile_name =  'Maxxess Support Renewals' 
     , @recipients = 'tandaya@ssgnet.com'  
     , @copy_recipients =  'tmarcure@maxxess-systems.com'  
    --[ , [ @blind_copy_recipients = ] 'blind_copy_recipient [ ; ...n ]' ]  
    --, @from_address = 'noreplay@maxxess-systems.com'  
    --[ , [ @reply_to = ] 'reply_to' ]   
     , @subject = 'Maxxess:  Request for information Renewal Message'  
     , @body = 'This is a test of the  HTML capabilities of database mail<br>
	--<br>
	Hi, <br>
<br>
If you could tell me which database and table I should look at, I can start building a 90, 60, 30, 0 days query to generate your renewal messages.<br>
<br>
Once everyon is happy with the output, I can schedule it to run once a day and I can also have a report stating what went out once a day as well.<br>
<br>
Let me know.  <br>
Regards,
<br>
Tim
' 
    --[ , [ @body_format = ] 'body_format' ]  -- TEXT (Default) / HTML
     , @body_format = 'HTML'  
    --[ , [ @importance = ] 'importance' ]  -- LOW / NORMAL (Default) / HIGH
    --[ , [ @sensitivity = ] 'sensitivity' ]  -- Normal (Default) / Personal / Private / Confidential
    --[ , [ @file_attachments = ] 'attachment [ ; ...n ]' ]  
    --[ , [ @query = ] 'query' ]  
    --[ , [ @execute_query_database = ] 'execute_query_database' ]  
    --[ , [ @attach_query_result_as_file = ] attach_query_result_as_file ]  
    --[ , [ @query_attachment_filename = ] query_attachment_filename ]  
    --[ , [ @query_result_header = ] query_result_header ]  
    --[ , [ @query_result_width = ] query_result_width ]  
    --[ , [ @query_result_separator = ] 'query_result_separator' ]  
    --[ , [ @exclude_query_output = ] exclude_query_output ]  
    --[ , [ @append_query_error = ] append_query_error ]  
    --[ , [ @query_no_truncate = ] query_no_truncate ]   
    --[ , [ @query_result_no_padding = ] @query_result_no_padding ]   
    --[ , [ @mailitem_id = ] mailitem_id ] [ OUTPUT ]  