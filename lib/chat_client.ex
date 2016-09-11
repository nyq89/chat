defmodule Chat.ChatClient do

  def connect(username, server),
    do: spawn(__MODULE__, :init, [username, server])

  def init(username, server) do
    send(server, {self, :connect, username})
    loop(username, server, ["main"])
  end

  def loop(username, server, channels) do
    receive do
      {{:info, msg}, channelname} ->
        IO.puts(~s{[#{username}'s clients][#{channelname}] - #{msg}})
        loop(username, server, channels)

      {:join, channelname} ->
        send(server, {self, :join_channel, username, channelname})
        loop(username, server, [channelname | channels])
      
      {:leave, channelname} ->
        send(server, {self, :leave_chanel, username, channelname})
        channels = List.delete(channels, channelname)
        loop(username, server, channels)

      {:new_msg, from, {msg, channelname}} ->
        IO.puts(~s{[#{username}'s client][#{channelname}] - From #{from}: #{msg}})
        loop(username, server, channels)

      {:new_priv_msg, from, msg} ->
        IO.puts(~s{[#{username}'s client] - From #{from}(Private): #{msg}})
        loop(username, server, channels)

      {:send, msg, channelname} ->
        if Enum.member?(channels, channelname) do
          send(server, {self, :broadcast, msg, channelname})
        else
          IO.puts("Not in channel #{channelname}")
        end
        loop(username, server, channels)

      {:priv, rec, msg} ->
        IO.puts(~s{[#{username}'s client] - To #{rec}(Private): #{msg}})
        send(server, {self, :priv, msg, rec})
        loop(username, server, channels)

      :disconnect ->
        exit(0)
    end
  end
end
