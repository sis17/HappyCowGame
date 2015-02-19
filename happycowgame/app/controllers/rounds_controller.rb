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
    render json: {number: 1, active: false}
  end
end
