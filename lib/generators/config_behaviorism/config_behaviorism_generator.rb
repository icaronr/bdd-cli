require 'test_generator'


  class ConfigBehaviorismGenerator < Rails::Generators::NamedBase
    desc "Creates a observer initializer file."
    def create_config_behaviorism
      template_path = File.join(File.dirname(__FILE__), './templates/observer.rb')
      template = File.read(template_path)
      create_file "config/initializers/observer.rb", template

      puts "Observer Initializer created."
    end
  end
