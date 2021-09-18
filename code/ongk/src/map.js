// Retrieve all datasets
const hillsboroughDataset = Papa.parse(hillsboroughData, { header: true });
const miamiDadeDataset = Papa.parse(miamiDadeData, { header: true });
const orangeDataset = Papa.parse(orangeData, { header: true });
const housingLossData = _.concat(
  hillsboroughDataset.data,
  miamiDadeDataset.data,
  orangeDataset.data
);

// Get columns
const housingLossDataCols = hillsboroughDataset.meta.fields;
const numericalCols = _.without(
  housingLossDataCols,
  "census_tract_GEOID",
  "state",
  "county",
  "county_GEOID",
  "pct-below-poverty-level"
);

// Add to select
let metricKey = "total-evictions";
const selectElt = document.getElementById("metric-select");
selectElt.addEventListener("change", handleSelectChange);

// Get summary of data across all tracts
let numericalSummary = {};
for (let colIdx = 0; colIdx < numericalCols.length; colIdx++) {
  const colKey = numericalCols[colIdx];
  const colValues = _.map(housingLossData, (o) => parseFloat(o[colKey]));
  _.remove(colValues, (v) => _.isNaN(v));

  numericalSummary[colKey] = {
    min: _.min(colValues),
    max: _.max(colValues),
    mean: _.mean(colValues),
    sum: _.sum(colValues),
  };

  const optionElt = document.createElement("option");
  optionElt.value = colKey;
  optionElt.innerHTML = colKey;
  if (colKey === metricKey) {
    optionElt.setAttribute("selected", "");
  }
  selectElt.appendChild(optionElt);
}

// Clean tract data and convert to numerical values
const tractData = _.keyBy(housingLossData, "census_tract_GEOID");
_.each(tractData, (tData) => {
  _.each(numericalCols, (header) => {
    tData[header] = parseFloat(tData[header]);
  });
});
delete tractData[""];

let myMap = L.map("mapid").setView([27.431328998518634, -81.36195249010888], 7);

L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
  maxZoom: 18,
  attribution:
    '&copy; <a href="https://openstreetmap.org/copyright">OpenStreetMap contributors</a>',
}).addTo(myMap);

let colorScale = d3.scaleQuantize(
  [numericalSummary[metricKey].min, numericalSummary[metricKey].max],
  d3.schemeRdBu[10]
);
let hillsboroughGeojson = L.geoJSON(hillsboroughTracts, {
  style: function (feature) {
    const geoID = feature.properties.census_tract_GEOID;
    const metricValue = parseFloat(tractData[geoID][metricKey]);
    return { color: "#ffffff", fillColor: colorScale(metricValue), fillOpacity: 0.7, weight: 1 };
  },
}).addTo(myMap);
let miamiDadeGeojson = L.geoJSON(miamiDadeTracts, {
  style: function (feature) {
    const geoID = feature.properties.census_tract_GEOID;
    const metricValue = parseFloat(tractData[geoID][metricKey]);
    return { color: "#ffffff", fillColor: colorScale(metricValue), fillOpacity: 0.7, weight: 1 };
  },
}).addTo(myMap);
let orangeGeojson = L.geoJSON(orangeTracts, {
  style: function (feature) {
    const geoID = feature.properties.census_tract_GEOID;
    const metricValue = parseFloat(tractData[geoID][metricKey]);
    return { color: "#ffffff", fillColor: colorScale(metricValue), fillOpacity: 0.7, weight: 1 };
  },
}).addTo(myMap);

document
  .getElementById("legend")
  .appendChild(Legend(colorScale, { title: metricKey, width: 800, tickFormat: "0.2f" }));

function handleSelectChange(event) {
  metricKey = event.target.value;
  colorScale = d3.scaleQuantize(
    [numericalSummary[metricKey].min, numericalSummary[metricKey].max],
    d3.schemeRdBu[10]
  );

  document.getElementById("legend").firstChild.remove();
  document
    .getElementById("legend")
    .appendChild(Legend(colorScale, { title: metricKey, width: 800, tickFormat: "0.2f" }));
  hillsboroughGeojson.resetStyle();
  miamiDadeGeojson.resetStyle();
  orangeGeojson.resetStyle();
}
