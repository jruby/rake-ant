require 'ant_test_helper'

class TestAnt < Minitest::Test
  include Ant::TestHelper

  def test_ant_import
    Dir.chdir(File.dirname(__FILE__)) do
      ant_import 'ant_example.xml'
      assert_equal 'surely', ant.properties['set_from_ant']
    end
  end
end

class TestAntLoad < Minitest::Test
  include Ant::TestHelper

  def setup
    @previous_java_home = ENV['JAVA_HOME'] || ENV_JAVA['java.home']

    if Gem.win_platform?
      ENV['JAVA_HOME'] = '/C:/java6'
    else
      ENV['JAVA_HOME'] = '/System/Library/Frameworks/JavaVM.framework/Home'
    end
    @tools_jar = "#{ENV['JAVA_HOME']}/lib/tools.jar"
    @classes_zip = "#{ENV['JAVA_HOME']}/lib/classes.zip"

    Ant.instance_eval do
      remove_const(:JAVA_HOME) rescue nil
    end
  end

  def teardown
    ENV['JAVA_HOME'] = @previous_java_home
    Ant.instance_eval do
      begin
        remove_const(:JAVA_HOME)
        const_set(:JAVA_HOME, @previous_java_home)
      rescue NameError
        # ignore, JAVA_HOME constant is not necessarily set now
      end
    end
  end

  def test_adds_tools_jar_to_classpath_when_java_home_is_set_and_it_exists
    stub_file_exist { Ant.load }
    assert_includes $CLASSPATH, "file:#{@tools_jar}"
  end

  def test_adds_classes_zip_to_classpath_when_java_home_is_set_and_it_exists
    stub_file_exist { Ant.load }
    assert_includes $CLASSPATH, "file:#{@classes_zip}"
  end

  # Only JAVA_HOME, tools.jar and classes.zip exist, and each must be checked.
  def stub_file_exist(&block)
    existing = [ENV['JAVA_HOME'], @tools_jar, @classes_zip]
    checked = []
    File.stub(:exist?, ->(path) { checked << path; existing.include?(path) }, &block)
    assert_empty existing - checked
  end
end

class TestAntNew < Minitest::Test
  include Ant::TestHelper

  def test_can_be_instantiated_with_a_block
    klass = nil

    Ant.new do
      klass = self.class
    end

    assert_equal Ant, klass
  end

  def test_can_be_instantiated_with_a_block_whose_single_argument_receives_the_ant_instance
    klass = nil
    ant_klass = nil

    Ant.new do |ant|
      klass = self.class
      ant_klass = ant.class
    end

    refute_equal Ant, klass
    assert_equal Ant, ant_klass
  end

  def test_executes_top_level_tasks_as_it_encounters_them
    Ant.new do |ant|
      refute_equal "bar", ant.properties["foo"]
      ant.property :name => "foo", :value => "bar"
      assert_equal "bar", ant.properties["foo"]
    end
  end

  def test_has_a_valid_location
    assert File.exist?(Ant.new.location.file_name)
  end
end

class TestAntInstance < Minitest::Test
  include Ant::TestHelper

  def setup
    @ant = example_ant
  end

  def test_defines_methods_corresponding_to_ant_tasks
    [:java, :antcall, :property, :import, :path, :patternset].each do |task|
      assert_includes @ant.methods, task
    end
  end

  def test_executes_the_default_target
    @ant.target("default") { property :name => "spec", :value => "example" }
    @ant.project.default = "default"
    @ant.execute_default
    assert_equal "example", @ant.properties["spec"]
  end

  def test_executes_the_specified_target
    @ant.target("a") { property :name => "a", :value => "true" }
    @ant.target("b") { property :name => "b", :value => "true" }
    @ant.execute_target("a")
    assert_equal "true", @ant.properties["a"]
    @ant["b"].execute
    assert_equal "true", @ant.properties["b"]
  end

  def test_raises_when_a_bogus_target_is_executed
    assert_raises(RuntimeError) { @ant["bogus"].execute }
  end

  def test_handles_key_value_arguments_from_the_command_line
    @ant.project.default = "help"
    @ant.process_arguments(["-Dcommand.line.msg=hello", "help"], false)
    @ant.define_tasks do
      target :help do
        property :name => "msg", :value => "${command.line.msg}"
      end
    end
    @ant.run
    assert_equal "hello", @ant.properties["msg"]
  end
end

class TestAntDotAnt < Minitest::Test
  include Ant::TestHelper

  def test_prefers_ant_home_to_path
    skip '$ANT_HOME is not set' unless ENV['ANT_HOME']

    with_hidden_ant_path do
      Ant.ant(:basedir => File.expand_path('..', __dir__))
    end
  end
end
