
function sizes_plot(target, data) {
    var series = [];
    $.each(data, function(i, item) {
        var pts = [];
        $.each(item.commits, function(i, c) {
            pts.push([Date.parse(c.date), c.size, c.size]);
        });
        series.push({
            data: pts,
            name: item.author
        });
    });
    draw_size_chart(target, series);
};

function draw_size_chart(div, data) {
    $(div).highcharts({
        chart: { type: 'bubble' },
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
        series: data
    });
};

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

function draw_chart(filename, target_div, charting_function) {
  $.getJSON("/data/" + filename + ".json", function(data) {
    charting_function(target_div, data);
  });
};

$(document).ready(function() {
    draw_chart('commit_sizes', '#commit_sizes', sizes_plot);
    draw_chart('complexity', '#complexity_trend', complexity_plot);
});
