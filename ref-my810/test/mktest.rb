# coding: utf-8
# mktest.rb
#

if ARGV.size != 1 then
  STDERR.puts "usage: ruby mktest.rb SOURCEFILE"
  exit 2
end

buf = []
open(ARGV[0]){|src|
  src.each_line {|line|
    bkup = line.dup
    line.chomp!

    line.sub!(/#.*/){""}
    line.strip!
    tokens = line.split /[\s]+/
    next if tokens.empty?

    # 先頭のトークンはアドレス
    head = tokens.shift
    a = head.to_i 16
    if buf.size != a then
      STDERR.puts "先頭トークンによるアドレスに不整合があります"
      STDERR.puts "入力行は:"
      STDERR.print bkup
      exit 2
    end

    # 残りを buf に詰めてゆく
    tokens.each{|hex|
      v = hex.to_i 16
      if v < 0 or v > 255 then
        STDERR.puts "値が異常です"
        STDERR.puts "トークンは: \"#{hex}\""
      end
      buf << v
    }
  }
}
print "    mem memory_cell[256][8] = {\n"
until buf.empty? do
  print "      "
  tmp = buf.shift 8
  print(tmp.map {|x| "%#04x" % [x]}.join(", "))
  if tmp.size != 8 then
    print(", 0x00" * (8 - tmp.size))
  end
  unless buf.empty? then
    print ",\n"
  end
end
print "} ;\n"
