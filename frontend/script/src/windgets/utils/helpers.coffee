Object::convert = (type, options)->
# This will be improved. I want a powerful convertation tool. But for now is enough...
	thisValue = @valueOf()
	switch type
		when 'array'
			result = []
			switch typeof thisValue
				when 'object'
					if thisValue.length
						result = @
					else
						if options?.recursive
							for own key, item of thisValue
								result.push item.convert('array', true)
						else
							result = [thisValue]
				when 'string'
					if options?.separator
						result = thisValue.split options.separator
				else
					result = [thisValue]
	result

Object::listen = (events, handlers, removeListener)->
	elms = @convert('array')
	events = events.convert('array', separator: /\s/g)
	handlers = handlers.convert('array')
	for elm in elms
		for event in events
			for handler in handlers
				elm[['removeEventListener', 'addEventListener'][+ !removeListener]] event, handler
	@