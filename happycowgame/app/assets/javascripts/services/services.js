var services = angular.module('happyCowServices', ['ngResource']);

services.factory('User', ['$resource',
  function($resource) {
    return $resource('/users/:id', {id: '@id'});
  }
]);

services.factory('Card', ['$resource',
  function($resource) {
    return $resource('/cards/:id', {id: '@id'});
  }
]);

services.factory('Round', ['$resource',
  function($resource) {
    return $resource('/rounds/:id', {id: '@id'});
  }
]);

services.factory('Action', ['$resource',
  function($resource) {
    return $resource('/actions/:id', {id: '@id'});
  }
]);

services.factory('Ration', ['$resource',
  function($resource) {
    var Ration = $resource('/rations/:id', {id: '@id'});
    Ration.selected = true;
    Ration.prototype.hasWater = function() {
      for (i in this.ingredients) {
        if (this.ingredients[i].type == 'water') {
          return true;
        }
      }
    };
    return Ration;
  }
]);
