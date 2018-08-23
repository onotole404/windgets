WindgetsWindow = (inputData)->
	WindgetsElement.call @, inputData

	@htmlNode.innerHTML = '<div class="windgets-window-head"><div class="windgets-window-icon js-windgets-window-button" data-state="tile" data-item-name="' + inputData.windowData.title + '"></div><div class="windgets-window-title js-windgets-window-mover">' + inputData.windowData.title + '</div><div class="windgets-window-button js-windgets-window-button" data-state="fullscreen"></div></div><div class="windgets-window-body">' + inputData.windowData.content + '</div><div class="windgets-window-resizer js-windgets-window-resizer"></div>'

	@activate = (flag, collapse)->
		if collapse
			setState 'tile'
		else if flag && state() == 'tile'
			setState restoreRect()
		@htmlNode.classList[['remove', 'add'][+!!(collapse || flag)]] 'active'
		@

	serviceData =
		defaultState: 'tile'
		snapDistance: 10
		savedProps: {}

	initControls = ->
		serviceData.controls =
			btns: @htmlNode.querySelectorAll '.js-windgets-window-button'
			mover: @htmlNode.querySelector '.js-windgets-window-mover'
			resizer: @htmlNode.querySelector '.js-windgets-window-resizer'

	setCssProps = ((props)->
		for key of props
			@htmlNode.style[key] = if typeof(props[key]) == 'number' then props[key] + 'px' else props[key]
	).bind @

	saveRect = (->
		serviceData.savedProps.rect = @htmlNode.getBoundingClientRect()
	).bind @

	restoreRect = ->
		defaultRect = ->
			desktopRect = inputData.windgets.elements.screen.desktop.htmlNode.getBoundingClientRect()
			k = if desktopRect.width > desktopRect.height then x: .4, y: .5 else x: .6, y: .6
			width: desktopRect.width * k.x
			height: desktopRect.height * k.y
			left: Math.random() * desktopRect.width * (1 - k.x)
			top: Math.random() * desktopRect.height * (1 - k.y)
		setCssProps serviceData.savedProps?.rect || serviceData.savedProps.rect = defaultRect()
		'regular'

	state = (->
		if arguments.length then @htmlNode.setAttribute 'data-state', arguments[0] else @htmlNode.getAttribute 'data-state'
	).bind @

	setState = ((targetState)->
		if targetState == 'tile'
			setCssProps inputData.windgets.elements.screen.panel.icons[inputData.id].htmlNode.getBoundingClientRect()
			inputData.windgets.activateWindow(inputData.id, true)
		state if state() != targetState then targetState else restoreRect()
	).bind @

	setMode = ((mode)->
		@htmlNode.classList[['remove', 'add'][+(mode in ['move', 'resize'])]] 'transform'
		@htmlNode.classList[['remove', 'add'][+(mode == 'move')]] 'move'
	).bind @

	setupActivateInterface = ->
		@htmlNode.listen 'mousedown touchstart', ->
			inputData.windgets.activateWindow inputData.id

	setupBtnsInterface = ->
		serviceData.controls.btns.listen 'click', (evt) ->
			setState evt.target.getAttribute 'data-state'

	setupTransformInterface = ->
		[serviceData.controls.mover, serviceData.controls.resizer].listen 'mousedown touchstart', ((evt)->
			evt.preventDefault()
			pointerData = if evt.type == 'mousedown'
				coords: evt, moveEvt: 'mousemove', stopEvt: 'mouseup'
			else
				coords: evt.touches[0], moveEvt: 'touchmove', stopEvt: 'touchend'
			desktopRect = inputData.windgets.elements.screen.desktop.htmlNode.getBoundingClientRect()
			windowRect = @htmlNode.getBoundingClientRect()
			cursorStartCoords = x: pointerData.coords.clientX, y: pointerData.coords.clientY
			windowStartCoords = left: windowRect.left - desktopRect.left, top: windowRect.top - desktopRect.top
			action = if evt.target == serviceData.controls.resizer then 'resize' else 'move'
			notChanged = move: true, resize: true
			availableState = null
			checkEdge = ((evt) ->
				coordsSrc = if evt.type == 'mousemove' then evt else evt.touches[0]
				if action == 'move'
					inputData.windgets.elements.screen.desktop.showWindowShap availableState =
						coordsSrc.clientY < desktopRect.top + serviceData.snapDistance && 'fullscreen' ||
						coordsSrc.clientY > desktopRect.bottom - serviceData.snapDistance && 'tile' ||
						coordsSrc.clientX < desktopRect.left + serviceData.snapDistance && 'left' ||
						coordsSrc.clientX > desktopRect.right - serviceData.snapDistance && 'right'
			).bind @
			transformChecks = if action == 'resize' then null else checkEdge
			transformWindow = ((evt)->
				coordsSrc = if evt.type == 'mousemove' then evt else evt.touches[0]
				delta = x: coordsSrc.clientX - cursorStartCoords.x, y: coordsSrc.clientY - cursorStartCoords.y
				setCssProps if action == 'resize'
					width: windowRect.width + delta.x, height: windowRect.height + delta.y
				else
					left: windowStartCoords.left + delta.x, top: windowStartCoords.top + delta.y
				pullofPos = ->
					ratio = serviceData.savedProps.rect.width / windowRect.width
					coordsSrc.clientX * (1 - ratio) - desktopRect.left + windowRect.left * ratio
				if notChanged[action]
					notChanged[action] = false
					setMode action
					if action == 'move'
						if state() != 'regular'
							setCssProps left: windowStartCoords.left = pullofPos()
							setState 'regular'
			).bind @
			stopTransform = (->
				window.listen(pointerData.moveEvt, [transformWindow, transformChecks], true)
				.listen pointerData.stopEvt, stopTransform, true
				setMode false
				if availableState
					setState availableState
					inputData.windgets.elements.screen.desktop.showWindowShap availableState = null
				else if state() == 'regular'
					saveRect()
			).bind @
			window.listen(pointerData.moveEvt, [transformWindow, transformChecks])
			.listen pointerData.stopEvt, stopTransform
		).bind @

	state serviceData.defaultState
	initControls.call @
	setupActivateInterface.call @
	setupBtnsInterface()
	setupTransformInterface.call @

	@