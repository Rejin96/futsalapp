from django.shortcuts import render
from django.http import JsonResponse
from django.http import HttpResponse
from backend.futsal_be.kick.utilities.utilities_admin import get_all_players,signup_u,add_futsal,input_timeslotbyFutsal
from backend.futsal_be.kick.utilities.utilities_admin import update_game_status
import json
from django.middleware.csrf import get_token
from django.views.decorators.csrf import ensure_csrf_cookie,csrf_exempt

@ensure_csrf_cookie
def csrf_token_view(request):
    csrf_token = get_token(request)
    return JsonResponse({'csrf_token': csrf_token})

# Create your views here.
def members(request):
    return HttpResponse("Hello World")



import json
from django.http import JsonResponse
from django.contrib.auth.models import User  # Ensure this is correctly imported

@csrf_exempt
def signup(request):
    if request.method == "POST":
        try:
            # Parse JSON data from the request body
            data = json.loads(request.body)
            name = data.get("name")
            email = data.get("email")
            password = data.get("password")
            location = data.get("location")
            phone_number = data.get("phone_number")

            # Validate inputs
            if not all([name, email, password, location, phone_number]):
                return JsonResponse({"status": "error", "message": "All fields are required!"}, status=400)

            # Debugging: Print received data
            print(f"Received signup request: {data}")

            # Create new user using the updated signup_u function
            result = signup_u(name, email, password, location, phone_number)

            # Determine response status code based on the result
            if result["status"] == "success":
                return JsonResponse(result, status=201)  # 201 for successful signup
            else:
                return JsonResponse(result, status=400)  # 400 for errors like duplicate email

        except json.JSONDecodeError:
            return JsonResponse({"status": "error", "message": "Invalid JSON data!"}, status=400)
        except Exception as e:
            print(f"Unexpected error: {e}")
            return JsonResponse({"status": "error", "message": f"Internal server error: {str(e)}"}, status=500)


@csrf_exempt      
def addfutsal(request):
    if request.method == "POST":
        try:
            # Parse JSON data from the request body
            data = json.loads(request.body)
            name = data.get("name")
            location = data.get("location")
            google_map_location = data.get("google_map_location")
            longitude = data.get("longitude")
            latitude = data.get("latitude")
            phone_number = data.get("phone_number")
            # Validate inputs
            if not all([name, location,google_map_location,longitude,latitude,phone_number]):
                return JsonResponse({"status": "error", "message": "All fields are required!"})

            # Call the add_user function
            result = add_futsal(name, location,google_map_location,longitude,latitude,phone_number)
            return JsonResponse(result)
            ...
        except json.JSONDecodeError:
            return JsonResponse({"status": "error", "message": "Invalid JSON data!"})
        
def addtimeSlotbyFutsal(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)
            futsal_id = data.get("futsal_id")
            date= data.get("date")
            start_time = data.get("start_time")
            end_time = data.get("end_time")
            state = data.get("state")
            occupied_by= data.get("occupied_by")

            if not all([futsal_id,date,start_time,end_time,state]):
                return JsonResponse({"status": "error", "message": "All fields are required!"})
            
            result = input_timeslotbyFutsal(futsal_id,date,start_time,end_time,state,occupied_by)
            return JsonResponse(result)
            ...
        except json.JSONDecodeError:
            return JsonResponse({"status": "error", "message": "Invalid JSON data!"})
        


def complete_game_request(request):
    if request.method == "POST":
        try:
            # Parse JSON data
            data = json.loads(request.body)
            request_id = data.get("request_id")

            # Validate input
            if not request_id:
                return JsonResponse({"status": "error", "message": "Request ID is required!"})

            # Call utility function to update game status
            result = update_game_status(request_id)
            return JsonResponse(result)

        except json.JSONDecodeError:
            return JsonResponse({"status": "error", "message": "Invalid JSON data!"})

        except Exception as e:
            return JsonResponse({"status": "error", "message": f"An error occurred: {e}"})

    return JsonResponse({"status": "error", "message": "Invalid request method. Use POST."})




