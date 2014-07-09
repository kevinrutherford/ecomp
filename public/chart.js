function complexity_plot(target, data) {
    var points = [];
    $.each(data, function(i, item) {
        var date = Date.parse(item[0]);
        points.push({
            x: date,
            y: item[1],
            radius: 2*(item[1]+1)
        });
    });
    draw_complexity_chart(target, points);
};

function draw_complexity_chart(div, data) {
    $(div).highcharts({
        chart: { type: 'spline' },
        title: { text: 'Total method complexity' },
        subtitle: { text: 'Per git commit' },
        xAxis: {
            type: 'datetime',
            dateTimeLabelFormats: {
                hour: '%b %e %H:%M',
                day: '%b %e',
                week: '%b %e'
            },
        },
        yAxis: {
            title: { text: 'Complexity' },
            min: 0
        },
        tooltip: {
            headerFormat: '<b>{series.name}</b><br>',
            pointFormat: '{point.x:%e-%b}: {point.y:.2f}'
        },
        series: [{
            name: 'Complexity',
            data: data
        }]
    });
};

$(document).ready(function() {
  $.getJSON('/data/complexity.json', function(data) {
    complexity_plot('#complexity_trend', data);
  });
});
