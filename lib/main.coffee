{CompositeDisposable, Disposable}  = require 'atom'
{exec} = require 'child_process'

module.exports =
  activate: ->
    @commandSubscription = atom.commands.add('atom-workspace',
      'env-from-shell:copy': =>
        @copyEnvs(atom.config.get('env-from-shell.variables'))
      'env-from-shell:reset': =>
        @envsSubscriptions?.dispose()
        @envsSubscriptions = null
    )

  deactivate: ->
    @commandSubscription?.dispose()
    @commandSubscription = null
    @envsSubscriptions?.dispose()
    @envsSubscriptions = null

  getEnvs: (names) ->
    @echoEnvs(names).then((stdout) ->
      lines = stdout.split("\n")
      envs = {}
      for name, idx in names
        envs[name] = lines[idx]
      envs
    )

  copyEnvs: (names) ->
    return if names.length is 0
    @getEnvs(names).then((envs) =>
      @envsSubscriptions?.dispose()
      @envsSubscriptions = @setEnvs(envs)
    ).catch((error) ->
      atom.notifications.addError(error.toString(), dismissable: true)
    )

  setEnvs: (envs) ->
    subscriptions = new CompositeDisposable

    Object.keys(envs).forEach((name) ->
      value = envs[name]
      if process.env[name]?
        oldValue = process.env[name]
        disposable = new Disposable( ->
          process.env[name] = oldValue
        )
      else
        disposable = new Disposable( ->
          delete process.env[name]
        )

      process.env[name] = value
      subscriptions.add(disposable)
    )

    if atom.config.get('env-from-shell.debug')
      console.log 'setEnvs', envs
    subscriptions

  echoEnvs: (names) ->
    new Promise((resolve, reject) =>
      echoCommands = @buildEchoCommands(names)
      command = "#{process.env.SHELL} -i -c #{echoCommands}"
      console.log 'command', command if atom.config.get('env-from-shell.debug')

      exec(command, (error, stdout, stderr) ->
        return reject(error) if error
        resolve(stdout)
      )
    )

  buildEchoCommands: (names) ->
    echoCommands = names.map((v) -> "echo ${#{v}};").join('')
    echoCommands = "'#{echoCommands}'"
    if process.env.SHELL.match(/fish|tc?sh$/)
      echoCommands = "\"sh -c #{echoCommands}\""
    echoCommands

  activateConfig: ->
    pack = atom.packages.getActivePackage('auto-run')
    return unless pack

    {registerCommand} = pack.mainModule.provideAutoRun()
    registerCommand(
      keyPath: 'env-from-shell.autoRun'
      command: 'env-from-shell:copy'
    )
