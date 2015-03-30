var menuCtrl = angular.module('happyCow').controller('MenuCtrl', [
  '$scope',
  function($scope) {
    return $scope;
  }
]);

menuCtrl.controller('ScoreViewCtrl', [
  '$scope',
  function($scope) {
  }
]);

angular.module('happyCow').controller('RoundViewCtrl', [
  '$scope', '$modal', 'Restangular',
  function($scope, $modal, Restangular) {
    $scope.review = function (round) {
      Restangular.one('rounds', round.id).get().then(function(roundData) {
        var modalInstance = $modal.open({
          templateUrl: 'reviewRound.html',
          controller: 'RoundReviewCtrl',
          size: 'lg',
          resolve: {
            round: function () {
              return roundData;
            }
          }
        });

        modalInstance.result.then(function () {}, function () {
          console.log('Modal dismissed at: ' + new Date());
        });
      });
    };
  }
]);
angular.module('happyCow').controller('RoundReviewCtrl',
  function ($scope, $modalInstance, round) {
    $scope.round = round;
    console.log(round);
    $scope.reviewDetailsTemplate = 'templates/partials/review_details.html';

    $scope.ok = function () {
      $modalInstance.close();
    };

    $scope.cancel = function () {
      $modalInstance.dismiss('cancel');
    };
});

menuCtrl.controller('PlayerViewCtrl', [
  '$scope',
  function($scope) {
    //if ($scope.game.game_users[1]) {
    //  $scope.nextPlayer = $scope.game.game_users[1];
    //}
  }
]);
