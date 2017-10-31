guard :shell, :all_on_start => false do
  watch %r{^src/.+\.hs} do |m|
    system "stack build"
  end
end

guard 'process',
      name: "WHP Local server",
      command: "scripts/start_local_server.sh",
      stop_signal: 'KILL',
      all_on_start: true do
  watch %r{^.stack-work/.+build/site/site}
end
