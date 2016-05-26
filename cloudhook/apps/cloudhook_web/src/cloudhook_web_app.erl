%%%-------------------------------------------------------------------
%% @doc cloudhook_web OTP Application callback module.
%%
%% Provides the behaviour callbacks required for this
%% app to be started and managed by the OTP application
%% management framework.
%%
%% @end
%%%-------------------------------------------------------------------

-module(cloudhook_web_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	case cloudhook_web_sup:start_link() of
		{ok, Super} ->
			{ok, _} = cowboy_start(),
			{ok, Super}
	end.

%%--------------------------------------------------------------------
stop(_State) ->
	ok.

%%====================================================================
%% Internal functions
%%====================================================================

cowboy_start() ->
	{ok, Options} = determine_options(),
	Dispatch      = cowboy_router:compile([
		{'_', [
			{"/api/event",    cloudhook_web_event,       #{}},
			{"/static/[...]", cowboy_static,             {priv_dir, cloudhook_web, "static/"}}
		]}
	]),
	cowboy:start_http(http, 25, Options, [{env, [{dispatch, Dispatch}]}]).

determine_options() ->
	WithIp = case application:get_env(cloudhook_web, ip) of
		undefined -> [];
		{ok, IpString} when is_list(IpString) ->
			{ok, Ip} = inet_parse:address(IpString),
			[{ip, Ip}];
		{ok, IpTuple} when is_tuple(IpTuple) -> [{ip, IpTuple}]
	end,
	Port = application:get_env(cloudhook_web, port, 8888),
	{ok, [{port, Port} |WithIp]}.
