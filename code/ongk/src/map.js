const housingLossData = Papa.parse(dataLossMiamiData, { header: true });
const housingLossDataCols = housingLossData.meta.fields;
const numericalCols = _.without(
  housingLossDataCols,
  "census_tract_GEOID",
  "state",
  "county",
  "county_GEOID"
);

// Add to select
const selectElt = document.getElementById("metric-select");
selectElt.addEventListener("change", handleSelectChange);

// Get summary of data across all tracts
let numericalSummary = {};
for (let colIdx = 0; colIdx < numericalCols.length; colIdx++) {
  const colKey = numericalCols[colIdx];
  const colValues = _.map(housingLossData.data, (o) => parseFloat(o[colKey]));
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
  selectElt.appendChild(optionElt);
}

// Clean tract data and convert to numerical values
const tractData = _.keyBy(housingLossData.data, "census_tract_GEOID");
_.map(tractData, (tData, geoID) => {
  _.each(numericalCols, (header) => {
    tData[header] = parseFloat(tData[header]);
  });
  return tData;
});
delete tractData[""];


let myMap = L.map("mapid").setView([25.60169, -80.461346], 10);

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 18,
        attribution: '&copy; <a href="https://openstreetmap.org/copyright">OpenStreetMap contributors</a>'
      }).addTo(myMap);

let metricKey = "total-evictions";
let colorScale = d3.scaleQuantize(
  [numericalSummary[metricKey].min, numericalSummary[metricKey].max],
  d3.schemeRdBu[10]
);
let geojson = L.geoJSON(tracts, {
  style: function (feature) {
    const geoID = feature.properties.census_tract_GEOID;
    const metricValue = parseFloat(tractData[geoID][metricKey]);
    return { color: colorScale(metricValue) };
  },
}).addTo(myMap);

function handleSelectChange(event) {
  metricKey = event.target.value;
  colorScale = d3.scaleQuantize(
    [numericalSummary[metricKey].min, numericalSummary[metricKey].max],
    d3.schemeRdBu[10]
  );
  
  geojson.resetStyle();
}
