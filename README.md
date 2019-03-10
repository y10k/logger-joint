Logger::Joint
=============

logger-joint is a utility to joint multiple loggers into one logger.
Logs can be output to multiple output destinations at the same time
with one jointed logger.

Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'logger-joint'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install logger-joint

Usage
-----

Using logger-joint is simple.
Create an instance of `Logger::Joint` that joints two loggers.
When a log is output to an instance of `Logger::Joint`, that log is
output to each logger.

```ruby
irb(main):001:0> require 'stringio'
=> false
irb(main):002:0> out1 = StringIO.new
=> #<StringIO:...>
irb(main):003:0> out2 = StringIO.new
=> #<StringIO:...>
irb(main):004:0> require 'logger'
=> true
irb(main):005:0> logger1 = Logger.new(out1)
=> #<Logger:...>
irb(main):006:0> logger2 = Logger.new(out2)
=> #<Logger:...>
irb(main):007:0> require 'logger/joint'
=> true
irb(main):008:0> joint_logger = Logger::Joint.new(logger1, logger2)
=> #<Logger::Joint:... @primary=#<Logger:...>, @secondary=#<Logger:...>>
irb(main):009:0> joint_logger.info('HALO')
=> true
irb(main):010:0> out1.string
=> "I, [2019-03-10T15:46:37.815496 #15407]  INFO -- : HALO\n"
irb(main):011:0> out2.string
=> "I, [2019-03-10T15:46:37.815669 #15407]  INFO -- : HALO\n"
```

An instance of `Logger::Joint` can be jointed with another logger.

```ruby
irb(main):012:0> out3 = StringIO.new
=> #<StringIO:...>
irb(main):013:0> logger3 = Logger.new(out3)
=> #<Logger:...>
irb(main):014:0> next_joint_logger = joint_logger + logger3
=> #<Logger::Joint:... @primary=#<Logger::Joint:... @primary=#<Logger:...>, @secondary=#<Logger:...>>, @secondary=#<Logger:...>>
irb(main):015:0> next_joint_logger.info('foo')
=> true
irb(main):016:0> out1.string
=> "I, [2019-03-10T15:46:37.815496 #15407]  INFO -- : HALO\nI, [2019-03-10T15:56:35.320060 #15416]  INFO -- : foo\n"
irb(main):017:0> out2.string
=> "I, [2019-03-10T15:46:37.815669 #15407]  INFO -- : HALO\nI, [2019-03-10T15:56:35.320521 #15416]  INFO -- : foo\n"
irb(main):018:0> out3.string
=> "I, [2019-03-10T15:56:35.320643 #15416]  INFO -- : foo\n"
```

By using refinement of `Logger::JointPlus` it is possible to extend
the logger object and joint the logger objects to create a
`Logger::Joint` instance.

```ruby
irb(main):025:0> Logger.new(StringIO.new) + Logger.new(StringIO.new)
Traceback (most recent call last):
        4: from /usr/local/bin/irb:23:in `<main>'
        3: from /usr/local/bin/irb:23:in `load'
        2: from /usr/local/lib/ruby/gems/2.6.0/gems/irb-1.0.0/exe/irb:11:in `<top (required)>'
        1: from (irb):25
NoMethodError (undefined method `+' for #<Logger:0x00007ffff42da338>)
irb(main):026:0> module RefinementExample
irb(main):027:1>   using Logger::JointPlus
irb(main):028:1>   Logger.new(StringIO.new) + Logger.new(StringIO.new)
irb(main):029:1> end
=> #<Logger::Joint:... @primary=#<Logger:...>, @secondary=#<Logger:...>>
```

By applying monkey patch with `require 'logger/joint_plus'` it is
possible to extend the logger object globally and joint the logger
objects to create a `Logger::Joint` instance.

```ruby
irb(main):030:0> require 'logger/joint_plus'
=> true
irb(main):031:0> Logger.new(StringIO.new) + Logger.new(StringIO.new)
=> #<Logger::Joint:... @primary=#<Logger:...>, @secondary=#<Logger:...>>
```

Contributing
------------

Bug reports and pull requests are welcome on GitHub at <https://github.com/y10k/logger-joint>.

License
-------

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
