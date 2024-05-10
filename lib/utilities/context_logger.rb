# logs namespace of calling class and method name
# Usage:
#   require 'utilities/context_logger'
#   module SomeModule
#     class SomeClass
#       include ContextLogger
# 
#       def some_method
#         log_from("Hello, World!")
#       end
#     end
#   end
#   SomeClass.new.some_method
# Output:
#   SomeModule::SomeClass#some_method - Hello, World!
module ContextLogger
  def log_from(messag, level = Logger::INFO)
    class_name = self.class.name
    method_name = caller_locations(1, 1)[0].label
    prefixed_message = "#{class_name}##{method_name} - #{message}"
    Rails.logger.add(level, prefixed_message)
  end
end