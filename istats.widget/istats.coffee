# utf-8 coffesscript 2.0
# istats.widget v0.1
#
# by CFMoreu on ATOM
# UNLICENSE
# 
# Battery Installed
# Fully Charged
# Charging

# UI input data
ui =
  margin: [200, 0, 0, 50]
  units : 'px'
  color : 'white, 0.5'
  coInv : 'black, 0.5'
  invert: false

# Processing UI data
ui.color = ui.coInv if ui.invert == true
margin   = ''
count    = 0
for i in ui.margin
  el     = ui.margin[count]
  margin += ' '+el+ui.units
  count++

battery = true

command: 'istats; pmset -g batt'

refreshFrequency: 3000

style: """
  margin: #{margin}
  color: rgba(#{ui.color})
  font-family: Helvetica Neue
"""

render: (output) -> """
  <div class="istats"></div>
  <div class="pmset"></div>
"""

update: (output, domEl) ->
  # Define constants, and extract the juicy html.
  dom = $(domEl)

  data =
    temp: []       # [cpu, gpu, battery]
    batt: []       # [charge, drawn, health, time]
    fan : []       # [numbers, speed1, speed2, speed...]
  unit =
    temp   : 'ºC'
    charge : '%'
    time   : ''
    speed  : 'RPM'

  temPattern = ///  # Begin HeRegEx
    (\w+)           # one or more letter followed by 'PU'
    \stemp:\s+      # ' temp:' followed by one or more ' '
    (\d+.\d+)       # one or more digit followed by . and one or more digit
  ///               # End HeRegEx

  batPattern = /Current\scharge:/
  powPattern = /(\d+[.\d+]+)%/
  bxxPattern =
    count    : /(count):\s+(\d+)/
    cycles   : /(cycles):\s+(\d+)/
    drawn    : /Now\s(drawin)g\sfrom\s'(\w+[\s\w+]+)'/
    time     : /(\d+:\d+)\s(remain)ing/
  bxx = ['count', 'cycles', 'drawn', 'time']

  out = output.split('\n')
  content = ''

  for i in out
    if i.match temPattern
      txt = i.match temPattern
      k = txt[1].toLowerCase()
      v = Math.round(parseFloat(txt[2]))
      data.temp[k] = v
    if i.match batPattern
      txt = i.match powPattern
      k = 'charge'
      v = txt[1]
      data.batt[k] = v
    for value in Object.values bxxPattern
      if i.match value
        txt = i.match value
        k = txt[1]
        v = txt[2]
        if v == 'remain'
          v = k
          k = 'remain'
        data.batt[k] = v
      # data.batt.push txt[2]
      # data.batt.push txt[3]
      # data.batt.push txt[4]


  # for k in data.temp
    # content += "#{k}: #{data.temp[k]} ºC<br>"
  # for k in data.batt
    # content += "#{k}: #{data.batt[k]}<br>"
  for it in Object.keys data
    i = data[it]
    if i == data.temp
      for key in Object.keys i
        val = i[key]
        u = unit.temp
        content += "#{key}: #{val} #{u}<br>"
    if i == data.batt
      for key in Object.keys i
        val = i[key]
        content += "batt.#{key}: #{val}<br>"
      val = Math.round(100-(data.batt.count/data.batt.cycles*100))
      content += "batt.life: #{val} %<br>"
    if i == data.fan
      content += "fan<br>"

  dom.find('.istats').html 'iStats'
  dom.find('.pmset').html content
