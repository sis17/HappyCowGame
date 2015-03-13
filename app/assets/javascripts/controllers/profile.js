hcApp.controller('ProfileCtrl', [
  '$scope', '$location', 'Restangular', 'notice',
  function($scope, $location, Restangular, notice) {

    $scope.saveProfile = function() {
      profile = {
        email: $scope.$storage.user.email,
        name: $scope.$storage.user.name,
        colour: $scope.$storage.user.colour
      }

      Restangular.one('users', $scope.$storage.user.id).patch({profile:profile}).then(function(response) {
        notice(response.message.title, response.message.text, response.message.type, 2);
      }, function() {
        notice('Profile Not Saved', 'Sorry, but we can\'t save your profile right now.', 'warning', 2);
      })
    }
  }
]);
