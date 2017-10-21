#
# NSL Synthesize helper script
#

require "pathname"
require "tempfile"

RUN_NSLC_DEBUG = false

SYNTH_FOR = :Xilinx
#SYNTH_FOR = :IVerilog

NSLC_DIR = "C:\\Program Files\\NSL Core"

NSLC_CMD = '"' + "#{NSLC_DIR}\\nslc.exe" + '"'
NSLPP_CMD = '"' + "#{NSLC_DIR}\\nslpp.exe" + '"'

SRC_PATHS=%w[
  nsl_src\\my8_74181.nsl
  nsl_src\\my8_alu.nsl
  nsl_src\\my8_core.nsl
  nsl_src\\my8_mem.nsl
  nsl_src\\my8_wrapper_nsl.nsl
  nsl_src\\npc74181.nsl
]

unless SYNTH_FOR == :Xilinx or
       SYNTH_FOR == :IVerilog then
  STDERR.puts "Please set SYNTH_FOR = :Xilinx or SYNTH_FOR = :IVerilog ."
  STDERR.puts "run_nslc failed"
  exit 1
end

NSL_CORE_OPTIONS = []

if SYNTH_FOR == :Xilinx then
  NSL_CORE_OPTIONS << "-sync_res"
  DEST_DIR = "project"
else
  # default id async reset
  DEST_DIR = "test"
end

def main
  $success = true

  SRC_PATHS.each {|path|
    unless File.file? path then
      STDERR.puts 'warning: file "' + path + '" doesn\'t exist, skipped'
      next
    end
    basename = File.basename path
    unless basename =~ /\.nsl\z/ then
      STDERR.puts "warning: unknown file #{basename.inspect} is skipped"
      next
    end
    do_synthesize path
  }
  STDERR.print(if $success then "Succeed!" else "Failed!!" end)
end

def do_synthesize path
  dirname = File.dirname path
  basename = File.basename path
  basename_exext = File.basename path, ".nsl"

  target = Pathname.new DEST_DIR
  target += "#{basename_exext}.v"
  target = target.to_s

  if RUN_NSLC_DEBUG then
    STDERR.puts "========"
    STDERR.puts "synthesize: #{path} ==> #{target}"
  end
  if File.file? target then
    a = File.mtime target
    b = File.mtime path
    if File.size(target) == 0 then
      STDERR.puts "info: #{target} is empty. forth synthesize"
    else
      if a > b then
        if RUN_NSLC_DEBUG then
          STDERR.puts "#{target} is newer than #{path}, skipped"
          STDERR.puts "========"
        end
        return
      end
    end
  end
  STDERR.puts "synthesizing..." if RUN_NSLC_DEBUG

  begin
    err_pp = Tempfile.open "run_nslc"
    err_synth = Tempfile.open "run_nslc"

    nslc_cmdline = [NSLC_CMD, *NSL_CORE_OPTIONS].join ' '

    pid_pp, pid_synth = nil, nil
    IO.pipe {|pipe_r, pipe_w|
      pid_pp = spawn NSLPP_CMD, {unsetenv_others: true, chdir: dirname, in: basename, out: pipe_w, err: err_pp.path}
      pid_synth = spawn nslc_cmdline, {in: pipe_r, out: target, err: err_synth.path}
    }

    _, stat_pp = Process.waitpid2 pid_pp
    _, stat_synth = Process.waitpid2 pid_synth

    stat_pp = stat_pp.to_i
    stat_synth = stat_synth.to_i

    buf = ""
    buf << ('processing "' + basename + '":' + "\n")
    if stat_pp == 0 and stat_synth == 0 then
      buf << "synthesize succeed !\n"
    elsif stat_pp != 0 then
      buf << "preprocess fail !!\n"
    elsif stat_synth != 0 then
      buf << "nslc fail !!\n"
    else
      raise
    end
    buf << "----\n"
    buf << "nslpp exit status: #{stat_pp}\n"
    buf << "nslpp stderr:\n#{err_pp.read}"
    buf << "----\n"
    buf << "nslc command: #{nslc_cmdline.inspect}\n"
    buf << "nslc exit status: #{stat_synth}\n"
    buf << "nslc stderr:\n#{err_synth.read}"
    if RUN_NSLC_DEBUG then
      STDERR.print buf
    else
      if stat_pp != 0 or stat_synth != 0 then
        STDERR.print buf
      end
    end
    begin
      Dir.mkdir "logs"
    rescue Errno::EEXIST
    end
    open("logs\\#{basename_exext}.log", "w"){|logfile|
      logfile.write buf
    }
    if stat_pp != 0 or stat_synth != 0 then
      $success = false
    end
    if File.size(target) == 0 then
      STDERR.puts "info: #{target} is empty. May be synthesize failed. Deleted."
      File.delete target
    end
  ensure
    err_pp.close! if err_pp
    err_synth.close! if err_synth
  end
  STDERR.puts "========" if RUN_NSLC_DEBUG
end

main
