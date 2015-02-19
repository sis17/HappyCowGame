var menuCtrl = angular.module('happyCow').controller('MenuCtrl', [
  '$scope',
  function($scope) {
    return $scope;
  }
]);

menuCtrl.controller('ScoreViewCtrl', [
  '$scope', 'User',
  function($scope, User) {
    /*var data = User.get({id: 1}, function(data) {
      console.log(data);
    });*/
    $scope.players = User.query();
  }
]);

menuCtrl.controller('RoundViewCtrl', [
  '$scope', 'Round',
  function($scope, Round) {
    $scope.rounds = Round.query();
  }
]);

menuCtrl.controller('PlayerViewCtrl', [
  '$scope', 'User',
  function($scope, User) {
    $scope.players = User.query();
  }
]);
