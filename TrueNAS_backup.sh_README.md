What this script does:

1.Calls the TrueNAS API to export the system configuration
2.Optionally includes the secret seed and/or root SSH authorized keys
3.Writes backups as timestamped .tar files
4.Verifies the download completed successfully
5.Removes backups older than a defined number of days

The output is equivalent to using System → General → Save Config in the TrueNAS UI, but suitable for automation.

Requirements:

Bash
curl
A TrueNAS API key with sufficient privileges
Network access to the TrueNAS API endpoint


Configuration:
At the top of the script, configure the following values:


TRUENAS_HOST:
The base URL of your TrueNAS system (HTTP or HTTPS).


API_KEY:
API key generated in the TrueNAS UI.


BACKUP_DIR:
Directory where backup files will be stored.


RETENTION_DAYS:
Number of days to keep backups before pruning old files.



Export options:
The script allows you to control what sensitive data is included in the backup.


EXPORT_SECRET_SEED:
When set to true, the backup includes the secret seed.
This allows user passwords to be reconstructed after a restore.


EXPORT_ROOT_AUTH_KEYS:
When set to true, the backup includes /root/.ssh/authorized_keys.


By default, root SSH authorized keys are excluded. This makes the backup less risky if it is stored off-system or synced elsewhere.
If you want a fully portable restore including SSH access, it’s easy to change:
EXPORT_ROOT_AUTH_KEYS=false

to:
EXPORT_ROOT_AUTH_KEYS=true

Choose this based on your security model and where backups are stored.

TLS / certificates
If your TrueNAS system uses a self-signed certificate, you can temporarily allow insecure TLS by setting:
INSECURE_TLS=true

Using a proper CA-trusted certificate is strongly recommended instead.

Encrypted pools
This script has been tested with a encrypted pool.
After a clean TrueNAS reinstall, restoring a configuration backup that includes the secret seed was sufficient to unlock the encrypted pool successfully. This makes the script suitable for disaster recovery scenarios where both configuration and encrypted storage need to be restored.

Retention policy
After a successful backup, the script deletes any matching backup files older than the specified retention period. This keeps the backup directory from growing indefinitely.

Security notes

Configuration backups contain sensitive information
Treat backup files like credentials
Restrict permissions on the backup directory
Protect API keys and do not hard-code them in public repositories


License
Use, modify, and adapt as you see fit. 

No warranty is provided.