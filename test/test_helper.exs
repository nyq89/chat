Application.start(:logger)
Logger.configure(level: :error)
ExUnit.start(assert_receive_timeout: 300, refute_receive_timeout: 300)