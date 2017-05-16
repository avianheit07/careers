var toUnk = [
  "/:unk"
]

routes = {
  '/': {
    controller: 'SiteController',
    action:'index'
  },
  'post /login':{
    controller: 'SiteController',
    action:'login'
  },
  'get /logout':{
    controller: 'SiteController',
    action: 'logout'
  },
  'get /auth/google': {
    controller: 'SiteController',
    action: 'oauth'
  },
  'post /company/create':{
    controller: 'CompanyController',
    action: 'create'
  },
  'delete /company/remove/:id':{
    controller: 'CompanyController',
    action: 'remove'
  },
  'get /user/search':{
    controller: 'UserController',
    action: 'search'
  },
  'put /user/update/:id': {
    conttroller: 'UserController',
    action: 'update'
  },
  'get /user/requester':{
    controller: 'UserController',
    action: 'requester'
  },
  'get /user/hr': {
    controller: 'Usercontroller',
    action: 'hr'
  },
  'get /position/remove/:id':{
    controller: 'PositionController',
    action: 'remove'
  },
  'get /position/list/:id':{
    controller: 'PositionController',
    action: 'list'
  },
  'get /applicant/show/:id':{
    controller: 'ApplicantController',
    action: 'show'
  },
  // Ensure tracker won't issue error.
  'get /applicant/tracker/:code':{
    controller: 'ApplicantController',
    action: 'tracker'
  },
  'get /tracker/:code':{
    controller: 'SiteController',
    action: 'index'
  },
  // Reprocess applicants that have applied for a specific ad
  'get /reprocessed/:id':{
    controller: 'SiteController',
    action: 'index'
  },
  'get /ad/:id': 'SiteController.index'
};

toUnk.forEach(function(url){
  routes[url] = {
    controller: 'SiteController',
    action: 'index',
    skipAssets: true
  }
});

module.exports.routes = routes;