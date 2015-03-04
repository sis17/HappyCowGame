hcApp.controller('ProfileCtrl', [
  '$scope', '$location', 'Restangular',
  function($scope, $location, Restangular) {

    $scope.saveProfile = function() {
      profile = {
        email: $scope.$storage.user.email,
        name: $scope.$storage.user.name,
        colour: $scope.$storage.user.colour
      }

      Restangular.one('users', $scope.$storage.user.id).patch({profile:profile}).then(function(response) {
        $scope.alert(response.message.title, response.message.text, response.message.type, 2);
      }, function() {
        $scope.alert('Profile Not Saved', 'Sorry, but we can\'t save your profile right now.', 'warning', 2);
      })
    }
  }
]);
