# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "zgomot"
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Troy Stribling"]
  s.date = "2013-08-15"
  s.email = "troy.stribling@gmail.com"
  s.executables = ["zgomot"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rvmrc",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/zgomot",
    "examples/arp_chords.rb",
    "examples/delay.rb",
    "examples/full_scale_notes.rb",
    "examples/inv_chords.rb",
    "examples/modes_notes.rb",
    "examples/notes.rb",
    "examples/percs.rb",
    "examples/percs_multi.rb",
    "examples/phase_notes.rb",
    "examples/prog_chords.rb",
    "examples/prog_chords_multi_vel_length.rb",
    "examples/prog_chords_rest.rb",
    "examples/prog_notes.rb",
    "examples/prog_notes_multi_vel_length.rb",
    "examples/prog_notes_rest.rb",
    "examples/progressive_modes.rb",
    "examples/reverse_chords.rb",
    "examples/route_chords.rb",
    "examples/scale_chords.rb",
    "examples/scale_notes.rb",
    "examples/scales_notes.rb",
    "examples/simple_chords.rb",
    "examples/simple_input.rb",
    "examples/simple_markov.rb",
    "examples/simple_note_list.rb",
    "examples/simple_notes.rb",
    "examples/zgomot.yml",
    "examples/zgomot_streams.rb",
    "lib/zgomot.rb",
    "lib/zgomot/boot.rb",
    "lib/zgomot/comp.rb",
    "lib/zgomot/comp/chord.rb",
    "lib/zgomot/comp/markov.rb",
    "lib/zgomot/comp/mode.rb",
    "lib/zgomot/comp/note.rb",
    "lib/zgomot/comp/note_list.rb",
    "lib/zgomot/comp/pattern.rb",
    "lib/zgomot/comp/perc.rb",
    "lib/zgomot/comp/permutation.rb",
    "lib/zgomot/comp/pitch_class.rb",
    "lib/zgomot/comp/progression.rb",
    "lib/zgomot/comp/scale.rb",
    "lib/zgomot/config.rb",
    "lib/zgomot/drivers.rb",
    "lib/zgomot/drivers/core_midi.rb",
    "lib/zgomot/drivers/driver.rb",
    "lib/zgomot/drivers/mgr.rb",
    "lib/zgomot/main.rb",
    "lib/zgomot/midi.rb",
    "lib/zgomot/midi/cc.rb",
    "lib/zgomot/midi/channel.rb",
    "lib/zgomot/midi/clock.rb",
    "lib/zgomot/midi/dispatcher.rb",
    "lib/zgomot/midi/note.rb",
    "lib/zgomot/midi/stream.rb",
    "lib/zgomot/patches.rb",
    "lib/zgomot/patches/object.rb",
    "lib/zgomot/patches/string.rb",
    "lib/zgomot/patches/time.rb",
    "lib/zgomot/ui.rb",
    "lib/zgomot/ui/output.rb",
    "lib/zgomot/ui/windows.rb",
    "lib/zgomot_sh.rb",
    "zgomot.gems",
    "zgomot.gemspec"
  ]
  s.homepage = "http://github.com/troystribling/zgomot"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "zgomot is a simple DSL for writting MIDI music."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ffi>, ["~> 1.0.9"])
      s.add_runtime_dependency(%q<rainbow>, ["~> 1.1.4"])
      s.add_runtime_dependency(%q<pry>, ["~> 0.9.12.2"])
      s.add_runtime_dependency(%q<fssm>, ["~> 0.2.10"])
    else
      s.add_dependency(%q<ffi>, ["~> 1.0.9"])
      s.add_dependency(%q<rainbow>, ["~> 1.1.4"])
      s.add_dependency(%q<pry>, ["~> 0.9.12.2"])
      s.add_dependency(%q<fssm>, ["~> 0.2.10"])
    end
  else
    s.add_dependency(%q<ffi>, ["~> 1.0.9"])
    s.add_dependency(%q<rainbow>, ["~> 1.1.4"])
    s.add_dependency(%q<pry>, ["~> 0.9.12.2"])
    s.add_dependency(%q<fssm>, ["~> 0.2.10"])
  end
end

