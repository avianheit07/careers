app.directive "slider",[
  "$timeout"
  ($t)->
    return {
      restrict: "E"
      replace: true
      transclude: true
      template:JST["common/directives/sliderDirective/slider.html"]()
      scope:
        status: "=status"
        statusname: "=statusname"

      link: (scope, element, attrs) ->
        scope.active = null

        if scope.statusname is 'verification'
          scope.$watch "status", (s) ->
            switch s
              when 0
                scope.active = 'NEW'
              when 1
                scope.active = 'VERIFIED'
              when 2
                scope.active = 'UNVERIFIED'
          , true

        else if scope.statusname is 'recommendation'
          scope.$watch "status", (s) ->
            switch s
              when 0
                scope.active = 'UNPROCESSED'
              when 1
                scope.active = 'RECOMMEND'
              when 2
                scope.active = 'NOT RECOMMEND'
          , true

        else if scope.statusname is 'examination'
          scope.$watch "status", (s) ->
            switch s
              when 0
                scope.active = 'UNPROCESSED'
              when 1
                scope.active = 'PASSED'
              when 2
                scope.active = 'FAILED'
          , true

        else if scope.statusname is 'interview'
          scope.$watch "status", (s) ->
            switch s
              when 0
                scope.active = 'UNPROCESSED'
              when 1
                scope.active = 'RECOMMEND'
              when 2
                scope.active = 'NOT RECOMMEND'
          , true

    }
]