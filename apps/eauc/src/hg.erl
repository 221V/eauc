-module(hg).
-compile([export_all, nowarn_export_all]).

%html generate module

% generate_login_form()
% hello_user(Nickname, Uid)
% hello_admin_url()
% generate_finished_lots_main(Finished_Lots_Data, [])
% generate_active_lots_rows(Time_Now, Lots_Data, [])
% generate_reload_finished_lots_main()
% generate_reload_active_lots()
% generate_goto_finished()
% 


generate_login_form() ->
  <<"<br><label><span>Login:</span><br><input id=\"login\" type=\"email\"></label><br><br><label><span>Password:</span><br><input id=\"password\" type=\"password\"></label><br><br><button id=\"login_btn\">Log In</button><br>">>.


hello_user(Nickname, Uid) ->
  [ <<"<br><span id=\"hellouser\">Hello, <span>">>, Nickname, <<" [id:">>, erlang:integer_to_binary(Uid), <<"]">>, <<"</span></span><br><br><span class=\"usermoney\">Money on account: <span id=\"usermoney\"></span></span><br><br><button id=\"logout\">Logout</button>">> ].


hello_admin_url() ->
  <<"<a href=\"/adminka/\">Admin panel</a>">>.


%generate_finished_lots_main(Finished_Lots_Data, [])
generate_finished_lots_main([], []) -> <<"<p>No data !</p>">>;
generate_finished_lots_main([], Acc) -> lists:reverse(Acc);
generate_finished_lots_main(Finished_Lots_Data, []) ->
  Z = [ <<"<p><span class=\"m_lot_count\">Count</span><span class=\"m_lot_name\">Lot name</span><span class=\"m_lot_bet_count\">Bet count</span><span class=\"m_lot_bet_last\">Bet win</span><span class=\"m_lot_nickname_last\">Nickname win</span><span class=\"m_lot_time\">Win-time</span></p>">> ],
  ?MODULE:generate_finished_lots_main(Finished_Lots_Data, [Z|[]]);
generate_finished_lots_main([{Name, Count, Bet_Count, Bet_Last, Nickname_Last, End_Time}|T], Acc) ->
  Bet_Last2 = case Bet_Last of
    0 -> <<"----">>;
    %_ -> hm:balance_int2bin(Bet_Last)
    _ -> [ <<" $ ">>, erlang:integer_to_binary(erlang:ceil(Bet_Last/100)) ]
  end,
  Nickname_Last2 = case Nickname_Last of
    <<"Nobody">> -> <<"----">>;
    _ -> Nickname_Last
  end,
  
  Z = [ <<"<p><span class=\"m_lot_count\">">>, erlang:integer_to_binary(Count), <<" x </span><span class=\"m_lot_name\">">>, Name, <<"</span><span class=\"m_lot_bet_count\">">>, erlang:integer_to_binary(Bet_Count), <<"</span><span class=\"m_lot_bet_last\">">>, Bet_Last2, <<"</span><span class=\"m_lot_nickname_last\">">>, Nickname_Last2, <<"</span><span class=\"m_lot_time\">">>, hm:timestamp2binary(End_Time), <<"</span></p>">> ],
  ?MODULE:generate_finished_lots_main(T, [Z|Acc]);
generate_finished_lots_main(_, []) -> <<"<p>Database error !</p>">>.


generate_active_lots_rows(_, [], []) -> <<"<p>No data !</p>">>;
generate_active_lots_rows(_, [], Acc) -> lists:reverse(Acc);
generate_active_lots_rows(Time_Now, Lots_Data, []) ->
  Z = [ <<"<p><span class=\"a_lot_time\">Lot time</span><span class=\"a_lot_count\">Count</span><span class=\"a_lot_name\">Lot name</span><span class=\"a_lot_bet_count\">Bet count</span><span class=\"a_lot_nickname_last\">Last nickname</span><span class=\"a_lot_bet_last\">Last bet</span><span class=\"a_lot_bet\"></span></p>">> ],
  ?MODULE:generate_active_lots_rows(Time_Now, Lots_Data, [Z|[]]);
generate_active_lots_rows(Time_Now, [{Id, Name, Count, Start_Bet, Bet_Step, Bet_Count, Bet_Last, Nickname_Last, End_Time}|T], Acc) ->
  Timer_Time = hm:timediff2binary(Time_Now, End_Time),
  Start_Bet2 = erlang:ceil(Start_Bet/100),
  Bet_Last2 = erlang:ceil(Bet_Last/100),
  Bet_Step2 = erlang:ceil(Bet_Step/100), 
  Bet_Next = case Bet_Last of
    0 ->
      erlang:integer_to_binary(Start_Bet2);
    _ ->
      erlang:integer_to_binary(Bet_Last2 + Bet_Step2)
  end,
  
  Z = [ <<"<p class=\"a_lots\" data-id=\"">>, erlang:integer_to_binary(Id), <<"\"><span class=\"a_lot_time\">">>, Timer_Time,
   <<"</span><span class=\"a_lot_count\">">>, erlang:integer_to_binary(Count), <<" x </span><span class=\"a_lot_name\">">>, Name, <<"</span><span class=\"a_lot_bet_count\">">>, erlang:integer_to_binary(Bet_Count), <<"</span><span class=\"a_lot_nickname_last\">">>, Nickname_Last, <<"</span><span class=\"a_lot_bet_last\">$ ">>, erlang:integer_to_binary(Bet_Last2), <<"</span><span class=\"a_lot_bet\">$ <input type=\"number\" min=\"">>, Bet_Next, <<"\" step=\"">>, erlang:integer_to_binary(Bet_Step2), <<"\" value=\"">>, Bet_Next, <<"\"><button class=\"new_bet\">New bet</button><span class=\"new_bet_note\"></span></span></p>">> ],
  ?MODULE:generate_active_lots_rows(Time_Now, T, [Z|Acc]);
generate_active_lots_rows(_, _, _) -> <<"<p>Database error !</p>">>.


generate_reload_finished_lots_main() ->
  <<"<br><button id=\"reload_finished_main\">Reload last 10 finished lots</button><br>">>.


generate_reload_active_lots() ->
  <<"<br><button id=\"reload_active_lots\">Reload first 10 active lots</button><br>">>.


generate_goto_finished() ->
  <<"<br><a href=\"/\">Go to finished lots</a><br>">>.




