#!/usr/bin/env ruby -w

def parse_element(line)
  return nil if line.strip.empty?

  name, attrs_str = line.split('=').map(&:strip)
  return nil unless attrs_str

  attrs = {}
  attrs_str.split(',').each do |attr|
    key, value = attr.split(':').map(&:strip)
    attrs[key] = value
  end

  {
    name: name,
    position: attrs['position'].to_i,
    number: attrs['number'].to_i,
    symbol: attrs['small'],
    molar: attrs['molar'],
    electron: attrs['electron'].to_i
  }
end

def parse_periodic_table(file_path)
  elements = []
  File.readlines(file_path).each do |line|
    element = parse_element(line)
    elements << element if element
  end
  elements
end

def generate_html(elements)
  elements_by_position = {}
  elements.each { |e| elements_by_position[e[:position]] = e }

  html = <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Periodic Table of Elements</title>
      <style>
        table { border-collapse: collapse; margin: 20px auto; }
        td { border: 1px solid black; padding: 10px; vertical-align: top; min-width: 100px; }
        td.empty { border: none; }
        h4 { margin: 0 0 10px 0; }
        ul { margin: 0; padding-left: 20px; }
      </style>
    </head>
    <body>
      <table>
  HTML

  rows = [
    (0..17),
    (18..35),
    (36..53),
    (54..71),
    (72..89),
    (90..107),
    (108..125),
    [],
    (126..143),
    (144..161)
  ]

  rows.each do |row_range|
    if row_range.is_a?(Array) && row_range.empty?
      html += "    <tr><td class=\"empty\" colspan=\"18\">&nbsp;</td></tr>\n"
      next
    end

    html += "    <tr>\n"
    row_range.each do |pos|
      element = elements_by_position[pos]
      if element
        html += <<~CELL
              <td style="border: 1px solid black; padding:10px">
                <h4>#{element[:name]}</h4>
                <ul>
                  <li>No #{element[:number]}</li>
                  <li>#{element[:symbol]}</li>
                  <li>#{element[:molar]}</li>
                  <li>#{element[:electron]} electron#{element[:electron] > 1 ? 's' : ''}</li>
                </ul>
              </td>
        CELL
      else
        html += "      <td class=\"empty\"></td>\n"
      end
    end
    html += "    </tr>\n"
  end

  html += <<~HTML
      </table>
    </body>
    </html>
  HTML

  html
end

def main
  file_path = File.join(File.dirname(__FILE__), 'periodic_table.txt')
  elements = parse_periodic_table(file_path)
  html = generate_html(elements)

  output_path = File.join(File.dirname(__FILE__), 'periodic_table.html')
  File.write(output_path, html)
  puts "Generated #{output_path}"
end

main
