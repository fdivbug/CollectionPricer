require 'nokogiri'
require 'open-uri'

require 'pp'

def css_bullshit_to_int(str)
  md = /^background-position: (-?[0-9]+\.?[0-9]*[a-z][a-z]) /.match(str)
  leftpos = md[1]
  case leftpos
  when '-49.5pt', '-66px', '-5.52em'
    '0'
  when '0pt', '-5.25em', '0em', '0px'
    '1'
  when '-0.6em', '-5pt', '-7px'
    '2'
  when '-1.15em', '-14px', '-10.5pt'
    '3'
  when '-1.79em', '-21px', '-16pt'
    '4'
  when '-21pt', '-2.35em', '-28px'
    '5'
  when '-2.9em', '-35px', '-26pt'
    '6'
  when '-32pt', '-42px', '-3.47em'
    '7'
  when '-49px', '-4.2em', '-37pt'
    '8'
  when '-56px', '-42pt'
    '9'
  when '-63px', '-47.5pt'
    '.'
  else
    "<<#{leftpos}>>"
  end
end

namespace :buylist do
  desc "Update the prices in the database from Star City Games' buylist page."
  task :update => :environment do
    BuyListURL = "http://sales.starcitygames.com/buylist/"
    Nbsp = Nokogiri::HTML("&nbsp;").text
    css = CssParser::Parser.new
    columns = []
    cards = {}

    doc = Nokogiri::HTML(open(BuyListURL))
    css.add_block! doc.xpath('//style')[1].text

    doc.xpath("//style/following-sibling::table[not (@class='content_bump')]/tr").each do |row|
      cells = []
      ed_headers = row.xpath("td[@width='33%']")
      if ed_headers.size > 0
        columns = ed_headers.map {|x| x.text.sub(' (Foil)', '') }
        next
      else
        names = row.xpath("td[@align='left' or @colspan='2']").map {|x| x.text.gsub(Nbsp, ' ') }
        next if names.size < 1
        deets = row.xpath("td[@width='15']/preceding-sibling::td[not (@width='15')]")
        deets.each do |cell|
          if cell['colspan'] == '2' # Empty column
            cells += [nil, nil]
          elsif cell['align'] == 'left' # Card name
            name = cell.text
            print "#{name}  "
            cells << name
          else # Card price
            numdivs = cell.css("div.numdiv")
            value = ''
            numdivs.each do |x|
              value += css_bullshit_to_int(css.find_by_selector(".#{x['class'].split.first}").first)
            end
            puts value
            cells << value.to_f
          end
        end
      end
      columns.each do |expansion|
        name, value = cells.shift(2)
        next if name == nil && value == nil
        unless cards.has_key? expansion
          cards[expansion] = {}
        end
        cards[expansion][name] = value
      end
    end
    pp cards
  end

end
