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
ui.iconSize = ui.radius

battery = true

command: 'pmset -g batt'

refreshFrequency: false
# refreshFrequency: ui.refresh*1000

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

  .cpu-icon
    position: fixed
    width: #{ui.iconSize}px
    height: #{ui.iconSize}px
    top: #{ui.margin[0]+ui.radius-ui.iconSize/2}px
    left: #{ui.margin[3]+ui.radius-ui.iconSize/2}px
    fill: rgba(#{ui.color})

  .fan-icon
    position: fixed
    width: #{ui.iconSize}px
    height: #{ui.iconSize}px
    top: #{ui.margin[0]+ui.radius-ui.iconSize/2}px
    left: #{ui.margin[3]+ui.radius-ui.iconSize/2}px
    fill: rgba(#{ui.color})
    transform: rotate(90deg)
    animation-name: rotation
    animation-duration: #{ui.sec}s
    animation-delay: 0s
    animation-timing-function: linear
    animation-iteration-count: infinite

  @keyframes rotation
    from {transform: rotate(0+#{ui.desfase}deg)}
    to {transform: rotate(360*#{ui.vueltas}+#{ui.desfase}deg)}
"""


  # <link rel="import" href="istats.widget/icon-sprites-01.svg" />
render: (output) -> """
  <svg style="display:none;">
   <symbol id="cpu"   viewBox="0 0 809.45 809.45">
     <path d="M678.9,253.65v36.56H801a8.49,8.49,0,0,1,8.49,8.49v12.86a8.49,8.49,0,0,1-8.49,8.49H678.9v36.56H801a8.49,8.49,0,0,1,8.49,8.49V378a8.49,8.49,0,0,1-8.49,8.49H678.9V423H801a8.49,8.49,0,0,1,8.49,8.49v12.86a8.49,8.49,0,0,1-8.49,8.49H678.9V489.4H801a8.49,8.49,0,0,1,8.49,8.49v12.86a8.49,8.49,0,0,1-8.49,8.49H678.9V555.8H801a8.49,8.49,0,0,1,8.49,8.49v12.86a8.49,8.49,0,0,1-8.49,8.49H678.9V625A53.92,53.92,0,0,1,625,678.9H585.64V801a8.49,8.49,0,0,1-8.49,8.49H564.29A8.49,8.49,0,0,1,555.8,801V678.9H519.24V801a8.49,8.49,0,0,1-8.49,8.49H497.89A8.49,8.49,0,0,1,489.4,801V678.9H452.85V801a8.49,8.49,0,0,1-8.49,8.49H431.5A8.49,8.49,0,0,1,423,801V678.9H386.45V801a8.49,8.49,0,0,1-8.49,8.49H365.1a8.49,8.49,0,0,1-8.49-8.49V678.9H320.05V801a8.49,8.49,0,0,1-8.49,8.49H298.7a8.49,8.49,0,0,1-8.49-8.49V678.9H253.65V801a8.49,8.49,0,0,1-8.49,8.49H232.3a8.49,8.49,0,0,1-8.49-8.49V678.9H184.48A53.92,53.92,0,0,1,130.56,625V585.64H8.49A8.49,8.49,0,0,1,0,577.15V564.29a8.49,8.49,0,0,1,8.49-8.49H130.56V519.24H8.49A8.49,8.49,0,0,1,0,510.75V497.89a8.49,8.49,0,0,1,8.49-8.49H130.56V452.85H8.49A8.49,8.49,0,0,1,0,444.36V431.5A8.49,8.49,0,0,1,8.49,423H130.56V386.45H8.49A8.49,8.49,0,0,1,0,378V365.1a8.49,8.49,0,0,1,8.49-8.49H130.56V320.05H8.49A8.49,8.49,0,0,1,0,311.56V298.7a8.49,8.49,0,0,1,8.49-8.49H130.56V253.65H8.49A8.49,8.49,0,0,1,0,245.16V232.3a8.49,8.49,0,0,1,8.49-8.49H130.56V184.48a53.92,53.92,0,0,1,53.92-53.92h39.34V8.49A8.49,8.49,0,0,1,232.3,0h12.86a8.49,8.49,0,0,1,8.49,8.49V130.56h36.56V8.49A8.49,8.49,0,0,1,298.7,0h12.86a8.49,8.49,0,0,1,8.49,8.49V130.56h36.56V8.49A8.49,8.49,0,0,1,365.1,0H378a8.49,8.49,0,0,1,8.49,8.49V130.56H423V8.49A8.49,8.49,0,0,1,431.5,0h12.86a8.49,8.49,0,0,1,8.49,8.49V130.56H489.4V8.49A8.49,8.49,0,0,1,497.89,0h12.86a8.49,8.49,0,0,1,8.49,8.49V130.56H555.8V8.49A8.49,8.49,0,0,1,564.29,0h12.86a8.49,8.49,0,0,1,8.49,8.49V130.56H625a53.92,53.92,0,0,1,53.92,53.92v39.34H801a8.49,8.49,0,0,1,8.49,8.49v12.86a8.49,8.49,0,0,1-8.49,8.49ZM607.23,572.73v-336a34.49,34.49,0,0,0-34.49-34.49h-336a34.49,34.49,0,0,0-34.49,34.49v336a34.49,34.49,0,0,0,34.49,34.49h336A34.49,34.49,0,0,0,607.23,572.73Z"/>
   </symbol>
   <symbol id="gpu"   viewBox="0 0 809.45 809.45">
     <path d="M714.62,419A125.43,125.43,0,1,1,589.18,293.53,125.43,125.43,0,0,1,714.62,419ZM589.18,343.7A75.26,75.26,0,1,0,664.44,419,75.26,75.26,0,0,0,589.18,343.7Zm140.7-131.24H82.1V179a42.22,42.22,0,0,0-42.22-42.22H-.5v9.18H37.31A34.08,34.08,0,0,1,71.39,180v78H52v176h19.4V472.7H52V574.23h19.4V702.71H82.1V626.23H221.3v47.42l244-.76V626.23h53.54v46.65H659.55V626.23h70.33c43.95,0,79.57-36.39,79.57-80.34V292A79.57,79.57,0,0,0,729.88,212.46Z"/>
   </symbol>
   <symbol id="fan"   viewBox="0 0 809.45 809.45">
     <path d="M491.23,404.73a86.5,86.5,0,1,1-86.5-86.5A86.5,86.5,0,0,1,491.23,404.73ZM743.13,551.6,517,421.08a114.41,114.41,0,0,0,1.18-16.35A113.17,113.17,0,0,0,510,362.25c35.57-61.66,70.62-112.8,31.72-218.52-37.47-101.85-179-200-179-105.5v261a113.82,113.82,0,0,0-47.4,35.54c-71.2,0-133-4.77-205.13,81.79-69.47,83.38-83.71,255-1.87,207.77L334.41,493.82a113,113,0,0,0,54.46,23.3c35.62,61.64,62.37,117.58,173.4,136.75C669.2,672.34,825,598.85,743.13,551.6Z"/>
   </symbol>
   <symbol id="batt0" viewBox="0 0 809.45 809.45">
     <path d="M809.45,294V626.23H-.5V294A81.49,81.49,0,0,1,81,212.46h74.23V181.23h114v31.23h271V181.23h114v31.23H728A81.49,81.49,0,0,1,809.45,294ZM269.23,390.11h-114v29.24h114Zm385,0H611.84V347.73H582.61v42.38H540.23v29.24h42.38v42.38h29.24V419.34h42.38Z"/>
   </symbol>
   <symbol id="batt1" viewBox="0 0 809.45 809.45">
     <path d="M809.45,294V626.23H-.5V294A81.49,81.49,0,0,1,81,212.46h74.23V181.23h114v31.23h271V181.23h114v31.23H728A81.49,81.49,0,0,1,809.45,294Z"/>
   </symbol>
   <symbol id="batt2" viewBox="0 0 809.45 809.45">
     <path d="M809.45,294V626.23H-.5V294A81.49,81.49,0,0,1,81,212.46h74.23V181.23h114v31.23h271V181.23h114v31.23H728A81.49,81.49,0,0,1,809.45,294ZM735.23,403.23h-286v-108l-378,108h286v108Z"/>
   </symbol>
  </svg>
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
  <svg width='#{ui.radius*2}px' height='#{ui.radius*2}px'>
    <circle class='bg' r='#{ui.radius-ui.thickness/2}' cx='#{ui.radius}' cy='#{ui.radius}' />
    <circle class='bar' r='#{ui.radius-ui.thickness/2}' cx='#{ui.radius}' cy='#{ui.radius}'
    style='stroke-dasharray: #{ui.c/2} #{ui.c}'/>
  </svg>
  <svg class="fan-icon">
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
  # dom.find('head').appendChild '<link rel="import" href="istats.widget/icon-sprites-01.svg" />'
  # dom.find('.pmset').html content
