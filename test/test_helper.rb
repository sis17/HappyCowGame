ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def json_response
      ActiveSupport::JSON.decode @response.body
  end

  # create a bit of the graph to move between positions
  def setup_positions(ration)
    pos1 = positions(:pos7)
    pos2 = positions(:pos8)
    pos3 = positions(:pos9)
    pos4 = positions(:pos10)
    pos1.positions.push(pos2)
    pos1.save
    pos2.positions.push(pos3)
    pos2.save
    pos3.positions.push(pos4)
    pos3.save
    ration.position = pos1
    ration.save
  end
end
