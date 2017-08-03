defmodule Objects do
  # -----------------
  # predefined objects
  def square() do
    for x <- 0..2,
      y <- 0..2,
      do: Board.mk_point(x, y)
  end

  def vert_five() do
    for y <- 0..4,
      do: Board.mk_point(0, y)
  end

  def horiz_five() do
    for x <- 0..4,
      do: Board.mk_point(x, 0)
  end

end
