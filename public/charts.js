
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

function churn_vs_complexity_plot(target, data) {
    var points = [];
    max_churn = 0;
    $.each(data, function(i, item) {
        points.push({
            x: +(item.complexity.emeancc).toFixed(2),
            y: item.churn,
            name: item.filename
        });
        max_churn = Math.max(max_churn, item.churn)
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
        }, {
            type: 'line',
            name: 'Threshold',
            color: '#bbbbbb',
            dashStyle: 'DashDot',
            data: [[1, max_churn], [5, 0]]
        }]
    });
};

function ctrend_plot(target, data) {
    var points = [];
    $.each(data, function(i, item) {
        points.push({
            x: Date.parse(item.date),
            y: item.complexity.maxemaxcc,
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
            title: { text: 'Most complex method' },
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
