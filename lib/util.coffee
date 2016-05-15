exports.stringifyPairs = (obj) ->
  s = []
  for key, value of obj
    s.push("#{key}: #{value}")
  return s.join(', ')
