class Position < ActiveRecord::Base
  has_many :rations
  has_many :motiles

  has_and_belongs_to_many(:positions,
    :join_table => "next_positions",
    :foreign_key => "position_from_id",
    :association_foreign_key => "position_to_id")

  def as_json(options={})
    super(
      :include=> [
        :positions
      ]
    )
  end
end
