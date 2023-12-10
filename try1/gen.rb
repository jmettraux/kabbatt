
#
# try1/gen.rb
#

require 'stringio'

class Svg

  #
  # general svg

  def initialize(w, h, vb=nil, &block)

    @out = StringIO.new

    @out <<
      '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' << "\n" <<
      '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" ' <<
      '"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">' <<
      "\n"

    vb = vb || "0 0 #{w.to_i} #{h.to_i}"

    h = { width: w, height: h, viewBox: vb }
    h['xmlns'] = "http://www.w3.org/2000/svg"
    h['xmlns:xlink'] = "http://www.w3.org/1999/xlink"

    tag('svg', h, &block)
  end

  def to_s

    @out.string
  end

  def g(attributes={}, &block); tag('g', attributes, &block); end
  def circle(attributes={}, &block); tag('circle', attributes, &block); end
  def polygon(attributes={}, &block); tag('polygon', attributes, &block); end
  def title(text, attributes={}); tag('title', attributes, text); end

  def tag(name, attributes, text=nil, &block)

    @out << '<' << name
    attributes.each do |k, v|
      @out << ' ' << k << '="' << v.to_s << '"' if v != nil
    end
    if block
      @out << '>'
      @out << "\n"
      instance_eval(&block)
      #@out << "\n"
      @out << '</' << name << ">\n"
    elsif text
      @out << '>' << text << '</' << name << ">\n"
    else
      @out << "/>\n"
    end
  end

  #
  # kabbatt

  #<circle cx="100" cy="100" r="50" fill="blue" />
  #<polygon points="100,50 150,100 100,150 50,100" fill="red" />
  def ability(x, y, name, nam)

    r = 5
    cx = x + r
    cy = y + r

    g(id: nam, class: 'ability') do
      title(nam)
      circle(cx: cx, cy: cy, r: r, fill: 'white', stroke: 'black')
    end
  end
end

puts(
  Svg.new('300pt', '300pt') do
    ability(100, 100, 'Strength', 'STR')
  end)

