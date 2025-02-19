import sys
import os

# Add the parent directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from sqlalchemy import create_engine
#from sqlalchemy.ext.declarative import declarative_base
from futsal_be.config import DB_USER,DB_NAME,DB_HOST,DB_PASSWORD,DB_PORT
from sqlalchemy.orm import sessionmaker,declarative_base

#Base class for model
Base = declarative_base()

#creating engine and session
#mysql://user:password@host:port/database
engine = create_engine('mysql+mysqlconnector://'+DB_USER+':'+DB_PASSWORD+'@'+DB_HOST+':'+str(DB_PORT)+'/'+DB_NAME)
Session_local = sessionmaker(bind=engine)


def init_db():
    Base.metadata.create_all(bind=engine)

