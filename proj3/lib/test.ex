map = %{"hi"=>1,"hello"=>2}
map = Map.get_and_update(map, "hi", fn current_value ->
  IO.inspect current_value
  {current_value, "new value!"}
end)
IO.inspect map
