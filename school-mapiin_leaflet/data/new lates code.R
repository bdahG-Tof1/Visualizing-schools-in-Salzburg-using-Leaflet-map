install.packages("htmltools")
install.packages("leaflet.extras")
# Load necessary libraries
library(leaflet)
library(sf)
library(htmltools)  # For creating the custom HTML legend
library(leaflet.extras)  # For search functionality

# Path to your GeoJSON file
geojson_path <- "C:\\Users\\charl\\Downloads\\school-map\\school.geojson"

# Read the GeoJSON data
school_data <- st_read(geojson_path)

# Separate POINT and POLYGON geometries
points <- school_data[st_geometry_type(school_data) == "POINT", ]
polygons <- school_data[st_geometry_type(school_data) %in% c("POLYGON", "MULTIPOLYGON"), ]

# Create a custom icon for schools
school_icon <- makeIcon(
  iconUrl = "C:/Users/charl/Downloads/school-map/assets/school-icon.png", # Path to your custom icon
  iconWidth = 32,   # Width of the icon
  iconHeight = 32,  # Height of the icon
  iconAnchorX = 16, # Horizontal anchor point (center of the icon)
  iconAnchorY = 32  # Vertical anchor point (bottom of the icon)
)

# Create a unified custom HTML legend
custom_legend <- HTML('
  <div style="background:white; padding:10px; border-radius:5px; box-shadow:0px 0px 10px rgba(0,0,0,0.2);">
    <h4 style="margin:0; text-align:center;">Legend</h4>
    <div style="display:flex; align-items:center; margin-top:5px;">
      <img src="C:/Users/charl/Downloads/school-map/assets/school-icon.png" style="width:32px; height:32px; margin-right:5px;">
      <span>School Location</span>
    </div>
    <div style="display:flex; align-items:center; margin-top:5px;">
      <div style="width:20px; height:20px; background:blue; margin-right:5px; border:1px solid black;"></div>
      <span>School Areas</span>
    </div>
  </div>
')

# Initialize the leaflet map
map <- leaflet() %>%
  # Add base tile layer
  addTiles() %>%
  
  # Add POINT geometries with popups
  addMarkers(
    data = points,
    icon = school_icon,
    popup = ~paste0(
      "<b>Name:</b> ", name, "<br>",
      "<b>Amenity:</b> ", amenity
    ),
    group = "Schools (Points)"
  ) %>%
  
  # Add POLYGON geometries with popups
  addPolygons(
    data = polygons,
    fillColor = "blue",
    fillOpacity = 0.5,
    color = "black",
    weight = 1,
    popup = ~paste0(
      "<b>Name:</b> ", name, "<br>",
      "<b>Amenity:</b> ", amenity, "<br>",
      "<b>Building Type:</b> ", building
    ),
    highlightOptions = highlightOptions(
      weight = 2,
      color = "red",
      fillOpacity = 0.8,
      bringToFront = TRUE
    ),
    group = "Schools (Polygons)"
  ) %>%
  
  # Add the unified custom legend as a control
  addControl(
    custom_legend,
    position = "bottomright"
  ) %>%
  
  # Add layer control
  addLayersControl(
    overlayGroups = c("Schools (Points)", "Schools (Polygons)"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  
  # Add a search box for features
  addSearchFeatures(
    targetGroups = c("Schools (Points)", "Schools (Polygons)"),
    options = searchFeaturesOptions(
      zoom = 15,
      openPopup = TRUE,
      firstTipSubmit = TRUE,
      autoCollapse = TRUE,
      hideMarkerOnCollapse = TRUE
    )
  ) %>%
  
  # Add a scalebar
  addScaleBar(position = "bottomleft") %>%
  
  # Add a fullscreen button
  addFullscreenControl() %>%
  
  # Add a minimap
  addMiniMap(
    tiles = providers$OpenStreetMap.Mapnik,
    toggleDisplay = TRUE
  ) %>%
  # Add a measure tool
  addMeasure(
    position = "topleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters",
    activeColor = "#ff0000",
    completedColor = "#00ff00"
  ) %>%
  
  # Add layer control
  addLayersControl(
    baseGroups = c("OpenStreetMap", "Toner Lite", "Satellite", "CartoDB Light"),
    overlayGroups = c("Schools (Points)", "Schools (Polygons)"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  # Add a title to the map
  addControl(
    html = "<h2 style='text-align:center; color:blue;'>INTERACTIVE MAP OF SALZBURG SCHOOLS</h2>",
    position = "topright"
  )

# Display the map
map
