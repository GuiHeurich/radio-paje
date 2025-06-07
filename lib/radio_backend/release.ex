defmodule RadioBackend.Release do
  @app :radio_backend

  @doc """
  This function is called from our deployment script to run database migrations.
  """
  def migrate do
    # First, ensure the application is loaded
    load_app()

    # Get the list of Ecto repos from our application's configuration
    for repo <- repos() do
      # Ecto.Migrator.with_repo ensures the repo is started before migrating
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  defp repos do
    # This reads the :ecto_repos configuration we set in config/runtime.exs
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
