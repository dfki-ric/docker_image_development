
# helper script to determine osdeps of a workspace to be installes in build_image phase

require 'autoproj'
require 'autoproj/cli/inspection_tool'
require 'pp'

tool = Autoproj::CLI::InspectionTool.new
tool.initialize_and_load
tool.finalize_setup
all_osdeps = tool.ws.all_os_packages

os_package_installer = tool.ws.os_package_installer
os_package_installer.setup_package_managers
resolved = os_package_installer.resolve_and_partition_osdep_packages(
    all_osdeps, all_osdeps)

resolved.each do |pkg_manager, packages|
    if "#{pkg_manager.class}" == 'Autoproj::PackageManagers::AptDpkgManager' then
        puts packages.to_a.sort.join(" \n ")
        puts
    end
end
