-module(cloudhook_web_event).

-export([
	init/2
]).

-define(FROM, "ricecake@tfm.nu").

init(Req, Args) ->
	{ok, Body, Req2} = cowboy_req:body(Req),
	Event = jsx:decode(Body, [return_maps]),
	{Recipient, Opts} = get_recipient(Event),
	Message = get_message(Event),
	Res = gen_smtp_client:send_blocking({?FROM, Recipient, Message}, Opts),
	{ok, cowboy_req:reply(200, [], jsx:encode(#{ res => Res }), Req2), Args}.

get_recipient(#{ <<"type">> := <<"Context A">> }) -> {["ricecake@tfm.nu"],     application:get_env(cloudhook_web, smtp_opts, [{relay, "mail.tfm.nu"}])};
get_recipient(#{ <<"type">> := <<"Context B">> }) -> {["geoffcake@gmail.com"], application:get_env(cloudhook_web, smtp_opts, [{relay, "gmail-smtp-in.l.google.com"}])};
get_recipient(#{ <<"type">> := <<"Context C">> }) -> {["farlateal@gmail.com"], application:get_env(cloudhook_web, smtp_opts, [{relay, "gmail-smtp-in.l.google.com"}])};
get_recipient(#{ <<"type">> := _ }) ->               {["ricecake@tfm.nu"],     application:get_env(cloudhook_web, smtp_opts, [{relay, "mail.tfm.nu"}])}.


get_message(#{ <<"lat">> := Lat, <<"lon">> := Lon, <<"time">> := Time} = Args) ->
	{Recipients, _} = get_recipient(Args),
	string:join([
		"Subject: This is a test email",
		"From: Sebastian Green-Husted",
		string:concat("To: ", string:join(Recipients, ", ")),
		"",
		io_lib:format("@~w: ~w, ~w", [Time, Lat, Lon])
	], "\r\n").
