EnvFromShell = require '../lib/main'
{env} = process

describe "EnvFromShell", ->
  [workspaceElement, activationPromise, envFromShell] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('env-from-shell')

    spyOn(EnvFromShell, 'echoEnvs').andCallFake((names) ->
      Promise.resolve(names.map((name) -> "#{name} shell value").join("\n"))
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

  describe "echoEnvs", ->
    beforeEach ->
      jasmine.unspy(EnvFromShell, 'echoEnvs')

    it "Return the result of printing environment variable in the user's shell", ->
      waitsForPromise ->
        EnvFromShell.echoEnvs(['ATOM_HOME', 'NODE_PATH']).then((output) ->
          expect(output).toEqual([env.ATOM_HOME, env.NODE_PATH].join("\n"))
        )
