
def utf16le_bom
  if RUBY_VERSION > "1.9"
    [0xff, 0xfe].collect{|byte| byte.chr}.join.force_encoding("utf-16le")
  else
    [0xff, 0xfe].collect{|byte| byte.chr}.join
  end
end
