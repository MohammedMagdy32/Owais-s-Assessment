import mysql.connector
import subprocess
import random
import string

# Function to generate a random password
def generate_random_string(length=12):
    return ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(length))

# Update MySQL credentials
def update_mysql():
    new_user = "user_" + generate_random_string(6)
    new_password = generate_random_string()

    try:
        # Connect to MySQL inside the Docker container and you can change the env as you enviroment 
        conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='Root@123',  # Old password
            database='nodejs_api'
        )
        cursor = conn.cursor()
        
        # Create a new user with the new password
        cursor.execute(f"CREATE USER '{new_user}'@'%' IDENTIFIED BY '{new_password}';")
        cursor.execute(f"GRANT ALL PRIVILEGES ON *.* TO '{new_user}'@'%' WITH GRANT OPTION;")
        conn.commit()
        
        print(f"New credentials: User='{new_user}', Password='{new_password}'")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

# Restart Docker container
def restart_container():
    subprocess.run(["docker", "restart", "mysql"])
    print("Docker container restarted successfully.")

# Main function to run the script
def main():
    update_mysql()
    restart_container()

if __name__ == "__main__":
    main()

