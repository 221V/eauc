-module(redirect_to_main).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").

main() -> #dtl{file="null",app=eauc,bindings=[]}.

event(init) ->
  wf:redirect("/");

event(_) -> [].
