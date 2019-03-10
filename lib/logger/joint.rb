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

  def initialize(primary_logger, secondary_logger)
    self.class.respond_as_logger? primary_logger or raise TypeError, 'primary is not a logger.'
    self.class.respond_as_logger? secondary_logger or raise TypeError, 'secondary is not a logger.'
    @primary = primary_logger
    @secondary = secondary_logger
  end

  def level
    [ @primary, @secondary ].map(&:level).min
  end

  def apply_method(name, *args, &block)
    r = @primary.__send__(name, *args, &block)
    @secondary.__send__(name, *args, &block)
    r
  end
  private :apply_method

  def add(*args, &block)
    apply_method(:add, *args, &block)
  end

  def debug(*args, &block)
    apply_method(:debug, *args, &block)
  end

  def info(*args, &block)
    apply_method(:info, *args, &block)
  end

  def warn(*args, &block)
    apply_method(:warn, *args, &block)
  end

  def error(*args, &block)
    apply_method(:error, *args, &block)
  end

  def fatal(*args, &block)
    apply_method(:fatal, *args, &block)
  end

  def unknown(*args, &block)
    apply_method(:unknown, *args, &block)
  end

  def apply_level_predicate(name)
    @primary.__send__(name) || @secondary.__send__(name)
  end
  private :apply_level_predicate

  def debug?
    apply_level_predicate(:debug?)
  end

  def info?
    apply_level_predicate(:info?)
  end

  def warn?
    apply_level_predicate(:warn?)
  end

  def error?
    apply_level_predicate(:error?)
  end

  def fatal?
    apply_level_predicate(:fatal?)
  end

  def joint(other_logger)
    Logger::Joint.new(self, other_logger)
  end

  alias + joint
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
