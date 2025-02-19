from dotenv import load_dotenv
import os

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '../../.env'))

DB_HOST = os.getenv('db_host')
DB_USER = os.getenv('db_user')
DB_PASSWORD = os.getenv('db_password')
DB_NAME = os.getenv('db_name')
DB_PORT = os.getenv('db_port')
