require 'test_helper'

class RationsControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should create ration" do
    assert_difference('Ration.count') do
      post :create,
        {ration:
          {game_user_id:20,
            ingredients:[
              {
                id:38,game_user_id:20,game_card_id:93,
                game_card:{
                  id:93,game_id:14,card_id:6,quantity:3,
                  card:{
                    id:6,title:"Oligos",description:"A special ingredient, only the first and second absorbed score points.",
                    image:"cards/oligos.png",category:"oligos",rating:5,user_id:1
                  }
                },
                game_user:{id:20,score:0,colour:"ff0555",user_id:1,game_id:14,
                  user:{id:1,name:"Simeon",experience:0}
                }
              }
            ],game_id:14
          }
        }
    end

  end
end
