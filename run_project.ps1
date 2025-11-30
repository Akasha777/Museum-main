<#
Small helper script to run the Museum project on Windows.

Usage examples (PowerShell):
  - Use XAMPP (recommended):
      .\run_project.ps1 -Mode xampp -XamppPath 'C:\xampp' -ProjectPath 'C:\Users\akash\Documents\project.extra\Museum-main[1]\Museum-main'

  - Use PHP built-in server (requires PHP & MySQL installed separately):
      .\run_project.ps1 -Mode php -PhpPort 8000 -ProjectPath 'C:\Users\akash\Documents\project.extra\Museum-main[1]\Museum-main'

Notes:
  - The script will attempt to import `museumsys.sql` into a database called `museumsys` using the mysql binary found in the XAMPP folder (when Mode=xampp).
  - If MySQL root account uses a password, you must update the script or import the database manually.
  - The script will not attempt to modify `connection.php` — update DB credentials in the project if needed.
#>

param(
    [ValidateSet('xampp','php')]
    [string]$Mode = 'xampp',

    [string]$ProjectPath = "C:\Users\akash\Documents\project.extra\Museum-main[1]\Museum-main",

    # XAMPP defaults
    [string]$XamppPath = 'C:\xampp',

    # Port for php built-in server mode
    [int]$PhpPort = 8000,

    # MySQL root password if any, leave empty for default root without password
    [string]$MySqlRootPassword = ''
)

function Write-Info($s){ Write-Host "[INFO] $s" -ForegroundColor Cyan }
function Write-Err($s){ Write-Host "[ERROR] $s" -ForegroundColor Red }

if(-not (Test-Path -Path $ProjectPath)){
    Write-Err "Project path not found: $ProjectPath"
    exit 1
}

switch($Mode){
    'xampp' {
        $dest = Join-Path $XamppPath 'htdocs\Museum-main'
        Write-Info "Copying project to XAMPP htdocs -> $dest"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $dest
        Copy-Item -Path $ProjectPath -Destination $dest -Recurse -Force

        $mysqlExe = Join-Path $XamppPath 'mysql\bin\mysql.exe'
        if(-not (Test-Path $mysqlExe)){
            Write-Err "mysql.exe not found at $mysqlExe. Is XAMPP installed at $XamppPath?"
            Write-Host "You can run the project manually from XAMPP Control Panel after copying the files."
            exit 1
        }

        # create database and import sql
        $sqlFile = Join-Path $dest 'museumsys.sql'
        if(-not (Test-Path $sqlFile)){
            Write-Err "SQL file not found: $sqlFile"
            Write-Host "Make sure museumsys.sql is in the project folder or import manually via phpMyAdmin."
            exit 1
        }

        Write-Info "Creating database 'museumsys' and importing $sqlFile"
        $createDbCmd = "CREATE DATABASE IF NOT EXISTS museumsys;"

        if([string]::IsNullOrWhiteSpace($MySqlRootPassword)){
            & $mysqlExe -u root -e $createDbCmd
            if($LASTEXITCODE -ne 0){ Write-Err "Failed to create DB. See error output above."; exit 1 }
            # Import
            & $mysqlExe -u root museumsys < $sqlFile
            if($LASTEXITCODE -ne 0){ Write-Err "Import failed. Consider using phpMyAdmin to import $sqlFile."; exit 1 }
        } else {
            & $mysqlExe -u root -p$MySqlRootPassword -e $createDbCmd
            if($LASTEXITCODE -ne 0){ Write-Err "Failed to create DB (password auth)."; exit 1 }
            & $mysqlExe -u root -p$MySqlRootPassword museumsys < $sqlFile
            if($LASTEXITCODE -ne 0){ Write-Err "Import failed (password auth)."; exit 1 }
        }

        Write-Info "Project copied and DB imported. Start Apache + MySQL via XAMPP Control Panel (or run services) and open http://localhost/Museum-main"
    }

    'php' {
        Write-Info "Starting built-in PHP server on port $PhpPort. Ensure a separate MySQL server is running and available (root/no-password by default)."
        Push-Location $ProjectPath

        # Start server in a new window so the script can return
        $phpCmd = "php -S 127.0.0.1:$PhpPort"
        Write-Info "Launching: $phpCmd"

        Start-Process -NoNewWindow -FilePath "powershell" -ArgumentList "-NoExit","-Command","$phpCmd" -WorkingDirectory $ProjectPath

        Pop-Location
        Write-Info "PHP server started. Open http://127.0.0.1:$PhpPort in your browser."
    }

    Default { Write-Err "Invalid mode"; exit 1 }
}

Write-Info "Done. If the application doesn't show correctly, open the project's folder and inspect `connection.php` for DB credentials (host, username, password, dbname)."
