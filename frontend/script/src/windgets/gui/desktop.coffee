WindgetsDesktop = (inputData)->
	WindgetsElement.call @, inputData

	@showWindowShap = (snap)->
		@htmlNode.setAttribute 'data-window-snap', snap

	@