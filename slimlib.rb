require "slim/include"

Slim::Engine.set_options(:disable_escape => true)

#
#
# hakyll template wrapper
#
#
def field name
  return "$#{name.to_s}$"
end

def _if cond, &block
  return "$if(#{cond})$\n#{yield}\n"
end

def _else &block
  return "$else$\n#{yield}\n"
end

def _endif
  return "$endif$\n"
end

def _for stmt, &block
  return "$for(#{stmt})$\n#{yield}\n"
end

def _endfor
  return "$endfor$\n"
end

#
#
# url helpers
#
#
def archive_image(file_name)
  return "/images/2016/archive/$canonical_name$/" + file_name
end

#
#
# styles
#
#

def class_has_video
  return "$if(has_video)$has-video-icon$endif$"
end

def schedule_prj_cover_style(project_name, image_path)
  return <<END
<style>
.#{project_name}-cover {
background-image: linear-gradient(270deg, rgba(255,255,255,0), rgba(255,255,255,1)), url("#{image_path}");
transform: perspective(1280px) rotate3d(#{rand(-30..30)}, #{rand(-90..90)}, #{rand(20..45)}, #{rand((-50)..(-10))}deg);

}
</style>
<h1 name="#{project_name}" id="#{project_name}" style="width:0; hieght:0;"></h1>
<a class="scroll" id="#{project_name}-link" href="##{project_name}" style="width:0; hieght:0;"></a>
END
end
