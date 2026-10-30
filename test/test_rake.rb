require 'ant_test_helper'

class TestRakeHelpers < Minitest::Test
  include Ant::TestHelper

  def test_sets_file_lists_as_task_attributes_by_joining_them_with_commas
    ant = Ant.new
    ant.property :name => "files", :value => FileList['*.*']
    assert_match(/,/, ant.properties["files"])
  end
end

class TestRakeAntTask < Minitest::Test
  include Ant::TestHelper

  def setup
    @app = Rake.application
    Rake.application = Rake::Application.new
  end

  def teardown
    Rake.application = @app
  end

  def test_creates_a_rake_task_whose_body_defines_ant_tasks
    refute_includes ant.properties, "foo"

    Rake::Task.define_task :initial
    ant_task :ant => :initial do
      property :name => "foo", :value => "bar"
    end
    refute_nil Rake::Task[:ant]
    assert_equal ["initial"], Rake::Task[:ant].prerequisites
    Rake::Task[:ant].invoke

    assert_equal "bar", ant.properties["foo"]
  end
end
