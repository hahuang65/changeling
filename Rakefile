#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec/core/rake_task"

Dir.glob('benchmarks/*.rake').each { |r| import r }

desc "Run all benchmarks."
task :benchmark, :count, :fields do |t, args|
  args.with_defaults(:count => 1000, :fields => 20)

  Rake::Task["benchmark_setup"].invoke
  Rake::Task["benchmark_tire"].reenable
  Rake::Task["benchmark_tire"].invoke
  puts "====================================================================\n\n"
  Rake::Task["benchmark_changeling"].reenable
  Rake::Task["benchmark_changeling"].invoke
end

RSpec::Core::RakeTask.new("spec") do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

RSpec::Core::RakeTask.new('spec:progress') do |spec|
  spec.rspec_opts = %w(--format progress)
  spec.pattern = "spec/**/*_spec.rb"
end

task :default => :spec


# Helper methods
def generate_loglings(count, fields)
  hashes = generate_logling_hashes(count, fields)

  loglings = []

  hashes.each { |hash| loglings << Changeling::Models::Logling.new(hash) }

  loglings
end

def generate_logling_hashes(count, fields)
  hashes = []
  count.times do
    hash = {}

    hash['klass'] = "Object"
    hash['oid'] = BSON::ObjectId.new.to_s
    hash['modified_by'] = BSON::ObjectId.new.to_s
    hash['modified_at'] = Time.now.to_s
    hash['modifications'] = {}
    fields.times do |time|
      hash['modifications']["name_of_field_#{time}"] = ["value_of_field_before_#{time}", "value_of_field_after_#{time}"]
    end
    hash['modifications'] = hash['modifications'].to_json

    hashes << hash
  end

  hashes
end
