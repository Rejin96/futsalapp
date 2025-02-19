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
    path('pick_time_slot/',views_user.pick_time_slot,name='pick_time_slot'),
    path('join_request/',views_user.join_request,name='join_request'),
    path('handleparticipation/',views_user.handleparticiation,name='handleparticipation'),
    path('change_state/',views_user.Change_state,name='change_state'), #change from online to offline(need jwt as header)
    path('near_by/',views_user.near_by,name='near_by') #shows what fustal are nearby
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)