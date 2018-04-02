-module(pg).
-behaviour(gen_server).
-compile([export_all, nowarn_export_all]).


start_pool() ->
  timer:sleep(1000),
  Params = #{host => "localhost",
    port => 6432,
    username => "user",
    password => "pass",
    database => "database"},
  
  case epgsql_pool:start(my_main_pool, 50, 100, Params) of
    {ok, _} ->
      io:format("~p~n",["pg_pool start !!"]),
      ok;
    Z ->
      io:format("Pool start err: ~p~n~p~n", ["err db connect", Z]),
      err
  end.


start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init(_) ->
  %timer:sleep(3000),
  %io:format("~p~n",[?MODULE:start_pool()]),
  %?MODULE:start_pool(),
  %io:format("~p~n",["789000"]),
  erlang:spawn(?MODULE, start_pool, []),
  {ok, []}.


handle_call(_Req, _From, State) ->
  {reply, not_handled, State}.


handle_cast(_Req, State) ->
  {noreply, State}.


handle_info(_Req, State) ->
  {noreply, State}.


terminate(Reason, _State) ->
  io:format("Pool ~p terminating: ~p~n", [?MODULE, Reason]),
  ok.


code_change(_OldVsn, State, _Extra) -> 
  {ok, State}.


transaction(Fun) ->
  case epgsql_pool:transaction(my_main_pool, Fun) of
    {ok, _} ->
      ok;
    Error ->
      io:format("transaction error: ~p~n in tr fun: ~p~n", [Error, Fun]),
      Error
  end.


select(Q,A) ->
  case epgsql_pool:query(my_main_pool, Q, A) of
    {ok,_,R} ->
      R;
    {error,E} ->
      io:format("~p~n", [E]),
      {error,E}
  end.


in_up_del(Q,A) ->
  case epgsql_pool:query(my_main_pool, Q, A) of
    {ok,R} ->
      R;
    {error,E} ->
      io:format("~p~n", [E]),
      {error,E}
  end.


returning(Q,A) ->
  case epgsql_pool:query(my_main_pool, Q, A) of
    {ok,1,_,R} ->
      R;
    {error,E} ->
      io:format("~p~n", [E]),
      {error,E}
  end.


