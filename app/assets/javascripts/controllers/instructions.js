angular.module('happyCow').controller('InstructionsCtrl',
  function ($scope, $modalInstance, user) {
    $scope.user = user;

    $scope.cancel = function () {
      $modalInstance.dismiss('cancel');
    };
});
