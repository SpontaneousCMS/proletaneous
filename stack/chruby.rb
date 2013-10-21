package :chruby, provides: :ruby do
  requires :install_chruby, opts
  requires :default_ruby, opts
end

package :install_chruby do
  version = "0.3.6"
  source "https://github.com/postmodern/chruby/archive/v#{version}.tar.gz" do
    custom_archive "chruby-#{version}.tar.gz"
    custom_install 'make install'
  end
  verify do
    has_file "/usr/local/share/chruby/chruby.sh"
  end
end

package :default_ruby do
  requires :ruby_version, opts
  ruby    = opts[:ruby]
  source_chruby = "/etc/profile.d/00-chruby.sh"
  runner %(echo '[ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ] || return' > #{source_chruby})
  runner %(echo 'source /usr/local/share/chruby/chruby.sh' >> #{source_chruby})
  runner %(echo "chruby #{ruby}" > /etc/profile.d/01-default-ruby.sh)
  verify do
    has_file source_chruby
    has_file "/etc/profile.d/01-default-ruby.sh"
  end
end

package :ruby_version do
  requires :ruby_install, opts
  version = opts[:ruby_version]
  ruby    = opts[:ruby]
  install_dir =  "/opt/rubies/#{ruby}"
  runner "ruby-install ruby #{version}"
  runner %(#{install_dir}/bin/gem install bundler --no-rdoc --no-ri)
  verify do
    has_executable "#{install_dir}/bin/ruby"
  end
end

package :ruby_install do
  requires :curl
  version = "0.3.0"
  source "https://codeload.github.com/postmodern/ruby-install/tar.gz/v#{version}" do
    custom_archive "ruby-install-#{version}.tar.gz"
    custom_install 'make install'
  end
  verify do
    has_executable "/usr/local/bin/ruby-install"
  end
end

package :curl do
  apt "curl"
  verify do
    has_executable "/usr/bin/curl"
  end
end