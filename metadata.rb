maintainer       "Knewton"
maintainer_email "se@knewton.com"
license          "Apache 2.0"
description      "Installs Nix"
version          Time.at(`git --git-dir=#{File.join(File.dirname(__FILE__),'.git')} log --max-count=1 --pretty=format:%ct`.to_i).strftime("1.0.%Y%m%d%H%M")
