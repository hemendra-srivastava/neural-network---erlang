-module(ann).
-export([perceptron/3, sigmoid/1, dot_prod/2, feed_forward/2, replace_input/2, convert_to_list/1]).

sigmoid(X) ->
    1 / 1 + (math:exp(-X)).

%%% added optimization for tail recursion
dot_prod([], [], Value) ->
    Value;
dot_prod([X_head | X_tail], [Y_head | Y_tail], Value) ->
    dot_prod(X_tail, Y_tail, X_head * Y_head + Value).

feed_forward(Weights, Inputs) ->
    sigmoid(dot_prod(Weights, Inputs)).

perceptron(Weights, Inputs, Output_PIDs) ->
    receive
	{stimulate, Input} ->
	    New_inputs = replace_input(Inputs, Input),
	    Output = feed_forward(Weights, convert_to_list(New_inputs)),
	    if Output_PIDs =/= [] ->
		    lists:foreach(fun(Output_PID) ->
					  Output_PID ! {stimulate, {self(), Output}}
				  end,
				  Output_PIDs);
	       Output_PIDs =:= [] ->
		    io:format("~n~w outputs: ~w", [self(), Output])
	    end,
	    perceptron(Weights, New_inputs, Output_PIDs)
    end.

replace_input(Inputs, Input) ->
    {Input_PID, _} = Input,
    lists:keyreplace(Input_PID, 1, Inputs, Input).

convert_to_list(Inputs) ->
    lists:map(fun(Tup) -> {_, Val} = Tup, Val end, Inputs).



