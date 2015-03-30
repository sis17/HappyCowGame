class Motile < ActiveRecord::Base
  belongs_to :game
  belongs_to :position

  def move
    messages = []
    moves = 3
    while moves > 0 do
      ids = []
      self.position.positions.each do |position|
        ids.push(position.id) if position.area_id == 3 && position.order != 61
      end

      if ids.length > 0
        self.position = Position.find(ids[rand(ids.length-1)])
        self.save

        #remove an ingredient from colliding rations
        rations = Ration.joins(:game_user).where(position_id: self.position_id, game_users: {game_id: self.game.id})
        rations.each do |ration|
          ingredient = Ingredient.where(ration_id: ration.id).first
          name = ingredient.ingredient_cat.name
          messages.push({
            title:'Motile Collision',
            text:'A ration belonging to '+ration.game_user.user.name+' was hit by a motile peice and lost a <span class="label '+name+'">'+name+'</span>',
            type:'warning', time: 6
          })
          ingredient.destroy
        end
      else
        # how did this happen?
      end

      moves -= 1
    end
    return messages
  end

  def as_json(options={})
    super(
      :include => [
        :game,
        :position
      ]
    )
  end
end
