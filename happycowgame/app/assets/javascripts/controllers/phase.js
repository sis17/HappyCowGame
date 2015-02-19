var phaseCtrl = angular.module('happyCow').controller('PhaseCtrl', [
  '$scope',
  function($scope) {
    return $scope;
  }
]);

phaseCtrl.controller('EventCtrl', [
  '$scope',
  function($scope) {

  }
]);

phaseCtrl.controller('CardsCtrl', [
  '$scope', 'Card', 'Ration',
  function($scope, Card, Ration) {
    $scope.cards = Card.query();
    $scope.rations = Ration.query();
  }
]);
