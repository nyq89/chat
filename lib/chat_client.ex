defmodule ChatClient do

  def connect(username, server), do: spawn(__MODULE__, :init, [username, server])

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
        IO.puts(~s{[#{username}'s client] - #{from}: #{msg}})
        loop(username, server)

      {:send, msg} ->
        send(server, {self, :broadcast, msg})
        loop(username, server)

      :disconnect ->
        exit(0)
    end
  end
end
