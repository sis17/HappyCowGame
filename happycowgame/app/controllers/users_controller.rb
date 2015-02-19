class UsersController < ApplicationController
  def index
    render json: [
    {id: 2, name: 'Mary', score: '17', turnOrder: 1, active: false},
    {id: 1, name: 'Me', score: '6', turnOrder: 2, active: true},
    {id: 3, name: 'John', score: '7', turnOrder: 3, active: false},
    {id: 4, name: 'Samson', score: '2', turnOrder: 4, active: false}
    ]
  end

  def show
    render json: {id: 1, name: 'Me', score: '6', turnOrder: 2, active: true}
  end
end
