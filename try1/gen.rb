
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
  def to_h(prefix=''); { "#{prefix}x" => @x, "#{prefix}y" => @y }; end
end

dx = 5
dy = -30
  #
ABILITIES = [

  os(point: Point.new(dx + 125, dy + 100), t:  'N', name: 'Strength'),
  os(point: Point.new(dx + 425, dy + 100), t:  'N', name: 'Intelligence'),
  os(point: Point.new(dx + 125, dy + 300), t:  'W', name: 'Constitution'),
  os(point: Point.new(dx + 435, dy + 300), t:  'E', name: 'Wisdom'),
  os(point: Point.new(dx + 125, dy + 500), t:  'W', name: 'Dexterity'),
  os(point: Point.new(dx + 425, dy + 500), t:  'E', name: 'Charisma'),

  os(point: Point.new(dx + 275, dy +  70), t:  'n', name: 'fortitude'),
  os(point: Point.new(dx + 355, dy + 160), t:  'n', name: 'will'),
  os(point: Point.new(dx + 470, dy + 200), t:  'w', name: 'learning'),
  os(point: Point.new(dx + 205, dy + 160), t:  'e', name: 'drive'),
  os(point: Point.new(dx + 110, dy + 205), t:  'w', name: 'physical'),
  os(point: Point.new(dx + 325, dy + 400), t:  'e', name: 'evasion'),
  os(point: Point.new(dx + 520, dy + 265), t:  'w', name: 'wit'),
  os(point: Point.new(dx + 230, dy + 400), t:  'e', name: 'presence'),
  os(point: Point.new(dx + 275, dy + 530), t:  'n', name: 'performance'),
  os(point: Point.new(dx + 460, dy + 370), t:  'w', name: 'mental'),
  os(point: Point.new(dx + 275, dy + 350), t:  'n', name: 'endurance'),
  os(point: Point.new(dx + 265, dy + 240), t:  'e', name: 'impulse'),
  os(point: Point.new(dx + 325, dy + 300), t:  'n', name: 'xxx'),
  os(point: Point.new(dx + 105, dy + 365), t:  'e', name: 'balance'),
  os(point: Point.new(dx +  40, dy + 280), t: 'ne', name: 'coordination'),
    ].inject({}) { |h, a|
      k = a.name[0, 3]
      k = k.upcase if k.match?(/^[A-Z]/)
      h[k] = a
      h }

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

    cr = 19
    c = xy.add(0, cr / 2 + 4)

    ddx = 20
    ddy = 24
    d = xy.add(-ddx / 2 - 8, -6)
    ds = Seq.new
    ds << d.add(-ddx, 0) << d.add(0, ddy) << d.add(ddx, 0) << d.add(0, -ddy)

    tp = xy.add(-3, -11)
    tr = abi.point.to_translate_s

    ttr =
      case abi.t
      when 'E', 'e' then 'translate(23 29)'
      when 'W'      then 'translate(-54 31)'
      when 'w'      then 'translate(-45 38)'
      when 'n'      then 'translate(1 0)'
      when 'ne'     then 'translate(17 12)'
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

    g(class: 'abilities') do

      g(class: 'links') do

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
      end

      g(class: 'abis') do

        ABILITIES.each { |k, v| ability(k, v) }
      end
    end
  end)

