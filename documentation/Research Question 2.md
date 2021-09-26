## Research Question 2 (Mapping - Portable) Documentation

> Using the given “processed” data sets and GeoJSON files for Hillsborough, Miami-Dade, and Orange counties, explore 2-3 mapping techniques capable of displaying census tract-level eviction, foreclosure, or overall housing loss rates alongside key demographic information. Bonus points if the maps are portable/shareable (e.g., in HTML format or similar) and can be viewed offline!

Based on the work done by volunteers [@keck343](https://github.com/keck343), [@ongk](https://github.com/ongk), [@danakraushar](https://github.com/danakraushar) and [@iofall](https://github.com/iofall), following pros and cons for different toolsets were identified:

### 1. GeoPandas
[@keck343](https://github.com/keck343) worked on visualizations using GeoPandas and Python. [Link](https://github.com/datakind/sep21-housing-insecurity/blob/main/code/QuinnKeck/housing_insecurity_maps_geopandas.ipynb).

**Pros:**
- Can use Python, no need to install external software, provided you already have a Python install.
- Can use Jupyter notebooks that can be exported in the form of PDFs and HTML, making these files easier to share with non-technical users. LaTeX exports are also possible.
- Visualizations can be exported to PNGs without having to export the entire code.
- Can be deployed through Python Webframeworks to provide interactivity.

**Cons:**
- Visualizations are sometimes unclear and hard to read.
- Visualizations are static and do not offer advanced features such as tooltips, hover effects etc.

### 2. Leaflet.js
[@ongk](https://github.com/ongk) worked on visualizations using HTML, Leaflet.js and Lodash deployed at [Link](https://ongk.github.io/sep21-housing-insecurity/code/ongk/src/).

**Pros:**
- Easily accessible through a web browser.
- Provides interactivity and a lot of customization options.
- Static files can be shared without need for deployment (provided data is shared along with them).
- Can be deployed statically without need for a backend as seen above on the GitHub Pages deployment.

**Cons:**
- For offline interactivity, data needs to be downloaded along with the HTML and JS codes.

### 3. R
[@danakraushar](https://github.com/danakraushar) worked on mapping using R, ggplot and sf packages.

**Pros:**
- Can use R, no need to install external software, provided you already have an R install.
- Can use R Shiny for deployment to provide interactivity and a web based interface for interaction.

**Cons:**
- No inbuilt interactivity

### 4. Plotly
[@iofall](https://github.com/iofall) worked on mapping using Plotly's Python library. [Link](https://github.com/datakind/sep21-housing-insecurity/tree/main/code/iofall).

**Pros:**
- Inbuilt interactivity and easily customizable.
- Can export as HTML and JS snippets which can be embedded into webpages.
- Plotly Dash can be used high quality Dashboards on par with popular BI tools, right from Python. These dashboards can also be deployed on web servers.

**Cons:**
- Company wide Dash deployments are easier with the paid Dash Enterprise.

### 5. Tableau
[@iofall](https://github.com/iofall) worked on visualizations using Tableau. [Link](https://github.com/datakind/sep21-housing-insecurity/tree/main/code/iofall).

**Pros:**
- Inbuilt interactivity and easily customizable.
- Can be embedded into webpages provided you use Tableau Public (free) or have a license for Tableau Server (paid).
- Full-fledged BI platform with a lot of enterprise grade features.

**Cons:**
- If your data/work cannot be public, you need to purchase a licencse.
- Tableau specific knowledge required.

