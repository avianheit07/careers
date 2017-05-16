app.directive "search",[
  "$timeout"
  "$http"
  ($t,$h)->
    return {
      restrict: "E"
      replace: true
      template:JST["common/directives/searchDirective/search.html"]()
      scope:
        role: "=role"
        company: '=company'

      link: (scope, element, attrs) ->
        scope.selected = []
        scope.search = ''

        scope.find = ->
          if scope.search.length >= 3
            $h.get '/user/search?search='+scope.search
            .success (data) ->
              scope.users = data
              console.log 'u: ', scope.users

        scope.add = (data) ->
          console.log 'datas in dir: ', data.id, scope.role, scope.company
          io.socket.post '/user/role', {id:data.id,role:scope.role,companyId:scope.company}
          scope.selected.push data
          scope.search = ''

        scope.remove = (data) ->
          io.socket.delete '/user/role', {id:data.id}
          angular.forEach scope.selected, (item, index) ->
            if item.id is data.id
              scope.selected.splice(index,1)

        scope.evaluate = (data) ->
          x = false
          angular.forEach scope.selected, (item, index) ->
            if item.id is data.id
              x = true
          return x
    }
]