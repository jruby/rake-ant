require 'ant_test_helper'

class TestTask < Minitest::Test
  include Ant::TestHelper

  def setup
    # The single example ant project these tests validate
    @output = output = "ant-file#{rand}.txt"
    @message = message = String.new
    @ant = example_ant :basedir => "." do
      property :name => "jar", :value => "spec-test.jar"
      property :name => "dir", :value => "build"

      target :jar do
        jar :destfile => "${jar}", :compress => "true", :index => "true" do
          fileset :dir => "${dir}"
        end
      end

      macrodef :name => "greet" do
        attribute :name => "msg"
        sequential do
          echo :message => "Hello @{msg}", :file => "#{output}"
        end
      end

      target :greet do
        greet :msg => "Ant"
      end

      target :rubygreet do
        message << "Hello Ruby!"
      end
    end
  end

  def teardown
    File.unlink(@output) if File.exist?(@output)
  end

  def test_jar_has_structure
    assert_structure @ant.project.targets["jar"],
      [{:_name => "jar", :destfile => "spec-test.jar", :compress => "true", :index => "true",
        :_children => [ { :_name => "fileset", :dir => "build" }] }]
  end

  def test_jar_has_configured_structure
    assert_configured_structure @ant.project.targets["jar"],
      [{:_type => "org.apache.tools.ant.taskdefs.Jar",
        :_children => [{:_type => "org.apache.tools.ant.types.FileSet"}] }]
  end

  def test_macrodef_is_defined_and_invokable_from_a_target
    @ant.execute_target(:greet)
    assert_equal "Hello Ant", File.read(@output)
  end

  def test_rubygreet_executes_the_code_block_when_the_target_is_executed
    assert_empty @message
    @ant.execute_target(:rubygreet)
    assert_equal "Hello Ruby!", @message
  end
end
