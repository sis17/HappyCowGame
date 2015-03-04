var welcomeCtrl = hcApp.controller('GamesCtrl', [
  '$scope', '$location', 'Restangular',
  function($scope, $location, Restangular) {
    //console.log($scope.$storage.user);
    //$scope.game_users = $scope.user.getGameUsers();
    $scope.game_users = Restangular.one('users', $scope.$storage.user.id).getList('game_users');

    $scope.selectGame = function(game_user) {
      Restangular.one('games', game_user.game.id).get().then(function(game) {
        $scope.$storage.user.game_user = game_user;
        $scope.game = game;
        $scope.$storage.game = game;
      }, function() {
        $scope.alert('Game Not Found', 'Sorry about this, but we can\'t find that game.', 'danger', 2);
      });
    }

    $scope.finishSetup = function() {
      $scope.$storage.game = $scope.game;
      $location.path('games/new');
    }

    $scope.newGame = function() {
      $scope.$storage.game = null;
      $location.path('games/new');
    }

    $scope.translatePhase = function(phaseNum) {
      switch(phaseNum) {
        case 1:
          return 'Event';
        case 2:
          return 'Cards';
        case 3:
          return 'Movement';
        case 4:
          return 'Review';
      }
    }
  }
]);