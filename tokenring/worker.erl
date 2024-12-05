-module(worker).
-export([worker_node/1]).

worker_node(PidControl) ->
    receive
        PidNext -> dowork(PidControl, PidNext)
    end.

dowork(PidControl, PidNext) ->
    receive
        stop -> PidNext ! stop;
        token ->
            PidControl ! {self(), eat},
            PidNext ! token,
            dowork(PidControl, PidNext)
    end.