
# BCN Surf Forecast

Static page showing the hourly wave forecast (SIWANA model, Puertos del
Estado) for **Boya de Barcelona II** (code `712018020`): significant wave
height, peak and mean period, and mean propagation direction as a 16-point
compass label.

A GitHub Actions workflow runs every hour, fetches the data from
`https://poem.puertos.es/portus/ForecastData/Siwana/forecast`, renders
`_site/index.html`, and deploys it to GitHub Pages. Open pages also reload
themselves every 15 minutes.

## Requirements

Ruby ≥ 3.0, standard library only (no gems).

Note: GitHub may delay scheduled runs during busy periods. It also disables
scheduled workflows in public repositories with no activity for 60 days.
If that happens, re-enable the workflow from the Actions tab.
