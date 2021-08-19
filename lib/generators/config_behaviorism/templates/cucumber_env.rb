After do |scenario|
    if ENV["TESTGENERATOR"] then
      log "fim do cenário!!"
        keys = Rails.cache.instance_variable_get(:@data).keys
        # Monta um obj com as entradas da cache
        obj = {}
        
        # obj[user] = { 
          # method:{}, 
          # method2: {}, 
          # method3: {} 
        # }
  
        keys.each do |key|
          line = Rails.cache.fetch(key)
          klass, method_name = key.split('#')
          obj[klass] ||= {method_name => JSON.parse(line.to_json)}
          obj[klass].store(method_name, JSON.parse(line.to_json))
        end
        
        obj.each do |k, v|
          file_name = Rails.root.join("tmp/BDD_#{k}.json")
          log file_name
          File.open(file_name, 'w+') do |file|
            file_content = file.read
            if file_content == "" then
              file_content = "{}"
            end
            file_content = JSON.parse(file_content)
            v.each do |m_name, args_attrs|
              file_content[m_name] = args_attrs
            end
            
            file.write("[\n")
            file_content.each_with_index do |(k,v), index|
              file.write("{\"#{k}\": #{v.to_json}}")
              index == (file_content.size-1) ? file.write("\n") : file.write(",\n")
            end
  
            file.write("]")
          end
        end
        Rails.cache.clear
      end
  end