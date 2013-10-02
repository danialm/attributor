require_relative '../spec_helper'

describe Attributor::Integer do

  subject(:type) { Attributor::Integer }

  context '.example' do

    it 'returns an Integer' do
      type.example.should be_a(::Integer)
    end

    [[1,1], [1,5], [-2,-2], [-3,2]].each do |min, max|
      it "returns an Integer in the range [#{min},#{max}]" do
        20.times do
          value = type.example(:min => min, :max => max)
          value.should <= max
          value.should >= min
        end
      end
    end

    [[1,-1], [1,"5"], ["-2",4], [false, false], [true, true]].each do |min, max|
      it "raises for the invalid range [#{min.inspect}, #{max.inspect}]" do
        opts = {:min => min, :max => max}
        expect { type.example(opts) }.to raise_error("Invalid range: [#{min.inspect}, #{max.inspect}]")
      end
    end

  end

  context '.load' do
    let(:value) { nil }


    context 'for incoming integer values' do
      let(:value) { 1 }

      it 'returns the incoming value' do
        type.load(value).should be(value)
      end
    end

    context 'for incoming string values' do


      context 'that are valid integers' do
        let(:value) { '1024' }
        it 'decodes it if the string represents an integer' do
          type.load(value).should == 1024
        end
      end

      context 'that are not valid integers' do

        context 'with simple alphanumeric text' do
          let(:value) { 'not an integer' }

          it 'raises an error' do
            expect { type.load(value) }.to raise_error(/invalid value/)
          end
        end

        context 'with a floating point value' do
          let(:value) { '98.76' }
          it 'raises an error' do
            expect { type.load(value) }.to raise_error(/invalid value/)
          end
        end

      end

    end
  end
end

