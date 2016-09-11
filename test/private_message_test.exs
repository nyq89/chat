defmodule Chat.PrivateMessageTest do
  use ExUnit.Case

  alias Chat.ChatServer
  alias Chat.ChatClient

  #This is just for visual testeing.
  #It will not show if the messages is correct or not.
  test "send private message" do
    server = ChatServer.start
    gashi = ChatClient.connect("gashi", server)
    hashi = ChatClient.connect("hashi", server)
    jabbe = ChatClient.connect("jabbe", server)
    :timer.sleep(500)

    send(hashi, {:priv, "gashi", "legget"})
    send(jabbe, {:send, "All them gashihashis", "main"})
  end
end