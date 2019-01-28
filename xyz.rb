require 'optparse'
require 'RMagick'

option = {}
OptionParser.new do |opt|
  opt.on('-s', '--src=VALUE', 'Source file path') {|v| option[:src] = v}
  opt.on('-d', '--dst=VALUE', 'Destination file path') {|v| option[:dst] = v}
  opt.on('-f', '--flip=VALUE', 'Flip u | v | uv | vu') {|v| option[:flip] = v}
  opt.on('--sub=VALUE', 'Subtract RGB by 0.0 - 1.0') {|v| option[:sub] = v}
  opt.on('--split', 'Split RGB channels') {|v| option[:split] = v}
  opt.on('--resize=VALUE', 'Resize by 0.0 - 1.0') {|v| option[:resize] = v}
  opt.parse!(ARGV)
end
dst_path = option[:dst] || option[:src].gsub(/(.+)\.(.*)/, '\1_' + Time.now.to_i.to_s + '.\2')
raise 'Required the source file path. You can see help using --help option.' unless option[:src]

puts option.merge(dst: dst_path)

img = Magick::ImageList.new(option[:src])

img = if option[:sub]
        sub = [[option[:sub].to_f, 0].max, 1].min.to_f * 65535
        for y in 0...img.rows
          for x in 0...img.columns
            pix = img.pixel_color(x, y)
            new_pix = Magick::Pixel.new((pix.red - sub).clamp(0, 65535), (pix.green - sub).clamp(0, 65535), (pix.blue - sub).clamp(0, 65535))
            img.pixel_color(x, y, new_pix)
          end
        end
        img
      end

img = if option[:flip]
        case option[:flip].downcase
        when 'u'
          img.flop
        when 'v'
          img.flip
        when 'uv'
          img.flop
          img.flip
        when 'vu'
          img.flip
          img.flop
        else
          img
        end
      end

img = if option[:resize]
        resize_ratio = [[option[:resize].to_f, 0].max, 1].min.to_f
        img.resize_to_fit(img.columns * resize_ratio, img.rows * resize_ratio)
      end

if option[:split]
  split_base = Magick::Image.new(img.columns, img.rows)
  img_rgb = [split_base.dup, split_base.dup, split_base.dup]

  for y in 0...img.rows
    for x in 0...img.columns
      pix = img.pixel_color(x, y)
      img_rgb[0].pixel_color(x, y, Magick::Pixel.new(pix.red, pix.red, pix.red))
      img_rgb[1].pixel_color(x, y, Magick::Pixel.new(pix.green, pix.green, pix.green))
      img_rgb[2].pixel_color(x, y, Magick::Pixel.new(pix.blue, pix.blue, pix.blue))
    end
  end
  img_rgb[0].write(dst_path.gsub(/(.+)\.(.*)/, '\1_red.\2'))
  img_rgb[1].write(dst_path.gsub(/(.+)\.(.*)/, '\1_green.\2'))
  img_rgb[2].write(dst_path.gsub(/(.+)\.(.*)/, '\1_blue.\2'))
  img_rgb.each(&:destroy!)
else
  img.write(dst_path)
end

img.destroy!
