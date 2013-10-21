package :essential do
  requires :build_essential
  requires :libxml
  requires :inotify_tools
  requires :misc_tools
  requires :github_known_hosts
end

package :build_essential do
  description 'Build tools & core libraries'
  pkg = %w(build-essential)
  apt pkg
  verify do
    pkg.each { |p| has_apt p }
  end
end

package :libxml do
  pkg = %w(libxml2 libxml2-dev libxslt1.1 libxslt1-dev)
  apt pkg
  verify do
    pkg.each { |p| has_apt p }
  end
end

package :inotify_tools do
  pkg = %w(inotify-tools)
  apt pkg
  verify do
    pkg.each { |p| has_apt p }
  end
end

package :misc_tools do
  pkg = %w(htop apache2-utils)
  apt pkg
  verify do
    pkg.each { |p| has_apt p }
  end
end

package :github_known_hosts do
  known_hosts = "/etc/ssh/ssh_known_hosts"
  key = File.read(File.expand_path('../../templates/home/known_hosts', __FILE__))
  file known_hosts, contents: key, owner: 'root:root', mode: "0644"
  verify do
    has_file known_hosts
  end
end