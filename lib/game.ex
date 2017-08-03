defmodule Game do

  def start() do
    GenServer.start_link(__MODULE__, [], id: __MODULE__)
  end

  def stop(), do: call(:stop)
  def score(), do: call(:score)
  def moves(), do: call(:moves)
  def board(), do: call(:board)
  def place(obj_name, x, y), do: call(:place, obj_name, x, y}
  def undo(), do: call(:undo)
  
  def init(_) do
    Process.register(self(), __MODULE__)
    {:ok, %{:b => Board.create(),
	    :moves => [],
	    :score => 0}}
  end

  def handle_call(:score, _, s), do: {:reply, s.score, s}
  def handle_call(:moves, _, s), do: {:reply, s.moves, s}
  def handle_call(:board, _, s), do: {:reply, s.board, s}
  def handle_call(action = {:place, obj_name, x, y}, s) do
    moves = [{action, s} | s.moves]
    {score, b} = place_and_prune(s.board, obj_name, x, y)
    {:reply, :ok, %{s | moves: moves, score: s.score + score, board: b}}
  end

  def place_and_prune(b, obj_name, x, y) do
    obj = Objects.map_name(obj_name)
    

  def handle_call(:stop, _, s) do
    {:stop, :ok, :normal, s}
  end

  def terminate(a, b) do
    IO.puts "terminating #{inspect a}, #{inspect b}"
    :ok
  end

  def call(req), do: GenServer.call(__MODULE__, req)
  
end
