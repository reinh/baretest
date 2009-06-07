#--
# Copyright 2009 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module Test

	# Run is the envorionment in which the suites and asserts are executed.
	# Prior to the execution, the Run instance extends itself with the
	# formatter given.
	# Your formatter can override:
	# * run_all
	# * run_suite
	# * run_test
	class Run
		# The toplevel suite.
		attr_reader :suite

		# The initialisation blocks of extenders
		attr_reader :inits

		# Run the passed suite.
		# Calls run_all with the toplevel suite as argument and a block that
		# calls run_suite with the yielded argument (which should be the toplevel
		# suite).
		def initialize(suite, opts={})
			@suite       = suite
			@inits       = []
			@options     = opts
			@format      = opts[:format] || 'cli'
			@count       = opts[:count] || Hash.new(0)
			@interactive = opts[:interactive]

			# Add the mock adapter and initialize it
			extend(Test.mock_adapter) if Test.mock_adapter

			# Extend with the output formatter
			require "test/run/#{@format}" if @format
			extend(Test.extender["test/run/#{@format}"]) if @format

			# Extend with irb dropout code
			require "test/irb_mode" if @interactive
			extend(Test::IRBMode) if @interactive

			# Initialize extenders
			@inits.each { |init| instance_eval(&init) }
		end

		# Hook initializers for extenders
		def init(&block)
			@inits << block
		end

		# Formatter callback.
		# Invoked once at the beginning.
		# Gets the toplevel suite as single argument.
		def run_all
			run_suite(@suite)
		end

		# Formatter callback.
		# Invoked once for every suite.
		# Gets the suite to run as single argument.
		# Runs all assertions and nested suites.
		def run_suite(suite)
			suite.tests.each do |test|
				run_test(test)
			end
			suite.suites.each do |suite|
				run_suite(suite)
			end
			@count[:suite] += 1
		end

		# Formatter callback.
		# Invoked once for every assertion.
		# Gets the assertion to run as single argument.
		def run_test(assertion)
			rv = assertion.execute
			@count[:test]            += 1
			@count[assertion.status] += 1
			rv
		end
	end
end