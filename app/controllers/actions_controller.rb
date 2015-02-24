class ActionsController < ApplicationController
  def index
    render json: [
      {round_id: 4, phase_id: 2, game_user_id: 1, title: 'New Cards',
        description: '<span class="badge player-1">Player 1</span> got <span class="label label-success">+2</span> cards.'},
      {round_id: 4, phase_id: 2, game_user_id: 1, title: 'Made a Ration',
        description: '<span class="badge player-1">Player 1</span> made a new ration using <span class="label water">
        water</span> and <span class="label energy">energy</span> ingredient cards.'},
      {round_id: 4, phase_id: 2, game_user_id: 1, title: 'An Action',
        description: '<span class="badge player-1">Player 1</span> used and action card <span class="label label-success">
        Hungry Cow</span>. This made his 1st ration move forward <span class="label label-success">2</span> places.'},
      {round_id: 4, phase_id: 3, game_user_id: 1, title: 'Choosing',
        description: '<span class="badge player1">Player 1</span> chose to move ration number 3, with 2 <span class="label fiber">fiber</span>.'},
      {round_id: 4, phase_id: 3, game_user_id: 1, title: 'Dice',
        description: '<span class="badge player1">Player 1</span> rolled two dice, giving the options to move
        <span class="badge">3</span> or <span class="badge">5</span> spaces.'},
      {round_id: 4, phase_id: 3, game_user_id: 1, title: 'Moving',
        description: '<span class="badge player1">Player 1</span> chose to move the ration <span class="badge">5</span> places. The ration is now at position 16 in the Rumen.'},
    ]
  end

  def show
    render json: []
  end
end
