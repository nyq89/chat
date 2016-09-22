defmodule Chat.ChatServer do

  def start, do: spawn(__MODULE__, :init, [])

  def init do
    Process.flag(:trap_exit, true)
    loop(%{"main" => [], :clients => []})
  end

  def loop(channels) do
    receive do
      {sender, :connect, username} ->
        Process.link(sender)
        main = Map.get(channels, "main")
        clients = Map.get(channels, :clients)
        broadcast({:info, username <> " joined the chat and channel main"}, main, "main")
        channels = %{channels | "main" => [{username, sender} | main], :clients => [{username, sender} | clients] }
        loop(channels)

      {sender, :join_channel, username, channelname} ->
        channel = Map.get(channels, channelname, [])
        channels = Map.put(channels, channelname, [{username, sender} | channel])
        broadcast({:info, "[" <> channelname <> "]" <>
          username <> " joined the channel"},
          Map.get(channels, channelname),
          channelname)
        loop(channels)

      {sender, :broadcast, msg, channelname} ->
        clients = Map.get(channels, channelname)
        broadcast({:new_msg, find(sender, clients), msg}, clients, channelname)
        loop(channels)

      {sender, :priv, msg, rec} ->
        clients = Map.get(channels, :clients)
        priv({:new_priv_msg, find(sender, clients), msg}, rec, clients)
        loop(channels)

      {sender, :leave_channel, channelname} ->
        name = Map.get(channels, channelname) |> find(sender)
        channel = Map.get(channels, channelname)
        channel = channel_update(Map.get(channels, channelname), name)
        leave(sender, channelname, channels)
        channels = %{channels | channelname => channel}
        loop(channels)

      {sender, :EXIT, userchannels} ->
        name = Map.get(channels, :clients) |> find(sender)
        Enum.eache(userchannels, fn(x) ->
          leave(sender, x, channels)
          channels =%{channels | x => channel_update(Map.get(channels, x), name)}
        end)
        loop(channels)
    end
  end

  defp leave(sender, channelname, channels) do
      channel = Map.get(channels, channelname)
      broadcast({:info, find(sender, channel) <> "left the " <> channelname}, channel, channelname)
  end

  defp broadcast(msg, clients, channelname) do
    Enum.each(clients, fn {_, rec}
      -> send(rec, {msg, channelname})
    end)
  end

  defp priv(msg, rec, clients) do
    Enum.each(clients, fn {u, p}
      -> if rec  == u do
        send(p, msg) end end)
  end

  defp find(sender, [{u, p} | _]) when p == sender, do: u
  defp find(sender, [_ | t]), do: find(sender,t)

  defp channel_update(channel, sender) do
    Enum.filer(channel, (fn {u, _} ->
      u == sender
    end))
  end
end
