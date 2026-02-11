# Bulk update C:\xampp -> E:\xampp in batch files
$files = @(
    'E:\xampp\php\wp.bat',
    'E:\xampp\php\pear.bat',
    'E:\xampp\php\pecl.bat',
    'E:\xampp\php\peardev.bat',
    'E:\xampp\php\pciconf.bat',
    'E:\xampp\php\pci.bat',
    'E:\xampp\php\phpunit.bat',
    'E:\xampp\mysql\scripts\ctl.bat',
    'E:\xampp\apache\scripts\ctl.bat',
    'E:\xampp\ctlscript.bat',
    'E:\xampp\perl\bin\perlthanks.bat',
    'E:\xampp\perl\bin\config_data.bat',
    'E:\xampp\perl\bin\splain.bat',
    'E:\xampp\perl\bin\pl2pm.bat',
    'E:\xampp\perl\bin\perlivp.bat',
    'E:\xampp\perl\bin\htmltree.bat',
    'E:\xampp\perl\bin\pod2latex.bat',
    'E:\xampp\perl\bin\pod2html.bat',
    'E:\xampp\perl\bin\h2xs.bat',
    'E:\xampp\perl\bin\perlbug.bat',
    'E:\xampp\perl\bin\h2ph.bat',
    'E:\xampp\perl\bin\libnetcfg.bat'
)

$count = 0
foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        if ($content -match 'C:\\xampp|C:/xampp') {
            $newContent = $content -replace 'C:\\xampp', 'E:\xampp' -replace 'C:/xampp', 'E:/xampp'
            Set-Content $file -Value $newContent -NoNewline
            $count++
            Write-Host "Updated: $file"
        }
    }
}
Write-Host "`nUpdated $count files"
