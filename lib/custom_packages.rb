require 'yaml'

require 'pathname'
require 'fileutils'
require 'tmpdir'

module CustomPackages
  class PackageInstaller
    include ::CustomPackages::ShellHelpers

    def initialize(*args)
      @build_dir, @cache_dir = args

      @target_dir = Pathname.new(File.join(@build_dir, 'tmp', 'packages'))

      prepare
    end

    def prepare
      FileUtils.rm_rf(@target_dir)
      FileUtils.mkdir_p(@target_dir)
      Dir.chdir(@target_dir)
    end

    def install_packages(package_file)
      @config, @packages = YAML.load_file(package_file).values_at('config', 'packages')
      @config = Hash[@config.map { |key, value| [key.to_sym, value] }]

      @packages.each do |package, steps|
        topic "Installing #{package}"

        steps.each do |step|
          command = step % @config
          puts command
          run command
        end
      end
    end

    def cleanup
      FileUtils.rm_rf(@target_dir)
    end
  end
end
