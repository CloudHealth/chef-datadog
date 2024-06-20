# Copyright:: 2011-Present, Datadog
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

describe 'datadog::kafka_consumer' do
  expected_yaml = <<-EOF
  logs:

  instances:
    - kafka_connect_str: localhost:19092
      consumer_groups:
        my_consumer:
          my_topic: [0, 1, 4, 12]
      monitor_unlisted_consumer_groups: false
      zk_connect_str: localhost:2181
      zk_prefix: /0.8
      kafka_consumer_offsets: true

  init_config:
  # The Kafka Consumer check does not require any init_config
  EOF

  cached(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu',
      version: '16.04',
      step_into: ['datadog_monitor']
    ) do |node|
      node.automatic['languages'] = { python: { version: '2.7.2' } }

      node.normal['datadog'] = {
        api_key: 'someapikey',
        kafka_consumer: {
          instances: [
            {
              kafka_connect_str: 'localhost:19092',
              consumer_groups: {
                my_consumer: {
                  my_topic: [0, 1, 4, 12]
                }
              },
              monitor_unlisted_consumer_groups: false,
              zk_connect_str: 'localhost:2181',
              password: 'localhost:2181',
              zk_prefix: '/0.8',
              kafka_consumer_offsets: true
            }
          ]
        }
      }
    end.converge(described_recipe)
  end

  subject { chef_run }

  it_behaves_like 'datadog-agent'

  it { is_expected.to include_recipe('datadog::dd-agent') }

  it { is_expected.to add_datadog_monitor('kafka_consumer') }

  it 'renders expected YAML config file' do
    expect(chef_run).to(render_file('/etc/datadog-agent/conf.d/kafka_consumer.d/conf.yaml').with_content { |content|
      expect(YAML.safe_load(content).to_json).to be_json_eql(YAML.safe_load(expected_yaml).to_json)
    })
  end
end
