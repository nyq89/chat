defmodule Chat.PrivateMessageTest do
  use ExUnit.Case

  alias Chat.ChatServer
  alias Chat.ChatClient

  test "send private message" do
    server = ChatServer.start
    gashi = ChatClient.connect("gashi", server)
    hashi = ChatClient.connect("hashi", server)
    :timer.sleep(500)

    send(hashi, {:priv, "gashi", "legget"})
    :timer.sleep(500)
  end
end