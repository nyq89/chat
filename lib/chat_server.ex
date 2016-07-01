defmodule ChatServer do

  def start, do: spawn(__MODULE__, :init, [])

  def init do
    Process.flag(:trap_exit, true)
    loop([])
  end

  def loop(clients) do
    receive do
      {sender, :connect, username} ->
        Process.link(sender)
        broadcast({:info, username <> " joined the chat"}, clients)
        loop([{username, sender} | clients])

      {sender, :broadcast, msg} ->
        broadcast({:new_msg, find(sender, clients), msg}, clients)
        loop(clients)

      {sender, :priv, msg, rec} ->
        priv({:new_priv_msg, find(sender, clients), msg}, rec, clients)
        loop(clients)

      {:EXIT, pid, _} ->
        broadcast({:info, find(pid, clients) <> " left the chat"}, clients)
        loop(clients |> Enum.filter(fn {_, rec}
          -> rec != pid
          end))
    end
  end

    defp broadcast(msg, clients) do
      Enum.each(clients, fn {_, rec}
        -> send(rec, msg)
      end)
    end

    defp priv(msg, rec, clients) do
      Enum.each(clients, fn {u, p}
        -> if rec  == u do
          send(p, msg) end end)
    end

    defp find(sender, [{u, p} | _]) when p == sender, do: u
    defp find(sender, [_ | t]), do: find(sender,t)
end
