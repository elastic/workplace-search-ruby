# Changelog

## 0.4.1

This version is compatible with Workplace Search v7.6.

### Bug fixes
- Removed extra debug output for end-users (#17)

## 0.4.0

This version is compatible with Workplace Search v7.6.

### Breaking changes

- The old [elastic-enterprise-search](https://rubygems.org/gems/elastic-enterprise-search/) gem has been deprecated and replaced by [elastic-workplace-search](https://rubygems.org/gems/elastic-workplace-search/) to follow the product name change. See [the announcement](https://www.elastic.co/blog/elastic-enterprise-search-updates-for-7-6-0) for more details.
- The API path has been changed from `/api/v1/ent/` to `/api/ws/v1/`.

### How to upgrade

- See the [README](https://github.com/elastic/workplace-search-ruby) for updated installation and usage instructions.
- If you were using a [custom API endpoint](https://github.com/elastic/workplace-search-ruby#change-api-endpoint), update the API path from `/api/v1` to `/api/ws/v1`.

## 0.3.0

This release adds support for the new [permissions API](https://swiftype.com/documentation/enterprise-search/api/document-permissions) in Enterprise Search.

### Features
- Add support for the permissions API (#15)

## 0.2.1

Update the path to the ca bundle (#14)

## 0.2.0

### Bug fixes
- Fixed auto-require in Rails and enabled requiring by gem name, `require 'elastic-enterprise-search'`. (@JasonStoltz in #13 )

## 0.1.0

### Rebranding
This release indicates the rebranding of the client from Swiftype to Elastic namespace:
- We released the new ruby gem [elastic-enterprise-search](https://rubygems.org/gems/elastic-enterprise-search). The old [swiftype-enterprise](https://pypi.org/project/swiftype-enterprise/) package will be deprecated soon.

### How to upgrade
- Rename the package from `swiftype_enterprise` to `elastic_enterprise_search` in your codebase.
- Change references to `SwiftypeEnterpriseClient` to `Client`.
- Change exception name prefixes from `SwiftypeEnterprise` to `EnterpriseSearch`.
