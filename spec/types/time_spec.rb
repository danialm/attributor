require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Attributor::Time do
  subject(:type) { Attributor::Time }

  it 'it is not Dumpable' do
    expect(type.new.is_a?(Attributor::Dumpable)).not_to be(true)
  end

  context '.native_type' do
    its(:native_type) { should be(::Time) }
  end

  context '.example' do
    its(:example) { should be_a(::Time) }
  end

  context '.dump' do
    let(:example) { type.example }
    subject(:value) { type.dump(example) }
    it 'is formatted correctly' do
      expect(value).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+-]\d{2}:\d{2}/)
    end
    context 'nil values' do
      it 'should be nil' do
        expect(type.dump(nil)).to be_nil
      end
    end
  end

  context '.load' do
    it 'returns nil for nil' do
      expect(type.load(nil)).to be(nil)
    end

    context 'for incoming objects' do
      it 'returns correct Time for DateTime objects' do
        object = Time.now
        loaded = type.load(object)
        expect(loaded).to be_a(::Time)
        expect(loaded.to_time).to eq object
      end

      it 'returns correct Time for DateTime objects' do
        object = DateTime.now
        loaded = type.load(object)
        expect(loaded).to be_a(::Time)
        expect(loaded).to eq(object.to_time)
      end
    end

    context 'for incoming strings' do
      [
        '2001-02-03T04:05:06+07:00',
        'Sat, 03 Feb 2001 04:05:06 GMT',
        '20010203T040506+0700',
        '2001-W05-6T04:05:06+07:00',
        'H13.02.03T04:05:06+07:00',
        'Sat, 3 Feb 2001 04:05:06 +0700',
        '2013/08/23 00:39:55 +0000',
        '2007-10-19T04:11:33Z',
        '2001-02-03T04:05:06+07:00.123456', # custom format with microseconds
      ].each do |value|
        it "returns correct Time for #{value.inspect}" do
          expect(type.load(value)).to eq Time.parse(value)
        end
      end

      [
        '2013/08/33 00:39:55 +0000',
        '2007-10-33T04:11:33Z',
        '2001-02-33T04:05:06+07:00.123456', # custom format with microseconds
      ].each do |value|
        it "raises Attributor::AttributorException for #{value.inspect}" do
          expect do
            type.load(value)
          end.to raise_error(Attributor::DeserializationError, /Error deserializing a String using Time/)
        end
      end

      [
        '',
        'foobar'
      ].each do |value|
        it "raises Attributor::AttributorException for #{value.inspect}" do
          expect do
            type.load(value)
          end.to raise_error(Attributor::DeserializationError, /Error deserializing a String using Time/)
        end
      end
    end
  end
  context '.as_json_schema' do
    subject(:js){ type.as_json_schema }
    it 'adds the right attributes' do
      expect(js.keys).to include(:type, :'x-type_name')
      expect(js[:type]).to eq(:string)
      expect(js[:format]).to eq(:'time')
      expect(js[:'x-type_name']).to eq('Time')
    end
  end  
end
