defmodule Mix.Tasks.Deps.List do
  use Mix.Task

  @shortdoc "List paths to all dependencies"

  @moduledoc """
  List paths to all dependencies.

  By default, list all dependencies. Dependency can
  be given to output info about specific one.
  """

  import Mix.Deps, only: [all: 0, by_name!: 1, format_dep: 1]

  def run(args) do
    case OptionParser.parse(args, switches: []) do
      { opts, [] } -> print(all, opts)
      { opts, rest } -> print(by_name!(rest), opts)
    end
  end

  defp print(deps, _opts) do
    shell = Mix.shell
    Enum.map deps,
      fn(Mix.Dep[] = dep) ->
        shell.info "* #{dep.app}: #{deps_path(dep)}"
        dep.app
      end
  end

  defp deps_path(Mix.Dep[app: app, opts: opts]) do
    if nil?(opts[:path]) do
      Path.join(Mix.project[:deps_path], app)
    else
      opts[:path]
    end
  end
end
