class RationsController < ApplicationController
  def index
    render json: [
      {id:1, position: {id: 16, order:16, centre_x: 300, centre_y: 400, area_id: 1},
        game_user_id: 1, ingredients: [{type:'water'}, {type:'energy'}]},
      {id:2, position: {id: 5, order:5, centre_x: 100, centre_y: 100, area_id: 1},
        game_user_id: 1, ingredients: [{type:'water'}, {type:'fiber'}]},
      {id:3, position: {id: 23, order:23, centre_x: 350, centre_y: 400, area_id: 1},
        game_user_id: 1, ingredients: [{type:'protein'}, {type:'oligos'}]}
    ]
  end

  def show
    render json: {id:1,
      postion: {id: 1, order:1, centre_x: 200, centre_y: 200, area_id: 1},
      ingredients: [
        {type: 'water'},
        {type: 'water'},
        {type: 'energy'},
        {type: 'protien'},
      ]
    }
  end
end
