
#
# try1/gen.rb
#

require 'stringio'

class Svg

  #
  # general svg

#<svg width="506pt" height="332pt"
# viewBox="0.00 0.00 506.00 332.00" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  def initialize(w, h, vb=nil, &block)

    @out = StringIO.new

    @out <<
      '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' <<
      '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" ' <<
      '"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">' <<
      "\n"

    vb = vb || "0 0 #{w.to_i} #{h.to_i}"

    tag('svg', { width: w, height: h, viewBox: vb }, &block)
  end

  def to_s

    @out.string
  end

  def g(attributes={}, &block)

    tag('g', attributes, &block)
  end

  def tag(name, attributes, &block)

    @out << '<' << name
    attributes.each do |k, v|
      @out << ' ' << k << '="' << v.to_s << '"' if v != nil
    end
    @out << '>'
    if block
      @out << "\n"
      block.call
      #@out << "\n"
    end
    @out << '</' << name << ">\n"
  end

  #
  # kabbatt

  def draw_attribute(x, y, name, nam, &block)

    g(id: nam, class: 'attribute', &block)
  end
end

puts(
  Svg.new('100pt', '200pt') do
    draw_attribute(10, 10, 'Strength', 'STR')
  end)

