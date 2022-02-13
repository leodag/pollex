defmodule Pollex.Poll do
  use GenServer

  defp name(poll) do
    {:via, Registry, {Pollex.PollRegistry, poll}}
  end

  def start_link(opts \\ []) do
    poll = Keyword.get(opts, :name)
    GenServer.start_link(__MODULE__, opts, [name: name(poll)])
  end

  def create(name, opts) do
    start_link([{:name, name} | opts])
  end

  def vote(poll, index, identifier) do
    call(poll, {:vote, index, identifier})
  end

  def get(poll) do
    call(poll, :get)
  end

  def get_votes(poll) do
    call(poll, :get_votes)
  end

  defp call(poll, msg) do
    try do
      GenServer.call(name(poll), msg)
    catch
      :exit, {:noproc, _} ->
        {:error, :poll_not_found}
    end
  end

  def init(opts) do
    title = Keyword.get(opts, :title)
    text = Keyword.get(opts, :text)
    alternatives = Keyword.get(opts, :alternatives)
    votes = for _ <- 1..length(alternatives), do: 0
    votes = List.to_tuple(votes)
    identifiers = MapSet.new()

    {
      :ok,
      %{
        title: title,
        text: text,
        alternatives: alternatives,
        votes: votes,
        identifiers: identifiers
      }
    }
  end

  def handle_call(:get, _from, state) do
    {:reply, {:ok, %{state | votes: Tuple.to_list(state.votes)}}, state}
  end

  def handle_call(:get_votes, _from, state) do
    {:reply, {:ok, Tuple.to_list(state.votes)}, state}
  end

  def handle_call({:vote, alternative_idx, identifier}, _from, %{ votes: votes, identifiers: identifiers } = state) do
    if not Enum.member?(identifiers, identifier) do
      votes = put_elem(votes, alternative_idx, elem(votes, alternative_idx) + 1)
      identifiers = MapSet.put(identifiers, identifier)
      {:reply, {:ok, Tuple.to_list(votes)}, %{state | votes: votes, identifiers: identifiers}}
    else
      {:reply, {:error, {:already_voted, Tuple.to_list(votes)}}, state}
    end
  end
end
