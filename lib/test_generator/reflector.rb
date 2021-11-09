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
            p "cacetada 1"
            return nil
          end
        else
          begin
            obj.method(method_name).super_method.call
          rescue 
            "cacetada 2"
            return nil
          end
        end
      end
    end
  end
end
