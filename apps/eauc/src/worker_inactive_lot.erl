-module(worker_inactive_lot).
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init(_) ->
  %timer:sleep(3000),
  io:format("Worker inactive lot starts ~n", []),
  erlang:send_after(7000, self(), process),
  {ok, []}.


handle_call(_Req, _From, State) ->
  {reply, not_handled, State}.


handle_cast(_Req, State) ->
  {noreply, State}.


handle_info(_Req, State) ->
  Finished = pq:make_finished_lots(),
  %io:format("~p~n~n", ["worker inactive lots working!"]),
  Finished_Valid = erlang:is_integer(Finished) andalso (Finished =/= 0),
  case Finished_Valid of
    true ->
      io:format("Finished: ~p~n", [Finished]);
    _ -> ok
  end,
  
  erlang:send_after(1000, self(), process),
  {noreply, State}.


terminate(Reason, _State) ->
  io:format("Worker inactive lot ~p terminating: ~p~n", [?MODULE, Reason]),
  ok.


code_change(_OldVsn, State, _Extra) -> 
  {ok, State}.


