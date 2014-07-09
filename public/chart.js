function complexity_trend(div, data) {
    $(div).highcharts({
        chart: { type: 'spline' },
        title: { text: 'Total method complexity' },
        subtitle: { text: 'Per git commit' },
        xAxis: { type: 'datetime' },
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
