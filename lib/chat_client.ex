defmodule Chat.ChatClient do

  def connect(username, server),
    do: spawn(__MODULE__, :init, [username, server])

  def init(username, server) do
    send(server, {self, :connect, username})
    loop(username, server)
  end

  def loop(username, server) do
    receive do
      {:info, msg} ->
        IO.puts(~s{[#{username}'s clients] - #{msg}})
        loop(username, server)

      {:new_msg, from, msg} ->
        IO.puts(~s{[#{username}'s client] - From #{from}: #{msg}})
        loop(username, server)

      {:new_priv_msg, from, msg} ->
        IO.puts(~s{[#{username}'s client] - From #{from}(Private): #{msg}})
        loop(username, server)

      {:new_priv_msg, from, msg} ->
        IO.puts (~s{[#{username}'s client] - #{from}(Private): #{msg}})
        loop(username, server)

      {:send, msg} ->
        send(server, {self, :broadcast, msg})
        loop(username, server)

      {:priv, rec, msg} ->
        IO.puts(~s{[#{username}'s client] - To #{rec}(Private): #{msg}})
        send(server, {self, :priv, msg, rec})
        loop(username, server)

      :disconnect ->
        exit(0)
    end
  end
end
