# -*- coding: utf-8 -*-

require 'logger'
require 'logger/joint/version'

class Logger::Joint
  # methods common to Logger and Syslog::Logger are need for.
  def self.respond_as_logger?(object)
    [ :level,
      :add,
      :debug,
      :info,
      :warn,
      :error,
      :fatal,
      :unknown,
      :debug?,
      :info?,
      :warn?,
      :error?,
      :fatal?
    ].all?{|name| object.respond_to? name }
  end
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
