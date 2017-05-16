app.controller "CompanyCtrl", [
  "$scope"
  "$http"
  "COMPANY"
  "$timeout"
  ($scope, $http, COMPANY, $timeout) ->
    $scope.active =
      modal: {
        phone: []
        email: []
      }
      index: null

    $scope.role = 'hr'
    io.socket.get "/company/list", (data) ->
      $scope.companies = data
      console.log 'companies: ', $scope.companies
      $scope.$digest()
    io.socket.on "company/list", (msg) ->

      if msg isnt undefined or msg isnt null
        if msg.hasOwnProperty('method')
          switch msg.method.method
            when 'DELETE'
              $idx = null
              $scope.companies.forEach (company, index) ->
                if company.id is msg.id
                  $idx = index
                  return
              if $idx isnt null
                $scope.companies.splice msg.method.index, 1
        else
          $idx = null
          $scope.companies.forEach (company, index) ->
            if company.id is msg.id
              $idx = index
              return

          if $idx isnt null
            # console.log "update"
            $scope.companies[$idx] = msg
          else
            # console.log "create"
            $scope.companies.push msg

      $scope.$digest()

    io.socket.get "/user/hr", (data) ->
      $scope.user.hr = data
      $scope.$digest()

    io.socket.on "user/hr", (msg) ->
      if msg isnt undefined or msg isnt null
        if msg.hasOwnProperty('method')
          switch msg.method.method
            when 'DELETE'
              $idx = null
              $scope.user.hr.forEach (user, index) ->
                if user.id is msg.appuserId
                  $idx = index
                  return
              console.log $idx
              if $idx isnt null
                $scope.user.hr.splice $idx, 1
        else
          $idx = null
          $scope.user.hr.forEach (user, index) ->
            if user.id is msg.id
              $idx = index
              return

          if $idx isnt null
            $scope.user.hr[$idx] = msg
          else
            $scope.user.hr.push msg
        $scope.$digest()


    io.socket.get "/user/requester", (data) ->
      $scope.user.requester = data
      $scope.$digest()

    io.socket.on "user/requester", (msg) ->


    # modal for companies, create and update
    $scope.modalShown  = false

    $scope.toggleModal = (data) ->
      $scope.active =
        modal: {
          phone: []
          email: []
        }
        index: null
      $scope.modalShown = !$scope.modalShown

    $scope.hideModal = () ->
      $scope.modalShown = false


    $scope.company =
      phone: ''
      email: ''
      select: (index) ->
        value = index
        $scope.active.index = value
        $scope.modalShown   = !$scope.modalShown
        $scope.active.modal = $scope.companies[value]
      selected: (index) ->
        return index is $scope.active.index
      save: (what) ->
        $scope.active.modal.users = $scope.user.selected
        type = (if $scope.active.modal.id then "put" else "post")
        io.socket[type] "/company/create", $scope.active.modal, (data, jwres) ->
          if data
            $scope.active.modal = null
            $scope.$apply()
      remove: (index) ->
        $scope.hideModal()
        io.socket.delete "/company/remove/#{$scope.active.modal.id}", {"index": index}, (data, jwres) ->
          if data isnt undefined
            $scope.active.modal = null
            $scope.$apply()
      addPhone: ->
        $scope.active.modal.phone.push @phone
        @phone = ''
      addEmail: ->
        $scope.active.modal.email.push @email
        @email = ''
      splice: (what,index) ->
        switch what
          when 'phone'
            $scope.active.modal.phone.splice index, 1
          when 'email'
            $scope.active.modal.email.splice index, 1

    # $scope.select = (index) ->
    #   value = index
    #   $scope.active.index = value
    #   $scope.modalShown   = !$scope.modalShown
    #   $scope.active.modal = $scope.companies[value]

    # $scope.selected = (index) ->
    #   return index is $scope.active.index

    # $scope.addPhone = () ->

    # $scope.save = (what) ->
    #   $scope.active.modal.users = $scope.user.selected
    #   type = (if $scope.active.modal.id then "put" else "post")
    #   io.socket[type] "/company/create", $scope.active.modal, (data, jwres) ->
    #     if data
    #       $scope.active.modal = null
    #       $scope.$apply()

    # $scope.remove = (index) ->
    #   $scope.hideModal()
    #   io.socket.delete "/company/remove/#{$scope.active.modal.id}", {"index": index}, (data, jwres) ->
    #     if data isnt undefined
    #       $scope.active.modal = null
    #       $scope.$apply()


    $scope.user =
      search: ''
      selected: []
      hr: []
      requester: []
      find: ->
        self = this
        if @search.length >= 3 and @search?
          if $scope.pending
            $timeout.cancel($scope.pending)

          $scope.pending = $timeout ->
            $http.get '/user/search?search='+self.search
            .success (data) ->
              $scope.users = data
          , 1000
      add: (data) ->
        io.socket.post '/user/role', {id:data.id,role:$scope.role,companyId:$scope.active.modal.id}
        @search = ''
      remove: (data) ->
        io.socket.delete '/user/role', {id:data.id, role: "hr"}
      searchFilter: (user) ->
        match = false
        $scope.user.hr.forEach (item, index) ->
          if user.id is item.id
            match = true
        return user if match is false
      resultFilter: (user) ->
        if $scope.active.modal and $scope.active.modal.hasOwnProperty("id")
          return user
]