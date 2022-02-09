defmodule PollexWeb.PollController do
  use PollexWeb, :controller

  def poll_page(conn, params) do
    poll_name = params["poll"]

    render(conn, "index.html", poll_name: poll_name, poll: Pollex.Poll.get(poll_name))
  end

  def vote(conn, params) do
    poll_name = params["poll"]
    alternative = String.to_integer(params["alternative"])

    Pollex.Poll.vote(poll_name, alternative)

    poll = Pollex.Poll.get_votes(poll_name)

    json(conn, %{votes: poll.votes})
  end

  def create(conn, params) do
    title = params["title"]
    named = params["named"]
    text = params["text"]
    alternatives = params["alternatives"]

    name = if named == "true", do: title, else: random_name()

    IO.inspect conn

    Pollex.Poll.create(name, [title: title, text: text, alternatives: alternatives])

    json(conn, %{name: name})
  end

  def random_name() do
    characters = '0123456789abcdef'

    for _ <- 1..10, into: "", do: <<Enum.random(characters)>>
  end
end
