
#
# try1/gen.rb
#

require 'ostruct'
require 'stringio'

def os(h); OpenStruct.new(h); end

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

  'STR' => os(point: Point.new(125, 100), t: 'N', name: 'Strength'),
  'INT' => os(point: Point.new(425, 100), t: 'N', name: 'Intelligence'),
  'CON' => os(point: Point.new(130, 300), t: 'W', name: 'Constitution'),
  'WIS' => os(point: Point.new(430, 300), t: 'E', name: 'Wisdom'),
  'DEX' => os(point: Point.new(125, 500), t: 'W', name: 'Dexterity'),
  'CHA' => os(point: Point.new(425, 500), t: 'E', name: 'Charisma'),

  'for' => os(point: Point.new(275,  70), t: 'n', name: 'fortitude'),
  'wil' => os(point: Point.new(345, 160), t: 'n', name: 'will'),
  'lea' => os(point: Point.new(460, 200), t: 'w', name: 'learning'),
  'dri' => os(point: Point.new(195, 160), t: 'e', name: 'drive'),
  'phy' => os(point: Point.new(105, 220), t: 'w', name: 'physical'),
  'eva' => os(point: Point.new(325, 400), t: 'e', name: 'evasion'),
  'wit' => os(point: Point.new(525, 270), t: 'w', name: 'wit'),
  'pre' => os(point: Point.new(235, 400), t: 'e', name: 'presence'),
  'per' => os(point: Point.new(275, 530), t: 'n', name: 'performance'),
  'men' => os(point: Point.new(455, 370), t: 'w', name: 'mental'),
  'end' => os(point: Point.new(275, 350), t: 'n', name: 'endurance'),
  'imp' => os(point: Point.new(265, 240), t: 'e', name: 'impulse'),
  'xxx' => os(point: Point.new(325, 300), t: 'n', name: 'xxx'),
  'bal' => os(point: Point.new(110, 380), t: 'e', name: 'balance'),
  'coo' => os(point: Point.new( 40, 280), t: 'e', name: 'coordination'),
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

  def ability(key, abi)

    xy = Point.new(0, 0)

    cr = 17
    c = xy.add(0, cr / 2 + 4)

    ddx = 17
    ddy = 21
    d = xy.add(-ddx / 2 - 8, -4)
    ds = Seq.new
    ds << d.add(-ddx, 0) << d.add(0, ddy) << d.add(ddx, 0) << d.add(0, -ddy)

    tp = xy.add(-3, -11)
    tr = abi.point.to_translate_s

    ttr =
      case abi.t
      when 'E', 'e' then 'translate(19.5 30)'
      when 'W' then 'translate(-53 30)'
      when 'w' then 'translate(-41 30)'
      when 'n' then 'translate(1 0)'
      else ''; end

    cs = 'ability'
    cs += ' core' if key.match(/^[A-Z]+$/)

    g(id: abi.name.downcase, class: cs, transform: tr) do
      circle(c.to_h('c').merge(r: cr))
      polygon(points: ds)
      #circle(xy.to_h('c').merge(id: 'xy', r: 2))
      text(key, tp.to_h.merge(class: 'label', transform: ttr))
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
  Svg.new('600pt', '600pt') do
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
.ability.core circle { stroke: #9f9f9f; }
.ability.core polygon { stroke: grey; }
.ability .label {
  color: grey;
  font-family: monospace;
  font-size: 12pt;
}
    })

    link('STR', 'for', 'INT')
    link('STR', 'wil', 'WIS')
    link('INT', 'lea', 'WIS')
    link('INT', 'dri', 'CON')
    link('STR', 'phy', 'CON')
    link('INT', 'eva', 'DEX')
    link('INT', 'wit', 'CHA')
    link('STR', 'pre', 'CHA')
    link('DEX', 'per', 'CHA')
    link('WIS', 'men', 'CHA')
    link('CON', 'end', 'WIS')
    link('WIS', 'imp', 'DEX')
    link('CON', 'xxx', 'CHA')
    link('CON', 'bal', 'DEX')
    link('STR', 'coo', 'DEX')

    ABILITIES.each { |k, v| ability(k, v) }
  end)

