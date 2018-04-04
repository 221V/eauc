-module(hm).
-compile([export_all, nowarn_export_all]).

%-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").
%-include_lib("kernel/include/file.hrl").

%help module


%% validations

% is_valid_email(A)
% valid_start_time(A)
% valid_time_length(A)
% valid_ids_string(A)

%% trim

% trim(Bin)
% trim_l(List)

%% input data changing

% htmlspecialchars(String) % & -> &amp;, " -> &quot;, ' -> &apos;, < -> &lt;, > -> &gt;
% balance_int2bin(V)
% start_time_and_interval2end_date(Start_Time, Interval) %% end_date, Start_DateTime, Length_Sec

%% other

% get_session_value(Key,Req)
% timestamp2binary({{Year,Month,Day},{Hour,Minit,Second}})
% timediff2binary({{Year,Month,Day},{Hour,Minit,Second}},{{Year2,Month2,Day2},{Hour2,Minit2,Second2}})
% hash_pass(A)
% lots_data2jsarr(Time_Now, Lots_Data, Acc)
% 
% =================


%% validations


is_valid_email(A) ->
  %case re:run(A, "^[a-z0-9_-]+(\.[a-z0-9_-]+)*@([0-9a-z][0-9a-z-]*[0-9a-z]\.)+([a-z]{2,8})$") of
  case re:run(A, "^(.)+@(.)+\.(.+)$") of
    nomatch -> false;
    _ -> true
  end.


valid_start_time(A) ->
  case re:run(A, <<"^[0-9]{4}\/[0-9]{2}\/[0-9]{2}[\s]{1}[0-9]{2}:[0-9]{2}$">>) of
    nomatch -> false;
    _ -> true
  end.


valid_time_length(A) ->
  case re:run(A, "^[0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{2}$") of
    nomatch -> false;
    _ -> true
  end.


valid_ids_string(A) ->
  case re:run(A, "^([0-9]{1,}[,]{1})*[0-9]{1,}$") of
    nomatch -> false;
    _ -> true
  end.


%% trim


%trim binary
trim(<<>>) -> <<>>;
trim(Bin = <<C,BinTail/binary>>) ->
  case ?MODULE:is_whitespace(C) of
    true -> ?MODULE:trim(BinTail);
    false -> ?MODULE:trim_tail(Bin)
  end.

trim_tail(<<>>) -> <<>>;
trim_tail(Bin) ->
  Size = erlang:size(Bin) - 1,
  <<BinHead:Size/binary,C>> = Bin,
  case ?MODULE:is_whitespace(C) of
    true -> ?MODULE:trim_tail(BinHead);
    false -> Bin
  end.

%helper - trim symbols
is_whitespace($\s) -> true;
is_whitespace($\t) -> true;
is_whitespace($\n) -> true;
is_whitespace($\r) -> true;
is_whitespace(_) -> false.

%trim list
trim_l("") -> "";
trim_l(List=[H|T]) ->
  case ?MODULE:is_whitespace(H) of
    true -> ?MODULE:trim_l(T);
    false -> ?MODULE:trim_tail_l(lists:reverse(List))
  end.

trim_tail_l("") -> "";
trim_tail_l(List=[H|T]) ->
  case ?MODULE:is_whitespace(H) of
    true -> ?MODULE:trim_tail_l(T);
    false -> lists:reverse(List)
  end.


%% input data changing


htmlspecialchars(String) ->
  unicode:characters_to_binary( [?MODULE:htmlspecialchars2(X) || X <- String], utf8, latin1).

