app.directive "modal", ->
  restrict: "E"
  scope:
    show: "="

  replace: true
  transclude: true
  link: (scope, element, attrs) ->
    scope.title = attrs.title
    scope.hideModal = () ->
      scope.show = false
      return
    return

  template: JST["common/directives/modalDirective/partialmodal.html"]
