class Position < ActiveRecord::Base
  has_many :rations
  has_many :motiles

  has_and_belongs_to_many(:positions,
    :join_table => "next_positions",
    :foreign_key => "position_from_id",
    :association_foreign_key => "position_to_id")

  def is_free(game, existing_ration)
    taken_positions = game.get_taken_positions(existing_ration)
    return false if taken_positions[self.id]
    return true
  end

  # build_graph returns a hash of all the available positions within a certain
  # depth of the current position. It does this by taking a depth (level) from
  # the current position at a time, while also assmebling the next level.
  def build_graph(depth, taken_positions)
      # the graph is a hash of all possible positions
      graph = {}
      # add the initial position to the graph
      self.build(graph, taken_positions)
      current_level = self.positions

      # while the depth is not reached, add levels of positions to the graph
      while depth > 0 do
        depth -= 1
        # this holds the next level of positions to be added
        next_level = []
        # loop through the current level of positions
        current_level.each do |position|
          # add the position to the graph, if not already there
          added = position.build(graph, taken_positions)
          # if it has been added, add it's links to the next level
          next_level.concat(position.positions) if added
        end
        current_level = next_level
      end
      # return the finished graph
      return graph
  end

  def build(graph, taken_positions)
      # if the position is not already in the graph, or is not taken by a motile
      # piece or another ration, then add it to the graph
      if !graph[self.id] and !taken_positions[self.id] or graph.size == 0
        graph[self.id] = {}
        graph[self.id]['id'] = self.id;
        graph[self.id]['area_id'] = self.area_id;
        graph[self.id]['order'] = self.order;
        graph[self.id]['centre_x'] = self.centre_x;
        graph[self.id]['centre_y'] = self.centre_y;
        graph[self.id]['links'] = {};
        self.positions.each do |next_position|
          graph[self.id]['links'][next_position.id] = next_position.id
        end
        graph[self.id]['rations'] = {};
        return true
      end
      return false
  end

  def as_json(options={})
    super(
      :include=> [
        :positions
      ]
    )
  end
end
