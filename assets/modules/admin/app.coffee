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
    .when("/company",
      template: JST["admin/company/company.html"]()
      controller: "CompanyCtrl"
    )
    .when("/settings",
      template: JST["common/settings/settings.html"]()
      controller: "SettingsCtrl"
    )
    .otherwise redirectTo: "/"
]