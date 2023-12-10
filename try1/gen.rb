
#
# try1/gen.rb
#

require 'stringio'


class Point

  def initialize(x, y); @x = x; @y = y; end

  def add!(x, y); @x += x;@y += y; self; end

  def add(x, y); Point.new(@x + x, @y + y); end

  def to_s; "#{@x},#{@y}"; end

  def to_h(prefix='')

    { "#{prefix}x" => @x, "#{prefix}y" => @y }
  end
end

class Seq

  def initialize; @a = []; end

  def <<(e); @a << e; self; end

  def to_s; @a.map(&:to_s).join(' '); end
end

class Svg

  #
  # general svg

  def initialize(w, h, vb=nil, &block)

    @out = StringIO.new

    @out <<
      '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' << "\n" <<
      '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" ' <<
      '"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">' << "\n"

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
  def text(text, attributes={}); tag('text', attributes, text); end
  def style(s); tag('style', {}, s); end

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

  def ability(x, y, name, nam)

    xy = Point.new(0, 0)

    cr = 13
    c = xy.add(0, cr / 2 + 4)

    ddx = 12
    ddy = 15
    d = xy.add(-ddx / 2 - 4, 0)
    ds = Seq.new
    ds << d.add(-ddx, 0) << d.add(0, ddy) << d.add(ddx, 0) << d.add(0, -ddy)

    t = "translate(#{x} #{y})"

    tp = xy.add(0, cr * 2 + 4)

    g(id: name.downcase, class: 'ability', transform: t) do
      circle(c.to_h('c').merge(r: cr))
      polygon(points: ds)
      #circle(xy.to_h('c').merge(id: 'xy', r: 2))
      text(nam, tp.to_h.merge(class: 'label'))
    end
  end
end

puts(
  Svg.new('300pt', '300pt') do
    style(%{
      #xy { fill: red; stroke: red; stroke-width: 2pt; }
      .ability circle {
        fill: white;
        stroke: lightgrey;
        stroke-width: 3pt;
      }
      .ability polygon {
        fill: white;
        stroke: grey;
        stroke-width: 3pt;
      }
      .ability .label {
        font-family: Helvetica Neue;
        font-size: 12pt;
      }
    })
    ability(100, 100, 'Strength', 'STR')
    ability(200, 100, 'Intelligence', 'INT')
  end)

