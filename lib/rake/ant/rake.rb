def ant_task(*args, &block)
  Rake::Task.define_task(*args) do |t|
    ant.define_tasks(&block)
  end
end

# Defines a task that draws the target dependencies of an Ant build file as
# a PNG. Requires Graphviz's `dot` on the PATH.
def ant_graph_task(name = :'ant:graph', buildfile = 'build.xml', output = 'build_graph.png')
  Rake::Task.define_task(name) do
    ant_import buildfile
    IO.popen(['dot', '-Tpng', '-x', '-o', output], 'w') do |dot|
      dot.write Rake::Ant.dot(ant.project)
    end
    fail "dot exited with #{$?.exitstatus}" unless $?.success?
  end
end

class FileList
  def to_str
    join(',')
  end
end
