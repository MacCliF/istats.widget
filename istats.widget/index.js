/**
 * Stats Widget for Übersicht http://tracesof.net/uebersicht/
 *
 * Requires installation of https://github.com/Chris911/iStats.
 *
 * This project is a fork from https://github.com/roele/istats.widget.
 *
 */

/**
 * Visual appearance configuration
 */

ui: {
  /* Temperature unit, either C or F */
  unit: 'C',

  /* Vertical position in PX, either top or bottom */
  top: '30',
  //bottom: '0',

  /* Horizontal position in PX, either left or right */
  left: '10',
  //right: '0',

  /* Stats color */
  color: '#fff',

  /* Stats donut background color*/
  bgcolor: 'black',

  /* Stats donut background opacity*/
  bgopacity: '0.4',

  /* Stats width in PX */
  width: 80,

  /* Stats height in PX */
  height: 80,

  /* Stats radius in PX, needs be be at leat (width/2 - thickness) */
  radius: 30,

  /* Donut line thickness in PX */
  thickness: 3,

  /* Icon size in PX */
  iconsize: 30,

  /* Icon height in PX */
  iconheight: 75,

  /* Label font size in PX */
  fontsize: 12
}

,command: 'istats.widget/istats.sh'

,refreshFrequency: 5000

,render: function(output) {
  var data = this.parseOutput(output);
  var html  = '<div id="stats" ';
      html +=      'style="color: ' + this.ui.color + '; ';
  if (this.ui.top) {
      html +=           'top:' + this.ui.top + 'px; ';
  } else if (this.ui.bottom) {
      html +=           'bottom:' + this.ui.bottom + 'px; ';
  }
  if (this.ui.left) {
      html +=           'left:' + this.ui.left + 'px; ';
  } else if (this.ui.right) {
      html +=           'right:' + this.ui.right + 'px; ';
  }
  html += '">';

  if (data.cpu) {
      html += this.renderChart('CPU', 'iconx-cpu', 100, 0);
  }

  if (data.extra) {
      html += this.renderChart('GPU', 'iconx-gpu', 100, 0);
  }
/*
  if (data.battery) {
      html += this.renderChart('Battery', 'icon-carbattery', 100, 0);
  }
*/
  if (data.fan) {
    for (var i = 0; i < data.fan['total-fans-in-system']; i++) {
      html += this.renderChart('Fan ' + i, 'iconx-fan', 100, 0);
    }
  }
  html +=  '</div>';

  return html;
}

,update: function(output, domElement) {
  // we just assume max. values as they are not available via iStats
  var MAX_CPU = 90;
  var MAX_FAN = 5000;

  var data = this.parseOutput(output);
  var c = Math.floor(2 * Math.PI * this.ui.radius);

  if (data.cpu) {
    var temperature = (this.ui.unit.toUpperCase() === 'C')
                        ? Math.floor(data.cpu['cpu-temp']) + '°C'
                        : Math.floor(data.cpu['cpu-temp'] * 1.8 + 32) + '°F';

    $('#stats .cpu circle.bar').css('stroke-dasharray', Math.floor( (data.cpu['cpu-temp'] / MAX_CPU * 100) * c/100) + ' ' + c);
    $('#stats .cpu .temp').text(
      temperature
    );
  }

  if (data.extra) {
    var temperature = (this.ui.unit.toUpperCase() === 'C')
                        ? Math.floor(data.extra['tg0d-gpu-0-die-temp']) + '°C'
                        : Math.floor(data.extra['tg0d-gpu-0-die-temp'] * 1.8 + 32) + '°F';

    $('#stats .gpu circle.bar').css('stroke-dasharray', Math.floor( (data.extra['tg0d-gpu-0-die-temp'] / MAX_CPU * 100) * c/100) + ' ' + c);
    $('#stats .gpu .temp').text(temperature);
  }
/*
  if (data.battery) {                                                                                                                        // V
    $('#stats .battery circle.bar').css('stroke-dasharray', Math.floor( ((data.battery['current-charge'] / data.battery['maximum-charge'] * 100)+2) * c/100) + ' ' + c);
    $('#stats .battery .temp').text(Math.floor((data.battery['current-charge'] / data.battery['maximum-charge'] * 100)+1) + '%');
  }                                                                                                                 // ^
*/
  if (data.fan) {
    for (var i = 0; i < data.fan['total-fans-in-system']; i++) {
      $('#stats .fan-' + i + ' circle.bar').css('stroke-dasharray', Math.floor( (data.fan['fan-' + i + '-speed'] / MAX_FAN * 100) * c/100) + ' ' + c);
      $('#stats .fan-' + i + ' .temp').text(Math.floor(data.fan['fan-' + i + '-speed']) + ' RPM');
    }
  }
}

