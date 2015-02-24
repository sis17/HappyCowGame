class RecordsController < ApplicationController
  def index
    render json: [
      {round_id: 4, game_user_id: 1, name: 'score_start', value: 6},
      {round_id: 4, game_user_id: 1, name: 'score_end', value: 8},
      {round_id: 4, game_user_id: 1, name: 'cards', value: 7},
      {round_id: 4, game_user_id: 1, name: 'rations', value: 3},
      {round_id: 4, game_user_id: 2, name: 'score_start', value: 6},
      {round_id: 4, game_user_id: 2, name: 'score_end', value: 8},
      {round_id: 4, game_user_id: 2, name: 'cards', value: 7},
      {round_id: 4, game_user_id: 2, name: 'rations', value: 3},
      {round_id: 4, game_user_id: 3, name: 'score_start', value: 6},
      {round_id: 4, game_user_id: 3, name: 'score_end', value: 8},
      {round_id: 4, game_user_id: 3, name: 'cards', value: 7},
      {round_id: 4, game_user_id: 3, name: 'rations', value: 3},
      {round_id: 4, game_user_id: 4, name: 'score_start', value: 6},
      {round_id: 4, game_user_id: 4, name: 'score_end', value: 8},
      {round_id: 4, game_user_id: 4, name: 'cards', value: 7},
      {round_id: 4, game_user_id: 4, name: 'rations', value: 3},
    ]
  end

  def show

  end
end
