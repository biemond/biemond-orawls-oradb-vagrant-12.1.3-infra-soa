#!/usr/bin/env rspec

require 'spec_helper'

oracle_user = Puppet::Type.type(:oracle_user)

describe oracle_user do

  let(:attribute_class) {  @class.attrclass(attribute_name) }
  let(:attribute) {@resource.property(attribute_name)}


  before :each do
    @class = oracle_user
    @provider = double 'provider'
    allow(@provider).to receive(:name).and_return(:simple)
    allow(@class).to receive(:defaultprovider).and_return @provider
    class Puppet::Type::Oracle_user; def self.default_sid; 'TEST'; end; end
    @resource = @class.new({:name  => 'SCOTT'})
  end


  it 'should have :name and :username, as its namevar' do
    expect( @class.key_attributes).to eq([:name, :username])
  end

  describe ':name' do

    let(:attribute_class) { @class.attrclass(:username) }

    it 'should pick its value from element USERNAME' do
      raw_resource = InstancesResults['USERNAME','SCOTT']
      expect(attribute_class.translate_to_resource(raw_resource)).to eq 'SCOTT'
    end

    it 'should raise an error when name not found in raw_results' do
      raw_resource = InstancesResults['NO_USERNAME','SCOTT','SID','TEST']
      expect{attribute_class.translate_to_resource(raw_resource)}.to raise_error(RuntimeError)
    end

    it 'should accept a name' do
      @resource[:username] = 'SCOTT'
      expect(@resource[:username]).to eq 'SCOTT'
    end

    it 'should munge to uppercase' do
      @resource[:username] = 'scott'
      expect(@resource[:username]).to eq 'SCOTT'
    end

    it 'should not accept a name with whitespace' do
      expect { @resource[:username] = 'a a' }.to raise_error(Puppet::Error)
    end

    it 'should not accept an empty name' do
      expect { @resource[:username] = '' }.to raise_error(Puppet::Error)
    end
  end

  describe ':user_id' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :user_id,
      :result_identifier  => 'USER_ID',
      :raw_value          => 500,
      :test_value         => 500,
      :apply_text         => 'set user_id = 500'
    }
  end

  describe ':default_tablespace' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :default_tablespace,
      :result_identifier  => 'DEFAULT_TABLESPACE',
      :raw_value          => 'USERS',
      :test_value         => 'USERS',
      :apply_text         => "default tablespace USERS"
    }
  end

  describe ':temporary_tablespace' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :temporary_tablespace,
      :result_identifier  => 'TEMPORARY_TABLESPACE',
      :raw_value          => 'TEMP',
      :test_value         => 'TEMP',
      :apply_text         => "temporary tablespace TEMP"
    }
  end

  describe ':password' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :password,
      :result_identifier  => 'PASSWORD',
      :raw_value          => 'password',
      :test_value         => 'password'
    }
  end


  describe ':quotas' do

    it "must be specced and tested"

  end

  describe ':grants' do

    it "must be specced and tested"

  end


end