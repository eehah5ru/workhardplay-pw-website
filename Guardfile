
#
# nohup and guard
# https://stackoverflow.com/questions/20877031/running-guard-as-a-daemon-proces
#
# FIXME: enable to make it quiet
interactor :off
# logger device: 'guard.log'
directories %w(pictures-high)

#
# resize pictures 
#
guard 'rake', :task => 'resize:all', :run_on_start => false do
  watch(%r{^pictures-high/.+})
end


# guard :shell, :all_on_start => false do
#   watch %r{^src/.+\.hs} do |m|
#     system "stack build"
#   end
# end

# guard 'process',
#       name: "WHP Local server",
#       command: "scripts/start_local_server.sh",
#       stop_signal: 'KILL',
#       all_on_start: true do
#   watch %r{^.stack-work/.+build/site/site}
# end

