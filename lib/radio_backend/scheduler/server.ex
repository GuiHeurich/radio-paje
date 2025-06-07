# lib/radio_backend/scheduler/server.ex

defmodule RadioBackend.Scheduler.Server do
  use GenServer

  alias RadioBackend.Repo
  alias RadioBackend.Scheduler.Track
  alias RadioBackendWeb.Endpoint

  defstruct [
    :current_track,
    :playlist,
    :starts_at
  ]

  # =================================================================
  # Public API (No changes here)
  # =================================================================

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def now_playing do
    GenServer.call(__MODULE__, :now_playing)
  end

  # =================================================================
  # GenServer Callbacks (The internal logic)
  # =================================================================

  @impl true
  def init(:ok) do
    # 2. Replace the hard-coded list with a database query.
    # We'll also randomize the playlist order each time the server starts!
    playlist = Repo.all(Track) |> Enum.shuffle()

    IO.puts("Loaded #{length(playlist)} tracks from the database.")

    initial_state = %__MODULE__{playlist: playlist}
    new_state = play_next_track(initial_state)

    {:ok, new_state}
  end

  @impl true
  def handle_call(:now_playing, _from, state) do
    reply = %{
      current_track: state.current_track,
      starts_at: state.starts_at
    }
    {:reply, reply, state}
  end

  @impl true
  def handle_info(:next_song, state) do
    IO.puts("Track finished, playing next song...")
    new_state = play_next_track(state)
    {:noreply, new_state}
  end

  # =================================================================
  # Private Helper Functions
  # =================================================================

defp play_next_track(state) do
  case state.playlist do
    [] ->
      IO.puts("Playlist finished. Reloading and shuffling...")
      reloaded_playlist = Repo.all(Track) |> Enum.shuffle()
      play_next_track(%__MODULE__{state | playlist: reloaded_playlist})

    [next_track | remaining_playlist] ->
      IO.puts("Now playing: #{next_track.title} by #{next_track.artist}")

      Process.send_after(self(), :next_song, next_track.duration)

      # Prepare the data to be sent to the frontend
      now_playing_data = %{
        current_track: next_track,
        starts_at: System.os_time(:millisecond)
      }

      # --- ADD THIS LINE ---
      # Broadcast the "new_song" event to all listeners on the channel.
      Endpoint.broadcast("now_playing:lobby", "new_song", now_playing_data)
      # ---------------------

      # Update the state using the data we just prepared
      %__MODULE__{
        current_track: now_playing_data.current_track,
        playlist: remaining_playlist,
        starts_at: now_playing_data.starts_at
      }
  end
end
end

