-module(gol).
-compile(export_all).

init() ->
	frame:init(),
	frame:set_head("Conway's Game of Life in Erlang"),
	frame:set_foot("By Jonatan and Anders"),
	frame:set_w(100),
	frame:set_h(100),
	spawn_link(gol,gol,[]).

	%spawn_link(gol,draw,[]).

% TODO: Finish
draw() -> 
	receive
		{{X,Y},Alive} ->
			if
				Alive == 1 ->
					frame ! {change_cell, X, Y, purple};
				true ->
					frame ! {change_cell, X, Y, black}
			end
	end,
	draw().

% Old function to draw content for browser
gol() ->
    X = random:uniform(20),
    Y = random:uniform(10),
    frame ! {change_cell, X, Y, purple},
    receive 
        after 100 ->
                gol:gol()
        end.

% A cell holds its coordinate, state and a list of neighbours
cell(X, Y, State, []) ->
	receive 
		{Neighbours} ->
			cell(X, Y, State, Neighbours)
	end;

cell(X, Y, State, Neighbours) ->
	receive
		{broadcast, Pid} -> 
			broadcastState(State, Neighbours),
			Pid ! { self() }
	end,

	receive
		{update, Pid2} -> 
			Pid2 ! { self(), State },

			% TODO
			case State of 
				1 -> cell(X, Y, 1, Neighbours); 
				0 -> cell(X, Y, 0, Neighbours)
			end
	end.

% Keep the game updated and synced
tic(Cells, KeyList, RitaPid) ->
	%broadcast(Cells, KeyList),
	%update(Cells, KeyList, RitaPid),
	timer:apply_after(1005, gol, tic, [Cells, KeyList, RitaPid]).
	
% Broadcast its state to all neighbours
broadcastState(_, []) -> ok;
broadcastState(Alive, [Neighbour|Neighbours]) ->
	Neighbour ! {Alive},
	broadcastState(Alive, Neighbours).