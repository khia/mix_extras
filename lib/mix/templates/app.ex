defmodule Mix.Templates.App do
  @moduledoc """
  mix gen Mix.Templates.App apps/mytest --sup true --ns my
  or
  mix gen App apps/mytest --sup true --ns my
  """
  import Mix.Generator
  import Mix.Utils, only: [camelize: 1, underscore: 1]

  def structure(_path, assigns) do
    app = assigns[:app]
    spec =
      [
       {"README.md",  readme_template(assigns)},
       {".gitignore", gitignore_text},
       {"mix.exs", mixfile_template(assigns)},
       {"test/test_helper.exs", test_helper_template(assigns)},
       {"test/#{app}_test.exs", test_lib_template(assigns)},
      ]
    if assigns[:sup] do
      spec = [
       {"lib/#{app}.ex", lib_app_template(assigns)},
       {"lib/sup.ex", lib_supervisor_template(assigns)},
      ] ++ spec
    else
      spec = [{"lib/#{app}.ex", lib_template(assigns)}|spec]
    end
  end
  def generate(path, assigns, _opts // []) do
    lc {file_name, template} inlist structure(path, assigns) do
      create_file(file_name, template)
    end
  end
  def assigns(path, opts) do
    name        = opts[:app] || Path.basename(Path.expand(path))
    default_app = default_app(name, opts[:ns])
    ns = opts[:ns]
    app = opts[:app] || name
    check_project_name!(name)
    mod     = opts[:module] || camelize(default_app)
    unless nil?(ns) do
      mod = Enum.join([camelize(ns), mod], ".")
    end
    otp_app = if opts[:sup], do: "[mod: { #{mod}, [] }]", else: "[]"
    [app: app, name: name, mod: mod, otp_app: otp_app]
  end

  defp default_app(name, nil), do: name
  defp default_app(name, ns), do: String.replace(name, ns, "")

  defp check_project_name!(name) do
    unless name =~ %r/^[a-z][\w_]*$/i do
      raise Mix.Error, message: "project path must start with a letter and have only letters, numbers and underscore"
    end
  end

  embed_template :readme, """
   # <%= @mod %>

   ** TODO: Add description **
   """

   embed_text :gitignore, """
   /ebin
   /deps
   erl_crash.dump
   """

  embed_template :mixfile, """
  defmodule <%= @mod %>.Mixfile do
    use Mix.Project

    def project do
      [ app: :<%= @app %>,
        version: "0.0.1",
        deps: deps ]
    end

    # Configuration for the OTP application
    def application do
      <%= @otp_app %>
    end

    # Returns the list of dependencies in the format:
    # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
    defp deps do
      []
    end
  end
  """

  embed_template :lib, """
  defmodule <%= @mod %> do
  end
  """

  embed_template :lib_app, """
  defmodule <%= @mod %> do
    use Application.Behaviour

    # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
    # for more information on OTP Applications
    def start(_type, _args) do
      <%= @mod %>.Supervisor.start_link
    end
  end
  """

  embed_template :lib_supervisor, """
  defmodule <%= @mod %>.Supervisor do
    use Supervisor.Behaviour

    def start_link do
      :supervisor.start_link(__MODULE__, [])
    end

    def init([]) do
      children = [
        # Define workers and child supervisors to be supervised
        # worker(<%= @mod %>.Worker, [])
      ]

      # See http://elixir-lang.org/docs/stable/Supervisor.Behaviour.html
      # for other strategies and supported options
      supervise(children, strategy: :one_for_one)
    end
  end
  """

  embed_template :test_lib, """
  Code.require_file "../test_helper.exs", __FILE__

  defmodule <%= @mod %>Test do
    use ExUnit.Case

    test "the truth" do
      assert(true)
    end
  end
  """

  embed_template :test_helper, """
  ExUnit.start
  """

end
