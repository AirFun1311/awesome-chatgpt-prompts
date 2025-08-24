# Performance Plan

## Metrics
- Build latency: `jekyll build` wall time
- Peak RAM during build
- Broken/slow links count (4xx/timeout)

## Benchmarks
- Build time:
  - `/usr/bin/time -v bundle exec jekyll build`
  - `hyperfine 'bundle exec jekyll build --trace' --warmup 1`
- Link check time: `bundle exec htmlproofer ./_site --timeframe 6m`

## Profiling Hotspots
- Use `--trace` to identify slow pages/collections
- Enable verbose logging: `JEKYLL_LOG_LEVEL=debug bundle exec jekyll build`

## Quick Wins
- Cache Bundler (already in CI)
- Exclude non-site dirs (`vendor`, `node_modules`, `.github`, docs)
- Prefer `relative_url` for internal links to avoid redirects
- Minimize external HTTP checks in tests with `--only-4xx`

## Next
- Add sitemap and feed for SEO and crawl efficiency
- Consider incremental rebuilds for local dev: `--incremental`