/**
 * Camelize and Dasherize helpers
 * implementation from prelude.ls library: http://www.preludels.com/
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */


export camelize = (.replace /[-_]+(.)?/g, (, c) -> (c ? '').to-upper-case!)

# convert camelCase to camel-case, and setJSON to set-JSON
export dasherize = (str) ->
    str
      .replace /([^-A-Z])([A-Z]+)/g, (, lower, upper) ->
         "#{lower}-#{if upper.length > 1 then upper else upper.to-lower-case!}"
      .replace /^([A-Z]+)/, (, upper) ->
         if upper.length > 1 then "#upper-" else upper.to-lower-case!
