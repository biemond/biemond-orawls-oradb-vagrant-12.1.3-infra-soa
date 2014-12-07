shared_examples "an easy_type attribute" do |test_attributes|

  attribute_name      = test_attributes[:attribute]
  result_identifier   = test_attributes[:result_identifier]
  test_value          = test_attributes[:test_value]
  apply_text          = test_attributes[:apply_text]
  create_text         = test_attributes[:create_text]
  modify_text         = test_attributes[:modify_text]
  raw_value           = test_attributes[:raw_value]
  test_value_string   = test_attributes[:test_value_string]
  raw_resource        = test_attributes[:raw_resource]
  invalid_raw_resource= test_attributes[:invalid_raw_resource]

  test_value_string    ||= test_value.to_s

  raw_resource = raw_resource ?
    InstancesResults[raw_resource.to_a] :
    InstancesResults[result_identifier,raw_value]
  invalid_raw_resource = invalid_raw_resource ?
    InstancesResults[invalid_raw_resource.to_a] :
    InstancesResults["NO_#{result_identifier}",raw_value]


  let(:attribute_class) {  @class.attrclass(attribute_name) }
  let(:attribute) { @resource.property(attribute_name) || @resource.parameter(attribute_name)}


  describe attribute_name do

    if result_identifier
      context "when geting data from the system" do

        it "should raise an error when #{result_identifier} not found in raw_results" do
          expect{attribute_class.translate_to_resource(invalid_raw_resource)}.to raise_error(RuntimeError)
        end

        it "should pick its value from element #{result_identifier}"  do
          expect(attribute_class.translate_to_resource(raw_resource)).to eq test_value
        end

        it "should translate element #{raw_value} to #{test_value}"  do
          expect(attribute_class.translate_to_resource(raw_resource)).to eq test_value
        end

      end
    end

    if apply_text
      context "on applying the resource" do

        before do
          @resource[attribute_name] = test_value
        end

        it "returns #{apply_text}" do
          expect(attribute.on_apply(nil)).to eq apply_text
        end

      end
    end

    if create_text
      context "on creating the resource" do

        before do
          @resource[attribute_name] = test_value
        end

        it "returns #{create_text}" do
          expect(attribute.on_create(nil)).to eq create_text
        end

      end
    end

    if modify_text
      context "on modifying the resource" do

        before do
          @resource[attribute_name] = test_value
        end

        it "returns #{modify_text}" do
          expect(attribute.on_modify(nil)).to eq modify_text
        end
      end
    end


  end
end