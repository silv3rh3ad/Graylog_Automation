# Description

This are some script that i have been using for automating task in graylog, each script is dedicated to automate manual and repetative work done in graylog.

# Delete Archives

This script is created to deleted any archives which is older then 3 months through an API call.
Before running the script make sure to modify the $AUTH_TOKEN, $URL and graylog_backend_api token in the script, if in case of the $AUTH_TOKEN or graylog_backend_api are not working please ditch the variables and directly update the changes in curl command.

## Usage 
```
./delete_archive.sh
```
![image](https://user-images.githubusercontent.com/91337497/152809592-ae553f19-cd28-4785-a706-6f0e0ec51f6a.png)

One the confirmation has been done of archives listed are the one you want to delete then approve the file confirmation.

![image](https://user-images.githubusercontent.com/91337497/152809707-c7366031-2ad1-4d58-a183-5a478d5c7e31.png)



# Support !! 

Please feel free to drop any suggestion for improving this script or any ideas for differect tasks dedicated to graylog that we can work on developing script for.