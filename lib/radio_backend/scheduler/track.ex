defmodule RadioBackend.Scheduler.Track do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :title, :artist, :duration, :url]}

  schema "tracks" do
    field :title, :string
    field :url, :string
    field :artist, :string
    field :duration, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(track, attrs) do
    track
    |> cast(attrs, [:title, :artist, :duration, :url])
    |> validate_required([:title, :artist, :duration, :url])
  end
end
