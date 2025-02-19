import jwt
from django.http import JsonResponse
from functools import wraps
from django.conf import settings

def check_auth(f):
    @wraps(f)
    def decorated_function(request, *args, **kwargs):
        # Get the Authorization header from the request
        authorization = request.headers.get('Authorization')
        
        if not authorization:
            return JsonResponse({"error": "Token not found"}, status=401)
        
        try:
            # Split "Bearer <token>"
            token = authorization.split(" ")[1]
            
            # Decode and verify the token
            decoded = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
            
            # Optionally, store the decoded user ID or other claims in the request
            request.user_id = decoded['user_id']
        except jwt.ExpiredSignatureError:
            return JsonResponse({"error": "Token has expired"}, status=401)
        except jwt.InvalidTokenError:
            return JsonResponse({"error": "Invalid Token"}, status=400)

        return f(request, *args, **kwargs)
    return decorated_function
