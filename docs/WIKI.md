# Wiki

This is the wiki for [`myownl.ink`](https://myownl.ink).

## Architecture

![general architecture](./assets/0_general_arch.png)

### Create new short URL

Creating a new short URL involves four main steps:

1. Validate the target URL
2. Fetch the target URL's title tag
3. Persist the title and target URL, producing a database ID
4. Generate the short URL code from the sequential ID

#### 1. Check if target URL is a valid URL

The target URL provided by users is validated before any short URL is created. The validation checks that:

- The URL uses a supported HTTP scheme.
- The URL is not a loopback, local, or private address, reducing the risk of exposing internal services.
- The URL is not already a shortened URL from this application, which prevents self-referential redirects.

#### 2. Fetching the target URL title tag

To fetch the title tag, the application requests the target URL's HTML document and extracts the content inside the document's `<title>` tag. The time required for this step depends on the target site's response time and the amount of HTML that needs to be read.

The current implementation performs this fetch synchronously during short URL creation. This is simple and keeps the data available immediately, but it can add latency to the create flow. If many users create links at the same time, slow target sites can also occupy Rails workers for longer than normal requests.

#### 3. Persisting the title tag and target URL into the database, obtaining an ID

Before the short URL code can be generated, the application stores the extracted title and target URL in the database. PostgreSQL assigns the row a sequential `bigint` `id`, and that ID becomes the input for short URL generation.

#### 4. Generating the short URL code based on the sequential ID

The short URL code is the unique string at the end of the URL path. For example, in `/abc123`, the code is `abc123`. The application generates this code by encoding the database row's `id` with Base62.

Base62 is a good fit because it uses only alphanumeric characters while still representing large numbers compactly. Since the database primary key is unique, the encoded code is also unique. The tradeoff is predictability: because IDs are sequential, short URLs can be guessed by incrementing or decrementing nearby codes.

A 7-character Base62 code space supports more than 3.5 trillion unique values, so the code space is large enough for this service's expected scale.

The route allows codes up to 15 characters, but PostgreSQL `bigint` IDs only support values up to `9,223,372,036,854,775,807`. This is lower than the full `62**15` code space, so decoded values above the `bigint` range must be treated as missing records. Even with that limit, PostgreSQL's `bigint` range is much larger than the 7-character Base62 space described above.

![create shorturl flow](./assets/1_create_shorturl.png)

### Accessing the short URL

When a user opens a short URL, the application first checks the cache for the short code to target URL mapping. If the mapping is not cached, it reads the record from the database. This reduces redirect latency for frequently accessed links and lowers the number of database reads.

Because the application currently has no edit or delete action for short URLs, explicit cache invalidation is not required. Cache entries expire after 12 hours. If mutating actions are added later, cache invalidation should be added at the same time.

Each access also records visit metadata in the database, including the timestamp and geolocation.

![access shorturl flow](./assets/2_shorturl_access.png)

### Get report for a shorturl

The report for a short URL is generated from the short URL access log table. The current implementation reads the access records directly and shows the click count, timestamp, and geolocation for each visit. If reporting becomes expensive, these metrics can be cached or precomputed into an aggregate table.

![get shorturl report](./assets/3_shorturl_report.png)

## UI Component Structure

The UI is implemented with Rails server-rendered ERB and Tailwind CSS. Shared partials are used as component-like building blocks for cards, page containers, buttons, flash messages, and pagination.

## Limitations

### Synchronous fetching of the title tag for the target URL

The target URL's title tag is currently fetched synchronously during short URL creation. The user only receives the short URL after the fetch finishes, so slow target sites can make the create flow feel slower.

A better production approach would be to create and return the short URL first, then fetch the title in a background job and update the record once the title is available.

### Fetching of title tag fails for site with large HTML with current HTML size limit

A limit is set to the size of HTML that will be pulled to the backend. This is currently a fixed value and thus does not work for all sites, especially big sites with large HTML content. As such it might be more ideal to stream HTML in chunks and check for the title tags, rather than setting this fixed limit.

### Short URL to target URL caching

Short URL to target URL mappings are currently cached in memory. This works for a single application process, but it becomes less effective when the service scales horizontally because each process has its own cache. A distributed cache such as Solid Cache or Redis would make cached redirects available across instances.

### Synchronous ShorturlAccess writes

Short URL accesses are currently persisted synchronously during the redirect flow. When someone visits a short URL, the application resolves the target URL, writes a new access log record, and then completes the redirect.

This adds latency to the redirect path, especially because geolocation lookup depends on a third-party service and can take additional time to complete.

An improvement would be to redirect as soon as the target URL is resolved, then enqueue a background job to persist and enrich the access log. That keeps redirects fast while still collecting analytics.

### Geocoding API Rate Limits

The application currently uses `geocoder` with the default free `nominatim` lookup, which is limited to 1 request per second. This is acceptable for a small demo, but it will become a bottleneck as traffic grows. A production deployment should use a paid provider or a higher-capacity geolocation service.

## Further improvements

### Custom 404 pages

When short URL resolution fails, the application currently renders the default 404 page. A custom 404 page for short URL redirects would make the failure clearer and could ask the user to double-check the short URL.

### Reactive frontend

The `show` page could be improved with a reactive frontend that updates the click count and access table as new visits arrive.
