# utf-8 coffesscript 2.0
# istats.widget v0.1
#
# by CFMoreu on ATOM
# UNLICENSE

# UI & input data
ui =
  margin: [20, 0, 0, 30]     # in units
  m_right: 20                 # in PX separation of charts in
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
ui.iconSize = ui.radius

# Terminal request
command: 'istats; pmset -g batt'

# refreshFrequency: false
refreshFrequency: ui.refresh*1000

# CSS3 stylish
style: """
  color: rgba(#{ui.color})
  font-family: Helvetica Neue

  #istats
    position: fixed
    margin: #{margin}

  #pmset
    position: fixed
    margin-top: #{ui.radius*3} px

  .bar, .bg
    fill: transparent
    stroke-width: #{ui.thickness}
    stroke-dasharray: #{ui.c} #{ui.c}

  .bar
    stroke: rgba(#{ui.color.slice 0, -5} 0.3)
    stroke-dasharray: #{ui.c*0.75} #{ui.c}

  .bg
    stroke: rgba(#{ui.color.slice 0, -5} 0.1)

  .circle
    transform: rotate(-90deg)

  .chart
    position: relative
    float: left
    margin-right: #{ui.m_right}px

  .desc
    position: absolute
    width: #{ui.radius*2}px
    top: #{ui.radius*2.15}px
    left: 0px
    margin: auto
    text-align: center

  .icon
    position: absolute
    margin: auto
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

# HTML5 structure
render: (output) -> """
  <div id="istats">
    <div id="stats"></div>
    <div id="pmset"></div>
  </div>
"""





# Parse output & Update function
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

  data.cgpuMAX = 90
  data.fanMAX  = 5000

  temPattern = /(\w+)\stemp:\s+(\d+.\d+)/               # End HeRegEx
  batPattern = /Current\scharge:/
  powPattern = /(\d+[.\d+]+)%/
  bxxPattern =
    count    : /(count):\s+(\d+)/
    cycles   : /(cycles):\s+(\d+)/
    drawin    : /Now\s(drawin)g\sfrom\s'(\w+[\s\w+]+)'/
    time     : /(\d+:\d+)\s(remain)ing/
  bxx = ['count', 'cycles', 'drawn', 'time']
  fanPattern = /Fan\s\d+\sspeed:\s+(\d+)\sRPM/

  out = output.split('\n')
  content = ''

  if output.match batPattern
    other = "There is a battery"
  else
    other = "There is NO battery"

  fan_c = 0

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
    if output.match batPattern
      for value in Object.values bxxPattern
        if i.match value
          txt = i.match value
          k = txt[1]
          v = txt[2]
          if v == 'remain'
            v = k
            k = 'remain'
          data.batt[k] = v
    if i.match fanPattern
      txt = i.match fanPattern
      data.fan[fan_c] = txt[1]
      fan_c += 1

  chart=
    cpu:  [data.temp.cpu/data.cgpuMAX*ui.c, "#{data.temp.cpu} ºC",  "cpu"]
    gpu:  [data.temp.gpu/data.cgpuMAX*ui.c, "#{data.temp.gpu} ºC",  "gpu"]
  if output.match batPattern
    chart.batt = [data.batt.charge/100*ui.c, "#{data.batt.drawin}",  "batt0"]
    if data.batt.drawin == "AC Power"
      if data.batt.remain == "0:00"
        chart.batt[1]="AC"
        chart.batt[2]="batt2"
      else
        chart.batt[1]=data.batt.remain
        chart.batt[2]="batt2"
    else
      chart.batt[1]=data.batt.remain
  i = 0
  while i < data.fan.length
    k = "fan"+i
    chart[k] = [data.fan[i]/data.fanMAX*ui.c, "#{data.fan[i]} RPM", "fan"]
    i+=1

  for k in Object.keys chart
    j=chart[k]
    circ=j[0]
    if k.match /(fan)\d+/
      value = k.match /(fan)\d+/
      k = value[1]
    content += """
    <div id="#{k}-stats" class="chart">
      <svg class="circle" width='#{ui.radius*2}px' height='#{ui.radius*2}px'>
        <circle class='bg' r='#{ui.radius-ui.thickness/2}' cx='#{ui.radius}' cy='#{ui.radius}' />
        <circle class='bar' r='#{ui.radius-ui.thickness/2}' cx='#{ui.radius}' cy='#{ui.radius}'
        style='stroke-dasharray: #{circ} #{ui.c}'/>
      </svg>
      <svg id="#{k}-icon" class="icon">
        <use xlink:href="istats.widget/icon_sprites-04.svg##{j[2]}" />
      </svg>
      <span class="desc">#{j[1]}</span>
    </div>
    """

  # other=""
  # for k in Object.keys chart
  #   other+=k

  dom.find('#stats').html content
  # dom.find('#pmset').html other
