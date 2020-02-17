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
  File.join(DST_DIR, path)
end

def src_pictures
  pictures.map{|p| src_picture p}
end

def dst_pictures
  pictures.map{|p| dst_picture p}
end

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

desc "resize pictures"
namespace :resize do

  desc "resize all pics in #{SRC_DIR} into #{DST_DIR}"
  task :all => dst_pictures do
    puts "done"
  end
  
  pictures.each do |picture_path|
    dst_picture_path = File.join(DST_DIR, picture_path)
    src_picture_path = File.join(SRC_DIR, picture_path)

    file dst_picture_path => [src_picture_path] do |f|
      mkdir_p File.dirname(f.name)

      orig_image = Magick::Image::read(src_picture_path).first
      resized_image = orig_image.resize_to_fill(1280, 1280)
      resized_image.write(dst_picture_path)

      puts "Resized: #{src_picture_path}"
    end
  end
end

# task :resize do
#   # base_dir = File.dirname(__FILE__)
  

#   images = Dir.glob("**/*.*", base: SRC_DIR)

#   puts images.map{|i| File.dirname(i)}

  
# end
