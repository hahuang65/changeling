desc "Benchmark Changeling processing times, from after_save hook through the final Tire index update."
task :benchmark_changeling, :count, :fields do |t, args|
  args.with_defaults(:count => 1000, :fields => 20)
  count = args[:count].to_i
  fields = args[:fields].to_i

  Rake::Task["benchmark_setup"].invoke

  puts "Benchmarking Changeling: #{count} object(s) with #{fields} fields each.".upcase
  puts "Generating objects. This may take a minute..."

  hashes = generate_logling_hashes(count, fields)
  loglings = []

  puts "Done generating objects. Proceeding to benchmark..."

  Benchmark.bmbm do |bm|
    bm.report('Creation of Logling Index') do
      Changeling::Models::Logling.tire.create_elasticsearch_index
    end

    bm.report("Initializing Loglings") do
      hashes.each { |hash| Changeling::Models::Logling.new(hash) }
    end

    bm.report('Creating Loglings') do
      hashes.each { |hash| Changeling::Models::Logling.create(hash) }
    end

    bm.report('Deletion of Logling Index') do
      Changeling::Models::Logling.tire.index.delete
    end
  end
end
