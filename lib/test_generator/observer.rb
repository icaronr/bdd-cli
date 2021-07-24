module TestGenerator
  module Observer
    DENYLIST = [:attributes, :serializable_hash, :inspect, :has_one_attached, :version=]

    # include TestGenerator::Reflector
    include TestGenerator::Logger
    
    def self.included(base_klass)
      base_klass.extend(ClassMethods)
      puts base_klass.name
      klass_name = base_klass.name.gsub("::", "_")
      observer = const_set("#{klass_name}_Observer", Module.new)
      base_klass.prepend observer
    end

    module ClassMethods
      def observe
        klass = self
        methods = klass.instance_methods(false) - DENYLIST
        klass_name = klass.name.gsub("::", "_")
        observer = const_get "#{klass_name}_Observer"
        
        observer.class_eval do
          methods.each do |method_name|
            define_method(method_name) do |*args, &block|
              # reflect(klass, method_name, args, self)
              log(klass, method_name, args, self)
              super(*args, &block)
            end
          end
        end
      end
    end
  end
end
