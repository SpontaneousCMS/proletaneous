package :system_update do
  description "Update package lists & upgrade installed packages"
  runner "whoami"
  runner "apt-get update"
  # causes problems when run over cap
  # runner "apt-get upgrade -y"
end