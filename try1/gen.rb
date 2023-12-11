
#
# try1/gen.rb
#

require 'ostruct'
require 'stringio'


class Point

  attr_reader :x, :y

  def initialize(x, y); @x = x; @y = y; end

  def add!(x, y); @x += x;@y += y; self; end

  def add(x, y); Point.new(@x + x, @y + y); end

  def to_s; "#{@x},#{@y}"; end

  def to_translate_s; "translate(#{@x} #{@y})"; end

  def to_h(prefix='')

    { "#{prefix}x" => @x, "#{prefix}y" => @y }
  end
end

ABILITIES = {
  'STR' => OpenStruct.new(point: Point.new(100, 100), name: 'Strength'),
  'INT' => OpenStruct.new(point: Point.new(400, 100), name: 'Intelligence'),
  'CON' => OpenStruct.new(point: Point.new(100, 300), name: 'Constitution'),
  'WIS' => OpenStruct.new(point: Point.new(400, 300), name: 'Wisdom'),
  'DEX' => OpenStruct.new(point: Point.new(100, 500), name: 'Dexterity'),
  'CHA' => OpenStruct.new(point: Point.new(400, 500), name: 'Charisma'),

  'for' => OpenStruct.new(point: Point.new(250, 100 - 30), name: 'fortitude'),
  'wil' => OpenStruct.new(point: Point.new(340, 180), name: 'will'),
  'lea' => OpenStruct.new(point: Point.new(400 + 30, 200), name: 'learning'),
}

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
  def path(attributes={}, &block); tag('path', attributes, &block); end
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

  def ability(txy, name, nam)

    xy = Point.new(0, 0)

    cr = 13
    c = xy.add(0, cr / 2 + 4)

    ddx = 12
    ddy = 17
    d = xy.add(-ddx / 2 - 7, -3)
    ds = Seq.new
    ds << d.add(-ddx, 0) << d.add(0, ddy) << d.add(ddx, 0) << d.add(0, -ddy)

    tp = xy.add(-3, -11);

    g(id: name.downcase, class: 'ability', transform: txy.to_translate_s) do
      circle(c.to_h('c').merge(r: cr))
      polygon(points: ds)
      #circle(xy.to_h('c').merge(id: 'xy', r: 2))
      text(nam, tp.to_h.merge(class: 'label'))
    end
  end

  def link(*ks)

    abis = ks.map { |k| ABILITIES[k] }
    pts = abis.map { |a| a.point }

    seq = Seq.new

    #if ks.size == 2
    #  seq << 'M' << abis[0].point.add(0, 7) << 'L' << abis[1].point.add(0, 7)
    #else
    qp = Point.new(
      pts[1].x * 2 - (pts[0].x + pts[2].x) / 2,
      pts[1].y * 2 - (pts[0].y + pts[2].y) / 2)
    seq << 'M' << pts[0].add(0, 7) << 'Q' << qp.add(0, 7) << pts[2].add(0, 7)
    #end

    path(d: seq, class: 'link0', id: ks.join('-') + '-0')
    path(d: seq, class: 'link1', id: ks.join('-') + '-1')
  end
end

puts(
  Svg.new('1000pt', '1000pt') do
    style(%{
#xy { fill: red; stroke: red; stroke-width: 2pt; }
path.link0 {
  stroke: lightgrey;
  stroke-width: 10pt;
  stroke-linecap: round;
  stroke-linejoin: round;
  fill: none;
}
path.link1 {
  stroke: white;
  stroke-width: 4pt;
  stroke-linecap: round;
  stroke-linejoin: round;
  fill: none;
}
.ability circle {
  fill: white;
  stroke: lightgrey;
  stroke-width: 3pt;
}
.ability polygon {
  fill: white;
  stroke: #bfbfbf;
  stroke-width: 3pt;
}
.ability .label {
  color: grey;
  font-family: Helvetica Neue;
  font-size: 12pt;
}
    })

    link('STR', 'for', 'INT')
    link('STR', 'wil', 'WIS')
    link('INT', 'lea', 'WIS')

    ABILITIES.each do |k, v|
      ability(v.point, v.name, k)
    end
  end)

