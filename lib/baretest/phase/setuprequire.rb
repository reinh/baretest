#--
# Copyright 2009-2010 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



require 'baretest/phase/setup'
require 'baretest/phase/failure'



module BareTest
  class Phase
    class SetupRequire < Setup
      def initialize(path)
        super() do
          begin
            require path
          rescue LoadError => load_error
            if load_error.message[-path.length,path.length] == path then
              raise BareTest::Phase::Failure.new(@__phase__, "Missing source file: #{path}")
            else
              raise
            end
          end
        end
      end

      def inspect
        sprintf "#<%s>", self.class
      end
    end
  end
end