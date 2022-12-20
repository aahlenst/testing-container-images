require 'serverspec'

# Test needs to be in a separate folder because each folder is run in a separate
# process. Otherwise, Serverspec needs to be reset which is harder than
# necessary.
describe 'myimage configuration' do

  before(:all) do
    set :backend, :exec
  end

  describe docker_image('myimage') do
    it { should exist }
    its(['Config.ExposedPorts']) { should have_attributes(size: 1) }
    its(['Config.ExposedPorts']) { should include /80\/tcp/ }
  end
end