require 'spec_helper'

# describe 'oracle' do
#   context 'supported operating systems' do
#     ['Debian', 'RedHat'].each do |osfamily|
#       describe "oracle class without any parameters on #{osfamily}" do
#         let(:params) {{ }}
#         let(:facts) {{
#           :osfamily => osfamily,
#         }}

#         it { should compile.with_all_deps }

#         it { should contain_class('oracle::params') }
#         it { should contain_class('oracle::install').that_comes_before('oracle::config') }
#         it { should contain_class('oracle::config') }
#         it { should contain_class('oracle::service').that_subscribes_to('oracle::config') }

#         it { should contain_service('oracle') }
#         it { should contain_package('oracle').with_ensure('present') }
#       end
#     end
#   end

#   context 'unsupported operating system' do
#     describe 'oracle class without any parameters on Solaris/Nexenta' do
#       let(:facts) {{
#         :osfamily        => 'Solaris',
#         :operatingsystem => 'Nexenta',
#       }}

#       it { expect { should contain_package('oracle') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
#     end
#   end
# end
