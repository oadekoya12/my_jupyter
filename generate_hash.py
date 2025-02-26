import os
from notebook.auth.security import passwd

password = os.getenv('JUPYTER_PASSWORD')
if not password:
    raise ValueError("JUPYTER_PASSWORD environment variable is not set")

hashed_password = passwd(password)
print(hashed_password)
