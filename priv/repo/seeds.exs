alias RadioBackend.Repo
alias RadioBackend.Scheduler.Track

Repo.delete_all(Track)
IO.puts("Cleared old tracks.")

tracks_data = [
  %{
    title: "Brazil",
    artist: "Declan McKenna",
    duration: 252000, # in milliseconds
    url: "/music/um.opus"
  },
  %{
    title: "Mas Que Nada",
    artist: "Sérgio Mendes",
    duration: 157000,
    url: "/music/dois.opus"
  },
  %{
    title: "Aquarela do Brasil",
    artist: "Gal Costa",
    duration: 199000,
    url: "/music/tres.opus"
  },
  %{
    title: "The Girl From Ipanema",
    artist: "Stan Getz & João Gilberto",
    duration: 315000,
    url: "/music/quatro.opus"
  }
]

Enum.each(tracks_data, fn track_attrs ->
  %Track{}
  |> Track.changeset(track_attrs)
  |> Repo.insert!()
end)

IO.puts "Database seeded with #{length(tracks_data)} tracks!"
