desc "Benchmark Tire indexing times alone when objects are already created."
task :benchmark_tire, :count, :fields do |t, args|
  require 'benchmark'

  args.with_defaults(:count => 1000, :fields => 20)
  count = args[:count].to_i
  fields = args[:fields].to_i

  Rake::Task["benchmark_setup"].invoke

  puts "Benchmarking Tire: #{count} Logling(s) with #{fields} fields each.".upcase
  puts "Generating loglings. This may take a minute..."

  loglings = generate_loglings(count, fields)

  puts "Done generating loglings. Proceeding to benchmark..."

  Benchmark.bmbm do |bm|
    bm.report('Creation of Logling Index') do
      Changeling::Models::Logling.tire.create_elasticsearch_index
    end

    bm.report('Inserting Loglings into Index') do
      loglings.each { |logling| logling.update_index }
    end

    bm.report('Deletion of Logling Index') do
      Changeling::Models::Logling.tire.index.delete
    end
  end
end
