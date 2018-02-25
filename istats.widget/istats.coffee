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
  radius: 470                  # in PX
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
ui.iconSize = ui.radius*.5
ui.iconSet = ['\\f002', '\\f108', '\\f553', '\\f66f']
ui.iconSelect = ui.iconSet[3]

battery = true

command: 'pmset -g batt'

#refreshFrequency: ui.sec*1000/20
refreshFrequency: ui.refresh*1000

style: """
  margin: #{margin}
  color: rgba(#{ui.color})
  font-family: Helvetica Neue

  @font-face
    font-family: 'Icons'
    src: url('istats.widget/icons.ttf') format('truetype')
    font-weight: normal
    font-style: normal

  [class^='icon-'], [class*=' icon-']
    font-family: 'Icons'
    background: none
    width: auto
    height: auto
    font-style: normal

  #istats
    position: absolute
    margin: 0rem 0rem 0rem 0rem
    padding: 0 0

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

  .chart i
    animation-name: rotation
    animation-duration: #{ui.sec}s
    animation-delay: 0s
    animation-timing-function: linear
    animation-iteration-count: infinite

  .chart .icon
    position: fixed
    font-size: #{ui.iconSize}px
    top: #{Math.round(ui.margin[0]+ui.radius-(ui.iconSize/0.8185)/2)}px
    left: #{Math.round(ui.margin[3]+ui.radius-ui.iconSize/2)}px
    transform-origin: 50.095% 52.81%

  .chart svg
    transform: rotate(-90deg)


  .chart .icon-cpu:before
    content: '#{ui.iconSelect}'

  .chart .icon-fan
    fill: 'white'

  @keyframes rotation
    from {transform: rotate(0+#{ui.desfase}deg)}
    to {transform: rotate(360*#{ui.vueltas}+#{ui.desfase}deg)}
"""

render: (output) -> """
  <link rel="import" href="icon-sprites-01.svg" />
  <div id="istats">
    <div id="stats">
      <div class="chart"></div>
    </div>
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
  myCircle = """
  <i class="icon icon-cpu"></i>
  <svg width='#{ui.radius*2}px' height='#{ui.radius*2}px'>
    <circle class='bg' r='#{ui.radius-ui.thickness/2}' cx='#{ui.radius}' cy='#{ui.radius}' />
    <circle class='bar' r='#{ui.radius-ui.thickness/2}' cx='#{ui.radius}' cy='#{ui.radius}'
    style='stroke-dasharray: #{ui.c/2} #{ui.c}'/>
  </svg>
  <svg class="svg icon-fan">
    <use xlink:href="#fan"></use>
  </svg>
  """
  # style='stroke-dasharray: #{data.temp.cpu/data.temp.cgpuMAX*ui.c} #{ui.c}'/>

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

  # dom.find('.istats').html 'iStats'
  dom.find('.chart').html myCircle
  # dom.find('.pmset').html content
