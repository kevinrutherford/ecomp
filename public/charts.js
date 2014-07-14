
function recent_commits_plot(target, data) {
    var series = [];
    $.each(data, function(i, item) {
        var pts = [];
        $.each(item.commits, function(i, c) {
            pts.push({
                name: c.ref,
                x: Date.parse(c.date),
                y: c.num_files_touched,
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
        tooltip: {
            formatter: function() {
                var header = '<b>'+ this.point.name + ' by ' + this.series.name + '</b><br>';
                var detail = 'Files touched: ' + this.point.y + '<br>' + 'Complexity delta: ' + this.point.z;
                return header + detail;
            }
        },
        series: data
    });
};

function churn_vs_complexity_plot(target, data) {
    var points = [];
    $.each(data, function(i, item) {
        points.push({
            x: +(item.complexity.emeancc).toFixed(2),
            y: item.churn,
            name: item.filename
        });
    });
    draw_churn_vs_complexity_chart(target, points);
};

function draw_churn_vs_complexity_chart(div, data) {
    $(div).highcharts({
        chart: {
            type: 'scatter',
            zoomType: 'xy'
        },
        title: { text: null },
        subtitle: { text: null },
        xAxis: { title: { text: 'Complexity' } },
        yAxis: {
            title: { text: 'Churn' },
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
                    pointFormat: 'Complexity: {point.x}<br>Churn: {point.y}'
                }
            }
        },
        series: [{
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
            y: item.complexity.maxemaxcc,
            name: item.ref + " by " + item.author
        });
    });
    draw_complexity_trend_chart(target, points);
};

function draw_complexity_trend_chart(div, data) {
    $(div).highcharts({
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
