app.directive "fileuploader", [
  "$http"
  ($http) ->
    # Runs during compile
    return (
      restrict: "E" # E = Element, A = Attribute, C = Class, M = Comment
      template: "<div class=\"angu-uploader\"><div class=\"up-content\"><input type=\"file\" id=\"file-input\" style=\"display:none\"><span ng-class=\"{active:dom.files}\" name='resume'>{{droptext}}</span><div class=\"progress\" style=\"width:{{dom.progress}}%;\"></div></div></div>"
      replace: true
      scope:
        files: "="
        url: "@"
        type: "@"
        afterUpload: "="

      # {} = isolate, true = child, false/undefined = no change
      controller: ($scope, $element, $attrs) ->
        uploadProgress = (event) ->
          $scope.$apply ->
            $scope.dom.progress = Math.round(event.loaded * 100 / event.total)  if event.lengthComputable
            return

          return
        uploadComplete = (event) ->
          m = event.currentTarget.response
          $scope.$apply ->
            $scope.dom.progress = 0
            $scope.dom.files = false
            if typeof $attrs.afterUpload isnt "undefined"
              m                  = angular.fromJson(m)
              $scope.droptext    = "#{m[0].filename}"
              type               = $attrs.type
              $scope.afterUpload = m[0]
            return

          return
        uploadFailed = (event) ->
          alert "There was an error attempting to upload the file."
          return
        uploadCanceled = (event) ->
          $scope.$apply ->
            $scope.dom.progress = 0
            return

          alert "The upload has been canceled by the user or the browser dropped the connection."
          return
        $scope.preparedFiles = []
        $scope.fileChange = null
        $scope.droptext = "Drop your résumé here. "
        $scope.dom =
          files: false
          progress: 0

        reader = new FileReader()
        reader.onload = (loadEvent) ->
          console.log 'loadEvent', loadEvent
          $scope.$apply ->
            $scope.files = loadEvent.target.result
            return

          return

        dropbox = document.getElementById($attrs.id)
        $element.bind "dragover", (event) ->
          event.stopPropagation()
          event.preventDefault()
          $scope.$apply ->
            $scope.droptext = "DROP NOW"
            return

          return

        $element.bind "dragleave", (event) ->
          event.stopPropagation()
          event.preventDefault()
          $scope.$apply ->
            $scope.droptext = "Drop your file here"
            return

          return

        $scope.dropHappened = false
        $element.bind "drop", (event) ->
          event.stopPropagation()
          event.preventDefault()
          $scope.droptext = ""
          files = event.dataTransfer.files
          console.log 'files drop: ', files
          $scope.$apply $scope.organize(files)  if files.length > 0
          reader.readAsDataURL files[0]

          $scope.uploadFile()
          return


        input = $element[0].querySelector('#file-input')
        $element.bind 'click', (e) ->
          input.click()

        $element.bind 'change', (e) ->
          event.stopPropagation()
          event.preventDefault()
          files = e.target.files
          $scope.$apply $scope.organize(files)  if files.length > 0
          reader.readAsDataURL files[0]

          $scope.uploadFile()
          return


        $scope.setFiles = (element) ->
          $scope.$apply (scope) ->
            files = element.files
            console.log 'files', files
            $scope.organize files
            return
          return

        $scope.organize = (files) ->
          $scope.preparedFiles = []
          filenames = []
          i = 0

          while i < files.length
            filenames.push files[i].name
            $scope.preparedFiles.push files[i]
            i++
          $scope.droptext = angular.copy(filenames.join(", "))
          $scope.dom.files = true
          return

        $scope.uploadFile = ->
          if $scope.preparedFiles.length > 0
            fd = new FormData()
            for i of $scope.preparedFiles
              fd.append "file", $scope.preparedFiles[i]
            xhr = new XMLHttpRequest()
            xhr.upload.addEventListener "progress", uploadProgress, false
            xhr.addEventListener "load", uploadComplete, false
            xhr.addEventListener "error", uploadFailed, false
            xhr.addEventListener "abort", uploadCanceled, false
            xhr.open "POST", $attrs.url
            xhr.send fd
          return
        return
    )
]