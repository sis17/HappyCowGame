hcApp.controller('GroupGameCtrl', [
  '$scope', '$location', '$modal', 'Restangular', 'notice',
  function($scope, $location, $modal, Restangular, notice) {
    $scope.game = {
      name: '',
      carddeck: null,
      rounds_min: 10,
      rounds_max: 10
    };
    Restangular.one('carddecks', 1).get().then(function(carddeck) {
      $scope.game.carddeck_id = carddeck.id;
      $scope.carddeck = carddeck;
    });
    $scope.game_users = [];

    // get list of users for invites
    $scope.users = Restangular.all("users").getList();
    // get list of carddecks to choose from
    $scope.decks = Restangular.all("carddecks").getList();

    $scope.create = function() {
      $scope.created = true;
      Restangular.all('games').post({
        new: true,
        game: $scope.game,
        users: $scope.groupUsers.all()
      }).then(function(response) {
        //notice(response.messages);
        if (response.success) {
          // now begin the game
          Restangular.one('games', response.game.id).patch({begin:true}).then(function(response) {
            if (response.success) {
              // set up game_users on groupUsers
              for (i in response.game.game_users) {
                var game_user = response.game.game_users[i];
                if ($scope.groupUsers.get(game_user.user_id)) {
                  $scope.groupUsers.get(game_user.user_id).game_user = game_user;
                  console.log(game_user.user.id);
                  // assign the first user
                  if (game_user.id == response.game.round.game_user_id) {
                    console.log('assigning the first user:')
                    console.log(game_user);
                    $scope.user.assign($scope.groupUsers.get(game_user.user_id));
                  }
                }
              }
              console.log($scope.groupUsers.all());
              $location.path('games/play/'+response.game.id);
            }
          }, function() {
            notice('Creation Failed', 'An error occured and the game could not be created.', 'warning', 4);
          });
        }
      }, function() {
        notice('Initalisation Failed', 'An error occured and the game could not be initialised.', 'warning', 4);
      });
    }

    $scope.abandon = function() {
      // change location
      $location.path('');
    }

    $scope.selectUser = function($item, $model, $label) {
      $scope.selectedUser = $item;
    }
    $scope.unselectUser = function() {
      $scope.selectedUser = null;
    }
    $scope.removeUser = function(user) {
      $scope.groupUsers.remove(user.id);
    }

    $scope.inviteUser = function() {
      user = $scope.selectedUser;
      $scope.selectedUser = null;

      var modalInstance = $modal.open({
        templateUrl: 'loginGroupUser.html',
        controller: 'LoginGroupUserCtrl',
        resolve: {
          user: function () {
            return user;
          }
        }
      });

      modalInstance.result.then(function (user) {
        user.game_users = [];
        $scope.groupUsers.add(user);
        console.log($scope.groupUsers.all());
      }, function () {
        console.log('Modal dismissed at: ' + new Date());
      });
    }
    $scope.availableUsers = function() {
      users = []
      for (i in $scope.users.$object) {
        user = $scope.users.$object[i]
        if (user) {
          canAdd = true
          groupUsers = $scope.groupUsers.all();
          if (groupUsers) {
            for (i in groupUsers) {
              var groupUser = groupUsers[i];
              if (groupUser && groupUser.user_id && groupUser.user_id == user.id) {
                canAdd = false;
              }
            }
          }
          if (canAdd) {
            users.push(user)
          }
        }
      }
      return users;
    }
  }
]);

angular.module('happyCow').controller('LoginGroupUserCtrl',
  function (notice, $scope, $modalInstance, Restangular, user) {
    $scope.user = user;

    $scope.login = function () {
      Restangular.service('login').post({email: user.email, password: user.password}).then(function (response) {
        notice(response.messages)
        if (response.success) {
          $scope.user = response.user;
          $modalInstance.close($scope.user);
        }
      }, function() {
        notice('Uh Oh', 'The request could not be completed.', 'warning', 4);
      });
    };

    $scope.cancel = function () {
      $modalInstance.dismiss('cancel');
    };
});
