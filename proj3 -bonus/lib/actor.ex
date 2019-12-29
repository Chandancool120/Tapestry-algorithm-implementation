defmodule ActorNode do
  use GenServer


  def start_link(nodename,nodenamestr,routingTable) do
    GenServer.start_link(__MODULE__,[routingTable,nodenamestr,%{}], name: nodename)
  end

  def init(state) do
    {:ok,state}
  end

  def updateRoutingTable(node,routingTable) do
    GenServer.cast(node,{:updateRoutingTable,routingTable})
  end

  def updateHopCount(node,destNode) do
    GenServer.cast(node,{:updateHopCount,destNode})
  end

  def getHopCount(node,destNode) do
    GenServer.call(node,{:getHopCount,destNode},10000)
  end

  def updateRequests(node, map) do
    GenServer.cast(node,{:updateRequests,map})
  end

  def handle_cast({:updateRequests,map},state) do
    {:noreply,List.replace_at(state,2,map)}
  end

  def handle_call({:getHopCount,destNode},_from,state) do
    # IO.inspect "HIksdbjb"
    map = Enum.at(state,2)
    # IO.inspect map
    val = Map.get(map,destNode)
    # IO.inspect val
    {:reply,val,state}
  end

  def handle_cast({:updateHopCount,destNode},state) do
    map = Enum.at(state,2)
    map = Map.get_and_update(map, destNode, fn current_value ->
      # IO.inspect "HI #{current_value}"
      {current_value, current_value+1}
    end)
    map = elem(map,1)
    state = List.replace_at(state,2,map)
    {:noreply,state}
  end

  def handle_cast({:updateRoutingTable,routingTable},state) do
    actorName = Enum.at(state,1)
    state = [routingTable, actorName,0]
    {:noreply,state}
  end

  def searchNode(node,initNode,destNode,parentPid,failNodes) do
    GenServer.cast(node,{:searchNode,initNode,destNode,parentPid,failNodes})
  end

  def handle_cast({:searchNode,initNode,destNode,parentPid,failNodes},state) do
    match = findMatch(Enum.at(state,1),destNode)
    routingTable = Enum.at(state,0)
    match = if length(match)!=0 do
      match
    else
      [0,String.at(destNode,0)]
    end
    if length(match)!=0 do
      level = Enum.at(match,0)
      col = elem(Integer.parse(Enum.at(match,1),16),0)
      nextNodeList = Enum.at(Enum.at(routingTable,level),col)
      updateHopCount(String.to_atom(initNode),destNode)
      if Enum.member?(nextNodeList, destNode) do
        send parentPid, {:taskDone,initNode,destNode}
        Process.sleep(1000)
      else
        eligibleNodes = Enum.map(nextNodeList,fn(next)->
          if Enum.member?(failNodes,next) do
            nil
          else
            next
          end
        end)
        eligibleNodes = Enum.uniq(eligibleNodes) -- [nil]
        if length(eligibleNodes)==0 do
          send parentPid, {:taskDone,initNode,destNode}
          Process.sleep(200)
        else
          nextNode = Enum.random(eligibleNodes)
          searchNode(String.to_atom(nextNode),initNode,destNode,parentPid,failNodes)
        end

      end
    end
    {:noreply,state}
  end

  def findMatch(startNode, destNode) do
    list = Peers.while(startNode, destNode, 1, [])
    result = if length(list)!=0 do
      Enum.at(list,length(list)-1)
    else
      []
    end
    result
  end

end
