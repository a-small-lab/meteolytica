#opens the package utilized to navigate through MySQL
library(RODBC)

#connects to the database of your choice
#note: this must be filled in with the appropriate names, see comment at end
db_connect <- odbcDriverConnect(paste(
  'driver = your_driver',
  'server = your_server',
  'database = your_database',
  'User ID = your_user_ID',
  'Password = your_Password',
  'trusted_connection = true', sep = ";"),
  readOnlyOptimize = TRUE,
  rows_at_time = 1,
  believeNRows = FALSE)

#-B seperates the columns with tabs and starts a new line at the end of each row
#-e runs the command after you have logged into MySQL

#separate multiple columns, and tables with a comma
#if you have 2 tables containing the same column name in each your_column 
#will be typed as your_table.your_column in the place of your.column

#sed commands
#s/\t/","/g;s/^/"/ searchs for and fills each tab with a ","
#;s/$/"/ places a " at the start of each line
#;s/\n//g places a " at the end of each line

#may not work experimenting from the information provided in the 
#"Bottom-up creation..." post
#note: this must be filled in with the appropriate names, see comment at end
specified data <- sqlQuery(db_connect, "mysql ?u your_username ?p your_database -B -e 
                           ?SELECT your_columns 
                           FROM your_tables 
                           WHERE your_condition1 AND your_condition2? 
                           | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g'
                           > your_filename.csv", as.is = TRUE)

#all places where the variable name starts with your_ you must change to be 
#specific to you