require 'spec_helper'


describe port(8080) do
  it { should be_listening }
end

describe command('/sbin/chkconfig | grep galaxy') do
  its(:stdout) { should include('galaxy') }
end

