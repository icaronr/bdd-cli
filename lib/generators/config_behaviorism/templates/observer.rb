require 'test_generator'
Rails.application.eager_load!
ApplicationRecord.descendants.each do |model|
  model.send(:include, TestGenerator::Observer)
  model.observe
end
=begin
config.after_initialize do
  p ENV['TESTGENERATOR']
  if ENV['TESTGENERATOR'] then
    require 'test_generator'
    cache = ActiveSupport::Cache::MemoryStore.new
    Rails.cache = cache
    Rails.application.eager_load!
    ApplicationRecord.descendants
                    .each do |model|
      model.send(:include,
          TestGenerator::Observer)
      model.observe
    end
  
    puts 'Observing models.'
  else
    puts "If you want to generate logs for future analysis, run: testgenerator run"
  end
end
=end