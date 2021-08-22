module Behaviorism
    def install
        puts "Installing dependencies..."
        system "rm config/initializers/bdd_logger.rb"
        system "rm features/support/bdd_env.rb"
        puts "Generating initializer..."
        system "bundle exec rails g config_behaviorism init"
        puts "All done!"
    end
    
    def run args=["-p", "features"]
        type, *paths = args
        puts "Running cucumber..."
        if type == "-p" then
            if paths.size > 0 then
                paths = paths.join(" ")
                begin
                system "TESTGENERATOR=true bundle exec cucumber #{paths} --verbose", exception: true
                rescue StandardError => err
                    puts "Error running cucumber..."
                    return
                end
                puts "Processing logs..."
                puts "All done!"
            else
                puts "No paths specified"
                return
            end
        else
            puts "Option #{type} not supported!"
            return
        end
    end
    
    def clean args
        puts "Removing logs..."
        system "rm tmp/BDD_*"
        puts "Removing factories..."
        system "rm -rf spec/BDD"
        if args.include? "tests" then
            system "rm -rf spec/models/BDD"
        end
        puts "All done!"
    end
    
    def generate args
        generator, model_name = args
        puts "Checking command..."
        system "bundle exec rails g unit_test #{model_name}"
        puts "All done!"
    end
end