from dotenv import load_dotenv
import os
import jwt

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '../../.env'))

SECRET_KEY = os.getenv('SECRET_KEY')

def genToken(user_id):
    token = jwt.encode({"user_id": user_id}, SECRET_KEY, algorithm="HS256")
    return token
