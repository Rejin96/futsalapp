import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..','..')))
from backend.futsal_be.futsal_be.db_setup import Session_local

from kick.models import User,FutsalLocation

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
