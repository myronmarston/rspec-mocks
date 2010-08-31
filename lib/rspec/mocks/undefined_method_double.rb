module RSpec
  module Mocks
    class UndefinedMethodDouble
      class << self
        attr_writer :recording_enabled
        def recording_enabled?; @recording_enabled; end

        def record(method_double, invocation)
          return unless recording_enabled?
          method_double_hash[method_double].add_invocation invocation
        end

        def method_doubles
          method_double_hash.values
        end

        def clear
          @method_double_hash = nil
        end

        private

        def method_double_hash
          @method_double_hash ||= Hash.new { |h, k| h[k] = UndefinedMethodDouble.new(k) }
        end
      end

      def initialize(method_double)
        @method_double, @invocations = method_double, []
      end

      def object;      @method_double.object;      end
      def method_name; @method_double.method_name; end
      def invocations; @invocations.dup;           end

      def definitions
        @method_double.stubs.map { |s| s.expected_from } +
        @method_double.expectations.map { |s| s.expected_from }
      end

      def add_invocation(invocation)
        @invocations << invocation
      end
    end
  end
end

