require 'spec_helper'

describe 'consul::service' do
  let(:facts) {{ :architecture => 'x86_64' }}
  let(:title) { "my_service" }

  describe 'with no args' do
    let(:params) {{}}

    it {
      should contain_file("/etc/consul/service_my_service.json")
        .with_content(/"service" *: *{/)
        .with_content(/"id" *: *"my_service"/)
        .with_content(/"name" *: *"my_service"/)
    }
  end
  describe 'with service name' do
    let(:params) {{
      'service_name' => 'different_name',
    }}

    it {
      should contain_file("/etc/consul/service_my_service.json")
        .with_content(/"service" *: *{/)
        .with_content(/"id" *: *"my_service"/)
        .with_content(/"name" *: *"different_name"/)
    }
  end
  describe 'with service name and address' do
    let(:params) {{
      'service_name' => 'different_name',
      'address' => '127.0.0.1',
    }}

    it {
      should contain_file("/etc/consul/service_my_service.json")
        .with_content(/"service" *: *{/)
        .with_content(/"id" *: *"my_service"/)
        .with_content(/"name" *: *"different_name"/)
        .with_content(/"address" *: *"127.0.0.1"/)
    }
  end
  describe 'with script and interval' do
    let(:params) {{
      'checks' => [
        {
          'interval'    => '30s',
          'script' => 'true'
        }
      ]
    }}
    it {
      should contain_file("/etc/consul/service_my_service.json") \
        .with_content(/"checks" *: *\[/)
        .with_content(/"interval" *: *"30s"/)
        .with_content(/"script" *: *"true"/)
    }
  end
  describe 'with http and interval' do
    let(:params) {{
      'checks' => [
        {
          'interval'    => '30s',
          'http' => 'localhost'
        }
      ]
    }}
    it {
      should contain_file("/etc/consul/service_my_service.json") \
        .with_content(/"checks" *: *\[/)
        .with_content(/"interval" *: *"30s"/)
        .with_content(/"http" *: *"localhost"/)
    }
  end
  describe 'with ttl' do
    let(:params) {{
      'checks' => [
        {
          'ttl'    => '30s',
        }
      ]
    }}
    it {
      should contain_file("/etc/consul/service_my_service.json") \
        .with_content(/"checks" *: *\[/)
        .with_content(/"ttl" *: *"30s"/)
    }
  end
  describe 'with both ttl and interval' do
    let(:params) {{
      'checks' => [
        {
          'ttl'    => '30s',
          'interval'    => '30s',
        }
      ]
    }}
    it {
      expect { should raise_error(Puppet::Error) }
    }
  end
  describe 'with port' do
    let(:params) {{
      'checks' => [
        {
          'ttl'    => '30s',
        }
      ],
      'port' => 5,
    }}
    it { 
      should contain_file("/etc/consul/service_my_service.json")
        .with_content(/"port":5/)
    }
    it { 
      should_not contain_file("/etc/consul/service_my_service.json")
        .with_content(/"port":"5"/)
    }
  end
  describe 'with both ttl and script' do
    let(:params) {{
      'checks' => [
        {
          'ttl'    => '30s',
          'script' => 'true'
        }
      ]
    }}
    it {
      expect { should raise_error(Puppet::Error) }
    }
  end
  describe 'with interval but no script' do
    let(:params) {{
      'checks' => [
        {
          'interval'    => '30s',
        }
      ]
    }}
    it {
      expect { should raise_error(Puppet::Error) }
    }
  end
  describe 'with multiple checks script and http' do
    let(:params) {{
      'checks' => [
        {
          'interval'    => '30s',
          'script' => 'true'
        },
        {
          'interval'    => '10s',
          'http' => 'localhost'
        }
      ]
    }}
    it {
      should contain_file("/etc/consul/service_my_service.json") \
        .with_content(/"checks" *: *\[/)
        .with_content(/"interval" *: *"30s"/)
        .with_content(/"script" *: *"true"/)
        .with_content(/"interval" *: *"10s"/)
        .with_content(/"http" *: *"localhost"/)
    }
  end
  describe 'with multiple checks script and invalid http' do
    let(:params) {{
      'checks' => [
        {
          'interval'    => '30s',
          'script' => 'true'
        },
        {
          'http' => 'localhost'
        }
      ]
    }}
    it {
      expect { should raise_error(Puppet::Error) }
    }
  end
end
