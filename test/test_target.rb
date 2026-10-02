require 'ant_test_helper'

class TestTarget < Minitest::Test
  include Ant::TestHelper

  def test_delays_executing_tasks_in_targets_until_the_target_is_executed
    ant = example_ant :name => "foo" do
      target :foo do
        property :name => "foo", :value => "bar"
      end
    end
    refute_equal "bar", ant.properties["foo"]
    ant.execute_target(:foo)
    assert_equal "bar", ant.properties["foo"]
  end

  def test_ant_accumulates_targets_and_tasks_in_the_same_global_project
    ant do
      target :a
    end
    ant do
      target :b
    end
    assert_includes ant.project.targets.keys.to_a, "a"
    assert_includes ant.project.targets.keys.to_a, "b"
  end

  def test_heeds_if_and_unless_conditions
    message = String.new
    ant = example_ant do
      property :name => "foo", :value => "defined"
      target :will_never_execute, :if => "not.defined" do
        message << "will_never_execute?"
      end

      target :also_will_never_execute, :unless => "foo" do
        message << "also_will_never_execute"
      end

      target :may_execute, :if => "bar" do
        message << "executed"
      end
    end

    ant.execute_target(:will_never_execute)
    ant.execute_target(:also_will_never_execute)
    ant.execute_target(:may_execute)
    assert_empty message

    ant.property :name => "bar", :value => "defined"
    ant.execute_target(:may_execute)
    refute_empty message
  end

  def test_executes_target_tasks_and_non_tasks_in_order
    bar = nil
    ant = example_ant do
      target :foo do
        property :name => "bar", :value => "true"
        bar = ant.properties["bar"]
      end
    end
    ant.execute_target(:foo)
    assert_equal "true", bar
  end

  def test_is_executable_if_it_does_not_have_a_block
    bar = nil
    ant = example_ant do
      target :foo do
        property :name => "bar", :value => "true"
        bar = ant.properties["bar"]
      end
      target :bar, :depends => :foo
    end
    ant.execute_target(:bar)
    assert_equal "true", bar
  end

  def test_does_not_support_antcall_for_calling_other_targets
    ant = example_ant do
      target :foo
      target :bar do
        antcall :target => :foo
      end
    end
    assert_raises(Java::OrgApacheToolsAnt::BuildException) do
      ant.execute_target(:bar)
    end
  end

  def test_supports_ant_for_calling_other_buildfiles
    Dir.mktmpdir do |dir|
      output = File.join(dir, "output.txt")
      File.write(File.join(dir, "other.xml"), <<~XML)
        <project name="other">
          <target name="foo">
            <echo message="called foo" file="#{output}"/>
          </target>
        </project>
      XML
      a = example_ant do
        target :bar do
          ant :antfile => File.join(dir, "other.xml"), :target => :foo
        end
      end
      a.execute_target(:bar)
      assert_equal "called foo", File.read(output)
    end
  end
end
