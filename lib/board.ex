defmodule Board do

  def create() do
    ps = all_points()
    Enum.reduce(ps, %{}, fn(k, m) -> set_empty(m, k) end)
  end

  def place_and_prune(b, obj, p) do
    abs_obj = absolute(obj, p)
    b |>
      place(abs_obj) |>
      prune(abs_obj)
  end

  # idea: placing an object could result in an outcome. This outcome
  # can be used to prune and to calculate score
  def prune(b, obj) do
    {cols, rows} = should_be_pruned(b, obj)
    score = calc_score(obj, cols, rows)
    {score, do_prune(b, cols, rows)}
  end

  def should_be_pruned(b, abs_obj) do
    {cols, rows} = Enum.unzip(abs_obj)
    {cols_to_be_pruned(b, cols), rows_to_be_pruned(b, rows)}
  end

  def cols_to_be_pruned(b, cols) do
    cols |>
      Enum.uniq |>
      Enum.filter(fn(c) -> is_col_full(b, c) end)
  end

  def rows_to_be_pruned(b, rows) do
    rows |>
      Enum.uniq |>
      Enum.filter(fn(c) -> is_row_full(b, c) end)
  end

  def is_col_full(b, c), do: all_full(b, gen_col(c))
  def is_row_full(b, r), do: all_full(b, gen_row(r))
  
  def gen_col(c), do: Enum.zip(List.duplicate(c, 10), cols())
  def gen_row(r), do: Enum.zip(rows(), List.duplicate(r, 10))

  def do_prune(b, cols, rows) do
    ps = Enum.flat_map(cols, &gen_col/1) ++
      Enum.flat_map(rows, &gen_row/1)
    Enum.reduce(ps, b, fn(p, b) -> set_empty(b, p) end)
  end
  
  def calc_score(obj, cols, rows) do
    # one score point per 'pixel' (or point on board), 10 for each row
    # and column removed, and then remove the overlapping between cols
    # and rows
    #IO.puts "o: #{inspect obj}, c: #{inspect cols}, r: #{inspect rows}"
    (length(obj) +
      10 * length(cols) +
      10 * length(rows) -
      length(cols) * length(rows))
  end
  
  def place_at(b, obj, x, y), do: place_at(b, obj, mk_point(x, y))
  def place_at(b, obj, p) do
    place(b, absolute(obj, p))
  end

  def place(b, obj) when is_list(obj) do
    Enum.reduce(obj, b, fn(p, b) -> place(b, p) end)
  end
  def place(b, p) do
    Map.delete(b, p)
  end
  
  def can_place(b, obj), do: all_empty(b, obj)

  # Transform the relative coords of an object into absolute coords on
  # board
  def absolute(ps, {x, y}), do: Enum.map(ps, fn({x1, y1}) -> {x1 + x, y1 + y} end)
  
  
  #---------
  # Board filling primitives
  
  def set_empty(b, p), do: Map.put(b, p, true)
  def set_full(b, p), do: Map.delete(b, p)
  
  def is_empty?(b, x, y), do: is_empty?(b, mk_point(x, y))
  def is_empty?(b, p), do: Map.has_key?(b, p)

  def all_empty(b, ps), do: Enum.all?(ps, fn(p) -> is_empty?(b, p) end)
  def all_full(b, ps), do: not Enum.any?(ps, fn(p) -> is_empty?(b, p) end)
  
  def can_place_at(b, obj, p), do: can_place(b, absolute(obj, p))
  def can_place_at(b, obj, x, y), do: can_place_at(b, obj, mk_point(x, y))
  
  def all_points() do
    for x <- cols(),
      y <- rows(),
      do: mk_point(x, y)
  end

  def is_empty_board(b), do: 100 == (b |> Map.keys |> length)

  defp rows(), do: 0..9
  defp cols(), do: 0..9
  def mk_point(x, y), do: {x, y}

  #---------
  # Board value is an evaluation of the worth of a board, so that
  # different placements can be ordered
  def value(b) do
    ps = Map.keys(b)
    count_points_where_obj_is_placeable(b, ps, Objects.square()) +
    count_points_where_obj_is_placeable(b, ps, Objects.vert_five()) +
    count_points_where_obj_is_placeable(b, ps, Objects.horiz_five())
  end
  
  def count_points_where_obj_is_placeable(b, points, obj) do
    length(Enum.filter(points, fn(p) -> can_place_at(b, obj, p) end))
  end
  
  # -----------------
  # print stuff

  def print(b) do
    Enum.map(rows(), fn(r) -> print_row(b, r) end)
  end

  def print_row(b, y) do
    IO.puts row_to_string(b, y)
  end
  
  def row_to_string(b, y) do
    Enum.map(cols(), fn(x) -> point_char(b, mk_point(x, y)) end)
  end

  defp point_char(b, p) do
    if is_empty?(b, p) do
      ?.
    else
      ?X
    end
  end

end
