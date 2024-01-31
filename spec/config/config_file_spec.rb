# frozen_string_literal: true

require 'app_helper'
require 'tempfile'

RSpec.describe ConfigFile do
  let(:config_path) { Pathname.new(Dir.mktmpdir) }
  let(:file_path) { config_path.join(file_name) }

  after do
    config_path.rmtree if config_path.exist?
  end

  describe '#load_for' do
    context 'when the file is a YAML file' do
      ['test_config.yaml', 'test_config.yml'].each do |yaml_file_name|
        let(:file_name) { yaml_file_name }

        it 'loads and returns the YAML content' do
          content = %(
            development:
              key: value
          ).strip

          file_path.write(content)
          config_file = described_class.new(file_name:, config_path:)
          result = config_file.load_for(environment: 'development')

          expect(result).to eq({ 'key' => 'value' })
        end
      end
    end

    context 'when the file is an ERB YAML file' do
      let(:file_name) { 'test_config.yaml.erb' }

      it 'loads and returns the evaluated YAML content' do
        content = %(
          development:
            key: <%= 1 + 1 %>
        ).strip

        file_path.write(content)
        config_file = described_class.new(file_name:, config_path:)
        result = config_file.load_for(environment: 'development')

        expect(result).to eq({ 'key' => 2 })
      end
    end

    context 'when the file type is unrecognized' do
      it 'raises UnRecognizedFileType error' do
        invalid_file_path = config_path.join('invalid_file.txt')
        invalid_file_path.write('invalid content')
        config_file = described_class.new(file_name: 'invalid_file.txt', config_path:)

        expect { config_file.load_for(environment: 'development') }.to raise_error(ConfigFile::UnRecognizedFileType)
      end
    end
  end
end
