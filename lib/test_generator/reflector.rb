module TestGenerator
  module Reflector
    include TestGenerator::Logger

    def reflect(klass, method_name, args, obj)
      attrs = obj.instance_variable_get("@attributes").to_hash
      atrs = obj.instance_variable_get("@id")
      if klass.name == "Service" then
        p "---------------------------------"
        pp klass.send(:get_callbacks, :validate)
        p "---------------------------------"
      end
      # klass.columns_hash.each do |k, v|
      # p "#{k}: #{v.type} = #{v.methods}" 
      # end

      if klass.exists? id: attrs['id']
        obj = klass.find(attrs['id'])

        response = if args.any?
          begin
          obj.method(method_name).super_method.call(*args)
          rescue
            p "Quebrou 1"
          end
        else
          begin
            obj.method(method_name).super_method.call
          rescue 
            p "Quebrou 2"
            # p method_name
          end
        end

        log(klass, method_name, args, attrs, response)
      end
    end
  end
end
