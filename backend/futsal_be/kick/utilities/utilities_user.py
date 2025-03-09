
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
        futsal = session.query(FutsalLocation).filter_by(name=futsal_name).first()

        timeslots = session.query(TimeSlot).filter_by(date=date, futsal_id=futsal.futsal_id).all()
        
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

def querydb(date, time, location):
    session = get_session()
    try:
        # Join GameRequest -> TimeSlot -> FutsalLocation
        game_requests = (
            session.query(GameRequest, TimeSlot, FutsalLocation)
            .join(TimeSlot, GameRequest.slot_id == TimeSlot.slot_id)
            .join(FutsalLocation, TimeSlot.futsal_id == FutsalLocation.futsal_id)
            .filter(
                TimeSlot.date == date,                     # Filter by date
                TimeSlot.start_time == time,               # Filter by time
                FutsalLocation.address == location            # Filter by location name
            )
            .all()
        )

        # If no matching game requests found
        if not game_requests:
            return {"status": "error", "message": "No game requests found for the given criteria!"}

        # Format the result
        result = []
        for gr, ts, fl in game_requests:
            result.append({
                "request_id": gr.request_id,
                "futsal_name": fl.name,
                "address": fl.address,
                "player_count": gr.player_count,
                "start_time": str(ts.start_time),
                "end_time": str(ts.end_time),
                "google_map_location": fl.google_map_location,
                #bellow this is commented out
                
                # "game_request": {
                #     "request_id": gr.request_id,
                #     "slot_id": gr.slot_id,
                #     "created_by": gr.created_by,
                #     "player_count": gr.player_count,
                #     "status": gr.status
                # },
                # "time_slot": {
                #     "slot_id": ts.slot_id,
                #     "date": str(ts.date),
                #     "start_time": str(ts.start_time),
                #     "end_time": str(ts.end_time),
                #     "state": ts.state,
                #     "occupied_by": ts.occupied_by
                # },
                # "futsal_location": {
                #     "futsal_id": fl.futsal_id,
                #     "name": fl.name,
                #     "address": fl.address,
                #     "google_map_location": fl.google_map_location,
                #     "latitude": fl.latitude,
                #     "longitude": fl.longitude,
                #     "phone_number": fl.phone_number
                # }
                
            })

        return {
            "status": "success",
            "game_requests": result
        }

    except Exception as e:
        session.rollback()
        return {"status": "error", "message": f"An error occurred: {e}"}

    finally:
        session.close()


def see_game_details_u(user_id):
    session = get_session()
    try:
        # Step 1: Get request IDs where the user has participated
        games = session.query(PlayerParticipation).filter_by(user_id=user_id).all()
        request_ids = [game.request_id for game in games]

        if not request_ids:
            return {"status": "error", "message": "User has not participated in any games."}

        # Step 2: Get game request details along with creator info, participant status, time details, futsal name, and google map location
        game_requests = (
            session.query(GameRequest, User, PlayerParticipation, TimeSlot, FutsalLocation)
            .join(User, GameRequest.created_by == User.user_id)  # Join with User to get creator's name
            .join(PlayerParticipation, PlayerParticipation.request_id == GameRequest.request_id)  # Join with PlayerParticipation
            .join(TimeSlot, TimeSlot.slot_id == GameRequest.slot_id)  # Join with TimeSlot for start and end time
            .join(FutsalLocation, FutsalLocation.futsal_id == TimeSlot.futsal_id)  # Join with FutsalLocation to get futsal details
            .filter(GameRequest.request_id.in_(request_ids), PlayerParticipation.user_id == user_id)  # Only for the given user
            .all()
        )

        # Step 3: Format the response
        result = []
        for gr, creator, participant, ts, futsal in game_requests:
            result.append({
                "request_id": gr.request_id,
                "creator_name": creator.name,  # Fetch the creator's name
                "num_players": gr.player_count,
                "game_status": gr.status,
                "participant_status": participant.status,  # Participant status
                "start_time": str(ts.start_time),  # Start time from TimeSlot
                "end_time": str(ts.end_time),  # End time from TimeSlot
                "futsal_name": futsal.name,  # Futsal name from FutsalLocation
                "google_map_location": futsal.google_map_location  # Google map location from FutsalLocation
            })

        return {
            "status": "success",
            "game_details": result
        }

    except Exception as e:
        session.rollback()
        return {"status": "error", "message": f"An error occurred: {str(e)}"}

    finally:
        session.close()

def created_game_details_u(user_id):
    session = get_session()
    try:
        # Step 1: Get all game requests created by the user
        game_requests = session.query(GameRequest).filter_by(created_by=user_id).all()

        if not game_requests:
            return {"status": "error", "message": "No game requests created by the user."}

        # Step 2: Fetch the game details along with participant details, futsal name, and time slot info
        result = []
        for gr in game_requests:
            # Fetch participants for the current game request
            participants = (
                session.query(PlayerParticipation, User)
                .join(User, User.user_id == PlayerParticipation.user_id)  # Join with User to get participant details
                .filter(PlayerParticipation.request_id == gr.request_id)
                .all()
            )

            # Fetch the time slot and futsal details for the current game request
            time_slot = (
                session.query(TimeSlot, FutsalLocation)
                .join(FutsalLocation, FutsalLocation.futsal_id == TimeSlot.futsal_id)  # Join with FutsalLocation
                .filter(TimeSlot.slot_id == gr.slot_id)
                .first()
            )

            # Step 3: Format the game details response
            participants_data = []
            for participant, user in participants:
                participants_data.append({
                    "participant_id": user.user_id,
                    "participant_name": user.name,
                    "participant_status": participant.status
                })

            result.append({
                "request_id": gr.request_id,
                "num_players": gr.player_count,
                "game_status": gr.status,
                "start_time": str(time_slot[0].start_time),  # TimeSlot start time
                "end_time": str(time_slot[0].end_time),  # TimeSlot end time
                "futsal_name": time_slot[1].name,  # Futsal name
                "google_map_location": time_slot[1].google_map_location,  # Futsal google map location
                "participants": participants_data  # List of participants and their statuses
            })

        return {
            "status": "success",
            "created_game_details": result
        }

    except Exception as e:
        session.rollback()
        return {"status": "error", "message": f"An error occurred: {str(e)}"}

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
        return {"status": "success","participant_user_id":user_id, "message": "Participation request created successfully."}

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

def show_recommended_players_u(recommended_players_ids):
    session = get_session()

    try:
        print(recommended_players_ids)
        # Fetch player details by their IDs
        players = session.query(User).filter(User.user_id.in_(recommended_players_ids)).all()

        # If no players are found, return an error message
        if not players:
            return {"status": "error", "message": "No players found"}

        recommended_players_list = [
            {
                "user_id": player.user_id,
                "name": player.name,
                "phone_number": player.phone_number,
                "location": player.location,
                "status": player.status
            }
            for player in players
        ]

        return {
            "status": "success",
            "recommended_players": recommended_players_list
        }

    except Exception as e:
        session.rollback()
        # Log the error and return a detailed message
        print(f"Error occurred: {e}")
        return {"status": "error", "message": f"An error occurred: {e}"}
    
    finally:
        session.close()
