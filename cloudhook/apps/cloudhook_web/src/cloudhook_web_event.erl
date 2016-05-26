-module(cloudhook_web_event).

-export([
	init/2
]).

-define(FROM, "ricecake@tfm.nu").

init(Req, Args) ->
	%{Addr, _Port} = cowboy_req:peer(Req),
	%_IP = list_to_binary(inet_parse:ntoa(Addr)),
	{ok, Body, Req2} = cowboy_req:body(Req),
	Event = jsx:decode(Body, [return_maps]),
	{Recipient, Opts} = get_recipient(Event),
	Message = get_message(Event),
	_Res = gen_smtp_client:send_blocking({?FROM, Recipient, Message}, Opts),
	{ok, cowboy_req:reply(204, Req2), Args}.

get_recipient(#{ <<"type">> := <<"Context A">> }) -> {["ricecake@tfm.nu"], [{relay, "mail.tfm.nu"}]};
get_recipient(#{ <<"type">> := <<"Context B">> }) -> {["geoffcake@gmail.com"], [{relay, "smtp.gmail.com"}]};
get_recipient(#{ <<"type">> := <<"Context C">> }) -> {["farlateal@gmail.com"], [{relay, "smtp.gmail.com"}]};
get_recipient(#{ <<"type">> := _ }) -> {["ricecake@tfm.nu"], [{relay, "mail.tfm.nu"}]}.

get_message(#{ <<"lat">> := Lat, <<"lon">> := Lon, <<"time">> := Time} = Args) ->
	{Recipients, _} = get_recipient(Args),
	string:join([
		"Subject: This is a test email",
		"From: Sebastian Green-Husted",
		string:concat("To: ", string:join(Recipients, ", ")),
		"",
		binary_to_list(<<$@, Time/binary, ": ", Lat/binary, ", ", Lon/binary>>)
	], "\r\n").
