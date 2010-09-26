require 'spec_helper'
require 'yaml'

module RSpec
  module Mocks
    class SerializableStruct < Struct.new(:foo, :bar); end

    describe "Serialization" do
      subject { SerializableStruct.new(7, "something") }

      def set_stub
        subject.stub(:bazz => 5)
      end

      it 'serializes to yaml the same with and without stubbing, using #to_yaml' do
        expect { set_stub }.to_not change { subject.to_yaml }
      end

      it 'serializes to yaml the same with and without stubbing, using YAML.dump' do
        expect { set_stub }.to_not change { YAML.dump(subject) }
      end

      it 'marshals the same with and without stubbing' do
        pending("not sure how to fix this yet") do
          expect { set_stub }.to_not change { Marshal.dump(subject) }
        end
      end
    end
  end
end
