from django.urls import path
from django.conf import settings
from .views import views_admin
from .views import views_user
from django.conf.urls.static import static


urlpatterns = [
    #admin user's
    path('csrf-token/', views_admin.csrf_token_view,name='csrf-token'),
    path('signup/', views_admin.signup, name='signup'),
    path('add_futsal/',views_admin.addfutsal,name='add_futsal'),
    path('complete_game_request/',views_admin.complete_game_request,name='complete_game_request'),
    path('add_timeslotfutsal/',views_admin.addtimeSlotbyFutsal,name='add_timeslotfutsal'),
    #user api's
    path('login/', views_user.login, name='login'),
    path('getplayer/', views_user.getplayer, name='player_data'),#get method need jwt 
    path('update/',views_user.update,name='update'),#(need jwt as header)
    path('change_state/',views_user.Change_state,name='change_state'), #change from online to offline(need jwt as header)
    #path('getfutsals/',views_user.getfutsal,name='getfutsals'),#for choosing
    path('near_by/',views_user.near_by,name='near_by'), #shows what fustal are nearby
    path('show_time_slot/',views_user.show_time_slot,name='show_time_slot'), 
    path('pick_time_slot/',views_user.pick_time_slot,name='pick_time_slot'),
    path('show_game_req/',views_user.show_game_req,name='show_game_req'),
    path('join_request/',views_user.join_request,name='join_request'),
    #see the game details
    path('see_game_details/',views_user.see_game_details,name='see_game_details'),
    path('created_game_details/',views_user.created_game_details,name='created_game_details'),
    path('handleparticipation/',views_user.handleparticiation,name='handleparticipation'),
    #cosine algorithm
    path('recommend_players/',views_user.recommend_players_view,name='recommend_players'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
