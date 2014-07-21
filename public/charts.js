
function recent_commits_plot(target, data) {
    var series = [];
    $.each(data, function(i, item) {
        var pts = [];
        $.each(item.commits, function(i, c) {
            pts.push({
                name: c.ref,
                x: Date.parse(c.date),
                y: c.complexity.delta_sum_of_file_weights,
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

function hsvToRgb(h, s, v) {
    var r, g, b;
    var i;
    var f, p, q, t;
    
    // Make sure our arguments stay in-range
    h = Math.max(0, Math.min(360, h));
    s = Math.max(0, Math.min(100, s));
    v = Math.max(0, Math.min(100, v));
    
    // We accept saturation and value arguments from 0 to 100 because that's
    // how Photoshop represents those values. Internally, however, the
    // saturation and value are calculated from a range of 0 to 1. We make
    // That conversion here.
    s /= 100;
    v /= 100;
    
    if(s == 0) {
        // Achromatic (grey)
        r = g = b = v;
        return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
    }
    
    h /= 60; // sector 0 to 5
    i = Math.floor(h);
    f = h - i; // factorial part of h
    p = v * (1 - s);
    q = v * (1 - s * f);
    t = v * (1 - s * (1 - f));

    switch(i) {
        case 0:
            r = v;
            g = t;
            b = p;
            break;
            
        case 1:
            r = q;
            g = v;
            b = p;
            break;
            
        case 2:
            r = p;
            g = v;
            b = t;
            break;
            
        case 3:
            r = p;
            g = q;
            b = v;
            break;
            
        case 4:
            r = t;
            g = p;
            b = v;
            break;
            
        default: // case 5:
            r = v;
            g = p;
            b = q;
    }
    
    return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
};

function rgbToHex(r, g, b) {
    return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
};

function colour_for(x, y, max_x, max_y) {
    var cold = [90, 80, 100];
    var hot = [0, 100, 60];
    var p = ((x/max_x) + (y/max_y)) / 2;

    var h = (1 - p) * cold[0] + p * hot[0];
    var s = (1 - p) * cold[1] + p * hot[1];
    var v = (1 - p) * cold[2] + p * hot[2];
    var rgb = hsvToRgb(h, s, v);

    return rgbToHex(rgb[0], rgb[1], rgb[2]);
};

function churn_vs_complexity_plot(target, data) {
    var max_churn = 0,
        max_complexity = 0;
    $.each(data, function(i, item) {
        max_churn = Math.max(max_churn, item.churn);
        max_complexity = Math.max(max_complexity, item.weight);
    });
    var points = [];
    $.each(data, function(i, item) {
        var w = +(item.weight).toFixed(2);
        var ch = item.churn;
        points.push({
            x: ch,
            y: w,
            color: colour_for(w, ch, max_complexity, max_churn),
            name: item.filename
        });
    });
    draw_churn_vs_complexity_chart(target, points, Math.max(max_churn, max_complexity));
};

function draw_churn_vs_complexity_chart(div, data, max) {
    $(div).highcharts({
        credits: { enabled: false },
        chart: { zoomType: 'xy' },
        colors: ['#99ff32'],
        title: { text: null },
        subtitle: { text: null },
        yAxis: {
            title: { text: 'Complexity' },
            min: 0,
            max: max
        },
        xAxis: {
            title: { text: 'Number of times changed' },
            min: 0,
            max: max
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
                    pointFormat: 'Complexity: {point.y}<br>Number of commits: {point.x}'
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
            y: item.complexity.mean_of_file_weights,
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
            name: 'Mean complexity'
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
