// api_urls.dart
const String baseUrl = "http://192.168.1.68:8000";

const Map<String, String> apiUrls = {
  "csrftoken": "$baseUrl/csrf-token/",
  "signup": "$baseUrl/signup/",
  "login": "$baseUrl/login/",
  "getplayer": "$baseUrl/getplayer/",
  "update": "$baseUrl/update/",
  "changestate": "$baseUrl/change_state/",
  "getfutsals": "$baseUrl/getfutsals/",
  "nearBy": "$baseUrl/near_by/",
  "showtimeslot": "$baseUrl/show_time_slot/",
  "picktimeslot": "$baseUrl/pick_time_slot/",
  "showgamereq": "$baseUrl/show_game_req/",
  "joinrequest": "$baseUrl/join_request",
  "seegamedetails": "$baseUrl/see_game_details/",
  "createdgamedetails": "$baseUrl/created_game_details/",
  "handleparticipation": "$baseUrl/handleparticipation/",
};
