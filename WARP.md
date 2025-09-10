# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Author Rule

**IMPORTANT**: When creating any files, scripts, or documentation, always use "Fastdust" as the author name.

## Project Overview

This is a specialized SSL certificate auto-renewal script designed for Ubuntu VPS servers running Nginx. The script uses certbot with the nginx plugin to seamlessly renew Let's Encrypt certificates without service interruption.

## Core Architecture

### Script Structure
- **Single executable**: `cron-job.sh` is the main entry point with modular function design
- **Error handling first**: Uses `set -e` and dedicated error handling functions
- **Logging-centric**: All operations are logged with timestamps to `/tmp/cron-job.log`
- **Template pattern**: The script serves as a framework where actual business logic is added in the designated TODO section

### Key Functions
- `log_message()`: Standardized logging with timestamp formatting
- `handle_error()`: Centralized error logging and script termination
- Main execution block: Where custom job logic should be implemented

## Common Commands

### Development & Testing (Ubuntu VPS)
```bash
# Make script executable
sudo chmod +x /opt/scripts/cron-job.sh

# Test script execution manually (as root)
sudo /opt/scripts/cron-job.sh

# Monitor real-time log output
sudo tail -f /var/log/ssl-renewal.log

# View complete log history
sudo cat /var/log/ssl-renewal.log

# Clear log file for testing
sudo truncate -s 0 /var/log/ssl-renewal.log

# Check nginx status
systemctl status nginx

# Test nginx configuration
nginx -t

# Check existing certificates
certbot certificates

# Test certbot nginx plugin
certbot plugins | grep nginx
```

### Cron Management
```bash
# Edit crontab (use examples from crontab.example)
crontab -e

# List current cron jobs
crontab -l

# Remove all cron jobs (use carefully)
crontab -r

# Check cron service status (Linux)
sudo service cron status

# Check cron service status (macOS)
sudo launchctl list | grep cron
```

### Debugging
```bash
# Check script permissions and details
ls -la cron-job.sh

# View system cron logs (Linux)
tail -f /var/log/cron.log

# View system cron logs (macOS)
tail -f /var/log/system.log | grep cron

# Test script with verbose output
bash -x ./cron-job.sh
```

## Development Patterns

### Adding New Functionality
When extending the script, follow this pattern:
1. Add new functions before the main execution block
2. Use the existing `log_message()` and `handle_error()` functions
3. Replace the TODO section (lines 28-34) with actual business logic
4. Test manually before scheduling with cron
5. Always use absolute paths since cron runs with minimal environment

### Error Handling
- The script uses `set -e` to exit on any error
- Use `handle_error "description"` for custom error reporting
- All errors are automatically logged with timestamps

### Logging Strategy
- Every significant operation should be logged
- Use consistent message format: action + result
- Logs persist in `/tmp/cron-job.log` across executions
- Consider log rotation for long-running deployments

## Environment Considerations

### Cron Environment Limitations
Cron jobs run with a minimal environment. If your custom logic requires:
- Specific PATH variables
- Environment variables
- Shell configurations

Add these to the top of `cron-job.sh`:
```bash
export PATH=/usr/local/bin:/usr/bin:/bin
source ~/.bash_profile  # if needed
```

### File Paths
Always use absolute paths in cron jobs. The script location should be referenced with full path in crontab entries.

## Testing Workflow

1. **Manual execution**: Always test `./cron-job.sh` first
2. **Log verification**: Check `/tmp/cron-job.log` for expected output
3. **Cron testing**: Start with frequent schedule (every minute) for testing
4. **Production deployment**: Update to actual schedule after verification

## Schedule Examples (from crontab.example)

- Testing: `* * * * *` (every minute)
- Regular tasks: `*/5 * * * *` (every 5 minutes)  
- Daily tasks: `30 2 * * *` (daily at 2:30 AM)
- Weekly tasks: `0 9 * * 1` (Mondays at 9 AM)
- Monthly tasks: `0 0 1 * *` (1st of month at midnight)

## File Structure Context

```
cron-job-project/
├── cron-job.sh        # Executable script with logging framework
├── crontab.example    # Schedule templates and cron format reference
├── README.md          # Comprehensive setup and usage documentation
└── .gitignore         # Excludes logs, temp files, and OS-specific files
```

The project intentionally maintains a minimal structure focused on the core cron job functionality while providing comprehensive documentation and examples for common use cases.
