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
      template: JST["requester/ad/ad.html"]()
      controller: "AdCtrl"
    )
    .when("/ad/:id",
      template: JST["requester/ad/applicant.html"]()
      controller: "AdApplicantCtrl"
    )
    .when("/position",
      template: JST["requester/position/position.html"]()
      controller: "PositionCtrl"
    )
    .when("/requester",
      template: JST["requester/requester/requester.html"]()
      controller: "RequesterCtrl"
    )
    .when("/applicant",
      template: JST["requester/applicant/applicant.html"]()
      controller: "ApplicantCtrl"
    )
    .when("/settings",
      template: JST["common/settings/settings.html"]()
      controller: "SettingsCtrl"
    )
    .otherwise redirectTo: "/"
]