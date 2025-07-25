
defmodule RadioBackendWeb.NowPlayingChannel do
  use RadioBackendWeb, :channel
  alias RadioBackend.Scheduler.Server

  @impl true
  def join("now_playing:lobby", _payload, socket) do
    # Instead of pushing directly, we send a message to ourself.
    # This message will be processed only after the join is complete.
    send(self(), :after_join)
    {:ok, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    # Now that the socket is properly joined, we can safely push to it.
    now_playing_data = Server.now_playing()
    push(socket, "new_song", now_playing_data)

    # All handle_info callbacks must return {:noreply, socket}.
    {:noreply, socket}
  end
end
