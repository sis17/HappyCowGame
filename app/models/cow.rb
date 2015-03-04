class Cow < ActiveRecord::Base
  has_one :game
  belongs_to :event, foreign_key: 'disease_id'
  belongs_to :event, foreign_key: 'weather_id'

  def as_json(options={})
    super(
      :include=> [
        :game
      ]
    )
  end
end
