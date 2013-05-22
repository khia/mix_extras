defmodule Mix.Tasks.Purge do
  use Mix.Task

  @shortdoc "Remove all ebin directories"

  @moduledoc """
  Purge compiled dependencies.

  By default, purges all dependencies. A list of deps can
  be given to clean specific ones. Purge does not unlock
  the repositories, unless --unlock is given.
  """

  import Mix.Deps, only: [all: 0, by_name: 1, format_dep: 1]

  def run(args) do
    case OptionParser.parse(args, switches: [:unlock]) do
      { opts, [] }   -> do_clean all, opts
      { opts, args } -> do_clean by_name(args), opts
    end
  end

  defp do_clean(deps, opts) do
    shell = Mix.shell

    apps = Enum.map deps, fn(Mix.Dep[opts: opts] = dep) ->
      purge = opts[:purge]
      if purge == nil or purge do
        shell.info "* Purging #{format_dep(dep)}"
        clean_ebin(deps_path(dep))
        dep.app
      end
    end

    if opts[:unlock] do
      Mix.Task.run "deps.unlock", apps
    end
  end

  defp deps_path(Mix.Dep[app: app, opts: opts]) do
    if nil?(opts[:path]) do
      Path.join(Mix.project[:deps_path], app)
    else
      opts[:path]
    end
  end

  defp clean_ebin(path) do
    files =  Path.wildcard(Path.join(path, "ebin/*"))
    files |> filter |> Enum.map File.rm(&1)
  end

  def filter(files) do
    Enum.filter(files, fn(x) -> String.first(Path.basename(x)) != "." end)
  end
end
