# -*- coding: utf-8 -*-

require 'logger'
require 'logger/joint'

Logger.class_eval{
  include Logger::Joint::PlusMethod
}

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
