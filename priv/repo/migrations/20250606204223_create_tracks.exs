defmodule RadioBackend.Repo.Migrations.CreateTracks do
  use Ecto.Migration

  def change do
    create table(:tracks) do
      add :title, :string
      add :artist, :string
      add :duration, :integer
      add :url, :string

      timestamps(type: :utc_datetime)
    end
  end
end
