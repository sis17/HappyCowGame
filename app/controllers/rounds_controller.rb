class RoundsController < ApplicationController
  def index
    render json: [
      {id:1, number: 1, active: false},
      {id:2, number: 2, active: false},
      {id:3, number: 3, active: false},
      {id:4, number: 4, active: true}
    ]
  end

  def show
    render json: {number: 4, active: true, game_id: 1, current_phase: 1, game_user_id: 1,
      event: {title: 'Constipation', type: 'Pathology', image: 'events/disease/constipation-1.png',
              description: '<p>You can only play the lowest dice for rations in the intestine.</p>
              <p>This card stays on the board until it is replaced by another pathology or removed by a special card.</p>
              <p><span class="label label-danger">-1 to Welfare</span></p>'}
      }
  end
end
