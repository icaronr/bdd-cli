module TestGenerator
  module Logger
    require 'json'

    # def log(klass, method_name, args, attrs, response)
    def log(klass, method_name, args, obj)
      # get object attributes
      attrs = obj.instance_variable_get("@attributes").to_hash
      # Create temp model file
      # file_name = Rails.root.join("tmp/BDD_#{klass}.json")
      file_line = { 
        # "klass": "#{klass}",
        # "method": "#{method_name}",
        "args": args.to_json,
        "attrs": attrs.to_json
        # "response": "#{response.inspect.gsub('nil', 'null').to_json}"
      }
      Rails.cache.write("#{klass}##{method_name}",file_line)
      # file_content << file_line
      # # file_line = "{ \"klass\": \"#{klass}\", \"method\": \"#{method_name}\", \"args\": #{args.inspect}, \"attrs\": #{attrs.to_json}, \"response\": #{response.inspect.gsub('nil', 'null').to_json} }"
      # # file_line = "{ \"klass\": \"#{klass}\", \"method\": \"#{method_name}\", \"args\": #{args.inspect}, \"attrs\": #{attrs.to_json} }"
      # file = File.new(file_name, 'a')

      # unless File.open(file_name).each_line.any? { |line| line.include?(file_line) }
      #   file.puts file_line
      # end
      # p "[LOG_#{klass}] #{file_line}"
      # p keys = cache.instance_variable_get(:@data).keys
      # file.close
    end

    def self.write_log(klass, file_content)
      file_name = Rails.root.join("tmp/BDD_#{klass}.json")
      File.open(file_name, 'w+') do |file|
        file.write(JSON.generate(file_content))
      end
      #file.close
      #file.puts(JSON.generate(file_content))
      # unless File.open(file_name).each_line.any? { |line| line.include?(file_line) }
      #   file.puts file_line
      # end
    end


  end
end
