var directives = angular.module('happyCowDirectives', [])

.directive('popup', function ($compile,$templateCache) {
  return {
    restrict: "A",
    compile: function($templateElement, $templateAttributes) {
      return function($scope, $element, $attributes) {
          var options = {
              content: function() {
                return $($element).next().html();
              },
              container: 'body',
              placement: 'bottom',
              html: true
          };
          $($element).popover(options);
      };
    }
  };
});
