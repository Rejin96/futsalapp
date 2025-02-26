import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..','..')))
from backend.futsal_be.futsal_be.db_setup import Session_local

from kick.models import User,FutsalLocation,TimeSlot,GameRequest,PlayerParticipation

import math

def get_session():
    return Session_local()

def haversine(lat1, lon1, lat2, lon2):
    # Convert latitude and longitude from degrees to radians
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])

    # Haversine formula
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    r = 6371  # Radius of Earth in kilometers

    return r * c

def calculate_dist(point):
    session = get_session()
    try:
        # Use SQLAlchemy ORM to query the User table
        futsals = session.query(FutsalLocation).all()
        distances = []
        a = float(point[0])
        b = float(point[1])
        for futsal in futsals:
            ref_longitude = float(futsal.longitude)
            ref_latitude = float(futsal.latitude)
            distance = haversine(ref_longitude,ref_latitude,a,b)
            distances.append({"name": futsal.name, "distance": distance})
        
        distances.sort(key=lambda x: x["distance"])
        return distances
    except Exception as e:
        print(f'Error: {e}')
        return []
    finally:
        session.close()

def show_using_hav(date,time,longitude,latitude):
    session = get_session()
    try:
        # Query GameRequest, TimeSlot, and FutsalLocation based on date and time
        game_requests = (
            session.query(GameRequest, TimeSlot, FutsalLocation)
            .join(TimeSlot, GameRequest.slot_id == TimeSlot.slot_id)
            .join(FutsalLocation, TimeSlot.futsal_id == FutsalLocation.futsal_id)
            .filter(TimeSlot.date == date, TimeSlot.start_time == time)
            .all()
        )
        
        # If no matching game requests found
        if not game_requests:
            return {"status": "error", "message": "No games found for the given date and time!"}

        # List to store futsal names and distances
        distances = []

        # Convert input coordinates to float
        a = float(latitude)
        b = float(longitude)

        # Loop through game requests to calculate distances
        for gr, ts, fl in game_requests:
            ref_longitude = float(fl.longitude)
            ref_latitude = float(fl.latitude)

            # Calculate the distance using the haversine function
            distance = haversine(ref_longitude, ref_latitude, b, a)
            distances.append({
                                "request_id": gr.request_id,
                                "futsal_name": fl.name,
                                "address": fl.address,
                                "player_count": gr.player_count,
                                "start_time": str(ts.start_time),
                                "end_time": str(ts.end_time),
                                "google_map_location": fl.google_map_location,
                                "distance": distance
                              })

        # Sort distances by value
        distances.sort(key=lambda x: x["distance"])

        return {
            "status": "success",
            "distances": distances
        }
    
    except Exception as e:
        print(f"Error: {e}")
        return {"status": "error", "message": f"An error occurred: {e}"}
    
    finally:
        session.close()

