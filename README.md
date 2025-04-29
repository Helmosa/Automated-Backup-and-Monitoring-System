# PowerShell-Based Backup and Monitoring System

Automates database backups (MySQL, MS SQL Server) and sends notifications on failure. Designed for Windows environments using PowerShell, with Grafana support for monitoring.

## Features
- Scheduled backups for MySQL and MS SQL Server.
- Email and Slack alerts on failures.
- Parallel execution via PowerShell jobs.
- Can be used on Grafana dashboard for metrics.

## Technologies Used

- Winows PowerShell
- Slack Webhooks
- SMTP


## Setup Instructions

1. Clone the Repository.
2. To configure Databases and Alerts:
 - Open "config.json".
 - Add your MySQL and MS SQL server connection details.
 - Fill in email and Slack credentials under notifications.
3. Run the script by opening Windows PowerShell, navigate to the project folder and type: ".\scripts\Run-Backup.ps1 -ConfigPath .\config\config.json".