%helper
% & -> &amp;, " -> &quot;, ' -> &apos;, < -> &lt;, > -> &gt;
htmlspecialchars2($&) -> "&amp;";
htmlspecialchars2($") -> "&quot;";
%htmlspecialchars2($') -> "&apos;";
htmlspecialchars2($') -> "&#39;";
htmlspecialchars2($<) -> "&lt;";
htmlspecialchars2($>) -> "&gt;";
htmlspecialchars2($|) -> "&#124;";
htmlspecialchars2($`) -> "&#96;";
htmlspecialchars2(A) -> A.
%"


balance_int2bin(V) ->
  if V =:= 0 ->
      <<"0.00">>;
    V =:= 100 ->
      <<"1.00">>;
    V < 100 ->
      erlang:list_to_binary("0." ++ erlang:integer_to_list(V));
    V > 100 ->
      V0 = erlang:integer_to_list(V),
      VL = erlang:length(V0) - 2,
      erlang:list_to_binary(string:sub_string(V0,1,VL) ++ "." ++ string:sub_string(V0,VL+1))
  end.


start_time_and_interval2end_date(Start_Time, Interval) ->
  %% <<"^[0-9]{4}\/[0-9]{2}\/[0-9]{2}[\s]{1}[0-9]{2}:[0-9]{2}$">> == Start_Time == binary
  %% "^[0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{2}$" == Interval == list string
  
  [S_T01, S_T02 |_] = string:split(Start_Time, <<" ">>, all),
  [S_T03, S_T04, S_T05 |_] = string:split(S_T01, <<"/">>, all),
  [S_T06, S_T07 |_] = string:split(S_T02, <<":">>, all),
  
  [I01, I02, I03, I04 |_] = string:split(Interval, ":", all),
  
  Start_DateTime = {{erlang:binary_to_integer(S_T03), erlang:binary_to_integer(S_T04), erlang:binary_to_integer(S_T05)},{erlang:binary_to_integer(S_T06), erlang:binary_to_integer(S_T07), 0}},
  Start_Timestamp = calendar:datetime_to_gregorian_seconds(Start_DateTime),
  
  Length_Sec = erlang:list_to_integer(I01) * 3600*24 + erlang:list_to_integer(I02) * 3600 + erlang:list_to_integer(I03) * 60 + erlang:list_to_integer(I04),
  [ calendar:gregorian_seconds_to_datetime( Start_Timestamp + Length_Sec ), Start_DateTime, Length_Sec ].


%% other


get_session_value(Key,Req) ->
  SessionCookie = n2o_cowboy:cookie(<<"site-sid">>, Req),
  ?MODULE:get_session_value2(n2o_session:lookup_ets({SessionCookie, Key})).

%helper
get_session_value2({_, _, _, _, A}) -> A;
get_session_value2(_) -> undefined.


%{{2017,10,18},{12,29,50.0}}
timestamp2binary({{Year,Month,Day},{Hour,Minit,Second}}) ->
  [erlang:integer_to_binary(Year), <<"/">>, ?MODULE:make_valid_day(Month), <<"/">>, ?MODULE:make_valid_day(Day), <<" ">>, ?MODULE:make_valid_day(Hour), <<":">>, ?MODULE:make_valid_day(Minit), <<":">>, ?MODULE:make_valid_day(erlang:trunc(Second))];
timestamp2binary(_) -> <<"undefined err !!7">>.

%helper
make_valid_day(Data) when Data < 10 ->
  [<<"0">>, erlang:integer_to_binary(Data)];
make_valid_day(Data) ->
  erlang:integer_to_binary(Data).


timediff2binary({{Year,Month,Day},{Hour,Minit,Second}},{{Year2,Month2,Day2},{Hour2,Minit2,Second2}}) ->
  Second1 = erlang:trunc(Second),
  Second21 = erlang:trunc(Second2),
  {Days, {Hours, Minits, Seconds}} = calendar:time_difference({{Year,Month,Day},{Hour,Minit,Second1}},{{Year2,Month2,Day2},{Hour2,Minit2,Second21}}),
  Hours2 = case Days of
    0 -> ?MODULE:make_valid_day(Hours);
    _ -> erlang:integer_to_binary((Days * 24) + Hours)
  end,
  [ Hours2, <<":">>, ?MODULE:make_valid_day(Minits), <<":">>, ?MODULE:make_valid_day(Seconds) ].


%make hash pass
hash_pass(A) ->
  S1 = <<"Some хороша salt!!\"@#ы$%5^&*()=="/utf8>>,
  S2 = <<"yeah ____________<>(c)2018++ lol"/utf8>>,
  A2 = erlang:list_to_binary(A),
  [ erlang:element(C+1, {$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$A,$B,$C,$D,$E,$F}) || <<C:4>> <= crypto:hash(sha512, <<S1/binary,A2/binary,S2/binary>>)].


% lots_data2jsarr(Time_Now, Lots_Data, Acc)
lots_data2jsarr(_, [], []) -> <<"[]">>;
lots_data2jsarr(Time_Now, Lots_Data, []) ->
  ?MODULE:lots_data2jsarr(Time_Now, Lots_Data, [<<"[">>]);
lots_data2jsarr(_, [], Acc) ->
  lists:reverse([<<"]">>|Acc]);
lots_data2jsarr(Time_Now, [{Id, Start_Bet, Bet_Step, Bet_Count, Bet_Last, Nickname_Last, Status, End_Time}|T], Acc) ->
  Timer_Time = ?MODULE:timediff2binary(Time_Now, End_Time),
  Lot_Bet_Input = case (Bet_Last > 0) of
    true ->
      erlang:integer_to_binary(erlang:floor((Bet_Last + Bet_Step)/100));
    _ ->
      erlang:integer_to_binary(erlang:floor(Start_Bet/100))
  end,
  End = case T of
    [] -> <<"">>;
    _ -> <<",">>
  end,
  
  Z = [ <<"[">>, erlang:integer_to_binary(Id), <<",">>, erlang:integer_to_binary(Status), <<",\"">>, Timer_Time, <<"\",">>, Lot_Bet_Input, <<",">>, erlang:integer_to_binary(Bet_Count), <<",">>, erlang:integer_to_binary(erlang:floor(Bet_Last/100)), <<",\"">>, Nickname_Last, <<"\"">>, <<"]">>, End ],
  
  ?MODULE:lots_data2jsarr(Time_Now, T, [Z|Acc]).


