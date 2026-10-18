# Portus waves

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

## Usage

```sh
ruby test/portus_forecast_test.rb   # run the tests
ruby bin/build                      # writes _site/index.html
```

Optional environment variables for `bin/build`:

| Variable              | Default                | Description                 |
|-----------------------|------------------------|-----------------------------|
| `PORTUS_CODE`         | `712018020`            | Portus point code           |
| `PORTUS_SCHEME`       | `Siwana`               | Forecast model scheme       |
| `PORTUS_STATION_NAME` | `Boya de Barcelona II` | Title shown on the page     |
| `OUTPUT_DIR`          | `_site`                | Where `index.html` is saved |
| `TZ`                  | `Europe/Madrid`        | Time zone of displayed times|

## Deploying to GitHub Pages

1. Push this repository to GitHub (default branch `main`).
2. In **Settings → Pages**, set **Source** to **GitHub Actions**.
3. Run the workflow once from the **Actions** tab (or push to `main`).
   After that, it rebuilds the page every hour at minute 7.

Note: GitHub may delay scheduled runs during busy periods. It also disables
scheduled workflows in public repositories with no activity for 60 days.
If that happens, re-enable the workflow from the Actions tab.
