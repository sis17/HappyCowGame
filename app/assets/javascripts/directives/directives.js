var directives = angular.module('happyCowDirectives', [])

// an element with the 'popup' attribute will use this directive
.directive('popup', function ($compile,$templateCache) {
  return {
    restrict: "A",
    compile: function($templateElement, $templateAttributes) {
      return function($scope, $element, $attributes) {
          // set the options for the Bootstrap popover
          var options = {
            content: function() {
              if ($attributes.template && $attributes.template.length > 0) {
                // the content can be set by providing a template name.
                return $('#'+$attributes.template).html();
              } else {
                // the content can be set by using the content of the following element, a hidden div.
                return $($element).next().html();
              }
            },
            container: 'body',
            placement: 'bottom',
            html: true
          };
          // the constructed popover is returned
          $($element).popover(options);
      };
    }
  };
});
