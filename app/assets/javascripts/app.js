var hcApp = angular.module('happyCow', [
  'ui.bootstrap', 'ngSanitize', 'ngRoute', 'restangular', 'angularModalService', 'ngStorage',
  'happyCowServices'
]);

hcApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/login', {
        templateUrl: 'templates/login.html',
        controller: 'LoginCtrl'
      }).
      when('/register', {
        templateUrl: 'templates/register.html',
        controller: 'RegisterCtrl'
      }).
      when('/games', {
        templateUrl: 'templates/games.html',
        controller: 'GamesCtrl'
      }).
      when('/games/new', {
        templateUrl: 'templates/game_new.html',
        controller: 'GameNewCtrl'
      }).
      when('/games/play', {
        templateUrl: 'templates/game_play.html',
        controller: 'GameCtrl'
      }).
      otherwise({
        templateUrl: 'templates/welcome.html',
        controller: 'WelcomeCtrl'
      });
  }]);

/*hcApp.run(function($rootScope, $templateCache) {
  $rootScope.$on('$viewContentLoaded', function() {
    $templateCache.removeAll();
  });
});*/
