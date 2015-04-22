var hcApp = angular.module('happyCow', [
  'ui.bootstrap', 'ngSanitize', 'ngRoute', 'restangular', 'angularModalService',
  'ngStorage', 'colorpicker.module',
  'happyCowServices', 'happyCowDirectives'
]).

config(
  function($routeProvider, RestangularProvider) {
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
      when('/games/setup/:gameId', {
        templateUrl: 'templates/game_setup.html',
        controller: 'GameSetupCtrl'
      }).
      when('/games/play/:gameId', {
        templateUrl: 'templates/game_play.html',
        controller: 'GameCtrl'
      }).
      when('/games/review/:gameId', {
        templateUrl: 'templates/game_review.html',
        controller: 'GameReviewCtrl'
      }).
      /*when('/games/group', {
        templateUrl: 'templates/group_new.html',
        controller: 'GroupGameCtrl'
      }).
      when('/games/group/:gameId', {
        templateUrl: 'templates/group_setup.html',
        controller: 'GroupSetupCtrl'
      }).*/
      otherwise({
        templateUrl: 'templates/welcome.html',
        controller: 'WelcomeCtrl'
      });


  }
);
