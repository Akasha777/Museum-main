# Running this Museum project on Windows

I added a helper script `run_project.ps1` to make it faster to run this PHP + MySQL project on Windows.

Two common ways to run locally are supported:

- XAMPP (recommended)
- PHP built-in server (developer-only; requires a separate MySQL server)

----

How to use the script (PowerShell):

1) Open PowerShell as Administrator (recommended for XAMPP operations).

2) Copy the repository path and run the script with the preferred mode.

Example: XAMPP (recommended)

```powershell
cd "C:\xampp\htdocs" # optional
# Run the script — change paths if your XAMPP or project live elsewhere
.\run_project.ps1 -Mode xampp -XamppPath 'C:\xampp' -ProjectPath 'C:\Users\akash\Documents\project.extra\Museum-main[1]\Museum-main'
```

What it does:
- Copies your project into C:\xampp\htdocs\Museum-main
- Uses \mysql\bin\mysql.exe to create a database `museumsys` and import `museumsys.sql` from the project folder

Notes:
- If your MySQL `root` user has a password, pass it to the script via the `-MySqlRootPassword` argument.
- The script will not alter `connection.php`. Verify `connection.php` matches the MySQL credentials and host.

Example: PHP built-in server

```powershell
.\run_project.ps1 -Mode php -PhpPort 8000 -ProjectPath 'C:\Users\akash\Documents\project.extra\Museum-main[1]\Museum-main'
```

What it does:
- Starts PHP's built-in server in a new terminal window (requires PHP CLI installed and on PATH).
- You must have MySQL running separately and import `museumsys.sql` yourself (or via the script if you use XAMPP).

Troubleshooting
- If pages show source code instead of rendered content: make sure you're serving via Apache or `php -S` (do NOT open files via file://).
- If the DB connection fails: open `connection.php` and confirm host, username, password, and database name.
- To import the DB manually: use phpMyAdmin (http://localhost/phpmyadmin) or the MySQL CLI:
  ```powershell
  # create DB
  mysql -u root -e "CREATE DATABASE IF NOT EXISTS museumsys;"
  # import
  mysql -u root museumsys < "C:\Path\To\project\museumsys.sql"
  ```

Default admin users (from the SQL dump) — handy to test logins:
- `ad101` / `frosty`
- `super` / `forever`

If you'd like, I can:
- Create a small PowerShell wrapper to start XAMPP or to detect your PHP and MySQL paths automatically.
- Walk you through any errors you see when you try these steps — paste the PowerShell output or browser error and I'll help debug.
