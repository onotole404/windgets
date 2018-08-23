Windgets = (inputData)->
	structure =
		screen:
			constructor: WindgetsScreen
			htmlClass: 'windgets-screen js-windgets-screen'
			subs:
				desktop:
					constructor: WindgetsDesktop
					htmlClass: 'windgets-desktop js-windgets-desktop'
					subs:
						windows:
							constructor: WindgetsWindow
							htmlClass: 'windgets-window js-windgets-window'
							data: inputData.windowsData
				panel:
					constructor: WindgetsPanel
					htmlClass: 'windgets-panel js-windgets-panel'
					subs:
						icons:
							constructor: WindgetsIcon
							htmlClass: 'windgets-icon js-windgets-icon'
							data: inputData.windowsData
	openedWindows = []

	createElements = ((container, structure)->
		elements = {}
		for own key, node of structure
			if node.subs
				Object.assign elements[key] = new node.constructor(htmlClass: node.htmlClass), createElements elements[key].htmlNode, node.subs
				container.appendChild elements[key].htmlNode
			else
				elements[key] = node.data.map ((item, i)->
					element = new node.constructor windgets: @, id: i, htmlClass: node.htmlClass, windowData: item
					container.appendChild element.htmlNode
					element
				), @
		elements
	).bind @

	@elements = createElements inputData.container, structure

	@activateWindow = (id, deactivate, fromIcon)->
		if id in openedWindows
			if fromIcon && id == openedWindows[-1..][0]
				@elements.screen.desktop.windows[id].activate false, deactivate = true
			else
				openedWindows.splice (openedWindows.indexOf id), 1
		if deactivate
			id = openedWindows[-1..][0]
		else
			openedWindows.push id
		@elements.screen.desktop.windows.forEach (window, i)->
			window.activate id == i
		openedWindows.forEach ((window, i)->
			@elements.screen.desktop.windows[window].htmlNode.style.zIndex = i
			), @
		@activateIcon id
		@

	@activateIcon = (id)->
		@elements.screen.panel.icons.forEach (icon, i) ->
			icon.activate id == i
		@

	@