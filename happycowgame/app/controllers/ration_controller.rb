class RationController < ApplicationController
  def index
    render json: [
      {id:1, postion: 16, game_user_id: 1},
      {id:2, postion: 5, game_user_id: 1},
      {id:3, postion: 2, game_user_id: 1}
    ]
  end

  def show
    render json: {id:1,
      postion: {id: 1, order:1, centre_x: 200, centre_y: 200, area_id: 1},
      ingredients: {
        {type: 'water'},
        {type: 'water'},
        {type: 'energy'},
        {type: 'protien'},
      }
    }
  end
end
