app = angular.module("CareersApp", [
  "ngResource"
  "ngRoute"
  "ngAnimate"
  "ngCookies"
  "toaster"
  ])
app.config [
  "$routeProvider"
  "$locationProvider"
  ($routeProvider, $locationProvider) ->
    $locationProvider.html5Mode true
    $routeProvider
    .when("/login",
      template: JST["public/login/login.html"]()
      controller: "LoginCtrl"
    )
    .when("/",
      template: JST["public/home/home.html"]()
      controller: "HomeCtrl"
    )
    .when("/ad/:id",
      template: JST["public/home/ad.html"]()
      controller: "AdCtrl"
    )
    .when("/tracker/:code",
      template: JST["public/tracker/tracker.html"]()
      controller: "TrackerCtrl"
    )
    .when("/reprocessed/:id",
      template: JST["public/reprocess/reprocess.html"]()
      controller: "ReprocessCtrl"
    )
    .otherwise redirectTo: "/"
]