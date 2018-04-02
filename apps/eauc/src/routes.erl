-module(routes).
-include_lib("n2o/include/wf.hrl").
-export([init/2, finish/2]).

finish(State, Ctx) -> {ok, State, Ctx}.
init(State, Ctx) ->
    Path = wf:path(Ctx#cx.req),
    wf:info(?MODULE,"Route: ~p~n",[Path]),
    {ok, State, Ctx#cx{path=Path,module=route_prefix(Path)}}.

route_prefix(<<"/ws/",P/binary>>) -> route(P);
route_prefix(<<"/",P/binary>>)    -> route(P);
route_prefix(P)                   -> route(P).

route(<<>>)           -> main;
route(<<"auction/">>) -> auction;
route(<<"adminka/">>) -> adminka;
route(_)              -> redirect_to_main.
