class Ration < ActiveRecord::Base
  belongs_to :user

  def as_json(options={})
    super(
      :include => [
        {user: {:only => [:name, :id]}}
      ]
    )
  end
end
