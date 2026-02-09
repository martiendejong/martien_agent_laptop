#!/bin/bash
# Upload Art Revisionist to Staging via FTP

FTP_HOST="ftp.artrevisionist.com"
FTP_USER="info@artrevisionist.com"
FTP_PASS="u48zm5dRaDTxVc9wdSbW"
REMOTE_BASE="/public_html/staging/wp-content"

LOCAL_THEME="/c/xampp/htdocs/wp-content/themes/artrevisionist-wp-theme"
LOCAL_PLUGIN="/c/xampp/htdocs/wp-content/plugins/artrevisionist-wordpress"

echo "=== Uploading to Art Revisionist Staging ==="
echo ""

# Check if lftp is available
if command -v lftp &> /dev/null; then
    echo "Using lftp for upload..."

    # Upload Theme
    echo "Uploading theme..."
    lftp -c "
    set ftp:ssl-allow no;
    open -u $FTP_USER,$FTP_PASS $FTP_HOST;
    mirror -R --delete --verbose=1 '$LOCAL_THEME' '$REMOTE_BASE/themes/artrevisionist-wp-theme';
    bye
    "

    # Upload Plugin
    echo "Uploading plugin..."
    lftp -c "
    set ftp:ssl-allow no;
    open -u $FTP_USER,$FTP_PASS $FTP_HOST;
    mirror -R --delete --verbose=1 '$LOCAL_PLUGIN' '$REMOTE_BASE/plugins/artrevisionist-wordpress';
    bye
    "

    echo ""
    echo "✓ Upload complete!"
    echo "Staging URL: https://artrevisionist.com/staging"
else
    echo "ERROR: lftp not found. Install with: choco install lftp"
    exit 1
fi
