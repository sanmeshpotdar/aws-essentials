#!/bin/bash

##Here's a Linux script that moves Nginx access and error logs to an AWS S3 bucket using a cronjob:

bash#!/bin/bash

# Set the AWS credentials*AWS_ACCESS_KEY_ID="your_access_key_id"
AWS_SECRET_ACCESS_KEY="your_secret_access_key"

*# Set the S3 bucket name*S3_BUCKET="your_s3_bucket_name"

*# Set the log directory*LOG_DIR="/var/log/nginx"

*# Set the date for the log files*DATE=$(date +"%Y-%m-%d")*# Move the access log*
aws s3 mv $LOG_DIR/access.log s3://$S3_BUCKET/nginx/access/$DATE.log --aws-access-key-id $AWS_ACCESS_KEY_ID --aws-secret-access-key $AWS_SECRET_ACCESS_KEY

*# Move the error log*
aws s3 mv $LOG_DIR/error.log s3://$S3_BUCKET/nginx/error/$DATE.log --aws-access-key-id $AWS_ACCESS_KEY_ID --aws-secret-access-key $AWS_SECRET_ACCESS_KEY

*# Remove the local log files*rm $LOG_DIR/access.log $LOG_DIR/error.log`

Here's how the script works:

1. Set the AWS credentials and S3 bucket name.
2. Set the log directory where Nginx stores the access and error logs.
3. Get the current date for the log file names.
4. Use the **`aws`** command-line tool to move the access log to the S3 bucket with the date as the file name.
5. Use the **`aws`** command-line tool to move the error log to the S3 bucket with the date as the file name.
6. Remove the local log files after they have been moved to the S3 bucket.

To set up a cronjob to run this script, follow these steps:

1. Save the script to a file, for example, **`move_nginx_logs.sh`**.
2. Make the script executable with **`chmod +x move_nginx_logs.sh`**.
3. Open the crontab editor with **`crontab -e`**.
4. Add a new line to the crontab, for example, **`0 0 * * * /path/to/move_nginx_logs.sh`** to run the script every day at midnight.
5. Save and exit the crontab editor.

Make sure to replace

```
your_access_key_id
```

,

```
your_secret_access_key
```

, and

```
your_s3_bucket_name
```

with your actual AWS credentials and S3 bucket name.Note: This script assumes that you have the AWS CLI installed and configured on your system. If not, you can install it with

```
sudo apt-get install awscli
```

(on Ubuntu/Debian) or

```
sudo yum install awscli
```

(on CentOS/RHEL).

To move Nginx access and error logs to an AWS S3 bucket using a cron job, you can follow these steps:

1. **Install AWS CLI**: Ensure that you have the AWS CLI installed and configured on your server.
2. **Create a Script**: Write a script to move the logs to the S3 bucket.
3. **Set Up a Cron Job**: Schedule the script to run periodically using cron.

### **Step-by-Step Instructions**

### **1. Install AWS CLI**

If you haven't already installed the AWS CLI, you can do so with the following commands:

```
shCopy code
sudo apt-get update
sudo apt-get install awscli -y

```

Then, configure the AWS CLI with your credentials:
shCopy code
aws configure

### **2. Create the Script**

Create a shell script to move the logs to the S3 bucket. Save this script as **`move_logs_to_s3.sh`** in a convenient location, for example, **`/usr/local/bin`**.

#!/bin/bash

# Variables
S3_BUCKET="s3://your-bucket-name/nginx-logs"
LOG_DIR="/var/log/nginx"
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")

# Compress logs
tar -czf /tmp/nginx-logs-$TIMESTAMP.tar.gz $LOG_DIR/access.log $LOG_DIR/error.log

# Upload to S3
aws s3 cp /tmp/nginx-logs-$TIMESTAMP.tar.gz $S3_BUCKET/

# Check if the upload was successful
if [ $? -eq 0 ]; then
  # Clear logs if upload was successful
  > $LOG_DIR/access.log
  > $LOG_DIR/error.log
else
  echo "Failed to upload logs to S3" >&2
fi

# Remove the local compressed log file
rm /tmp/nginx-logs-$TIMESTAMP.tar.gz

Make sure to give the script executable permissions:
shCopy code
chmod +x /usr/local/bin/move_logs_to_s3.sh

### **3. Set Up a Cron Job**

Edit the crontab to schedule the script. Run:

```
shCopy code
crontab -e

```

Add the following line to run the script daily at midnight (adjust the schedule as needed):

```
shCopy code
0 0 * * * /usr/local/bin/move_logs_to_s3.sh

```

### **Explanation**

- The script sets up variables for the S3 bucket, log directory, and a timestamp for unique log filenames.
- It compresses the **`access.log`** and **`error.log`** files into a single tar.gz file with a timestamp.
- The script uses the **`aws s3 cp`** command to upload the compressed log file to the specified S3 bucket.
- If the upload is successful, it clears the original log files to prevent them from growing indefinitely.
- Finally, it removes the local compressed log file to save space.

### **Additional Considerations**

- **Permissions**: Ensure that the script has the necessary permissions to read the log files and write to the S3 bucket.
- **Log Rotation**: You might want to integrate this script with a log rotation tool like **`logrotate`** for more sophisticated log management.
- **Error Handling**: Enhance error handling to cover various edge cases and potential issues.

This setup will help you regularly move your Nginx logs to an S3 bucket, ensuring that your logs are backed up and your server's storage is managed effectively.

https://www.youtube.com/watch?v=wJJnTGHmPYQ

https://www.digitalocean.com/community/tutorials/how-to-use-logrotate-and-s3cmd-to-archive-logs-to-object-storage-on-ubuntu-16-04

https://jainsaket-1994.medium.com/installing-crontab-on-amazon-linux-2023-ec2-98cf2708b171

#!/bin/bash

# Set the AWS credentials

AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""

# Set the S3 bucket name

S3_BUCKET="linux-nginx-logs"

# Set the log directory

LOG_DIR="/var/log/nginx"

# Set the date for the log files

DATE=$(date +"%Y-%m-%d")

# Move the access log

aws s3 mv $LOG_DIR/access.log s3://$S3_BUCKET/nginx/access/$DATE.log --aws-access-key-id $AWS_ACCESS_KEY_ID --aws-secret-access-key $AWS_SECRET_ACCESS_KEY

# Move the error log

aws s3 mv $LOG_DIR/error.log s3://$S3_BUCKET/nginx/error/$DATE.log --aws-access-key-id $AWS_ACCESS_KEY_ID --aws-secret-access-key $AWS_SECRET_ACCESS_KEY

# Remove the local log files

rm $LOG_DIR/access.log $LOG_DIR/error.log
