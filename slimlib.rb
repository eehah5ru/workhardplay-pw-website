require "slim/include"

def field name
  return "$#{name.to_s}$"
end

def archive_image(file_name)
  return "/images/2016/archive/$canonical_name$/" + file_name
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
