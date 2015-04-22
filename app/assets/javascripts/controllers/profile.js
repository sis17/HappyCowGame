hcApp.controller('ProfileCtrl', [
  '$scope', '$location', 'Restangular', 'notice',
  function($scope, $location, Restangular, notice) {
    // set user as logged in
    $scope.setAuthHeaders($scope.$storage.user.id, $scope.$storage.user.key);

    $scope.passwordNew = '';
    $scope.passwordConf = '';

    $scope.saveProfile = function() {
      var profile = {
        email: $scope.$storage.user.email,
        name: $scope.$storage.user.name,
        colour: $scope.$storage.user.colour
      }

      if ($scope.passwordNew.length > 0) {
        profile.password = $scope.passwordNew;
        if ($scope.passwordConf == $scope.passwordNew) {
          $scope.updateProfile(profile);
        } else{
          notice('Passwords Don`t Match', 'In order to update your password, please provide a matching confirmation password.', 'danger', 6);
        }
      } else {
        $scope.updateProfile(profile);
      }
    }

    $scope.updateProfile = function(profile) {
      Restangular.one('users', $scope.$storage.user.id).patch({profile:profile}).then(function(response) {
        notice(response.message.title, response.message.text, response.message.type, 4);
      }, function(response) {
        $scope.failedUpdate(response);
        //notice('Profile Not Saved', 'Sorry, but we can\'t save your profile right now.', 'warning', 4);
      });
    }
  }
]);
