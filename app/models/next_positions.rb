class NextPosition < ActiveRecord::Base
  belongs_to :position, foreign_key: 'position_to_id'
  belongs_to :position, foreign_key: 'position_from_id'
end
