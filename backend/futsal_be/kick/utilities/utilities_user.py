
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..')))

import bcrypt
from sqlalchemy.exc import IntegrityError
from backend.futsal_be.futsal_be.db_setup import Session_local
from backend.futsal_be.kick.createToken import genToken
from kick.models import User,FutsalLocation,TimeSlot,GameRequest,PlayerParticipation
from django.conf import settings

def get_session():
    return Session_local()

def login_u(email, password):
    session = get_session()
    try:
        user = session.query(User).filter_by(email=email).first()
        print(user.user_id)
        if not user:
            return {"status": "error", "message": "Signup first"}
        
        # Check if the password is correct
        if bcrypt.checkpw(password.encode('utf-8'), user.password.encode('utf-8')):
            token = genToken(user.user_id)  # Generate a JWT token
            return {
                "status": "success", 
                "message": "Login successful", 
                "token": token
            }
        else:
            return {"status": "error", "message": "Incorrect password"}

    except Exception as e:
        session.rollback()
        return {"status": "error", "message": "An error occurred. Please try again later."}
    finally:
        session.close()

def getplayer_u(user_id):
    session = get_session()
    try:
        user = session.query(User).filter_by(user_id=user_id).first()

        if not user:
            return {"status": "error", "message": "User not found!"}

        # ✅ Construct image path (if exists)
        image_url = None
        if user.image:
            image_url = f"/media/user_{user.user_id}/{user.image}"

        # ✅ Prepare user data
        user_data = {
            "user_id": user.user_id,
            "name": user.name,
            "email": user.email,
            "phone_number": user.phone_number,
            "location": user.location,
            "status": user.status,
            "credit": user.credit,
            "image": image_url,  # Return URL instead of base64
        }
        return {"status": "success", "user": user_data}

    except Exception as e:
        session.rollback()
        return {"status": "error", "message": f"An error occurred: {e}"}

    finally:
        session.close()


    
def update_u(user_id, name, image_filename, location, phone_number):
    session = get_session()
    try:
        user = session.query(User).filter_by(user_id=user_id).first()
        if not user:
            return {"status": "error", "message": "User not found!"}

        if name:
            user.name = name
        if image_filename:
            user.image = image_filename  # Save only filename, not binary data
        if location:
            user.location = location
        if phone_number:
            user.phone_number = phone_number

        session.commit()
        return {"status": "success", "message": "User updated successfully!"}

    except Exception as e:
        session.rollback()
        return {"status": "error", "message": f"An error occurred: {e}"}


def change_state(user_id):
    session = get_session()
    try:
        user = session.query(User).filter_by(user_id = user_id).first()
        if not user:
            return {"status": "error", "message": "User not found!"}
        
        if user.status == "online":
            user.status = "offline"
        else:
            user.status = "online"
        
        session.commit()

        return {"status": "success", "message": f"{user_id} status is toggle."}

    except Exception as e:
        session.rollback()
        return {"status": "error", "message": f"An error occurred: {e}"}
    
    finally:
        session.close()

def show_time_slot_u(futsal_name, date):
    session = get_session()
    try:
        # Fetch the FutsalLocation object by its name
        futsal = session.query(FutsalLocation).filter_by(name=futsal_name).first()

        # Query the TimeSlot table for the given date and futsal ID
        timeslots = session.query(TimeSlot).filter_by(date=date, futsal_id=futsal.futsal_id).all()
        
        # Format the timeslot data to be returned in the response
        timeslot_list = [
            {
                "slot_id": ts.slot_id,
                "start_time": str(ts.start_time),
                "end_time": str(ts.end_time),
                "state": ts.state,
                "occupied_by": ts.occupied_by
            }
            for ts in timeslots
        ]

        return {
            "status": "success",
            "futsal_id": futsal.futsal_id,
            "timeslots": timeslot_list
        }
    except Exception as e:
        session.rollback()
        return {"status": "error", "message": f"An error occurred: {e}"}
    finally:
        session.close()


def pick_slot(slot_id, user_id, player_count):
    session = get_session()
    try:
        # Fetch the slot
        slot = session.query(TimeSlot).filter_by(slot_id=slot_id).first() 
        if not slot:
            return {"status": "error", "message": "Time slot not found!"}

        # Check if the slot is available
        if slot.state != "available":
            return {"status": "error", "message": "Time slot is not available!"}

        # Update the slot state and occupied_by field
        slot.state = "occupied"
        slot.occupied_by = user_id

        if(player_count<10):
        # Create a game request
            game_request = GameRequest(
                slot_id=slot_id,
                created_by=user_id,
                player_count=player_count,
                status="open"
            )
        else:
            game_request = GameRequest(
                slot_id=slot_id,
                created_by=user_id,
                player_count=player_count,
                status="completed"
            )
        session.add(game_request)
        session.commit()

        return {"status": "success", "message": f"Slot {slot_id} picked by user {user_id}."}

    except IntegrityError:
        session.rollback()
        return {"status": "error", "message": "Database integrity error!"}

    except Exception as e:
        session.rollback()
        return {"status": "error", "message": f"An error occurred: {e}"}

    finally:
        session.close()

def update_game_status(request_id):
    session = get_session()
    try:
        # Fetch the game request
        game_request = session.query(GameRequest).filter_by(request_id=request_id).first()
        if not game_request:
            return {"status": "error", "message": "Game request not found!"}

        # Fetch the slot
        slot = session.query(TimeSlot).filter_by(slot_id=game_request.slot_id).first()
        if not slot:
            return {"status": "error", "message": "Associated time slot not found!"}

        # Check player count and update statuses
        if game_request.player_count >= 9:
            game_request.status = "completed"
            slot.state = "booked"

        session.commit()

        return {"status": "success", "message": "Game request and slot updated successfully."}

    except Exception as e:
        session.rollback()
        return {"status": "error", "message": f"An error occurred: {e}"}

    finally:
        session.close()

def create_participation_request(request_id, user_id):
    session = get_session()
    try:
        # Check if the game request exists
        game_request = session.query(GameRequest).filter_by(request_id=request_id).first()
        if not game_request:
            return {"status": "error", "message": "Game request not found!"}

        # Create a participation record
        participation = PlayerParticipation(
            request_id=request_id,
            user_id=user_id,
            status="pending"
        )
        session.add(participation)
        session.commit()
        return {"status": "success", "message": "Participation request created successfully."}

    except IntegrityError:
        session.rollback()
        return {"status": "error", "message": "Participation request already exists!"}

    except Exception as e:
        session.rollback()
        return {"status": "error", "message": f"An error occurred: {e}"}

    finally:
        session.close()

def handle_participation(request_id, user_id, action):
    session = get_session()
    try:
        # Fetch the game request
        game_request = session.query(GameRequest).filter_by(request_id=request_id).first()
        if not game_request:
            return {"status": "error", "message": "Game request not found!"}

        # Fetch the participation record
        participation = session.query(PlayerParticipation).filter_by(request_id=request_id, user_id=user_id).first()
        if not participation:
            return {"status": "error", "message": "Participation record not found!"}

        if action == "confirm":
            participation.status = "confirmed"
            game_request.player_count += 1
            if game_request.player_count >= 9:
                update_game_status(request_id)

        elif action == "cancel":
            participation.status = "cancelled"

        session.commit()
        return {"status": "success", "message": f"Participation {action}ed successfully."}

    except Exception as e:
        session.rollback()
        return {"status": "error", "message": f"An error occurred: {e}"}

    finally:
        session.close()
