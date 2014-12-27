shared_examples "an ensurable resource" do |attributes|

  resource_name     = attributes[:resource_name]
  present_manifest  = attributes[:present_manifest]
  absent_manifest   = attributes[:absent_manifest]
  change_manifest   = attributes[:change_manifest]
  debug             = attributes[:debug] || false

  if present_manifest
    describe "ensure => 'present'" do

      context "#{resource_name} doesn't exist" do
        it "should create the #{resource_name}" do
          apply_manifest(present_manifest, :expect_changes => true, :debug => debug)
        end
      end

      context "#{resource_name} exist" do
        it 'should do nothing' do
          apply_manifest(present_manifest, :catch_changes => true, :debug => debug)
        end
      end
    end

    if change_manifest
      describe "Changing a value" do

        it 'should change the value' do
          apply_manifest(change_manifest, :expect_changes => true, :debug => debug)
        end
      end
    end

    if absent_manifest
      describe "ensure => 'absent'" do

        context "#{resource_name} exist" do
          it "should remove the #{resource_name}" do
            apply_manifest(absent_manifest, :expect_changes => true, :debug => debug)
          end
        end

        context "#{resource_name} doesn't exist" do
          it 'should do nothing ' do
            apply_manifest(absent_manifest, :catch_changes => true, :debug => debug)
          end
        end
      end
    end
  end
end