,renderChart: function(title, icon, percentage, temp) {
  var r = this.ui.radius;
  var c = Math.floor(2 * Math.PI * this.ui.radius);
  var p = c / 100 * percentage;

  var html  = '<div class="chart ' + title.replace(/\s/g, '-').toLowerCase() + '">';
      html +=       '<i class="icon ' + icon + '" style="font-size: ' + this.ui.iconsize + 'px; line-height:' + this.ui.iconheight + 'px"></i>';
      html +=       '<svg width="' + this.ui.width + 'px" height="' + this.ui.height + 'px">';
      html +=         '<circle class="bg" r="' + r + '" cx="' + (this.ui.width/2) + '" cy="' + (this.ui.height/2) + '"';
      html +=                ' style="opacity: ' + this.ui.bgopacity + '; stroke: ' + this.ui.bgcolor + '; stroke-width: ' + this.ui.thickness + '; stroke-dasharray: ' + c + ' ' + c + '"/>';
      html +=         '<circle class="bar" r="' + r + '" cx="' + (this.ui.width/2) + '" cy="' + (this.ui.height/2) + '" ';
      html +=                ' style="stroke: ' + this.ui.color + '; stroke-width: ' + this.ui.thickness + '; stroke-dasharray: ' + p + ' ' + c + '" />';
      html +=       '</svg>';
      html +=       '<div class="temp" style="font-size:' + this.ui.fontsize + 'px">' + temp + '</div>';
      html += '</div>';
  return html;
}

,parseOutput: function(output) {
  var out = output.split('\n');
  var o = {};
  var section;
  while (out.length > 0) {
    var line = out.shift();
    if (!line || line.match(/(\r|\n)/)) {
        section = undefined;
        continue;
    }
    if (line.match(/---.*?/)) {
      section = line.replace(/---\s+(.*?)\s+---/, '$1');
      continue;
    }

    var e = line.split(':');
    var k = e.length > 0 ? e[0].toLowerCase().replace(/\s/g, '-') : null;
    var v = e.length > 1 ? e[1].replace(/.*?(\d+)(\.\d{0,1})*.*/, '$1$2') : null;
    if (v === null) {
      continue;
    }
    if (section === 'CPU Stats') {
      o.cpu = o.cpu || {};
      o.cpu[k] = v;
    }
    if (section === 'Extra Stats') {
      o.extra = o.extra || {};
      o.extra[k] = v;
    }
    if (section === 'Fan Stats') {
      o.fan = o.fan || {};
      o.fan[k] = v;
    }
    if (section == 'Battery Stats') {
      o.battery = o.battery || {};
      o.battery[k] = v;
    }
  }

  return o;
}

,style: "                                                    \n\
  font-family: 'Helvetica Neue'                              \n\
  font-size: 16px                                            \n\
  width: 500px                                                \n\
  height: 150px                                               \n\
  transform: auto;                                           \n\
                                                             \n\
  @font-face                                                 \n\
    font-family: 'Icons';                                    \n\
    src: url('istats.widget/icons.ttf') format('truetype')   \n\
    font-weight: normal;                                     \n\
    font-style: normal;                                      \n\
                                                             \n\
  @font-face                                                 \n\
    font-family: 'Iconsx';                                    \n\
    src: url('istats.widget/iconsx.otf') format('truetype')   \n\
    font-weight: normal;                                     \n\
    font-style: normal;                                      \n\
                                                            \n\
  [class^='icon-'], [class*=' icon-']                        \n\
    font-family: 'Icons';                                    \n\
    background: none;                                        \n\
    width: auto;                                             \n\
    height: auto;                                            \n\
    font-style: normal                                       \n\
                                                             \n\
  [class^='iconx-'], [class*=' iconx-']                        \n\
    font-family: 'Iconsx';                                    \n\
    background: none;                                        \n\
    width: auto;                                             \n\
    height: auto;                                            \n\
    font-style: normal;  \n\
    font-size: 50px                                     \n\
                                                            \n\
  #stats                                                     \n\
    position: absolute                                       \n\
    margin: 0 0                                              \n\
    padding: 0 0                                             \n\
                                                             \n\
  #stats .chart                                              \n\
    position: relative                                       \n\
    float: left                                              \n\
    margin: 0rem 1rem 0rem 1rem                              \n\
                                                             \n\
  #stats .chart i                                            \n\
    text-align: center                                       \n\
    position: absolute                                       \n\
    width: 100%                                              \n\
                                                             \n\
  #stats .chart .temp                                        \n\
    text-align: center                                       \n\
    display: block                                           \n\
                                                             \n\
  #stats .chart svg                                          \n\
    transform: rotate(-90deg)                                \n\
                                                             \n\
  #stats .chart circle                                       \n\
    fill: transparent                                        \n\
                                                             \n\
  #stats .chart .iconx-cpu:before                             \n\
    content: 'A'                                        \n\
                                                             \n\
  #stats .chart .iconx-gpu:before                             \n\
    content: 'B'                                        \n\
                                                             \n\
  #stats .chart .icon-carbattery:before                      \n\
    content: '\\f553'                                        \n\
                                                             \n\
  #stats .chart .iconx-fan:before                             \n\
    content: 'C'                                        \n\
"
