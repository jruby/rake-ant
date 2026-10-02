require 'ant_test_helper'
require 'tmpdir'

class TestGraph < Minitest::Test
  include Ant::TestHelper
  include Rake::DSL

  BUILDFILE = File.expand_path('graph_example.xml', __dir__)

  def setup
    @app = Rake.application
    Rake.application = Rake::Application.new
  end

  def teardown
    Rake.application = @app
  end

  def test_dot_has_an_edge_from_each_dependency_to_its_target
    ant_import BUILDFILE
    dot = Rake::Ant.dot(ant.project)

    assert dot.start_with?("digraph ant {\n")
    assert dot.end_with?("}\n")
    edges = dot.lines[1..-2].map(&:chomp)
    assert_equal ["compile -> dist_jar", "compile -> test_unit", "init -> compile", "init -> dist_jar"], edges.sort
  end

  def test_ant_graph_task_defines_a_task
    ant_graph_task :graph, BUILDFILE, 'unused.png'
    refute_nil Rake::Task[:graph]
  end

  def test_ant_graph_task_writes_a_png
    skip 'Graphviz dot is not installed' unless system('dot', '-V', [:out, :err] => File::NULL)

    Dir.mktmpdir do |dir|
      output = File.join(dir, 'build_graph.png')
      ant_graph_task :graph, BUILDFILE, output
      Rake::Task[:graph].invoke

      assert_equal "\x89PNG".b, File.binread(output, 4)
    end
  end
end
