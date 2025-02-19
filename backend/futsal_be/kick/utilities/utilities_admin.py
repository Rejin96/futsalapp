import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..')))

import bcrypt
from sqlalchemy.exc import IntegrityError
from backend.futsal_be.futsal_be.db_setup import Session_local
from kick.models import User,FutsalLocation,TimeSlot,GameRequest,PlayerParticipation
from sqlalchemy import text

def get_session():
    return Session_local()

#adds the user after he sign up
def signup_u(name, email, password, location, phone_number):
    session = get_session()
    try:
        # Check if email already exists
        existing_user = session.query(User).filter_by(email=email).first()
        if existing_user:
            return {"status": "error", "message": f"A user with email '{email}' already exists."}

        # Check if phone number already exists
        existing_phone = session.query(User).filter_by(phone_number=phone_number).first()
        if existing_phone:
            return {"status": "error", "message": f"Phone number '{phone_number}' is already in use."}

        # Hash password
        salt = bcrypt.gensalt()
        hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
        encryptedpass = hashed_password.decode('utf-8')

        # Create new user
        user = User(
            name=name,
            email=email,
            password=encryptedpass,
            location=location,
            phone_number=phone_number
        )
        session.add(user)
        session.commit()
        return {"status": "success", "message": f"User '{name}' added successfully!"}

    except Exception as e:
        session.rollback()
        return {"status": "error", "message": f"Error adding user: {e}"}

    finally:
        session.close()


def get_all_players():
    session = get_session()
    try:
        # Use SQLAlchemy ORM to query the User table
        players = session.query(User).all()
        return [{"id": player.user_id, "name": player.name,"email": player.email,
                 "phone number":player.phone_number,"location":player.location} 
                for player in players]
    except Exception as e:
        print(f'Error: {e}')
        return []
    finally:
        session.close()


def add_futsal(name,location,google_map_location,longitude,latitude,phone_number):
    session = get_session()
    try:
        futsal = FutsalLocation(
            name=name,
            address=location,
            google_map_location=google_map_location,
            longitude = longitude,
            latitude = latitude, 
            phone_number = phone_number
        )
        session.add(futsal)
        session.commit()
        return {"status": "success", "message": f"Futsal '{name}' added successfully!"}
    except IntegrityError:
        session.rollback()
        return {"status": "error", "message": f"The futsal '{name}' already exists."}
    except Exception as e:
        session.rollback()
        return {"status": "error", "message": f"Error adding user: {e}"}
    finally:
        session.close()

from sqlalchemy.exc import IntegrityError

def input_timeslotbyFutsal(futsal_id, date, start_time, end_time, state, occupied_by=None):
    session = get_session()
    try:
        # Create a new TimeSlot object
        slot = TimeSlot(
            futsal_id=futsal_id,
            date=date,
            start_time=start_time,
            end_time=end_time,
            state=state,
            occupied_by=occupied_by
        )
        session.add(slot)
        session.commit()
        return {"status": "success", "message": f"Time slot as '{state}' added successfully!"}
    except IntegrityError:
        session.rollback()
        try:
            # Delete the existing conflicting record
            session.query(TimeSlot).filter_by(
                futsal_id=futsal_id,
                date=date,
                start_time=start_time,
                end_time=end_time
            ).delete()
            
            # Add the new record
            session.add(slot)
            session.commit()
            return {"status": "success", "message": "Old time slot removed and new time slot added successfully!"}
        except Exception as e:
            session.rollback()
            print(f'Error during replacement: {e}')
            return {"status": "error", "message": "Failed to replace the existing record!"}
    except Exception as e:
        print(f'Error: {e}')
        return {"status": "error", "message": "An unexpected error occurred!"}
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




