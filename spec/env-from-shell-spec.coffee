EnvFromShell = require '../lib/main'
{env} = process

describe "EnvFromShell", ->
  [workspaceElement, activationPromise, envFromShell] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('env-from-shell')

    spyOn(EnvFromShell, 'getEnvs').andCallFake((names) ->
      environment = {}
      names.forEach((name) ->
        environment[name] = "#{name} shell value"
      )
      Promise.resolve(environment)
    )

    env.FOO = 'default value'
    delete env.FOO_PATH

    atom.config.set('env-from-shell.variables', ['FOO', 'FOO_PATH'])

  describe "when the env-from-shell:copy", ->
    it "Set the environment variable from the user's shell", ->
      expect(env.FOO).toEqual('default value')
      expect(env.FOO_PATH).toBeUndefined()
      atom.commands.dispatch workspaceElement, 'env-from-shell:copy'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(env.FOO).toEqual('FOO shell value')
        expect(env.FOO_PATH).toEqual('FOO_PATH shell value')

    it "when the env-from-shell:reset", ->
      atom.commands.dispatch workspaceElement, 'env-from-shell:copy'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(env.FOO).toEqual('FOO shell value')
        expect(env.FOO_PATH).toEqual('FOO_PATH shell value')
        atom.commands.dispatch workspaceElement, 'env-from-shell:reset'
        expect(env.FOO).toEqual('default value')
        expect(env.FOO_PATH).toBeUndefined()

  describe "getEnvs", ->
    beforeEach ->
      jasmine.unspy(EnvFromShell, 'getEnvs')

    it "Return the result of environment variable in the user's shell", ->
      waitsForPromise ->
        EnvFromShell.getEnvs(['ATOM_HOME', 'NODE_PATH']).then((environment) ->
          expect(environment.ATOM_HOME).toEqual(env.ATOM_HOME)
          expect(environment.NODE_PATH).toEqual(env.NODE_PATH)
        )
