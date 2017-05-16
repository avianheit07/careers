app.controller "NavigatorCtrl", [
  "$scope"
  "$location"
  "$http"
  ($s,$l,$http) ->
    $s.logout = ->
      document.location = "/logout"
    $s.url = (url)->
      url is $l.path()
    # $http.get("/user/profile/self",{cache:true}).success (data)->
    #   $s.SELF = data
]