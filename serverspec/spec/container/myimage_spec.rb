require 'net/http'
require 'uri'

require 'serverspec'
require 'docker'

describe 'myimage' do

  before(:all) do
    @container = Docker::Container.create(
      'Image' => 'myimage',
      'HostConfig' => {
        'AutoRemove' => true,
        'PortBindings' => {
          '80/tcp' => [{ 'HostPort' => '8080', 'HostIp' => '127.0.0.1' }]
        }
      }
    )
    @container.start()

    set :backend, :docker
    set :docker_container, @container.id
  end
  
  describe package('nginx') do
    it { should be_installed }
  end

  # Serverspec cannot filter processes and it can only find them by name.
  # Consequences:
  #  * Assertions can only be performed on the master process.
  #  * It is not possible to check whether workers run as www-data.
  #  * The :count is one bigger than expected because tini is included in the
  #    total due to its command containing 'nginx'.
  #
  # https://serverspec.org/resource_types.html#process
  describe process("nginx") do
    its(:user) { should eq "root" }
    its(:count) { should >= 2 }
    its(:args) { should match /-g daemon off;/ }
  end

  # Workaround to ensure nginx workers run as www-data.
  describe command('ps -U www-data -o command | uniq') do
    its(:stdout) { should contain('nginx: worker process').after('COMMAND') }
  end

  describe 'Exposed nginx' do
    it "should should say 'Welcome'" do
      page = Net::HTTP.get(URI.parse('http://127.0.0.1:8080/'))
      expect(page).to include("Welcome to nginx!")
    end
  end

  after(:all) do
    @container.stop()
  end
end
