/**
 * Panic attack helper
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! \backbone.wreqr : { radio }


export panic-attack = (err)!->
	radio.commands.execute \police, \panic, err
	throw err
