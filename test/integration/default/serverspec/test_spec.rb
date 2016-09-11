require 'serverspec'

# Required by serverspec
set :backend, :exec

describe command('hostname') do
  its(:stdout) { should match /test/ }
end
describe command('uname -a') do
  its(:stdout) { should match /test/ }
end

