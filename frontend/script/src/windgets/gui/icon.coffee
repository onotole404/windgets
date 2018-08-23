WindgetsIcon = (inputData)->
	WindgetsElement.call @, inputData

	@htmlNode.setAttribute('data-item-name', inputData.windowData.title)

	@activate = (flag)->
		@htmlNode.classList[['remove', 'add'][+flag]] 'active'
		@

	setupActivateInterface = ->
		@htmlNode.listen 'click', ->
			inputData.windgets.activateWindow inputData.id, false, true

	setupActivateInterface.call @

	@