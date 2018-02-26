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
  margin: [20, 0, 0, 30]     # in units
  radius: 50                  # in PX
  units : 'px'
  color : 'white, 0.5'
  coInv : 'black, 0.5'
  invert: true
  vueltas: 90*1               # RPM
  desfase: 0
  thickness: 8                # % of radius
  sec: 60
  refresh: 3                  # s of refresh

# Processing UI data
ui.color = ui.coInv if ui.invert == true
margin   = ''
count    = 0
for i in ui.margin
  el     = ui.margin[count]
  margin += ' '+el+ui.units
  count++
ui.thickness = ui.thickness*ui.radius/100
ui.c = Math.floor 2*Math.PI*(ui.radius-ui.thickness/2)
ui.iconSize = ui.radius*1.2

battery = true

command: 'istats; pmset -g batt'

refreshFrequency: false
# refreshFrequency: ui.refresh*1000

style: """
  color: rgba(#{ui.color})
  font-family: Helvetica Neue
  font-size: 12px

  #istats
    position: fixed
    margin: 50px 0px 0px 50px
    padding: 0px 0px

  .bar
    fill: transparent
    stroke: rgba(#{ui.color.slice 0, -5} 0.3)
    stroke-width: #{ui.thickness}
    stroke-dasharray: 20 #{ui.c}

  .bg
    fill: transparent
    stroke: rgba(#{ui.color.slice 0, -5} 0.1)
    stroke-width: #{ui.thickness}
    stroke-dasharray: #{ui.c} #{ui.c}

  .circle
    transform: rotate(-90deg)

  .chart
    position: relative
    float: left
    margin: 0px 30px 0px 0px
    padding: 0 0

  .desc
    position: absolute
    width: #{ui.radius*2}px
    bottom: -20px
    left: 0px
    margin: auto
    text-align: center

  .icon
    position: absolute
    top: #{ui.radius-ui.iconSize/2}px
    left: #{ui.radius-ui.iconSize/2}px
    width: #{ui.iconSize}px
    height: #{ui.iconSize}px
    fill: rgba(#{ui.color})

  #fan-icon
    animation-name: rotation
    animation-duration: #{ui.sec}s
    animation-delay: 0s
    animation-timing-function: linear
    animation-iteration-count: infinite

  @keyframes rotation
    from {transform: rotate(0+#{ui.desfase}deg)}
    to {transform: rotate(360*#{ui.vueltas}+#{ui.desfase}deg)}
"""

# top: #{ui.margin[0]+ui.radius-ui.iconSize/2}px
# left: #{ui.margin[3]+ui.radius-ui.iconSize/2}px

  # <link rel="import" href="istats.widget/icon_sprites-01.svg" />
render: (output) -> """
  <div id="istats">
    <div id="stats"></div>
    <div class="pmset"></div>
  </div>
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

  data.temp.cgpuMAX = 90

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
  # ui.rotate += 10
  for k in Object.keys data.temp
    circ=data.temp[k]/data.temp.cgpuMAX*ui.c
    content += """
    <div id="#{k}-stats" class="chart">
      <svg class="circle" width='#{ui.radius*2}px' height='#{ui.radius*2}px'>
        <circle class='bg' r='#{ui.radius-ui.thickness/2}' cx='#{ui.radius}' cy='#{ui.radius}' />
        <circle class='bar' r='#{ui.radius-ui.thickness/2}' cx='#{ui.radius}' cy='#{ui.radius}'
        style='stroke-dasharray: #{circ} #{ui.c}'/>
      </svg>
      <svg id="fan-icon" class="icon">
        <use xlink:href="istats.widget/icon_sprites-01.svg#fan" />
      </svg>
      <span class="desc">#{k}: #{data.temp[k]} ºC</span>
    </div>
    """
# <span class="desc">#{k}: #{data.temp[k]} ºC</span>

  # for it in Object.keys data
  #   i = data[it]
  #   if i == data.temp
  #     for key in Object.keys i
  #       val = i[key]
  #       u = unit.temp
  #       content += "#{key}: #{val} #{u}<br>"
  #   if i == data.batt
  #     for key in Object.keys i
  #       val = i[key]
  #       content += "batt.#{key}: #{val}<br>"
  #     val = Math.round(100-(data.batt.count/data.batt.cycles*100))
  #     content += "batt.life: #{val} %<br>"
  #   if i == data.fan
  #     content += "fan<br>"

  # dom.find('.istats').html 'iStats'
  dom.find('#stats').html content
  # dom.find('head').appendChild '<link rel="import" href="istats.widget/icon-sprites-01.svg" />'
  # dom.find('.pmset').html content
