# coding: utf-8
require "slim/include"

Slim::Engine.set_options(:disable_escape => true,
                        :disable_capture => false)

descr = :descr
long_descr = :long_descr

def include_slim(name, options = {}, &block)
  t = Slim::Template.new("#{name}.slim", options)
  if block_given?
    t.render(self, options, &block)
  else
    t.render(self, options)
  end
end

def capture_to(var, &block)
  t = Slim::Template.new { "  ==yield" }
  c = t.render(self, {}, &block)
  block.binding.local_variable_set(var, c)
  # set_var.call(block)
  # # In Rails we have to use capture!
  # # If we are using Slim without a framework (Plain Tilt),
  # # you can just yield to get the captured block.

  # # a = block.call
  # return ''
end

def capture_block &block
  r = block.call
  # return r
  return "aaa"
end

def capture_block_to(var, &block)
  block.binding.local_variable_set(var, block.call)
  return nil
  # In Rails we have to use capture!
  # If we are using Slim without a framework (Plain Tilt),
  # you can just yield to get the captured block.
  # set_var.call(yield)
end
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

def _participantName p_id
  return "$participantName(\"#{p_id}\")$"
end
#
#
# url helpers
#
#
def archive_image(file_name)
  return "/images/2016/archive/$canonicalName$/" + file_name
end

#
#
# styles
#
#

def class_has_video
  return "$if(hasVideo)$has-video-icon$endif$"
end

def schedule_prj_cover_style(project_name, image_path)
  return <<END
<style>
.#{project_name}-cover {
  background-image: linear-gradient(270deg, rgba(255,255,255,0), rgba(255,255,255,1)), url("#{image_path}");
  opacity: 0.5;
  filter: saturate(200%);
/*background-image: url("#{image_path}");*/

transform: perspective(1280px) rotate3d(#{rand(-30..30)}, #{rand(-90..90)}, #{rand(20..45)}, #{rand((-50)..(-10))}deg);

}
</style>
<h1 name="#{project_name}" id="#{project_name}" style="width:0; hieght:0;"></h1>
<a class="scroll" id="#{project_name}-link" href="##{project_name}" style="width:0; hieght:0;"></a>
END
end

#
#
# 2018
#
#
def sh18_participant_info(p_id)
  return <<END
<div class="participant-name">
     <div class="hor-line">
          ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
     </div>
     <div class="name">
          $participantName("#{p_id}")$ ($participantCity("#{p_id}")$)
     </div>
</div>
<div class="participant-bio">
     $participantBio("#{p_id}")$
</div>
END
end
