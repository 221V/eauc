-module(auction).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").

main() -> #dtl{file="auction",app=eauc,bindings=[]}.


event(init) ->
  Nickname = wf:user(),
  case Nickname of
    undefined ->
      wf:redirect("/");
    _ ->
      
      Time_Now2 = case pq:get_time_now() of
        [{Time_Now}] -> hm:timestamp2binary(Time_Now);
        _ -> Time_Now = {{2000,1,1},{1,1,1}}, hm:timestamp2binary(Time_Now)
      end,
      
      Uid = wf:session(uid),
      Hello_User_HTML = hg:hello_user(Nickname, Uid),
      
      Account_Money = case pq:get_user_money_nick_by_id(Uid) of
        [{_Nick, User_Money}] ->
          User_Money2 = erlang:integer_to_binary(erlang:floor(User_Money/100)),
          User_Money2;
        _ ->
          User_Money = <<"">>,
          User_Money2 = <<"0">>,
          <<"database err">>
      end,
      
      Limit = 10,
      Offset = 0,
      Lots_Data = pq:get_active_lots(Limit, Offset),
      Lots_HTML = hg:generate_active_lots_rows(Time_Now, Lots_Data, []),
      Reload_Active_Btn_HTML = hg:generate_reload_active_lots(),
      Goto_Finished_HTML = hg:generate_goto_finished(),
      
      wf:wire(wf:f("qi('hello_user').innerHTML='~s';qi('hello_user').style.display='block';logout_bind();"
                   "window.user_money=~s;qi('usermoney').innerHTML='$ ~s';"
                   "qi('time_now').innerHTML='~s';page_timer_tick();"
                   "qi('lots_active').innerHTML='~s~s~s';"
                   "page_timers_back();reload_active_bind();new_bet1_bind();"
                   "setTimeout(function(){update_display_user_money();}, 1000);"
                   "setTimeout(function(){update_display_active_lots();}, 1000);", [unicode:characters_to_binary(Hello_User_HTML,utf8), unicode:characters_to_binary(User_Money2,utf8), unicode:characters_to_binary(Account_Money,utf8), unicode:characters_to_binary(Time_Now2,utf8), unicode:characters_to_binary(Lots_HTML,utf8), unicode:characters_to_binary(Reload_Active_Btn_HTML,utf8), unicode:characters_to_binary(Goto_Finished_HTML,utf8)])),
      case wf:session(status) of
        2 ->
          Admin_Url_HTML = hg:hello_admin_url(),
          wf:wire(wf:f("add_url('~s');", [unicode:characters_to_binary(Admin_Url_HTML,utf8)]));
        _ -> ok
      end
  end;


event({client,{reload_active}}) ->
  case wf:user() of
    undefined ->
      wf:redirect("/");
    _ ->
      
      Time_Now2 = case pq:get_time_now() of
        [{Time_Now}] -> hm:timestamp2binary(Time_Now);
        _ -> Time_Now = {{2000,1,1},{1,1,1}}, hm:timestamp2binary(Time_Now)
      end,
      
      Limit = 10,
      Offset = 0,
      Lots_Data = pq:get_active_lots(Limit, Offset),
      Lots_HTML = hg:generate_active_lots_rows(Time_Now, Lots_Data, []),
      Reload_Active_Btn_HTML = hg:generate_reload_active_lots(),
      Goto_Finished_HTML = hg:generate_goto_finished(),
      
      wf:wire(wf:f("timers.forEach(function(el){clearTimeout(el);});new_bet1_unbind();"
                   "qi('time_now').innerHTML='~s';page_timer_tick();"
                   "qi('lots_active').innerHTML='~s~s~s';page_timers_back();"
                   "reload_active_bind();window.reload_wait=false;new_bet1_bind();", [unicode:characters_to_binary(Time_Now2,utf8), unicode:characters_to_binary(Lots_HTML,utf8), unicode:characters_to_binary(Reload_Active_Btn_HTML,utf8), unicode:characters_to_binary(Goto_Finished_HTML,utf8)]))
  end;


