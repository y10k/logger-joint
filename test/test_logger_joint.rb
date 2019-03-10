# -*- coding: utf-8 -*-

require 'logger'
require 'logger/joint'
require 'stringio'
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

  class LoggerJointTest < Test::Unit::TestCase
    def setup
      @primary_output = StringIO.new
      @secondary_output = StringIO.new
      @primary_logger = Logger.new(@primary_output)
      @secondary_logger = Logger.new(@secondary_output)
    end

    def make_joint_logger(primary_level, secondary_level)
      @primary_logger.level = primary_level
      @secondary_logger.level = secondary_level
      @joint_logger = Logger::Joint.new(@primary_logger, @secondary_logger)
    end
    private :make_joint_logger

    def test_logger_joint_as_logger
      make_joint_logger(:info, :info)
      assert_equal(true, (Logger::Joint.respond_as_logger? @joint_logger))
    end

    def test_not_logger_error
      error = assert_raise(TypeError) { Logger::Joint.new(Object.new, @secondary_logger) }
      assert_equal('primary is not a logger.', error.message)

      error = assert_raise(TypeError) { Logger::Joint.new(@primary_logger, Object.new) }
      assert_equal('secondary is not a logger.', error.message)
    end

    data('primary_debug_secondary_debug'     => [ Logger::DEBUG,   :debug,   :debug   ],
         'primary_debug_secondary_info'      => [ Logger::DEBUG,   :debug,   :info    ],
         'primary_debug_secondary_warn'      => [ Logger::DEBUG,   :debug,   :warn    ],
         'primary_debug_secondary_error'     => [ Logger::DEBUG,   :debug,   :error   ],
         'primary_debug_secondary_fatal'     => [ Logger::DEBUG,   :debug,   :fatal   ],
         'primary_debug_secondary_unknown'   => [ Logger::DEBUG,   :debug,   :unknown ],
         'primary_info_secondary_info'       => [ Logger::INFO,    :info,    :info    ],
         'primary_info_secondary_warn'       => [ Logger::INFO,    :info,    :warn    ],
         'primary_info_secondary_error'      => [ Logger::INFO,    :info,    :error   ],
         'primary_info_secondary_fatal'      => [ Logger::INFO,    :info,    :fatal   ],
         'primary_info_secondary_unknown'    => [ Logger::INFO,    :info,    :unknown ],
         'primary_warn_secondary_warn'       => [ Logger::WARN,    :warn,    :warn    ],
         'primary_warn_secondary_error'      => [ Logger::WARN,    :warn,    :error   ],
         'primary_warn_secondary_fatal'      => [ Logger::WARN,    :warn,    :fatal   ],
         'primary_warn_secondary_unknown'    => [ Logger::WARN,    :warn,    :unknown ],
         'primary_error_secondary_error'     => [ Logger::ERROR,   :error,   :error   ],
         'primary_error_secondary_fatal'     => [ Logger::ERROR,   :error,   :fatal   ],
         'primary_error_secondary_unknown'   => [ Logger::ERROR,   :error,   :unknown ],
         'primary_fatal_secondary_fatal'     => [ Logger::FATAL,   :fatal,   :fatal   ],
         'primary_fatal_secondary_unknown'   => [ Logger::FATAL,   :fatal,   :unknown ],
         'primary_unknown_secondary_unknown' => [ Logger::UNKNOWN, :unknown, :unknown ],
         'primary_info_secondary_debug'      => [ Logger::DEBUG,   :info,    :debug   ],
         'primary_error_secondary_debug'     => [ Logger::DEBUG,   :error,   :debug   ],
         'primary_fatal_secondary_debug'     => [ Logger::DEBUG,   :fatal,   :debug   ],
         'primary_unknown_secondary_debug'   => [ Logger::DEBUG,   :unknown, :debug   ],
         'primary_error_secondary_info'      => [ Logger::INFO,    :error,   :info    ],
         'primary_fatal_secondary_info'      => [ Logger::INFO,    :fatal,   :info    ],
         'primary_unknown_secondary_info'    => [ Logger::INFO,    :unknown, :info    ],
         'primary_fatal_secondary_error'     => [ Logger::ERROR,   :fatal,   :error   ],
         'primary_unknown_secondary_error'   => [ Logger::ERROR,   :unknown, :error   ],
         'primary_unknown_secondary_fatal'   => [ Logger::FATAL,   :unknown, :fatal   ])
    def test_level(data)
      expected_level, primary_level, secondary_level = data
      make_joint_logger(primary_level, secondary_level)
      assert_equal(expected_level, @joint_logger.level)
    end

    data('debug'   => [ Logger::DEBUG,   'DEBUG' ],
         'info'    => [ Logger::INFO,    'INFO'  ],
         'warn'    => [ Logger::WARN,    'WARN'  ],
         'error'   => [ Logger::ERROR,   'ERROR' ],
         'fatal'   => [ Logger::FATAL,   'FATAL' ],
         'unknown' => [ Logger::UNKNOWN, 'ANY'   ])
    def test_add(data)
      level, expected_keyword = data
      make_joint_logger(level, level)

      @joint_logger.add(level, 'foo', 'TEST')
      assert_match(/ #{expected_keyword} /, @primary_output.string)
      assert_match(/ TEST: foo$/, @primary_output.string)
      assert_match(/ #{expected_keyword} /, @secondary_output.string)
      assert_match(/ TEST: foo$/, @secondary_output.string)

      @joint_logger.add(level) { 'bar' }
      assert_match(/: bar$/, @primary_output.string)
      assert_match(/: bar$/, @secondary_output.string)
    end

    data('debug'   => [ :debug,   'DEBUG' ],
         'info'    => [ :info,    'INFO'  ],
         'warn'    => [ :warn,    'WARN'  ],
         'error'   => [ :error,   'ERROR' ],
         'fatal'   => [ :fatal,   'FATAL' ],
         'unknown' => [ :unknown, 'ANY'   ])
    def test_log(data)
      log_method_name, expected_keyword = data
      make_joint_logger(log_method_name, log_method_name)

      @joint_logger.__send__(log_method_name, 'foo')
      assert_match(/ #{expected_keyword} /, @primary_output.string)
      assert_match(/: foo$/, @primary_output.string)
      assert_match(/ #{expected_keyword} /, @secondary_output.string)
      assert_match(/: foo$/, @secondary_output.string)
    end

    data('primary_debug_secondary_debug'       => [ true,  true,  true,  :debug, :debug ],
         'primary_debug_secondary_no_debug'    => [ true,  true,  false, :debug, :info  ],
         'primary_no_debug_secondary_debug'    => [ true,  false, true,  :info,  :debug ],
         'primary_no_debug_secondary_no_debug' => [ false, false, false, :info,  :info  ])
    def test_debug?(data)
      expected_joint_debug, expected_primary_debug, expected_secondary_debug, primary_level, secondary_level = data
      make_joint_logger(primary_level, secondary_level)

      assert_equal(expected_primary_debug, @primary_logger.debug?)
      assert_equal(expected_secondary_debug, @secondary_logger.debug?)
      assert_equal(expected_joint_debug, @joint_logger.debug?)
    end

    data('primary_info_secondary_info'       => [ true,  true,  true,  :info,  :info  ],
         'primary_info_secondary_no_info'    => [ true,  true,  false, :info,  :error ],
         'primary_no_info_secondary_info'    => [ true,  false, true,  :error, :info  ],
         'primary_no_info_secondary_no_info' => [ false, false, false, :error, :error ])
    def test_info?(data)
      expected_joint_info, expected_primary_info, expected_secondary_info, primary_level, secondary_level = data
      make_joint_logger(primary_level, secondary_level)

      assert_equal(expected_primary_info, @primary_logger.info?)
      assert_equal(expected_secondary_info, @secondary_logger.info?)
      assert_equal(expected_joint_info, @joint_logger.info?)
    end

    data('primary_warn_secondary_warn'       => [ true,  true,  true,  :warn,  :warn  ],
         'primary_warn_secondary_no_warn'    => [ true,  true,  false, :warn,  :error ],
         'primary_no_warn_secondary_warn'    => [ true,  false, true,  :error, :warn  ],
         'primary_no_warn_secondary_no_warn' => [ false, false, false, :error, :error ])
    def test_warn?(data)
      expected_joint_warn, expected_primary_warn, expected_secondary_warn, primary_level, secondary_level = data
      make_joint_logger(primary_level, secondary_level)

      assert_equal(expected_primary_warn, @primary_logger.warn?)
      assert_equal(expected_secondary_warn, @secondary_logger.warn?)
      assert_equal(expected_joint_warn, @joint_logger.warn?)
    end

    data('primary_error_secondary_error'       => [ true,  true,  true,  :error, :error ],
         'primary_error_secondary_no_error'    => [ true,  true,  false, :error, :fatal ],
         'primary_no_error_secondary_error'    => [ true,  false, true,  :fatal, :error ],
         'primary_no_error_secondary_no_error' => [ false, false, false, :fatal, :fatal ])
    def test_error?(data)
      expected_joint_error, expected_primary_error, expected_secondary_error, primary_level, secondary_level = data
      make_joint_logger(primary_level, secondary_level)

      assert_equal(expected_primary_error, @primary_logger.error?)
      assert_equal(expected_secondary_error, @secondary_logger.error?)
      assert_equal(expected_joint_error, @joint_logger.error?)
    end

    data('primary_fatal_secondary_fatal'       => [ true,  true,  true,  :fatal,   :fatal   ],
         'primary_fatal_secondary_no_fatal'    => [ true,  true,  false, :fatal,   :unknown ],
         'primary_no_fatal_secondary_fatal'    => [ true,  false, true,  :unknown, :fatal   ],
         'primary_no_fatal_secondary_no_fatal' => [ false, false, false, :unknown, :unknown ])
    def test_fatal?(data)
      expected_joint_fatal, expected_primary_fatal, expected_secondary_fatal, primary_level, secondary_level = data
      make_joint_logger(primary_level, secondary_level)

      assert_equal(expected_primary_fatal, @primary_logger.fatal?)
      assert_equal(expected_secondary_fatal, @secondary_logger.fatal?)
      assert_equal(expected_joint_fatal, @joint_logger.fatal?)
    end

    def test_joint
      make_joint_logger(:info, :info)

      third_output = StringIO.new
      third_logger = Logger.new(third_output)
      third_logger.level = :info

      next_joint_logger = @joint_logger.joint(third_logger)
      assert_instance_of(Logger::Joint, next_joint_logger)

      next_joint_logger.info('foo')
      assert_match(/: foo$/, @primary_output.string)
      assert_match(/: foo$/, @secondary_output.string)
      assert_match(/: foo$/, third_output.string)
    end

    def test_joint_plus
      make_joint_logger(:info, :info)

      third_output = StringIO.new
      third_logger = Logger.new(third_output)
      third_logger.level = :info

      next_joint_logger = @joint_logger + third_logger
      assert_instance_of(Logger::Joint, next_joint_logger)

      next_joint_logger.info('foo')
      assert_match(/: foo$/, @primary_output.string)
      assert_match(/: foo$/, @secondary_output.string)
      assert_match(/: foo$/, third_output.string)
    end

    def test_joint_not_logger_error
      make_joint_logger(:info, :info)
      error = assert_raise(TypeError) { @joint_logger.joint(Object.new) }
      assert_equal('secondary is not a logger.', error.message)
    end
  end
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
