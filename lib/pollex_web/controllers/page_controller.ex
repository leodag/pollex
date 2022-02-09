defmodule PollexWeb.PageController do
  use PollexWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
