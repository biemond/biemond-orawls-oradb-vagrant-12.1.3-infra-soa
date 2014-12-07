#!/usr/bin/env rspec

require 'spec_helper'

role = Puppet::Type.type(:role)

describe role do

  let(:attribute_class) {  @class.attrclass(attribute_name) }
  let(:attribute) {@resource.property(attribute_name)}

  before :each do
    @class = role
    @provider = double 'provider'
    allow(@provider).to receive(:name).and_return(:simple)
    allow(@class).to receive(:defaultprovider).and_return @provider
    class Puppet::Type::Role; def self.default_sid; 'TEST'; end; end
    @resource = @class.new({:name  => 'CONNECT'})
  end


  it 'should have :name  and :role_name as its namevar' do
    expect(@class.key_attributes).to eq ([:name, :role_name])
  end

  describe ':role_name' do

    let(:attribute_class) { @class.attrclass(:role_name) }

    it 'should pick its value from element ROLE' do
      raw_resource = InstancesResults['ROLE','MY_ROLE']
      expect(attribute_class.translate_to_resource(raw_resource)).to eq 'MY_ROLE'
    end

    it 'should raise an error when name not found in raw_results' do
      raw_resource = InstancesResults['NO_ROLE','MY_NAME']
      expect{attribute_class.translate_to_resource(raw_resource)}.to raise_error(RuntimeError)
    end

    it 'should accept a name' do
      @resource[:role_name] = 'CONNECT'
      expect(@resource[:role_name]).to eq 'CONNECT'
    end

    it 'should munge to uppercase' do
      @resource[:role_name] = 'connect'
      expect(@resource[:role_name]).to eq 'CONNECT'
    end
  end


  describe ':password' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :password,
      :raw_value          => 'hhhqhs',
      :test_value         => '',
      :apply_text         =>  "identified by "
    }
  end

end