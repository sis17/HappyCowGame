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

  def build_graph(depth, taken_positions)
      graph = {}
      # create the position, if not already there
      self.build(graph, taken_positions)
      next_positions = self.positions

      while depth > 0 do
        depth -= 1
        next_next_positions = []

        next_positions.each do |next_position|
          # create the position, if not already there
          added = next_position.build(graph, taken_positions)
          if added
            next_next_positions.concat(next_position.positions)
          end
        end
        next_positions = next_next_positions
      end
      return graph
  end

  def build(graph, taken_positions)
      added = false
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
        added = true

        # if the position is taken by a ration, add the ration to the list
        #if taken_positions[position.id] && taken_positions[position.id][:type] == 'ration'
        #  ration = taken_positions[position.id]
        #  graph[position.id]['rations'][ration[:id]] = ration[:id]
        #end
      end
      return added
  end

  def as_json(options={})
    super(
      :include=> [
        :positions
      ]
    )
  end
end
