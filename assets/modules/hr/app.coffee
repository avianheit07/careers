app = angular.module("CareersApp", [
  "ngResource"
  "ngRoute"
  "ngAnimate"
  "toaster"
])
app.config [
  "$routeProvider"
  "$locationProvider"
  ($routeProvider, $locationProvider) ->
    $locationProvider.html5Mode true
    $routeProvider
    .when("/ad",
      template: JST["hr/ad/ad.html"]()
      controller: "AdCtrl"
    )
    .when("/ad/:id",
      template: JST["hr/ad/applicant.html"]()
      controller: "AdApplicantCtrl"
    )
    .when("/position",
      template: JST["hr/position/position.html"]()
      controller: "PositionCtrl"
    )
    .when("/requester",
      template: JST["hr/requester/requester.html"]()
      controller: "RequesterCtrl"
    )
    .when("/applicant",
      template: JST["hr/applicant/applicant.html"]()
      controller: "ApplicantCtrl"
    )
    .when("/settings",
      template: JST["common/settings/settings.html"]()
      controller: "SettingsCtrl"
    )
    .otherwise redirectTo: "/"
]