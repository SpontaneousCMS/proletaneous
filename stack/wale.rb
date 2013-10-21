
package :wal_e, provides: :database_backup do
  requires :python_dev, opts
  requires :python_setuptools, opts
  requires :pipe_viewer, opts
  requires :lzop, opts
  requires :libevent, opts
  requires :wal_e_dependencies, opts
  requires :wal_e_env, opts
  requires :wal_e_command, opts
  requires :wal_e_crontab, opts
end

# make base backup every day @ 2am
package :wal_e_crontab do
  tmpfile = "/tmp/wal-e.cron"
  backup_days_to_keep = opts[:db_backup_days] || 7
  wal_e = "/usr/bin/chpst -e /etc/wal-e.d/env /usr/local/bin/wal-e"
  crontab = [
     "# Make a base backup of the db every night at midnight",
     "0 0 * * * #{wal_e} backup-push /var/lib/postgresql/9.1/main",
     "# Delete old backups every night at 3am, keeping #{backup_days_to_keep} days",
     "0 3 * * * #{wal_e} delete --confirm before $(#{wal_e} backup-list | sed '1d' | tail -#{backup_days_to_keep} | head -1 | awk '{print $1}' )"
  ].join("\n")
  puts crontab
  file tmpfile, contents: crontab << "\n"
  runner "crontab -u postgres #{tmpfile} ; rm #{tmpfile}"
end

package :wal_e_command do
  runner "easy_install wal-e"
  verify do
    has_executable "wal-e"
  end
end

package :wal_e_env do
  env_dir = "/etc/wal-e.d/env"
  env = opts[:production_env]
  if env # first run is without opts
    runner "test -d #{env_dir} || mkdir -p #{env_dir}"
    %w(WALE_AWS_ACCESS_KEY_ID WALE_AWS_SECRET_ACCESS_KEY WALE_WALE_S3_PREFIX).each do |k|
      raise "Missing environment setting '#{k}'" if !env.key?(k)
      key, value = k.gsub(/^WALE_/, ''), env[k]
      file "#{env_dir}/#{key}", contents: value, owner: "root:postgres", mode: "0640"
    end
  end
end

package :pipe_viewer do
  apt "pv"
  verify do
    has_apt "pv"
  end
end

package :lzop do
  apt "lzop"
  verify do
    has_apt "lzop"
  end
end

package :libevent do
  apt %w(libevent-dev libevent-core-2.0-5)
  verify do
    has_apt "libevent-dev"
  end
end

package :wal_e_dependencies do
  runner "easy_install boto"
  runner "easy_install gevent"
end


package :python_setuptools do
  apt "python-setuptools"
  verify do
    has_apt "python-setuptools"
  end
end

package :python_dev do
  apt "python-dev"
  verify do
    has_apt "python-dev"
  end
end