var hcApp = angular.module('happyCow', [
  'ui.bootstrap', 'ngSanitize', 'ngRoute', 'restangular', 'angularModalService', 'ngStorage', 'colorpicker.module',
  'happyCowServices', 'happyCowDirectives'
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
      when('/profile', {
        templateUrl: 'templates/profile.html',
        controller: 'ProfileCtrl'
      }).
      when('/games', {
        templateUrl: 'templates/games.html',
        controller: 'GamesCtrl'
      }).
      when('/games/new/:gameId', {
        templateUrl: 'templates/game_new.html',
        controller: 'GameNewCtrl'
      }).
      when('/games/play/:gameId', {
        templateUrl: 'templates/game_play.html',
        controller: 'GameCtrl'
      }).
      otherwise({
        templateUrl: 'templates/welcome.html',
        controller: 'WelcomeCtrl'
      });
  }]);
