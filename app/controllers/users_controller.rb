class UsersController < ApplicationController
  def index
    render json: [
    {id: 2, name: 'Mary', score: '17', turnOrder: 1, colour: 'f00', active: false},
    {id: 1, name: 'Me', score: '6', turnOrder: 2, colour: '00f', active: true},
    {id: 3, name: 'John', score: '7', turnOrder: 3, colour: '0f0', active: false},
    {id: 4, name: 'Samson', score: '2', turnOrder: 4, colour: 'f0f', active: false}
    ]
  end

  def show
    render json: {id: 1, name: 'Me', score: '6', turnOrder: 2, colour: '00f', active: true}
  end
end
