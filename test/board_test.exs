defmodule BoardTest do
  use ExUnit.Case

  test "can create empty board" do
    res = Board.create
    assert true == is_map(res)
  end

  test "can check for empty point" do
    b = Board.create
    assert true == Board.is_empty?(b, 0, 0)
  end

  test "can place a single point" do
    b = Board.create |>
      Board.place([{0, 0}])
    
    assert false == Board.is_empty?(b, 0, 0)
    assert true == Board.is_empty?(b, 0, 1)
  end

  test "can place two points" do
    b = Board.create |>
      Board.place([{0, 0}, {0, 1}])
    
    assert false == Board.is_empty?(b, 0, 0)
    assert false == Board.is_empty?(b, 0, 1)
    assert true == Board.is_empty?(b, 0, 2)
  end

  test "can check a single point for placement" do
    b = Board.create |>
      Board.place([{0, 0}])
    assert false == Board.can_place(b, [{0, 0}])
    assert true == Board.can_place(b, [{0, 1}])
  end

  test "can check a two points for placement" do
    b = Board.create |>
      Board.place([{0, 0}])
    assert false == Board.can_place(b, [{0, 0}, {0,1}])
    assert true == Board.can_place(b, [{0, 1}, {0, 2}])
  end

  test "can check relative point for placement" do
    b = Board.create |>
      Board.place([{0, 0}])
    assert false == Board.can_place_at(b, [{0, 0}], 0, 0)
    assert true == Board.can_place_at(b, [{0, 0}], 0, 1)
  end

  test "can place object at specific coord" do
    obj = Objects.square()
    b = Board.create |>
      Board.place_at(obj, {0, 0})
    
    assert false == Board.is_empty?(b, 0, 0)
    assert false == Board.is_empty?(b, 0, 1)
    assert true == Board.is_empty?(b, 0, 3)
  end

  test "value of empty board" do
    res = Board.create |>
      Board.value
    assert 184 == res
  end
  
  test "value of board with one point taken" do
    res = Board.create |>
      Board.place([{0, 0}]) |>
      Board.value
    assert 181 == res
  end

  test "value of board with one object placed" do
    obj = Objects.square()
    res = Board.create |>
      Board.place_at(obj, {0, 0}) |>
      Board.value
    assert 157 == res
  end

  test "value of board with one object placed in the middle" do
    obj = Objects.square()
    res = Board.create |>
      Board.place_at(obj, {4, 4}) |>
      Board.value
    assert 123 == res
  end

  #-----------
  # place & prune

  test "single object prunes nothing, but scores" do
    obj = Objects.vert_five()
    {score, b} = Board.create |>
      Board.place_and_prune(obj, {0, 0})
    assert 5 == score
    assert false == Board.is_empty_board(b)
  end
  
  test "vert_five prunes col" do
    obj = Objects.vert_five()
    {score, b} = Board.create |>
      Board.place_at(obj, {0, 5}) |>
      Board.place_and_prune(obj, {0, 0})
    assert 15 == score
    assert true == Board.is_empty_board(b)
  end

  test "single horizontal five prunes nothing, but scores" do
    obj = Objects.horiz_five()
    {score, b} = Board.create |>
      Board.place_and_prune(obj, {0, 0})
    assert 5 == score
    assert false == Board.is_empty_board(b)
  end
  
  test "horiz_five prunes row" do
    obj = Objects.horiz_five()
    {score, b} = Board.create |>
      Board.place_at(obj, {5, 0}) |>
      Board.place_and_prune(obj, {0, 0})
    assert 15 == score
    assert true == Board.is_empty_board(b)
  end

  test "horiz_five prunes row and three cols" do
    obj = Objects.horiz_five()
    filler = Objects.square()
    {score, b} = Board.create |>
      Board.place_at(filler, {0, 1}) |>
      Board.place_at(filler, {0, 4}) |>
      Board.place_at(filler, {0, 7}) |>
      Board.place_and_prune(obj, {0, 0})
    IO.puts ""
    Board.print(b)
    assert 35 == score
    assert false == Board.is_empty_board(b)
  end

  
  #-----------
  #-----------
  test "can print empty board" do
    import ExUnit.CaptureIO

    res = capture_io(fn() -> Board.create |> Board.print end)
    expected = """
    ..........
    ..........
    ..........
    ..........
    ..........
    ..........
    ..........
    ..........
    ..........
    ..........
    """
    assert expected == res
  end

  test "can print with object on board" do
    import ExUnit.CaptureIO

    obj = Objects.square()
    res = capture_io(fn() -> Board.create |> Board.place_at(obj, 1, 1) |> Board.print end)
    expected = """
    ..........
    .XXX......
    .XXX......
    .XXX......
    ..........
    ..........
    ..........
    ..........
    ..........
    ..........
    """
    assert expected == res
  end

end
