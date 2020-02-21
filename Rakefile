require 'fileutils'
require "rmagick"

#
#
# histogram with rmagick
# https://github.com/rmagick/rmagick/tree/master/examples
#
#

SRC_DIR = "pictures-high"

DST_DIR = "pictures"


def pictures
  Dir.glob("**/*.*", base: SRC_DIR).select{|p| !File.directory?(src_picture(p))}
end

def src_picture path
  File.join(SRC_DIR, path)
end

def dst_picture path
  # make picture jpg
  ext = File.extname(path)
  jpg_path = path.sub(/#{ext}$/, ".jpg")
  
  File.join(DST_DIR, jpg_path)
end

def src_pictures
  pictures.map{|p| src_picture p}
end

def dst_pictures
  pictures.map{|p| dst_picture p}
end

# module Vagrant
#   def self::up target
#     sh "vagrant"
#   end
  
# end


#
#
# DEV ENV TASKS
#
#
namespace :stack do
  desc "build executables"
  task :build do
    sh "stack build"
  end
end

namespace :server do
  desc "build website once"
  task :build => ["stack:build", "resize:all"] do
    sh "stack exec site build"
  end

  desc "rebuild website: clean and build again"
  task :rebuild => ["stack:build", "resize:all"] do
    sh "stack exec site rebuild"
  end

  desc "start local server and watch changes"
  task :watch => ["stack:build", "resize:all"] do
    sh "stack exec site --  watch --port 8001"
  end

  desc "clean hakyll cache"
  task :clean => ["stack:build"] do
    sh "stack exec site clean"
  end
end

#
#
# RESIZE PICS TASKS
#
#
desc "resize pictures"
namespace :resize do

  desc "resize all pics in #{SRC_DIR} into #{DST_DIR}"
  task :all => dst_pictures do
    puts "Resizing pictues: done"
  end

  src_pictures.zip(dst_pictures).each do |src_pic, dst_pic|
    file dst_pic => [src_pic] do |f|
      mkdir_p File.dirname(f.name)

      image = Magick::Image::read(src_pic).first
      
      image.resize_to_fit!(1280)
      image.write(f.name) do
        self.quality = 89
        self.format = "JPEG"
      end

      puts "Resized: #{src_pic}"      
    end
  end

  #
  # PURGE
  #
  desc "purge resized pictures"
  task :purge do
    rm_rf "#{DST_DIR}"
  end
end

#
#
# REMOTE VAGRANT TASKS
#
#

desc "REMOTE TASKS on vagrant machines"
namespace :vagrant do
  desc "update vagrant plugins"
  task :plugin_update do
    sh "vagrant plugin update"
  end

  desc "vagrant / master REMOTE TASKS"
  namespace :master do

    #
    # vagrant tasks
    #
    desc "up vagrant machine"
    task :up do
      sh "vagrant up master"
    end

    desc "halt vagrant machine"
    task :halt do
      sh "vagrant halt master"
    end

    desc "reload vagrant machine"
    task :reload do
      sh "vagrant reload master"
    end

    desc "provision"
    task :provision do
      sh "vagrant provision master"
    end

    desc "rsync-auto"
    task :rsync_auto do
      sh "vagrant rsync-auto master"
    end

    #
    # hakyll tasks
    #
    
    desc "start hakyll server watch"
    task :watch => [:up] do
      sh "vagrant ssh master -c \"bash /vagrant/bin/whph-master-site-watch.sh\""
    end

    desc "clean hakyll server"
    task :clean => [:up] do
      sh "vagrant ssh master -c \"bash /vagrant/bin/whph-master-site-clean.sh\""
    end

    desc "deploy site bin"
    task :deploy_bin => [:up] do
      sh "vagrant ssh master -c \"bash /vagrant/bin/whph-master-deploy-bins.sh\""
    end
  end

  desc " vagrant / slave REMOTE TASKS"
  namespace :slave do
    #
    # vagrant tasks
    #
    desc "up vagrant machine"
    task :up do
      sh "vagrant up slave"
    end

    desc "halt vagrant machine"
    task :halt do
      sh "vagrant halt slave"
    end

    desc "reload vagrant machine"
    task :reload do
      sh "vagrant reload slave"
    end

    desc "provision"
    task :provision do
      sh "vagrant provision slave"
    end

    desc "rsync-auto"
    task :rsync_auto do
      sh "vagrant rsync-auto slave"
    end

    #
    # hakyll tasks
    #
    desc "start hakyll server watch"
    task :watch => [:up] do
      sh "vagrant ssh slave -c \"bash /vagrant/bin/whph-slave-site-watch.sh\""
    end

    desc "clean hakyll server"
    task :clean => [:up] do
      sh "vagrant ssh slave -c \"bash /vagrant/bin/whph-slave-site-clean.sh\""
    end    
    
  end
  
end

desc "MASTER LOCAL tasks"
namespace :master do

end


desc "SLAVE LOCAL tasks"
namespace :slave do
  task :make_bin do
    mkdir_p "bin"
  end

  desc "fetch latest version of hakyll site binary"
  task :fetch_bin => [:make_bin] do
    sh "rsync -avz deploy@myfutures.trade:~/whph-slave-bins/site bin/"
  end

  task :watch => [:fetch_bin, "resize:all"] do
    sh "bin/site watch --port 8001"
  end
end
  
# task :resize do
#   # base_dir = File.dirname(__FILE__)
  

#   images = Dir.glob("**/*.*", base: SRC_DIR)

#   puts images.map{|i| File.dirname(i)}

  
# end
