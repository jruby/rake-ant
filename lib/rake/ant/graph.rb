class Rake::Ant
  # Graphviz DOT text for the target dependencies of an Ant project, with an
  # edge from each dependency to the target that depends on it.
  def self.dot(project)
    edges = []
    project.targets.each do |name, target|
      target.dependencies.to_a.each do |dep|
        edges << "#{dot_id(dep)} -> #{dot_id(name)}"
      end
    end
    "digraph ant {\n#{edges.map { |edge| "#{edge}\n" }.join}}\n"
  end

  def self.dot_id(name)
    name.gsub(/[-.]/, '_')
  end
end
