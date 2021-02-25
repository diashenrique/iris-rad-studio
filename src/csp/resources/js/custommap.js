var urlOrigin = window.location.origin;
var urlREST = urlOrigin + "/csp/irisapp/api";

$(document).ready(function () {

    $.getJSON(urlREST + "/global/header", function(response) {
        var maxValue = response.totalVaccination.toLocaleString();
      });

    $.getJSON(urlREST + "/sql/map", function (response) {

        // Create map instance
        var chart = am4core.create("chartdiv", am4maps.MapChart);
        chart.geodata = am4geodata_worldLow;
        chart.projection = new am4maps.projections.Miller();
        chart.background.fill = am4core.color("#aadaff");
        chart.background.fillOpacity = 1;

        // Create map polygon series
        var polygonSeries = chart.series.push(new am4maps.MapPolygonSeries());
        polygonSeries.useGeodata = true;
        polygonSeries.exclude = ["AQ"];

        // Add heat rule
        polygonSeries.heatRules.push({
            "property": "fill",
            "target": polygonSeries.mapPolygons.template,
            "min": am4core.color("#dbe3a6"),
            "max": am4core.color("#518e10")
        });

        // Add expectancy data
        polygonSeries.events.on("beforedatavalidated", function (ev) {
            var source = ev.target.data;
            if (source.maybe) {
                ev.target.data = source;
            }
        });

        // Configure series tooltip
        var polygonTemplate = polygonSeries.mapPolygons.template;
        polygonTemplate.tooltipText = "{name}: {value}";
        polygonTemplate.nonScalingStroke = true;
        polygonTemplate.strokeWidth = 0.5;

        // Create hover state and set alternative fill color
        var hs = polygonTemplate.states.create("hover");
        hs.properties.fill = am4core.color("#3c5bdc");

        polygonSeries.data = response;

        // Set up heat legend
        let heatLegend = chart.createChild(am4maps.HeatLegend);
        heatLegend.series = polygonSeries;
        heatLegend.align = "right";
        heatLegend.valign = "bottom";
        heatLegend.width = am4core.percent(20);
        heatLegend.marginRight = am4core.percent(4);
        heatLegend.minValue = 0;
        heatLegend.maxValue = maxValue;

        // Set up custom heat map legend labels using axis ranges
        var minRange = heatLegend.valueAxis.axisRanges.create();
        minRange.value = heatLegend.minValue;
        var maxRange = heatLegend.valueAxis.axisRanges.create();
        maxRange.value = heatLegend.maxValue;

        // Blank out internal heat legend value axis labels
        heatLegend.valueAxis.renderer.labels.template.adapter.add("text", function (labelText) {
            return "";
        });

        

    });

    $.getJSON(urlREST + "/sql/mappercent", function (response) {

        // Create map instance
        var chart = am4core.create("chartdivpercent", am4maps.MapChart);
        chart.geodata = am4geodata_worldLow;
        chart.projection = new am4maps.projections.Miller();
        chart.background.fill = am4core.color("#aadaff");
        chart.background.fillOpacity = 1;

        // Create map polygon series
        var polygonSeries = chart.series.push(new am4maps.MapPolygonSeries());
        polygonSeries.useGeodata = true;
        polygonSeries.exclude = ["AQ"];

        // Add heat rule
        polygonSeries.heatRules.push({
            "property": "fill",
            "target": polygonSeries.mapPolygons.template,
            "min": am4core.color("#dbe3a6"),
            "max": am4core.color("#518e10")
        });

        // Add expectancy data
        polygonSeries.events.on("beforedatavalidated", function (ev) {
            var source = ev.target.data;
            if (source.maybe) {
                ev.target.data = source;
            }
        });

        // Configure series tooltip
        var polygonTemplate = polygonSeries.mapPolygons.template;
        polygonTemplate.tooltipText = "{name}: {value} %";
        polygonTemplate.nonScalingStroke = true;
        polygonTemplate.strokeWidth = 0.5;

        // Create hover state and set alternative fill color
        var hs = polygonTemplate.states.create("hover");
        hs.properties.fill = am4core.color("#3c5bdc");

        polygonSeries.data = response;

        // Set up heat legend
        let heatLegend = chart.createChild(am4maps.HeatLegend);
        heatLegend.series = polygonSeries;
        heatLegend.align = "right";
        heatLegend.valign = "bottom";
        heatLegend.width = am4core.percent(20);
        heatLegend.marginRight = am4core.percent(4);
        heatLegend.minValue = 0;
        heatLegend.maxValue = 100;

        // Set up custom heat map legend labels using axis ranges
        var minRange = heatLegend.valueAxis.axisRanges.create();
        minRange.value = heatLegend.minValue;
        var maxRange = heatLegend.valueAxis.axisRanges.create();
        maxRange.value = heatLegend.maxValue;

        // Blank out internal heat legend value axis labels
        heatLegend.valueAxis.renderer.labels.template.adapter.add("text", function (labelText) {
            return "";
        });

        

    });


});