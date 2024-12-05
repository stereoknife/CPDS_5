-module(control).
-export([go/2]).

% N is the number of ring processes, N >= 1
% M is the range of targets
% flush the mailbox to erase obsolet info,
% creates the worker ring and starts the game
%
go(N, M) -> flush_mailbox(),
    TargetList = generate(M),
    io:format("~p~n", [TargetList]),
    [FirstWorker|_] = worker_ring(N, self()),
    FirstWorker ! token,
    ResultList = controlgame(TargetList, []),
    io:format("~w~n", [ResultList]),
    FirstWorker ! stop.

%generates a list of M random numbers in rtrange 1..M
generate(0) -> [];
generate(M) -> [rand:uniform(M)|generate(M-1)].

controlgame([], ResultList) -> ResultList;
controlgame([H|T], ResultList) ->
    receive
        {Pid, eat} -> controlgame(T, [{Pid, H}|ResultList])
    end.

flush_mailbox() -> receive
                        _Any -> flush_mailbox()
                   after 0 -> ok
                   end.

%
%
% Some auxiliar functions may be necessary
%
%

% sets up a ring of N workers, each one running worke_node function from worker module

worker_ring(N, PidControl) ->
    LastPid = spawn(worker, worker_node, [PidControl]),
    [H|T] = worker_ring_spawn(N-1, [LastPid], PidControl),
    LastPid ! H,
    [H|T].

worker_ring_spawn(0, L, _) -> L;
worker_ring_spawn(N, [H|T], PidControl) ->
    Pid = spawn(worker, worker_node, [PidControl]),
    Pid ! H,
    worker_ring_spawn(N-1, [Pid|[H|T]], PidControl).