# -*- coding: utf-8 -*-

require 'logger'
require 'logger/joint'
require 'syslog/logger'
require 'test/unit'

module Logger::Joint::Test
  class LoggerJointClassMethodTest < Test::Unit::TestCase
    data('logger'    => Logger.new(STDOUT),
         'syslog'    => Syslog::Logger.new,
         'duck_type' => Object.new.tap{|obj|
           def obj.level; end
           def obj.add(serverity, message); end
           def obj.debug(message); end
           def obj.info(message); end
           def obj.warn(message); end
           def obj.error(message); end
           def obj.fatal(message); end
           def obj.unknown(message); end
           def obj.debug?; end
           def obj.info?; end
           def obj.warn?; end
           def obj.error?; end
           def obj.fatal?; end
         })
    def test_respond_as_logger(logger)
      assert_equal(true, (Logger::Joint.respond_as_logger? logger))
    end

    data('object'    => Object.new,
         'duck_type' => Object.new.tap{|obj|
           # def obj.level; end
           def obj.add(serverity, message); end
           def obj.debug(message); end
           def obj.info(message); end
           def obj.warn(message); end
           def obj.error(message); end
           def obj.fatal(message); end
           def obj.unknown(message); end
           def obj.debug?; end
           def obj.info?; end
           def obj.warn?; end
           def obj.error?; end
           def obj.fatal?; end
         })
    def test_respond_as_logger_not(not_logger)
      assert_equal(false, (Logger::Joint.respond_as_logger? not_logger))
    end
  end
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
