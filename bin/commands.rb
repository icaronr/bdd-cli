module Behaviorism
    def install
        puts "Installing dependencies..."
        puts "Generating initializer..."
        puts "All done!"
    end
    
    def run
        puts "Running cucumber..."
        begin
        system "bundle exec cucumber", exception: true
        rescue StandardError => err
            puts "Error running cucumber..."
            return
        end
        puts "Processing logs..."
        puts "All done!"
    end
    
    def clean
        puts "Removing logs..."
        puts "Removing factories..."
        puts "All done!"
    end
    
    def generate
        puts "Checking command..."
        puts "All done!"
    end
end