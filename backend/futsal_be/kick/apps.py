import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..')))
from django.apps import AppConfig
from backend.futsal_be.futsal_be.db_setup import init_db

class KickConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'kick'

    def ready(self):
        # Ensure the database is only initialized in specific cases
        
        try:
            print("Initializing the database...")
            init_db()
            print("Database initialized successfully.")
        except Exception as e:
            print(f"Error initializing database: {e}")
