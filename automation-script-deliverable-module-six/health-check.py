import requests
import subprocess
from datetime import datetime

# Health check
# you cah change the following localhost endpoint to your live endpoint 
try:
    response = requests.get('http://localhost:3000/metrics')
    if response.status_code == 200:
        print("Application is healthy.")
    else:
        print("Application is not healthy.")
except Exception as e:
    print(f"Error performing health check: {e}")

