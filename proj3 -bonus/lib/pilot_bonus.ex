
defmodule Peers do

  def main(args) do
    # args = ["10","10"]
    # IO.inspect args
    numNodes = Enum.at(args,0) |> String.to_integer()
    failNodes = Enum.at(args,1) |> String.to_integer()
    numRequests = Enum.at(args,2) |> String.to_integer()
    numNodesList = Enum.to_list(0..numNodes-1)

    hashNodes = Enum.map(numNodesList,fn(x)->
      String.pad_leading(Integer.to_string(x,16),4,"0")
    end)
    IO.puts("Creating routing tables.........................")
    createMappings(hashNodes,numNodes,numNodesList)
    createActors(numNodes)
    IO.puts("actors created with their routing tables!")
    IO.puts("Dynamic addition of additional nodes started............")
    newNode = numNodes
    addDynamicNode(newNode,hashNodes)
    IO.puts("Dynamic addition of additional nodes is done!")
    hashNodes = hashNodes ++ [String.pad_leading(Integer.to_string(newNode,16),4,"0")]
    failNodesList = Enum.take_random(hashNodes,failNodes)
    Enum.each(failNodesList,fn(fail)->
      pid = Process.whereis(String.to_atom(fail))
      IO.puts("Process with #{inspect pid} killed")
    end)
    IO.puts("Processes killing is done.")
    Enum.each(hashNodes -- failNodesList,fn(initNode)->
      requests = Enum.take_random(hashNodes--[initNode],numRequests)
      map = %{}
      map = Map.new(requests,fn(x)->
        {x,0}
      end)
      ActorNode.updateRequests(String.to_atom(initNode),map)
      Enum.each(requests,fn(x)->
        ActorNode.searchNode(String.to_atom(initNode),initNode,x,self(),failNodesList)
        # Process.sleep(5)
      end)
    end)
    numNodes = numNodes+1 - length(failNodesList)
    len = length(Enum.take_random(0..numNodes-2,numRequests))
    # IO.inspect len
    convergeCheck(0,numNodes*len,[])
  end

  def addDynamicNode(newNode,hashNodes) do
    newhashNodes = hashNodes
    hashNodes = hashNodes ++ [newNode]
    nodeNameStr = String.pad_leading(Integer.to_string(newNode,16),4,"0")
    layer = Enum.map(0..15,fn(x)->
      []
    end)
    layers = Enum.map(0..3,fn(x)->
      layer
    end)
    :ets.insert(:table,{nodeNameStr,layers})
    # IO.puts("table inserted")
    createRoutingTables(nodeNameStr,newhashNodes,hashNodes)
    #-------------------------------newNode's table updation in its state-------------------------------------------
    temp = Enum.at(:ets.lookup(:table, nodeNameStr),0)
    routingTable = elem(temp,1)
    nodeName = String.to_atom(nodeNameStr)
    ActorNode.start_link(nodeName,nodeNameStr,routingTable)
    #--------------------------------------------------------------------------------------------------------------
    nearestNode = newNode-1
    nearestNodeStr = String.pad_leading(Integer.to_string(nearestNode,16),4,"0")
    levelMatchList = while(nodeNameStr,nearestNodeStr,1,[])
    levelMatchList = if length(levelMatchList)==0 do
      [[0,String.at(nearestNodeStr,0)]]
    else levelMatchList
    end
    level = Enum.at(Enum.at(levelMatchList,length(levelMatchList)-1),0)
    matchedNodes = getMatchedNodes(nodeNameStr,nearestNodeStr,level,[nearestNodeStr],0)
    # IO.inspect matchedNodes
    # IO.inspect nodeNameStr
    Enum.each(matchedNodes,fn(node)->
      createRoutingTables(node,[nodeNameStr],hashNodes)
      temp = Enum.at(:ets.lookup(:table, node),0)
      routingTable = elem(temp,1)
      ActorNode.updateRoutingTable(String.to_atom(node),routingTable)
    end)

  end

  def getMatchedNodes(nodeNameStr,nearestNodeStr,level,resultNodes,index) do
    resultNodes = if length(resultNodes)!=index do
      list = Enum.slice(resultNodes, index-1, length(resultNodes)-index)
      temp = Enum.map(list,fn(x)->
        temp3 = Enum.at(:ets.lookup(:table, x),0)
        routingTable = elem(temp3,1)
        temp2 = Enum.map(level..3,fn(l)->
          nodes = Enum.at(routingTable,l)
        end)


      end)
      temp = Enum.uniq(List.flatten(temp)) -- [nil]
      resultNodes = resultNodes ++ temp
      resultNodes = Enum.uniq(resultNodes)
      # IO.inspect resultNodes
      # IO.puts("#{length(resultNodes)} #{index}")
      getMatchedNodes(nodeNameStr,nearestNodeStr,level+1,resultNodes,index+1)
    else
      resultNodes
    end
    resultNodes
  end

  def createActors(numNodes) do
    Enum.each(0..numNodes-1,fn(x)->
      nodeNameStr = String.pad_leading(Integer.to_string(x,16),4,"0")
      temp = Enum.at(:ets.lookup(:table, nodeNameStr),0)
      routingTable = elem(temp,1)
      nodeName = String.to_atom(nodeNameStr)
      ActorNode.start_link(nodeName,nodeNameStr,routingTable)
    end)
  end

  def createMappings(hashNodes,numNodes,numNodesList) do

    # IO.inspect hashNodes
    # ---------------------------table creation-------------------------------------------
    table = :ets.new(:table, [:named_table, :public])
    layer = Enum.map(0..15,fn(x)->
      []
    end)
    layers = Enum.map(0..3,fn(x)->
      layer
    end)
    Enum.each(hashNodes,fn(x)->
      :ets.insert(:table,{x,layers})
    end)
    #------------------------------------------------------------------------------------
    mappings = Enum.map(hashNodes,fn(x)->
      newhashNodes = hashNodes -- [x]
      createRoutingTables(x,newhashNodes,hashNodes)
    end)


    # IO.inspect Enum.at(:ets.lookup(:table, "03E0"),0)
  end

  def createRoutingTables(x,newhashNodes,hashNodes) do

    neighbors = Enum.map(newhashNodes,fn(y)->
      neigh = while(x,y,1,[])
      neigh = if length(neigh)==0 do
        [[0,String.at(y,0)]]
      else neigh
      end

      val = y
      # IO.inspect neigh
      Enum.each(neigh,fn(n)->
        # IO.inspect n
        level = Enum.at(n,0)
        col = elem(Integer.parse(Enum.at(n,1),16),0)
        temp = Enum.at(:ets.lookup(:table, x),0)
        tableLists = elem(temp,1)
        valList = Enum.at(Enum.at(tableLists,level),col)
        if length(valList)<=4 do
          valList = valList ++ [val]
          innerList = List.replace_at(Enum.at(tableLists,level),col,valList)
          tableLists = List.replace_at(tableLists,level,innerList)
          :ets.insert(:table,{x,tableLists})
        end
        # if Enum.at(Enum.at(tableLists,level),col)==nil do
        #   innerList = List.replace_at(Enum.at(tableLists,level),col,val)
        #   tableLists = List.replace_at(tableLists,level,innerList)
        #   :ets.insert(:table,{x,tableLists})
        # else
        #   prev1 = Enum.at(Enum.at(tableLists,level),col)
        #   prev = elem(Integer.parse(prev1,16),0)
        #   curr = elem(Integer.parse(val,16),0)
        #   actVal = elem(Integer.parse(x,16),0)
        #   if abs(actVal-curr)<abs(actVal-prev) do
        #     # newNeigh = while(x,prev1,1,[])
        #     # Enum.each(newNeigh,fn(nn)->
        #     #   temp = Enum.at(:ets.lookup(:table, x),0)
        #     #   tableLists = elem(temp,1)
        #     #   newlevel = Enum.at(nn,0)
        #     #   newcol = elem(Integer.parse(Enum.at(nn,1),16),0)
        #     #   innerList = List.replace_at(Enum.at(tableLists,newlevel),newcol,nil)
        #     #   tableLists = List.replace_at(tableLists,level,innerList)
        #     #   :ets.insert(:table,{x,tableLists})
        #     # end)
        #     temp = Enum.at(:ets.lookup(:table, x),0)
        #     tableLists = elem(temp,1)
        #     innerList = List.replace_at(Enum.at(tableLists,level),col,val)
        #     tableLists = List.replace_at(tableLists,level,innerList)
        #     :ets.insert(:table,{x,tableLists})
        #   end
        # end
      end)


    end)
  end

  def while(x,y, i, result) when i<4 do
    result = if String.at(x,i-1)==String.at(y,i-1) do
      result = result ++ [[i,String.at(y,i)]]
      # IO.inspect result
      while(x,y,i+1,result)
    else
      result
    end
    result
  end

  def while(x,y, i, result) do
    result
  end


  def convergeCheck(n,numNodes,hopValues) when n===numNodes do
    hopValues = Enum.map(hopValues,fn(x)->
      ActorNode.getHopCount(String.to_atom(Enum.at(x,0)),Enum.at(x,1))
    end)
    # IO.inspect hopValues
    maxHop = Enum.max(hopValues)
    IO.puts("Maximum hop value is #{maxHop}")
    nil # n represents number of nodes knowing the rumor
  end


  def convergeCheck(n,numNodes,hopValues) when n>=0 do
    receive do
      {:taskDone,initNode,destNode} ->
        # pid = Process.whereis(String.to_atom(initNode))
        # IO.inspect pid
        # IO.inspect Process.alive?(pid)
        hopValues = hopValues ++ [[initNode,destNode]]
        IO.puts("#{length(hopValues)} requests served")
        convergeCheck(n+1,numNodes,hopValues)

    end
  end
end

# Peers.mains()

