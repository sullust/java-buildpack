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

require 'fileutils'
require 'java_buildpack/component/versioned_dependency_component'
require 'java_buildpack/jre'

module JavaBuildpack
  module Jre

    # Encapsulates the detect, compile, and release functionality for the OpenJDK-like memory calculator
    class OpenJDKLikeMemoryCalculator < JavaBuildpack::Component::VersionedDependencyComponent

      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        download(@version, @uri) do |file|
          FileUtils.mkdir_p memory_calculator.parent
          FileUtils.cp_r(file.path, memory_calculator)
          memory_calculator.chmod 0755
        end

        # TODO: Output staging-time memory resolution
        # TODO: Fail if things aren't going to work
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release
        # TODO: Add call to memory calculator
      end

      protected

      # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
      def supports?
        true
      end

      private


      # KEY_MEMORY_HEURISTICS = 'memory_heuristics'.freeze
      #
      # KEY_MEMORY_SIZES = 'memory_sizes'.freeze
      #
      # VERSION_8 = JavaBuildpack::Util::TokenizedVersion.new('1.8.0').freeze
      #
      # private_constant :KEY_MEMORY_HEURISTICS, :KEY_MEMORY_SIZES, :VERSION_8
      #
      # def memory
      #   sizes      = @configuration[KEY_MEMORY_SIZES] ? @configuration[KEY_MEMORY_SIZES].clone : {}
      #   heuristics = @configuration[KEY_MEMORY_HEURISTICS] ? @configuration[KEY_MEMORY_HEURISTICS].clone : {}
      #
      #   if @version < VERSION_8
      #     heuristics.delete 'metaspace'
      #     sizes.delete 'metaspace'
      #   else
      #     heuristics.delete 'permgen'
      #     sizes.delete 'permgen'
      #   end
      #
      #   OpenJDKMemoryHeuristicFactory.create_memory_heuristic(sizes, heuristics, @version).resolve
      # end


      def memory_calculator
        @droplet.sandbox + "bin/#{@droplet.component_id}-#{@version}"
      end
    end

  end
end
