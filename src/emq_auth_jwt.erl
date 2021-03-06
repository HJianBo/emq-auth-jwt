%%--------------------------------------------------------------------
%% Copyright (c) 2013-2017 EMQ Enterprise, Inc. (http://emqtt.io)
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emq_auth_jwt).

-include_lib("jwt/include/jwt.hrl").

-include_lib("emqttd/include/emqttd.hrl").

-behaviour(emqttd_auth_mod).

%% emqttd_auth callbacks
-export([init/1, check/3, description/0]).

%%--------------------------------------------------------------------
%% emqttd_auth_mod callbacks
%%--------------------------------------------------------------------

init(Secret) ->
    {ok, Secret}.

check(_User, undefined, _Secret) ->
    {error, password_undefined};
check(#mqtt_client{}, Password, Secret) ->
    case jwt:decode(Password, Secret) of
        {ok, _Token} ->
            ok;
        {error, badtoken} ->
            ignore;
        {error, Error} ->
            lager:error("JWT decode error:~p", [Error]),
            {error, password_error}
    end.

description() ->
    "Authentication with JWT".

