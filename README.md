Handlebars helper for smart partials import.
======================

> Extracted from [doxx](https://github.com/balena-io-modules/doxx).

This is a very simple module that exposes a couple of convenience methods to render Handlebars templates by hand, and a "smart partials" helper.

## `Handlebars`

The packaged Handlebars engine is exported as `Handlebars`

## Utility methods

### `compileTemplate(templateString)`

A memoized version of `Handlebars.compile`

### `render(template, context)`

Compiles the template and renders it to a string with the given context.
Uses the memoized `compileTemplate`.

### `getPartial(partialName)`

Find the partial with the given name (the partial must be previously registered) and returns compiled template for it.
Uses the memoized `compileTemplate`.

### `getBestPartial(prefix, options, separator = '/')`

Loops through an array of `options` looking for partials named `"#{prefix}#{separator}#{option}"`. Returns the first match as compiled template.
Returns `undefined` if no matches found.
Uses the memoized `compileTemplate`.

Example: `getBestPartial('some/folder', [ 'specificPartial', 'defaultPartial' ])`
will first check for `some/folder/specificPartial` and then for `some/folder/defaultPartial` and return the compiled template for the first existing partial.

**Special JSON partials handling.** For convenience multiple partials can be combined under a single JSON partial. To use this feature that special combined partial name must end with `.json` (if your partials are imported from the filesystem this usually means that the file should have double extension, like `some/file.json.part`).
The partial is parsed and it should result in an object whose keys are treated as search partial names. In this case the `separator` parameter is ignored.

This is useful when you have lots of small (usually one-line) partials — instead of a folder with hundreds of files in it you can have a single JSON file.

## `createImportHelper(options)`

This is the main feature of the module. The function creates a helper (_but does not register it_) that can be called like that:

`{{ import "prefix" }}`.

This helper will search for partials with their names starting with `prefix` (using `getBestPartial`). The options must be specified in the specific field on the helper execution context.

The options are:

`importName`, default `'import'`. Used in exceptions and log message to identify the helper.

`beforeRun`, default `null`. If a function is passed it will be called before each helper call. A good place to do some checks and log things / throw errors.

`partialsSearchFieldName`, default `'$partials_search'`. The name of the property on the execution context where the search order is defined (corresponds to the `options` parameter of the `getBestPartial` method).

`defaultPartialName`, default `'_default'`. The name of the partial to be checked if not partials from `partialsSearchFieldName` are found.

`contextFieldName`, default `'$variables'`. Used for reporting only. If set and no partials are found the value of this field from the execution context is included into the exception message.

## `registerHelper(options)`

Creates the import helper and registers it with Handlebars under `options.importName`. `options` are the same described above.

## `registerConsolidate(consolidate, options)`

Convenience method if you use `consolidate` to render your handlebars templates. This calls `registerHelper` and then passes the reference to packaged `Handlebars` to `consolidate`.



License
-------

The project is licensed under the Apache 2.0 license.
