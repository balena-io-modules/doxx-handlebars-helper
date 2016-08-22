_ = require('lodash')
Handlebars = require('handlebars')
{ stringifyPairs } = require('./util')

exports.Handlebars = Handlebars

exports.compileTemplate = compileTemplate = _.memoize (tpl) ->
  return Handlebars.compile(tpl)

exports.render = (template, context) ->
  return '' if not template
  compiled = compileTemplate(template)
  return compiled(context)

parseJsonPartial = _.memoize (key) ->
  partial = Handlebars.partials[key]
  return if not partial?
  try
    return JSON.parse(partial)
  catch e
    throw new Error("Error parsing JSON partial #{key}: #{e}")

getPartial = (hash, key) ->
  partial = hash[key]
  return if not partial?
  return compileTemplate(partial)

exports.getPartial = (key) -> getPartial(Handlebars.partials, key)

getFullKey = (prefix, option, sep) -> "#{prefix}#{sep}#{option}"

exports.getBestPartial = getBestPartial = _.memoize (prefix, options, sep = '/') ->
  hash = Handlebars.partials
  getKey = getFullKey
  combinedPrefix = "#{prefix}.json"
  if hash[combinedPrefix]?
    hash = parseJsonPartial(combinedPrefix)
    getKey = (prefix, option, sep) -> option

  for option in options
    partial = getPartial(hash, getKey(prefix, option, sep))
    return partial if partial
, getFullKey

importDefaults =
  importName: 'import'
  beforeRun: null
  partialsSearchFieldName: '$partials_search'
  defaultPartialName: '_default'
  contextFieldName: '$variables'

exports.createImportHelper = createImportHelper = (options) ->
  return (prefix) ->
    importDefaults.beforeRun?.apply(this)

    partialsSearch = this[options.partialsSearchFieldName]
    if not partialsSearch
      console.warn("""#{options.importName}: no partials search specified, using "#{options.defaultPartialName}".""")
      partialsSearch = [ ]

    partial = getBestPartial(prefix, partialsSearch.concat(options.defaultPartialName))
    if partial
      return new Handlebars.SafeString(partial(this))

    error = [
      """#{options.importName}: Can't find any matching partial for "#{prefix}"."""
    ]
    if options.contextFieldName
      context = this[options.contextFieldName]
      error.push("Context: #{stringifyPairs(context)}.")
    error.push("Partials search: #{partialsSearch.join(', ')}.")
    throw new Error(error.join('\n'))

exports.registerHelper = registerHelper = (consolidate, options) ->
  options = _.assign({}, importDefaults, options)
  Handlebars.registerHelper options.importName, createImportHelper(options)

exports.registerConsolidate = (consolidate, options) ->
  registerHelper(consolidate, options)

  consolidate.requires.handlebars = Handlebars
