# require 'spec_helper_acceptance'

# describe 'tablespace' do

#   context 'with size and datafile' do
#     # Using puppet_apply as a helper
#     it 'should work with no errors' do
#       pp = <<-EOS
#       tablespace {'test':
#         size      => 10M,
#         datafile  => 'test.dbf'
#       }
#       EOS

#       # Run it twice and test for idempotency
#       expect(apply_manifest(pp,:catch_failures => true).exit_code).to_not eq(1)
#       expect(apply_manifest(pp,:catch_failures => true).exit_code).to eq(0)
#     end

#     # describe package('oracle') do
#     #   it { should be_installed }
#     # end

#     # describe service('oracle') do
#     #   it { should be_enabled }
#     #   it { should be_running }
#     # end
#   end
# end
