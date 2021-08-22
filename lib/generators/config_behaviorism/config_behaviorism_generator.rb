require 'test_generator'


  class ConfigBehaviorismGenerator < Rails::Generators::NamedBase
    desc "Creates a observer initializer file."
    def create_config_behaviorism
      # init observer
      template_path = File.join(File.dirname(__FILE__), './templates/observer.rb')
      template = File.read(template_path)
      create_file "config/initializers/bdd_logger.rb", template
      puts "Observer Initializer created."
      #init cucumber env
      cucumber_template_path = File.join(File.dirname(__FILE__), './templates/cucumber_env.rb')
      cucumber_template = File.read(cucumber_template_path)
      create_file "features/support/bdd_env.rb", cucumber_template

      File.open("features/support/env.rb", 'a+') do |file|
        lines = file.readlines
        if !lines.include?("require File.join(File.dirname(__FILE__), 'bdd_env.rb')") then
          file.write "\nrequire File.join(File.dirname(__FILE__), 'bdd_env.rb')"
        end
      end
      puts "Cucumber env created."

    end
  end
