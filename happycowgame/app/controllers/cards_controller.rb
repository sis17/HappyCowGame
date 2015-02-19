class CardsController < ApplicationController
  def index
    render json: [
      {
        id: 1, title: 'Energy', description: 'An Ingredient that can be used in rations. If more energy than water exists in the Rumen, the PH level decreases.',
        image: 'cards/energy.png', type: 'energy', rating: 5, user_id: 1
      },
      {
        id: 2, title: 'Protien', description: 'An Ingredient that can be used in rations. It scores most points when absorbed as Meat, and a good amount when absorbed as Milk.',
        image: 'cards/protien.png', type: 'protien', rating: 5, user_id: 1
      },
      {
        id: 3, title: 'Water', description: 'An Ingredient that can be used in rations. +1 to dice roll.',
        image: 'cards/water.png', type: 'water', rating: 5, user_id: 1
      },
      {
        id:1, title:'Acidodis/Alkalosis', description: 'Move the Rumen PH marker up or down 1-3 spaces. Your choice.',
        image: 'cards/actions/acidodis.png', type: 'action', rating: 3.4, user_id: 1
      }
    ]
  end

  def show
    render json: {
      id:1,
      title:'Acidodis/Alkalosis',
      description: 'Move the Rumen PH marker up or down 1-3 spaces. Your choice.',
      type: 'action',
      rating: 3.4,
      user_id: 1
    }
  end
end
