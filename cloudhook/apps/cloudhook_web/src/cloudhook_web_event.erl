-module(cloudhook_web_event).

-export([
	init/2
]).

init(Req, Args) ->
	{Addr, _Port} = cowboy_req:peer(Req),
	IP = list_to_binary(inet_parse:ntoa(Addr)),
	{ok, Body, Req2} = cowboy_req:body(Req),
	Event = jsx:decode(Body, [return_maps]),
	io:format("~p~n", [{IP, Event}]),
	{ok, cowboy_req:reply(204, Req2), Args}.
