defmodule PollexWeb.PollNotFoundException do
  defexception [:message, plug_status: 404]
end
