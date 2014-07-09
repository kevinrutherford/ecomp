function complexity_plot(target, data) {
    var points = [];
    $.each(data, function(i, item) {
        points.push({
            x: Date.parse(item.date),
            y: item.complexity,
            radius: 2 * (item.complexity + 1)
        });
    });
    draw_complexity_chart(target, points);
};

function draw_complexity_chart(div, data) {
    $(div).highcharts({
        chart: { type: 'spline' },
        title: { text: null },
        subtitle: { text: null },
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
