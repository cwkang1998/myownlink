# Wiki

This is the wiki for [`myownl.ink`](https://myownl.ink).

## Architecture

![general architecture](./assets/0_general_arch.png)

### Create new shorturl

![create shorturl flow](./assets/1_create_shorturl.png)

### Accessing the shorturl

![access shorturl flow](./assets/2_shorturl_access.png)

### Get report for a shorturl

![get shorturl report](./assets/3_shorturl_report.png)

## Limitations

### Geocoding API Rate Limits

Currently the `geocoder`'s geocoding API is using a free default of `nominatim`, which limits to 1 request a second. This will become problematic when the amount of user scales up, and as such should be switched to a paid API with more limits in production deployment.

## Scaling
