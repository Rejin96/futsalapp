#from django.db import models
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..')))

from sqlalchemy import Column, Integer, String,LargeBinary, ForeignKey, Enum, Date, Time,UniqueConstraint
from sqlalchemy.orm import relationship
from backend.futsal_be.futsal_be.db_setup import Base
from sqlalchemy.dialects.mysql import LONGBLOB


class User(Base):
    __tablename__ = 'users'
    user_id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    email = Column(String(150), unique=True, nullable=False)
    password = Column(String(255), nullable=False)
    phone_number = Column(String(15), nullable=False)
    location = Column(String(255), nullable=False)
    status = Column(Enum('online','offline',name='player_status'),default = 'offline')
    credit = Column(Integer, default=60)
    image = Column(String(255), nullable=True)  

    #is_verified = Column(Boolean, default=False)

class FutsalLocation(Base):
    __tablename__ = 'futsal_locations'
    futsal_id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    address = Column(String(255), nullable=False)
    google_map_location = Column(String(255),nullable=False)
    longitude = Column(String(50),nullable=False)
    latitude = Column(String(50),nullable=False)
    phone_number = phone_number = Column(String(15), nullable=False)

class TimeSlot(Base):
    __tablename__ = 'time_slots'
    slot_id = Column(Integer, primary_key=True)
    futsal_id = Column(Integer, ForeignKey('futsal_locations.futsal_id'))
    date = Column(Date, nullable=False)
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)
    state = Column(Enum('available', 'occupied', 'booked', name='slot_state'), default='available')
    occupied_by = Column(Integer, ForeignKey('users.user_id'))

    __table_args__ = (
        UniqueConstraint('futsal_id', 'date', 'start_time', 'end_time', name='uix_timeslot'),
    )

class GameRequest(Base):
    __tablename__ = 'game_requests'
    request_id = Column(Integer, primary_key=True)
    slot_id = Column(Integer, ForeignKey('time_slots.slot_id'))
    created_by = Column(Integer, ForeignKey('users.user_id'))
    player_count = Column(Integer, nullable=False)
    status = Column(Enum('open', 'completed', 'cancelled', name='request_status'), default='open')

class PlayerParticipation(Base):
    __tablename__ = 'player_participation'
    participation_id = Column(Integer, primary_key=True)
    request_id = Column(Integer, ForeignKey('game_requests.request_id'))
    user_id = Column(Integer, ForeignKey('users.user_id'))
    status = Column(Enum('pending', 'confirmed', 'cancelled', name='participation_status'), default='pending')
