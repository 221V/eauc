-module(worker_bets).
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([complete_bets/1]).


start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init(_) ->
  %timer:sleep(3000),
  io:format("Worker bets starts ~n", []),
  ets:new(table_bets, [ordered_set, public, named_table]),
  erlang:send_after(7000, self(), process),
  {ok, []}.


handle_call(_Req, _From, State) ->
  {reply, not_handled, State}.


handle_cast(_Req, State) ->
  {noreply, State}.


handle_info(_Req, State) ->
  Bets = ets:match_object(table_bets, {'$1', '$2'}),
  ?MODULE:complete_bets(Bets),
  %io:format("~p~n~n", ["worker bets working!"]),
  
  erlang:send_after(500, self(), process),
  {noreply, State}.


terminate(Reason, _State) ->
  io:format("Worker inactive lot ~p terminating: ~p~n", [?MODULE, Reason]),
  ok.


code_change(_OldVsn, State, _Extra) -> 
  {ok, State}.


complete_bets([]) -> ok;
complete_bets([{{Timestamp, Lot_Id, User_Id}, Bet}|T]) ->
  Lot_Info = pq:get_active_lot_bets_by_id(Lot_Id),
  case Lot_Info of
    [] ->
      %% err -- active lot not found
      %% if we check active lot at insert bet into ets --
      %% can todo check here lot only by id
      %% but now only delete this bet
      ets:delete(table_bets, {Timestamp, Lot_Id, User_Id});
    
    [{Start_Bet, Bet_Step, Bet_Last}] ->
      %% lot is ok
      
      Bet_Valid1 = ((Bet_Last =/= 0) and ((Bet_Last + Bet_Step) =< Bet)) or (Start_Bet =< Bet),
      case Bet_Valid1 of
        true ->
          %% bet ok
          
          User_Money0 = pq:get_user_money_by_id(User_Id),
          case User_Money0 of
            [{User_Money}] ->
              
              case (User_Money >= Bet) of
                true ->
                  %% user money ok
                  
                  User_Last_Bet0 = pq:get_user_lot_lastbet(User_Id, Lot_Id),
                  case User_Last_Bet0 of
                    [] ->
                      %% no last bet by this user on this lot
                      
                      Money_New = User_Money - Bet,
                      ResultN = pg:transaction(fun() ->
                        %% transaction
                        
                        pq:update_user_money(User_Id, Money_New),
                        pq:make_money_log(User_Id, User_Money, Bet, 1)
                        
                      end),
                      
                      case ResultN of
                        ok ->
                          %% transaction ok
                          ets:delete(table_bets, {Timestamp, Lot_Id, User_Id});
                        _ ->
                          %% transaction err
                          err
                      end;
                    
                    [{User_Last_Bet}] ->
                      %% there are some last bet by this user on this lot
                      
                      Money_Change = Bet - User_Last_Bet,
                      Money_New = User_Money - Bet,
                      ResultN = pg:transaction(fun() ->
                        %% transaction
                        
                        pq:update_user_money(User_Id, Money_New),
                        pq:make_money_log(User_Id, User_Money, Money_Change, 2)
                        
                      end),
                      
                      case ResultN of
                        ok ->
                          %% transaction ok
                          ets:delete(table_bets, {Timestamp, Lot_Id, User_Id});
                        _ ->
                          %% transaction err
                          err
                      end;
                    
                    _ ->
                      %% db err
                      ets:delete(table_bets, {Timestamp, Lot_Id, User_Id})
                  end;
                _ ->
                  %% user money err
                  ets:delete(table_bets, {Timestamp, Lot_Id, User_Id})
              end;
            _ ->
              %% user money db err
              ets:delete(table_bets, {Timestamp, Lot_Id, User_Id})
          end;
        _ ->
          %% bet err
          ets:delete(table_bets, {Timestamp, Lot_Id, User_Id})
      end;
    
    _ ->
      %% err -- database/pool err? check settings
      %% delete this bet
      ets:delete(table_bets, {Timestamp, Lot_Id, User_Id})
  end,
  
  ?MODULE:complete_bets(T);
complete_bets(_) -> ok.


