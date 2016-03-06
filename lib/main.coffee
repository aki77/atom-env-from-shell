{CompositeDisposable, Disposable}  = require 'atom'
{async: cenv} = require 'consistent-env'

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
    cenv().then((environment) ->
      envs = {}
      names.forEach((name) ->
        return unless environment[name]?
        envs[name] = environment[name]
      )
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

  activateConfig: ->
    pack = atom.packages.getActivePackage('auto-run')
    return unless pack

    {registerCommand} = pack.mainModule.provideAutoRun()
    registerCommand(
      keyPath: 'env-from-shell.autoRun'
      command: 'env-from-shell:copy'
    )
