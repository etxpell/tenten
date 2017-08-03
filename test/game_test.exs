defmodule GameTest do
  use ExUnit.Case

  test "start a fresh game" do
    Game.start()
    assert 0 ==Game.score()
    assert [] == Game.moves()
  end

end
