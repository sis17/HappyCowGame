class Carddeck < ActiveRecord::Base
  belongs_to :user
  has_many :games
  has_and_belongs_to_many :cards

  def as_json(options={})
    super(
      :include=> [
        {user: {:only => [:id, :name, :email]}},
        :cards
      ]
    )
  end
end