event({client,{new_bet1, Lot_Id, New_Bet}}) ->
  %% action after user's click make new bet
  %% check is valid new bet and add to bets queue
  
  Nickname = wf:user(),
  case Nickname of
    undefined ->
      err;
    _ ->
      %% ok, logged user
      
      Valid_Data1 = (erlang:is_integer(Lot_Id) and (Lot_Id > 0)) and (erlang:is_integer(New_Bet) and (New_Bet > 0)),
      
      case Valid_Data1 of
        true ->
          %% ok
          
          New_Bet2 = New_Bet * 100,
          Uid = wf:session(uid),
          User_Money0 = pq:get_user_money_nick_by_id(Uid),
          case User_Money0 of
            [{_Nick, User_Money}] ->
              
              case (User_Money >= New_Bet2) of
                true ->
                  %% user money ok, bet ok
                  
                  Lot_Info = pq:get_active_lot_bets_by_id(Lot_Id),
                  case Lot_Info of
                    [] ->
                      %% err - active lot not found
                      wf:wire("window.bet1_wait=false;alert('invalid bet data !');");
                    [{Start_Bet, Bet_Step, Bet_Last}] ->
                      %% lot ok
                      
                      Valid_Data2 = ((Bet_Last =/= 0) and ((Bet_Last + Bet_Step) =< New_Bet2)) or (Start_Bet =< New_Bet2),
                      case Valid_Data2 of
                        true ->
                          %% bet ok, user money ok
                          
                          DateTimeSeconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
                          ets:insert(table_bets, {{DateTimeSeconds, Lot_Id, Uid}, New_Bet2}),
                          %% change btn color here
                          wf:wire("window.bet1_wait=false;");
                        _ ->
                          wf:wire("window.bet1_wait=false;alert('invalid bet data !');")
                      end;
                    _ ->
                      %% db err
                      wf:wire("window.bet1_wait=false;alert('db err !');")
                  end;
                _ ->
                  %% bet err
                  wf:wire("window.bet1_wait=false;alert('invalid bet data !');")
              end;
            _ ->
              %% user money err
              wf:wire("window.bet1_wait=false;alert('invalid bet data !');")
          end;
        _ ->
          wf:wire("window.bet1_wait=false;alert('invalid bet data !');")
      end
  end;


event({client,{update_user_money}}) ->
  Nickname = wf:user(),
  case Nickname of
    undefined ->
      err;
    _ ->
      % ok, logged user
      
      Uid = wf:session(uid),
      User_Money0 = pq:get_user_money_nick_by_id(Uid),
      case User_Money0 of
        [{_Nick, User_Money}] ->
          % ok
          
          User_Money2 = erlang:integer_to_binary(erlang:floor(User_Money/100)),
          
          wf:wire(wf:f("window.user_money=~s;qi('usermoney').innerHTML='$ ~s';"
            "window.upd_user_money_wait=false;setTimeout(function(){update_display_user_money();}, 5000);", [unicode:characters_to_binary(User_Money2,utf8), unicode:characters_to_binary(User_Money2,utf8)]));
        _ ->
          % user money db err
          wf:wire("window.upd_user_money_wait=false;setTimeout(function(){update_display_user_money();}, 10000);")
      end
  end;


event({client,{update_active_lots, Lots_Ids}}) ->
  Valid_Ids = hm:valid_ids_string(Lots_Ids),
  
  case Valid_Ids of
    true ->
      %% ids valid
      
      Limit = 10,
      Lots_Data = pq:get_active_lots_by_ids(Lots_Ids, Limit),
      case Lots_Data of
        [{_Some_Id, _, _, _, _, _, _, _}|_] ->
          %% data ok
          
          case pq:get_time_now() of
            [{Time_Now}] -> ok;
            _ -> Time_Now = {{2000,1,1},{1,1,1}}
          end,
          Data2 = hm:lots_data2jsarr(Time_Now, Lots_Data, []),
          
          wf:wire(wf:f("window.upd_active_lots_wait=false;"
            "do_update_display_active_lots('~s');"
            "setTimeout(function(){update_display_active_lots();}, 2000);",[unicode:characters_to_binary(Data2,utf8)]));
        _ ->
          %% err or no data
          wf:wire("window.upd_active_lots_wait=false;setTimeout(function(){update_display_active_lots();}, 2000);")
      end;
    _ ->
      %% invalid ids
      wf:wire("window.upd_active_lots_wait=false;setTimeout(function(){update_display_active_lots();}, 2000);")
  end;


event({client,{logout}}) ->
  wf:logout(),
  wf:redirect("/");


event(_) -> [].
