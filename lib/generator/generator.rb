# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

require 'json'
require 'erb'

module Elastic
  # Generates endpoint Ruby code for the Workplace Search JSON API spec.
  class Generator
    CURRENT_PATH = File.dirname(__FILE__).freeze
    TARGET_DIR = "#{CURRENT_PATH}/api/".freeze

    def generate
      @spec = load_spec
      tags = setup_tags(@spec['tags'])
      empty_directory

      # for each endpoint in the spec generate code
      @spec['paths'].each do |endpoints|
        generate_classes(endpoints)
        # generate specs(endpoints)
      end
    end

    private

    def generate_classes(endpoints)
      @path = endpoints[0]

      endpoints[1].each do |method, endpoint|
        @http_method = method
        setup_values(endpoint)
        write_file(generate_method_code)
      end
    end

    def setup_values(endpoint)
      @module_name = module_name(endpoint['tags'])
      @method_name = to_snakecase(endpoint['operationId'])
      @required_params = []
      @params = setup_parameters(endpoint['parameters'])
      @doc = setup_doc(endpoint)
    end

    def empty_directory
      FileUtils.remove_dir(TARGET_DIR)
      Dir.mkdir(TARGET_DIR)
    end

    # TODO : Do this correctly
    def setup_parameters(params)
      params.map do |param|
        @required_params << param['name'] if param['required']
      end
    end

    # TODO: Need to decide if it's better to have one module per tag or one file
    # per method, since tags have their own docs and such
    def setup_tags(tags)
      tags.map do |tag|
        {
          name: tag['name'],
          description: tag['description'],
          url: tag['externalDocs']['url']
        }
      end
    end

    def write_file(content)
      file_name = "#{TARGET_DIR}#{@method_name}.rb"
      File.open(file_name, 'w') { |f| f.puts content }
      run_rubocop(file_name)
      puts colorize(:green, "\nSuccessfully generated #{file_name}.rb\n\n")
    end

    def run_rubocop(file)
      system("rubocop -c ./.rubocop.yml --format autogenconf -x #{file}")
    end

    def load_spec
      file = CURRENT_PATH + '/workplace-search.json'
      JSON.parse(File.read(file))
    end

    def generate_method_code
      template = "#{CURRENT_PATH}/templates/template.erb"
      code = ERB.new(File.read(template), nil, '-')
      code.result(binding)
    end

    def module_name(tag)
      tag.first.gsub(/\s{1}API/, '').gsub(/\s/, '')
    end

    def setup_doc(endpoint)
      # Description is markdown with [description](external_url)
      # So we split the string with regexp:
      matches = endpoint['description'].match(/\[(.+)\]\((.+)\)/)
      description = matches[1]
      url = matches[2]
      <<~DOC
        # #{@module_name} - #{endpoint['summary']}
        # #{description}
        #
        # @see #{url}
        #
      DOC
    end

    def to_snakecase(camel_case)
      camel_case.gsub(/([a-z])([A-Z])+/, '\1_\2').downcase
    end

    def colorize(color, message)
      colors = { red: 31, green: 32 }
      "\e[#{colors[color]}m#{message}\e[0m"
    end
  end
end
