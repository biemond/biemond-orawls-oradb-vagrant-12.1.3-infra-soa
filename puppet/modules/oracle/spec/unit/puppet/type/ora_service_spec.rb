#!/usr/bin/env rspec

require 'spec_helper'

oracle_service = Puppet::Type.type(:ora_service)

describe oracle_service do

  let(:attribute_class) {  @class.attrclass(attribute_name) }
  let(:attribute) {@resource.property(attribute_name)}


  before :each do
    @class = oracle_service
    @provider = double 'provider'
    allow(@provider).to receive(:name).and_return(:simple)
    class Puppet::Type::Oracle_service; def self.default_sid; 'TEST'; end; end
    allow(@class).to receive(:defaultprovider).and_return @provider
    @resource = @class.new({:name  => 'SCOTT'})
  end


  it 'should have :name and :service_name as its namevar' do
    expect(@class.key_attributes).to eq([:name, :service_name])
  end

  describe ':service_name' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :service_name,
      :result_identifier  => 'NAME',
      :raw_value          => 'PIF.infoplus.nl',
      :test_value         => 'PIF.INFOPLUS.NL'
    }
  end


end