defmodule Mix.Tasks.Gen do
  use Mix.Task

  @shortdoc "Generate files using template of structure"

  @moduledoc """
  Creates a directory structure using given template.
  It expects the path of the project as argument.

      mix gen MODULE PATH

  Supports optional arguments:
    --ns <namespace>
    --sup
  """
  def run(argv) do
    { opts, argv } = OptionParser.parse(argv)
    case argv do
      [] ->
        raise Mix.Error, message: "expected MODULE and PATH to be given, please use `mix gen MODULE PATH`"
      [module_name, path|_] ->
        File.mkdir_p!(path)
        module = Module.concat([module_name])
        unless Code.ensure_loaded?(module) do
          module = Module.concat([Mix.Templates, module_name])
        end
        File.cd!(path, fn() -> generate(module, path, opts) end)
    end
  end

  def generate(module, path, opts) do
    assigns = module.assigns(path, opts)
    :ok = create_structure(module.structure(path, assigns))
    module.generate(path, assigns, opts)
  end

  def create_structure([]), do: :ok
  def create_structure([{path, _}|rest]) do
    File.mkdir_p!(Path.dirname(path))
    create_structure(rest)
  end
  def create_structure([path|rest]) do
    File.mkdir_p!(Path.dirname(path))
    create_structure(rest)
  end

end
