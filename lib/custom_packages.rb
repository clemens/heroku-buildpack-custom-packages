require 'yaml'

require 'pathname'
require 'fileutils'
require 'tmpdir'

module CustomPackages
  class PackageInstaller
    include ::CustomPackages::ShellHelpers

    def initialize(*args)
      @build_dir, @cache_dir = args

      prepare
    end

    def prepare
      FileUtils.mkdir_p(@cache_dir)
      Dir.chdir(@cache_dir)
    end

    def install_packages(package_file)
      @config, @packages = YAML.load_file(package_file).values_at('config', 'packages')
      @config ||= {}
      @config = Hash[@config.map { |key, value| [key.to_sym, value] }]
      @config.merge!(:cache_dir => @cache_dir, :build_dir => @build_dir)

      puts "Installing packages (BUILD_DIR: #{@build_dir}, CACHE_DIR: #{@cache_dir})"

      @packages.each do |package, steps|
        topic "Installing #{package}"

        steps.each do |step|
          command = step % @config
          puts command
          run command
        end
      end
    end
  end
end
