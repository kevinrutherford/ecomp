
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

function churn_vs_complexity_plot(target, data) {
    var points = [];
    $.each(data, function(i, item) {
        points.push({
            x: item.complexity.emaxcc,
            y: item.churn,
            name: item.filename
        });
    });
    draw_churn_vs_complexity_chart(target, points);
};

function draw_churn_vs_complexity_chart(div, data) {
    $(div).highcharts({
        chart: { type: 'scatter' },
        title: { text: null },
        subtitle: { text: null },
        xAxis: { title: { text: 'Complexity' } },
        yAxis: {
            title: { text: 'Churn' },
            min: 0
        },
        series: [{ data: data }]
    });
};

function draw_chart(filename, target_div, charting_function) {
  $.getJSON("/data/" + filename + ".json", function(data) {
    charting_function(target_div, data);
  });
};

$(document).ready(function() {
    draw_chart('commit_sizes', '#commit_sizes', sizes_plot);
    draw_chart('churn_vs_complexity', '#churn_vs_complexity', churn_vs_complexity_plot);
});
