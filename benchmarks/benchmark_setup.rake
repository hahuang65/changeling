task :benchmark_setup do
  Rake::Task["install"].invoke

  begin
    require 'changeling'
    require 'bson'
  rescue LoadError
    require 'rubygems'
    require 'changeling'
    require 'bson'
  end

  # Setup Tire stuff for benchmarks.
  Tire::Model::Search.index_prefix "changeling_benchmark"
  Changeling::Models::Logling.tire.index.delete
end
