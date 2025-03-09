import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from backend.futsal_be.futsal_be.db_setup import Session_local
from kick.models import PlayerParticipation, User, GameRequest

def get_session():
    return Session_local()

def get_participation_data():
    """Fetch player participation data from the database."""
    session = get_session()
    try:
        participations = session.query(PlayerParticipation).all()
        data = {}

        # Get all game requests and include the creator of the request
        game_requests = session.query(GameRequest).all()

        # Initialize participation data with the confirmed participations
        for p in participations:
            if p.status == 'confirmed':  # Consider only confirmed games
                if p.user_id not in data:
                    data[p.user_id] = set()
                data[p.user_id].add(p.request_id)

        # Add the creator of each game request to the participation data
        for game_request in game_requests:
            creator_id = game_request.created_by
            if creator_id not in data:
                data[creator_id] = set()
            data[creator_id].add(game_request.request_id)

        return data

    except Exception as e:
        print(f"Error fetching participation data: {e}")
        return {}
    finally:
        session.close()

from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

def compute_similarity():
    """Compute cosine similarity between players based on game participation."""
    data = get_participation_data()
    print(f"Participation Data: {data}")
    players = list(data.keys())  # List of player IDs
    num_players = len(players)

    print(f"Total Players: {num_players}")

    if num_players == 0:
        return {}

    # Create a list of all unique games (request IDs)
    all_games = set()
    for game_ids in data.values():
        all_games.update(game_ids)
    
    all_games = list(all_games)  # Convert to list to use as indexes

    # Create a player-game matrix (binary matrix indicating if a player participated in a game)
    player_game_matrix = np.zeros((num_players, len(all_games)))

    for i, player in enumerate(players):
        for j, game in enumerate(all_games):
            if game in data[player]:  # If the player participated in this game
                player_game_matrix[i, j] = 1

    # Compute cosine similarity
    similarity_matrix = cosine_similarity(player_game_matrix)
    print(f"Similarity Matrix: \n{similarity_matrix}")

    # Create a dictionary to map players to their most similar players
    similarity_dict = {}
    for i, player in enumerate(players):
        similar_players = sorted(
            [(players[j], similarity_matrix[i][j]) for j in range(num_players) if i != j],
            key=lambda x: x[1], reverse=True
        )
        similarity_dict[player] = similar_players
    #print similarity dictionary    
    print(f"Similarity Dictionary: {similarity_dict}")
    return similarity_dict


def recommend_players(user_id):
    """Get recommended players for the given user_id."""
    similarity_dict = compute_similarity()

    print(f"Similarity dict: {similarity_dict}")  # Debugging line to see the entire dict

    if user_id not in similarity_dict:
        return []

    recommended = similarity_dict[user_id]
    # Log the recommended players to see the output
    print(f"Recommended players for {user_id}: {recommended}")
    # Remove the user from their own recommendations
    recommended_players = [
        player for player, similarity in recommended if player != user_id
    ]

    return recommended_players


