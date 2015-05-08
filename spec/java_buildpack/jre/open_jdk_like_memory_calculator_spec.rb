# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2013-2015 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'
require 'component_helper'
require 'java_buildpack/component/mutable_java_home'
require 'java_buildpack/jre/open_jdk_like_memory_calculator'

describe JavaBuildpack::Jre::OpenJDKLikeMemoryCalculator do
  include_context 'component_helper'

  let(:java_home) { JavaBuildpack::Component::MutableJavaHome.new }

  let(:version_7) { VERSION_7 = JavaBuildpack::Util::TokenizedVersion.new('1.7.0_+') }

  let(:version_8) { VERSION_8 = JavaBuildpack::Util::TokenizedVersion.new('1.8.0_+') }

  let(:configuration) do
    { 'memory_sizes'      => { 'metaspace' => '64m..',
                               'permgen'   => '64m..' },
      'memory_heuristics' => { 'heap'      => '75',
                               'metaspace' => '10',
                               'permgen'   => '10',
                               'stack'     => '5',
                               'native'    => '10' } }
  end

  it 'copies executable to bin directory',
     cache_fixture: 'stub-memory-calculator' do

    java_home.version = version_7
    allow(component).to receive(:shell)

    component.compile

    expect(sandbox + "bin/java-buildpack-memory-calculator-#{version}").to exist
  end

  it 'chmods executable to 0755',
     cache_fixture: 'stub-memory-calculator' do

    java_home.version = version_7
    allow(component).to receive(:shell)

    component.compile

    expect(File.stat(sandbox + "bin/java-buildpack-memory-calculator-#{version}").mode).to eq(0100755)
  end

  it 'runs the memory calculator to sanity check',
     cache_fixture: 'stub-memory-calculator' do

    java_home.version = version_7
    expect(component).to receive(:shell).with('$PWD/.java-buildpack/open_jdk_like_memory_calculator/bin/' \
                                              'java-buildpack-memory-calculator-0.0.0 -memorySizes=permgen:64m.. ' \
                                              '-memoryWeights=heap:75,permgen:10,stack:5,native:10 ' \
                                              '-totMemory=$MEMORY_LIMIT')

    component.compile
  end

  it 'create memory calculation command for Java 7' do
    java_home.version = version_7
    command           = component.memory_calculation_command

    expect(command).to eq('CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_like_memory_calculator/bin/' \
                          'java-buildpack-memory-calculator-0.0.0 -memorySizes=permgen:64m.. ' \
                          '-memoryWeights=heap:75,permgen:10,stack:5,native:10 -totMemory=$MEMORY_LIMIT)')
  end

  it 'create memory calculation command for Java 8' do
    java_home.version = version_8
    command           = component.memory_calculation_command

    expect(command).to eq('CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_like_memory_calculator/bin/' \
                          'java-buildpack-memory-calculator-0.0.0 -memorySizes=metaspace:64m.. ' \
                          '-memoryWeights=heap:75,metaspace:10,stack:5,native:10 -totMemory=$MEMORY_LIMIT)')
  end

  it 'adds $CALCULATED_MEMORY to the JAVA_OPTS' do
    component.release

    expect(java_opts).to include('"$CALCULATED_MEMORY"')
  end

end
