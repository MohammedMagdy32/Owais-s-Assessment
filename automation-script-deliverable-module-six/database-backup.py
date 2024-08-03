import subprocess
from datetime import datetime
import os

# Environment variables for security
MYSQL_HOST = 'localhost'
MYSQL_PORT = '3306'
DB_NAME = os.getenv('DB_NAME', 'nodejs_api')
DB_USER = os.getenv('DB_USER', 'root')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'Root@123')
BACKUP_DIR = '/home/shalan/Desktop'

def create_backup_directory():
    if not os.path.exists(BACKUP_DIR):
        os.makedirs(BACKUP_DIR)

def backup_database():
    create_backup_directory()
    backup_file = f"{BACKUP_DIR}/{DB_NAME}_backup_{datetime.now().strftime('%Y%m%d%H%M%S')}.sql"
    command = f"docker exec mysql mysqldump -u {DB_USER} -p{DB_PASSWORD} {DB_NAME} > {backup_file}"
    try:
        subprocess.run(command, shell=True, check=True, executable='/bin/bash')
        print(f"Backup created: {backup_file}")
    except subprocess.CalledProcessError as e:
        print(f"Error backing up database: {e}")

def main():
    backup_database()

if __name__ == "__main__":
    main()

