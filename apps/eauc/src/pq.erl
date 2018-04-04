-module(pq).
-compile([export_all, nowarn_export_all]).

%postgresql queries module

% get_all_cities()
% update_city_by_id(City_Id, City_Name, City_Pop)
% add_city(City_Name, City_Pop)
% add_city_return_id(City_Name, City_Pop)
% delete_city_by_id(City_Id)
% 
% get_time_now()
% get_finished_lots(Limit, Offset)
% get_active_lots(Limit, Offset)
% get_active_lots_by_ids(Ids, Limit)
% get_active_lot_bets_by_id(Lot_Id)
% get_user_money_nick_by_id(User_Id)
% update_user_money(Worker, User_Id, Money)
% make_money_log(Worker, User_Id, Money_Before, Money_Change, Money_Type)
% make_new_bet(Worker, Lot_Id, Nickname, User_Id, Bet_Add, Bet_Total)
% update_lot_info(Worker, Lot_Id, Last_Bet, Nickname, User_Id)
% get_user_lot_lastbet(User_Id, Lot_Id)
% make_finished_lots()
% get_user_login(Email)
% add_new_lot(Name, Count, Start_Bet, Bet_Step, Prise, Time_Length, Start_Time, End_Time)
% 


%get_all_cities() ->
%  pg:select("SELECT id, name, population FROM test ORDER BY id", []).


%update_city_by_id(City_Id, City_Name, City_Pop) ->
%  pg:in_up_del("UPDATE test SET name = $1, population = $2 WHERE id = $3", [City_Name, City_Pop, City_Id]).


%add_city(City_Name, City_Pop) ->
%  pg:in_up_del("INSERT INTO test (name, population) VALUES ($1, $2)", [City_Name, City_Pop]).


%add_city_return_id(City_Name, City_Pop) ->
%  pg:returning("INSERT INTO test (name, population) VALUES ($1, $2) RETURNING id", [City_Name, City_Pop]).


%delete_city_by_id(City_Id) ->
%  pg:in_up_del("DELETE FROM test WHERE id = $1", [City_Id]).


get_time_now() ->
  pg:select("SELECT LOCALTIMESTAMP(0)", []).


get_finished_lots(Limit, Offset) ->
  pg:select("SELECT name, count, bet_count, bet_last, nickname_last, end_time FROM eauc_lots WHERE status = 2 ORDER BY end_time DESC LIMIT $1 OFFSET $2", [Limit, Offset]).


get_active_lots(Limit, Offset) ->
  pg:select("SELECT id, name, count, start_bet, bet_step, bet_count, bet_last, nickname_last, end_time FROM eauc_lots WHERE status = 1 ORDER BY end_time ASC LIMIT $1 OFFSET $2", [Limit, Offset]).


get_active_lots_by_ids(Ids, Limit) ->
  pg:select("SELECT id, start_bet, bet_step, bet_count, bet_last, nickname_last, status, end_time FROM eauc_lots WHERE id IN (" ++ Ids ++ ") Limit $1", [Limit]).


get_active_lot_bets_by_id(Lot_Id) ->
  pg:select("SELECT start_bet, bet_step, bet_last FROM eauc_lots WHERE (id = $1 AND status = 1) LIMIT 1", [Lot_Id]).


get_user_money_nick_by_id(User_Id) ->
  pg:select("SELECT nickname, money FROM eauc_users WHERE id = $1 LIMIT 1", [User_Id]).


update_user_money(Worker, User_Id, Money) ->
  pg:transaction_q(Worker, "UPDATE eauc_users SET money = $1 WHERE id = $2 ", [Money, User_Id]).


make_money_log(Worker, User_Id, Money_Before, Money_Change, Money_Type) ->
  pg:transaction_q(Worker, "INSERT INTO eauc_users_money_log (uid, money_before, money_change, money_type) VALUES ($1, $2, $3, $4)", [User_Id, Money_Before, Money_Change, Money_Type]).


make_new_bet(Worker, Lot_Id, Nickname, User_Id, Bet_Add, Bet_Total) ->
  pg:transaction_q(Worker, "INSERT INTO eauc_bets (lot_id, nickname, uid, bet_add, bet_total) VALUES ($1, $2, $3, $4, $5)", [Lot_Id, Nickname, User_Id, Bet_Add, Bet_Total]).


update_lot_info(Worker, Lot_Id, Last_Bet, Nickname, User_Id) ->
  pg:transaction_q(Worker, "UPDATE eauc_lots SET bet_last = $1, nickname_last = $2, uid_last = $3, bet_count = bet_count + 1 WHERE id = $4 ", [Last_Bet, Nickname, User_Id, Lot_Id]).


get_user_lot_lastbet(User_Id, Lot_Id) ->
  pg:select("SELECT bet_total FROM eauc_bets WHERE lot_id = $1 AND uid = $2 ORDER BY id DESC LIMIT 1", [Lot_Id, User_Id]).


make_finished_lots() ->
  pg:in_up_del("UPDATE \"eauc_lots\" SET \"status\" = 2 WHERE (\"status\" = 1 AND \"end_time\" < LOCALTIMESTAMP(0) );", []).


get_user_login(Email) ->
  pg:select("SELECT id, nickname, password, status FROM eauc_users WHERE email = $1 LIMIT 1", [Email]).


add_new_lot(Name, Count, Start_Bet, Bet_Step, Prise, Time_Length, Start_Time, End_Time) ->
  pg:in_up_del("INSERT INTO eauc_lots (name, count, start_bet, bet_step, prise, time_length, start_time, end_time) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)", [Name, Count, Start_Bet, Bet_Step, Prise, Time_Length, Start_Time, End_Time]).


