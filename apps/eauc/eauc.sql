
DROP TABLE IF EXISTS eauc_users;
CREATE TABLE "eauc_users" (
  "id" bigserial,
  "nickname" varchar(255) NOT NULL,
  "email" varchar(255) NOT NULL,
  "password" varchar(255) NOT NULL,
  "status" smallint NOT NULL DEFAULT 1,
  -- status = banned-0, user-1, admin-2
  "money" integer NOT NULL DEFAULT 0,
  -- in pennies
  "inserted_at" TIMESTAMP NOT NULL DEFAULT LOCALTIMESTAMP(0),
  "updated_at" TIMESTAMP NOT NULL DEFAULT LOCALTIMESTAMP(0),
  PRIMARY KEY ("id")
);
INSERT INTO "eauc_users" (id, nickname, email, password, status) VALUES (1, 'test1', 'test1@gmail.com', 'DA66E8AFBF93B668623FD42FD989E972D3A4B2BAC5DC5DA7FB6ADE6F542F4CCFF0117B00CE5D76F045FA1279EDA69E2A16CA2276D2FF419D8807E46FB0B69D9E', 2);
INSERT INTO "eauc_users" (id, nickname, email, password) VALUES (2, 'test2', 'test2@gmail.com', 'DA66E8AFBF93B668623FD42FD989E972D3A4B2BAC5DC5DA7FB6ADE6F542F4CCFF0117B00CE5D76F045FA1279EDA69E2A16CA2276D2FF419D8807E46FB0B69D9E');
INSERT INTO "eauc_users" (id, nickname, email, password) VALUES (3, 'test3', 'test3@gmail.com', 'DA66E8AFBF93B668623FD42FD989E972D3A4B2BAC5DC5DA7FB6ADE6F542F4CCFF0117B00CE5D76F045FA1279EDA69E2A16CA2276D2FF419D8807E46FB0B69D9E');
-- pass 12345678
ALTER SEQUENCE eauc_users_id_seq RESTART WITH 4;


DROP TABLE IF EXISTS eauc_users_money_log;
CREATE TABLE "eauc_users_money_log" (
  "id" bigserial,
  "uid" bigint NOT NULL,
  -- references eauc_users id
  "money_before" integer NOT NULL,
  -- in pennies
  "money_change" integer NOT NULL,
  -- in pennies -- how many add or decrease
  "money_type" smallint NOT NULL DEFAULT 1,
  -- money_type = 1-bet full-new (-), 2-bet partial-update (-), 3-addition (+)
  "inserted_at" TIMESTAMP NOT NULL DEFAULT LOCALTIMESTAMP(0),
  PRIMARY KEY ("id")
);


DROP TABLE IF EXISTS eauc_lots;
CREATE TABLE "eauc_lots" (
  "id" bigserial,
  "name" varchar(255) NOT NULL,
  -- name of lot
  "count" integer NOT NULL,
  -- count of pieces in lot
  "start_bet" integer NOT NULL,
  -- in pennies
  "bet_step" integer NOT NULL,
  -- in pennies
  "bet_count" integer NOT NULL DEFAULT 0,
  "bet_last" integer NOT NULL DEFAULT 0,
  -- in pennies
  "nickname_last" varchar(255) NOT NULL DEFAULT 'Nobody',
  -- references eauc_users nickname
  "uid_last" bigint NOT NULL DEFAULT 0,
  -- references eauc_users id
  "status" smallint NOT NULL DEFAULT 1,
  -- status = deleted-0, active-1, finished-2
  "prise" varchar(255) NOT NULL,
  -- prise -- key/vaucher or url with prize for winner
  "time_length" integer NOT NULL,
  -- time in seconds
  "start_time" TIMESTAMP NOT NULL DEFAULT LOCALTIMESTAMP(0),
  "end_time" TIMESTAMP NOT NULL,
  PRIMARY KEY ("id")
);

-- pg:select("SELECT LOCALTIMESTAMP(0)",[]).
-- [{{{2018,2,23},{0,31,35.0}}}]
-- pg:select("SELECT LOCALTIMESTAMP(0) + interval '37 minutes'",[]).
-- [{{{2018,2,23},{1,9,35.0}}}]
-- pg:select("SELECT '2018-02-23 02:25:02'::timestamp + interval '37 minutes'",[]).
-- [{{{2018,2,23},{3,2,2.0}}}]


DROP TABLE IF EXISTS eauc_bets;
CREATE TABLE "eauc_bets" (
  "id" bigserial,
  "lot_id" bigint NOT NULL,
  -- references eauc_lots id
  "nickname" varchar(255) NOT NULL,
  -- references eauc_users nickname
  "uid" bigint NOT NULL,
  -- references eauc_users id
  "bet_add" integer NOT NULL,
  -- in pennies, increase the previous bet(bid)
  "bet_total" integer NOT NULL,
  -- in pennies
  "timestamp" TIMESTAMP NOT NULL DEFAULT LOCALTIMESTAMP(0),
  PRIMARY KEY ("id")
);




