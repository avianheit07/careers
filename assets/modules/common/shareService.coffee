app.factory 'share', ($rootScope) ->
  sharedData = {}

  sharedData.set = (ad,ads,applications) ->
    sharedData.ad = ad
    sharedData.ads = ads
    sharedData.applications = applications
    return

  sharedData