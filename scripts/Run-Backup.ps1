param (
    [string]$ConfigPath = "./config/config.json"
)

$config = Get-Content $ConfigPath | ConvertFrom-Json
$jobs = @()

function Send-Alert($message) {
    if ($config.notifications.email.enabled) {
        $smtp = New-Object Net.Mail.SmtpClient($config.notifications.email.smtp_server, $config.notifications.email.port)
        $smtp.EnableSsl = $true
        $smtp.Credentials = New-Object System.Net.NetworkCredential($config.notifications.email.username, $config.notifications.email.password)
        $mail = New-Object Net.Mail.MailMessage
        $mail.From = $config.notifications.email.username
        $mail.To.Add($config.notifications.email.to)
        $mail.Subject = "Backup Failure Alert"
        $mail.Body = $message
        $smtp.Send($mail)
    }
    if ($config.notifications.slack.enabled) {
        Invoke-RestMethod -Uri $config.notifications.slack.webhook_url -Method Post -Body (@{text=$message} | ConvertTo-Json) -ContentType 'application/json'
    }
}

function Backup-MySQL($entry) {
    $cmd = "mysqldump -h $($entry.host) -u $($entry.user) -p$($entry.password) $($entry.database) > backup_$($entry.database).sql"
    try {
        Invoke-Expression $cmd
    } catch {
        Send-Alert "MySQL backup failed for $($entry.database)"
    }
}

function Backup-MSSQL($entry) {
    $cmd = "sqlcmd -S $($entry.server) -U $($entry.user) -P $($entry.password) -Q "BACKUP DATABASE [$($entry.database)] TO DISK='backup_$($entry.database).bak'""
    try {
        Invoke-Expression $cmd
    } catch {
        Send-Alert "MSSQL backup failed for $($entry.database)"
    }
}

foreach ($db in $config.mysql) {
    $jobs += Start-Job { param($db) Backup-MySQL $db } -ArgumentList $db
}
foreach ($db in $config.mssql) {
    $jobs += Start-Job { param($db) Backup-MSSQL $db } -ArgumentList $db
}

Wait-Job $jobs
