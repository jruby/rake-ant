require 'ant_test_helper'

class TestProject < Minitest::Test
  include Ant::TestHelper

  def setup
    @ant = example_ant :name => "spec project", :description => "spec description"
  end

  def test_has_the_basedir_set
    # expand_path is used to avoid / and \\ mismatch on Windows
    assert_equal Dir::tmpdir, File.expand_path(@ant.project.base_dir.path)
  end

  def test_has_a_project_helper_created
    assert_kind_of Ant::ProjectHelper, @ant.project.get_reference(Ant::ProjectHelper::PROJECTHELPER_REFERENCE)
  end

  def test_has_a_logger_set
    refute_empty @ant.project.build_listeners
  end

  def test_has_a_name_and_description
    assert_equal "spec project", @ant.project.name
    assert_equal "spec description", @ant.project.description
  end
end
