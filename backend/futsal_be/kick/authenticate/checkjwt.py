from dotenv import load_dotenv
import os
import jwt

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '../../../.env'))

SECRET_KEY = os.getenv('SECRET_KEY')

def decryptToken(token):
    try:
        decoded = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        return decoded
    except jwt.ExpiredSignatureError:
        return "Token has expired"
    except jwt.InvalidTokenError:
        return "Invalid token"