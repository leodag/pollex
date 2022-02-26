defmodule PollexWeb.PollController do
  use PollexWeb, :controller

  def poll_page(conn, params) do
    poll_name = params["poll"]

    case Pollex.Poll.get(poll_name) do
      {:ok, poll} ->
        render(conn, "index.html", poll_name: poll_name, poll: poll)
      {:error, :poll_not_found} ->
        raise PollexWeb.PollNotFoundException, message: "Poll not found"
    end
  end

  def vote(conn, params) do
    poll_name = params["poll"]
    alternative = String.to_integer(params["alternative"])

    case Pollex.Poll.vote(poll_name, alternative, conn.remote_ip) do
      {:ok, votes} ->
        json(conn, %{result: :ok, votes: votes})
      {:error, {reason, votes}} ->
        json(conn, %{result: reason, votes: votes})
    end
  end

  def create(conn, params) do
    title = params["title"]
    named = params["named"]
    text = params["text"]
    alternatives = params["alternatives"]

    name = if named == "true", do: title, else: random_name()

    case Pollex.Poll.create(name, [title: title, text: text, alternatives: alternatives]) do
      {:ok, _} ->
        json(conn, %{name: name, result: "created"})
      {:error, {:already_started, _}} ->
        json(conn, %{name: name, result: "already_exists"})
    end
  end

  def random_name() do
    characters = 'abcdefghijkl'

    for _ <- 1..10, into: "", do: <<Enum.random(characters)>>
  end
end
