require 'serverspec'

# Required by serverspec
set :backend, :exec

describe process("mig-api") do

  its(:user) { should eq "_mig" }

  it "is listening on port 1664" do
    expect(port(1664)).to be_listening
  end

end

describe command('curl http://127.0.0.1/api/v1/heartbeat') do
  its(:stdout) { should match /gatorz say hi/ }
end
describe command('curl http://127.0.0.1/api/v1/dashboard') do
  its(:stdout) { should match /"version":"1.0"/ }
end

### Note: non-deterministic order creation...
### Note2: require connection to postgresql
#describe command('curl http://127.0.0.1/api/v1/investigator?investigatorid=1') do
#  its(:stdout) { should match /scheduler/ }
##  its(:stdout) { should match /Dupont/ }
#end
#describe command('curl http://127.0.0.1/api/v1/investigator?investigatorid=2') do
#  its(:stdout) { should match /Dupont/ }
##  its(:stdout) { should match /dupond/ }
#end
#describe command('curl http://127.0.0.1/api/v1/investigator?investigatorid=3') do
#  its(:stdout) { should match /dupond/ }
##  its(:stdout) { should match /scheduler/ }
#end

