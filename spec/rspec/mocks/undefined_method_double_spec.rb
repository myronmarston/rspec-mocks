require 'spec_helper'

module RSpec
  module Mocks
    describe UndefinedMethodDouble do
      before(:each) do
        described_class.clear
        subject.should_not respond_to(:some_method)
      end

      def self.caller_string(line, method_name)
        "#{__FILE__}:#{line}:in `#{method_name}'"
      end

      def define_method_double
        subject.send(method_double_type, :some_method).any_number_of_times
      end
      DEFINITION_ONE = caller_string(__LINE__ - 2, :send)

      def define_method_double_again
        subject.send(method_double_type, :some_method).any_number_of_times
      end
      DEFINITION_TWO = caller_string(__LINE__ - 2, :send)

      def invoke
        subject.some_method
      end
      INVOCATION_ONE = caller_string(__LINE__ - 2, :invoke)

      def invoke_again
        subject.some_method
      end
      INVOCATION_TWO = caller_string(__LINE__ - 2, :invoke_again)

      def recorded(attribute)
        described_class.method_doubles.map { |md| md.send(attribute) }
      end

      context 'when recording is disabled' do
        before(:each) { described_class.recording_enabled = false }

        { :stub => 'stub', :should_receive => 'mock' }.each do |method_double_type, method_double_name|
          describe "a #{method_double_name} of a previously undefined method" do
            subject { "a string" }
            let(:method_double_type) { method_double_type }
            before(:each) { define_method_double }

            it "is not recorded" do
              invoke
              described_class.method_doubles.should be_empty
            end
          end
        end
      end

      context 'when recording is enabled' do
        before(:each) { described_class.recording_enabled = true }

        { :stub => 'stub', :should_receive => 'mock' }.each do |method_double_type, method_double_name|
          describe "a #{method_double_name} of a previously defined method" do
            let(:method_double_type) { method_double_type }
            subject { "a string" }

            it 'is not recorded' do
              def subject.some_method; end
              define_method_double
              invoke
              described_class.method_doubles.should be_empty
            end
          end

          describe "a #{method_double_name} of a previously undefined method" do
            let(:method_double_type) { method_double_type }
            before(:each) { define_method_double }
            subject { "a string" }

            context 'when the method double is defined and invoked once' do
              before(:each) { invoke }

              it "records the #{method_double_name}ed object" do
                recorded(:object).should == [subject]
              end

              it "records the #{method_double_name}ed method" do
                recorded(:method_name).should == [:some_method]
              end

              it "records the invocation" do
                recorded(:invocations).should == [[INVOCATION_ONE]]
              end

              it "records the definition" do
                recorded(:definitions).should == [[DEFINITION_ONE]]
              end

              %w[mock stub double].each do |mock_object_type|
                context "for a pure #{mock_object_type} object" do
                  subject { send(mock_object_type) }

                  it "is not recorded" do
                    described_class.method_doubles.should be_empty
                  end
                end
              end
            end

            context 'when the method double is defined once and invoked twice' do
              before(:each) { invoke; invoke_again }

              it "records only a single #{method_double_name}ed object" do
                recorded(:object).should == [subject]
              end

              it "records only a single #{method_double_name}ed method" do
                recorded(:method_name).should == [:some_method]
              end

              it "records only a single definition" do
                recorded(:definitions).should == [[DEFINITION_ONE]]
              end

              it "records each invocation" do
                recorded(:invocations).should == [[INVOCATION_ONE, INVOCATION_TWO]]
              end
            end

            context 'when the method double is defined twice and invoked once' do
              before(:each) { invoke; define_method_double_again }

              it "records only a single #{method_double_name}ed object" do
                recorded(:object).should == [subject]
              end

              it "records only a single #{method_double_name}ed method" do
                recorded(:method_name).should == [:some_method]
              end

              it "records each definition" do
                recorded(:definitions).flatten.should =~ [DEFINITION_ONE, DEFINITION_TWO]
              end

              it "records only a single invocation" do
                recorded(:invocations).should == [[INVOCATION_ONE]]
              end
            end

            it "is not recorded when the method is defined before the invocation" do
              def subject.some_method; end
              invoke
              described_class.method_doubles.should be_empty
            end
          end
        end
      end
    end
  end
end
