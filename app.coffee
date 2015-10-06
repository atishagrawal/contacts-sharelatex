Settings   = require "settings-sharelatex"
logger     = require "logger-sharelatex"
express    = require "express"
bodyParser = require "body-parser"
Errors     = require "./app/js/Errors"
HttpController = require "./app/js/HttpController"
Metrics    = require "metrics-sharelatex"
Path       = require "path"

Metrics.initialize("contacts")
logger.initialize("contacts")
Metrics.mongodb.monitor(Path.resolve(__dirname + "/node_modules/mongojs/node_modules/mongodb"), logger)
Metrics.event_loop?.monitor(logger)

app = express()

app.use Metrics.http.monitor(logger)

app.get  '/user/:user_id/contacts', HttpController.getUserContacts
app.post '/user/:user_id/contacts', bodyParser.json(limit: "2mb"), HttpController.addUserContacts

app.get '/status', (req, res)->
	res.send('contacts is alive')

app.use (error, req, res, next) ->
	logger.error err: error, "request errored"
	if error instanceof Errors.NotFoundError
		res.send 404
	else
		res.send(500, "Oops, something went wrong")

port = Settings.internal.contacts.port
host = Settings.internal.contacts.host
app.listen port, host, (error) ->
	throw error if error?
	logger.info "Docstore starting up, listening on #{host}:#{port}"