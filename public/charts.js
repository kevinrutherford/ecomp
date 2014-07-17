
function recent_commits_plot(target, data) {
    var series = [];
    $.each(data, function(i, item) {
        var pts = [];
        $.each(item.commits, function(i, c) {
            pts.push({
                name: c.ref,
                x: Date.parse(c.date),
                y: c.complexity.delta_sumesumcc,
                z: c.num_files_touched
            });
        });
        series.push({
            data: pts,
            name: item.author
        });
    });
    draw_recent_commits_chart(target, series);
};

function draw_recent_commits_chart(div, data) {
    $(div).highcharts({
        credits: { enabled: false },
        chart: {
            type: 'bubble',
            zoomType: 'xy'
        },
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
        yAxis: { title: { text: 'Change in total project complexity' } },
        tooltip: {
            formatter: function() {
                var header = '<b>'+ this.point.name + ' by ' + this.series.name + '</b><br>';
                var detail = 'Files touched: ' + this.point.z + '<br>' + 'Complexity delta: ' + this.point.y;
                return header + detail;
            }
        },
        series: data
    });
};

var heat_colours = [
    '#00ffff', '#00AEF9', '#0061F4', '#0017EF',
    '#2E00EA', '#7200E5', '#B300E0', '#DB00C5',
    '#D60080', '#D1003E', '#cc0000'
];

function colour_for(x, y, max_churn, max_complexity) {
    var distance = 5 * ((x/max_complexity) + (y/max_churn))
    return heat_colours[Math.floor(distance)];
};

function churn_vs_complexity_plot(target, data) {
    var max_churn = 0,
        max_complexity = 0;
    $.each(data, function(i, item) {
        max_churn = Math.max(max_churn, item.churn);
        max_complexity = Math.max(max_complexity, item.complexity.emeancc);
    });
    var points = [];
    $.each(data, function(i, item) {
        var x = +(item.complexity.emeancc).toFixed(2);
        var y = item.churn;
        points.push({
            x: x,
            y: y,
            color: colour_for(x, y, max_churn, max_complexity),
            name: item.filename
        });
    });
    draw_churn_vs_complexity_chart(target, points, max_churn+5);
};

function draw_churn_vs_complexity_chart(div, data, max_churn) {
    $(div).highcharts({
        credits: { enabled: false },
        chart: { zoomType: 'xy' },
        title: { text: null },
        subtitle: { text: null },
        xAxis: { title: { text: 'Mean method complexity' } },
        yAxis: {
            title: { text: 'Number of times changed' },
            min: 0
        },
        plotOptions: {
            scatter: {
                marker: {
                    radius: 5,
                    states: {
                        hover: {
                            enabled: true,
                            lineColor: 'rgb(100,100,100)'
                        }
                    }
                },
                states: { hover: { marker: { enabled: false } } },
                tooltip: {
                    headerFormat: '<b>{point.key}</b><br>',
                    pointFormat: 'Mean method complexity: {point.x}<br>Number of commits: {point.y}'
                }
            }
        },
        series: [{
            type: 'scatter',
            name: 'Source files',
            data: data
        }]
    });
};

function ctrend_plot(target, data) {
    var points = [];
    $.each(data, function(i, item) {
        points.push({
            x: Date.parse(item.date),
            y: item.complexity.meanesumcc,
            name: item.ref + " by " + item.author
        });
    });
    draw_complexity_trend_chart(target, points);
};

function draw_complexity_trend_chart(div, data) {
    $(div).highcharts({
        credits: { enabled: false },
        chart: {
            type: 'spline',
            zoomType: 'xy'
        },
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
            title: { text: 'Mean complexity per source file' },
            min: 0
        },
        series: [{
            data: data,
            name: 'Complexity'
        }]
    });
};

function draw_chart(filename, target_div, charting_function) {
  $.getJSON("/data/reek/" + filename + ".json", function(data) {
    charting_function(target_div, data);
  });
};

$(document).ready(function() {
    draw_chart('recent_commits_by_author', '#recent_commits', recent_commits_plot);
    draw_chart('current_files', '#churn_vs_complexity', churn_vs_complexity_plot);
    draw_chart('commits', '#complexity_trend', ctrend_plot);
});
